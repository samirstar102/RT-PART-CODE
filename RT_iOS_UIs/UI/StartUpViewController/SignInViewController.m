#import "SignInViewController.h"
#import "HUDataManager.h"
#import "AppDelegate.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "RTUser.h"
#import "iToast.h"
#import "RTLocationManager.h"
#import <QuartzCore/QuartzCore.h>

@interface SignInViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *whiteBackLabel;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *referralTextField;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIView *validatingView;
@property (strong, nonatomic) IBOutlet UIImageView *spinnerImageView;
@property (strong, nonatomic) IBOutlet UILabel *validatingLabel;
@property (strong, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UILabel *successEmailLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *successCheckImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic) BOOL shouldSkipToMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForValidatingView;

@end



int nValue=0, nContinueButtonYPos = 0, nWhiteBackHeight = 0;

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([RTUserContext sharedInstance].email != nil && [RTUserContext sharedInstance].email.length > 0) {
        self.emailTextField.text = [RTUserContext sharedInstance].email;
        
        NSDate *date = [NSDate date];
        if ([date compare:[RTUserContext sharedInstance].expireDate] == NSOrderedDescending) {
            self.shouldSkipToMain = YES;
            [self continueButtonClicked:nil];
        }
    }
    
    self.heightConstraintForValidatingView.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // register keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void) initViews {
    [super initViews];
    
    [RTUIManager applyContainerViewStyle:self.loginView];
    
    nWhiteBackHeight = self.loginView.frame.size.height;
    self.successView.layer.cornerRadius = 3;
    
    [RTUIManager applyEmailTextFieldStyle:self.emailTextField placeholderText:@"Enter Your .Edu Email"];
    [RTUIManager applyEmailTextFieldStyle:self.referralTextField placeholderText:@"Referral Code (optional)"];
    
    self.continueButton.layer.cornerRadius = 3;
    self.okButton.layer.cornerRadius = 3;
    nContinueButtonYPos = self.continueButton.frame.origin.y;
    
    [self validatingAnimation];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBarHidden = YES;
}

- (void) initViewsIPhone35{
    [super initViewsIPhone35];
    self.ScrollViewTopConstraint.constant = 56;
}

- (void) initEvents {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}
- (IBAction)textEditDone:(id)sender{
    [self continueButtonClicked:nil];
}

- (IBAction)continueButtonClicked:(id)sender {
    [self.continueButton setUserInteractionEnabled:NO];
    [self.emailTextField setUserInteractionEnabled:NO];
//    [self.referral setUserInteractionEnabled:NO];
    
//    [self showloadingIndicator];
    
//    if (self.referralFailed) {
//        [self submitReferral:self.referral.text];
//        return;
//    }
    if (self.successView.hidden)
    {
        if ([self isDataValidatedToContinue])
        {
            NSString *email = self.emailTextField.text;
            [self showValidatingAnimation:YES];
            [[RTServerManager sharedInstance] authenticateWithEmail:email complete:^(BOOL success, RTAPIResponse *response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        NSDictionary *dataObject = [response.jsonObject objectForKey:@"authentication"];
                        NSString *token = [dataObject objectForKey:@"token"];
                        int userId = [[dataObject objectForKey:@"user_id"] intValue];
                        int seconds = [[dataObject objectForKey:@"expiration"] intValue];
                        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:seconds];
                        BOOL verified  = [[dataObject objectForKey:@"verified"]boolValue];
                        BOOL lockedOut = [[dataObject objectForKey:@"locked_out"]boolValue];
                        BOOL firstLogin = [[dataObject objectForKey:@"first_login"]boolValue];

                        [[RTUserContext sharedInstance] setEmail:email];
                        [[RTUserContext sharedInstance] setUserId:userId];
                        [[RTUserContext sharedInstance] setAccessToken:token];
                        [[RTUserContext sharedInstance] setSigninDate:[NSDate date]];
                        [[RTUserContext sharedInstance] setExpireDate:expireDate];
                        [[RTUserContext sharedInstance] setVerified:verified];
                        [[RTUserContext sharedInstance] setLockedOut:lockedOut];
                        [[RTUserContext sharedInstance] setAccessToken:token];
                        [[RTServerManager sharedInstance] setAccessToken:token];
                        
                        if (lockedOut)  {
                            [UIView animateWithDuration:0.3f animations:^{
                                self.view.alpha = 0.0f;
                            }completion:^(BOOL finished) {
                                 [[AppDelegate getInstance] bringUpEmailLockOutViewController];
                            }];
                           
                            return ;
                        }
//                        else if (firstLogin && ![self.referral isHidden]) {
//                            [self submitReferral:self.referral.text];
//                            return;
//                        }
                        else if (!firstLogin) {
//                            [[AppDelegate getInstance] waitForAuth];
//                            [[RTLocationManager sharedInstance]requestAccess];
                        } else if([RTUserContext sharedInstance].email == nil || ![[RTUserContext sharedInstance].email isEqualToString:email]) {
                            [RTUserContext sharedInstance].studentIdImage = nil;
                            self.shouldSkipToMain = NO;
                        }
                        
                        [self submitReferralWithFirstLogin:firstLogin];
//                        [self setUserProfileImage];
//                        [self loginSuccess];
                    }
                    else {
                        [self showErrorMessage:1];
                        [Flurry logEvent:@"user_login_failure"];
                        [self showValidatingAnimation:NO];
                    }
                });
                
            }];
        }
        else
        {
            [self showValidatingAnimation:NO];
        }
    }
    else
    {
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [RTUserContext sharedInstance].email, @"School_ID",
                                       nil];
        [Flurry logEvent:@"user_login" withParameters:articleParams];
        [self goNext];
    }
}

