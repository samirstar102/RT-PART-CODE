//
//  RTUIManager.m
//  RoverTown
//
//  Created by Robin Denis on 18/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTUIManager.h"
#import "UIColor+Config.h"
#import "MBProgressHUD.h"

typedef void (^AlertHandler)(UIAlertAction *);

@interface RTUIManager () <UIAlertViewDelegate>

@property (nonatomic, assign) AlertHandler alertHandler;
@property (nonatomic) UIView *spinnerView;

@end


@implementation RTUIManager

IMPLEMENT_SINGLETON

+ (UIColor *)navBarTintColor {
    return [UIColor colorWithRed:(float)0x0C/0xff green:(float)0x56/0xff blue:(float)0x8D/0xff alpha:1.0];
}

+ (NSDictionary *)navBarTitleAttributes {
    return @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: MEDFONT18};
}

+ (CGFloat)cornerRadiusForContainer {
    return kCornerRadiusDefault;
}

+ (UIColor *)borderColorForContainer {
    return [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
}

+ (void)applyNormalButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.layer.cornerRadius = kCornerRadiusDefault;
    [btn.titleLabel setFont:REGFONT14];

}

+ (void)applyDefaultButtonStyle:(UIButton *)btn {
    [self applyNormalButtonStyle:btn];
    btn.backgroundColor = [UIColor colorWithRed:0 green:86/255.0 blue:137/255.0 alpha:1];
}

+ (void)applyDeleteButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:191/255.0 green:26/255.0 blue:50/255.0 alpha:1];
    
    btn.layer.cornerRadius = kCornerRadiusSmall;
    
    [btn.titleLabel setFont:REGFONT14];
}

+ (void)applyRedeemDiscountButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(159.0/255.0f) blue:(78.0/255.0f) alpha:1.0f];
   
    btn.layer.cornerRadius = kCornerRadiusDefault;
    
    [btn.titleLabel setFont:REGFONT14];
}

+ (void)applyRedeemRewardButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor roverTownColorOrange];
    
    btn.layer.cornerRadius = kCornerRadiusDefault;
    
    [btn.titleLabel setFont:REGFONT14];
}

+ (void)applyCancelRedeemButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(168.0/255.0f) green:(169.0/255.0f) blue:(173.0/255.0f) alpha:1.0f];
    
    btn.layer.cornerRadius = kCornerRadiusDefault;
    
    [btn.titleLabel setFont:REGFONT14];
}

+ (void)applyFollowButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(173.0/255.0f) blue:(226.0/255.0f) alpha:1.0f];
    
    btn.layer.cornerRadius = kCornerRadiusSmall;
    
    [btn.titleLabel setFont:REGFONT12];
    
    [btn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [btn.layer setBorderWidth:1.0f];
}

+ (void)applyNeverMindButtonStyle:(UIButton *)btn {
    [self applyNormalButtonStyle:btn];
    [btn setBackgroundColor:[UIColor lightGrayColor]];
}

+ (void)applyFollowForUpdatesButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(173.0/255.0f) blue:(226.0/255.0f) alpha:1.0f];
    
    btn.layer.cornerRadius = kCornerRadiusDefault;
}

+ (void)applyRateUsPositiveButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(159.0/255.0f) blue:(78.0/255.0f) alpha:1.0f];
    
    btn.layer.cornerRadius = kCornerRadiusDefault;
}

+ (void)applyRateUsNegativeButtonStyle:(UIButton *)btn {
    btn.tintColor = [UIColor whiteColor];
    btn.backgroundColor = [UIColor colorWithRed:(129.0/255.0f) green:(130.0/255.0f) blue:(134.0/255.0f) alpha:1.0f];
    
    btn.layer.cornerRadius = kCornerRadiusDefault;
}

