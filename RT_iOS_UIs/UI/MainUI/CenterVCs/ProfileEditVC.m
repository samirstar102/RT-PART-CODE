//
//  ProfileEditVC.m
//  RoverTown
//
//  Created by Robin Denis on 8/16/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "ProfileEditVC.h"
#import "RTUIManager.h"
#import "AWSManager.h"
#import "RTUserContext.h"
#import "RTMajor.h"
#import "NSDate+Utilities.h"
#import "MBProgressHUD.h"
#import "RTImagePickerController.h"
#import "UIImage+Resize.h"
#import "UIViewController+MMDrawerController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RTAutocompletingSearchViewController.h"

@interface ProfileEditVC () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AWSManagerDelegate, RTAutocompletingSearchViewControllerDelegate, RTAutoCompletingSearchViewControllerDataSource>
{
    NSString *gender;
    UIImage *imageStudentSelfie;
    MBProgressHUD *progressHUD;
    UIView *dimView;
    
    __weak IBOutlet NSLayoutConstraint *heightConstraintForSelfieView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForAddProfileSelfieButton;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForDatePicker;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForMajorsPicker;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForMajorPickerView;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnAddProfileSelfie;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;
@property (weak, nonatomic) IBOutlet UIButton *btnUnspecified;
@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnMajor;
@property (weak, nonatomic) IBOutlet UIView *vwAddProfileSelfie;
@property (weak, nonatomic) IBOutlet UIView *vwDatePickerContainer;
@property (weak, nonatomic) IBOutlet UIView *vwMajorsPickerContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnRetry;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *jobLocationTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dpBirthday;
//@property (weak, nonatomic) IBOutlet UIPickerView *pickerMajors;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) RTImagePickerController *photoPicker;
@property (weak, nonatomic) IBOutlet RTAutocompletingSearchViewController *majorSearchController;
@property (nonatomic) BOOL majorsIsShowing;
@property (nonatomic) BOOL viewIsSlidUp;

@end

@implementation ProfileEditVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDatePickerMinimumDate];
    [self initView];
    [self initEvent];
}

- (void)initView {
    [RTUIManager applyContainerViewStyle:self.ivFrame];
    [RTUIManager applyRedeemDiscountButtonStyle:self.btnSaveProfile];
    [RTUIManager applyDefaultButtonStyle:self.btnAddProfileSelfie];
    [RTUIManager applyDefaultTextFieldStyle:self.tfFirstName placeholderText:@"First name"];
    [RTUIManager applyDefaultTextFieldStyle:self.tfLastName placeholderText:@"Last name"];
    [RTUIManager applyDefaultTextFieldStyle:self.jobTitleTextField placeholderText:@"Job Title"];
    [RTUIManager applyDefaultTextFieldStyle:self.companyNameTextField placeholderText:@"Company Name"];
    [RTUIManager applyDefaultTextFieldStyle:self.jobLocationTextField placeholderText:@"Location of Job"];
    
    [self.btnRetry.layer setCornerRadius:kCornerRadiusDefault];
    [self.btnRemove.layer setCornerRadius:kCornerRadiusDefault];
    
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    [self.tfFirstName setText:currentUser.firstName];
    [self.tfFirstName setDelegate:self];
    [self.tfLastName setText:currentUser.lastName];
    [self.tfLastName setDelegate:self];
    [self.companyNameTextField setText:currentUser.job.companyName];
    [self.jobTitleTextField setText:currentUser.job.jobTitle];
    [self.jobLocationTextField setText:currentUser.job.locationOfJob];
    gender = currentUser.gender;
    [self setRadioButtonWithGender:gender];
    
    //Initializes the birthday button with users birthday
    NSString *birthday = [currentUser.birthday stringWithFormat:@"MM/dd/yyyy"];
    if( birthday.length != 0 )
        [self.btnBirthday setTitle:birthday forState:UIControlStateNormal];
    else {
        [self.btnBirthday setTitle:NSLocalizedString(@"Profile_Tap_To_Add_Birthday", nil) forState:UIControlStateNormal];
    }
    
    if( currentUser.major.length != 0 ) {
        [self.btnMajor setTitle:currentUser.major forState:UIControlStateNormal];
    }
    
    if( currentUser.userProfilePicture != nil && currentUser.userProfilePicture.length != 0 ) {
        if( [RTUserContext sharedInstance].studentProfileImage != nil )
            [self.self.ivPhoto setImage:[RTUserContext sharedInstance].studentProfileImage];
        else
            [self.self.ivPhoto setImage:[UIImage imageNamed:@"person_default_icon"]];
//        [self.ivPhoto sd_setImageWithURL:[NSURL URLWithString:currentUser.userProfilePicture]
//                       placeholderImage:[UIImage imageNamed:@"person_default_icon"]];
        [self showSelfieViewWithAnimated:NO];
    }
    
    [self hideDatePickerViewWithAnimated:NO];
    [self hideMajorsPickerViewWithAnimated:NO];
    
    //Initalize photo picker
    self.photoPicker = [[RTImagePickerController alloc] init];
    
    self.companyNameTextField.delegate = self;
    self.jobTitleTextField.delegate = self;
    self.jobLocationTextField.delegate = self;
    
    //Adds Search View
    if( self.majorSearchController == nil ) {
        self.majorSearchController = [RTAutocompletingSearchViewController autocompletingSearchViewController];
        [self.majorSearchController.view setFrame:self.vwMajorsPickerContainer.bounds];
        self.majorSearchController.delegate = self;
        self.majorSearchController.dataSource = self;
        [self addChildViewController:self.majorSearchController];
        [self.vwMajorsPickerContainer addSubview:self.majorSearchController.view];
    }
}

