//
//  RTDiscountCommentViewController.m
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountCommentViewController.h"
#import "RTDiscountCommentView.h"
#import "RTUIManager.h"
#import "UINavigationItem+Additions.h"

#import "RTServerManager.h"
#import "RTActivityFeedModel.h"
#import "RTActivityFeedCell.h"
#import "RTActivity.h"
#import "RTComment.h"
#import "RTDiscountCommentCell.h"
#import "UIImage+Resize.h"
#import "RTImagePickerController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "AWSManager.h"
#import "MBProgressHUD.h"
#import "RTLocationManager.h"
#import "RTUIManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+MMDrawerController.h"
#import "RTStoryboardManager.h"
#import "BusinessInfoVC.h"
#import "RTPublicProfileViewController.h"

#define buttonWidthForCommentView 80
#define buttonHeightForCommentView 35

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface RTDiscountCommentViewController () <RTDiscountCommentViewDelegate, RTDiscountCommentModelDelegate, RTDiscountCommentCellDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AWSManagerDelegate, RTActivityFeedCellDelegate, BusinessInfoVCDelegate>

@property (nonatomic) RTDiscountCommentView *commentView;
@property (nonatomic) RTDiscountCommentModel *model;

@property (nonatomic) UITableView *commentsTableView;
@property (nonatomic) UITableView *activityTableView;

@property (nonatomic) NSArray *tablesObjectArray;
@property (nonatomic) NSArray *activitiesArray;
@property (nonatomic) NSArray *commentsArray;

@property (nonatomic) UIImageView *spinnerView;

@property (nonatomic) UIButton *commentButton;
@property (nonatomic) UIButton *activityButton;
@property (nonatomic) UISegmentedControl *segmentedControl;

@property (nonatomic) UIView *submitCommentView;
@property (nonatomic) UIView *submitBackgroundView;
@property (nonatomic) UIButton *cameraButton;
@property (nonatomic) UIButton *submitButton;
@property (nonatomic) UITextField *submitTextField;

@property (nonatomic, weak) UIImageView *commentPhoto;
@property (nonatomic, weak) UIImage *commentPhotoImage;
@property (nonatomic) UIView *photoBackgroundView;
@property (nonatomic) UIButton *retakePhotoButton;
@property (nonatomic) UIButton *deletePhotoButton;

@property (nonatomic) NSString *commentImageString;
@property (nonatomic) NSString *commentText;

@property (nonatomic, weak) MBProgressHUD *progressHUD;

@property (nonatomic, retain) UIImagePickerController *imageCamera;

@property (nonatomic) UIView *dimView;
@property (nonatomic) BOOL imageViewIsUp;

@property (nonatomic) UIView *commentImageFullView;
@property (nonatomic) UIImageView *commentImageFullImageView;
@property (nonatomic) UIButton *dismissCommentImageFullViewButton;

@property (nonatomic) UIView *bottomCameraView;

@property (nonatomic, weak) UIView *updatingCommentView;
@property (nonatomic) UILabel *updatingCommentMessage;
@property (nonatomic) int movementDistance;

@property (nonatomic) BOOL hasImageAttached;
@property (nonatomic) BOOL isShowingProgressIndicator;

@property (nonatomic) BOOL atBottomOfActivityList;
@property (nonatomic) int commentIncrementalInteger;
@property (nonatomic) BOOL commentsIsShowing;

@end

@implementation RTDiscountCommentViewController

