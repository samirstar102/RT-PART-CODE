//
//  BusinessInfoViewController.m
//  RoverTown
//
//  Created by Robin Denis on 5/21/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "BusinessInfoVC.h"
#import "LeftNavViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "RTUIManager.h"
#import "BusinessInfoDiscountsCell.h"
#import "BusinessInfoContactCell.h"
#import "AlcoholDiscountsCell.h"
#import "RedeemVC.h"
#import "SupportVC.h"
#import "SessionMgr.h"
#import "RTServerManager.h"
#import "RTStoryboardManager.h"
#import "RTModelBridge.h"
#import "RTLocationManager.h"
#import "RTUserContext.h"
#import "RTStoryboardManager.h"
#import "NSURL+String.h"
#import "NSDate+Utilities.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "RTRedeemDiscountModel.h"
#import "RTRedeemDiscountViewController.h"

#import "RTAlertViewController.h"

#import "RTActivity.h"
#import "RTActivityFeedCell.h"

#import "RTDiscountCommentViewController.h"
#import "RTDiscountCommentModel.h"
#import "RTShareViewController.h"
#import "RTActivityFeedViewController.h"
#import "RTActivityFeedModel.h"
#import "RTPublicProfileViewController.h"

//Index Constants
const int INDEX_CALL_STORE = 0;
const int INDEX_NAVIGATE_TO_STORE = 1;
const int INDEX_REDEEM = 2;

#define kAlertTagAtBusiness             (10001)

@interface BusinessInfoVC () <BusinessInfoDiscountsCellDelegate, BusinessInfoContactCellDelegate, RedeemVCDelegate, AlcoholDiscountsCellDelegate, RTRedeemDiscountModelDelegate, RTRedeemDiscountViewControllerDelegate,RTRedeemDiscountViewDelegate,RTRedeemOnlineDiscountViewProtocol, RTActivityFeedCellDelegate, RTDiscountCommentViewControllerDelegate, RTActivityFeedModelDelegate,
RTShareViewControllerDelegate, RTActivityFeedViewControllerDelegate>
{
    NSArray *menuData;
    RTStudentDiscount *redeemDiscount;
    int indexOfExpandedCell;
    BOOL isCellExpanded;    //Indicates one of the table view cells of discounts table is expanded
    BOOL isDiscounts;   //Indicates whether discounts table should be displayed or contact info should be displayed
    CLLocationCoordinate2D *currentLocation;
    NSMutableArray *arrayDiscountsForStore;
    
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForDatePickerView;
}
@property (nonatomic) RTActivityFeedViewController *activiyViewController;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITableView *discountsTableView;
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *followButtonView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) RTStudentDiscount *discountToRetain;
@property (nonatomic, retain) RTRedeemDiscountModel *modelToRetain;

@property (strong, nonatomic) NSArray *activities;
@property (nonatomic) UIView *activityImageFullView;
@property (nonatomic) UIImageView *activityImageFullImageView;
@property (nonatomic) UIButton *dismissActivityImageFullViewButton;

@property (nonatomic) RTShareViewController *shareViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForDiscounts;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForContact;

@property (nonatomic) BOOL isShowingProgressIndicator;
@property (nonatomic) BOOL atBottomOfActivityList;

- (IBAction)onFollowButton:(id)sender;

@end

@implementation BusinessInfoVC

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up navigation controller as backable
    [self setUpBackableNavBar];
}

