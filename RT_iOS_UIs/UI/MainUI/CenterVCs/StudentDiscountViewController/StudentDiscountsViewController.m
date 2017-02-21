//
//  StudentDiscountsViewController.m
//  RoverTown
//
//  Created by Robin Denis on 9/3/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "StudentDiscountsViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#import "AppDelegate.h"

#import "StudentDiscountsCell.h"
#import "AlcoholDiscountsCell.h"

#import "BusinessInfoVC.h"
#import "RedeemVC.h"
#import "SupportVC.h"
#import "SupportSupportVC.h"
#import "EmailLockoutVC.h"
#import "ProfileVC.h"
#import "ProfileQuestionVC.h"
#import "SubmitDiscountVC.h"
#import "RTRedeemDiscountViewController.h"

#import "RTRedeemDiscountModel.h"
#import "RTAutocompletingSearchViewController.h"

#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUIManager.h"
#import "RTUserContext.h"

#import "SessionMgr.h"
#import "RTStoryboardManager.h"

#import "LeftNavViewController.h"
#import "CustomRefreshControl.h"
#import "RTLocationManager.h"
#import "RTCategory.h"
#import "RTMajor.h"
#import "RTShareViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "NSDate+Utilities.h"

#import "RTDiscountCommentViewController.h"
#import "RTDiscountCommentModel.h"
#import "RTDiscountSearchViewController.h"
#import "RTSubmitViewController.h"
#import "UINavigationItem+Additions.h"
#import "CenterViewControllerBase.h"

#define kCategoryAllDiscounts       @"Nearby Discounts"
#define kCategoryNewDiscounts       @"Latest Discounts"
#define kCategoryPopularDiscounts   @"Popular Discounts"
#define KCategoryOnlineDiscounts    @"Online Discounts"
#define kCategoryFeaturedDiscounts  @"Featured Discounts"
#define kCategoryVerifiedDiscounts  @"Verified Discounts"

#define kRateUsFirstQuestion            @"Hi! Are you enjoying RoverTown?"
#define kRateUsSecondQuestionPositive   @"Would you like to rate us 5 stars?"
#define kRateUsSecondQuestionNegative   @"Would you like to give us some feedback?"

#define kNoDiscountCategory         @"Oops! We don\'t have any discounts for this category just yet."
#define kNoDiscountSearch           @"Sorry! Your search for \"%@\" did not match any discounts. Would you like to try #<go>Google#?"
#define kGoogleSearchPrefix         @"https://www.google.com/#q="

#define kNumberOfPullingItems 20

#define kAlertTagEnableLocationAccess   (10000)
#define kAlertTagAtBusiness             (10001)
#define kAlertTagAppUpdate              (10002)
#define kAlertTagEmailVerification      (10003)

#define IS_IPHONE_4_OR_4S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5_OR_5S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface StudentDiscountsViewController () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, BusinessInfoVCDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate, StudentDiscountsCellDelegate, AlcoholDiscountsCellDelegate, RTRedeemDiscountViewControllerDelegate, ProfileQuestionVCDelegate, SubmitDiscountCardViewControllerDelegate, RTShareViewControllerDelegate, RTAutoCompletingSearchViewControllerDataSource, RTAutocompletingSearchViewControllerDelegate, UISearchBarDelegate, UIWebViewDelegate, EmailLockOutVCDelegate, RTDiscountCommentViewControllerDelegate, RTDiscountSearchViewControllerDelegate, RTLocationManagerDelegate>
{
    /**
     Didn't contain discounts of that list_hidden = YES
     */
    NSMutableArray *arrayDiscountsForList;
    
    /**
     Did contain discounts regardless value of list_hidden
     */
    NSMutableArray *arrayDiscountsForBusiness;
    
    /**
     Categories array of nearby discounts.
     */
    NSArray *arrayDefaultCategoryNames;
    NSMutableArray *arrayDynamicCategories;
    
    /**
     Discount which has been selected for sharing
     */
    RTStudentDiscount *discountForShare;
    
    /**
     BusinessInfo view controller for redirecting when running from push notification
     */
    BusinessInfoVC *businessInfoVCForRedirect;
    
    int indexOfExpandedCell;
    BOOL isCellExpanded;
    BOOL isOnSearching;
    BOOL isEverSearched;
    BOOL atBottomOfDiscountList;
    BOOL gettingDiscounts;
    BOOL gettingCategories;
    double oldLatitude;
    double oldLongitude;
    
    NSString *currentSelectedCategoryName;
    int currentSelectedCategoryId;
    
    
    __weak IBOutlet NSLayoutConstraint *heightConstraintForShareView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForSearchBar;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForSubmitDiscountView;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForCategoryPickerView;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForMajorPickerView;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForDatePickerView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForMajorPickerView;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *viewForCategoryPickerView;
@property (weak, nonatomic) IBOutlet UIView *viewForMajorPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerCategory;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UILabel *discountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchAllDiscounsLabel;
@property (weak, nonatomic) IBOutlet UIView *categorySelectionView;

//Search
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchDiscountBar;
@property (weak, nonatomic) UIWebView *searchWebView;
@property (weak, nonatomic) NSString *searchDefaultString;

//Rate us view (header view of discount table view)
@property (weak, nonatomic) IBOutlet UILabel *lblRateUsQuestion;
@property (weak, nonatomic) IBOutlet UIButton *btnRateUsNegativeButton;
@property (weak, nonatomic) IBOutlet UIButton *btnRateUsPositiveButton;
@property (weak, nonatomic) IBOutlet UIImageView *ivRateUsFrame;

//No discount error view
@property (weak, nonatomic) IBOutlet UIView *viewForNoDiscountError;
@property (weak, nonatomic) IBOutlet UIImageView *ivFrameForNoDiscountError;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDiscountErrorGuide;
@property (weak, nonatomic) IBOutlet UIView *viewForSubmitDiscount;
@property (weak, nonatomic) IBOutlet UILabel *lblNoDiscountError;
@property (weak, nonatomic) IBOutlet UIButton *noDiscountGoogleButton;
@property (nonatomic, retain) NSString *searchQueryForWebView;


//Date Picker View
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet RTAutocompletingSearchViewController *majorSearchController;

@property (nonatomic, assign) BOOL isShowingProgressIndicator;

@property (nonatomic) UIView *saveForLaterView;
@property (nonatomic) BOOL dontAskAgainForSave;
@property (nonatomic) BOOL dontAskAgainChecker;
@property (nonatomic, weak) UIImageView *dontAskAgainCheckMark;

- (IBAction)searchButtonClicked:(id)sender;
- (IBAction)shareMessageButtonClicked:(id)sender;
- (IBAction)shareMailButtonClicked:(id)sender;
- (IBAction)shareTwitterButtonClicked:(id)sender;
- (IBAction)shareFacebookButtonClicked:(id)sender;
- (IBAction)shareCancelButtonClicked:(id)sender;

@property (strong, nonatomic) CustomRefreshControl *customRefreshControl;
@property (nonatomic) RTShareViewController *shareViewController;
@property (nonatomic) NSMutableArray *arrayForRefresh;
@property BOOL shouldTakeOut;
@property (nonatomic) RTStudentDiscount *discountForSaveLater;
@property (nonatomic) RTDiscountSearchViewController *searchViewController;
@property (nonatomic) RTSubmitViewController *submitViewController;

@property (nonatomic) BOOL searchCategoryCustomIsOpen;
@property (nonatomic) BOOL searchHasBeenStarted;

@end

@implementation StudentDiscountsViewController

@synthesize isShowingProgressIndicator;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    if( isShowingProgressIndicator ) {
        [self hideTableViewProgressIndicator];
        [self showTableViewProgressIndicatorIsInitial:YES];
    }
    self.navigationController.title = @"Discounts";
    if (self.delegate != nil) {
        [self.delegate updateBoneCount];
    }
}

- (void)viewDidLoad {// init data
    isOnSearching = NO;
    isShowingProgressIndicator = NO;
    isEverSearched = NO;
    
    [super viewDidLoad];
    [self.mainTableView setUserInteractionEnabled:NO];
    
    // call api for getting discounts
    arrayDiscountsForList = [[NSMutableArray alloc] init];
    arrayDiscountsForBusiness = [[NSMutableArray alloc] init];
    
    // Initialize categories
    arrayDynamicCategories = [[NSMutableArray alloc] init];
    arrayDefaultCategoryNames = @[kCategoryAllDiscounts, kCategoryFeaturedDiscounts, KCategoryOnlineDiscounts, kCategoryVerifiedDiscounts,  kCategoryPopularDiscounts, kCategoryNewDiscounts];
    currentSelectedCategoryName = kCategoryAllDiscounts;
    currentSelectedCategoryId = -1;
    
    //Check if location service is enabled.
    if( [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            double latitude = [RTLocationManager sharedInstance].latitude, longitude = [RTLocationManager sharedInstance].longitude;
            
            int counter = 0, timeout = 20;
            
            //check if latitude and longitude is avilable for 20 seconds
            while( latitude == 0 && longitude == 0 && counter < timeout ) {
                counter++;
                
                latitude = [RTLocationManager sharedInstance].latitude;
                longitude = [RTLocationManager sharedInstance].longitude;
                
                [NSThread sleepForTimeInterval:1.0f];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getNearbyCategoriesWithIsInitialize:YES];
                [self getNearbyDiscountsWithIsInitialize:NO];
            });
        });
    }
    else {
        [self getNearbyCategoriesWithIsInitialize:YES];
        [self getNearbyDiscountsWithIsInitialize:NO];
    }
    
    //Hides RateUs tile if number of redeem is zero or the duration of app usage is less than one week or user had already rated this app or not passed more than 30 days after user delayed rating the app
    if( [RTUserContext sharedInstance].redeemCount <= 0 || ![self isPastOverDaysFromSignInWithDays:7] || [RTUserContext sharedInstance].wasRated || ( [RTUserContext sharedInstance].rateDelayed && ![self isPastOver30DaysFromDelayRatingApp]) ) {
  
        RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
        if(
           [self isPastOverDaysFromSignInWithDays:14] &&
           currentUser.firstName.length == 0 &&
           currentUser.lastName.length == 0 &&
           currentUser.gender.length == 0 &&
           [currentUser.birthday stringWithFormat:@"MM/dd/yyyy"].length == 0 &&
           currentUser.major.length == 0 &&
           ![RTUserContext sharedInstance].showedProfileQuestion ) {
            shouldShowProfileQuestion = YES;
        }
        shouldShowRateUs = NO;
    }
    
    if( !isAppVersionChecked ) {
        isAppVersionChecked = YES;
        [self checkAppVersionAndForceUpdate];
    }
    
    //Adds Search View
    if( self.majorSearchController == nil ) {
        self.majorSearchController = [RTAutocompletingSearchViewController autocompletingSearchViewController];
        [self.majorSearchController.view setFrame:self.viewForMajorPickerView.bounds];
        self.majorSearchController.delegate = self;
        self.majorSearchController.dataSource = self;
        [self addChildViewController:self.majorSearchController];
        [self.viewForMajorPickerView addSubview:self.majorSearchController.view];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL dontAskAgain = [[userDefaults objectForKey:@"doNotAskAgainForSave"] boolValue];
    self.dontAskAgainForSave = dontAskAgain;
}

- (void)locationManagerChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

- (void)locationManagerUpdateLocation {
    double latitude = [RTLocationManager sharedInstance].latitude;
    double longitude = [RTLocationManager sharedInstance].longitude;
    
    CLLocation *locOld = [[CLLocation alloc] initWithLatitude:oldLatitude longitude:oldLongitude];
    CLLocation *locCurrent = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocationDistance distanceInMeter = [locOld distanceFromLocation:locCurrent];
    
    if( distanceInMeter >= 30 ) {    //Save current location to server if the location has been changed more than 30 metres
        oldLatitude = latitude;
        oldLongitude = longitude;
        
        [[RTServerManager sharedInstance] saveBackgroundLocationWithLatitude:latitude longitude:longitude complete:^(BOOL success, RTAPIResponse *response) {
            if( success ) {
                //
            }
            else {
                //
            }
        }];
    }
}

