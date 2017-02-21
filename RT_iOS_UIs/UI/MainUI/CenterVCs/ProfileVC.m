//
//  ProfileVC.m
//  RoverTown
//
//  Created by Robin Denis on 19/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "ProfileVC.h"
#import "RTUIManager.h"
#import "UIImage+Resize.h"
#import "OverlayView.h"
#import "RTUserContext.h"
#import "RTUser.h"
#import "AWSManager.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "MBProgressHUD.h"
#import "HUDataManager.h"
#import "RTImagePickerController.h"
#import "RTStoryboardManager.h"
#import "ProfileDescriptionVC.h"
#import "ProfileEditVC.h"
#import "ProfileAboutMeVC.h"
#import "UIViewController+MMDrawerController.h"
#import "NSDate+Utilities.h"
#import "UIColor+Config.h"
#import "RTPublicProfileViewController.h"

@interface ProfileVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, ProfileDescriptionVCDelegate, ProfileEditVCDelegate, ProfileAboutMeVCDelegate, RTPublicProfileViewControllerDelegate>
{
    UIImage *imageStudentId;
    NSString *studentId;
    CGFloat constantForTopConstraintForDeletePhoto;
    RTUser *currentUser;
    NSTimer *animationTimer;
    UIViewController *currentViewController;
    NSMutableArray *majorsArray;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForUpdateEmailView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForEmailValidationView;
    __weak IBOutlet NSLayoutConstraint *leftConstraintForAboutMeView;
    __weak IBOutlet NSLayoutConstraint *leftConstraintForStudentIDView;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segNavigation;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;

@property (weak, nonatomic) IBOutlet UIImageView *ivContainer;
@property (weak, nonatomic) IBOutlet UIImageView *ivHorzBar;
@property (weak, nonatomic) IBOutlet UIImageView *ivStudentId;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnDeletePhoto;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintForTakePhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintForDeletePhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForCheckmark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForLabelStudentId;

@property (retain, nonatomic) OverlayView *overlayView;
@property (retain, nonatomic) MBProgressHUD *progressHUD;
@property (retain, nonatomic) UIView *dimView;

// image picker
@property (retain, nonatomic) RTImagePickerController * picker;
@property (retain, nonatomic) UIPopoverController *popover;

@property (nonatomic) UIView *tapToAddId;

//Email Update view
@property (weak, nonatomic) IBOutlet UIImageView *ivCheckmark;
@property (weak, nonatomic) IBOutlet UILabel *labelStudentId;
@property (weak, nonatomic) IBOutlet UIButton *btnTapToEdit;
@property (weak, nonatomic) IBOutlet UILabel *lblEnterNewEmailDescription;
@property (weak, nonatomic) IBOutlet UITextField *tfNewEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelUpdateEmail;
@property (weak, nonatomic) IBOutlet UIImageView *ivSpinner;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailValidationAnimation;

// RTPublicProfileViewController
@property (nonatomic) RTPublicProfileViewController *aboutMeViewController;

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) initViews{
    [super initViews];
    
    [self getUser];
    
    // init local variables using profile data
    imageStudentId = [RTUserContext sharedInstance].studentIdImage;
    studentId = [RTUserContext sharedInstance].email;
    
    // set container
    [RTUIManager applyContainerViewStyle:self.ivContainer];
    
    // horizontal bar
    self.ivHorzBar.backgroundColor = [RTUIManager borderColorForContainer];
    
    // add button & delete button
    [RTUIManager applyDefaultButtonStyle:self.btnTakePhoto];
    [RTUIManager applyDeleteButtonStyle:self.btnDeletePhoto];
    
    // save original constant
    constantForTopConstraintForDeletePhoto = self.topConstraintForDeletePhoto.constant;
    
    [self refreshIvStudentId];
    [self refreshButtons];
    
    // initialize picker;
    self.picker = [[RTImagePickerController alloc] init];
    
    //Hides the validating animation of email
    heightConstraintForEmailValidationView.constant = 0.0f;
    
    //Initialize Email View
    [self showCurrentEmailViewWithAnimation:NO];
    [RTUIManager applyDefaultButtonStyle:self.btnUpdateEmail];
    [RTUIManager applyEmailTextFieldStyle:self.tfNewEmail placeholderText:@"Enter Your .Edu Email"];
    
    self.aboutMeViewController = [[RTPublicProfileViewController alloc] initForPrivateUser];
    self.aboutMeViewController.delegate = self;
    
    [self showAboutMeViewWithAnimated:NO];
    if( [self anyProfileInformationExist] ) {
        [self showProfileAboutMeViewWithAnimated:NO];
        [self.segNavigation setSelectedSegmentIndex:1];
        [self showStudentIDViewWithAnimated:NO];
    }
    else {
        [self.segNavigation setSelectedSegmentIndex:0];
        [self showProfileDescriptionViewWithAnimated:NO];
    }
}