- (instancetype)initWithModel:(RTDiscountCommentModel *)model {
    if (self = [super init]) {
        self.model = model;
        self.commentView = [self getDiscountCommentViewByDiscount];
        [self.view addSubview:self.commentView];
        [self.commentView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.commentView.frame), 100)];
        self.model.delegate = self;
        [self initializeActivitiesTableView];
        [self initializeCommentsTableView];
        // get the comments array
        [self showSpinner];
        [self.model getComments];
        [self.model getActivities];
        // get the activities array
        self.activityTableView.dataSource = self;
        self.activityTableView.delegate = self;
        self.commentsTableView.dataSource = self;
        self.commentsTableView.delegate = self;
        self.imageViewIsUp = NO;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
        self.commentsIsShowing = YES;
        self.commentIncrementalInteger = 0;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackableNavBar];
    self.title = @"Discount";
    if (self.commentsArray.count) {
        [self.commentsTableView reloadData];
    }
    if (self.activitiesArray.count) {
        [self.activityTableView reloadData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.activityTableView reloadData];
//        });
    }
    [self setUpSegmentedController];
    [self setUpSubmitView];
    [self hidePhotoCommentView];
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)setUpSegmentedController {
    UIView *segmentView = [[UIView alloc] init];
    [segmentView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:segmentView];
    [segmentView setFrame:CGRectMake(0, 141, self.view.frame.size.width, 50)];
    NSArray *segItems = @[@"Comments", @"Activity"];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segItems];
    [segControl setTintColor:[UIColor roverTownColor6DA6CE]];
    _segmentedControl = segControl;
    [segmentView addSubview:self.segmentedControl];
    _segmentedControl.frame = CGRectMake(CGRectGetWidth(segmentView.frame)/2 - 120, 10, 240, 30);
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setSelectedSegmentIndex:0];
}

-(void)keyboardOnScreen:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
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
}

-(void)keyboardOffScreen:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
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
}

- (RTDiscountCommentView *)getDiscountCommentViewByDiscount {
    UIImageView *logo = [self.model storeLogo];
    UIImageView *discountImage = [self.model discountImage];
    NSString *storeName = [self.model discountStoreName];
    NSString *discountName = [self.model discountTitle];
    RTStudentDiscount *discount = self.model.discount;
    BOOL following = self.model.isFollowing;
    return [[RTDiscountCommentView alloc] initWithFrame:self.view.bounds logo:logo discountImage:discountImage storeName:storeName discountTitle:discountName discount:discount following:following delegate:self];
}

- (void)onFollowTappedForDiscount:(RTStudentDiscount *)studentDiscount {
    NSString *storeId = [NSString stringWithFormat:@"%d", self.model.discount.store.storeId];
    
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:![studentDiscount.store.user.following boolValue] complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            BOOL followingState = ![self.model.discount.store.user.following boolValue];
            self.model.discount.store.user.following = [NSNumber numberWithBool:followingState];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commentView setFollowButtonEnabled:[self.model.discount.store.user.following boolValue]];
                if (self.delegate != nil) {
                    [self.delegate discountCommentViewController:self onChangeFollowing:followingState];
                }
            });
        }
    }];
}

- (void)commentsSuccess:(NSArray *)comments {
    NSArray *commentsArray = [NSArray arrayWithArray:comments];
    [self.commentsTableView.tableFooterView setHidden:YES];
    if (self.commentsArray.count && commentsArray.count > self.commentsArray.count) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSIndexPath *indexPath;
        for (int i=0; i < commentsArray.count - self.commentsArray.count; i++) {
            indexPath = [NSIndexPath indexPathForRow:self.commentsArray.count - 1 + i inSection:0];
            [indexPaths addObject:indexPath];
        }
        self.commentsArray = commentsArray;
        [self.commentsTableView beginUpdates];
        [self.commentsTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.commentsTableView endUpdates];
        [self.commentsTableView reloadData];
        [self hideSpinner];
        [self hideTableViewProgressIndicator];
    }else {
        
        NSArray *commentsArray = [NSArray arrayWithArray:comments];
        self.commentsArray = commentsArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsTableView reloadData];
            [self showCommentsTableViewWithAnimated:YES];
            [self hideTableViewProgressIndicator];

        });

    }
}

- (void)commentsUpdateSuccess:(NSArray *)comments {
    NSArray *commentsArray = [NSArray arrayWithArray:comments];
    self.commentsArray = [NSArray arrayWithArray:commentsArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commentsTableView reloadData];
        [self showCommentsTableViewWithAnimated:YES];
        [self hideTableViewProgressIndicator];
    });
    self.submitTextField.text = @"";
    [self hideSpinner];
}

- (void)commentsFailed {
    [self hideTableViewProgressIndicator];
}

- (void)activitiesSuccess:(NSArray *)activities {
    NSArray *activitiesArray = [NSArray arrayWithArray:activities];
    self.activitiesArray = activitiesArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityTableView reloadData];
        [self hideTableViewProgressIndicator];
    });
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSArray *activitiesArray = [NSArray arrayWithArray:activities];
//        self.activitiesArray = activitiesArray;
//        [self.activityTableView reloadData];
//    });
}