- (void)userOptionsViewHasChangedWithExpanded:(BOOL)expanded {
    if (!expanded) {
        [self.searchViewController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 46)];
    } else {
        [self.searchViewController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 184)];
        [self.view bringSubviewToFront:self.searchViewController.view];
    }
}

- (void) initViews{
    [super initViews];
    
    if( businessInfoVCForRedirect != nil ) {
        [self.navigationController pushViewController:businessInfoVCForRedirect animated:NO];
    }
    
    //Hides search bar
    [self hideSearchBarWithAnimated:NO];
    [self.searchAllDiscounsLabel setAlpha:0.0f];
    
    //Hides sharing view
    heightConstraintForShareView.constant = 0 - self.shareView.frame.size.height;
    
    indexOfExpandedCell = -1;
    isCellExpanded = NO;

    [self hideCategoryPickerViewWithAnimation:NO];
    [self hideMajorPickerViewWithAnimation:NO];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mainTableView.frame.size.width, 4)];
    [headerView setBackgroundColor:[UIColor roverTownColor6DA6CE]];
//    self.mainTableView.tableHeaderView = headerView;
    self.mainTableView.tableFooterView = headerView;
    
    [self showTableViewProgressIndicatorIsInitial:YES];
    
    //Initialize RateUs view (header view of discounts table view)
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnRateUsPositiveButton];
    [RTUIManager applyRateUsNegativeButtonStyle:self.btnRateUsNegativeButton];
    [self.lblRateUsQuestion setText:kRateUsFirstQuestion];
    
    self.ivRateUsFrame.layer.masksToBounds = NO;
    self.ivRateUsFrame.layer.cornerRadius = kCornerRadiusDefault;
    self.ivRateUsFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivRateUsFrame.layer.shadowRadius = 3;
    self.ivRateUsFrame.layer.shadowOpacity = 0.5;
    
    self.mainTableView.separatorColor = [UIColor clearColor];
    [self.mainTableView setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    
    //Initialize No Discount View
    [self.ivFrameForNoDiscountError.layer setCornerRadius:kCornerRadiusDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdatedForFirstTime) name:kLocationUpdated object:nil];
    
    //Adds Submit Discount view controller
    CGRect bound = self.viewForSubmitDiscount.bounds;
    SubmitDiscountCardViewController *vc = (SubmitDiscountCardViewController *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountCardVC storyboardName:kStoryboardStudentDiscounts];
    vc.delegate = self;
    bound.size.height = 400;
    [vc.view setFrame:bound];
    [self.viewForSubmitDiscount addSubview:vc.view];
    [self addChildViewController:vc];
    [self.searchDiscountBar setAlpha:0.0f];
//    self.searchDiscountBar = nil;
    
}

- (void) initEvents{
    [super initEvents];
    
    NSUInteger code = [CLLocationManager authorizationStatus];
    
    
    if( [[RTUserContext sharedInstance] shouldShowNotificationForEmailVerification] ) {
        
        //Show alert if did receive notification in active state
        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Email Verification" message:@"Oh snap! You still haven't verified your .edu email address. Open our email and do it on the quick before you get locked out of these sweet, sweet discounts." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Help", nil];
        [notificationAlert setTag:kAlertTagEmailVerification];
        [notificationAlert show];
    }
    else if (code == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enable Location Access to sort student discounts nearest to furthest.", nil) message:NSLocalizedString(@"You must enable Location Access for Rovertown in your settings.", nil) delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel",nil];
        [alert setTag:kAlertTagEnableLocationAccess];
        [alert show];
    }
    
    self.pickerCategory.dataSource = self;
    self.pickerCategory.delegate = self;

    arrayDiscountsForList = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopupViews:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.mainTableView addGestureRecognizer:tapGesture];
    [RTLocationManager sharedInstance].delegate = self;
    [[RTLocationManager sharedInstance] requestAccess];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.customRefreshControl = [CustomRefreshControl attachToTableView:self.mainTableView
                                                     withRefreshTarget:self
                                                      andRefreshAction:@selector(refreshTriggered)];
    self.customRefreshControl.backgroundColor = [UIColor clearColor];
    [RTUIManager applyBlurView:self.shareView];
    [RTUIManager applyBlurView:self.viewForCategoryPickerView];
    [RTUIManager applyBlurView:self.viewForMajorPickerView];
    [RTUIManager applyBlurView:self.datePickerView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Resetting the refresh control if the user leaves the screen
    [self.customRefreshControl finishedLoading];
}

#pragma mark - Methods

- (void)setRedirectToBusinessInfoWithStoreId:(int)storeId {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.delegate = self;
    vc.storeId = [NSNumber numberWithInt:storeId];
    businessInfoVCForRedirect = vc;
}

- (void)redirectToBusinessInfoWithStoreId:(int)storeId {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.delegate = self;
    [vc loadDiscountsForStore:storeId];
    businessInfoVCForRedirect = vc;
}

- (BOOL)isPastOverDaysFromSignInWithDays:(int)days {
    NSDate *signInDate = [RTUserContext sharedInstance].signinDate;
    
    if( signInDate == nil ) {
        signInDate = [NSDate date];
    }
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *fromDate, *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:signInDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:currentDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    if( [difference day] >= days )
        return YES;
    else
        return NO;
}

- (BOOL)isPastOver30DaysFromDelayRatingApp {
    NSDate *delayedDate = [RTUserContext sharedInstance].delayRateDate;
    
    if( delayedDate == nil ) {
        delayedDate = [NSDate date];
    }
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *fromDate, *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:delayedDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:currentDate];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    if( [difference day] >= 30 )
        return YES;
    else
        return NO;
}

- (void)showNoDiscountErrorViewWithAnimated : (BOOL)animated errorText:(NSString *) errorText {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    NSArray *localizedStringPieces = [errorText componentsSeparatedByString:@"#"];
    
    // Loop through all the pieces
    NSUInteger msgChunkCount = localizedStringPieces ? localizedStringPieces.count : 0;
    CGPoint wordLocation = CGPointMake(0.0, 0.0);
    for (NSUInteger i = 0; i < msgChunkCount; i++) {
        NSString *chunk = [localizedStringPieces objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;
        }
        BOOL isGoogleLink = [chunk hasPrefix:@"<go>"];
        
        // Create UILabel styling dependent on link
        //UILabel *label = [[UILabel alloc] init];
        self.lblNoDiscountError.font = [UIFont systemFontOfSize:15.0f];
        self.lblNoDiscountError.text = chunk;
        self.lblNoDiscountError.userInteractionEnabled = isGoogleLink;
        if (isGoogleLink) {
            self.lblNoDiscountError.textColor = [UIColor roverTownColorDarkBlue];
            SEL selectorAction = @selector(tapOnGoogleLink:);
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:selectorAction];
            [self.lblNoDiscountError addGestureRecognizer:tapGesture];
            // Trip markup characters from link
            self.lblNoDiscountError.text = [self.lblNoDiscountError.text stringByReplacingOccurrencesOfString:@"<go>" withString:@""];
        } else {
            self.lblNoDiscountError.textColor = [UIColor blackColor];
        }
        [self.lblNoDiscountError sizeToFit];
    }
    if (self.viewForNoDiscountError.frame.size.width < wordLocation.x + self.lblNoDiscountError.bounds.size.width) {
        wordLocation.x = 0.0;
        wordLocation.y += self.lblNoDiscountError.frame.size.height;
        
        // Trim any leading white space
        NSRange startingWhiteSpaceRange = [self.lblNoDiscountError.text rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        if (startingWhiteSpaceRange.location == 0) {
            self.lblNoDiscountError.text = [self.lblNoDiscountError.text stringByReplacingCharactersInRange:startingWhiteSpaceRange withString:@""];
            [self.lblNoDiscountError sizeToFit];
        }
    }
    self.lblNoDiscountError.frame = CGRectMake(wordLocation.x, (2 * wordLocation.y), self.lblNoDiscountError.frame.size.width, self.lblNoDiscountError.frame.size.height);
    
    [self.viewForNoDiscountError addSubview:self.lblNoDiscountError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration animations:^{
            [self.viewForNoDiscountError setAlpha:1.0f];
            [self.viewForSubmitDiscount setAlpha:1.0f];
            [self.mainTableView setAlpha:0.0f];
            [self.view layoutIfNeeded];
        }];
    });
   
}

-(void)showNoDiscountErrorViewWithAnimated:(BOOL)animated errorText:(NSString*)errorText andTerm:(NSString*)searchTerm andLocation:(NSString*)location {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    CGFloat maxWidth = CGRectGetWidth(self.view.frame) - 16;
    
    self.lblNoDiscountError.text = [NSString stringWithFormat:@"Sorry, your search for \"%@\" did not match any discounts.", searchTerm];
    self.lblNoDiscountError.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.lblNoDiscountError.textColor = [UIColor blackColor];
    [self.lblNoDiscountError setPreferredMaxLayoutWidth:maxWidth];
    [self.viewForNoDiscountError addSubview:self.lblNoDiscountError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.noDiscountGoogleButton setTitle:[NSString stringWithFormat:@"Search for \"%@\" on Google", searchTerm] forState:UIControlStateNormal];
    });
    [self.noDiscountGoogleButton addTarget:self action:@selector(googleLinkTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewForNoDiscountError addSubview:self.noDiscountGoogleButton];
    [self.noDiscountGoogleButton setFrame:CGRectMake(8, CGRectGetMaxY(self.lblNoDiscountError.frame), CGRectGetWidth(self.view.frame) - 16, 46)];
    
    [self.view bringSubviewToFront:self.viewForNoDiscountError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration animations:^{
            [self.viewForNoDiscountError setAlpha:1.0f];
            [self.viewForSubmitDiscount setAlpha:1.0f];
            [self.mainTableView setAlpha:0.0f];
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)hideNoDiscountErrorViewWithAnimated : (BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.viewForNoDiscountError setAlpha:0.0f];
        [self.viewForSubmitDiscount setAlpha:0.0f];
        [self.mainTableView setAlpha:1.0f];
    }];
}

- (void)showSearchBarWithAnimated:(BOOL)animated {
    float duration = animated ? kAnimationDurationDefault : 0.0f;
    
    heightConstraintForSearchBar.constant = 10;
    
    [UIView animateWithDuration:duration / 2 animations:^{
        //[self.categorySelectionView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            [self.searchAllDiscounsLabel setAlpha:0.0f];
        }];
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideSearchBarWithAnimated:(BOOL)animated {
    float duration = animated ? kAnimationDurationDefault : 0.0f;
    
    heightConstraintForSearchBar.constant = 0;
    
    [UIView animateWithDuration:duration / 2 animations:^{
        //[self.searchAllDiscounsLabel setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            //[self.categorySelectionView setAlpha:1.0f];
        }];
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showDatePickerViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if( animated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForDatePickerView.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideDatePickerViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if( animated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForDatePickerView.constant = -242.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)tapOnSuggestLink:(id)sender {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_Support];
    SupportVC *supportVC = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
    [supportVC setDefaultSelection:kSubjectSuggestDiscount];
    [self.navigationController pushViewController:supportVC animated:YES];
    
    LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
    [leftNavVC.tableView reloadData];
}

- (void)locationUpdatedForFirstTime {
    if (!self.mainTableView.visibleCells.count) {
        [self getNearbyCategoriesWithIsInitialize:YES];
        [self getNearbyDiscountsWithIsInitialize:NO];
    }
}

- (void)showProfileQuestion {
    [[RTUserContext sharedInstance] setShowedProfileQuestion:YES];
    
    ProfileQuestionVC *vc = (ProfileQuestionVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIProfileQuestionVC storyboardName:kStoryboardStudentDiscounts];
    
    CGRect bound = vc.view.bounds;
    bound.size.height = 259;
    
    [vc.view setBounds:bound];
    vc.delegate = self;
    
    self.mainTableView.tableHeaderView = vc.view;
    self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
    
    [self addChildViewController:vc];
}

- (void)showSubmitDiscountCard {
    SubmitDiscountCardViewController *vc = (SubmitDiscountCardViewController *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountCardVC storyboardName:kStoryboardStudentDiscounts];
    
    CGRect bound = vc.view.bounds;
    bound.size.height = 259;
    
    [vc.view setBounds:bound];
    vc.delegate = self;
    
    self.mainTableView.tableHeaderView = vc.view;
    self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
    
    [self addChildViewController:vc];
}

#pragma mark - Get Nearby Discounts

- (void)searchFinishedWithResults:(NSArray *)results {
    if (self.searchViewController.isInitialSearch) {
        arrayDiscountsForList = [NSMutableArray array];
        [arrayDiscountsForList addObjectsFromArray:results];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
        });
        [self.searchViewController hideAdditionalOptionsWhileSearching];
        [self.searchViewController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 46)];
        [self stopProgressIndicator];

    } else {
        [arrayDiscountsForList addObjectsFromArray:results];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
        });
        [self.searchViewController hideAdditionalOptionsWhileSearching];
        [self.searchViewController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 46)];
        [self stopProgressIndicator];

    }
}