- (void)initEvents {
    [super initEvents];
    
    [self.tfNewEmail setDelegate:self];
    
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // align center for checkmark & label student id
    CGFloat containerWidth = self.ivContainer.frame.size.width;
    CGFloat checkmarkWidth = self.ivCheckmark.frame.size.width;
    CGFloat leftConstant = self.leftConstraintForCheckmark.constant;
    if (studentId == nil || studentId.length == 0) {
        leftConstant = (containerWidth - checkmarkWidth) / 2.0;
    }
    else {
        CGSize boundingSize = CGSizeMake(containerWidth, self.labelStudentId.frame.size.height);
        NSDictionary *attributes = @{NSFontAttributeName: self.labelStudentId.font};
        CGRect rtBounds = [studentId boundingRectWithSize:boundingSize options:0 attributes:attributes context:nil];
        CGFloat wholeWidth = checkmarkWidth + self.leftConstraintForLabelStudentId.constant + rtBounds.size.width;
        leftConstant = (containerWidth - wholeWidth) / 2.0;
    }
    
    self.leftConstraintForCheckmark.constant = leftConstant;
    
    //Set preferred max layout width of UILabels in order not to crash on iOS 7
    if( SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.lblDescription setPreferredMaxLayoutWidth:self.ivContainer.frame.size.width - 16];
    }
    
    [self refreshIvStudentId];
}

- (void)refreshButtons {
    [self.btnDeletePhoto setTitle:@"Delete photo" forState:UIControlStateNormal];
    
    if (imageStudentId == nil) {
        self.topConstraintForDeletePhoto.constant = self.topConstraintForTakePhoto.constant;
        self.btnDeletePhoto.hidden = YES;
        
        [self.btnTakePhoto setTitle:@"Add student ID photo" forState:UIControlStateNormal];
    }
    else {
        self.topConstraintForDeletePhoto.constant = constantForTopConstraintForDeletePhoto;
        self.btnDeletePhoto.hidden = NO;
        
        [self.btnTakePhoto setTitle:@"Take new student ID photo" forState:UIControlStateNormal];
    }
}

