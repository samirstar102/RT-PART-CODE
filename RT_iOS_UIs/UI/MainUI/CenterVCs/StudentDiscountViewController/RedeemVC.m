//
//  RedeemViewController.m
//  RoverTown
//
//  Created by Robin Denis on 5/20/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RedeemVC.h"
#import "RTUIManager.h"
#import "SessionMgr.h"
#import "RTLocationManager.h"
#import "ZXMultiFormatWriter.h"
#import "ZXImage.h"
#import "ZXDataMatrixWriter.h"
#import "RTUserContext.h"
#import "AppDelegate.h"
#import "RTServerManager.h"
#import "NSDate+Utilities.h"
#import "RTModelBridge.h"
#import "RTBluetoothManager.h"
#import "RTMotionManager.h"
#import "UIColor+Config.h"
#import "RTStoryboardManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kAlertTagBluetoothSetting   (10000)
#define kAlertTagAcceptDiscount     (10001)

@interface RedeemVC () <UIAlertViewDelegate>
{
    NSTimer *animationTimer;
    BOOL bAnimationShowing;
    BOOL bBadgeCountChanged;
    BOOL bStatusBarHidden;
    BOOL bRelayout;
    BOOL bIsInRange;
    BOOL bRedeemSucceeded;
    int nIndicator;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForDiscountNotAcceptedButton;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForFinePrintTextview;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForFollowerRewardLabel;
    __weak IBOutlet NSLayoutConstraint *topConstraintForFollowerRewardLabel;
}

@property (weak, nonatomic) IBOutlet UIView *portraitView;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *discountNotAcceptedButton;
@property (weak, nonatomic) IBOutlet UILabel *redeemedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *txtFinePrint;

@property (weak, nonatomic) IBOutlet UIView *landscapeView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ivPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *labelNoImage;
@property (weak, nonatomic) IBOutlet UIImageView *animationImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *animationImageView2;

@property (nonatomic, retain) UIAlertView *alertViewForBluetooth;

- (IBAction)doneClicked:(id)sender;
- (IBAction)followClicked:(id)sender;
- (IBAction)supportClicked:(id)sender;

@end

@implementation RedeemVC