- (void)getNearbyDiscountsWithIsInitialize : (BOOL)isInitialize {
    if (gettingDiscounts) {
        [self stopProgressIndicator];
        return;
    }
    int start = [self setStartWithInitialize:isInitialize];
    
    [self hideNoDiscountErrorViewWithAnimated:YES];
    gettingDiscounts = YES;
    [[RTServerManager sharedInstance] nearbyDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:NO];
        }
        else {
            // TO DO
            // show error
            [self showNoDiscountErrorViewWithAnimated:YES errorText:kNoDiscountCategory];
        }
        
        [self stopProgressIndicator];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            gettingDiscounts = NO;
        });
    }];
}

#pragma mark - Get Categories

-(void) getNearbyCategoriesWithIsInitialize : (BOOL)isInitialize {
    if (gettingCategories) {
        return;
    }
    if (isInitialize) {
        [self initializeExtendedCell];
    }
    
    [self hideNoDiscountErrorViewWithAnimated:YES];
    
    [[RTServerManager sharedInstance] nearbyCategoriesWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSArray *categories = [response.jsonObject objectForKey:@"categories"];
            NSArray *arrayRet = [RTModelBridge getCategoriesFromResposeForGetCategories:categories];
            dispatch_async(dispatch_get_main_queue(), ^{
                if( isInitialize ) {
                    arrayDynamicCategories = [[NSMutableArray alloc] init];
                }
                
                for (RTCategory *category in arrayRet) {
                    [arrayDynamicCategories addObject:category];
                }
                
                [self.pickerCategory reloadAllComponents];
            });
        }
        else {
            //
        }
    }];
}

#pragma mark - Search Discounts

-(void) searchDiscountsWithSearchKey:(NSString*) searchKey isInitialize:(BOOL)isInitialize {
    isOnSearching = YES;
    [self hideNoDiscountErrorViewWithAnimated:YES];
    
    int start = [self setStartWithInitialize:isInitialize];
    
    [[RTServerManager sharedInstance] searchNearbyDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems term:searchKey complete:^(BOOL success, RTAPIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopProgressIndicator];
        });
        
        if( success ) {
            // SONNYSONNYSONNY
            
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:NO];
            NSArray *discounts = [response.jsonObject objectForKey:@"discounts"];
            NSArray *arrayRet = [RTModelBridge getStudentDiscountsFromResponseForGetDiscounts:discounts];
            if (arrayRet.count == 0) {
                [[RTServerManager sharedInstance] getSearchQueryForGoogleWithSearchTerm:searchKey latitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude complete:^(BOOL success, RTAPIResponse *response) {
                    if ( success ) {
                        id searchData = [response.jsonObject objectForKey:@"search"];
                        NSString *searchQuery = [searchData objectForKey:@"query"];
                        self.searchQueryForWebView = searchQuery;
                    } else {
                        NSLog(@"There was no response for the search query!");
                    }
                }];
            }
        }
        else {
            //
        }
        
    }];
}

-(void) buildSearchForWebViewFromString:(NSString *)localizedString
{
    // This will be a webView built from a Google search string
}

-(IBAction)googleLinkTapped:(id)sender {
    [self buildWebViewForGoogleSearch];
}

-(void) tapOnGoogleLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self buildWebViewForGoogleSearch];
    }
}

#pragma mark - UIWebViewDelegate

- (void) buildWebViewForGoogleSearch {
    [Flurry logEvent:@"user_search_google"];
    UIView *containerWebView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGFloat buttonHeight = 0.1 * containerWebView.frame.size.height;
    CGFloat buttonWidth = 0.5 * containerWebView.frame.size.width;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, containerWebView.frame.size.height - buttonHeight)];
    self.searchWebView = webView;
    [containerWebView addSubview:self.searchWebView];
    containerWebView.tag = 45; //This is so that the UIButton can tag the webView for dismissal
    [self.searchWebView setDelegate:self];
    [self.view addSubview:containerWebView];
    NSString *googleSearch = @"https://www.google.com/#q=";
    NSString *urlString = [NSString stringWithFormat:@"%@%@", googleSearch, self.searchQueryForWebView];
    NSString *stringFinal = [urlString stringByReplacingOccurrencesOfString:@"\\s" withString:@"+" options:NSRegularExpressionSearch range:NSMakeRange(0, urlString.length)];
    self.searchDefaultString = stringFinal;
    NSURL *url = [NSURL URLWithString:stringFinal];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.searchWebView loadRequest:urlRequest];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(buttonWidth, webView.frame.size.height, buttonWidth, buttonHeight);
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:@"Close" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [button addTarget:self
               action:@selector(close:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(0, webView.frame.size.height, buttonWidth, buttonHeight);
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [backButton addTarget:self
                   action:@selector(goBack:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [containerWebView addSubview:button];
    [containerWebView addSubview:backButton];

}

-(IBAction)goBack:(id)sender
{
    if ([self.searchWebView canGoBack]) {
        [self.searchWebView goBack];
    } else {
        NSURL *url = [NSURL URLWithString:self.searchDefaultString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.searchWebView loadRequest:request];
        [self.searchWebView reload];
    }
}
-(IBAction)close:(id)sender
{
    [[self.view viewWithTag:45] removeFromSuperview];
}

#pragma mark - Check App Version and Force Update

- (void)checkAppVersionAndForceUpdate {
    [[RTServerManager sharedInstance] checkAppVersion:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                id data = [response.jsonObject objectForKey:@"app"];
                //            NSString *currentVersion = [data objectForKey:@"current_version"];
                BOOL update_available = [[data objectForKey:@"update_available"] boolValue];
                BOOL force_update = [[data objectForKey:@"force_update"] boolValue];
                
                if( update_available ) {
                    if( force_update ) {
                        //Force user to update the app
                        [RTUIManager alertWithTitle:kUpdateNotificationForce message:nil okButtonTitle:@"OK" parentVC:self.navigationController handler:^(UIAlertAction *action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLRoverTownOniTunes]];
                        }];
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUpdateNotificationGeneral message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                        [alert setTag:kAlertTagAppUpdate];
                        
                        [alert show];
                    }
                }
            });
        }
    }];
}

#pragma mark - Category Manipulations

- (void)checkAndAddCategory:(RTCategory *)category {
    
    BOOL isAlreadyExist = NO;
    
    for( RTCategory *existingCategory in arrayDynamicCategories ) {
        if( category.categoryId == existingCategory.categoryId) {
            isAlreadyExist = YES;
            break;
        }
    }
    
    if( isAlreadyExist == NO ) {
        [arrayDynamicCategories addObject:category];
        [self.pickerCategory reloadAllComponents];
    }
}

- (void)searchForCategoryWithID : (int)categoryId isInitialize:(BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    
    [[RTServerManager sharedInstance] categoryDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems categoryId:categoryId complete:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:NO];
        }
        else {
            //
        }
        [self stopProgressIndicator];
    }];
}

-(void) getNewDiscountsWithIsInitialize : (BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    
    [self hideNoDiscountErrorViewWithAnimated:YES];
    
    [[RTServerManager sharedInstance] newDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:YES];
        }
        else {
            //
        }
        [self stopProgressIndicator];
    }];
}

-(void) getPopularDiscountsWithIsInitialize : (BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    
    [self hideNoDiscountErrorViewWithAnimated:YES];
    
    [[RTServerManager sharedInstance] popularDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:YES];
        }
        else {
            //
        }
        
        [self stopProgressIndicator];
    }];
}

- (void) getOnlineDiscountsWithIsInitialize:(BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    RTLocationManager *locationManager = [RTLocationManager sharedInstance];
    [[RTServerManager sharedInstance] onlineDiscountsWithLatitude:locationManager.latitude longitude:locationManager.longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response){
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:YES];
        }
        [self stopProgressIndicator];
    }];
}

-(void) getFeaturedDiscountsWithIsInitialize : (BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    
    [[RTServerManager sharedInstance] featuredDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:YES];
        }
        else {
            //
        }
        
        [self stopProgressIndicator];
    }];
}

-(void) getVerifiedDiscountsWithIsInitialize : (BOOL)isInitialize {
    int start = [self setStartWithInitialize:isInitialize];
    
    [[RTServerManager sharedInstance] verifiedDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:start limit:kNumberOfPullingItems complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            [self getDiscountsSuccessWithResponse:response isInitialize:isInitialize isCategory:YES];
        }
        else {
            //
        }
        
        [self stopProgressIndicator];
    }];
}

#pragma mark - Notifying the pong refresh control of scrolling (Scrollview)

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self showTableViewProgressIndicatorIsInitial:NO];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self hideTableViewProgressIndicator];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.customRefreshControl scrollViewDidScroll];
    isShowingProgressIndicator = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.customRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Listening for the user to trigger a refresh

- (void)refreshTriggered {
    [self collapseCell];
    [self hideTableViewProgressIndicator];
    [self hideRateUsViewWithAnimation:NO];
    
    //Loads discounts for current category
//    [self initializeDiscountsTable];
    
    if( isOnSearching ) {
        [self searchDiscountsWithSearchKey:self.searchDiscountBar.text isInitialize:YES];
    }
    else {
        if( [currentSelectedCategoryName isEqualToString:kCategoryAllDiscounts] )
            [self getNearbyDiscountsWithIsInitialize:YES];
        else if( [currentSelectedCategoryName isEqualToString:kCategoryNewDiscounts] )
            [self getNewDiscountsWithIsInitialize:YES];
        else if( [currentSelectedCategoryName isEqualToString:kCategoryPopularDiscounts] )
            [self getPopularDiscountsWithIsInitialize:YES];
        else if ([currentSelectedCategoryName isEqualToString:KCategoryOnlineDiscounts])
            [self getOnlineDiscountsWithIsInitialize:YES];
        else if( [currentSelectedCategoryName isEqualToString:kCategoryFeaturedDiscounts] )
            [self getFeaturedDiscountsWithIsInitialize:YES];
        else if( [currentSelectedCategoryName isEqualToString:kCategoryVerifiedDiscounts] )
            [self getVerifiedDiscountsWithIsInitialize:YES];
        else if( currentSelectedCategoryId != -1 ){
            [self searchForCategoryWithID:currentSelectedCategoryId isInitialize:YES];
        }
    }
}

