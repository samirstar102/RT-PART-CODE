//
//  RTRedeemDiscountViewController.m
//  RoverTown
//
//  Created by Roger Jones Jr on 8/4/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTRedeemDiscountViewController.h"
#import "RTRedeemDiscountView.h"
#import "RTRedeemOnlineDiscountView.h"
#import "AppDelegate.h"
#import "RTUIManager.h"
#import "RTShareViewController.h"
#import "UIViewController+MMDrawerController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RTRedeemDiscountViewController ()<RTRedeemDiscountModelDelegate, RTShareViewControllerDelegate>
@property (nonatomic) UIView *redeemView;
@property (nonatomic) RTRedeemDiscountModel *model;
@property (nonatomic) UIAlertView *alertViewForBluetooth;
@property (nonatomic) RTShareViewController *shareViewController;

@end

@implementation RTRedeemDiscountViewController

- (id)initWithModel:(RTRedeemDiscountModel *)model {
    if (self = [super init]) {
        self.model = model;
        self.redeemView = [self getRedeemViewByDiscount];
        self.view  = self.redeemView;
        self.model.delegate = self;
        [self setTitle:@"Redeem"];
    }
    return self;
}

- (UIView *)getRedeemViewByDiscount {
    UIImageView *logo = [self.model discountStoreLogo];
    NSString *storeName = [self.model discountStoreName];
    NSString *description = [self.model discountDescription];
    NSString *finePrint = [self.model discountFinePrint];
    NSString *redemptionCode = [self.model redemptionCode];
    UIImage *barCode = [self.model discountBarcode];
    BOOL following = self.model.folllowingDiscountStore;
    BOOL requiresTap = self.model.discountRequiresTap;
    if ([self.model discountType] == RTDiscountType_Online) {
        return [[RTRedeemOnlineDiscountView alloc]initWithFrame:self.view.bounds storeName:storeName description:description middelImageView:nil redemptionCode:redemptionCode delegate:self.model];
    } else {
        return [[RTRedeemDiscountView alloc]initWithFrame:self.view.bounds logo:logo storeName:storeName description:description finePrint:finePrint barCode:barCode following:following tapToRedeem:requiresTap delegate:self.model];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackableNavBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self.model discountRequiresTap]) {
        [self allowRotations];
    }
    if (self.model.discountType == RTDiscountType_Online) {
        [self disableRotations];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isAvailableLandscape = NO;
    [self disableRotations];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.model willRotateToOrientation:toInterfaceOrientation];
}


#pragma mark RTRedeemDiscountModelDelegate

- (void)canRedeem {
    [(RTRedeemDiscountView *)self.redeemView switchToRedeem];
    if ([self.model userHasIdPicture]) {
        [self allowRotations];}
}


- (void)allowRotations {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isAvailableLandscape = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    self.mm_drawerController.shouldAllow = YES;
}

- (void)handleDidChangeStatusBarOrientationNotification:(NSNotification *)notification;
{
    // Do something interesting
    NSLog(@"The orientation is %@", [notification.userInfo objectForKey: UIApplicationStatusBarOrientationUserInfoKey]);
}

- (void)disableRotations {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isAvailableLandscape = NO;
    self.mm_drawerController.shouldAllow = NO;
}

- (void)showRedeemView {
    [(RTRedeemDiscountView *)self.redeemView removeStudentIdImage];
    [self.redeemView layoutSubviews];
}


- (void)showStudentIdImage:(UIImage *)studentIdImage {
    [(RTRedeemDiscountView *)self.redeemView showStudentIdImage:studentIdImage];
}

- (void)hideStudentIdImage:(UIImage *)studentIdImage {
    [(RTRedeemDiscountView *)self.redeemView removeStudentIdImage];
}

- (void)followStatusChanged {
    BOOL following = [self.model folllowingDiscountStore];
    [(RTRedeemDiscountView *)self.redeemView setFollowButtonEnabled:following];
    [self.delegate changeFollowing:following];
}

- (void)dismissWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged{
    [self.delegate boneAndBadgeCountChangedWithBoneCountChanged:boneCountChanged badgeCountChanged:badgeCountChanged];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)discountRedeemed:(NSDate *)redeemDate {
    [(RTRedeemDiscountView *)self.redeemView discountRedeemedAt:redeemDate];
}

- (void)bluetoothOff {
    NSString *alertMsg = [self.model bluetoothState];
    self.alertViewForBluetooth = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In order to redeem this discount you must turn your bluetooth on!", nil) message:alertMsg delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];
    [self.alertViewForBluetooth show];
}

- (void)bluetoothStatusChanges {
    if (![self.model isBluetoothOn]) {
       
    } else {
        
    }
}

- (void)discountNotAccepted:(RTStudentDiscount *)discount boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    [self.delegate discountUnaccepted:discount boneCountChanged:boneCountChanged badgeCountChanged:badgeCountChanged];
    [self.navigationController popViewControllerAnimated:YES];
   
}

- (void)onStartRedeem {
    [[RTUIManager sharedInstance] showProgressHUDWithViewController:self labelText:@"Please wait..."];
}

- (void)onFinishRedeem {
    
    [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self];
}

- (void)shareDiscount:(RTStudentDiscount *)discount{
    if (!self.shareViewController) {
        self.shareViewController = [[RTShareViewController alloc]initWithDiscount:discount];
        self.shareViewController.delegate = self;
    }
    [self addChildViewController:self.shareViewController];
    [self.shareViewController showShareViewFromView:self.view];
}

#pragma mark RTShareViewControllerDelegate

- (void)shareViewControllerDone {
    [self.shareViewController removeFromParentViewController];
}
@end