- (void)activitiesFailed {
    [self hideTableViewProgressIndicator];
}

- (void)setUpSubmitView {
    UIView *textfieldView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 110, CGRectGetWidth(self.view.frame), 50)];
    [textfieldView setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    self.submitCommentView = textfieldView;
    [self.view addSubview:self.submitCommentView];
    
    UIView *whiteBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 108, CGRectGetWidth(self.view.frame), 48)];
    [whiteBackground setBackgroundColor:[UIColor whiteColor]];
    self.submitBackgroundView = whiteBackground;
    [self.view addSubview:self.submitBackgroundView];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    submitButton.layer.cornerRadius = 5.0f;
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitCommentTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.submitButton = submitButton;
    [self.submitBackgroundView addSubview:self.submitButton];
    
    UITapGestureRecognizer *submitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitCommentTapped:)];
    [self.submitButton addGestureRecognizer:submitRecognizer];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"photo_camera"] forState:UIControlStateNormal];
    [cameraButton setBackgroundColor:[UIColor clearColor]];
    self.cameraButton = cameraButton;
    [self.submitBackgroundView addSubview:self.cameraButton];
    [self.cameraButton setFrame:CGRectMake(6, 6, 40, 36)];
    
    UITapGestureRecognizer *cameraRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCameraClicked)];
    [self.cameraButton addGestureRecognizer:cameraRecognizer];
    
    UITextField *submitTextField = [[UITextField alloc] init];
    submitTextField.layer.cornerRadius = 5.0f;
    submitTextField.layer.borderColor = [UIColor roverTownColorDarkBlue].CGColor;
    submitTextField.layer.borderWidth = 2.0f;
    submitTextField.placeholder = @"  Add a comment...";
    submitTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    submitTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    submitTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    submitTextField.returnKeyType = UIReturnKeyDone;
    submitTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f);
    self.submitTextField = submitTextField;
    [self.submitBackgroundView addSubview:self.submitTextField];
    [self.submitTextField setFrame:CGRectMake(CGRectGetMaxX(self.cameraButton.frame) + 4, 21 - buttonHeightForCommentView/2, CGRectGetWidth(self.view.frame) - buttonWidthForCommentView - CGRectGetMaxX(self.cameraButton.frame) - 12, buttonHeightForCommentView)];
    self.submitTextField.delegate = self;
    
    [self.submitButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - buttonWidthForCommentView - 2, 21 - buttonHeightForCommentView/2, buttonWidthForCommentView - 4, buttonHeightForCommentView)];
    
    UIView *photoPreviewView = [[UIView alloc] init];
    [photoPreviewView setBackgroundColor:[UIColor whiteColor]];
    self.photoBackgroundView = photoPreviewView;
    [self.view addSubview:self.photoBackgroundView];
    [self.photoBackgroundView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) -222, self.view.frame.size.width, 118)];
    
    UIImageView *photoPreviewImageView = [[UIImageView alloc] init];
    self.commentPhoto = photoPreviewImageView;
    [self.photoBackgroundView addSubview:self.commentPhoto];
    [self.commentPhoto setImage:[UIImage imageNamed:@"photo_camera"]];
    [self.commentPhoto setFrame:CGRectMake(8, 8, 100, 100)];
    
    UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [retakeButton setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [retakeButton setTitle:@"RETAKE" forState:UIControlStateNormal];
    [retakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    retakeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    retakeButton.layer.cornerRadius = 5.0f;
    [retakeButton addTarget:self action:@selector(openCameraClicked) forControlEvents:UIControlEventTouchUpInside];
    self.retakePhotoButton = retakeButton;
    [self.photoBackgroundView addSubview:self.retakePhotoButton];
    [self.retakePhotoButton setFrame:CGRectMake(126, 8, 120, 45)];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:142.0f/255.0f green:32.0f/255.0f blue:32.0f/255.0f alpha:1.0f]];
    [deleteButton setTitle:@"REMOVE" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    deleteButton.layer.cornerRadius = 5.0f;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.deletePhotoButton = deleteButton;
    [self.photoBackgroundView addSubview:self.deletePhotoButton];
    [self.deletePhotoButton setFrame:CGRectMake(126, 64, 120, 45)];
    
}