+ (void)applyReferralCodeSubmitButtonStyle:(UIButton *)btn {
    [btn.layer setCornerRadius:kCornerRadiusLarge];
    [btn.layer setBorderWidth:0.5f];
    [btn.layer setBorderColor:[UIColor blackColor].CGColor];
    [btn setBackgroundColor:[UIColor colorWithRed:23.0f/255.0f green:165.0f/255.0f blue:84.0f/255.0f alpha:1.0f]];
}

+ (void)applyWhiteButtonStyle:(UIButton *)btn tintColor:(UIColor *)tintColor alpha:(float)alpha {
    btn.tintColor = tintColor;
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.cornerRadius = kCornerRadiusDefault;
    btn.alpha = alpha;
}

+ (void)applyContainerViewStyle:(UIView *)viewContainer {
    viewContainer.backgroundColor = [UIColor whiteColor];
    viewContainer.layer.cornerRadius = [RTUIManager cornerRadiusForContainer];
    
    viewContainer.layer.shadowRadius = kCornerRadiusDefault;
    viewContainer.layer.shadowOffset = CGSizeMake(0, 1);
    viewContainer.layer.shadowOpacity = 0.5;
    
    viewContainer.layer.borderColor = [RTUIManager borderColorForContainer].CGColor;
}

+ (void)applyBlurView:(UIView *)view {
    if( [view subviews].count > 0 && [[[view subviews] objectAtIndex:0] isKindOfClass:[UIVisualEffectView class]]) {
        return;
    }
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        beView.frame = view.bounds;
        
        view.backgroundColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.01f];
        
        [view insertSubview:beView atIndex:0];
    }
    else {
        [view setBackgroundColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.9f]];
    }
}

+ (void)applyDefaultBorderView:(UIView *)view {
    UIColor *borderColor = [UIColor roverTownColor6DA6CE];
    
    [view.layer setBorderColor:borderColor.CGColor];
    [view.layer setBorderWidth:1.0f];
    [view.layer setCornerRadius:kCornerRadiusDefault];
}

+ (void)applyEmailTextFieldStyle:(UITextField *)tf placeholderText:(NSString *)placeholder {
    tf.layer.cornerRadius = kCornerRadiusDefault;
    [tf setBackgroundColor:[UIColor roverTownColor6DA6CE_Opacity35]];
    UIColor *color = [UIColor roverTownColor6DA6CE_Opacity70];
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:color}];
    //set left margin for new email textfield
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, tf.frame.size.height)];
    [leftView setBackgroundColor:[UIColor clearColor]];
    tf.leftView = leftView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    //set the text color of new email textfield
    [tf setTextColor:[UIColor roverTownColorDarkBlue]];
}

+ (void)applyReferralCodeTextFieldStyle:(UITextField *)tf {
    UIColor *bgColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    
    [tf setBackgroundColor:bgColor];
    //set left margin for new email textfield
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, tf.frame.size.height)];
    [leftView setBackgroundColor:bgColor];
    tf.leftView = leftView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    //set the text color of new email textfield
    [tf setTextColor:[UIColor blackColor]];
    
    //Sets Border
    [tf.layer setCornerRadius:0.0f];
    [tf.layer setMasksToBounds:YES];
    [tf.layer setBorderColor:[UIColor blackColor].CGColor];
    [tf.layer setBorderWidth:0.5f];
}

+ (void)applyDefaultTextFieldStyle:(UITextField *)tf placeholderText:(NSString *)placeholder {
    tf.layer.cornerRadius = kCornerRadiusDefault;
    [tf setBackgroundColor:[UIColor roverTownColor6DA6CE_Opacity35]];
    UIColor *color = [UIColor roverTownColor6DA6CE_Opacity70];
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(placeholder, nil) attributes:@{NSForegroundColorAttributeName:color}];
    //set left margin for new email textfield
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, tf.frame.size.height)];
    [leftView setBackgroundColor:[UIColor clearColor]];
    tf.leftView = leftView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    //set the text color of new email textfield
    [tf setTextColor:[UIColor roverTownColorDarkBlue]];
}