- (void)refreshIvStudentId {
    if(self.ivStudentId.subviews.count) {
        for (UIView *subview in self.ivStudentId.subviews) {
            [subview removeFromSuperview];
        }
    }
    if (imageStudentId == nil) {
        [self.ivStudentId setBackgroundColor:[UIColor roverTownColor6DA6CE]];
        UILabel *tapToAddLabel = [[UILabel alloc]init];
        [tapToAddLabel setText:@"+ TAP TO ADD STUDENT ID PHOTO"];
        [tapToAddLabel setTextAlignment:NSTextAlignmentCenter];
        [tapToAddLabel sizeToFit];
        tapToAddLabel.adjustsFontSizeToFitWidth = YES;
        tapToAddLabel.minimumScaleFactor = 0;
        [tapToAddLabel setTextColor:[UIColor roverTownColorDarkBlue]];
        UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
        UIImageView *placeholderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.ivStudentId.bounds) - (CGRectGetWidth(self.ivStudentId.bounds)/4), 20, CGRectGetWidth(self.ivStudentId.bounds)/2, CGRectGetHeight(self.ivStudentId.bounds)/2)];
        [tapToAddLabel setFrame:CGRectMake(CGRectGetMidX(placeholderImageView.frame) - CGRectGetWidth(placeholderImageView.frame)/2 - 30, CGRectGetMaxY(self.ivStudentId.bounds) - CGRectGetHeight(tapToAddLabel.frame) - 10, CGRectGetWidth(placeholderImageView.frame) + 60, CGRectGetHeight(tapToAddLabel.frame))];
        [placeholderImageView setImage:placeholderImage];
        [self.ivStudentId addSubview:placeholderImageView];
        [self.ivStudentId addSubview:tapToAddLabel];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTakePhoto:)];
        [self.ivStudentId addGestureRecognizer:tap];
        [self.ivStudentId setUserInteractionEnabled:YES];
    }
    else {
        self.ivStudentId.image = imageStudentId;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server APIs

- (void)getUser {
    currentUser = [[RTUser alloc] init];
    
    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            currentUser = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
            
            [RTUserContext sharedInstance].currentUser = currentUser;
            [RTUserContext sharedInstance].boneCount = currentUser.boneCount;
            [RTUserContext sharedInstance].badgeTotalCount = currentUser.badgeCount;
        }
        else {
            
        }
    }];
}

- (void)updateUser {
    if( ![self isDataValidatedToContinue] ) {
        return;
    }
    //Shows the validating animation
    [self showValidatingAnimationViewWithAnimation:YES isShow:YES];
    
    if( currentUser == nil )
        currentUser = [[RTUser alloc] init];
    
    currentUser.email = self.tfNewEmail.text;
    
    [[RTServerManager sharedInstance] updateUser:currentUser complete:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RTUserContext sharedInstance].email = currentUser.email;
                //Initialize the email textfield text
                [self.tfNewEmail setText:@""];
                //Hide the validating animation
                [self showValidatingAnimationViewWithAnimation:YES isShow:NO];
                //Move to original state with updating email
                [self showCurrentEmailViewWithAnimation:YES];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Hide the validating animation
                [self showValidatingAnimationViewWithAnimation:YES isShow:NO];
                //Shows an error message which is saying there isn't rovertown in that school
                [self showErrorMessage:1];
            });
        }
    }];
}

#pragma mark - button actions

/**
 Called when clicked Tap to edit button
 */
- (IBAction)onTapToEdit:(id)sender {
    //Move to nput view of new email
    [self showUpdateEmailViewWithAnimation:YES];
}

/**
 Called when clicked Update email button
 */
- (IBAction)onUpdateEmail:(id)sender {
    //Remove focus from email textfield before updating email
    if( [self.tfNewEmail isFirstResponder] ) {
        [self.tfNewEmail resignFirstResponder];
    }
    
    [self updateUser];
}

/**
 Called when clicked Cancel button before updating email
 */
- (IBAction)onCancelUpdateEmail:(id)sender {
    //Remove focus from email textfield
    if( [self.tfNewEmail isFirstResponder] ) {
        [self.tfNewEmail resignFirstResponder];
    }
    
    //Initialize email textfield text
    [self.tfNewEmail setText:@""];
    
    //Show validating animation
    [self showValidatingAnimationViewWithAnimation:NO isShow:NO];
    
    //Move to original state with updating email address
    [self showCurrentEmailViewWithAnimation:YES];
}