- (void)initEvent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hidePopupViews:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    [RTUIManager applyDropdownButtonWithBottomBorderStyle:self.btnBirthday];
    [RTUIManager applyDropdownButtonWithBottomBorderStyle:self.btnMajor];
    [RTUIManager applyBlurView:self.vwDatePickerContainer];
    [RTUIManager applyBlurView:self.vwMajorsPickerContainer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (void)showSelfieViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration / 2 animations:^{
        heightConstraintForAddProfileSelfieButton.constant = 0.0f;
        heightConstraintForSelfieView.constant = 0.0f;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            heightConstraintForSelfieView.constant = 84.0f;
            [self.vwAddProfileSelfie setHidden:NO];
            [self.btnAddProfileSelfie setAlpha:0.0f];
            
            [self.view layoutIfNeeded];
        }];
    }];
}

- (void)hideSelfieViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        heightConstraintForAddProfileSelfieButton.constant = 30.0f;
        heightConstraintForSelfieView.constant = 30.0f;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            heightConstraintForSelfieView.constant = 30.0f;
            [self.vwAddProfileSelfie setHidden:YES];
            [self.btnAddProfileSelfie setAlpha:1.0f];
            
            [self.view layoutIfNeeded];
        }];
    }];
}

- (void)showDatePickerViewWithAnimated:(BOOL)animated {
    //Dismiss keyboard if the view was in editing
    [self hidePopupViews];
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    bottomConstraintForDatePicker.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideDatePickerViewWithAnimated:(BOOL)animated {
    self.majorsIsShowing = NO;
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForDatePicker.constant = -self.vwDatePickerContainer.bounds.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showMajorsPickerViewWithAnimated:(BOOL)animated {
    self.majorsIsShowing = YES;
    [self hidePopupViews];
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForMajorsPicker.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideMajorsPickerViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForMajorsPicker.constant = -self.vwMajorsPickerContainer.bounds.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hidePopupViews:(UITapGestureRecognizer *)sender {
    [self hidePopupViews];
}

- (void)hidePopupViews {
    [self hideDatePickerViewWithAnimated:YES];
    [self hideMajorsPickerViewWithAnimated:YES];
    [self dismissKeyboard];
}

- (void)saveUserProfile {
    //Disable side menu swiping
    [Flurry logEvent:@"user_profile_edit"];
    self.mm_drawerController.shouldUsePanGesture = NO;
    [self showDimView];
    if( imageStudentSelfie != nil ) {
            [self uploadSelfie];
    }
    else {
        imageStudentSelfie = [RTUserContext sharedInstance].studentProfileImage;
        [self uploadUserInfoWithSelfieURL:[RTUserContext sharedInstance].currentUser.userProfilePicture];
    }
}

- (void)setRadioButtonWithGender:(NSString *)userGender {
    if( [userGender isEqualToString:kGenderMale] ) {
        [self onMaleButton:self.btnMale];
    }
    else if( [userGender isEqualToString:kGenderFemale] ) {
        [self onFemaleButton:self.btnFemale];
    }
    else {
        [self onUnspecifiedButton:self.btnUnspecified];
    }
}

- (void)refreshIvPhoto {
    if( imageStudentSelfie == nil ) {
        self.ivPhoto.image = [UIImage imageNamed:@"person_default_icon"];
    }
    else {
        self.ivPhoto.image = imageStudentSelfie;
    }
}

#pragma mark - Actions

- (IBAction)onBirthdayButton:(id)sender {
    [self showDatePickerViewWithAnimated:YES];
}

- (IBAction)onMajorButton:(id)sender {
    [self showMajorsPickerViewWithAnimated:YES];
}

- (IBAction)onSaveProfileButton:(id)sender {
    [self saveUserProfile];
}

- (IBAction)onRetryButton:(id)sender {
    [self openCamera];
}

/**
 * Called when uesr click remove button on selfie view
 */
- (IBAction)onRemoveButton:(id)sender {
    imageStudentSelfie = nil;
    [RTUserContext sharedInstance].studentProfileImage = nil;
    [self uploadSelfie];
    [self refreshIvPhoto];
    [self hideSelfieViewWithAnimated:YES];
}

- (IBAction)onMaleButton:(id)sender {
    [self.btnMale setSelected:YES];
    [self.btnFemale setSelected:NO];
    [self.btnUnspecified setSelected:NO];
    
    gender = kGenderMale;
}

- (IBAction)onFemaleButton:(id)sender {
    [self.btnMale setSelected:NO];
    [self.btnFemale setSelected:YES];
    [self.btnUnspecified setSelected:NO];
    
    gender = kGenderFemale;
}

- (IBAction)onUnspecifiedButton:(id)sender {
    [self.btnMale setSelected:NO];
    [self.btnFemale setSelected:NO];
    [self.btnUnspecified setSelected:YES];
    
    gender = kGenderUnspecified;
}

- (IBAction)onAddProfileSelfieButton:(id)sender {
    if ([RTImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self openCamera];
    }
    else {
        [RTUIManager alertWithTitle:@"Couldn't Take Photo" message:@"Your device couldn't support camera" okButtonTitle:@"OK" parentVC:self handler:^(UIAlertAction *action) {
        }];
    }
}

- (IBAction)onDatePickerDoneButton:(id)sender {
    [self hideDatePickerViewWithAnimated:YES];
    [self.btnBirthday setTitle:[[self.dpBirthday date] stringWithFormat:@"MM/dd/yyyy"] forState:UIControlStateNormal];
}


#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.tfFirstName ) {
        [self.tfLastName becomeFirstResponder];
    } else if (textField == self.companyNameTextField) {
        [self.jobTitleTextField becomeFirstResponder];
    } else if (textField == self.jobTitleTextField) {
        [self.jobLocationTextField becomeFirstResponder];
    } else if (textField == self.jobLocationTextField) {
        [textField resignFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (self.majorsIsShowing) {
        return NO;
    } else {
        return YES;
    }
}

//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    [self hideDatePickerViewWithAnimated:YES];
    
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
    CGRect missingLabelRect = [self.tfFirstName.superview convertRect:self.tfFirstName.frame toView:self.view];
    if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    [self.scrollView scrollRectToVisible:self.tfFirstName.frame animated:YES];
    
    if ([self.companyNameTextField isFirstResponder] || [self.jobTitleTextField isFirstResponder] || [self.jobLocationTextField isFirstResponder]) {
        if (!self.viewIsSlidUp) {
            NSDictionary *info = notif.userInfo;
            NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
            CGRect rawFrame = [value CGRectValue];
            CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
            int movementDistance = -1 * keyboardFrame.size.height;
            float movementDuration = 0.2f;
            [UIView beginAnimations:@"animteTextField" context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:movementDuration];
            self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
            [UIView commitAnimations];
            self.viewIsSlidUp = YES;
        }
    }
    
    
    if( [self.majorSearchController.searchBar isFirstResponder] ) {
        heightConstraintForMajorPickerView.constant = _keyboardSize.height + 40.0f;
        bottomConstraintForMajorsPicker.constant = _keyboardSize.height - 40.0f;
        [self.view layoutIfNeeded];
    }
    else {
        [self hideMajorsPickerViewWithAnimated:YES];
    }
    
}

//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    if (self.viewIsSlidUp) {
        NSDictionary *info = notif.userInfo;
        NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
        
        CGRect rawFrame = [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        int movementDistance = keyboardFrame.size.height;
        float movementDuration = 0.2f;
        [UIView beginAnimations:@"animteTextField" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
        [UIView commitAnimations];
        self.viewIsSlidUp = NO;
    }
    
    if( [self.majorSearchController.searchBar isFirstResponder] ) {
        heightConstraintForMajorPickerView.constant = 250.0f;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Manipulation of Dim View

- (void)showDimView {
    if( dimView == nil ) {
        dimView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        [dimView setBackgroundColor:[UIColor blackColor]];
        [self.navigationController.view addSubview:dimView];
    }
    
    progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = @"Saving your profile...";
    
    [dimView setAlpha:0.5f];
}

- (void)hideDimView {
    if( dimView != nil ) {
        [progressHUD hide:YES];
        
        [UIView animateWithDuration:0.1f animations:^{
            [dimView setAlpha:0.0f];
        }];
    }
}

#pragma mark - Photo Actions

- (void)openCamera {
    if( [RTImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        self.photoPicker.delegate = self;
        self.photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.photoPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:self.photoPicker animated:true completion:nil];
    }
}

#pragma mark - UIImagePickerViewContollerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:true completion:nil];
    
    // get image from info
    UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
    NSLog(@"image size = %f, %f", image.size.width, image.size.height);
    
    UIImage *resizedImage = nil;
    CGFloat targetWidth = 0.25 * image.size.width;
    CGFloat targetHeight = 0.25 * image.size.height;
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbNailRect = CGRectMake(0, 0, 0, 0);
    thumbNailRect.origin = CGPointMake(0.0, 0.0);
    thumbNailRect.size.width = targetSize.width;
    thumbNailRect.size.height = targetSize.height;
    
    [image drawInRect:thumbNailRect];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //sets the selected image to image view
    image = [resizedImage normalizedImage];
    
#if true
    // create thumbnail image
    CGRect rtIvPhoto = self.ivPhoto.frame;
    CGRect rtThumbnailImage = CGRectMake(rtIvPhoto.origin.x, rtIvPhoto.origin.y, 1200, 1200);
    imageStudentSelfie = [resizedImage createThumbnailImage:rtThumbnailImage.size];
#else
    imageStudentId = resizedImage;
#endif
    
    // set image to ivStudentId
    [self refreshIvPhoto];
    
    // refresh buttons
    [self showSelfieViewWithAnimated:YES];
    
    //[self.overlayView unregisterOrientationNotification];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)saveImageToPNGFile:image filePath:(NSString*)filePath {
    
    NSData *pngData = UIImagePNGRepresentation(image);
    
    return [pngData writeToFile:filePath atomically:YES];
}

#pragma mark - Amazon Web Service

- (void)uploadSelfie {
    //Save image to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:kStudentIDPhotoFileName];
    
    if ([self saveImageToPNGFile:imageStudentSelfie filePath:filePath]) {
        AWSManager *awsManager = [[AWSManager alloc] init];
        awsManager.delegate = self;
        [awsManager uploadFile:filePath contentType:@"image/png" bucketFolderName:kBucketFolderNameForUserProfileImages withPublic:YES];
        
        //Show Progress Bar
        if( progressHUD != nil ) {
            [progressHUD hide:YES];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            
            progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            progressHUD.mode = MBProgressHUDModeText;
            progressHUD.labelText = @"Preparing to upload...";
        }
    }
}

- (void)onUpdateProgress:(float)progress {
    if( progressHUD != nil ) {
        progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
        progressHUD.labelText = @"Uploading...";
        [progressHUD setProgress:(progress / 100)];
    }
}

- (void)onFileUploaded:(NSString *)awsURL {
    [self uploadUserInfoWithSelfieURL:awsURL];
}

- (void)onFileDownloaded:(NSData *)fileData bucketFolderName:(NSString *)bucketFolderName {
    imageStudentSelfie = [UIImage imageWithData:fileData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ivPhoto setImage:imageStudentSelfie];
    });
}

- (void)uploadUserInfoWithSelfieURL:(NSString *)url {
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    currentUser.firstName = self.tfFirstName.text;
    currentUser.lastName = self.tfLastName.text;
    currentUser.gender = gender;
    currentUser.birthday = [NSDate dateWithString:self.btnBirthday.titleLabel.text format:@"MM/dd/yyyy"];
    currentUser.job.companyName = self.companyNameTextField.text;
    currentUser.job.jobTitle = self.jobTitleTextField.text;
    currentUser.job.locationOfJob = self.jobLocationTextField.text;
    if( [self.btnMajor.titleLabel.text isEqualToString:NSLocalizedString(@"Profile_Tap_To_Add_Major", nil)] )
        currentUser.major = @"";
    else
        currentUser.major = self.btnMajor.titleLabel.text;
    currentUser.userProfilePicture = url;
    
    [RTUserContext sharedInstance].studentProfileImage = imageStudentSelfie;
    
    [[RTServerManager sharedInstance] updateUser:currentUser complete:^(BOOL success, RTAPIResponse *response) {
        
        if( success ) {
            [RTUserContext sharedInstance].currentUser = currentUser;
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideDimView];
            self.mm_drawerController.shouldUsePanGesture = YES;
            
            if( self.delegate != nil ) {
                [self.delegate profileEditVC:self onSaveProfileWithAnimated:YES];
            }
        });
    }];
}

