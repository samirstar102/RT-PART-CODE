//
//  EmailVerifyMessageVC.m
//  RoverTown
//
//  Created by Robin Denis on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "EmailVerifyMessageVC.h"
#import "RTUserContext.h"
#import "NewEmailVC.h"
#import "RTStoryboardManager.h"
#import "RTEmailLockOutModel.h"

@interface EmailVerifyMessageVC() <NewEmailVCDelegate, RTEmailLockOutModelDelegate, EmailVerifyMessageVCDelegate>

{
    
    __weak IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
    __weak IBOutlet UILabel *whiteBackLabel;
    __weak IBOutlet UIView *ScrollViewTopSpacing;
    __weak IBOutlet UIButton *userEmailLabel;
    __weak IBOutlet UIButton *checkVerifcationButton;
    __weak IBOutlet UIButton *goBackButton;
}


@property (weak, nonatomic) IBOutlet UIButton *btnEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckVerification;
@property (nonatomic) UIViewController *selectedView;

@property (nonatomic) RTEmailLockOutModel *emailVerificationModel;
@property (nonatomic) UIImageView *spinnerView;

@end

@implementation EmailVerifyMessageVC

- (void)initViews {
    [super initViews];
    
    self.emailVerificationModel = [[RTEmailLockOutModel alloc] init];
    self.emailVerificationModel.delegate = self;
    
    whiteBackLabel.clipsToBounds = YES;
    whiteBackLabel.layer.cornerRadius = kCornerRadiusDefault;
    
    checkVerifcationButton.layer.cornerRadius = kCornerRadiusDefault;
    
    ScrollViewTopConstraint.constant = 60;
}

- (void) initViewsIPhone35{
    ScrollViewTopConstraint.constant = 60;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [userEmailLabel setUserInteractionEnabled:NO];
    [userEmailLabel setTitle:[RTUserContext sharedInstance].email forState:UIControlStateNormal];
}

- (void)enableButtons {
    [checkVerifcationButton setEnabled:YES];
    [goBackButton setEnabled:YES];
}

- (void)checkVerificationButtonTapped {
    [self.emailVerificationModel authenticateUser];
}

#pragma mark - Actions
- (IBAction)checkVerificationButton {
    [self setButtonsEnable:NO];
    [checkVerifcationButton setEnabled:NO];
    [self.delegate checkVerificationButtonTapped];
}

- (IBAction)goBackButtonPressed:(id)sender {
    self.selectedView = (NewEmailVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSINewEmailVC storyboardName:kStoryboardNewEmail];
    ((NewEmailVC *)self.selectedView).delegate = self;
    
    self.selectedView.view.alpha = 0.0f;
    [self.view addSubview:self.selectedView.view];
    [self addChildViewController:self.selectedView];
    [UIView animateWithDuration:0.5f animations:^{
        self.selectedView.view.alpha = 1.0f;
    }];
}
#pragma mark - NewEmailVC Delegate
-(void)signUpWithEmail:(NSString *)newEmail{
    if ([self.emailVerificationModel setUserEmail:newEmail]) {
        [self showSpinner];
        [self.emailVerificationModel changeUserEmail:newEmail];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Please enter a valid .edu email address." message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        [((NewEmailVC *)self.selectedView) enableButtons];
        
    }
}

#pragma mark - RTEmailLockOutModelDelegate
- (void)authenticateSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideSpinner];
    });
    if ([self.selectedView isKindOfClass:[EmailVerifyMessageVC class]]) {
        [((EmailVerifyMessageVC *)(self.selectedView)) enableButtons];
    }else {
        [((NewEmailVC *)self.selectedView) dismiss];
        self.selectedView = (EmailVerifyMessageVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIEmailVerifyMessageVC storyboardName:kStoryboardEmailVerifyMessage];
        ((EmailVerifyMessageVC *)self.selectedView).delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedView.view.alpha = 0.0f;
            [self.view addSubview:self.selectedView.view];
            [self addChildViewController:self.selectedView];
            [UIView animateWithDuration:0.5f animations:^{
                self.selectedView.view.alpha = 1.0f;
            }];
        });
    }
}
- (void)authenticateErrorWithCode:(int)errorCode {
    NSString *errorMessage = @"Please try again";
    if (errorCode == 409) {
        errorMessage =  @"This email is already registered, please use a different one";
    }
    [self hideSpinner];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"An error has occurred." message:errorMessage delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alertView show];
    [self setButtonsEnable:YES];
}

#pragma mark - Private methods
- (void)showSpinner {
    if (!self.spinnerView) {
        UIImageView *spinner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spinner.png"]];
        [spinner sizeToFit];
        [spinner setFrame:CGRectMake(CGRectGetMidX(self.view.bounds) - CGRectGetWidth(spinner.frame), CGRectGetMidY(self.view.bounds) - CGRectGetHeight(spinner.frame), CGRectGetWidth(spinner.frame) *2, CGRectGetHeight(spinner.frame) * 2)];
        
        [self.view addSubview:spinner];
        self.spinnerView = spinner;
        
        CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
        fullRotation.duration = MAXFLOAT * 0.2;
        fullRotation.removedOnCompletion = YES;
        [self.spinnerView.layer addAnimation:fullRotation forKey:nil];
    }
}

- (void)hideSpinner {
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
    
}

- (void)setButtonsEnable:(BOOL)enabled {
    [checkVerifcationButton setEnabled:enabled];
    [goBackButton setEnabled:enabled];
    if ([self.selectedView respondsToSelector:@selector(enableButtons)]){
        [(NewEmailVC *)self.selectedView enableButtons];
    }
}

@end