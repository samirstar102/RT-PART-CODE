//
//  EmailLockoutVC.m
//  RoverTown
//
//  Created by Robin Denis on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "EmailLockoutVC.h"
#import "RTStoryboardManager.h"
#import "NewEmailVC.h"
#import "EmailVerifyMessageVC.h"

@interface EmailLockOutVC()<EmailVerifyMessageVCDelegate, NewEmailVCDelegate, RTEmailLockOutModelDelegate >
{
    __weak IBOutlet NSLayoutConstraint *topConstraintForScrollView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForGoBackButton;
}

@property (weak, nonatomic) IBOutlet UILabel *lblWhiteBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnResendVerificationEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUpWithNewEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (nonatomic) RTEmailLockOutModel *emailVerificationModel;
@property (nonatomic) UIViewController *selectedView;
@property (nonatomic) UIImageView *spinnerView;

@end

@implementation EmailLockOutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    
    if ( !self.isAbleToGoBack ) {
        [self hideGoBackButton];
    }
}

- (void) initViews {
    [super initViews];
    
    self.emailVerificationModel = [[RTEmailLockOutModel alloc]init];
    self.emailVerificationModel.delegate = self;
    NSString *detailsText = self.lblDetails.text;
    self.lblDetails.text = [self.emailVerificationModel getDetailsTextWithDefaultText:detailsText];
    
    self.lblWhiteBackground.clipsToBounds = YES;
    self.lblWhiteBackground.layer.cornerRadius = kCornerRadiusDefault;
    
    self.btnResendVerificationEmail.layer.cornerRadius = kCornerRadiusDefault;
    self.btnSignUpWithNewEmail.layer.cornerRadius = kCornerRadiusDefault;
}

- (void) initViewsIPhone35{
    topConstraintForScrollView.constant = 60;
    [self.lblTitle setFont:REGFONT13];
}

#pragma mark - Actions
- (IBAction)resendVerificationEmailButtonTapped {
    [self setButtonsEnable:NO];
    [self showSpinner];
    [self.emailVerificationModel resendVerificationEmail];
}

- (IBAction)signUpWithNewEmailButtonTapped {
    self.selectedView = (NewEmailVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSINewEmailVC storyboardName:kStoryboardNewEmail];
    ((NewEmailVC *)self.selectedView).delegate = self;
    
    self.selectedView.view.alpha = 0.0f;
    [self.view addSubview:self.selectedView.view];
    [self addChildViewController:self.selectedView];
    [UIView animateWithDuration:0.5f animations:^{
        self.selectedView.view.alpha = 1.0f;
    }];
    
}

- (IBAction)goBackButtonTapped:(id)sender {
    if( self.delegate != nil )
        [self.delegate emailLockOutVC:self onGoBackButtonTapped:self.emailVerificationModel];
}

#pragma mark - EmailVerifyMessageVCDelegate
-(void)checkVerificationButtonTapped{
    [self showSpinner];
    [self.emailVerificationModel authenticateUser];
}

#pragma mark - NewEmailVCDelegate
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
#pragma mark - RTEmailLockOutModelDelegat
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
#pragma mark - private methods

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
    [self.btnResendVerificationEmail setEnabled:enabled];
    [self.btnSignUpWithNewEmail setEnabled:enabled];
    if ([self.selectedView respondsToSelector:@selector(enableButtons)]){
        [(NewEmailVC *)self.selectedView enableButtons];
    }
}

- (void)showGoBackButton {
    heightConstraintForGoBackButton.constant = 45.0f;
    [self.view layoutIfNeeded];
}

- (void)hideGoBackButton {
    heightConstraintForGoBackButton.constant = 0.0f;
    [self.view layoutIfNeeded];
}

@end