- (void)imageTappedForImage:(UIImage *)image {
    [self openFullScreenImage:image];
}

- (void)imageTappedForImage:(UIImage *)image andComment:(NSString *)comment {
    [self openFullScreenImage:image withComment:comment];
}

- (void)showUpdatingCommentViewForType:(NSString*)type {
    if ([type isEqualToString:@"vote"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RTUIManager sharedInstance] showToastMessageWithViewController:self description:@"Submitting your vote..."];
        });
        
    } else if ([type isEqualToString:@"report"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RTUIManager sharedInstance] showToastMessageWithViewController:self description:@"Submitting your report..."];
        });
    }
}

- (void)votingActivityStarted {
    [self showUpdatingCommentViewForType:@"vote"];
}

- (void)reportingActvityStarted {
    [self showUpdatingCommentViewForType:@"report"];
}

- (void)hideUpdatingCommentView {
    [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self];
}

- (void)discountUpdateSuccess {
    [self hideUpdatingCommentView];
}

- (void)openFullScreenImage:(UIImage *)image {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.commentImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(imageView.frame)/2 - 140, self.view.frame.size.width, 200)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.commentImageFullImageView = commentImageView;
    [self.commentImageFullImageView setClipsToBounds:YES];
    [self.commentImageFullView addSubview:commentImageView];
    [self.view addSubview:self.commentImageFullView];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissCommentImageFullViewButton = closeImageButton;
    [self.dismissCommentImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissCommentImageFullViewButton sizeToFit];
    [self.commentImageFullView addSubview:self.dismissCommentImageFullViewButton];
    [self.dismissCommentImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(void)openFullScreenImage:(UIImage *)image withComment:(NSString *)comment {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.commentImageFullView = imageView;
    
    
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat scaleFactor = self.view.frame.size.width / imageWidth;
    CGFloat newImageHeight = imageHeight * scaleFactor * 0.75;
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)/2 - newImageHeight/2, self.view.frame.size.width, newImageHeight)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.commentImageFullImageView = commentImageView;
    [self.commentImageFullImageView setClipsToBounds:YES];
    [self.commentImageFullView addSubview:commentImageView];
    [self.view addSubview:self.commentImageFullView];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    [commentLabel setAlpha:1.0f];
    [commentLabel setText:comment];
    [commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    commentLabel.textColor = [UIColor whiteColor];
    commentLabel.numberOfLines = 0;
    commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [commentLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 16];
    [commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.commentImageFullImageView.frame) + 2, CGRectGetWidth(self.view.frame) - 16, CGRectGetHeight(commentLabel.frame))];
    [commentLabel sizeToFit];
    [self.commentImageFullView addSubview:commentLabel];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissCommentImageFullViewButton = closeImageButton;
    [self.dismissCommentImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissCommentImageFullViewButton sizeToFit];
    [self.commentImageFullView addSubview:self.dismissCommentImageFullViewButton];
    [self.dismissCommentImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(IBAction)closeImageView:(id)sender {
    if (self.commentImageFullView) {
        [self.commentImageFullView removeFromSuperview];
    }
}

- (void)showPhotoCommentView {
    [self.photoBackgroundView setAlpha:1.0f];
    self.photoBackgroundView.userInteractionEnabled = YES;
    [self.commentPhoto setAlpha:1.0f];
    [self.deletePhotoButton setAlpha:1.0f];
    [self.retakePhotoButton setAlpha:1.0f];
    [self.commentsTableView setAlpha:0.0f];
    [self.view bringSubviewToFront:self.photoBackgroundView];
    self.commentsTableView.userInteractionEnabled = NO;
}

- (void)hidePhotoCommentView {
    [self.photoBackgroundView setAlpha:0.0f];
    [self.commentPhoto setAlpha:0.0f];
    [self.deletePhotoButton setAlpha:0.0f];
    [self.retakePhotoButton setAlpha:0.0f];
    [self.commentsTableView setAlpha:1.0f];
    self.commentsTableView.userInteractionEnabled = YES;
}

-(IBAction)deleteButtonTapped:(id)sender {
    self.commentPhotoImage = nil;
    self.hasImageAttached = NO;
    [self hidePhotoCommentView];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view bringSubviewToFront:self.submitBackgroundView];
    self.mm_drawerController.shouldUsePanGesture = NO;
    [textField becomeFirstResponder];
    if (self.hasImageAttached) {
        [_commentsTableView setAlpha:0.0f];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.mm_drawerController.shouldUsePanGesture = YES;
    [textField resignFirstResponder];
    self.commentText = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.mm_drawerController.shouldUsePanGesture = YES;
    [textField resignFirstResponder];
    if (self.hasImageAttached) {
        [_commentsTableView setAlpha: 1.0f];
        self.commentText = textField.text;
    }
    self.commentText = textField.text;
    return YES;
}

- (void)openCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePickerCamera = [[UIImagePickerController alloc] init];
        imagePickerCamera.delegate = self;
        imagePickerCamera.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePickerCamera.allowsEditing = YES;
        imagePickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imageCamera = imagePickerCamera;
        
        [self presentViewController:self.imageCamera animated:YES completion:nil];
    }
    
}