+ (void)applyDropdownButtonWithBottomBorderStyle:(UIButton *)btn {
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, btn.bounds.size.height - 1.0f, btn.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [btn.layer addSublayer:bottomBorder];
    UIEdgeInsets edgeInsets = btn.contentEdgeInsets;
    [btn setContentEdgeInsets:UIEdgeInsetsMake(edgeInsets.top, 8, edgeInsets.bottom, edgeInsets.right)];
}

+ (void)applyDropdownButtonWithBlueBackgroundStyle:(UIButton *)btn {
    UIEdgeInsets edgeInsets = btn.contentEdgeInsets;
    [btn setContentEdgeInsets:UIEdgeInsetsMake(edgeInsets.top, 8, edgeInsets.bottom, edgeInsets.right)];
    [btn setBackgroundColor:[UIColor roverTownColor6DA6CE_Opacity35]];
    [btn.titleLabel setTextColor:[UIColor roverTownColorDarkBlue]];
}

+ (BOOL)isiOS8OrAbove {
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0"
                                                                       options: NSNumericSearch];
    return (order == NSOrderedSame || order == NSOrderedDescending);
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([RTUIManager sharedInstance].alertHandler != nil) {
        [RTUIManager sharedInstance].alertHandler(nil);
    }
}

#pragma mark - UITableView progress indicator

+ (void)showProgressIndicator : (UITableView *)tableView frameWidth:(int)frameWidth {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 64)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 32)];
    imageView.image = [UIImage imageNamed:@"refresh"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = INFINITY;
    [imageView.layer addAnimation:animation forKey:@"SpinAnimation"];
    
    [footerView addSubview:imageView];
    
    tableView.tableFooterView = footerView;
}

+ (void)hideProgressIndicator : (UITableView *)tableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableFooterView = footerView;
}

#pragma mark - Earned bone & badge Animation