- (void) initViews{
    [super initViews];
    
    indexOfExpandedCell = -1;
    isCellExpanded = NO;
    isDiscounts = YES;
    
    //Initialize discounts table view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.discountsTableView.frame.size.width, 8)];
    [headerView setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    self.discountsTableView.tableHeaderView = headerView;
    
    //Initializes contact table view
    self.contactTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    [self.contactTableView reloadData];
    
    //Initialize appearance for following button
    self.followButton.adjustsImageWhenHighlighted = NO;
    self.followButton.adjustsImageWhenDisabled = NO;
    [RTUIManager applyFollowForUpdatesButtonStyle:self.followButton];
    
    //Show/Hide Discounts and Contact table views
    [self showDiscountsTableWithAnimated:NO];
    
    arrayDiscountsForStore = [[NSMutableArray alloc] init];
    
    if( self.storeId != nil && self.store == nil ) {
        [self loadDiscountsForStore:[self.storeId intValue]];
    }
    else if( self.store != nil ) {
        [self initViewsWithStore:self.store];
    }
    
    self.logoImageView.layer.masksToBounds = YES;
    //Initialize borders
    [self.logoImageView.layer setBorderWidth:2.0f];
    [self.logoImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.buttonsView.layer setBorderWidth:1.0f];
    [self.buttonsView.layer setBorderColor:[[UIColor colorWithRed:(188.0/255.0f) green:(190.0/255.0f) blue:(192.0/255.0f) alpha:1.0f] CGColor]];
    [self.followButtonView.layer setBorderWidth:1.0f];
    [self.followButtonView.layer setBorderColor:[[UIColor colorWithRed:(188.0/255.0f) green:(190.0/255.0f) blue:(192.0/255.0f) alpha:1.0f] CGColor]];
    [self.titleView.layer setBorderWidth:1.0f];
    [self.titleView.layer setBorderColor:[[UIColor colorWithRed:(188.0/255.0f) green:(190.0/255.0f) blue:(192.0/255.0f) alpha:1.0f] CGColor]];
}

- (void)initViewsWithStore:(RTStore *)store {
    //Set logo image
    self.store = store;
    self.storeId = [NSNumber numberWithInt:self.store.storeId];
    [self.logoImageView setAlpha:0.0f];
    [self.storeNameLabel setAlpha:0.0f];
    [self.addressLabel setAlpha:0.0f];
    [self.segment setAlpha:0.0f];
    
    if( store != nil ) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", store.storeId], @"storeId", nil];
        [Flurry logEvent:@"user_store_info_view" withParameters:params];
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:store.logo]
                              placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
        
        //Initialize label texts
        self.storeNameLabel.text = store.name;

        [UIView animateWithDuration:0.2f animations:^{
            [self.logoImageView setAlpha:1.0f];
            [self.storeNameLabel setAlpha:1.0f];
            [self.addressLabel setAlpha:1.0f];
        }];

        //Initialize follow button
        [self setFollowButtonEnabled:[store.user.following boolValue]];
        
        // filter store array
        if( [store.discounts count] == 0 ) {
            [self loadDiscountsForStore:store.storeId];
        }
        else {
            arrayDiscountsForStore = [[NSMutableArray alloc] initWithArray:store.discounts];
            
            //Expands discount if the business has only one discount
            if( arrayDiscountsForStore.count == 1 ) {
                isCellExpanded = YES;
                indexOfExpandedCell = 0;
            }
            
            [self showSegmentMenuOptions];
            [self showStoreLocationDetails:store];
            
            [self.discountsTableView reloadData];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Init date picker view
    [RTUIManager applyBlurView:self.datePickerView];
}

- (void)showWithStoreId:(NSNumber *)storeId {
    [self loadDiscountsForStore:[storeId intValue]];
}

- (void)loadDiscountsForStore:(int)storeId {
    
    [RTUIManager showProgressIndicator : self.discountsTableView frameWidth:self.view.frame.size.width];
    
    [[RTServerManager sharedInstance] getStore:[NSString stringWithFormat:@"%d", storeId] complete:^(BOOL success, RTAPIResponse *response){
        
        if( success ) {
            NSDictionary *dicStore = [[response jsonObject] objectForKey:@"store"];
            self.store = [RTModelBridge getStoreWithDictionary:dicStore];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( self.store.discounts.count != 0 ) {
                    [self initViewsWithStore:self.store];
                }
            });
        }
        else {
            /*
             ADD REDIRECT TO MAIN STUDENT DISCOUNT VIEW
             */

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator : self.discountsTableView];
        });
    }];
}

- (void)showSegmentMenuOptions
{
    
    if (self.store.discounts.count && self.store.onlineOnly && self.segment.numberOfSegments == 3)
        [self.segment removeSegmentAtIndex:self.segment.numberOfSegments - 1 animated:NO];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.segment setAlpha:1.0f];
    }];
}

- (void)showStoreLocationDetails:(RTStore *)store
{
    
    if (store.discounts.count && store.onlineOnly) {
        self.addressLabel.text = @"";
        self.distanceLabel.text = @"";
    } else {
        NSString *locationString = [NSString stringWithFormat:@"%@, %@ %@ %@", store.location.address, store.location.city, store.location.state, store.location.zip];
        
        self.addressLabel.text = locationString;
        self.addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.distanceLabel.text = [self retrieveDistanceToStore:self.store];
    }
}

