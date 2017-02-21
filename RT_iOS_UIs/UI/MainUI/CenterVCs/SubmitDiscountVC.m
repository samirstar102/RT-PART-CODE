//
//  SubmitDiscountVC.m
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SubmitDiscountVC.h"
#import "SubmitDiscountFormMessageVC.h"
#import "SubmitDiscountFormVC.h"
#import "SubmitDiscountFormSuccessVC.h"

#import "RTStoryboardManager.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUserContext.h"
#import "RTUIManager.h"

#define kSISubmitDiscountFormMessageVC          @"SubmitDiscountFormMessageVC"
#define kSISubmitDiscountFormVC                 @"SubmitDiscountFormVC"
#define kSISubmitDiscountFormSuccessVC          @"SubmitDiscountFormSuccessVC"

@interface SubmitDiscountVC () <SubmitDiscountFormMessageVCDelegate, SubmitDiscountFormVCDelegate>
{
    UIViewController *currentViewController;
}

@property (weak, nonatomic) IBOutlet UIView *vwContainer;

@end

@implementation SubmitDiscountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load Form Message View
    [self showFormMessageViewWithAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation Methods

- (void)showFormMessageViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    SubmitDiscountFormMessageVC *formMessageVC = (SubmitDiscountFormMessageVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountFormMessageVC storyboardName:kStoryboardSubmitDiscount];
    formMessageVC.delegate = self;
    formMessageVC.view.frame = self.vwContainer.bounds;
    [formMessageVC.view setAlpha:0.0f];
    [self.vwContainer addSubview:formMessageVC.view];
    [self addChildViewController:formMessageVC];
    [formMessageVC didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = formMessageVC;
            
            [UIView animateWithDuration:duration animations:^{
                [formMessageVC.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = formMessageVC;
        
        [UIView animateWithDuration:duration animations:^{
            [formMessageVC.view setAlpha:1.0f];
        }];
    }
}

- (void)showFormViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    SubmitDiscountFormVC *formVC = (SubmitDiscountFormVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountFormVC storyboardName:kStoryboardSubmitDiscount];
    formVC.delegate = self;
    formVC.view.frame = self.vwContainer.bounds;
    [formVC.view setAlpha:0.0f];
    [self.vwContainer addSubview:formVC.view];
    [self addChildViewController:formVC];
    [formVC didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = formVC;
            
            [UIView animateWithDuration:duration animations:^{
                [formVC.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = formVC;
        
        [UIView animateWithDuration:duration animations:^{
            [formVC.view setAlpha:1.0f];
        }];
    }
}

- (void)showFormSuccessViewWithAnimated:(BOOL)animated boneCountChanged:(BOOL)boneCountChanged {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    SubmitDiscountFormSuccessVC *formSuccessVC = (SubmitDiscountFormSuccessVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountFormSuccessVC storyboardName:kStoryboardSubmitDiscount];
    formSuccessVC.boneCountChanged = YES;
    formSuccessVC.view.frame = self.vwContainer.bounds;
    [formSuccessVC.view setAlpha:0.0f];
    [self.vwContainer addSubview:formSuccessVC.view];
    [self addChildViewController:formSuccessVC];
    [formSuccessVC didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = formSuccessVC;
            
            [UIView animateWithDuration:duration animations:^{
                [formSuccessVC.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = formSuccessVC;
        
        [UIView animateWithDuration:duration animations:^{
            [formSuccessVC.view setAlpha:1.0f];
        }];
    }
}

#pragma mark - SubmitDiscountFormMessageVC Delegate

- (void)formMessageVC:(SubmitDiscountFormMessageVC *)vc onSubmitDiscountButtonClicked:(BOOL)animated {
    [vc dismissViewControllerAnimated:YES completion:nil];
    [self showFormViewWithAnimated:animated];
}

#pragma mark - SubmitDiscountFormVC Delegate

- (void)formVC:(SubmitDiscountFormVC *)vc onSendToRoverTownButtonClicked:(NSString *)businessName businessAddress:(NSString *)businessAddress discount:(NSString *)discount referralSubject:(NSString *)referralSubject {
    
    [[RTUIManager sharedInstance] showProgressHUDWithViewController:self.navigationController labelText:@"Please wait..."];
    [Flurry logEvent:@"user_discount_suggestion"];
    [[RTServerManager sharedInstance] suggestDiscountWithBusinessName:businessName businessAddress:businessAddress discount:discount referralSubject:referralSubject finePrint:nil photo:nil complete:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self.navigationController];
                    
                    BOOL userBoneCountChanged = NO;
                    if( success ) {
                        RTUser *user = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
                        if (user.boneCount != [RTUserContext sharedInstance].currentUser.boneCount) {
                            [RTUserContext sharedInstance].boneCount = user.boneCount;
                            userBoneCountChanged = YES;
                            
                            [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
                            
                            [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                        }
                        [RTUserContext sharedInstance].currentUser = user;
                    }
                    [vc dismissViewControllerAnimated:YES completion:nil];
                    [self showFormSuccessViewWithAnimated:YES boneCountChanged:userBoneCountChanged];
                });
            }];
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self.navigationController];
            });

            if( response.responseCode == 409 ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [vc dismissViewControllerAnimated:YES completion:nil];
                    [self showFormSuccessViewWithAnimated:YES boneCountChanged:NO];
                });
            }
        }
    }];
}

@end