- (void) showShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    heightConstraintForShareView.constant = 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void) hideShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    if( heightConstraintForShareView.constant == 0 ) {
        heightConstraintForShareView.constant = 0 - self.shareView.frame.size.height;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (alertView.tag == kAlertTagEnableLocationAccess ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    
    if( buttonIndex == 1)
    {
        if ( alertView.tag == kAlertTagAtBusiness ) {
            if (arrayDiscountsForList.count > 0 && indexOfExpandedCell >= 0 && indexOfExpandedCell < arrayDiscountsForList.count) {
                RTStudentDiscount *studentDiscount = arrayDiscountsForList[indexOfExpandedCell];
                [self gotoRedeemViewWithStudentDiscount:studentDiscount];
            }
        }
        else if (alertView.tag == kAlertTagAppUpdate ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/apple-store/id499947896?mt=8"]];
        }
        else if (alertView.tag == kAlertTagEmailVerification ) {
            EmailLockOutVC *emailLockOutVC = (EmailLockOutVC*)[SessionMgr createEmailVerificationLockOutViewController];
            emailLockOutVC.isAbleToGoBack = YES;
            emailLockOutVC.delegate = self;
            [self.navigationController presentViewController:emailLockOutVC animated:YES completion:nil];
//            [self.navigationController pushViewController:emailLockOutVC animated:YES];
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self hidePopupViews:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchViewController = [[RTDiscountSearchViewController alloc] initWithDelegate:self];
    [self addChildViewController:self.searchViewController];
    [self.view addSubview:self.searchViewController.view];
    
//    !!![searchBar endEditing:YES];
//    
//    isEverSearched = YES;
//    [self initializeDiscountsTable];
//    [self showTableViewProgressIndicatorIsInitial:YES];
//    [self searchDiscountsWithSearchKey:self.searchDiscountBar.text isInitialize:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelSearchDiscount];
}

- (void)cancelSearchDiscount {
    isOnSearching = NO;
    [self.searchDiscountBar setText:@""];
    [self.searchDiscountBar endEditing:YES];
    [self hideSearchBarWithAnimated:YES];
    
    if( isEverSearched ) {
        [self initializeDiscountsTable];
        [self showTableViewProgressIndicatorIsInitial:YES];
        [self getNearbyDiscountsWithIsInitialize:NO];
        isEverSearched = NO;
    }
}

#pragma mark - Other Actions

- (void)gotoRedeemViewWithStudentDiscount:(RTStudentDiscount *)studentDiscount {
    RTRedeemDiscountModel *redeemModel = [[RTRedeemDiscountModel alloc]initWithDiscount:studentDiscount];
    RTRedeemDiscountViewController *redeemViewController = [[RTRedeemDiscountViewController alloc]initWithModel:redeemModel];
    [redeemViewController.view setFrame:self.view.frame];
    [redeemViewController.view setNeedsLayout];
    redeemViewController.delegate = self;
    [self.navigationController pushViewController:redeemViewController animated:YES];
}

- (void)goToDiscountCommentsViewWithStudentDiscount:(RTStudentDiscount *)studentDiscount {
    RTDiscountCommentModel *commentModel = [[RTDiscountCommentModel alloc] initWithStudentDiscount:studentDiscount];
    RTDiscountCommentViewController *commentViewController = [[RTDiscountCommentViewController alloc] initWithModel:commentModel];
    commentViewController.delegate = self;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

- (void)discountCommentViewController:(RTDiscountCommentViewController *)viewController onChangeFollowing:(BOOL)isFollowing {
    StudentDiscountsCell *cell = [self.mainTableView cellForRowAtIndexPath: [NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
    [cell setFollowed:isFollowing];
    cell.discount.store.user.following = [NSNumber numberWithBool:isFollowing];
}

- (void)discountCommentViewController:(RTDiscountCommentViewController *)viewController onUpdateDiscountComments:(int)incrementalComment {
    StudentDiscountsCell *cell = [self.mainTableView cellForRowAtIndexPath: [NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
    [cell setCommentsValue:incrementalComment];
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if( self.pickerCategory == pickerView )
        return arrayDefaultCategoryNames.count + arrayDynamicCategories.count;
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if( self.pickerCategory == pickerView ) {
        if( row  < arrayDefaultCategoryNames.count ) {
            return [arrayDefaultCategoryNames objectAtIndex:row];
        }
        else {
            return ((RTCategory*)arrayDynamicCategories[row - arrayDefaultCategoryNames.count]).title;
        }
    }
    
    return @"";
}

- (void)showCategoryPickerViewWithAnimation:(BOOL)isAnimated {
    if( bottomConstraintForCategoryPickerView.constant == 0 )
        return;
    
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForCategoryPickerView.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideCategoryPickerViewWithAnimation:(BOOL)isAnimated {
    if( bottomConstraintForCategoryPickerView.constant != 0 )
        return;
    
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForCategoryPickerView.constant = -250.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showMajorPickerViewWithAnimation:(BOOL)isAnimated {
    if( bottomConstraintForMajorPickerView.constant == 0 )
        return;
    
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForMajorPickerView.constant = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideMajorPickerViewWithAnimation:(BOOL)isAnimated {
    [self.viewForMajorPickerView endEditing:YES];
    if( bottomConstraintForMajorPickerView.constant != 0 )
        return;
    
    float duration = 0.0f;
    
    if( isAnimated ) {
        duration = 0.2f;
    }
    
    bottomConstraintForMajorPickerView.constant = -250.0f;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Button Actions

- (IBAction)onCategoryButtonClicked:(id)sender {
    if( bottomConstraintForCategoryPickerView.constant == 0 ) {
        [self hideCategoryPickerViewWithAnimation:YES];
    }
    else {
        [self showCategoryPickerViewWithAnimation:YES];
    }
}

- (IBAction)searchButtonClicked:(id)sender {
    if( heightConstraintForSearchBar.constant != 0 ) {
        //Cancel search if search bar has already been showing
        self.searchViewController = [[RTDiscountSearchViewController alloc] initWithDelegate:self];
        [self addChildViewController:self.searchViewController];
        [self.view addSubview:self.searchViewController.view];
        [self cancelSearchDiscount];
    }
    else {
        //Shows search bar
        self.searchViewController = [[RTDiscountSearchViewController alloc] initWithDelegate:self];
        [self addChildViewController:self.searchViewController];
        [self.view addSubview:self.searchViewController.view];
        [self showSearchBarWithAnimated:YES];
    }
}

- (void)categoryButtonTappedFromViewController {
    self.searchCategoryCustomIsOpen = YES;
    [self showCategoryPickerViewWithAnimation:YES];
}

- (IBAction)datePickerDoneButtonClicked:(id)sender {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self.datePicker.date forKey:@"birthday"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BirthdaySetNotification" object:self userInfo:userInfo];
    
    [self hideDatePickerViewWithAnimated:YES];
    [self.mainTableView reloadData];
}

- (IBAction)shareMessageButtonClicked:(id)sender {
    //check if the device is able to send sms
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *contentTextForShare = @"";
    
    if( discountForShare != nil ) {
        contentTextForShare = [NSString stringWithFormat:@"Check out this discount at %@:\n%@.\n%@", discountForShare.store.name, discountForShare.discountDescription, discountForShare.url];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:nil];
    [messageController setBody:contentTextForShare];
    messageController.messageComposeDelegate = self;
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)shareMailButtonClicked:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    NSString *subjectForShare = @"";
    NSString *contentTextForShare = @"";
    
    if( discountForShare != nil ) {
        subjectForShare = [NSString stringWithFormat:@"%@ Discount on RoverTown", discountForShare.store.name];
        contentTextForShare = [NSString stringWithFormat:@"Check out this discount at %@:\n%@.\n%@", discountForShare.store.name, discountForShare.discountDescription, discountForShare.url];
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:subjectForShare];
    [mailController setMessageBody:contentTextForShare isHTML:NO];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)shareTwitterButtonClicked:(id)sender {
    @try {
        NSString *contentTextForShare = @"";
        
        if( discountForShare != nil ) {
            contentTextForShare = [NSString stringWithFormat:@"%@ at %@ via @rovertown", discountForShare.discountDescription, discountForShare.store.name];
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setURL:[NSURL URLWithString:discountForShare.url]];
            [composer setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:discountForShare.store.logo]]]];
            [composer setText:contentTextForShare];
            
            [composer showFromViewController:self completion:^(TWTRComposerResult result){
                if( result == TWTRComposerResultDone ) {
                    
                    double longitude = [RTLocationManager sharedInstance].longitude;
                    double latitude = [RTLocationManager sharedInstance].latitude;
                    
                    [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformTwitter longitude:longitude latitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
                        if( success ) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [RTUserContext sharedInstance].boneCount += 1;
                                [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
                                if (self.delegate != nil) {
                                    [self.delegate updateBoneCount];
                                }
                                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                                
                                [self hideShareViewWithAnimated:YES];
                            });
                        }
                    }];
                }
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)shareFacebookButtonClicked:(id)sender {
    @try {
        NSString *contentTextForShare = @"";
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if( discountForShare != nil ) {
            contentTextForShare = [NSString stringWithFormat:@"%@ at %@ via @rovertown", discountForShare.discountDescription, discountForShare.store.name];
            
            content.contentURL = [NSURL URLWithString:discountForShare.url];
            content.contentDescription = contentTextForShare;
            content.imageURL = [NSURL URLWithString:discountForShare.store.logo];
        }
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)shareCancelButtonClicked:(id)sender {
    [self hideShareViewWithAnimated:YES];
}

- (IBAction)hidePopupViews:(id)sender {
    [self hideCategoryPickerViewWithAnimation:YES];
    [self hideMajorPickerViewWithAnimation:YES];
    [self hideShareViewWithAnimated:YES];
    [self hideDatePickerViewWithAnimated:YES];
}

- (IBAction)onCategoryPickerDone:(id)sender {
    int row = (int)[self.pickerCategory selectedRowInComponent:0];
    
    [self hideCategoryPickerViewWithAnimation:YES];
    
    if (self.searchCategoryCustomIsOpen) {
        if (row < arrayDefaultCategoryNames.count) {
            NSString *categoryName = [arrayDefaultCategoryNames objectAtIndex:row];
            
            [self.searchViewController returnCategoryFromUser:categoryName];
        } else {
            NSString *categoryName = ((RTCategory*)arrayDynamicCategories[row - arrayDefaultCategoryNames.count]).title;
            
            [self.searchViewController returnCategoryFromUser:categoryName];

        }
        self.searchCategoryCustomIsOpen = NO;
    }
    else {
        if( row < arrayDefaultCategoryNames.count ) {
            NSString *categoryName = [arrayDefaultCategoryNames objectAtIndex:row];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", categoryName], @"categoryId", nil];
            [Flurry logEvent:@"user_category_select" withParameters:params];
            if( categoryName == currentSelectedCategoryName )   //Returns if category is current selected category
                return;
            else {
                currentSelectedCategoryName = categoryName;
                currentSelectedCategoryId = -1;
            }
            
            [self initializeDiscountsTable];
            [self.discountsLabel setText:categoryName];
            
            [self showTableViewProgressIndicatorIsInitial:YES];
            if( [categoryName isEqualToString:kCategoryAllDiscounts] ) {
                [self getNearbyDiscountsWithIsInitialize:YES];
            }
            else if( [categoryName isEqualToString:kCategoryNewDiscounts] ) {
                [self getNewDiscountsWithIsInitialize:YES];
            }
            else if( [categoryName isEqualToString:kCategoryPopularDiscounts] ) {
                [self getPopularDiscountsWithIsInitialize:YES];
            }
            else if ([categoryName isEqualToString:KCategoryOnlineDiscounts]) {
                [self getOnlineDiscountsWithIsInitialize:YES];
            }
            else if( [categoryName isEqualToString:kCategoryFeaturedDiscounts] ) {
                [self getFeaturedDiscountsWithIsInitialize:YES];
            }
            else if( [categoryName isEqualToString:kCategoryVerifiedDiscounts] ) {
                [self getVerifiedDiscountsWithIsInitialize:YES];
            }
        }
        else {
            NSString *categoryName = ((RTCategory*)arrayDynamicCategories[row - arrayDefaultCategoryNames.count]).title;
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", categoryName], @"categoryId", nil];
            if( categoryName == currentSelectedCategoryName )   //Returns if category is current selected category
                return;
            else {
                currentSelectedCategoryName = categoryName;
                currentSelectedCategoryId = ((RTCategory*)arrayDynamicCategories[row - arrayDefaultCategoryNames.count]).categoryId;
            }
            
            [self initializeDiscountsTable];
            [self.discountsLabel setText:categoryName];
            //Search for selected category
            [self showTableViewProgressIndicatorIsInitial:YES];
            [Flurry logEvent:@"user_category_select" withParameters:params];
            [self searchForCategoryWithID:((RTCategory*)arrayDynamicCategories[row - arrayDefaultCategoryNames.count]).categoryId isInitialize:YES];
        }
    }
    
}

- (IBAction)onRateUsPositiveButton:(id)sender {
    if( [self.lblRateUsQuestion.text isEqualToString:kRateUsFirstQuestion] ) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.lblRateUsQuestion setText:kRateUsSecondQuestionPositive];
            [self.btnRateUsPositiveButton setTitle:@"Definitely!" forState:UIControlStateNormal];
            [self.btnRateUsNegativeButton setTitle:@"Maybe later" forState:UIControlStateNormal];
            
            [self showRateUsViewWithAnimation:NO question:kRateUsSecondQuestionPositive];
        }];
    }
    else if( [self.lblRateUsQuestion.text isEqualToString:kRateUsSecondQuestionPositive] ) {    //Called when user want to rate this app
        //move to the rating screen in the app store.
        [self hideRateUsViewWithAnimation:YES];
        [RTUserContext sharedInstance].wasRated = YES;
        [RTUserContext sharedInstance].rateDelayed = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=499947896"]];
    }
    else if( [self.lblRateUsQuestion.text isEqualToString:kRateUsSecondQuestionNegative] ) {    //Called when user want to leave feedback for this app
        [RTUserContext sharedInstance].rateDelayed = NO;
        [SessionMgr transitionSystemStateRequest:SessionMgrState_Support];
        SupportVC *supportVC = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
        [self.navigationController pushViewController:supportVC animated:YES];
        
        LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
        [leftNavVC.tableView reloadData];
    }
}

- (IBAction)onRateUsNegativeButton:(id)sender {
    if( [self.lblRateUsQuestion.text isEqualToString:kRateUsFirstQuestion] ) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.lblRateUsQuestion setText:kRateUsSecondQuestionNegative];
            [self.btnRateUsPositiveButton setTitle:@"OK" forState:UIControlStateNormal];
            [self.btnRateUsNegativeButton setTitle:@"Maybe later" forState:UIControlStateNormal];
            
            [self showRateUsViewWithAnimation:NO question:kRateUsSecondQuestionNegative];
        }];
    }
    else {          //Called when user is going to rate or leave feedback later
        [RTUserContext sharedInstance].rateDelayed = YES;
        [RTUserContext sharedInstance].delayRateDate = [NSDate date];
        
        [self hideRateUsViewWithAnimation:YES];
    }
}

- (void)showRateUsViewWithAnimation:(BOOL)animated question:(NSString *)question {
    
    UILabel *lblQuestion = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    
    [lblQuestion setNumberOfLines:0];
    [lblQuestion setText:question];
    [lblQuestion sizeToFit];
    
    float duration =  0.0f;
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        CGRect orgFrame = self.mainTableView.tableHeaderView.frame;
        [self.mainTableView.tableHeaderView setFrame:CGRectMake(orgFrame.origin.x, orgFrame.origin.y, orgFrame.size.width, 126 + lblQuestion.bounds.size.height)];
        self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
    }];
}