- (void)showDiscountsTableWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.contactTableView setAlpha:0.0f];
        [self.activiyViewController.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.discountsTableView setAlpha:1.0f];
        }];
    }];
}

- (void)showContactTableWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contactTableView reloadData];
    });
    
    [UIView animateWithDuration:duration animations:^{
        [self.discountsTableView setAlpha:0.0f];
        [self.activiyViewController.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.contactTableView setAlpha:1.0f];
        }];
    }];
}

- (void)showActivityTableWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if (animated) {
        duration = 0.2f;
    }
    if (!self.activiyViewController) {
        RTActivityFeedViewController *activityVC = [[RTActivityFeedViewController alloc] initWithStoreId:[NSString stringWithFormat:@"%i", self.store.storeId]];
        self.activiyViewController = activityVC;
        self.activiyViewController.delegate = self;
    }
    CGFloat remainingHeight = self.view.frame.size.height - self.titleView.frame.size.height - self.buttonsView.frame.size.height - self.followButtonView.frame.size.height;
    [self addChildViewController:self.activiyViewController];
    [self.activiyViewController.view setFrame:self.discountsTableView.frame];
    [self.activiyViewController.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, remainingHeight)];
    [self.activiyViewController.view setAlpha:0];
    [self.view addSubview:self.activiyViewController.view];
    
    [UIView animateWithDuration:duration animations:^{
        [self.discountsTableView setAlpha:0.0f];
        [self.contactTableView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.activiyViewController.view setAlpha:1.0];
        }];
    }];
}

- (BOOL) shouldBeDisplayedAsAgeRestrictionCell:(RTStudentDiscount *)discount {
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    
    if( (discount.user_restrictions.age_restriction && [currentUser.birthday stringWithFormat:@"MM/dd/yyyy"].length == 0 ) ||
       [NSDate getAgeWithBirthdate:currentUser.birthday] < discount.user_restrictions.minimum_age ) {
        return YES;
    }
    
    return NO;
}

- (void)activitiesSucess:(NSArray *)activities {
    _activities = [NSArray arrayWithArray:activities];
}

- (void)activitiesFailed {
}

#pragma mark - table view delegate, data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( tableView == self.discountsTableView ) {
        return arrayDiscountsForStore.count;
    }
    else if( tableView == self.contactTableView ) {
        return 2;
    }
    else {
        return _activities.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( tableView == self.discountsTableView ) {
        RTStudentDiscount *discount = [arrayDiscountsForStore objectAtIndex:indexPath.row];
        
        if( isCellExpanded && [indexPath row] == indexOfExpandedCell ) {
            //Height when cell is expanded.
            if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
                return [AlcoholDiscountsCell heightForDiscount:discount isExpanded:YES];
            }
            else {
                return [BusinessInfoDiscountsCell heightForDiscount:discount isExpanded:YES];
            }
        }
        
        if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
            return [AlcoholDiscountsCell heightForDiscount:discount isExpanded:NO];
        }
        else {
            return [BusinessInfoDiscountsCell heightForDiscount:discount isExpanded:NO];
        }
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        
        RTActivity *activity = nil;
        if (_activities.count) {
            activity = [self.activities objectAtIndex:indexPath.row];
        }
        BOOL imageExists = ![activity.imageString isEqualToString:@""];
        return [RTActivityFeedCell heightForCellBusinessActivity:activity andView:self.view WithImage:imageExists];
        
    }
    else if( tableView == self.contactTableView ){
        if( indexPath.row == 0 ) {
            RTStoreLocation *storeLocation = self.store.location;
            NSString *locationInfo = [NSString stringWithFormat:@"%@, %@, %@, %@", storeLocation.address, storeLocation.city, storeLocation.state, storeLocation.zip];
            return [BusinessInfoContactCell heightForContactWithLabelText:locationInfo];
        }
        else if( indexPath.row == 1 ) {
            return [BusinessInfoContactCell heightForContactWithLabelText:self.store.location.phone];
        }
        else {
            return [BusinessInfoContactCell heightForContactWithLabelText:@""];
        }
        
    }
    else {
        return 0;
    }
}

