//
//  RTUIManager.h
//  RoverTown
//
//  Created by Robin Denis on 18/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTDefine.h"

@interface RTUIManager : NSObject

DEFINE_SINGLETON

+ (UIColor *)navBarTintColor;
+ (NSDictionary *)navBarTitleAttributes;
+ (CGFloat)cornerRadiusForContainer;
+ (UIColor *)borderColorForContainer;

#pragma mark - View Styles

/**
 *  Background Color - White
 *  Corner Radius - Default (3dp)
 *  Shadow Radius - Default (3dp)
 *  Shadow Offset - (0, 1)
 *  Shadow Opacity - 0.5
 *  Border Color - Ultimate Light Grey
 **/
+ (void)applyContainerViewStyle:(UIView *)viewContainer;

/**
 *  Apply White Blur View
 **/
+ (void)applyBlurView:(UIView *)view;

/**
 *  Corner Radius - Default (3dp)
 *  Border Color - Ultimate Light Blue
 *  Border Width - 1.0
 **/
+ (void)applyDefaultBorderView:(UIView *)view;

#pragma mark - Button Styles

/**
 *  Background Color - Dark Blue
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyDefaultButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Dark Red
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Small (2dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyDeleteButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Light Blue
 *  Text Color - White
 *  Font Size - REGFONT12
 *  Corner Radius - Small (2dp)
 *  Border Width - 1dp
 *  Border Color - White
 **/
+ (void)applyFollowButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Light Blue
 *  Text Color - White
 *  Font Size - Undefined
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyFollowForUpdatesButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Dark Green
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyRedeemDiscountButtonStyle:(UIButton *)btn;


/**
 *  never mind button
 **/
+ (void)applyNeverMindButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Orange
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyRedeemRewardButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Dark Green
 *  Text Color - White
 *  Font Size - Undefined
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyRateUsPositiveButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Other Green
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Large (6dp)
 *  Border Width - 0.5dp
 *  Border Color - Black
 **/
+ (void)applyReferralCodeSubmitButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Grey
 *  Text Color - White
 *  Font Size - Undefined
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyRateUsNegativeButtonStyle:(UIButton *)btn;

/**
 *  Background Color - Light Grey
 *  Text Color - White
 *  Font Size - REGFONT14
 *  Corner Radius - Default (3dp)
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyCancelRedeemButtonStyle:(UIView *)viewContainer;

/**
 *  Background Color - White
 *  Text Color - Set by parameter
 *  Font Size - Undefined
 *  Corner Radius - Set by parameter
 *  Border Width - 0dp
 *  Border Color - Null
 **/
+ (void)applyWhiteButtonStyle:(UIButton *)btn tintColor:(UIColor *)tintColor alpha:(float)alpha;

#pragma mark - Dropdown Button Styles

/**
 *  Defines a Dropdown Button with Light Grey Bottom Border
 **/
+ (void)applyDropdownButtonWithBottomBorderStyle:(UIButton *)btn;

/**
 *  Defines a Dropdown Button with Light Blue Background and Dark Blue Text
 **/
+ (void)applyDropdownButtonWithBlueBackgroundStyle:(UIButton *)btn;

#pragma mark - Text Field Styles

/**
 *  Background Color - Light Blue
 *  Text Color - Dark Blue
 *  Corner Radius - Default (3dp)
 *  Placeholder Text - Set by Parameter
 **/
+ (void)applyDefaultTextFieldStyle:(UITextField *)tf placeholderText:(NSString *)placeholder;

/**
 *  Background Color - Light Blue
 *  Text Color - Dark Blue
 *  Corner Radius - Default (3dp)
 *  Placeholder Text - @"Enter Your .Edu Email"
 **/
+ (void)applyEmailTextFieldStyle:(UITextField *)tf placeholderText:(NSString *)placeholder;

/**
 *  Background Color - Skin Color
 *  Text Color - Black
 *  Corner Radius - Null
 *  Placeholder Text - Null;
 **/
+ (void)applyReferralCodeTextFieldStyle:(UITextField *)tf;

#pragma mark - UI Animations

/**
 *  Play Earned Bone Animation
 */
+ (void)playEarnBoneAnimationWithSuperview:(UIView *)superView completeBlock:(dispatch_block_t)completeBlock;

/**
 *  Play Earned Badge Animation
 */
+ (void)playEarnBadgeAnimationWithSuperview:(UIView *)superView completeBlock:(dispatch_block_t)completeBlock;

/**
 *  Show Bone Message
 */
- (void)showBoneMessageWithParentView:(UIView *)parentView messageText:(NSString *)text animating:(BOOL)animating textColor:(UIColor *)textColor textFont:(UIFont *)textFont;

#pragma mark - Table View Refresh Animation

/**
 *  Show Table View Refresh Animation
 */
+ (void)showProgressIndicator : (UITableView *)tableView frameWidth:(int)frameWidth;

/**
 *  Hide Table View Refresh Animation
 */
+ (void)hideProgressIndicator : (UITableView *)tableView;

#pragma mark - Alert View

/**
 *  Show Alert View on prior versions to iOS 8 and later versions
 **/
+ (void)alertWithTitle:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle parentVC:(UIViewController *)parentVC handler:(void (^)(UIAlertAction *action))handler;

#pragma mark - Progress HUDs

/**
 *  Show Progress HUD with Simple Label Text
 **/
- (void)showProgressHUDWithViewController:(UIViewController *)vc labelText:(NSString *)labelText;

/**
 *  Hides All Progress HUDs in a View Controller
 **/
- (void)hideProgressHUDWithViewController:(UIViewController *)vc;

/**
 *  Show Toast Messasge
 **/
- (void)showToastMessageWithViewController:(UIViewController *)vc labelText:(NSString *)labelText descriptionText:(NSString *)descriptionText;

- (void)showToastMessageWithViewController:(UIViewController *)viewController description:(NSString *)description;

- (void)showToastMessageWithView:(UIView *)view labelText:(NSString *)labelText descriptionText:(NSString *)descriptionText;
- (void)showPageLoadingSpinnerWithView:(UIView *)view;
- (void)hidePageLoadingSpinner;
@end