@synthesize discount, isRewardRedemption;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    bAnimationShowing = YES;
    bBadgeCountChanged = NO;
    nIndicator = 0;
    bStatusBarHidden = YES;
    bRelayout = NO;
    
    //Hides Discount Not Accepted button
    heightConstraintForDiscountNotAcceptedButton.constant = 0.0f;
    
    //Hides follower reward label if this redemption is not for follower reward
    if( !self.isRewardRedemption ) {
        heightConstraintForFollowerRewardLabel.constant = 0.0f;
        topConstraintForFollowerRewardLabel.constant = 0.0f;
    }
    else {
        [self.followerRewardLabel setTextColor:[UIColor roverTownColorOrange]];
    }
    
    [self.navigationController setNavigationBarHidden:YES];
    [RTUIManager applyCancelRedeemButtonStyle:_doneButton];
    [RTUIManager applyFollowForUpdatesButtonStyle:_followButton];
    [self.doneButton setTitle:@"Cancel Redeem" forState:UIControlStateNormal];
    
    [self.followButton setAlpha:0.0f];
    
    //Hide Bar code View.
    [self.QRCodeImageView setAlpha:0.0f];
    
    if( discount != nil ) {
        bIsInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:discount.store.latitude longitude:discount.store.longitude];
        
        //Set image of logo
        [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:discount.store.logo]
                       placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
        
        //Initialize description label
        self.storeNameLabel.text = discount.store.name;
        
        //Initialize description label
        self.descriptionLabel.text = discount.discountDescription;
        
        //Initialize fine print label
        [self.txtFinePrint setText:discount.finePrint];
        UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 48, 100)];
        [lblTemp setNumberOfLines:0];
        [lblTemp setText:discount.finePrint];
        [lblTemp setFont:REGFONT12];
        [lblTemp sizeToFit];
        
        //Set or remove border of fine print label if the height is bigger than 90pt
        if( lblTemp.frame.size.height + 16 < 90 ) {
            [self.txtFinePrint setTextContainerInset:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
            [self.txtFinePrint setContentInset:UIEdgeInsetsZero];
            [self.txtFinePrint setTextAlignment:NSTextAlignmentCenter];

            heightConstraintForFinePrintTextview.constant = lblTemp.frame.size.height;
        } else {
            [self.txtFinePrint setTextContainerInset:UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f)];
            [self.txtFinePrint setContentInset:UIEdgeInsetsZero];
            [self.txtFinePrint setTextAlignment:NSTextAlignmentLeft];
            [self.txtFinePrint.layer setBorderColor:[UIColor roverTownColor999999].CGColor];
            [self.txtFinePrint.layer setBorderWidth:1.0f];
        }
        
        if( discount.requiresTap ) {
            //Load Animation View
            [self startTapAnimation];
        }
        else {
            [self goRedeemDone];
            /*
            if( discount.statistics.verified ) {
                [self callRedeemDiscount:discount isDiscountAccepted:YES];
            }
            else {
                [self showWasThisAccountAcceptedAlertView];
            }
            */
        }
        
        //Initialize redeemed time label
        [self.redeemedTimeLabel setText:@"Tap your phone to the beacon near the cash register to redeem this student discount."];
        
        //Initialize follow button
        [self setFollowButtonEnabled:[discount.store.user.following boolValue]];
        
        //Initialize QR code
        if( !discount.code.exist || [discount.code.encode_format isEqualToString:@""] || [discount.code.value isEqualToString:@""] ) {
            UIImage *image = [UIImage imageNamed:@"bone_icon_no_barcode"];
            [self.QRCodeImageView setImage:image];
        }
        else {
//            NSError *error = nil;
//            
//            ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
//        
//            ZXBitMatrix *result;
//            @try {
//                int width = 14, height = 80;
//                
////                ZXBarcodeFormat barcodeFormat = [RTModelBridge barcodeFormatWithString:discount.code.encode_format];
//                
//                if( barcodeFormat == kBarcodeFormatQRCode ) {
//                    width = 200;
//                    height = 200;
//                }
//
////                result = [writer encode:discount.code.value
////                                 format:[RTModelBridge barcodeFormatWithString:discount.code.encode_format]
////                                  width:width
////                                 height:height
////                                  error:&error];
////
//                if (result) {
//                    CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
//                    
//                    UIImage *uiImage = [UIImage imageWithCGImage:image];
//                    [self.QRCodeImageView setImage:uiImage];
//                } else {
//                    NSString *errorMessage = [error localizedDescription];
//                    NSLog(@"%@", errorMessage);
//                }
//            }
//            @catch (NSException *e) {
//                NSLog(@"%@", e.description);
//                UIImage *image = [UIImage imageNamed:@"bone_icon_no_barcode"];
//                [self.QRCodeImageView setImage:image];
//            }
        }
    }

    if ([RTUserContext sharedInstance].studentIdImage != nil) {
        self.ivPlaceholder.hidden = YES;
        self.labelNoImage.hidden = YES;
        
        self.profileImageView.image = [RTUserContext sharedInstance].studentIdImage;
    }
    else {
        self.ivPlaceholder.hidden = NO;
        self.labelNoImage.hidden = NO;
        
        self.profileImageView.image = nil;
        self.profileImageView.backgroundColor = [UIColor blackColor];
    }

    //Hides status bar
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBluetoothStateChanged) name:kBluetoothStateChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // available to rotate
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isAvailableLandscape = YES;
    
    // apply orientation
    //UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    //[self applyOrientation:orientation];
    
    [[RTMotionManager sharedInstance] startDeviceMotionUpdateWithTapHandler:^{
        [[RTMotionManager sharedInstance] stopDeviceMotionUpdate];
        
        // check bluetooth state
        BOOL isBluetoothOn = [[RTBluetoothManager sharedInstance] isBluetoothOn];
        if (!isBluetoothOn) {
            NSString *alertMsg = [[RTBluetoothManager sharedInstance] bluetoothStateString];
            self.alertViewForBluetooth = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Turn On Bluetooth to sort student discounts nearest to beacons.", nil) message:alertMsg delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];
            [self.alertViewForBluetooth setTag:kAlertTagBluetoothSetting];
            [self.alertViewForBluetooth show];
            return;
        }
        else {
            [self goRedeemDone];
//            if( discount.statistics.verified ) {
//                [self callRedeemDiscount:discount isDiscountAccepted:YES];
//            }
//            else {
//                [self showWasThisAccountAcceptedAlertView];
//            }
            
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // un-available to rotate
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isAvailableLandscape = NO;
    
    [[RTMotionManager sharedInstance] stopDeviceMotionUpdate];
}

- (BOOL)prefersStatusBarHidden {
    if( bStatusBarHidden ) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!bRelayout) {
        [self.descriptionLabel setNumberOfLines:0];
        [self.descriptionLabel sizeToFit];
        [self.storeNameLabel setNumberOfLines:0];
        [self.storeNameLabel sizeToFit];
        self.QRCodeImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            [self.view setNeedsLayout];
        
        bRelayout = YES;
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)doneClicked:(id)sender {
    
    if (self.discount.statistics.verified ) {
        [self callRedeemDiscount:discount isDiscountAccepted:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Was this discount accepted?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert setTag:kAlertTagAcceptDiscount];
        [alert show];
    }
//    if( bAnimationShowing ) {   //When tap animation is showing
//        // cancel clicked
//        [self showStatusBar];
//        if (self.delegate != nil) {
//            [self.delegate redeemVCDidCancel:self];
//        }
//        else {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//    else {    //When bar code is displayed
////        [self onRedeemDidDone];
//        
//        if( discount.statistics.verified ) { //when the discount is verified
//            [self callRedeemDiscount:discount isDiscountAccepted:YES];
//        }
//        else { //when the discount is unverified
//            if (discount.store.beacons.count == 0) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Was this discount accepted?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//                [alert setTag:kAlertTagAcceptDiscount];
//                [alert show];
//            }
//        }
//    }
}

- (IBAction)followClicked:(id)sender {
    NSString *storeId = [NSString stringWithFormat:@"%d", discount.store.storeId];
    
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:![discount.store.user.following boolValue] complete:^(BOOL success, RTAPIResponse *response){
        if( success ) {
            BOOL bState = ![discount.store.user.following boolValue];
            discount.store.user.following = [NSNumber numberWithBool:bState];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( self.delegate != nil ) {
                    [self.delegate redeemVC:self onChangeFollowing:bState storeId:discount.store.storeId];
                }
                
                [self setFollowButtonEnabled:bState];
            });
        }
        else {
            //
        }
        [self.followButton setEnabled:YES];
    }];
}