-(BOOL)isEmptyTextFieldString:(NSString*)text {
    NSString *trimmedString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedString isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

-(IBAction)submitCommentTapped:(id)sender {
    [self.submitTextField resignFirstResponder];
    BOOL isEmptyString = [self isEmptyTextFieldString:self.submitTextField.text];
    if (!self.commentPhotoImage && !isEmptyString) { // no image and yes comment
        [Flurry logEvent:@"user_comment_submit"];
        [self postCommentWithoutImage];
    } else if (self.commentPhotoImage && isEmptyString) { // image and no comment
        [Flurry logEvent:@"user_comment_photo_submit"];
        [self showDimView];
        [self uploadCommentPhoto];
    } else if (self.commentPhotoImage && !isEmptyString) {
        [Flurry logEvent:@"user_comment_submit"];
        [Flurry logEvent:@"user_comment_photo_submit"];
        [self showDimView];
        [self uploadCommentPhoto];
    }
    else if (!self.commentPhotoImage && (isEmptyString)) {
        [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Please take a photo or enter some text!"];
    }
    [self hidePhotoCommentView];
}

- (void)openCameraClicked {
    self.mm_drawerController.shouldUsePanGesture = NO;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self openCamera];
    } else if (status == AVAuthorizationStatusDenied) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Camera Not Available" message:@"You have not granted us camera access" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag=103;
        [alert show];
    } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                [self openCamera];
            } else {
                
            }
        }];
    }
}


#pragma mark - UIImagePickerViewControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.mm_drawerController.shouldUsePanGesture = YES;
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.commentPhotoImage = selectedImage;
    UIImage *resizedImage = nil;
    CGFloat targetWidth = 0.15 * self.commentPhotoImage.size.width;
    CGFloat targetHeight = 0.15 * self.commentPhotoImage.size.height;
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbNailRect = CGRectMake(0, 0, 0, 0);
    thumbNailRect.origin = CGPointMake(0.0, 0.0);
    thumbNailRect.size.width = targetSize.width;
    thumbNailRect.size.height = targetSize.height;
    
    [self.commentPhotoImage drawInRect:thumbNailRect];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.commentPhotoImage = resizedImage;
    [self.commentPhoto setImage:self.commentPhotoImage];
    self.commentPhoto.contentMode = UIViewContentModeScaleAspectFill;
    [self.commentPhoto setClipsToBounds:YES];
    self.hasImageAttached = YES;
    [self showPhotoCommentView];
    [self dismissViewControllerAnimated:self.imageCamera completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:picker completion:^{
    }];
}

-(BOOL)aveImageToPNGFile:image filePath:(NSString *)filePath {
    NSData *pngData = UIImagePNGRepresentation(image);
    return [pngData writeToFile:filePath atomically:YES];
}

#pragma mark - AWSManager