- (IBAction)onTakePhoto:(id)sender {
    
    if ([RTImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [RTUIManager alertWithTitle:@"Add Student ID Photo" message:@"Take a landscape photo (as in turn your phone sideways) and ensure the photo is clear and your ID fills the frame" okButtonTitle:@"OK" parentVC:self handler:^(UIAlertAction *action) {
            [self openCamera];
        }];
    }
    else {
        [RTUIManager alertWithTitle:@"Couldn't Take Photo" message:@"Your device couldn't support camera" okButtonTitle:@"OK" parentVC:self handler:^(UIAlertAction *action) {
        }];
    }
}

- (IBAction)onDeletePhoto:(id)sender {
    imageStudentId = nil;
    [RTUserContext sharedInstance].studentIdImage = nil;
    [Flurry logEvent:@"user_id_delete"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshIvStudentId];
        [self refreshButtons];
        [self.view layoutSubviews];
        self.ivStudentId.image = nil;
    });
}

- (IBAction)onSegmentChanged:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    if( segment.selectedSegmentIndex == 0 ) {
        [self showAboutMeViewWithAnimated:YES];
    }
    else {
        [self showStudentIDViewWithAnimated:YES];
    }
}

#pragma mark - custom methods

- (void)showAboutMeViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    leftConstraintForAboutMeView.constant = 0.0f;
    leftConstraintForStudentIDView.constant = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showStudentIDViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    leftConstraintForAboutMeView.constant = -[UIScreen mainScreen].bounds.size.width;
    leftConstraintForStudentIDView.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showCurrentEmailViewWithAnimation:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    heightConstraintForUpdateEmailView.constant = 78.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.lblEnterNewEmailDescription setAlpha:0.0f];
        [self.tfNewEmail setAlpha:0.0f];
        [self.btnUpdateEmail setAlpha:0.0f];
        [self.btnCancelUpdateEmail setAlpha:0.0f];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.ivCheckmark setAlpha:1.0f];
            [self.labelStudentId setAlpha:1.0f];
            [self.btnTapToEdit setAlpha:1.0f];
            
            [self.labelStudentId setText:[RTUserContext sharedInstance].email];
        }];
    }];
    
    [self.view layoutIfNeeded];
}

- (void)showUpdateEmailViewWithAnimation:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    heightConstraintForUpdateEmailView.constant = 201.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.ivCheckmark setAlpha:0.0f];
        [self.labelStudentId setAlpha:0.0f];
        [self.btnTapToEdit setAlpha:0.0f];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.lblEnterNewEmailDescription setAlpha:1.0f];
            [self.tfNewEmail setAlpha:1.0f];
            [self.btnUpdateEmail setAlpha:1.0f];
            [self.btnCancelUpdateEmail setAlpha:1.0f];
        }];
    }];
}