- (void)hideRateUsViewWithAnimation:(BOOL)animated {
    
    float duration =  0.0f;
    if( animated ) {
        duration = 0.2f;
        
        [UIView animateWithDuration:duration animations:^{
            [self.mainTableView.tableHeaderView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                CGRect orgFrame = self.mainTableView.tableHeaderView.frame;
                [self.mainTableView.tableHeaderView setFrame:CGRectMake(orgFrame.origin.x, orgFrame.origin.y, orgFrame.size.width, 4)];
                self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
            }];
        }];
    }
    else {
        [UIView animateWithDuration:duration animations:^{
            CGRect orgFrame = self.mainTableView.tableHeaderView.frame;
            [self.mainTableView.tableHeaderView setFrame:CGRectMake(orgFrame.origin.x, orgFrame.origin.y, orgFrame.size.width, 4)];
            self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
        }];
    }
}

- (void)hideProfileQuestionViewWithAnimation:(BOOL)animated {
    
    float duration =  0.0f;
    if( animated ) {
        duration = 0.2f;
        
        [UIView animateWithDuration:duration animations:^{
            [self.mainTableView.tableHeaderView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                CGRect orgFrame = self.mainTableView.tableHeaderView.frame;
                [self.mainTableView.tableHeaderView setFrame:CGRectMake(orgFrame.origin.x, orgFrame.origin.y, orgFrame.size.width, 4)];
                self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
            }];
        }];
    }
    else {
        [UIView animateWithDuration:duration animations:^{
            CGRect orgFrame = self.mainTableView.tableHeaderView.frame;
            [self.mainTableView.tableHeaderView setFrame:CGRectMake(orgFrame.origin.x, orgFrame.origin.y, orgFrame.size.width, 4)];
            self.mainTableView.tableHeaderView = self.mainTableView.tableHeaderView;
        }];
    }
}

#pragma mark Keyboard state
//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if( [self.majorSearchController.searchBar isFirstResponder] ) {
        heightConstraintForMajorPickerView.constant = _keyboardSize.height + 40.0f;
        [self.view layoutIfNeeded];
    }
    else {
        [self hideMajorPickerViewWithAnimation:YES];
    }
}
//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    if( [self.majorSearchController.searchBar isFirstResponder] ) {
        heightConstraintForMajorPickerView.constant = 250.0f;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - RTAutocompletingSearchViewController Delegate

- (void)searchControllerCanceled:(RTAutocompletingSearchViewController *)searchController {
    [self hideMajorPickerViewWithAnimation:YES];
}

- (void)searchController:(RTAutocompletingSearchViewController *)searchController tableView:(UITableView *)tableView selectedResult:(id)result {

    if( [RTUserContext sharedInstance].majorsArray.count == 0 )
        return;
    
    NSString *selectedMajorName = (NSString* )result;
    
    int nSelectedIndex = (int)[[[RTUserContext sharedInstance].majorsArray valueForKeyPath:@"majorName"] indexOfObject:selectedMajorName];
    RTMajor *selectedMajor = [RTUserContext sharedInstance].majorsArray[nSelectedIndex];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithLong:selectedMajor.majorId] forKey:@"majorId"];
    [userInfo setObject:selectedMajor.majorName forKey:@"majorName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MajorSetNotification" object:self userInfo:userInfo];
    
    [self hideMajorPickerViewWithAnimation:YES];
}

- (BOOL)searchControllerShouldPerformBlankSearchOnLoad:(RTAutocompletingSearchViewController *)searchController {
    return YES;
}

#pragma mark - RTAutocompletingSearchViewController Data Source

- (NSArray *)searchControllerDataSourceForSearch {
    NSMutableArray *majorNamesArray = [[RTUserContext sharedInstance].majorsArray valueForKeyPath:@"majorName"];
    
    return majorNamesArray;
}

