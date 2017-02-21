#import <MessageUI/MessageUI.h>

#import "LeftNavViewController.h"
#import "LeftNavHeaderView.h"
#import "LeftNavCell.h"
#import "UIColor+Config.h"

#import "UIViewController+MMDrawerController.h"
#import "AppDelegate.h"
#import "SessionMgr.h"
#import "RTStoryboardManager.h"
#import "ProfileVC.h"
#import "BonesAndBadgesVC.h"
#import "DollarsForDownloadsVC.h"
#import "FollowerRewardsVC.h"
#import "SubmitDiscountVC.h"
#import "SupportVC.h"
#import "FollowingVC.h"
#import "FollowingUpdatesVC.h"

#import "RTUIManager.h"
#import "RTShareViewController.h"

#define HEADER_HEIGHT   37.5f


@interface LeftNavViewController ()<RTShareViewControllerDelegate>

@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) LeftNavHeaderView *headerView;
@property (nonatomic) int     messageCount;
@property (nonatomic)   UIButton *shareAppButton;
@property (nonatomic) RTShareViewController *shareViewController;
@end

@implementation LeftNavViewController

@synthesize tableView;

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.view.backgroundColor = [UIColor roverTownColorDarkBlue];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setBackgroundColor:[UIColor clearColor]];

}

