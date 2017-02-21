//
//  RTRedeemDiscountModel.m
//  RoverTown
//
//  Created by Roger Jones Jr on 8/6/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//
#import <UIKit/UIKit.h> 
#import <SDWebImage/UIImageView+WebCache.h>
#import "RTRedeemDiscountModel.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "RTBeaconManager.h"
#import "RTUserContext.h"
#import "RTBluetoothManager.h"
#import "RTBeacon.h"
#import "RTModelBridge.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RTRedeemDiscountModel()<RTBeaconMangerDelegate, UIAlertViewDelegate>

@property (nonatomic) RTStudentDiscount *discount;
@property (nonatomic) BOOL tapFulfilled;
@property (nonatomic) BOOL userBoneCountChanged;
@property (nonatomic) BOOL userBadgeCountChanged;
@property (nonatomic) BOOL isAlreadyInLandscape;

@end

@implementation RTRedeemDiscountModel

- (id)initWithDiscount:(RTStudentDiscount *)discount {
    if (self = [super init]) {
        self.discount = discount;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged) name:kBluetoothStateChangedNotification object:nil];
        if (discount.requiresTap) {
            self.tapFulfilled = NO;
        }
        self.userBoneCountChanged = NO;
        self.userBadgeCountChanged = NO;
        self.isAlreadyInLandscape = NO;

    }
    return  self;
}

-(void)dealloc {
    [RTBeaconManager sharedInstance].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<RTRedeemDiscountModelDelegate>)delegate {
    _delegate = delegate;
    if( !self.discount.isOnlineDiscount ) {
        [self attemptRedeem];
    }
}

- (void)attemptRedeem {
    if (self.discount.requiresTap && !self.tapFulfilled) {
        if (![self isBluetoothOn]) {
            [self.delegate bluetoothOff];
            
        } else {
            NSArray *minorValues = [self.discount.store.beacons valueForKeyPath:@"minor"];
            RTBeaconManager *beaconManager = [RTBeaconManager sharedInstance];
            beaconManager.delegate = self;
            [[RTBeaconManager sharedInstance] redeemBeaconWithMinorValues:minorValues];
        }
        
    }else {
        [self.delegate canRedeem];
    }

}

- (void)redeemWithIsDiscountAccepted:(BOOL)isDiscountAccepted {
    double latitude = [RTLocationManager sharedInstance].latitude;
    double longitude = [RTLocationManager sharedInstance].longitude;
    BOOL inRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:self.discount.store.latitude longitude:self.discount.store.longitude];

    [self.delegate onStartRedeem];
    
    [[RTServerManager sharedInstance] redeemDiscountWithLatitude:latitude longitude:longitude discountId:self.discount.discountId storeId:self.discount.store.storeId isInRange:inRange isAccepted:isDiscountAccepted complete:^(BOOL success, RTAPIResponse *redeemResponse) {
        if(success){
            if( !isDiscountAccepted ) {
                [RTUserContext sharedInstance].redeemCount += 1;
            }
            else {
                NSLog(@"redeem good");
                [self.delegate discountRedeemed:[NSDate date]];
            }
            
        }
        else if( redeemResponse.responseCode == 409 ) {   //Called when redemption has been failed because the discount is already redeemed
            RTLog(@"error - discount is already redeemed");
        }
        else {
            NSLog(@"redeem bad");
        }
        if( isDiscountAccepted ) {
            [RTUserContext sharedInstance].redeemCount += 1;
            [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
                if( success ) {
                    RTUser *user = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
                    [RTUserContext sharedInstance].currentUser = user;
                    if (user.boneCount > [RTUserContext sharedInstance].boneCount) {
                        [RTUserContext sharedInstance].boneCount = user.boneCount;
                        self.userBoneCountChanged = YES;
                    }
                    
                    NSArray *arrayBadgesDicArray = [redeemResponse.jsonObject objectForKey:@"badges"];
                    if( arrayBadgesDicArray.count > 0 ) {
                        self.userBadgeCountChanged = YES;
                    }
                    
                    [RTUserContext sharedInstance].badgeTotalCount = user.badgeCount;
                }
                else {
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate onFinishRedeem];
                    [self.delegate dismissWithBoneCountChanged:self.userBoneCountChanged badgeCountChanged:self.userBadgeCountChanged];
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate discountNotAccepted:self.discount boneCountChanged:NO badgeCountChanged:NO];
            });
        }

    }];
}

- (void)updateBoneCount {
    
}