#pragma mark - UITableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RTStudentDiscount *discount = [arrayDiscountsForList objectAtIndex:indexPath.row];
    
    BOOL isExpanded = isCellExpanded && [indexPath row] == indexOfExpandedCell;
    
    BOOL isInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:discount.store.latitude longitude:discount.store.longitude];
    
    if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
        //Returns table view cell for alcohol discount
        NSString *ident = @"AlcoholDiscountsCellId";
        AlcoholDiscountsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        [cell bind:discount isExpanded:isExpanded animated:NO];
        cell.delegate = self;
        
        return cell;
    }
    else {
        //Returns table view cell for normal discount
        NSString *ident = @"StudentsDiscountsCellId";
        StudentDiscountsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        cell.delegate = self;
        if (isInRange || discount.isOnlineDiscount) {
            cell.isOutOfGeo = NO;
        } else {
            cell.isOutOfGeo = YES;
        }
        [cell bind:discount isExpanded:isExpanded animated:NO];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayDiscountsForList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RTStudentDiscount *discount = [arrayDiscountsForList objectAtIndex:indexPath.row];
    
    BOOL isExpanded = isCellExpanded && [indexPath row] == indexOfExpandedCell;
    
    if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
        //Returns height for alcohol discount
        return [AlcoholDiscountsCell heightForDiscount:discount isExpanded:isExpanded];
    }
    else {
        //Returns height for normal discount
        return [StudentDiscountsCell heightForDiscount:discount isExpanded:isExpanded];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchHasBeenStarted) {
        if (indexPath.row == arrayDiscountsForList.count - 2) {
            [self.searchViewController retrieveMoreSearchResults];
        }
    }
    
    if( arrayDiscountsForList.count < kNumberOfPullingItems )
        return;
    
    if( indexPath.row == [self.mainTableView numberOfRowsInSection:0] - 10 ) {
        [self showTableViewProgressIndicatorIsInitial:NO];
        
        if( isOnSearching ) {
            
            
            // SONNYSONNYSONNY
            
            //[self searchDiscountsWithSearchKey:self.searchDiscountBar.text isInitialize:NO];
            [self.searchViewController retrieveMoreSearchResults];
            
        }
        else if(!atBottomOfDiscountList){
            //Loads more discounts for current category
            if( [currentSelectedCategoryName isEqualToString:kCategoryAllDiscounts] )
                [self getNearbyDiscountsWithIsInitialize:NO];
            else if( [currentSelectedCategoryName isEqualToString:kCategoryNewDiscounts] )
                [self getNewDiscountsWithIsInitialize:NO];
            else if( [currentSelectedCategoryName isEqualToString:kCategoryPopularDiscounts] )
                [self getPopularDiscountsWithIsInitialize:NO];
            else if([currentSelectedCategoryName isEqualToString:KCategoryOnlineDiscounts])
                [self getOnlineDiscountsWithIsInitialize:NO];
            else if( [currentSelectedCategoryName isEqualToString:kCategoryFeaturedDiscounts] )
                [self getFeaturedDiscountsWithIsInitialize:NO];
            else if( [currentSelectedCategoryName isEqualToString:kCategoryVerifiedDiscounts] )
                [self getVerifiedDiscountsWithIsInitialize:NO];
            else if( currentSelectedCategoryId != -1 ){
                [self searchForCategoryWithID:currentSelectedCategoryId isInitialize:NO];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RTStudentDiscount *discount = [arrayDiscountsForList objectAtIndex:indexPath.row];
    RTStudentDiscount *expandedDiscount = nil;
    BOOL isExpanded = isCellExpanded == YES && indexOfExpandedCell == [indexPath row];
    int indexOfOldExpandedCell = indexOfExpandedCell;
    
    
    if( indexOfExpandedCell != -1 ) {
        expandedDiscount = [arrayDiscountsForList objectAtIndex:indexOfExpandedCell];
    }
    
    //Do nothing if selected cell is alcohol discount and restricted for age
//    if( discount != nil && [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
//        if( [AlcoholDiscountsCell isUserRestrictedWithDiscount:discount] ) {
//            return;
//        }
//    }
    
    isCellExpanded = !isExpanded;
    
    if( isExpanded ) {
        indexOfExpandedCell = -1;
    }
    else {
        indexOfExpandedCell = (int)[indexPath row];
    }
    
    if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
        AlcoholDiscountsCell *cell = (AlcoholDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
        if (cell.isAnimating)
            return;
        
        [[self mainTableView] beginUpdates];
        if( expandedDiscount != nil && !isExpanded ) {
            //Collapse expanded discount if the discount is already expanded and expanded discount is not selected discount
            if( [self shouldBeDisplayedAsAgeRestrictionCell:expandedDiscount] ) {
                AlcoholDiscountsCell *expandedCell = (AlcoholDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                
            }
            else {
                StudentDiscountsCell *expandedCell = (StudentDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                
            }
        }
        [cell bind:discount isExpanded:!isExpanded animated:YES];
        [[self mainTableView] endUpdates];
    }
    else {
        StudentDiscountsCell *cell = (StudentDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
        if (cell.isAnimating)
            return;
        
        [[self mainTableView] beginUpdates];
        if( expandedDiscount != nil && !isExpanded ) {
            //Collapse expanded discount if the discount is already expanded and expanded discount is not selected discount
            if( [self shouldBeDisplayedAsAgeRestrictionCell:expandedDiscount] ) {
                AlcoholDiscountsCell *expandedCell = (AlcoholDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                
            }
            else {
                StudentDiscountsCell *expandedCell = (StudentDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                
            }
        }
        [cell bind:discount isExpanded:!isExpanded animated:YES];
        [[self mainTableView] endUpdates];
    }
         
    [self.mainTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexOfExpandedCell == indexPath.row) {
        //Check if the table is being scrolled
        if( tableView.isDragging || tableView.isDecelerating ) {
            indexOfExpandedCell = -1;
            isCellExpanded = NO;
        }
    }
}

- (void)showTableViewProgressIndicatorIsInitial:(BOOL)isInitial {
    
    NSInteger visibleCellMin;
    if( [UIScreen mainScreen].bounds.size.height <= 480 ) {   //When the device is prior to iPhone 5
        visibleCellMin = isCellExpanded && arrayDiscountsForList.count > 2 ? 2 : 3;
    }
    else {
        visibleCellMin = isCellExpanded && arrayDiscountsForList.count > 3 ? 3 : 4;
    }
    
    if (self.mainTableView.visibleCells.count >= visibleCellMin || isInitial) {
        isShowingProgressIndicator = YES;
        
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
        
        self.mainTableView.tableFooterView = footerView;
        [self hideRateUsViewWithAnimation:NO];
    }
}

BOOL shouldShowRateUs = YES;
BOOL shouldShowProfileQuestion = NO;
BOOL isAppVersionChecked = NO;

- (void)hideTableViewProgressIndicator {
    isShowingProgressIndicator = NO;
    if (atBottomOfDiscountList) {
        [UIView animateWithDuration:0.3f animations:^{
            self.mainTableView.tableFooterView = nil;
        }];
    } else {
        self.mainTableView.tableFooterView = nil;
    }
    if( shouldShowRateUs ) {
        [self showRateUsViewWithAnimation:NO question:kRateUsFirstQuestion];
        shouldShowRateUs = NO;
    }
    else if( shouldShowProfileQuestion ){
        [self showProfileQuestion];
        
        shouldShowProfileQuestion = NO;
    }
    [self.mainTableView layoutIfNeeded];
}

-(void) initializeDiscountsTable {
    arrayDiscountsForBusiness = [[NSMutableArray alloc] init];
    arrayDiscountsForList = [[NSMutableArray alloc] init];
    [self.mainTableView reloadData];
}

#pragma mark - Student Discount Cell delegate

- (void)studentDiscountCell:(StudentDiscountsCell *)cell commentsTappedForDiscount:(RTStudentDiscount *)discount {
    [self goToDiscountCommentsViewWithStudentDiscount:discount];
}

////- (void)commentsTappedForDiscount:(RTStudentDiscount *)discount {
//    [self commentsTappedForDiscount:discount];
//}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onRedeem:(RTStudentDiscount *)studentDiscount {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", studentDiscount.store.storeId], @"storeId", nil];
    // show redeem
    
    // call api for redeem discount
    BOOL isInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:studentDiscount.store.latitude longitude:studentDiscount.store.longitude];
    
    if (isInRange && !studentDiscount.isOnlineDiscount) {
        [Flurry logEvent:@"user_child_redeem" withParameters:params];
    }
    
    if (isInRange || studentDiscount.isOnlineDiscount) {
        [self gotoRedeemViewWithStudentDiscount:studentDiscount];
    }
    else {
        [self gotoRedeemViewWithStudentDiscount:studentDiscount];
    }
}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onSaveForLater:(RTStudentDiscount *)studentDiscount {
    [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Saving discount..."];
    BOOL isInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:studentDiscount.store.latitude longitude:studentDiscount.store.longitude];
    self.discountForSaveLater = studentDiscount;
    if (!isInRange) {
        if (!self.dontAskAgainForSave) {
            [self showSaveForLaterAlertForStudentDiscount:studentDiscount forSave:YES];
            
        } else {
            double longitude = [RTLocationManager sharedInstance].longitude;
            double latitude = [RTLocationManager sharedInstance].latitude;
            NSString *longitudeString = [NSString stringWithFormat:@"%f", longitude];
            NSString *latitudeString = [NSString stringWithFormat:@"%f", latitude];
            NSString *discountId = [NSString stringWithFormat:@"%i", studentDiscount.discountId];
            NSString *storeId = [NSString stringWithFormat:@"%i", studentDiscount.store.storeId];
            [[RTServerManager sharedInstance] saveDiscount:discountId forStore:storeId atLongitude:longitudeString andLatitude:latitudeString complete:^(BOOL success, RTAPIResponse *response) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setSaveForLater];
                    });
                } else {
                    //
                }
            }];
        }
    }
}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell unsaveForLater:(RTStudentDiscount *)studentDiscount {
    [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Unsaving discount..."];
    self.discountForSaveLater = studentDiscount;
    if (!self.dontAskAgainForSave) {
        [self showUnsaveForReminderForDiscount:studentDiscount];
    } else {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        NSString *longitudeString = [NSString stringWithFormat:@"%f", longitude];
        NSString *latitudeString = [NSString stringWithFormat:@"%f", latitude];
        NSString *discountId = [NSString stringWithFormat:@"%i", studentDiscount.discountId];
        NSString *storeId = [NSString stringWithFormat:@"%i", studentDiscount.store.storeId];
        
        [[RTServerManager sharedInstance] unsaveDiscount:discountId forStore:storeId atLongitude:longitudeString andLatitude:latitudeString complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setSaveForLater];
//                    [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self];
                });
            } else {
                
            }
        }];
    }
}

-(void)saveForLaterDiscount:(RTStudentDiscount*)discount {
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    NSString *longitudeString = [NSString stringWithFormat:@"%f", longitude];
    NSString *latitudeString = [NSString stringWithFormat:@"%f", latitude];
    NSString *discountId = [NSString stringWithFormat:@"%i", discount.discountId];
    NSString *storeId = [NSString stringWithFormat:@"%i", discount.store.storeId];
    [[RTServerManager sharedInstance] saveDiscount:discountId forStore:storeId atLongitude:longitudeString andLatitude:latitudeString complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.saveForLaterView removeFromSuperview];
                self.saveForLaterView = nil;
                [[self mainTableView] beginUpdates];
                StudentDiscountsCell *expandedCell = (StudentDiscountsCell*)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfExpandedCell inSection:0]];
                [expandedCell setSaveForLater];
                [[self mainTableView] endUpdates];
            });
        } else {
            
        }
    }];
}

-(void)unsaveForLaterDiscount:(RTStudentDiscount *)discount {
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    NSString *longitudeString = [NSString stringWithFormat:@"%f", longitude];
    NSString *latitudeString = [NSString stringWithFormat:@"%f", latitude];
    NSString *discountId = [NSString stringWithFormat:@"%i", discount.discountId];
    NSString *storeId = [NSString stringWithFormat:@"%i", discount.store.storeId];
    [[RTServerManager sharedInstance] unsaveDiscount:discountId forStore:storeId atLongitude:longitudeString andLatitude:latitudeString complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.saveForLaterView removeFromSuperview];
                self.saveForLaterView = nil;
                [[self mainTableView] beginUpdates];
                StudentDiscountsCell *expandedCell = (StudentDiscountsCell*)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfExpandedCell inSection:0]];
                [expandedCell setUnsaveForLater];
                [[self mainTableView] endUpdates];
            });
        } else {
            
        }
    }];
}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onViewBusiness:(RTStudentDiscount *)studentDiscount {
    // show business info
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.delegate = self;
    vc.store = studentDiscount.store;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onFollow:(RTStudentDiscount *)studentDiscount {
    NSString *storeId = [NSString stringWithFormat:@"%d", studentDiscount.store.storeId];
    
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:![studentDiscount.store.user.following boolValue] complete:^(BOOL success, RTAPIResponse *response){
        if( success ) {
            studentDiscount.store.user.following = [NSNumber numberWithBool:(![studentDiscount.store.user.following boolValue])];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setFollowed:[studentDiscount.store.user.following boolValue]];
            });
            for (RTStudentDiscount *otherDiscounts in arrayDiscountsForList) {
                if (otherDiscounts.store.storeId == studentDiscount.store.storeId) {
                    otherDiscounts.store.user.following = studentDiscount.store.user.following;
                }
            }
        }
        else {
            //
        }
    }];
}

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onShare:(RTStudentDiscount *)studentDiscount {
    self.shareViewController = [[RTShareViewController alloc]initWithDiscount:studentDiscount];
    [self addChildViewController:self.shareViewController];
    self.shareViewController.delegate = self;
    [self.shareViewController showShareViewFromView:self.view];
}