- (void)activityCell:(RTActivityFeedCell *)cell onDiscountTapped:(RTStudentDiscount *)discount {
    // do nothing
    [self goToDiscountCommentViewWithDiscount:discount];
}

- (void)activityCell:(RTActivityFeedCell *)cell onUserTappedWithUserId:(int)userId {
    RTPublicProfileViewController *publicViewController = [[RTPublicProfileViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:publicViewController animated:YES];
}

- (void)userIdTappedForUserId:(int)userId {
    RTPublicProfileViewController *publicViewController = [[RTPublicProfileViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:publicViewController animated:YES];
}

- (void)goToPublicUserProfileForUserId:(int)userId {
    RTPublicProfileViewController *publicViewController = [[RTPublicProfileViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:publicViewController animated:YES];
}

-(void)goToDiscountCommentViewWithDiscount:(RTStudentDiscount*)discount {
    RTDiscountCommentModel *commentModel = [[RTDiscountCommentModel alloc] initWithStudentDiscount:discount];
    RTDiscountCommentViewController *commentVC = [[RTDiscountCommentViewController alloc] initWithModel:commentModel];
    commentVC.delegate = self;
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)activityCell:(RTActivityFeedCell *)cell onCommentTapped:(RTStudentDiscount *)discount {
    // do nothing also
    [self goToDiscountCommentViewWithDiscount:discount];
}

- (void)activityCell:(RTActivityFeedCell *)cell onViewBusiness:(RTStore *)store {
    // also do nothing
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ident;
    
    if( tableView == self.discountsTableView ) {
        RTStudentDiscount *discount = [arrayDiscountsForStore objectAtIndex:indexPath.row];
        
        if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
            ident = @"AlcoholDiscountsCellId";
            AlcoholDiscountsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
            if( isCellExpanded && [indexPath row] == indexOfExpandedCell ) {
                [cell bind:discount isExpanded:YES animated:NO];
            }
            else {
                [cell bind:discount isExpanded:NO animated:NO];
            }
            cell.delegate = self;
            
            return cell;
        }
        else {
            ident = @"BusinessInfoDiscountsCellId";
            BusinessInfoDiscountsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
            if( isCellExpanded && [indexPath row] == indexOfExpandedCell ) {
                [cell bind:discount isExpanded:YES animated:NO];
            }
            else {
                [cell bind:discount isExpanded:NO animated:NO];
            }
            cell.delegate = self;
            
            return cell;
        }
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        RTActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCellIdentifier"];
        if (cell == nil) {
            cell = [[RTActivityFeedCell alloc] initWithActivity:self.activities[indexPath.row]];
        }
        cell.delegate = self;
        [cell setActivity:self.activities[indexPath.row]];
        [cell setSelected:NO];
        return cell;
    }
    else if( tableView == self.contactTableView ) {
        ident = @"BusinessInfoContactCellId";
        BusinessInfoContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        
        NSArray *buttonNameArray = @[@"Navigate to Store", @"Call Store"];
        [cell setTag:indexPath.row];
        
        if( indexPath.row == 0 ) {
            RTStoreLocation *storeLocation = self.store.location;
            NSString *locationInfo = [NSString stringWithFormat:@"%@, %@, %@, %@", storeLocation.address, storeLocation.city, storeLocation.state, storeLocation.zip];
            [cell bind:self.store buttonName:buttonNameArray[indexPath.row] labelText:locationInfo];
        }
        else if( indexPath.row == 1 ) {
            [cell bind:self.store buttonName:buttonNameArray[indexPath.row] labelText:self.store.location.phone];
        }
        else {
            [cell bind:self.store buttonName:buttonNameArray[indexPath.row] labelText:@""];
        }
        
        cell.delegate = self;
        
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( tableView == self.discountsTableView ) {
        RTStudentDiscount *discount = [arrayDiscountsForStore objectAtIndex:indexPath.row];
        RTStudentDiscount *expandedDiscount = nil;
        BOOL isExpanded = isCellExpanded == YES && indexOfExpandedCell == [indexPath row];
        int indexOfOldExpandedCell = indexOfExpandedCell;
        
        
        if( indexOfExpandedCell != -1 ) {
            expandedDiscount = [arrayDiscountsForStore objectAtIndex:indexOfExpandedCell];
        }
        
        //Do nothing if selected cell is alcohol discount and restricted for age
//        if( discount != nil && [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
//            if( [AlcoholDiscountsCell isUserRestrictedWithDiscount:discount] ) {
//                return;
//            }
//        }
        
        isCellExpanded = !isExpanded;
        
        if( isExpanded ) {
            indexOfExpandedCell = -1;
        }
        else {
            indexOfExpandedCell = (int)[indexPath row];
        }
        
        if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
            AlcoholDiscountsCell *cell = (AlcoholDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:indexPath];
            if (cell.isAnimating)
                return;
            
            [self.discountsTableView beginUpdates];
            if( expandedDiscount != nil && !isExpanded ) {
                //Collapse expanded discount if the discount is already expanded and expanded discount is not selected discount
                if( [self shouldBeDisplayedAsAgeRestrictionCell:expandedDiscount] ) {
                    AlcoholDiscountsCell *expandedCell = (AlcoholDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                    [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                    
                }
                else {
                    BusinessInfoDiscountsCell *expandedCell = (BusinessInfoDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                    [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                    
                }
            }
            [cell bind:discount isExpanded:!isExpanded animated:YES];
            [self.discountsTableView endUpdates];
        }
        else {
            BusinessInfoDiscountsCell *cell = (BusinessInfoDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:indexPath];
            if (cell.isAnimating)
                return;
            
            [self.discountsTableView beginUpdates];
            if( expandedDiscount != nil && !isExpanded ) {
                //Collapse expanded discount if the discount is already expanded and expanded discount is not selected discount
                if( [self shouldBeDisplayedAsAgeRestrictionCell:expandedDiscount] ) {
                    AlcoholDiscountsCell *expandedCell = (AlcoholDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                    [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                    
                }
                else {
                    BusinessInfoDiscountsCell *expandedCell = (BusinessInfoDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                    [expandedCell bind:expandedDiscount isExpanded:NO animated:YES];
                    
                }
            }
            [cell bind:discount isExpanded:!isExpanded animated:YES];
            [self.discountsTableView endUpdates];
        }
        
        [self.discountsTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if( !isDiscounts )
        return;
    
    //Check if expanded cell is visible. If not, then collapse the cell.
    if( indexOfExpandedCell != -1  && isCellExpanded ) {
        CGRect cellRect = [self.discountsTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfExpandedCell inSection:0]];
        
        CGRect cellTopHalfRect = CGRectMake(cellRect.origin.x, cellRect.origin.y, cellRect.size.width, cellRect.size.height * 1 / 3);
        CGRect cellBottomHalfRect = CGRectMake(cellRect.origin.x, cellRect.origin.y + cellRect.size.height * 1 / 3, cellRect.size.width, cellRect.size.height * 2 / 3);
        
        if( !(CGRectContainsRect(self.discountsTableView.bounds, cellTopHalfRect) || CGRectContainsRect(self.discountsTableView.bounds, cellBottomHalfRect))) {
            
            BOOL toBeCollapsed = YES;
            
            //Check if is cell in bottom area (last 6 cells)
            if( indexOfExpandedCell >= [self.discountsTableView numberOfRowsInSection:0] - 8 ) {
                
                CGFloat heightSumOfBelowCells = 0.0f;
                
                for( int i = indexOfExpandedCell + 1; i < [self.discountsTableView numberOfRowsInSection:0]; i++ ){
                    heightSumOfBelowCells += [self.discountsTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].size.height;
                    heightSumOfBelowCells += 8.0f;
                }
                
                if( (heightSumOfBelowCells < self.discountsTableView.bounds.size.height) && !(CGRectContainsRect(self.discountsTableView.bounds, CGRectMake(cellTopHalfRect.origin.x, cellTopHalfRect.origin.y, cellTopHalfRect.size.width, 1))) ) {
                    toBeCollapsed = NO;
                }
            }
            
            //Collapsing Cell
            if( toBeCollapsed ) {
                RTStudentDiscount *discount = [arrayDiscountsForStore objectAtIndex:indexOfExpandedCell];
                
                isCellExpanded = NO;
                [[self discountsTableView] beginUpdates];
                if( [self shouldBeDisplayedAsAgeRestrictionCell:discount] ) {
                    AlcoholDiscountsCell *cell = (AlcoholDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfExpandedCell inSection:0]];
                    [cell bind:discount isExpanded:NO animated:YES];
                }
                else {
                    BusinessInfoDiscountsCell *cell = (BusinessInfoDiscountsCell *)[self.discountsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfExpandedCell inSection:0]];
                    [cell bind:discount isExpanded:NO animated:YES];
                }
                [[self discountsTableView] endUpdates];
                indexOfExpandedCell = -1;
            }
        }
    }
}

#pragma mark - BusinessInfoDiscountsCell cell delegate
- (void)businessInfoContactCell:(BusinessInfoContactCell *)cell onContactButton:(RTStore *)store {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", store.storeId], @"store_id", nil];

    if( cell.tag == 0 ) {    //when clicked "Navigate to Store".
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Navigate to Store" message:@"Do you want to launch your maps application to navigate to this store? This will take you out of RoverTown." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Launch Maps", nil];
        [alert setTag:INDEX_NAVIGATE_TO_STORE];
        [alert show];
        [Flurry logEvent:@"user_navigate_store" withParameters:params];

    }
    else if( cell.tag == 1 ) {   //when clicked "Call Store".
        //Check if device has telephone capabilities
        if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLByFormattedPhoneNumberString:self.store.location.phone]] ) {
            [Flurry logEvent:@"user_call_store" withParameters:params];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call Store" message:@"Do you want to launch your dialer to call this store? This will take you out of RoverTown." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call Store", nil];
            [alert setTag:INDEX_CALL_STORE];
            [alert show];
        }
        else {
            [Flurry logEvent:@"user_call_store_failure" withParameters:params];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device cannot make a phone call." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell onRedeem:(RTStudentDiscount *)businessInfoDiscount  {
    [businessInfoDiscount setStore:self.store];
    RTStore *storeToCheck = self.store;
    BOOL isInRange = [[RTLocationManager sharedInstance] isInRageWithDistanceInMile:kRedemptionRangeInMile latitude:storeToCheck.latitude longitude:storeToCheck.longitude];
    if (isInRange || businessInfoDiscount.isOnlineDiscount) {
        [self gotoRedeemViewWithStudentDiscount:businessInfoDiscount];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redeem Discount" message:@"Are you at this business? You must be at this business to redeem this student discount." delegate:self cancelButtonTitle:@"No, cancel" otherButtonTitles:@"Yes, I'm here", nil];
        [alert setTag:kAlertTagAtBusiness];
        [alert show];
        self.discountToRetain = businessInfoDiscount;
    }
}

- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell commentsTappedForDiscount:(RTStudentDiscount *)discount
{
    [discount setStore:self.store];
    RTDiscountCommentModel *commentModel = [[RTDiscountCommentModel alloc] initWithStudentDiscount:discount];
    RTDiscountCommentViewController *commentViewController = [[RTDiscountCommentViewController alloc] initWithModel:commentModel];
    commentViewController.delegate = self;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell onShare:(RTStudentDiscount *)studentDiscount
{
    [studentDiscount setStore:self.store];
    self.shareViewController = [[RTShareViewController alloc]initWithDiscount:studentDiscount];
    [self addChildViewController:self.shareViewController];
    self.shareViewController.delegate = self;
    [self.shareViewController showShareViewFromView:self.view];
}

#pragma mark RTShareViewControllerDelegate
- (void)shareViewControllerDone {
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
            for (RTStudentDiscount *otherDiscounts in arrayDiscountsForStore) {
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
    }];
    [self.discountsTableView  reloadData];
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

#pragma mark - RedeemVC Delegate

- (void)redeemVCDidDone:(RedeemVC *)vc boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    //Update the navigation bar for bone count
    dispatch_async(dispatch_get_main_queue(), ^{
        if( boneCountChanged ) {
            [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
            
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

-(void)redeemVCDidCancel:(RedeemVC *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)redeemVC:(RedeemVC *)vc onChangeFollowing:(BOOL)isFollowing storeId:(int)storeId {
    [self setFollowButtonEnabled:isFollowing];
    [self.discountsTableView reloadData];
}

-(void)redeemVC:(RedeemVC *)vc onDiscountUnaccepted:(int)discountId boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    [vc dismissViewControllerAnimated:NO completion:nil];
    
    //Update the navigation bar for bone count
    dispatch_async(dispatch_get_main_queue(), ^{
        if( boneCountChanged ) {
            [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
            
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
        
        [SessionMgr transitionSystemStateRequest:SessionMgrState_Support];
        SupportVC *supportVC = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
        [supportVC setDiscount:vc.discount];
        [self.navigationController pushViewController:supportVC animated:YES];
        
        LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
        [leftNavVC.tableView reloadData];
    });
}

#pragma mark - Service

- (void)gotoRedeemViewWithStudentDiscount:(RTStudentDiscount *)studentDiscount {
    [studentDiscount setStore:self.store];
    RTRedeemDiscountModel *redeemModel = [[RTRedeemDiscountModel alloc] initWithDiscount:studentDiscount];
    RTRedeemDiscountViewController *redeemViewController = [[RTRedeemDiscountViewController alloc] initWithModel:redeemModel];
    [redeemViewController.view setFrame:self.view.frame];
    redeemViewController.delegate = self;
    [self.navigationController pushViewController:redeemViewController animated:YES];
}

#pragma mark - Segment action

- (IBAction)onSegmentChanged:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) {
        isDiscounts = YES;
        [self showDiscountsTableWithAnimated:YES];
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        isDiscounts = NO;
        [self showActivityTableWithAnimated:YES];
    }
    else {
        isDiscounts = NO;
        [self showContactTableWithAnimated:YES];
    }
}

#pragma mark RTActivityFeedCell

-(void)openFullScreenImage:(UIImage*)image {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(imageView.frame)/2 - 140, self.view.frame.size.width, 200)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.activityImageFullImageView = commentImageView;
    [self.activityImageFullImageView setClipsToBounds:YES];
    [self.activityImageFullView addSubview:self.activityImageFullImageView];
    [self.view addSubview:self.activityImageFullView];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissActivityImageFullViewButton = closeImageButton;
    [self.dismissActivityImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissActivityImageFullViewButton sizeToFit];
    [self.activityImageFullView addSubview:self.dismissActivityImageFullViewButton];
    [self.dismissActivityImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(void)openFullScreenImage:(UIImage*)image withComment:(NSString*)comment {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(imageView.frame)/2 - 140, self.view.frame.size.width, 200)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.activityImageFullImageView = commentImageView;
    [self.activityImageFullImageView setClipsToBounds:YES];
    [self.activityImageFullView addSubview:self.activityImageFullImageView];
    [self.view addSubview:self.activityImageFullView];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    [commentLabel setAlpha:1.0f];
    [commentLabel setText:comment];
    [commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    commentLabel.textColor = [UIColor whiteColor];
    commentLabel.numberOfLines = 0;
    commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [commentLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 16];
    [commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.activityImageFullImageView.frame) + 2, CGRectGetWidth(self.view.frame) - 16, CGRectGetHeight(commentLabel.frame))];
    [commentLabel sizeToFit];
    [self.activityImageFullView addSubview:commentLabel];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissActivityImageFullViewButton = closeImageButton;
    [self.dismissActivityImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissActivityImageFullViewButton sizeToFit];
    [self.activityImageFullView addSubview:self.dismissActivityImageFullViewButton];
    [self.dismissActivityImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(IBAction)closeImageView:(id)sender {
    if (self.activityImageFullView) {
        [self.activityImageFullView removeFromSuperview];
    }
}

- (void)imageTappedForImage:(UIImage *)image andComment:(NSString *)comment {
    if ([comment isEqualToString:@"(null)"] || [comment isEqualToString:@""]) {
        [self openFullScreenImage:image];
    } else {
        [self openFullScreenImage:image withComment:comment];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1 ) {
        switch(alertView.tag) {
            case INDEX_REDEEM:
            {
                if (arrayDiscountsForStore.count > 0 && indexOfExpandedCell >= 0 && indexOfExpandedCell < arrayDiscountsForStore.count) {
                    RTStudentDiscount *studentDiscount = arrayDiscountsForStore[indexOfExpandedCell];
                    [self gotoRedeemViewWithStudentDiscount:studentDiscount];
                }

                break;
            }
            case INDEX_NAVIGATE_TO_STORE:
            {
                RTStore *store = self.store;
                [self navigateToStore:store];
                break;
            }
            case INDEX_CALL_STORE:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLByFormattedPhoneNumberString:self.store.location.phone]];
                
                break;
            }
            case kAlertTagAtBusiness:
            {
                NSLog(@"%@", self.discountToRetain.store);
                [self gotoRedeemViewWithStudentDiscount:self.discountToRetain];
                break;
            }
        }
    } else if (buttonIndex == 0) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.store.storeId], @"storeId", nil];
        switch (alertView.tag) {
            case INDEX_REDEEM:
            {
                
            }
            case INDEX_NAVIGATE_TO_STORE:
            {
                [Flurry logEvent:@"user_navigate_to_store_failure" withParameters:params];
            }
            case INDEX_CALL_STORE:
            {
                [Flurry logEvent:@"user_call_store_failure" withParameters:params];
            }
            case kAlertTagAtBusiness:
            {
                
            }
        }
    }
}

- (IBAction)onFollowButton:(id)sender {
    [self.followButton setEnabled:NO];
    NSString *storeId = [NSString stringWithFormat:@"%d", self.store.storeId];
    [[RTServerManager sharedInstance] followStore:storeId isEnabling:![self.store.user.following boolValue] complete:^(BOOL success, RTAPIResponse *response){
        if( success ) {
            BOOL bState = ![self.store.user.following boolValue];
            self.store.user.following = [NSNumber numberWithBool:bState];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( self.delegate != nil ) {
                    [self.delegate businessInfoVC:self onChangeFollowing:bState];
                }
                
                [self setFollowButtonEnabled:bState];
            });
        }
        else {
            //
        }
        [self.followButton setEnabled:YES];
    }];
}

- (IBAction)datePickerDoneButtonClicked:(id)sender {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self.datePicker.date forKey:@"birthday"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BirthdaySetNotification" object:self userInfo:userInfo];
    
    [self hideDatePickerViewWithAnimated:YES];
    [self.discountsTableView reloadData];
}

#pragma mark - Follow Button manipulation

- (void)setFollowButtonEnabled:(BOOL)isEnable {
    if( isEnable ) {
        [self.followButton setTitle:@" Following" forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@"check_icon"] forState:UIControlStateNormal];
    }
    else {
        [self.followButton setTitle:@"Follow for updates" forState:UIControlStateNormal];
        [self.followButton setImage:nil forState:UIControlStateNormal];
    }
}

#pragma private
- (void)navigateToStore:(RTStore *)store {
    Class mapItemClass = [MKMapItem class];
    
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(store.latitude, store.longitude);
        MKPlacemark* storePlaceMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: storePlaceMark ];
        [destination setName:store.name];
        MKMapItem *userLocation = [MKMapItem mapItemForCurrentLocation];
        NSArray *mapItems = @[userLocation, destination];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", store.storeId], @"storeId", nil];
        [Flurry logEvent:@"user_navigate_to_store" withParameters:params];
        [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
    }
}