+ (void)playEarnBoneAnimationWithSuperview:(UIView *)superView completeBlock:(dispatch_block_t)completeBlock {
    float delayBeforeAnimation = 0.5f;
    float durationForBlackOverlayAppearance = 0.12f, durationForBoneAnimation = 0.8f;
    float boneSize = superView.frame.size.width / 2;
    
    UIView *animationView = [[UIView alloc] initWithFrame:superView.bounds];
    UIImageView *ivBone = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earned_bone"]];
    UILabel *lblBone = [[UILabel alloc] initWithFrame:CGRectMake(0, superView.bounds.size.height / 4  +  boneSize / 2, superView.bounds.size.width, 10.0f)];
    
    //Initialize view for animation
    [animationView setBackgroundColor:[UIColor roverTownColorBlackOverlay]];
    [animationView setAlpha:0.0f];
    
    [ivBone setFrame:[self frameForBoneImageWithImageSize:0 superView:superView]];
    
    //Initialize label for bone earned
    [lblBone setText:@"+1 Bone!"];
    [lblBone setTextColor:[UIColor whiteColor]];
    [lblBone setFont:BOLDFONT30];
    [lblBone setNumberOfLines:0];
    [lblBone sizeToFit];
    [lblBone setClipsToBounds:YES];
    
    CGRect sizeForBoneLabel = lblBone.bounds;
    [lblBone setFrame:CGRectMake((superView.bounds.size.width - sizeForBoneLabel.size.width) / 2, superView.bounds.size.height / 4  +  boneSize / 2 + sizeForBoneLabel.size.height + 30, sizeForBoneLabel.size.width, 0)];
    [lblBone setAlpha:0.0f];
    
    //Add bone icon to animation view
    [animationView addSubview:ivBone];
    [animationView addSubview:lblBone];
    
    //Add animation view to super view
    [superView addSubview:animationView];
    
    [UIView animateWithDuration:durationForBlackOverlayAppearance delay:delayBeforeAnimation options:0 animations:^{
        [animationView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //Start spring animation for bone image
        [UIView animateWithDuration:durationForBoneAnimation delay:0.0f usingSpringWithDamping:0.35f initialSpringVelocity:0.5f options:0 animations:^{
            [ivBone setFrame:[self frameForBoneImageWithImageSize:boneSize superView:superView]];
        } completion:^(BOOL finished) {
            //Hides bone image and label after 0.2 seconds.
            [UIView animateWithDuration:0.2f delay:0.2f options:0 animations:^{
                [ivBone setAlpha:0.0f];
                [lblBone setAlpha:0.0f];
            } completion:^(BOOL finished) {
                //Hides animation view after bone image and label have been hidden.
                [UIView animateWithDuration:0.2f animations:^{
                    [animationView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    //Remove animation view after all animations are done
                    [animationView removeFromSuperview];
                    if( completeBlock != nil )
                        completeBlock();
                }];
            }];
        }];
        
        //Start rotating animation for bone image
        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.5f options:0 animations:^{
            [ivBone setTransform:CGAffineTransformMakeRotation(-5 * M_2_PI)];
        } completion:^(BOOL finished) {
            //
        }];
        
        //Start label animation after 0.2 seconds (fade in & rise up)
        [UIView animateWithDuration:0.3f delay:0.2f options:0 animations:^{
            [lblBone setFrame:CGRectMake((superView.bounds.size.width - sizeForBoneLabel.size.width) / 2, superView.bounds.size.height / 4  +  boneSize / 2, sizeForBoneLabel.size.width, sizeForBoneLabel.size.height)];
            [lblBone setAlpha:1.0f];
        } completion:^(BOOL finished) {
            //
        }];
    }];
}

+ (void)playEarnBadgeAnimationWithSuperview:(UIView *)superView completeBlock:(dispatch_block_t)completeBlock {
    float delayBeforeAnimation = 0.5f;
    float durationForBlackOverlayAppearance = 0.12f, durationForBadgeAnimation = 0.8f;
    float badgeSize = superView.frame.size.width / 2;
    
    UIView *animationView = [[UIView alloc] initWithFrame:superView.bounds];
    UIImageView *ivBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"earned_badge"]];
    UILabel *lblBadge = [[UILabel alloc] initWithFrame:CGRectMake(0, superView.bounds.size.height / 4  +  badgeSize / 2, superView.bounds.size.width, 10.0f)];
    
    //Initialize view for animation
    [animationView setBackgroundColor:[UIColor roverTownColorBlackOverlay]];
    [animationView setAlpha:0.0f];
    
    [ivBadge setFrame:[self frameForBoneImageWithImageSize:0 superView:superView]];
    
    //Initialize label for bone earned
    [lblBadge setText:@"+1 Badge!"];
    [lblBadge setTextColor:[UIColor whiteColor]];
    [lblBadge setFont:BOLDFONT30];
    [lblBadge setNumberOfLines:0];
    [lblBadge sizeToFit];
    [lblBadge setClipsToBounds:YES];
    
    CGRect sizeForBoneLabel = lblBadge.bounds;
    [lblBadge setFrame:CGRectMake((superView.bounds.size.width - sizeForBoneLabel.size.width) / 2, superView.bounds.size.height / 4  +  badgeSize / 2 + sizeForBoneLabel.size.height + 30, sizeForBoneLabel.size.width, 0)];
    [lblBadge setAlpha:0.0f];
    
    //Add badge icon to animation view
    [animationView addSubview:ivBadge];
    [animationView addSubview:lblBadge];
    
    //Add animation view to super view
    [superView addSubview:animationView];
    
    [UIView animateWithDuration:durationForBlackOverlayAppearance delay:delayBeforeAnimation options:0 animations:^{
        [animationView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //Start spring animation for bone image
        [UIView animateWithDuration:durationForBadgeAnimation delay:0.0f usingSpringWithDamping:0.35f initialSpringVelocity:0.5f options:0 animations:^{
            [ivBadge setFrame:[self frameForBoneImageWithImageSize:badgeSize superView:superView]];
        } completion:^(BOOL finished) {
            //Hides bone image and label after 0.2 seconds.
            [UIView animateWithDuration:0.2f delay:0.2f options:0 animations:^{
                [ivBadge setAlpha:0.0f];
                [lblBadge setAlpha:0.0f];
            } completion:^(BOOL finished) {
                //Hides animation view after bone image and label have been hidden.
                [UIView animateWithDuration:0.2f animations:^{
                    [animationView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    //Remove animation view after all animations are done
                    [animationView removeFromSuperview];
                    if( completeBlock != nil )
                        completeBlock();
                }];
            }];
        }];
        
        //Start rotating animation for bone image
        
        [ivBadge setTransform:CGAffineTransformMakeRotation(5 * M_2_PI)];

        [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:0.5f options:0 animations:^{
            
            [ivBadge setTransform:CGAffineTransformMakeRotation(0 * M_2_PI)];
        } completion:^(BOOL finished) {
            //
        }];
        
        //Start label animation after 0.2 seconds (fade in & rise up)
        [UIView animateWithDuration:0.3f delay:0.2f options:0 animations:^{
            [lblBadge setFrame:CGRectMake((superView.bounds.size.width - sizeForBoneLabel.size.width) / 2, superView.bounds.size.height / 4  +  badgeSize / 2, sizeForBoneLabel.size.width, sizeForBoneLabel.size.height)];
            [lblBadge setAlpha:1.0f];
        } completion:^(BOOL finished) {
            //
        }];
    }];
}

/**
 *  Show Bone Message
 **/
- (void)showBoneMessageWithParentView:(UIView *)parentView messageText:(NSString *)text animating:(BOOL)animating textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    if( parentView.subviews.count > 0 ) {
        //Remove all subviews if exist
        [parentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [parentView layoutIfNeeded];

    //Initializing Text Label
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, parentView.bounds.size.width - 20 - 8, 0)];
    if( animating ) {
        //Appends triple dots if text should be animated
        text = [text stringByAppendingString:@"..."];
        [lblText setNumberOfLines:1];
    }
    [lblText setText:text];
    [lblText setFont:textFont];
    [lblText setTextColor:textColor];
    [lblText sizeToFit];
    
    //Initializing Bone Image View
    UIImageView *ivBone = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [ivBone setImage:[UIImage imageNamed:@"spinner"]];
    
    int parentViewWidth = parentView.bounds.size.width;
    int parentViewHeight = parentView.bounds.size.height;
    int totalEstimatedWidth = ivBone.bounds.size.width + 8 + lblText.bounds.size.width;
    int totalEstimatedHeight = ivBone.bounds.size.height > lblText.bounds.size.height ? ivBone.bounds.size.height : lblText.bounds.size.height;
    
    CGRect boundsForBoneImage = ivBone.bounds;
    int xPosForBoneImage = ( parentViewWidth - totalEstimatedWidth ) / 2;
    int yPosForBoneImage = ( parentViewHeight - totalEstimatedHeight ) / 2 + (totalEstimatedHeight - boundsForBoneImage.size.height) / 2;
    [ivBone setFrame:CGRectMake(xPosForBoneImage, yPosForBoneImage, boundsForBoneImage.size.width, boundsForBoneImage.size.height)];
    
    CGRect boundsForTextLabel = lblText.bounds;
    int xPosForTextLabel = xPosForBoneImage + ivBone.bounds.size.width + 8;
    int yPosForTextLabel = ( parentViewHeight - totalEstimatedHeight ) / 2 + (totalEstimatedHeight - lblText.bounds.size.height) / 2;
    [lblText setFrame:CGRectMake(xPosForTextLabel, yPosForTextLabel, boundsForTextLabel.size.width, boundsForTextLabel.size.height)];
    
    [parentView addSubview:ivBone];
    [parentView addSubview:lblText];
    
    /////////////Start Animation////////////
    if( animating ) {
        //Bone Animation
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        rotationAnimation.duration = 1.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = INFINITY;
        
        [ivBone.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        //Message Label Animation
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:lblText forKey:@"textLabel"];
        [userInfo setObject:text forKey:@"text"];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startTripleDotTagAnimation:) userInfo:userInfo repeats:YES];
    }
}