- (IBAction)supportClicked:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showStatusBar];
    });
    
    if( self.delegate != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate redeemVC:self onDiscountUnaccepted:discount.discountId boneCountChanged:bIsInRange & bRedeemSucceeded badgeCountChanged:bBadgeCountChanged];
        });
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)goRedeemDone {
    [UIView animateWithDuration:0.3f animations:^{
        [self.animationImageView1 setAlpha:0.0f];
        [self.animationImageView2 setAlpha:0.0f];
        [self.QRCodeImageView setAlpha:1.0f];
        
        if( isRewardRedemption ) {  //if this is redemption is for a reward
            [self.followButton setAlpha:0.0f];
            [self.doneButton setBackgroundColor:[UIColor roverTownColorOrange]];
        }
        else {
            [self.followButton setAlpha:1.0f];//Initialize Redeem Button
            [RTUIManager applyRedeemDiscountButtonStyle:_doneButton];
        }
        
        heightConstraintForDiscountNotAcceptedButton.constant = 28;
    }];

    [self stopTapAnimation];
    
    //Initialize redeemed time label
    NSDate *redeemedAt = [NSDate date];
    NSString *dateString = [redeemedAt stringWithFormat:@"'Redeemed on' M/d/yyyy 'at' hh:mm a"];
    
    self.redeemedTimeLabel.text = dateString;
    
    [self.doneButton setTitle:@"I\'m done" forState:UIControlStateNormal];
    
    bAnimationShowing = NO;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self applyOrientation:toInterfaceOrientation];
}

- (void)applyOrientation:(UIInterfaceOrientation)orientation {
    if( UIInterfaceOrientationIsLandscape(orientation) ) {
        _portraitView.hidden = YES;
        _landscapeView.hidden = NO;
    }
    else {
        _portraitView.hidden = NO;
        _landscapeView.hidden = YES;
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)startTapAnimation {
    [self.animationImageView1 setImage:[UIImage imageNamed:@"redeem_tap1"]];
    [self.animationImageView2 setAlpha:0.0f];
    [self.animationImageView2 setImage:[UIImage imageNamed:@"redeem_tap2"]];
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tapAnimation) userInfo:nil repeats:YES];
}

- (void)stopTapAnimation {
    if( animationTimer ) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

- (void)tapAnimation {
    [UIView animateWithDuration:0.2f animations:^{
        if( (nIndicator++) % 2 ) {
            [self.animationImageView1 setAlpha:1.0f];
            [self.animationImageView2 setAlpha:0.0f];
        }
        else {
            [self.animationImageView1 setAlpha:0.0f];
            [self.animationImageView2 setAlpha:1.0f];
        }
    }];
}

- (void)showStatusBar {
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else {
        bStatusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)onRedeemDidDone {
    [RTUserContext sharedInstance].redeemCount += 1;
    
    [self.doneButton setUserInteractionEnabled:NO];
    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            RTUser *user = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
            
            [RTUserContext sharedInstance].currentUser = user;
            [RTUserContext sharedInstance].boneCount = user.boneCount;
            [RTUserContext sharedInstance].badgeTotalCount = user.badgeCount;
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.doneButton setUserInteractionEnabled:YES];
            [self showStatusBar];
        });
        
        if (self.delegate != nil) {
            [self.delegate redeemVCDidDone:self boneCountChanged:bIsInRange & bRedeemSucceeded badgeCountChanged:bBadgeCountChanged];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Alerts

- (void)showWasThisAccountAcceptedAlertView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Was this discount accepted?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert setTag:kAlertTagAcceptDiscount];
    [alert show];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( alertView.tag == kAlertTagAcceptDiscount ) {
        switch( buttonIndex ) {
            case 0:     //NO button
            {
                [self callRedeemDiscount:discount isDiscountAccepted:NO];
                
                break;
            }
            case 1:     //YES button
                [self callRedeemDiscount:discount isDiscountAccepted:YES];
//                [self onRedeemDidDone];
                
                break;
        }
    }
    else if (alertView.tag == kAlertTagBluetoothSetting) {
        self.alertViewForBluetooth = nil;
        
        if (buttonIndex == 0) {
            //Check if system is prior to 8.0 or not
            if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
        else {
            ///***/// [self goRedeemDone];
            if( discount.statistics.verified ) {
                [self callRedeemDiscount:discount isDiscountAccepted:YES];
            }
            else {
                [self showWasThisAccountAcceptedAlertView];
            }
        }
    }
}

