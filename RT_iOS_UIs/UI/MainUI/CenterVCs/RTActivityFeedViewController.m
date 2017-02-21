//
//  RTActivityFeedViewController.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivityFeedViewController.h"
#import "RTActivityFeedView.h"
#import "RTActivityFeedModel.h"
#import "RTActivityFeedCell.h"
#import "RTActivity.h"
#import "BusinessInfoVC.h"
#import "RTStudentDiscount.h"
#import "RTStoryboardManager.h"
#import "RTConstants.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "UIColor+Config.h"
#import "RTUIManager.h"
#import "RTPublicProfileViewController.h"
#import "RTActivityNoFeedView.h"
#import "RTDiscountCommentViewController.h"
#import "RTDiscountCommentModel.h"
#import "Flurry.h"

#define kNoFeedSpacerForView 8
#define kNoFeedHeight 100
#define kActivityCellReuseIdentifier  @"activityFeedCell"

@interface RTActivityFeedViewController ()<UITableViewDataSource, UITableViewDelegate, RTActivityFeedModelDelegate, RTActivityFeedCellDelegate, BusinessInfoVCDelegate, RTDiscountCommentViewControllerDelegate>

@property (nonatomic)RTActivityFeedModel *activityFeedModel;
@property (nonatomic, strong)NSArray *activities;
@property (nonatomic) RTStudentDiscount *discountForSegue;
@property (nonatomic) UIView *commentImageFullView;
@property (nonatomic) UIImageView *commentImageFullImageView;
@property (nonatomic) UIButton *dismissCommentImageFullViewButton;
@property (nonatomic) BOOL isShowingProgressIndicator;
@property (nonatomic) BOOL atBottomOfActivityList;
@property (nonatomic) UIImageView *spinnerView;
@property (nonatomic) RTActivityNoFeedView *noFeedView;
@property (nonatomic) NSString *titleForNoFeed;
@property (nonatomic) NSString *messageForFeed;
@end

@implementation RTActivityFeedViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        _activityFeedModel  = [[RTActivityFeedModel alloc]initWithDelegate:self];
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        [_tableView setBackgroundColor:[UIColor clearColor]];
        self.navigationController.title = @"Activities";
        [Flurry logEvent:@"uer_activity_view"];
        self.titleForNoFeed = @"There is no activity yet.";
        self.messageForFeed = @"Be the first RoverTown user in your area!";
    }
    return self;
}

-(instancetype)initWithUserId:(int)userId {
    self = [self init];
    self.titleForNoFeed = @"This user has no activity yet.";
    self.messageForFeed = @"Please try again later.";
    self.activityFeedModel.userId = userId;
    return self;
}

-(instancetype)initWithStoreId:(NSString*)storeId {
    self = [self init];
    self.titleForNoFeed = @"There's no activity for this business yet.";
    self.messageForFeed = @"Be the first RoverTown customer!";
    [self.activityFeedModel setStoreId:storeId];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_tableView];
    [self.tableView setFrame:self.view.frame];
    //[_tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150)];
    [self loadActivities];
    if (self.activities.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void) loadActivities {
    [self showSpinner];
    [self.activityFeedModel getActivities];
}

- (void) showSpinner {
    [[RTUIManager sharedInstance] showToastMessageWithView:self.tableView labelText:@"Loading activities" descriptionText:nil];
}

- (void)hideSpinner {
   
}

- (void)showNoActivityViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if (animated) {
        duration = 0.2f;
    }
    
    if (!self.noFeedView) {
        self.noFeedView = [[RTActivityNoFeedView alloc] initWithFrame:CGRectMake(kNoFeedSpacerForView/2, kNoFeedSpacerForView/2, self.view.frame.size.width - 2*kNoFeedSpacerForView, kNoFeedHeight) title:self.titleForNoFeed andMessage:self.messageForFeed];
        [self.noFeedView setAlpha:0.0f];
        [self.view addSubview:self.noFeedView];
        [UIView animateWithDuration:duration animations:^{
            [self.tableView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                [self.noFeedView setAlpha:1.0f];
            }];
        }];
    } else {
        [self.noFeedView setAlpha:0.0f];
        [self.view addSubview:self.noFeedView];
        [UIView animateWithDuration:duration animations:^{
            [self.tableView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                [self.noFeedView setAlpha:1.0f];
            }];
        }];
    }
}

#pragma mark -  delegate
- (void)activityCell:(RTActivityFeedCell *)cell onDiscountTappedWithId:(NSInteger)discountId andStoreId:(NSInteger)storeId {
    [[RTUIManager sharedInstance] showPageLoadingSpinnerWithView:self.tableView];
    [self.activityFeedModel retrieveDiscountWithDiscountId:discountId andStoreId:storeId];
}

- (void)discountRetrieved:(RTStudentDiscount *)discount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RTUIManager sharedInstance] hidePageLoadingSpinner];
        RTDiscountCommentModel *commentModel = [[RTDiscountCommentModel alloc] initWithStudentDiscount:discount];
        RTDiscountCommentViewController *commentVC = [[RTDiscountCommentViewController alloc] initWithModel:commentModel];
        commentVC.delegate = self;
        [self.navigationController pushViewController:commentVC animated:YES];
    });
}