- (void)showSaveForLaterAlertForStudentDiscount:(RTStudentDiscount*)studentDiscount forSave:(BOOL)saving{
    self.dontAskAgainChecker = NO;
    UIView *alertMainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertMainView setBackgroundColor:[UIColor clearColor]];
    self.saveForLaterView = alertMainView;
    [self.navigationController.view addSubview:self.saveForLaterView];
    
    UIView *alertViewBackground = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertViewBackground setBackgroundColor:[UIColor blackColor]];
    [alertViewBackground setAlpha:0.85f];
    [self.saveForLaterView addSubview:alertViewBackground];
    [alertViewBackground setFrame:self.saveForLaterView.frame];
    
    CGFloat windowWidth = 0.85 * self.view.frame.size.width;
    CGFloat windowHeight = 0.45 * self.view.frame.size.height;
    UIView *alertViewForeGround = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.navigationController.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 - windowHeight/2, windowWidth, windowHeight)];
    [alertViewForeGround setBackgroundColor:[UIColor whiteColor]];
    [self.saveForLaterView addSubview:alertViewForeGround];
    [alertViewForeGround setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 - windowHeight/2, windowWidth, windowHeight)];
    
    CGFloat buttonHeight = 40;
    CGFloat buttonWidth = 0.5 * windowWidth;
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [confirmButton setBackgroundColor:[UIColor whiteColor]];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    if (saving) {
        [confirmButton addTarget:self action:@selector(confirmedSaveDiscountwithSender:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [confirmButton addTarget:self action:@selector(confirmUnsavedDiscountWithSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.saveForLaterView addSubview:confirmButton];
    [confirmButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight, buttonWidth, buttonHeight)];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    [cancelButton addTarget:self action:@selector(cancelSaveDiscount:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveForLaterView addSubview:cancelButton];
    [cancelButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight, buttonWidth, buttonHeight)];
    
    UIButton *dontAskButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dontAskButton setBackgroundColor:[UIColor clearColor]];
    [dontAskButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dontAskButton setTitle:@"Don't ask me again" forState:UIControlStateNormal];
    dontAskButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [dontAskButton addTarget:self action:@selector(changeStateForDontAsk:) forControlEvents:UIControlEventTouchUpInside];
    [dontAskButton setTag:31];
    [self.saveForLaterView addSubview:dontAskButton];
    [dontAskButton setFrame:CGRectMake(CGRectGetHeight(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight - 30, buttonWidth - 8, 30)];
    
    UIImageView *dontAskAgainImage = [[UIImageView alloc] init];
    self.dontAskAgainCheckMark = dontAskAgainImage;
    [self.saveForLaterView addSubview:self.dontAskAgainCheckMark];
    [self.dontAskAgainCheckMark setBackgroundColor:[UIColor clearColor]];
    [self.dontAskAgainCheckMark setFrame:CGRectMake(CGRectGetMinX(dontAskButton.frame) - 20, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight - 23, 15, 15)];
    self.dontAskAgainCheckMark.contentMode = UIViewContentModeScaleAspectFill;
    [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"unchecked"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    if (saving) {
       titleLabel.text = @"Discount Reminder";
    } else {
        titleLabel.text = @"Cancel Reminder";
    }
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel sizeToFit];
    [self.saveForLaterView addSubview:titleLabel];
    [titleLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 16, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight)/2 + 16, CGRectGetWidth(titleLabel.frame), CGRectGetHeight(titleLabel.frame))];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    if (saving) {
        descriptionLabel.text = @"Since you're not at this business, we'll remind you to use this discount when you get there. Sound good?";
    } else {
        descriptionLabel.text = @"Are you sure you would like to cancel this reminder? You will no longer be reminded when you're near it.";
    }
    
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.numberOfLines = 0;
    [self.saveForLaterView addSubview:descriptionLabel];
    if (IS_IPHONE_6) {
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 60, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else if (IS_IPHONE_5_OR_5S) {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 48, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else if (IS_IPHONE_6_PLUS) {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 72, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 48, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    }
    [descriptionLabel sizeToFit];
}

-(void)showUnsaveForReminderForDiscount:(RTStudentDiscount *)discount {
    self.dontAskAgainChecker = YES;
    UIView *alertMainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertMainView setBackgroundColor:[UIColor clearColor]];
    self.saveForLaterView = alertMainView;
    [self.navigationController.view addSubview:self.saveForLaterView];
    
    UIView *alertViewBackground = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [alertViewBackground setBackgroundColor:[UIColor blackColor]];
    [alertViewBackground setAlpha:0.85f];
    [self.saveForLaterView addSubview:alertViewBackground];
    [alertViewBackground setFrame:self.saveForLaterView.frame];
    
    CGFloat windowWidth = 0.85 * self.view.frame.size.width;
    CGFloat windowHeight = 0.45 * self.view.frame.size.height;
    UIView *alertViewForeGround = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.navigationController.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 - windowHeight/2, windowWidth, windowHeight)];
    [alertViewForeGround setBackgroundColor:[UIColor whiteColor]];
    [self.saveForLaterView addSubview:alertViewForeGround];
    [alertViewForeGround setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 - windowHeight/2, windowWidth, windowHeight)];
    
    CGFloat buttonHeight = 40;
    CGFloat buttonWidth = 0.5 * windowWidth;
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [confirmButton setBackgroundColor:[UIColor whiteColor]];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    [confirmButton addTarget:self action:@selector(confirmUnsavedDiscountWithSender:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.saveForLaterView addSubview:confirmButton];
    [confirmButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight, buttonWidth, buttonHeight)];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    [cancelButton addTarget:self action:@selector(cancelSaveDiscount:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveForLaterView addSubview:cancelButton];
    [cancelButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight, buttonWidth, buttonHeight)];
    
    UIButton *dontAskButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [dontAskButton setBackgroundColor:[UIColor clearColor]];
    [dontAskButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dontAskButton setTitle:@"Don't ask me again" forState:UIControlStateNormal];
    dontAskButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [dontAskButton addTarget:self action:@selector(changeStateForUnsaveDontAsk:) forControlEvents:UIControlEventTouchUpInside];
    [dontAskButton setTag:35];
    [self.saveForLaterView addSubview:dontAskButton];
    [dontAskButton setFrame:CGRectMake(CGRectGetHeight(self.view.frame)/2 - windowWidth/2, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight - 30, buttonWidth - 8, 30)];
    
    UIImageView *dontAskAgainImage = [[UIImageView alloc] init];
    self.dontAskAgainCheckMark = dontAskAgainImage;
    [self.saveForLaterView addSubview:self.dontAskAgainCheckMark];
    [self.dontAskAgainCheckMark setBackgroundColor:[UIColor clearColor]];
    [self.dontAskAgainCheckMark setFrame:CGRectMake(CGRectGetMinX(dontAskButton.frame) - 20, CGRectGetHeight(self.navigationController.view.frame)/2 + CGRectGetHeight(alertViewForeGround.frame)/2 - buttonHeight - 23, 15, 15)];
    self.dontAskAgainCheckMark.contentMode = UIViewContentModeScaleAspectFill;
    [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"checked"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Cancel Reminder";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel sizeToFit];
    [self.saveForLaterView addSubview:titleLabel];
    [titleLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 16, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight)/2 + 16, CGRectGetWidth(titleLabel.frame), CGRectGetHeight(titleLabel.frame))];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"Are you sure you would like to cancel this reminder? You will no longer be reminded when you're near it.";
    
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.numberOfLines = 0;
    [self.saveForLaterView addSubview:descriptionLabel];
    if (IS_IPHONE_6) {
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 60, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else if (IS_IPHONE_5_OR_5S) {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 48, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else if (IS_IPHONE_6_PLUS) {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 72, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    } else {
        [descriptionLabel setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - windowWidth/2 + 24, CGRectGetHeight(self.navigationController.view.frame)/2 - (windowHeight/2) + 48, windowWidth - 48, windowHeight - buttonHeight - CGRectGetHeight(titleLabel.frame) - CGRectGetHeight(dontAskButton.frame) - 16)];
        [descriptionLabel setPreferredMaxLayoutWidth:windowWidth - 48];
    }
    [descriptionLabel sizeToFit];
}

-(IBAction)confirmedSaveDiscountwithSender:(id)sender {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:self.dontAskAgainChecker forKey:@"doNotAskAgainForSave"];
        [userDefaults synchronize];
        self.dontAskAgainForSave = self.dontAskAgainChecker;
        [self saveForLaterDiscount:self.discountForSaveLater];
}

-(IBAction)confirmUnsavedDiscountWithSender:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.dontAskAgainChecker forKey:@"doNotAskAgainForSave"];
    [userDefaults synchronize];
    self.dontAskAgainForSave = self.dontAskAgainChecker;
    [self unsaveForLaterDiscount:self.discountForSaveLater];
}

-(IBAction)cancelSaveDiscount:(id)sender {
    [self.saveForLaterView removeFromSuperview];
    self.saveForLaterView = nil;
}

-(IBAction)changeStateForDontAsk:(id)sender {
    if ([sender tag] == 31) {
        if (self.dontAskAgainChecker == NO) {
            self.dontAskAgainChecker = YES;
            [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"checked"]];
            
        } else {
            self.dontAskAgainChecker = NO;
            [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"unchecked"]];
        }
    }
}

-(IBAction)changeStateForUnsaveDontAsk:(id)sender {
    if ([sender tag] == 35) {
        if (self.dontAskAgainChecker == NO) {
            self.dontAskAgainChecker = YES;
            [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"checked"]];
            
        } else {
            self.dontAskAgainChecker = NO;
            [self.dontAskAgainCheckMark setImage:[UIImage imageNamed:@"unchecked"]];
        }
    }
}

#pragma mark RTShareViewControllerDelegate
- (void)shareViewControllerDone {
    if (self.delegate != nil) {
        [self.delegate updateBoneCount];
    }
    [self.shareViewController removeFromParentViewController];
}

#pragma mark - Alcohol Discount Cell Delegate

- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onTapBirthdayButton:(RTStudentDiscount *)studentDiscount {
    [self showDatePickerViewWithAnimated:YES];
}

- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onFollow:(RTStudentDiscount *)studentDiscount {
    NSString *storeId = [NSString stringWithFormat:@"%d", studentDiscount.store.storeId];
    
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:![studentDiscount.store.user.following boolValue] complete:^(BOOL success, RTAPIResponse *response){
        if( success ) {
            studentDiscount.store.user.following = [NSNumber numberWithBool:(![studentDiscount.store.user.following boolValue])];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setFollowed:[studentDiscount.store.user.following boolValue]];
            });
            for (RTStudentDiscount *otherDiscounts in arrayDiscountsForList) {
                if (otherDiscounts.store.storeId == studentDiscount.store.storeId) {
                    otherDiscounts.store.user.following = studentDiscount.store.user.following;
                }
            }
        }
        else {
            //
        }
    }];
}

- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onSubmitBirthday:(NSDate *)birthday {
    [RTUserContext sharedInstance].currentUser.birthday = birthday;
    [[RTServerManager sharedInstance] updateUser:[RTUserContext sharedInstance].currentUser complete:^(BOOL success, RTAPIResponse *response) {
        //
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView reloadData];
            });
        }
    }];
    
    //Initialize discounts table view
    
    //TODO: When user submits birthday, they discount ticket should be collapsed smoothly
    
}

#pragma mark - Redeem view controller delegate

- (void)boneAndBadgeCountChangedWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( boneCountChanged ) {
            [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
            if (self.delegate != nil) {
                [self.delegate updateBoneCount];
            }
            if( badgeCountChanged ) {
                [self setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
                
                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:^{
                    [RTUIManager playEarnBadgeAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                }];
            }
            else {
                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
            }
        }
        else if( badgeCountChanged ) {
            [self setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
            
            [RTUIManager playEarnBadgeAnimationWithSuperview:self.navigationController.view completeBlock:nil];
        }
    });
}

- (void)discountUnaccepted:(RTStudentDiscount *)discount boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    //Update the navigation bar for bone count
    dispatch_async(dispatch_get_main_queue(), ^{
        [SessionMgr transitionSystemStateRequest:SessionMgrState_Support];
        SupportVC *supportVC = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
        [supportVC setDiscount:discount];
        [self.navigationController pushViewController:supportVC animated:YES];
        
        LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
        [leftNavVC.tableView reloadData];
    });
}

-(void)shareDiscount:(RTStudentDiscount *)discount {
    
}

- (void)changeFollowing:(BOOL)isFollowing {
    StudentDiscountsCell *cell = [self.mainTableView cellForRowAtIndexPath: [NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
    [cell setFollowed:isFollowing];
    cell.discount.store.user.following = [NSNumber numberWithBool:isFollowing];
}

#pragma mark - BusinessInfoVC Delegate

-(void)businessInfoVC:(BusinessInfoVC *)vc onChangeFollowing:(BOOL)isFollowing {
    StudentDiscountsCell *cell = [self.mainTableView cellForRowAtIndexPath: [NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
    [cell setFollowed:isFollowing];
    cell.discount.store.user.following = [NSNumber numberWithBool:isFollowing];
}

#pragma mark - MFMailComposeViewController, MFMessageComposeViewController Delegates

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {

    [controller dismissViewControllerAnimated:YES completion:nil];
    if( result == MessageComposeResultSent ) {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        
        [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformSMS longitude:longitude latitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
            if( success ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RTUserContext sharedInstance].boneCount += 1;
                    [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
                    if (self.delegate != nil) {
                        [self.delegate updateBoneCount];
                    }
                    
                    [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                    [self hideShareViewWithAnimated:YES];
                });
            }
        }];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    [controller dismissViewControllerAnimated:YES completion:nil];
    if( result == MFMailComposeResultSent ) {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        
        [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformEmail longitude:longitude latitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RTUserContext sharedInstance].boneCount += 1;
                [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
                if (self.delegate != nil) {
                    [self.delegate updateBoneCount];
                }
                
                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                [self hideShareViewWithAnimated:YES];
            });
        }];
    }
}

#pragma mark - FBSDKSharingDelegate

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    
    [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformFacebook longitude:longitude latitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [RTUserContext sharedInstance].boneCount += 1;
                [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
                if (self.delegate != nil) {
                    [self.delegate updateBoneCount];
                }
                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                [self hideShareViewWithAnimated:YES];
            });
        }
    }];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    return;
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    return;
}