- (void)startTripleDotTagAnimation:(NSTimer *)timer {
    NSDictionary *dict = [timer userInfo];
    
    UILabel *lblText = (UILabel *)[dict objectForKey:@"textLabel"];
    NSString *text = (NSString *)[dict objectForKey:@"text"];
    
    static int nCount = 0;
    
    nCount++;
    nCount = nCount % 3;
    
    [lblText setText:[text substringToIndex:text.length - 2 + nCount]];
}

+ (CGRect)frameForBoneImageWithImageSize:(float)boneSize superView:(UIView *)superView {
    CGRect boundsForSuperview = superView.bounds;
    return CGRectMake((boundsForSuperview.size.width - boneSize) / 2, boundsForSuperview.size.height / 4 - boneSize / 2, boneSize, boneSize);
}

#pragma mark - Popup Dialogs

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)okButtonTitle parentVC:(UIViewController *)parentVC handler:(void (^)(UIAlertAction *))handler {
    
    if ([RTUIManager isiOS8OrAbove]) {
        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:handler];
        
        [alertMessage addAction:okAction];
        
        [parentVC presentViewController:alertMessage animated:YES completion:nil];
    }
    else {
        [RTUIManager sharedInstance].alertHandler = handler;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:[RTUIManager sharedInstance]
                                                   cancelButtonTitle:okButtonTitle
                                                   otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)showProgressHUDWithViewController:(UIViewController *)vc labelText:(NSString *)labelText {
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    
    progressHud.mode = MBProgressHUDModeIndeterminate;
    progressHud.removeFromSuperViewOnHide = YES;
    progressHud.labelText = labelText;
}