- (void)activityCell:(RTActivityFeedCell *)cell onUserTappedWithUserId:(int)userId {
    if (self.delegate != nil) {
        [self.delegate userIdTappedForUserId:userId];
    } else {
        [self goToPublicUserProfileForUserId:userId];
    }
}

- (void)goToPublicUserProfileForUserId:(int)userId {
    RTPublicProfileViewController *publicViewController = [[RTPublicProfileViewController alloc] initWithUserId:userId];
    [self.navigationController pushViewController:publicViewController animated:YES];
}

- (void)activityCell:(RTActivityFeedCell *)cell onViewBusinessWithID:(NSInteger)storeID {
    [[RTUIManager sharedInstance] showPageLoadingSpinnerWithView:self.tableView];
    [self.activityFeedModel getStoreById:storeID ];
}

- (void)storeRetrieved:(RTStore *)store {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RTUIManager sharedInstance] hidePageLoadingSpinner];
        BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
        vc.store = store;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - RTActivityFeedModelDelegate
- (void)activitiesFailed {
    [[RTUIManager sharedInstance] hidePageLoadingSpinner];
    [[RTUIManager sharedInstance] showToastMessageWithView:self.view labelText:nil descriptionText:@"There was a problem loading activities!"];
}

- (void)activitiesSucess:(NSArray *)activities {
    if (self.noFeedView) {
        [self.noFeedView setAlpha:0.0f];
        [self.noFeedView removeFromSuperview];
        self.noFeedView = nil;
    }
    
    if (!activities || activities.count == 0) {
        [self hideSpinner];
        [self hideTableViewProgressIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoActivityViewWithAnimated:YES];
        });
        [self showNoActivityViewWithAnimated:YES];
        [self.tableView reloadData];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RTUIManager sharedInstance] hidePageLoadingSpinner];
            _activities = [NSArray arrayWithArray:activities];
            [self hideTableViewProgressIndicator];
            [self hideSpinner];
            [self.tableView reloadData];
        });
    }
}

- (void)imageTappedForImage:(UIImage *)image andComment:(NSString *)comment {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
    self.commentImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat scaleFactor = self.view.frame.size.width / imageWidth;
    CGFloat newImageHeight = imageHeight * scaleFactor;
    if (newImageHeight / (self.view.frame.size.height) >= 0.75) {
        newImageHeight = 0.75 * newImageHeight;
    }
    
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(self.commentImageFullView.frame)/2 - newImageHeight/2, self.view.frame.size.width, newImageHeight)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.commentImageFullImageView = commentImageView;
    [self.commentImageFullImageView setClipsToBounds:YES];
    [self.commentImageFullView addSubview:commentImageView];
    [self.navigationController.view addSubview:self.commentImageFullView];
    
    if (![comment isEqualToString:@""] && ![comment isEqualToString:@"(null)"]) {
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
    }
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissCommentImageFullViewButton = closeImageButton;
    [self.dismissCommentImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissCommentImageFullViewButton sizeToFit];
    [self.commentImageFullView addSubview:self.dismissCommentImageFullViewButton];
    [self.dismissCommentImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.navigationController.view.frame) - 80, 80, 40)];
}

-(IBAction)closeImageView:(id)sender {
    if (self.commentImageFullView ) {
        [self.commentImageFullView removeFromSuperview];
    }
}

- (void)openFullScreenImage:(UIImage *)image withComment:(NSString*)comment {
    
}

#pragma mark - UITableViewDelegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RTActivity *activity = nil;
    if (_activities.count) {
        activity = [_activities objectAtIndex:indexPath.row];
    }
    BOOL imageExists = ![activity.imageString isEqualToString:@""];
    return [RTActivityFeedCell heightForCellActivity:activity andView:self.view withImage:imageExists];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RTActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivityCellReuseIdentifier];
    if (cell == nil) {
        cell = [[RTActivityFeedCell alloc] initWithActivity:self.activityFeedModel.activitiesArray[indexPath.row]];
    }
    cell.delegate = self;
    [cell setActivity:self.activities[indexPath.row]];
    [cell setSelected:NO];
    NSLog(@"The cell is %@",cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.activityFeedModel.doneGettingActivities) {
        if (indexPath.row == self.activityFeedModel.activitiesArray.count - 3 ) {
            [self.activityFeedModel getActivities];
            [self showTableViewProgressIndicatorIsInitial:NO];
        }
    }
}

- (void)businessInfoVC:(BusinessInfoVC *)vc onChangeFollowing:(BOOL)isFollowing {
    // this does nothing
}

-(void)showTableViewProgressIndicatorIsInitial:(BOOL)isInitial {
    NSInteger visibleCellMin;
    visibleCellMin = self.activities.count;
    if (self.tableView.visibleCells.count >= visibleCellMin || isInitial) {
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
        
        self.tableView.tableFooterView = footerView;
    }
}

-(void)hideTableViewProgressIndicator {
    self.isShowingProgressIndicator = NO;
    self.tableView.tableFooterView = nil;
}

- (void)discountCommentViewController:(RTDiscountCommentViewController *)viewController onChangeFollowing:(BOOL)isFollowing {
    
}

- (void)activityCell:(RTActivityFeedCell *)cell onCommentTapped:(RTStudentDiscount *)discount {
    
}

- (void)discountCommentViewController:(RTDiscountCommentViewController *)viewController onUpdateDiscountComments:(int)incrementalComment {
    
}

@end