-(void)uploadCommentPhoto {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"userCommentPhoto"];
    
    if ([self aveImageToPNGFile:self.commentPhotoImage filePath:filePath]) {
        AWSManager *awsManager = [[AWSManager alloc] init];
        awsManager.delegate = self;
        [awsManager uploadFile:filePath contentType:@"image/png" bucketFolderName:@"user_comment_images" withPublic:YES];
        
        if (self.progressHUD != nil) {
            [self.progressHUD hide:YES];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            self.progressHUD.mode = MBProgressHUDModeText;
            self.progressHUD.labelText = @"Preparing to upload...";
        }
    }
}

-(void)showDimView {
    if (self.dimView == nil) {
        self.dimView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        [self.dimView setBackgroundColor:[UIColor blackColor]];
        [self.navigationController.view addSubview:self.dimView];
    }
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = @"Uploading your comment...";
    
    [self.dimView setAlpha:0.5f];
}

-(void)hideDimView {
    if (self.dimView != nil) {
        [self.progressHUD hide:YES];
        
        [UIView animateWithDuration:0.1f animations:^{
            [self.dimView setAlpha:0.0f];
        }];
    }
}

-(void)onUpdateProgress:(float)progress {
    if (self.progressHUD != nil) {
        self.progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self.progressHUD.labelText = @"Uploading...";
        [self.progressHUD setProgress:(progress/100)];
    }
}

-(void)onFileUploaded:(NSString *)awsURL {
    self.commentImageString = awsURL;
    [self uploadDiscountComment];
}

- (void)deleteTappedWithCommentId:(int)commentId {
    [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Deleting your comment"];
    [[RTServerManager sharedInstance] deleteCommentWithCommentId:commentId complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self.model refreshCommentsFromPost];
        } else {
            [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"There was an error. Please try again later."];
        }
    }];
}

-(void)uploadDiscountComment {
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    [[RTServerManager sharedInstance] postDiscountCommentForStore:self.model.storeId discount:self.model.discountId atLongitude:longitude andLatitude:latitude withComment:self.commentText andImage:self.commentImageString complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            if (response.responseCode == 409 || response.responseCode == 403 || response.responseCode == 401) {
                [self showCommentLimitError];
            } else
            if (response.responseCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.submitTextField.text = @"";
                    [self hideDimView];
                });
                self.activitiesArray = [NSArray array];
                [self.model updateActivities];
                [self.model getActivities];
                [self.model refreshCommentsFromPost];
                self.commentIncrementalInteger += 1;
                if (self.delegate != nil) {
                    [self.delegate discountCommentViewController:self onUpdateDiscountComments:self.commentIncrementalInteger];
                }
            }
        } else {
            [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"There was an error. Please try again later."];
        }
    }];
}

-(void)postCommentWithoutImage {
    [self showDimView];
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    [[RTServerManager sharedInstance] postDiscountCommentForStore:self.model.storeId discount:self.model.discountId atLongitude:longitude andLatitude:latitude withComment:self.commentText andImage:@"" complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            if (response.responseCode == 409) {
                [self showCommentLimitError];
            } else
            if (response.responseCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.submitTextField.text = @"";
                    [self hideDimView];
                });
                self.activitiesArray = [NSArray array];
                [self.model updateActivities];
                [self.model getActivities];
                [self.model refreshCommentsFromPost];
                self.commentIncrementalInteger += 1;
                if (self.delegate != nil) {
                    [self.delegate discountCommentViewController:self onUpdateDiscountComments:self.commentIncrementalInteger];
                }
            }
            
        } else {
            [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"There was an error. Please try again later."];
        }
    }];
}

-(void)showCommentLimitError {
    [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:@"You have submitted too many comments too quickly." descriptionText:@"Try again later."];
}

-(void)animateCommentView:(UIView *)view up:(BOOL) up{
    int movementDistance = -118;
    const float movementDuration = 0.225f;
    
    int movement = (up ? movementDistance : - movementDistance);
    
    [UIView beginAnimations:@"animateCommentView" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)initializeCommentsTableView {
    _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, self.view.frame.size.height - 300)];
    [_commentsTableView setBackgroundColor:[UIColor clearColor]];
    _commentsTableView.allowsSelection = NO;
    _commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_commentsTableView setAlpha:0.0f];
    [self.view addSubview:_commentsTableView];
}