#pragma mark - bluetooth state changed event handler

- (void)onBluetoothStateChanged {
    if (self.alertViewForBluetooth != nil) {
        [self.alertViewForBluetooth dismissWithClickedButtonIndex:1 animated:YES];
    }
}

#pragma mark - Follow Button manipulation

- (void)setFollowButtonEnabled:(BOOL)isEnable {
    if( isEnable ) {
        [self.followButton setImage:[UIImage imageNamed:@"check_icon"] forState:UIControlStateNormal];
        [self.followButton setTitle:@" Following" forState:UIControlStateNormal];
    }
    else {
        [self.followButton setImage:nil forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow for updates" forState:UIControlStateNormal];
    }
}

#pragma mark - Service

- (void)callRedeemDiscount:(RTStudentDiscount *)studentDiscount isDiscountAccepted:(BOOL)isDiscountAccepted {
    [[RTUIManager sharedInstance] showProgressHUDWithViewController:self labelText:@"Please wait..."];
    
    // call api for redeem discount
    double latitude = [RTLocationManager sharedInstance].latitude;
    double longitude = [RTLocationManager sharedInstance].longitude;
    
    bIsInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:studentDiscount.store.latitude longitude:studentDiscount.store.longitude];
    
    [[RTServerManager sharedInstance] redeemDiscountWithLatitude:latitude longitude:longitude discountId:studentDiscount.discountId storeId:studentDiscount.store.storeId isInRange:bIsInRange isAccepted:isDiscountAccepted complete:^(BOOL success, RTAPIResponse *redeemResponse) {
        
        if( success ) {
            if( !isDiscountAccepted ) {
                [RTUserContext sharedInstance].redeemCount += 1;
                
            }
            else {
                NSArray *arrayBadgesDicArray = [redeemResponse.jsonObject objectForKey:@"badges"];
                
                if( [RTUserContext sharedInstance].badgeTotalCount < arrayBadgesDicArray.count ) {
                    bBadgeCountChanged = YES;
                }
                
                [RTUserContext sharedInstance].badgeTotalCount = (int)arrayBadgesDicArray.count;
            }
        }
        else if( redeemResponse.responseCode == 409 ) {
            RTLog(@"error - discount was already redeemed");
        }
        else {
            RTLog(@"error - redeemDiscount failed");
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self];
        });
        
        if( isDiscountAccepted ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RTUserContext sharedInstance].redeemCount += 1;
                [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
                    if (success) {
                        RTUser *user = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
                        [RTUserContext sharedInstance].currentUser = user;
                        if (user.boneCount != [RTUserContext sharedInstance].boneCount) {
                            [RTUserContext sharedInstance].boneCount = user.boneCount;
                            // add bonecount status changed bool
                        }
                        if (user.badgeCount != [RTUserContext sharedInstance].badgeTotalCount) {
                            [RTUserContext sharedInstance].badgeTotalCount = user.badgeCount;
                            // add badgeCount status changed bool
                        }
                        
                        NSArray *arrayBadgesDicArray = [redeemResponse.jsonObject objectForKey:@"badges"];
                        if ( [RTUserContext sharedInstance].badgeTotalCount < arrayBadgesDicArray.count ) {
                            // badge count changed
                        }
                        [RTUserContext sharedInstance].badgeTotalCount = (int) arrayBadgesDicArray.count;
                    }
                }];
                bRedeemSucceeded = success;
                [self onRedeemDidDone];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showStatusBar];
                if (self.delegate != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate redeemVC:self onDiscountUnaccepted:discount.discountId boneCountChanged:bIsInRange & bRedeemSucceeded badgeCountChanged:bBadgeCountChanged];
                    });
                }
                else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    }];
}

@end