- (UIImageView *)discountStoreLogo {
    UIImageView *logo = [[UIImageView alloc]init];
    [logo sd_setImageWithURL:[NSURL URLWithString:self.discount.store.logo] placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    return logo;
}

- (NSString *)discountStoreName {
    return self.discount.store.name;
}
    
- (NSString *)discountDescription {
    return self.discount.discountDescription;
}

- (NSString *)discountFinePrint {
    return self.discount.finePrint;
}

- (UIImage *)discountBarcode {
    return [self.discount.code imageForBarCode];
}

- (NSString *)redemptionCode {
   return self.discount.code.value;
}

- (BOOL)folllowingDiscountStore {
    return [self.discount.store.user.following boolValue];
}

- (BOOL)userHasIdPicture {
    return [RTUserContext sharedInstance].studentIdImage ? YES : NO;
}

- (BOOL)discountRequiresTap {
    if(self.discount.requiresTap && !self.tapFulfilled) {
        return YES;
    } else {
        return NO;
    }
}

- (RTDiscountType)discountType {
    if ([self.discount isOnlineDiscount]) {
        return RTDiscountType_Online;
    }
    return RTDiscountType_InStore;
}

- (void)willRotateToOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (!self.isAlreadyInLandscape && !self.discount.isOnlineDiscount) {
            UIImage *image;
            if ([RTUserContext sharedInstance].studentIdImage) {
                image = [RTUserContext sharedInstance].studentIdImage;
            } else {
                image = [UIImage imageNamed:@"show_id"];
            }
            [self.delegate showStudentIdImage:[RTUserContext sharedInstance].studentIdImage];
            self.isAlreadyInLandscape = YES;
        }
    } else {
        [self.delegate showRedeemView];
        self.isAlreadyInLandscape = NO;
    
    }
}

- (void)showWasThisDiscountAcceptedMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Was this discount accepted?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark Bluetooth

- (NSString *)bluetoothState {
    return [[RTBluetoothManager sharedInstance]bluetoothStateString];
}


- (BOOL)isBluetoothOn {
    return [[RTBluetoothManager sharedInstance] isBluetoothOn];
}

- (void)bluetoothStateChanged {
    NSLog(@"changed");
    [self attemptRedeem];
}


#pragma mark RTBeaconManagerDelegate

- (void)proximityImmediate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [RTBeaconManager sharedInstance].delegate = nil;
    self.tapFulfilled = YES;
    [self attemptRedeem];
}

-(void)proximity:(CLProximity)proximity {
    
}
#pragma mark RTRedeemDiscontViewDelegate

- (void)followButtonTapped {
    __block BOOL newFollowingStatus = [self.discount.store.user.following boolValue] ? NO : YES;
    NSString *storeId = [NSString stringWithFormat:@"%d", self.discount.store.storeId];
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:newFollowingStatus complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            self.discount.store.user.following = [NSNumber numberWithBool:newFollowingStatus];
            [self.delegate followStatusChanged];
        }else {
            
        }
    }];
}

- (void)notAcceptedTapped {
    [self.delegate discountNotAccepted:self.discount boneCountChanged:self.userBoneCountChanged badgeCountChanged:NO];
}
- (void)doneButtonTapped {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.discount.discountId], @"discountId", nil];
    if( self.discount.statistics.verified ) {
        [Flurry logEvent:@"user_redeem_complete" withParameters:params];
        [self redeemWithIsDiscountAccepted:YES];
    }
    else {
        [self showWasThisDiscountAcceptedMessage];
    }
    /*
    [self.delegate dismissWithBoneCountChanged:self.userBoneCountChanged badgeCountChanged:self.userBadgeCountChanged];
     */
    
    /*
    if( self.discount.statistics.verified ) { //when the discount is verified
        [self redeem];
//        [self.delegate dismissWithBoneCountChanged:self.userBoneCountChanged badgeCountChanged:self.userBadgeCountChanged];
    }
    else { //when the discount is unverified
        sdfsdf
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Was this discount accepted?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
     */
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.discount.discountId], @"discountId", nil];
    switch (buttonIndex) {
            
        case 0: //No
            [self redeemWithIsDiscountAccepted:NO];
            break;
            
        case 1: //Yes
            [self redeemWithIsDiscountAccepted:YES];
            [Flurry logEvent:@"user_unconfirmed_redeem" withParameters:params];
//            [self.delegate dismissWithBoneCountChanged:self.userBoneCountChanged badgeCountChanged:self.userBadgeCountChanged];
            break;
    }
}


#pragma mark - RTRedeemOnlineDiscountViewDelegate

- (NSString *)getInstructionTextForOnlineDiscount {
    if (self.discount.code.value.length) {
        return kOnlineDiscountRedemptionInstruction_Code;
    }
    return kOnlineDiscountRedemptionInstruction_NoCode;
}

-(void)neverMindButtonTapped {
    [self.delegate dismissWithBoneCountChanged:NO badgeCountChanged:NO];
    
}

- (void)cancelButtonTapped {
    [self.delegate dismissWithBoneCountChanged:NO badgeCountChanged:NO];
}

- (void)redeemOnlineButtonTapped {
    [Flurry logEvent:@"user_discount_online_redeem"];
    NSURL *url = [NSURL URLWithString:self.discount.code.url];
    [[UIApplication sharedApplication] openURL:url];
    [self.delegate dismissWithBoneCountChanged:NO badgeCountChanged:NO];
}

- (void)shareButtonTapped {
    [self.delegate shareDiscount:self.discount];
}

-(BOOL)enableRedeemButton {
    return self.discount.code.url.length ? YES : NO;
}
@end