- (void)submitReferralWithFirstLogin:(BOOL)firstLogin {
    
    if( self.referralTextField.text.length == 0 ) {
        [self setUserProfileImageWithIsFirstLogin:firstLogin];
        return;
    }
    
    [[RTServerManager sharedInstance] submitReferralCode:self.referralTextField.text withCompletionBlock:^(BOOL success, RTAPIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [RTUserContext sharedInstance].submittedReferralCode = YES;
//                [self loginSuccess];
                [self setUserProfileImageWithIsFirstLogin:firstLogin];
            } else {
                if (response.responseCode == 404) {
//                    self.referralFailed = YES;
                    [self showValidatingAnimation:NO];
                    [self showErrorMessage:3];
                    return;
                }
            }
        });
    }];
}

- (void)setUserProfileImageWithIsFirstLogin:(BOOL)firstLogin {
    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            [[RTUserContext sharedInstance] updateMajorsListWithCompletion:^(BOOL success, RTAPIResponse *response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    RTUser *currentUser = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
                    
                    [RTUserContext sharedInstance].currentUser = currentUser;
                    [RTUserContext sharedInstance].boneCount = currentUser.boneCount;
                    [RTUserContext sharedInstance].badgeTotalCount = currentUser.badgeCount;
                    
                    if( ![currentUser.userCardImage isKindOfClass:[NSNull class]] && currentUser.userCardImage.length > 0 ) {
                        AWSManager *awsManager = [[AWSManager alloc] init];
                        awsManager.delegate = self;
                        [awsManager downloadFile:[NSURL URLWithString:currentUser.userCardImage] bucketFolderName:kBucketFolderNameForUserCardImages];
                    }
                    if( ![currentUser.userProfilePicture isKindOfClass:[NSNull class]] && currentUser.userProfilePicture.length > 0 ) {
                        AWSManager *awsManager = [[AWSManager alloc] init];
                        awsManager.delegate = self;
                        [awsManager downloadFile:[NSURL URLWithString:currentUser.userProfilePicture] bucketFolderName:kBucketFolderNameForUserProfileImages];
                    }
                    if (!firstLogin) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.continueButton setUserInteractionEnabled:YES];
                            [self.emailTextField setUserInteractionEnabled:YES];
                            //                    [[AppDelegate getInstance] waitForAuth];
                            [[RTLocationManager sharedInstance]requestAccess];
                        });
                    }
                    if ( self.shouldSkipToMain == YES || !firstLogin ) {
                        // goto main directly
                        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [RTUserContext sharedInstance].email, @"School_ID",
                                                       nil];
                        [Flurry logEvent:@"user_login" withParameters:articleParams];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[AppDelegate getInstance] bringupMainUserControllerAnimated:YES];
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showSuccessView:YES];
                        });
                    }
                });
            }];
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showValidatingAnimation:NO];
        });
    }];
}