- (void)viewDidLayoutSubviews {
    self.headerView = [[LeftNavHeaderView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          self.view.frame.size.width,
                                                                          [LeftNavHeaderView getPreferredHeightForWidth])];
    [self.headerView.btnEditProfile addTarget:self action:@selector(onPressProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableHeaderView = self.headerView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];  

    [self positonComponents];
    [self layoutShareButton];
}

- (void)layoutShareButton {
    if (!self.shareAppButton) {
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = CGRectGetHeight(tableFrame) - 75;
        [self.tableView setFrame:tableFrame];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.tableView.frame), CGRectGetWidth(self.tableView.frame), 75.0f)];
        [self.view addSubview:view];
        
        self.shareAppButton = [[UIButton alloc]init];
        [self.shareAppButton setFrame:CGRectMake(15, 15, CGRectGetWidth(view.frame) - 30 , CGRectGetHeight(view.frame) - 30)];
        self.shareAppButton.layer.cornerRadius = 3.0;
        self.shareAppButton.clipsToBounds = YES;
        [self.shareAppButton setBackgroundColor:[UIColor whiteColor]];
        [self.shareAppButton setTitle:@"Share This App" forState:UIControlStateNormal];
        [self.shareAppButton.titleLabel setFont:REGFONT15];
        [self.shareAppButton setTitleColor:[UIColor roverTownColorDarkBlue] forState:UIControlStateNormal];
        [self.shareAppButton addTarget:self action:@selector(shareAppButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
        [view addSubview:self.shareAppButton];
    }
}
-(void)positonComponents
{
    self.tableView.frame = CGRectMake(0,
                                      self.view.bounds.origin.y,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height);
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    view.backgroundColor = [UIColor roverTownColorDarkBlue];
    return view;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LeftNavCell";
    
    LeftNavCell *cell = (LeftNavCell *)[tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[LeftNavCell alloc] initWithReuseIdentifier:CellIdentifier];

    switch (indexPath.row)
    {
        case 0:
            [cell configureCell:NSLocalizedString(@"Student Discounts", nil) image:[UIImage imageNamed:@"cap_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_StudentDiscounts)? 1.0f : 0.6f];
            break;
            
        case 1:
            [cell configureCell:NSLocalizedString(@"Activity Feed", nil) image:[UIImage imageNamed:@"activity_feed"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Notifications)? 1.0f : 0.6f];
            break;
            
//        case 2:
//            [cell configureCell:NSLocalizedString(@"Following", nil) image:[UIImage imageNamed:@"following_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Following)? 1.0f : 0.6f];
//            break;
            
        case 2:
            [cell configureCell:NSLocalizedString(@"Profile", nil) image:[UIImage imageNamed:@"profile_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Profile)? 1.0f : 0.6f];
            break;
            
        case 3:
            [cell configureCell:NSLocalizedString(@"Bones & Badges", nil) image:[UIImage imageNamed:@"discounts_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_BonesAndBadges)? 1.0f : 0.6f];
            break;
            
        case 4:
            [cell configureCell:NSLocalizedString(@"Dollars for Downloads", nil) image:[UIImage imageNamed:@"dollar_icon_1"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_DollarsForDownloads)? 1.0f : 0.6f];
            break;
            
//        case 6:
//            [cell configureCell:NSLocalizedString(@"Follower Rewards", nil) image:[UIImage imageNamed:@"star_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_FollowerRewards)? 1.0f : 0.6f];
//            break;
            
//        case 6:
//            [cell configureCell:NSLocalizedString(@"Notifications", nil) image:[UIImage imageNamed:@"notifications_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Notifications)? 1.0f : 0.6f];
//            break;
            
        case 5:
            [cell configureCell:NSLocalizedString(@"Submit a Discount", nil) image:[UIImage imageNamed:@"submit_discount_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_SubmitDiscount)? 1.0f : 0.6f];
            break;
            
        case 6:
            [cell configureCell:NSLocalizedString(@"Support", nil) image:[UIImage imageNamed:@"support_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Support)? 1.0f : 0.6f];
            break;
            
//        case 8:
//            [cell configureCell:NSLocalizedString(@"Feedback", nil) image:[UIImage imageNamed:@"feedback_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_Feedback)? 1.0f : 0.6f];
//            break;
            
//        case 8:
//            [cell configureCell:NSLocalizedString(@"About This App", nil) image:[UIImage imageNamed:@"about_icon"] whiteOpacity:([SessionMgr getSystemState] == SessionMgrState_About)? 1.0f : 0.6f];
//            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];

//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (indexPath.row)
    {
        case 0: //Student Discounts
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
            FollowingUpdatesVC *vc = [[FollowingUpdatesVC alloc]init];
            [vc showPage:RTFollowingViewControllerpage_DiscountPage];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.mm_drawerController setCenterViewController: navController
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
        case 1: //ActivityFeed
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_Notifications];
            FollowingUpdatesVC *vc = [[FollowingUpdatesVC alloc]init];
            [vc showPage:RTFollowingViewControllerpage_ActivityPage];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.mm_drawerController setCenterViewController:navController
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
//        case 2: //Following
//        {
//            [SessionMgr transitionSystemStateRequest:SessionMgrState_Following];
//            FollowingVC *vc = (FollowingVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowingVC storyboardName:kStoryboardFollowing];
//            
//            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
//                                       withFullCloseAnimation:YES
//                                                   completion:nil];
//            break;
//        }
        case 2: //Profile
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_Profile];
            ProfileVC *vc = (ProfileVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIProfileVC storyboardName:kStoryboardProfile];
            
            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
        case 3: //Bones & Badges
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_BonesAndBadges];
            BonesAndBadgesVC *vc = (BonesAndBadgesVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBonesAndBadgesVC storyboardName:kStoryboardBonesAndBadges];
            
            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
        case 4: //Dollars for Downloads
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_DollarsForDownloads];
            DollarsForDownloadsVC *vc = (DollarsForDownloadsVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIDollarsForDownloadsVC storyboardName:kStoryboardDollarsForDownloads];
            
            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
//        case 6: //Follower Rewards
//        {
//            [SessionMgr transitionSystemStateRequest:SessionMgrState_FollowerRewards];
//            FollowerRewardsVC *vc = (FollowerRewardsVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowerRewardsVC storyboardName:kStoryboardFollowerRewards];
//            
//            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
//                                       withFullCloseAnimation:YES
//                                                   completion:nil];
//            break;
//        }
//        case 6: //Notifications
//        {
//            [SessionMgr transitionSystemStateRequest:SessionMgrState_Notifications];
//            NotificationsVC *vc = (NotificationsVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSINotificationsVC storyboardName:kStoryboardNotifications];
//            
//            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
//                                       withFullCloseAnimation:YES
//                                                   completion:nil];
//            break;
//        }
        case 5: //Submit a Discount
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_SubmitDiscount];
            FollowingUpdatesVC *vc = [[FollowingUpdatesVC alloc]init];
            [vc showPage:RTFollowingViewControllerpage_SubmitPage];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.mm_drawerController setCenterViewController:navController
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
        case 6: //Suppport
        {
            [SessionMgr transitionSystemStateRequest:SessionMgrState_Support];
            SupportVC *vc = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
            [vc setDiscount:[[RTStudentDiscount alloc]init]];
            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc]
                                       withFullCloseAnimation:YES
                                                   completion:nil];
            break;
        }
//        case 8: //Feedback
//        {
//            [SessionMgr transitionSystemStateRequest:SessionMgrState_Feedback];
//            [BITHockeyManager sharedHockeyManager].feedbackManager.requireUserEmail = BITFeedbackUserDataElementRequired;
//            [BITHockeyManager sharedHockeyManager].feedbackManager.requireUserName = BITFeedbackUserDataElementRequired;
//            [[BITHockeyManager sharedHockeyManager].feedbackManager showFeedbackComposeView];
//            break;
//        }
//        case 8: //About This App
//        {
//            [SessionMgr transitionSystemStateRequest:SessionMgrState_About];
//            AboutVC *vc = (AboutVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIAboutVC storyboardName:kStoryboardAbout];
//            
//            [self.mm_drawerController setCenterViewController:[[UINavigationController alloc]initWithRootViewController:vc] withFullCloseAnimation:YES completion:nil];
//            break;
//        }
        default:
            break;
    }
    [aTableView reloadData];
}

- (IBAction)onPressProfile:(id)sender {
    
}

- (void)shareAppButtonPressed {
    if (!self.shareViewController) {
        self.shareViewController = [[RTShareViewController alloc]initWithShareType:RTShareType_Application];
    }
    [self addChildViewController:self.shareViewController];
    [self.shareViewController showShareViewFromView:self.view];
}

#pragma mark RTShareViewControllerDelegate

- (void)shareViewControllerDone {
    [self.shareViewController removeFromParentViewController];
}

@end