-(void)initializeActivitiesTableView {
    _activityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, self.view.frame.size.height - 255)];
    [_activityTableView setBackgroundColor:[UIColor clearColor]];
    _activityTableView.allowsSelection = NO;
    _activityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_activityTableView setAlpha:0.0f];
    [self.view addSubview:_activityTableView];
}

- (void)showCommentsTableViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if (animated) {
        duration = 0.2f;
    }
    [UIView animateWithDuration:duration animations:^{
        [self.activityTableView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.commentsTableView setAlpha:1.0f];
            [self.submitCommentView setAlpha:1.0f];
            [self.submitBackgroundView setAlpha:1.0f];
            [self.submitButton setAlpha:1.0f];
            [self.cameraButton setAlpha:1.0f];
            [self.submitTextField setAlpha:1.0f];
//            [self.view bringSubviewToFront:self.submitCommentView];
            [self.view bringSubviewToFront:self.submitBackgroundView];
            [self.view bringSubviewToFront:self.submitButton];
            [self.view bringSubviewToFront:self.submitTextField];
            [self.view bringSubviewToFront:self.cameraButton];
        }];
    }];
    [self hideSpinner];
}

-(void)activitySegmentTapped {
    [self showSpinner];
}

- (void)showActivitiesTableViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if (animated) {
        duration = 0.2f;
    }
    [UIView animateWithDuration:duration animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsTableView setAlpha:0.0f];
            [self.submitCommentView setAlpha:0.0f];
            [self.submitBackgroundView setAlpha:0.0f];
            [self.submitButton setAlpha:0.0f];
            [self.cameraButton setAlpha:0.0f];
            [self.submitTextField setAlpha:0.0f];
//            [self.view sendSubviewToBack:self.submitBackgroundView];
//            [self.view sendSubviewToBack:self.submitCommentView];
        });
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.activityTableView setAlpha:1.0f];
        }];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityTableView reloadData];
    });
    [self hideSpinner];
}

#pragma mark - spinnerView

-(void)showSpinner {
    if (!self.spinnerView) {
        UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner.png"]];
        [spinner sizeToFit];
        [spinner setFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-CGRectGetWidth(spinner.frame), CGRectGetMidY(self.view.bounds)-CGRectGetHeight(spinner.frame)+ 75, CGRectGetWidth(spinner.frame)*2, CGRectGetHeight(spinner.frame)*2)];
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

-(void)hideSpinner {
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            [self showSpinner];
            self.commentsIsShowing = YES;
            [self showCommentsTableViewWithAnimated:YES];
            break;
        }
        case 1:
        {
            [self showSpinner];
            self.commentsIsShowing = NO;
            [self showActivitiesTableViewWithAnimated:YES];
            break;
        }
    }
}

- (void)updateVoteForCommentCell:(RTDiscountCommentCell *)cell {
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell loadVoteCounts];
        [self hideUpdatingCommentView];
    });
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.activityTableView) {
        RTActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityFeedCellIdent"];
        if (cell == nil) {
            cell = [[RTActivityFeedCell alloc] initWithActivity:self.activitiesArray[indexPath.row]];
        }
        [cell setActivity:self.activitiesArray[indexPath.row]];
        cell.delegate = self;
        return cell;
    } else if (tableView == self.commentsTableView) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"S%ldR%ld", indexPath.section, indexPath.row];
        RTDiscountCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[RTDiscountCommentCell alloc] initWithComment:self.commentsArray[indexPath.row] delegate:self];
        }
        [cell loadVoteCounts];
        cell.privateIndexPath = indexPath;
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.activityTableView) {
        RTActivity *activity = nil;
        if (self.activitiesArray.count) {
            activity = [self.activitiesArray objectAtIndex:indexPath.row];
        }
        BOOL imageExists = ![activity.imageString isEqualToString:@""];
        return [RTActivityFeedCell heightForCellActivity:activity andView:self.view withImage:imageExists];
    } else if (tableView == self.commentsTableView) {
        RTComment *heightComment = self.commentsArray[indexPath.row];
        if ([heightComment.commentString isEqualToString:@"(null)"]) {
            if (![heightComment.imageString isEqualToString:@""]) {
                return 120;
            } else {
                return 90;
            }
        } else {
            UILabel *heightLabel = [[UILabel alloc] init];
            [heightLabel setText:heightComment.commentString];
            [heightLabel setNumberOfLines:0];
            CGFloat maxWidth = self.view.frame.size.width - 16;
            [heightLabel setPreferredMaxLayoutWidth:maxWidth];
            heightLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [heightLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
            [heightLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 56];
            [heightLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 56, CGRectGetHeight(heightLabel.frame))];
            [heightLabel sizeToFit];
            CGRect rectangle = [heightLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 56, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:15]} context:nil];
            if ([heightComment.imageString isEqualToString:@""]) {
                return rectangle.size.height + 75;
            } else {
                return rectangle.size.height + 125;
            }
        }
    }
    return 0;
}