#pragma mark - Redeem view controller delegate

- (void)boneAndBadgeCountChangedWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( boneCountChanged ) {
            [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
            
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
    [self setFollowButtonEnabled:isFollowing];
    [self.discountsTableView reloadData];
    
    if( self.delegate != nil ) {
        [self.delegate businessInfoVC:self onChangeFollowing:isFollowing];
    }
}

#pragma mark - CLLocation methods for distance to store

- (NSString *) retrieveDistanceToStore:(RTStore *)store {
    CLLocation *locCurrent = [[CLLocation alloc] initWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude];
    
    CLLocation *locStore = [[CLLocation alloc] initWithLatitude:self.store.latitude longitude:self.store.longitude];
    CLLocationDistance distanceMeters = [locCurrent distanceFromLocation:locStore];
    CLLocationDistance distanceMiles = distanceMeters / 1609.344;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:1];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    
    NSString *distanceString = [NSString stringWithFormat:@"%@ miles", [formatter stringFromNumber:[NSNumber numberWithDouble:distanceMiles]]];
    return distanceString;
}

- (void)showStudentIdImage:(UIImage *)studentIdImage {
    
}

- (void)neverMindButtonTapped {
    
}

- (void)dismissWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    
}

- (void)cancelButtonTapped {
    
}

- (void)bluetoothOff {
    
}

- (void)discountCommentViewController:(RTDiscountCommentViewController *)viewController onUpdateDiscountComments:(int)incrementalComment {
    
}

@end