#pragma mark - RTAutocompletingSearchViewController Delegate

- (void)searchControllerCanceled:(RTAutocompletingSearchViewController *)searchController {
    [self hideMajorsPickerViewWithAnimated:YES];
}

- (void)searchController:(RTAutocompletingSearchViewController *)searchController tableView:(UITableView *)tableView selectedResult:(id)result {
    [self.btnMajor setTitle:(NSString *)result forState:UIControlStateNormal];
    [self hideMajorsPickerViewWithAnimated:YES];
    [self.majorSearchController.searchBar resignFirstResponder];
}

- (BOOL)searchControllerShouldPerformBlankSearchOnLoad:(RTAutocompletingSearchViewController *)searchController {
    return YES;
}

#pragma mark - RTAutocompletingSearchViewController Data Source

- (NSArray *)searchControllerDataSourceForSearch {
    NSMutableArray *majorNamesArray = [[RTUserContext sharedInstance].majorsArray valueForKeyPath:@"majorName"];
    
    return majorNamesArray;
}

#pragma mark - UIDatePicker methods

-(void)setDatePickerMinimumDate
{
    NSCalendar *gregoarian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *componentsOfDate = [[NSDateComponents alloc] init];
    [componentsOfDate setYear:-18];
    NSDate *minimumDate = [gregoarian dateByAddingComponents:componentsOfDate toDate:currentDate options:0];
    self.dpBirthday.maximumDate = minimumDate;
}

@end