-(void)configureCell:(RTDiscountCommentCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell = [self.commentsTableView cellForRowAtIndexPath:indexPath];
    [self.commentsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [cell loadVoteCounts];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.activityTableView) {
        if (self.activitiesArray.count) {
            return self.activitiesArray.count;
        }
    } else if (tableView == self.commentsTableView) {
        if (self.commentsArray.count) {
            return self.commentsArray.count;
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.commentsTableView) {
        if (indexPath.row == self.model.commentsArray.count - 2) {
            if (!self.model.maxReachedForComments) {
                [self.model getComments];
                [self showTableViewProgressIndicatorIsInitial:YES];
                
            } else {
                [self hideTableViewProgressIndicator];
            }
        }
    } else if (tableView == self.activityTableView) {
        if (indexPath.row == self.model.activitiesArray.count - 2) {
            if (!self.model.maxReachedForActivities) {
                [self.model getActivities];
                [self showTableViewProgressIndicatorIsInitial:YES];
            } else {
                [self hideTableViewProgressIndicator];
            }
        }
    }
}

-(void)showTableViewProgressIndicatorIsInitial:(BOOL)isInitial {
    NSInteger visibleCellMin;
    visibleCellMin = self.activitiesArray.count;
    NSInteger visibleCellMinComments;
    visibleCellMinComments = self.commentsArray.count;
    if (self.commentsTableView.visibleCells.count >= visibleCellMinComments || isInitial) {
        self.isShowingProgressIndicator = YES;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
        imageView.image = [UIImage imageNamed:@"refresh"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
        animation.duration = 1.0f;
        animation.repeatCount = INFINITY;
        [imageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        
        [footerView addSubview:imageView];
        
        self.commentsTableView.tableFooterView = footerView;
    } else if (self.activityTableView.visibleCells.count >= visibleCellMin || isInitial) {
        self.isShowingProgressIndicator = YES;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
        imageView.image = [UIImage imageNamed:@"refresh"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
        animation.duration = 1.0f;
        animation.repeatCount = INFINITY;
        [imageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        
        [footerView addSubview:imageView];
        
        self.activityTableView.tableFooterView = footerView;
    }
}

-(void)hideTableViewProgressIndicator {
    self.isShowingProgressIndicator = NO;
    self.activityTableView.tableFooterView = nil;
    self.commentsTableView.tableFooterView = nil;
}

- (void)activityCell:(RTActivityFeedCell *)cell onViewBusinessWithID:(NSInteger)storeID {
    [[RTUIManager sharedInstance] showPageLoadingSpinnerWithView:self.activityTableView];
    [self.model getStoreByStoreId:storeID];
}

- (void)activityCell:(RTActivityFeedCell *)cell onUserTappedWithUserId:(int)userId {
    RTPublicProfileViewController *publicViewController = [[RTPublicProfileViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:publicViewController animated:YES];
}

- (void)storeSuccessful:(RTStore *)store {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RTUIManager sharedInstance] hidePageLoadingSpinner];
        BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
        vc.store = store;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)activityCell:(RTActivityFeedCell *)cell onDiscountTappedWithId:(NSInteger)discountId andStoreId:(NSInteger)storeId {
    // do nothing!
}

- (void)activityCell:(RTActivityFeedCell *)cell onCommentTapped:(RTStudentDiscount *)discount {
    // do nothing!
}

- (void)businessInfoVC:(BusinessInfoVC *)vc onChangeFollowing:(BOOL)isFollowing {
    // do nothing!!!
}

@end