#pragma mark - ProfileQuestionVC delegate

- (void)profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onFillOutMyProfile:(int)indexOfQuestion {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_Profile];
    ProfileVC *supportVC = (ProfileVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIProfileVC storyboardName:kStoryboardProfile];
    [self.navigationController pushViewController:supportVC animated:YES];
}

- (void)profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onPickBirthday:(int)indexOfQuestion {
    [self showDatePickerViewWithAnimated:YES];
}

- (void)profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onPickMajor:(int)indexOfQuestion {
    [self showMajorPickerViewWithAnimation:YES];
}

- (void)profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onDone:(int)indexOfQuestion firstName:(NSString *)firstName lastName:(NSString *)lastName gender:(NSString *)gender birthdate:(NSDate *)birthdate major:(NSString *)major {
    [RTUserContext sharedInstance].currentUser.firstName = firstName;
    [RTUserContext sharedInstance].currentUser.lastName = lastName;
    [RTUserContext sharedInstance].currentUser.gender = gender;
    [RTUserContext sharedInstance].currentUser.birthday = birthdate;
    [RTUserContext sharedInstance].currentUser.major = major;
    
    [[RTServerManager sharedInstance] updateUser:[RTUserContext sharedInstance].currentUser complete:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            [self.mainTableView reloadData];
        }
    }];
    
    [self hideProfileQuestionViewWithAnimation:YES];
}

- (void)profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onDismiss:(int)indexOfQuestion {
    [self hideProfileQuestionViewWithAnimation:YES];
}

#pragma mark - SubmitDiscountCardViewController Delegate

- (void)submitDiscountCardViewController:(SubmitDiscountCardViewController *)vc onSubmitDiscountButtonClicked:(BOOL)animated {
    
    self.submitViewController = [[RTSubmitViewController alloc] init];
    
    self.submitViewController.title = @"Submit Discount";
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0.0f, 0.0f, 16.0f, 13.0f)];
    [btnBack setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backNavAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [self.submitViewController.navigationItem addLeftBarButtonItem:backButtonItem];
    [self.submitViewController.view setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    
    [self.navigationController pushViewController:self.submitViewController animated:YES];
    
//    LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
//    [leftNavVC.tableView reloadData];
}

-(void)backNavAction {
    self.mm_drawerController.shouldUsePanGesture = YES;
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - EmailLockOutVC Delegate

- (void)emailLockOutVC:(EmailLockOutVC *)vc onGoBackButtonTapped:(RTEmailLockOutModel *)model {
    [vc dismissViewControllerAnimated:YES completion:nil];
    [self.view layoutIfNeeded];
}

#pragma mark - private

- (BOOL) shouldBeDisplayedAsAgeRestrictionCell:(RTStudentDiscount *)discount {
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    
    if( discount.user_restrictions.age_restriction && currentUser.birthday == nil )
        return YES;
    
    if( discount.user_restrictions.age_restriction && [currentUser.birthday stringWithFormat:@"MM/dd/yyyy"].length == 0 )
        return YES;
    
    if ( [NSDate getAgeWithBirthdate:currentUser.birthday] < discount.user_restrictions.minimum_age )
        return YES;
    
    return NO;
}

- (int) setStartWithInitialize:(BOOL)isInitialize {
    if(isInitialize) {
        [self initializeExtendedCell];
        return 0;
    }
    else {
        return (int)arrayDiscountsForList.count;
    }
}

- (void)initializeExtendedCell {
    indexOfExpandedCell = -1;
    isCellExpanded = NO;
}

- (void)setEndReached:(NSInteger) receivedDiscountsCount {
    if (receivedDiscountsCount < kNumberOfPullingItems) {
        atBottomOfDiscountList = YES;
    }
    else {
        atBottomOfDiscountList = NO;
    }
}

- (void)getDiscountsSuccessWithResponse:(RTAPIResponse *)response isInitialize:(BOOL)isInitialize isCategory:(BOOL)isCategory{
    NSArray *discounts = [response.jsonObject objectForKey:@"discounts"];
    NSArray *arrayRet = [RTModelBridge getStudentDiscountsFromResponseForGetDiscounts:discounts];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSInteger numberOfDiscountsReceived = [discounts count];
        NSInteger oldNumberOfDiscounts = arrayDiscountsForList.count;
        NSInteger newNumberOfDiscounts = oldNumberOfDiscounts;
        if( isInitialize ) {
            arrayDiscountsForList = [[NSMutableArray alloc] init];
            arrayDiscountsForBusiness = [[NSMutableArray alloc] init];
        }
        
        if (numberOfDiscountsReceived == 0 && arrayDiscountsForList.count == 0) {
            if( self.searchAllDiscounsLabel.alpha != 0.0f ) { //When this is the search result
                NSString *errorCopy = [NSString stringWithFormat:NSLocalizedString(@"#<go>Sorry! Your search for \"%@\" did not match any discounts. Would you like to try a Google search?#", @"The search should return a term"), self.searchDiscountBar.text];
                //NSString *errorCopy = [NSString stringWithFormat:NSLocalizedString(@"Sorry! Your search for \"%@\" did not match any discounts. Would you like to try #<go>Google?<go>"), self.searchDiscountBar.text];
                
                [self showNoDiscountErrorViewWithAnimated:YES errorText:errorCopy];
            }
            else {
                [self showNoDiscountErrorViewWithAnimated:YES errorText:kNoDiscountCategory];
            }
        }
        else if (numberOfDiscountsReceived != 0 ) {
            [self hideNoDiscountErrorViewWithAnimated:YES];
            for (RTStudentDiscount *discount in arrayRet) {
                if (discount.list_hidden == NO) {
                    [arrayDiscountsForList addObject:discount];
                }
                [arrayDiscountsForBusiness addObject:discount];
            
                if (isCategory) {
                    for( RTCategory *category in discount.store.categories ) {
                        [self checkAndAddCategory:category];
                    }
                }
            }
            
            if( numberOfDiscountsReceived < 4 && self.searchAllDiscounsLabel.alpha != 0.0f ) {
                CGRect bound = self.viewForSubmitDiscount.bounds;
                SubmitDiscountCardViewController *vc = (SubmitDiscountCardViewController *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISubmitDiscountCardVC storyboardName:kStoryboardStudentDiscounts];
                vc.delegate = self;
                bound.size.height = 400;
                [vc.view setFrame:bound];
                self.mainTableView.tableFooterView = vc.view;
                self.mainTableView.tableFooterView = self.mainTableView.tableFooterView;
                [self addChildViewController:vc];
            }
        }
        
        newNumberOfDiscounts = arrayDiscountsForList.count;
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSIndexPath *indexPath;
        if (!isInitialize) {
            [self.mainTableView reloadData];
            [self setEndReached:numberOfDiscountsReceived];
        } else {
            NSInteger numberOfNewCells = newNumberOfDiscounts - oldNumberOfDiscounts;

            if (numberOfNewCells < 0) {
                numberOfNewCells = numberOfNewCells * -1;
                NSMutableArray * indexesToDelete = [NSMutableArray array];
                for (int i = (int)newNumberOfDiscounts-1; i < oldNumberOfDiscounts-1; i++) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [indexesToDelete addObject:indexPath];
                }
                [self.mainTableView beginUpdates];
                [self.mainTableView deleteRowsAtIndexPaths:indexesToDelete withRowAnimation:UITableViewRowAnimationFade];
                [self.mainTableView endUpdates];
            } else {
                [self.mainTableView reloadData];
                [self setEndReached:numberOfDiscountsReceived];
            }
            
            if( self.mainTableView.visibleCells.count > 0 ) {
                for (int i = 0; i < self.mainTableView.visibleCells.count; i++) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    RTStudentDiscount *discount = arrayDiscountsForList[i];
                    if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
                        AlcoholDiscountsCell *cell = (AlcoholDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
                        if (cell.discount.discountId != discount.discountId) {
                            [indexPaths addObject:indexPath];
                        } else {
                            [cell recalculateDistance];
                        }
                    }
                    else {
                        StudentDiscountsCell *cell = (StudentDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
                        if (cell.discount.discountId != discount.discountId) {
                            [indexPaths addObject:indexPath];
                        } else {
                            [cell recalculateDistance];
                        }
                        [cell resetInternalViews];
                    }
                    
                    [self.mainTableView beginUpdates];
                    [self.mainTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.mainTableView endUpdates];
                }
            }
            else {
                [self.mainTableView beginUpdates];
                [self.mainTableView reloadData];
                [self.mainTableView endUpdates];
            }
        }
    });
}

- (void)collapseCell {
    if (indexOfExpandedCell != -1) {
        RTStudentDiscount *discount = arrayDiscountsForList[indexOfExpandedCell];
        
        if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
            AlcoholDiscountsCell *expandedCell = (AlcoholDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView beginUpdates];
                [expandedCell bind:expandedCell.discount isExpanded:NO animated:NO];
                [self.mainTableView endUpdates];
            });
        }
        else {
            StudentDiscountsCell *expandedCell = (StudentDiscountsCell *)[self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexOfExpandedCell inSection:0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTableView beginUpdates];
                [expandedCell bind:expandedCell.discount isExpanded:NO animated:NO];
                [self.mainTableView endUpdates];
            });
        }
        
        indexOfExpandedCell = -1;
        isCellExpanded = NO;
    }
}

- (void)stopProgressIndicator {
    [self.mainTableView setUserInteractionEnabled:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.customRefreshControl != nil) {
            [self.customRefreshControl finishedLoading];
            [self hideTableViewProgressIndicator];
        }
    });
}

#pragma mark - RTDiscountSearchViewControllerDelegate

////-(void)searchFailedWithMessage:(NSString*)query {
//    NSLog(@"%@", query);
//    NSString *googleErrorCopy = [NSString stringWithFormat:NSLocalizedString(@"#<go>Search for \"%@\" did not match any discounts. Would you like to try a Google search?#", @"The search should return a term"), query];
//    [self showNoDiscountErrorViewWithAnimated:YES errorText:googleErrorCopy];
//}

- (void)searchFailedWithQuery:(NSString *)query andLocation:(NSString *)location andTerm:(NSString *)term {
    self.searchQueryForWebView = query;
    NSString *errorMessage = [NSString stringWithFormat:NSLocalizedString(@"#<go>Search for \"%@\" on Google#", @"The search should return a term"), term];
    [self showNoDiscountErrorViewWithAnimated:YES errorText:errorMessage andTerm:term andLocation:location];
    
   // NSString *googleErrorCopy = [NSString stringWithFormat:@"#<go>Sorry! Your search for \"%@\" did not match any discounts. Would you like to try a Google search?#"]
}

- (void)searchCancelledFromViewController {
    [self hideSearchBarWithAnimated:YES];
    [self.searchViewController.view removeFromSuperview];
    [self.searchViewController removeFromParentViewController];
    self.searchViewController = nil;
}

- (void)searchInitializedByUser {
    [self hideNoDiscountErrorViewWithAnimated:YES];
    arrayDiscountsForList = [NSMutableArray array];
    [self showTableViewProgressIndicatorIsInitial:YES];
    [[RTUIManager sharedInstance] showToastMessageWithView:self.view labelText:nil descriptionText:@"Searching for discounts..."];
    [self.searchViewController hideAdditionalOptionsWhileSearching];
}

@end

/*************************************************************************************************************************
***********************************************SubmitDiscountCardViewController*******************************************
**************************************************************************************************************************/

#pragma mark - SubmitDiscountCardViewController Implementation

@interface SubmitDiscountCardViewController()

@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmitDiscount;

@end

@implementation SubmitDiscountCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    [self initEvents];
}

- (void)initViews {
    [RTUIManager applyContainerViewStyle:self.vwContainer];
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnSubmitDiscount];
}

- (void)initEvents {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)onSubmitDiscountButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate submitDiscountCardViewController:self onSubmitDiscountButtonClicked:YES];
    }
}



@end