- (void)showValidatingAnimationViewWithAnimation:(BOOL)animated isShow:(BOOL)isShow{
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    if( isShow ) {
        heightConstraintForEmailValidationView.constant = 20.0f;
        if( heightConstraintForUpdateEmailView.constant != 0 ) {
            heightConstraintForUpdateEmailView.constant = 221.0f;
        }
        [self startValidatingAnimationWithMessage:@"Validating .edu email."];
    }
    else {
        heightConstraintForEmailValidationView.constant = 0.0f;
        if( heightConstraintForUpdateEmailView.constant != 0 ) {
            heightConstraintForUpdateEmailView.constant = 201.0f;
        }
        [self stopValidatingAnimation];
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showProfileDescriptionViewWithAnimated:(BOOL)isAnimated {
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    ProfileDescriptionVC *profileDescriptionVC = (ProfileDescriptionVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"ProfileDescriptionVC" storyboardName:@"Profile"];
    profileDescriptionVC.delegate = self;
    profileDescriptionVC.view.frame = self.vwContainer.bounds;
    [profileDescriptionVC.view setAlpha:0.0f];
    [self.vwContainer addSubview:profileDescriptionVC.view];
    [self addChildViewController:profileDescriptionVC];
    [profileDescriptionVC didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = profileDescriptionVC;
            [UIView animateWithDuration:duration animations:^{
                [profileDescriptionVC.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = profileDescriptionVC;
        
        [UIView animateWithDuration:duration animations:^{
            [profileDescriptionVC.view setAlpha:1.0f];
        }];
    }
}

- (void)editEnabled {
    [self showProfileEditViewWithAnimated:YES];
}

- (void)showProfileEditViewWithAnimated:(BOOL)isAnimated {
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    ProfileEditVC *profileEditVC = (ProfileEditVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"ProfileEditVC" storyboardName:@"Profile"];
    profileEditVC.delegate = self;
    profileEditVC.view.frame = self.vwContainer.bounds;
    [profileEditVC.view setAlpha:0.0f];
    [self.vwContainer addSubview:profileEditVC.view];
    [self addChildViewController:profileEditVC];
    [profileEditVC didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = profileEditVC;
            
            [UIView animateWithDuration:duration animations:^{
                [profileEditVC.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = profileEditVC;
        
        [UIView animateWithDuration:duration animations:^{
            [profileEditVC.view setAlpha:1.0f];
        }];
    }
}

- (void)showProfileAboutMeViewWithAnimated:(BOOL)isAnimated {
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    if (!self.aboutMeViewController) {
        self.aboutMeViewController = [[RTPublicProfileViewController alloc] initForPrivateUser];
        self.aboutMeViewController.delegate = self;
    }
    
//    ProfileAboutMeVC *profileAboutMeVC = (ProfileAboutMeVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"ProfileAboutMeVC" storyboardName:@"Profile"];
//    profileAboutMeVC.delegate = self;
//    profileAboutMeVC.view.frame = self.vwContainer.bounds;
//    [profileAboutMeVC.view setAlpha:0.0f];
//    [self.vwContainer addSubview:profileAboutMeVC.view];
//    [self addChildViewController:profileAboutMeVC];
//    [profileAboutMeVC didMoveToParentViewController:self];
    
    self.aboutMeViewController.delegate = self;
    self.aboutMeViewController.view.frame = self.vwContainer.bounds;
    [self.aboutMeViewController.view setAlpha:0.0f];
    [self.vwContainer addSubview:self.aboutMeViewController.view];
    [self.vwContainer bringSubviewToFront:self.aboutMeViewController.view];
    [self addChildViewController:self.aboutMeViewController];
    [self.aboutMeViewController didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = self.aboutMeViewController;
            
            [UIView animateWithDuration:duration animations:^{
//                [profileAboutMeVC.view setAlpha:1.0f];
                [self.aboutMeViewController.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = self.aboutMeViewController;
        
        [UIView animateWithDuration:duration animations:^{
            [self.aboutMeViewController.view setAlpha:1.0f];
        }];
    }
}

- (BOOL) anyProfileInformationExist {
    if(
       [RTUserContext sharedInstance].currentUser.firstName.length != 0 ||
       [RTUserContext sharedInstance].currentUser.lastName.length != 0 ||
       [RTUserContext sharedInstance].currentUser.gender.length != 0 ||
       [[RTUserContext sharedInstance].currentUser.birthday stringWithFormat:@"MM/dd/yyyy"].length != 0 ||
       [RTUserContext sharedInstance].currentUser.major.length != 0
       ) {
        return YES;
    }
    return NO;
}

#pragma mark - Validate email address format

- (BOOL)isDataValidatedToContinue{
    if([self.tfNewEmail.text isEqualToString:@""] ||
       ![[HUDataManager defaultManager] isEmailOkay:self.tfNewEmail.text] ||
       ![[HUDataManager defaultManager] isEduEmailOkay:self.tfNewEmail.text])
    {
        [self showErrorMessage:0];
        return NO;
    }
    
    return YES;
}

- (void) showErrorMessage:(int) nType{
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
}

#pragma mark - Animation for email validation view

- (void)startValidatingAnimationWithMessage:(NSString*)message {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    [self.ivSpinner.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    //Message Text Animation
    if( !animationTimer ) {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(submitValidatingMessageAnimation:) userInfo:nil repeats:YES];
    }
    
    self.lblEmailValidationAnimation.text = message;
}

- (void)stopValidatingAnimation {
    if( [self.ivSpinner.layer animationForKey:@"rotationAnimation"] != nil )
        [self.ivSpinner.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)submitValidatingMessageAnimation:(NSTimer*) timer {
    static int nValue = 0;
    
    nValue++;
    
    nValue = nValue % 3;
    
    switch (nValue) {
        case 0:
            [self.lblEmailValidationAnimation setText:@"Validating .edu email."];
            break;
        case 1:
            [self.lblEmailValidationAnimation setText:@"Validating .edu email.."];
            break;
        case 2:
            [self.lblEmailValidationAnimation setText:@"Validating .edu email..."];
            break;
        default:
            [self.lblEmailValidationAnimation setText:@"Validating .edu email..."];
            break;
    }
}

#pragma mark - take photo actions
- (void)openCamera {
    if ([RTImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picker.delegate = self;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //CGRect frame = self.picker.cameraOverlayView.frame;
        //self.overlayView = [[OverlayView alloc] initWithFrame:self.picker.cameraOverlayView.frame];
//        CGSize targetSize = self.ivStudentId.frame.size;//CGSizeMake(self.ivStudentId.frame.size.height, self.ivStudentId.frame.size.width);
        //[self.overlayView setTargetImageSize:targetSize];
        //[self.overlayView registerOrientationNotification];
        
        // Device's screen size (ignoring rotation intentionally):
        // CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        // iOS is going to calculate a size which constrains the 4:3 aspect ratio
        // to the screen size. We're basically mimicking that here to determine
        // what size the system will likely display the image at on screen.
        // NOTE: screenSize.width may seem odd in this calculation - but, remember,
        // the devices only take 4:3 images when they are oriented *sideways*.

//        float cameraAspectRatio = 4.0 / 3.0;
//        float imageAspectRatio = targetSize.width / targetSize.height;
//        self.picker.cameraViewTransform = CGAffineTransformMakeScale(imageAspectRatio / cameraAspectRatio, 1);

        //self.picker.cameraOverlayView = self.overlayView;
    
        [self presentViewController:self.picker animated:true completion:nil];
    }
}

-(void) shootPicture {
    [self.picker takePicture];
}

- (IBAction)cancelPicture {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openGallary {
    self.picker.delegate = self;
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.picker animated: true completion: nil];
    }
    else {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.picker];
        [self.popover presentPopoverFromRect:self.btnTakePhoto.frame inView: self.view permittedArrowDirections: UIPopoverArrowDirectionAny animated: true];
    }
}

#pragma mark - UIImagePickerViewControllerDelegate
- (void)imagePickerController:(RTImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:true completion:nil];
    
    // get image from info
    UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
    NSLog(@"image size = %f, %f", image.size.width, image.size.height);
    
    //sets the selected image to image view
    image = [image normalizedImage];
    
#if true
    // create thumbnail image
    CGRect rtIvStudentId = self.ivStudentId.frame;
    CGRect rtThumbnailImage = CGRectMake(rtIvStudentId.origin.x, rtIvStudentId.origin.y, image.size.width > image.size.height? 1200:675, image.size.width > image.size.height? 675:1200);
    imageStudentId = [image createThumbnailImage:rtThumbnailImage.size];
    [RTUserContext sharedInstance].studentIdImage = imageStudentId;
#else
    imageStudentId = image;
#endif
    
    //Save image to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:kStudentIDPhotoFileName];
    
    if ([self saveImageToPNGFile:imageStudentId filePath:filePath]) {
        AWSManager *awsManager = [[AWSManager alloc] init];
        awsManager.delegate = self;
        [awsManager uploadFile:filePath contentType:@"image/png" bucketFolderName:kBucketFolderNameForUserCardImages];
        //Show Progress Bar
        if( self.progressHUD == nil ) {
            //Disable side menu swiping
            self.mm_drawerController.shouldUsePanGesture = NO;
            
            self.dimView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
            [self.dimView setBackgroundColor:[UIColor blackColor]];
            [self.dimView setAlpha:0.5f];
            [self.navigationController.view addSubview:self.dimView];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            self.progressHUD.mode = MBProgressHUDModeText;
            self.progressHUD.labelText = @"Preparing to upload...";
        }
    }
    
    // set image to ivStudentId
    [self refreshIvStudentId];
    
    // refresh buttons
    [self refreshButtons];
    
    //[self.overlayView unregisterOrientationNotification];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    
    //[self.overlayView unregisterOrientationNotification];
}

#pragma mark - UITextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self updateUser];
    if( [textField isFirstResponder] )
        [textField resignFirstResponder];
    return YES;
}

//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
    CGRect missingLabelRect = [self.tfNewEmail.superview convertRect:self.tfNewEmail.frame toView:self.view];
    if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    [self.scrollView scrollRectToVisible:self.tfNewEmail.frame animated:YES];
}
//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Image Manipulation
- (BOOL)saveImageToPNGFile:image filePath:(NSString*)filePath {
    
    NSData *pngData = UIImagePNGRepresentation(image);
    
    return [pngData writeToFile:filePath atomically:YES];
}

#pragma mark - AWSManager Delegate

- (void)onFileUploaded:(NSString *)awsURL {
    if( awsURL == nil ) { //File Uploading Failed.
        if( self.progressHUD != nil ) {
            self.progressHUD.labelText = @"Uploading has been failed.";
            [self.progressHUD hide:YES afterDelay:1.0f];
            [self.progressHUD removeFromSuperview];
            [self.dimView removeFromSuperview];
            self.dimView = nil;
            self.mm_drawerController.shouldUsePanGesture = YES;
            [self.view layoutIfNeeded];
        }
        
        return;
    }

    if( self.progressHUD != nil ) {
        self.progressHUD.mode = MBProgressHUDModeText;
        self.progressHUD.labelText = @"Updating profile...";
    }
    
    currentUser.userCardImage = awsURL;
    
    [[RTServerManager sharedInstance] updateUser:currentUser complete:^(BOOL success, RTAPIResponse *response) {
        if( self.progressHUD != nil) {
            if( success ) {
                [Flurry logEvent:@"user_id_upload"];
                self.progressHUD.labelText = @"Successfully updated.";
            }
            else {
                self.progressHUD.labelText = @"Update has been failed.";
            }
//            [self.progressHUD hide:YES afterDelay:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressHUD hide:YES afterDelay:1.0f];
                [self.progressHUD removeFromSuperview];
                [self.dimView removeFromSuperview];
                self.dimView = nil;
                self.mm_drawerController.shouldUsePanGesture = YES;
                [self.view layoutIfNeeded];
            });
        }
    }];
}

- (void)onUpdateProgress:(float)progress {
    if( self.progressHUD != nil ) {
        self.progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self.progressHUD.labelText = @"Uploading...";
        [self.progressHUD setProgress:(progress / 100)];
    }
}

#pragma mark - Profile Description View Controller Delegate

- (void)profileDescriptionVC:(ProfileDescriptionVC *)vc onFillOutMyProfileWithAnimated:(BOOL)animated {
    [self showProfileEditViewWithAnimated:animated];
}

#pragma mark - Profile Edit View Controller Delegate

- (void)profileEditVC:(ProfileEditVC *)vc onSaveProfileWithAnimated:(BOOL)animated {
    [self getUser];
    self.aboutMeViewController = [[RTPublicProfileViewController alloc] initForPrivateUser];
    [self showProfileAboutMeViewWithAnimated:animated];
}

#pragma mark - Profile About Me View Controller Delegate

- (void)profileAboutMeVC:(ProfileAboutMeVC *)vc onEditAboutMeWithAnimated:(BOOL)animated {
    [self showProfileEditViewWithAnimated:YES];
}

@end