- (void)goNext {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *startUpViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeRoverTownViewController"];
    [self.navigationController pushViewController:startUpViewController animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)isDataValidatedToContinue{
    if([self.emailTextField.text isEqualToString:@""] ||
       ![[HUDataManager defaultManager] isEmailOkay:self.emailTextField.text] ||
       ![[HUDataManager defaultManager] isEduEmailOkay:self.emailTextField.text])
    {
        [self showErrorMessage:0];
        return NO;
    }
    
//    if (!self.referral.isHidden && !self.referral.text.length) {
//        [self showErrorMessage:2];
//        return NO;
//    }
    
    return YES;
}

- (void) showErrorMessage:(int) nType{
//    [self removeLoadingIndicator];
    if (nType == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please Enter a.Edu Email", nil) message:NSLocalizedString(@"You must log into RoverTown with a.edu email. Example:name@university.edu", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (nType == 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry! RoverTown Is Not at Your School Yet.", nil) message:NSLocalizedString(@"RoverTown is constantly growing.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (nType == 2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Do You Have A Referral Code?", nil) message:NSLocalizedString(@"If so please enter it.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if (nType == 3)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Referral Code Failed", nil) message:NSLocalizedString(@"Please enter a valid referral code.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }
    [self.continueButton setUserInteractionEnabled:YES];
    [self.emailTextField setUserInteractionEnabled:YES];
//    [self.referral setUserInteractionEnabled:YES];
}

- (void) showValidatingAnimation:(BOOL) bShow{
    if( bShow ) {
        self.validatingView.hidden = YES;
        [self.continueButton setUserInteractionEnabled:NO];
        self.heightConstraintForValidatingView.constant = 20;
    }
    else {
        self.validatingView.hidden = YES;
        [self.continueButton setUserInteractionEnabled:YES];
        self.heightConstraintForValidatingView.constant = 0;
     
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x, self.loginView.frame.origin.y, self.loginView.frame.size.width, nWhiteBackHeight + (bShow ? 0:0))];
        [self.continueButton setFrame:CGRectMake(self.continueButton.frame.origin.x, nContinueButtonYPos + (bShow ? 0:0), self.continueButton.frame.size.width, self.continueButton.frame.size.height)];
        [self.view setNeedsLayout];
    } completion:^(BOOL finished) {
        self.validatingView.hidden = !bShow;
    }];
}

- (void) validatingAnimation{
    
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
    fullRotation.duration = MAXFLOAT * 0.2;
    fullRotation.removedOnCompletion = YES;
    [self.spinnerImageView.layer addAnimation:fullRotation forKey:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                           selector:@selector(validatingEmailAnimation:) userInfo:nil repeats:YES];
}

- (void) validatingEmailAnimation:(NSTimer*) timer{
    nValue++;
    nValue = nValue % 3;
    
    switch (nValue) {
        case 0:
            [self.validatingLabel setText:@"Validating .edu email."];
            break;
        case 1:
            [self.validatingLabel setText:@"Validating .edu email.."];
            break;
        case 2:
            [self.validatingLabel setText:@"Validating .edu email..."];
            break;
        default:
            [self.validatingLabel setText:@"Validating .edu email..."];
            break;
    }
    
}

- (void) showSuccessView:(BOOL)bShow{
    if (bShow) {
        self.successView.hidden = NO;
        self.loginView.hidden = YES;
        [self showValidatingAnimation:NO];
        
        NSString *emailString = self.emailTextField.text;
        CGSize myStringSize = [emailString sizeWithAttributes:@{NSFontAttributeName:REGFONT13}];
        
        [self.successCheckImageView setFrame:CGRectMake((self.view.frame.size.width - myStringSize.width)/2-30, self.successCheckImageView.frame.origin.y, self.successCheckImageView.frame.size.width, self.successCheckImageView.frame.size.height)];
        [self.successEmailLabel setFrame:CGRectMake((self.view.frame.size.width - myStringSize.width)/2, self.successEmailLabel.frame.origin.y, self.successEmailLabel.frame.size.width, self.successEmailLabel.frame.size.height)];
        [self.successEmailLabel setText:emailString];
//        [self.continueButton setTitle:@"OK" forState:UIControlStateNormal];
    }else{
        self.successView.hidden = YES;
        self.loginView.hidden = NO;
        [self.continueButton setTitle:@"Sign up" forState:UIControlStateNormal];
    }
}

#pragma mark AWSManager delegate
- (void)onUpdateProgress:(float)progress {
    return;
}

- (void)onFileDownloaded:(NSData *)fileData bucketFolderName:(NSString *)bucketFolderName {
    
    if( fileData != nil ) {
        if( [bucketFolderName isEqualToString:kBucketFolderNameForUserCardImages] ) {
            UIImage *image = [UIImage imageWithData:fileData];
            [RTUserContext sharedInstance].studentIdImage = image;
        }
        else {
            UIImage *image = [UIImage imageWithData:fileData];
            [RTUserContext sharedInstance].studentProfileImage = image;
        }
    }
}

#pragma mark Keyboard state
//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
    CGRect missingLabelRect = [self.referralTextField.superview convertRect:self.referralTextField.frame toView:self.view];
    if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
}
//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
//    NSInteger nextTag = textField.tag + 1;
//    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
//    if (nextResponder && !self.referral.hidden) {
//        [nextResponder becomeFirstResponder];
//    } else {
        [textField resignFirstResponder];
//    }
    return NO;
}

@end