- (void)hideProgressHUDWithViewController:(UIViewController *)vc {
    [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
}

- (void)showToastMessageWithViewController:(UIViewController *)vc labelText:(NSString *)labelText descriptionText:(NSString *)descriptionText {
    [self showToastMessageWithView:vc.view labelText:labelText descriptionText:descriptionText];
}

- (void)showToastMessageWithView:(UIView *)view labelText:(NSString *)labelText descriptionText:(NSString *)descriptionText {
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
    
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    progressHud.mode = MBProgressHUDModeText;
    progressHud.margin = 10.0f;
    progressHud.removeFromSuperViewOnHide = YES;
    progressHud.labelText = labelText;
    progressHud.detailsLabelText = descriptionText;
    
    [progressHud hide:YES afterDelay:2];
}

- (void)showToastMessageWithViewController:(UIViewController *)viewController description:(NSString *)description
{
    [MBProgressHUD hideAllHUDsForView:viewController.view animated:YES];
    
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    progressHud.mode = MBProgressHUDModeText;
    progressHud.margin = 10.0f;
    progressHud.removeFromSuperViewOnHide = YES;
    progressHud.detailsLabelText = description;
}

- (void)showPageLoadingSpinnerWithView:(UIView *)view {
    if (!self.spinnerView) {
        [view setUserInteractionEnabled:NO];
        UIImageView *spinner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spinner.png"]];
        [spinner sizeToFit];
        [spinner setFrame:CGRectMake(CGRectGetMidX(view.bounds) - CGRectGetWidth(spinner.frame), CGRectGetMidY(view.bounds) - CGRectGetHeight(spinner.frame), CGRectGetWidth(spinner.frame) *2, CGRectGetHeight(spinner.frame) * 2)];
        
        [view addSubview:spinner];
        self.spinnerView = spinner;
        
        CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
        fullRotation.duration = MAXFLOAT * 0.2;
        fullRotation.removedOnCompletion = YES;
        [self.spinnerView.layer addAnimation:fullRotation forKey:nil];
    }
}

- (void)hidePageLoadingSpinner {
    if (self.spinnerView) {
        [self.spinnerView.superview setUserInteractionEnabled:YES];
        [self.spinnerView removeFromSuperview];
        self.spinnerView = nil;
    }
}

@end
