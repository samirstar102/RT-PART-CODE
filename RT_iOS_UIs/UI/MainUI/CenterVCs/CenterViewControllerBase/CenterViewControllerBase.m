#import "CenterViewControllerBase.h"
#import "LeftNavViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "UINavigationItem+Additions.h"
#import "RTUserContext.h"
#import "SessionMgr.h"
#import "BonesAndBadgesVC.h"
#import "RTStoryboardManager.h"

#define kTagBoneButton  (10000)
#define kTagBadgeButton (10001)

@interface CenterViewControllerBase ()

@end

@implementation CenterViewControllerBase


- (void)viewDidLoad {
    [self setUpNavBar];
    
    [super viewDidLoad];
}

- (void)initViews{
    self.view.backgroundColor = [UIColor roverTownColor6DA6CE];
}

- (void)initEvents{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)setUpNavBar {
    self.navigationController.navigationBarHidden = NO;
    
    //Setup left navigation bar item
    UIButton *btnHamb = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHamb setFrame:CGRectMake(0.0f, 0.0f, 16.0f, 13.0f)];
    [btnHamb setImage:[UIImage imageNamed:@"menu_bars.png"] forState:UIControlStateNormal];
    [btnHamb addTarget:self action:@selector(leftNavAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *hamburgerBtn = [[UIBarButtonItem alloc] initWithCustomView:btnHamb];
    [self.navigationItem addLeftBarButtonItem:hamburgerBtn];
    
    //Setup right navigation bar item
    UIView *vwRightNavBarItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 51.0f, 26.0f)];
    
    UIButton *btnBone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBone setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 20.0f)];
    [btnBone setBackgroundColor:[UIColor whiteColor]];
    [btnBone.layer setCornerRadius:kCornerRadiusDefault];
    [btnBone setImage:[UIImage imageNamed:@"bone_counter_icon"] forState:UIControlStateNormal];
    [btnBone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBone.titleLabel setFont:REGFONT14];
    [btnBone setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5.0f)];
    [btnBone setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].boneCount] forState:UIControlStateNormal];
    [btnBone addTarget:self action:@selector(onBoneCountButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnBone setTag:kTagBoneButton];
    [vwRightNavBarItem addSubview:btnBone];
    
    int numberOfUnreadBadges = [RTUserContext sharedInstance].badgeTotalCount - [RTUserContext sharedInstance].badgeReadCount;
    
    //Check if there is badges unread and add notification bubble to rigth navigation bar item
    UIButton *btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBadge setFrame:CGRectMake(37.0f, 12.0f, 12.0f, 12.0f)];
    [btnBadge setBackgroundColor:[UIColor colorWithRed:0 green:158.0f/255.0f blue:74.0f/255.0f alpha:1.0f]];
    [btnBadge.layer setBorderWidth:1.0f];
    [btnBadge.layer setBorderColor:[UIColor whiteColor].CGColor];
    [btnBadge.layer setCornerRadius:6.0f];
    [btnBadge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBadge setTitle:[NSString stringWithFormat:@"%d", numberOfUnreadBadges] forState:UIControlStateNormal];
    [btnBadge.titleLabel setFont:BOLDFONT12];
    [btnBadge setUserInteractionEnabled:NO];
    [btnBadge setTag:kTagBadgeButton];
    //Hides badge button if there is no unread badges
    if (numberOfUnreadBadges <= 0 )
        [btnBadge setAlpha:0.0f];
    else
        [btnBadge setAlpha:1.0f];
    [vwRightNavBarItem addSubview:btnBadge];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:vwRightNavBarItem];
    
    [self.navigationItem addRightBarButtonItem:rightBarButtonItem];
}

-(void)setUpBackableNavBar {
    self.navigationController.navigationBarHidden = NO;
    
    //Setup left navigation bar item
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0.0f, 0.0f, 16.0f, 13.0f)];
    [btnBack setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backNavAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [self.navigationItem addLeftBarButtonItem:backButtonItem];
    
    //Setup right navigation bar item
    UIView *vwRightNavBarItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 51.0f, 26.0f)];
    
    UIButton *btnBone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBone setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 20.0f)];
    [btnBone setBackgroundColor:[UIColor whiteColor]];
    [btnBone.layer setCornerRadius:kCornerRadiusDefault];
    [btnBone setImage:[UIImage imageNamed:@"bone_counter_icon"] forState:UIControlStateNormal];
    [btnBone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBone.titleLabel setFont:REGFONT14];
    [btnBone setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5.0f)];
    [btnBone setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].boneCount] forState:UIControlStateNormal];
    [btnBone addTarget:self action:@selector(onBoneCountButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnBone setTag:kTagBoneButton];
    [vwRightNavBarItem addSubview:btnBone];
    
    int numberOfUnreadBadges = [RTUserContext sharedInstance].badgeTotalCount - [RTUserContext sharedInstance].badgeReadCount;
    
    //Check if there is badges unread and add notification bubble to rigth navigation bar item
    UIButton *btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBadge setFrame:CGRectMake(37.0f, 12.0f, 12.0f, 12.0f)];
    [btnBadge setBackgroundColor:[UIColor colorWithRed:0 green:158.0f/255.0f blue:74.0f/255.0f alpha:1.0f]];
    [btnBadge.layer setBorderWidth:1.0f];
    [btnBadge.layer setBorderColor:[UIColor whiteColor].CGColor];
    [btnBadge.layer setCornerRadius:6.0f];
    [btnBadge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBadge setTitle:[NSString stringWithFormat:@"%d", numberOfUnreadBadges] forState:UIControlStateNormal];
    [btnBadge.titleLabel setFont:BOLDFONT12];
    [btnBadge setUserInteractionEnabled:NO];
    [btnBadge setTag:kTagBadgeButton];
    //Hides badge button if there is no unread badges
    if (numberOfUnreadBadges <= 0 )
        [btnBadge setAlpha:0.0f];
    else
        [btnBadge setAlpha:1.0f];
    [vwRightNavBarItem addSubview:btnBadge];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:vwRightNavBarItem];
    
    [self.navigationItem addRightBarButtonItem:rightBarButtonItem];
    
    //Disable side menu swiping
    self.mm_drawerController.shouldUsePanGesture = NO;
}

-(void)setUpNavBarWithoutBones {
    self.navigationController.navigationBarHidden = NO;
    
    //Setup left navigation bar item
    UIButton *btnHamb = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHamb setFrame:CGRectMake(0.0f, 0.0f, 16.0f, 13.0f)];
    [btnHamb setImage:[UIImage imageNamed:@"menu_bars.png"] forState:UIControlStateNormal];
    [btnHamb addTarget:self action:@selector(leftNavAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *hamburgerBtn = [[UIBarButtonItem alloc] initWithCustomView:btnHamb];
    [self.navigationItem addLeftBarButtonItem:hamburgerBtn];
    
    [self.navigationItem setRightBarButtonItems:nil];
}

-(void)setNumberOfBonesWithNumber:(int)numberOfBones {
    float delayBeforeBoneCountSetup = 0.5f;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:numberOfBones], @"bone_count", nil];
    
    [self performSelector:@selector(updateBoneCount:) withObject:params afterDelay:delayBeforeBoneCountSetup];
}

-(void)setNumberOfBadgesWithNumber:(int)numberOfBadges {
    float delayBeforeBoneCountSetup = 0.5f;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:numberOfBadges], @"badge_count", nil];
    
    [self performSelector:@selector(updateBadgeCount:) withObject:params afterDelay:delayBeforeBoneCountSetup];
}

-(void)updateBoneCount:(NSDictionary *)params {
    int bone_count = [[params objectForKey:@"bone_count"] intValue];
    //Setup right navigation bar item
    NSMutableArray *rightBarButtonItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    for( int i = 0; i < rightBarButtonItems.count; i++ ) {
        UIBarItem *barItem = rightBarButtonItems[i];
        
        UIView *view = (UIView *)[barItem valueForKey:@"view"];
        if( view == nil )
            continue;
        for( int j = 0; j < view.subviews.count; j++ ) {
            UIButton *button = (UIButton *)[view.subviews objectAtIndex:j];
            
            if( button != nil && button.tag == kTagBoneButton ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        [button setTitle:[NSString stringWithFormat:@"%d", bone_count] forState:UIControlStateNormal];
                });
            }
        }
    }
}

-(void)updateBadgeCount:(NSDictionary *)params {
    int badge_count = [[params objectForKey:@"badge_count"] intValue];
    int numberOfUnreadBadges = badge_count - [RTUserContext sharedInstance].badgeReadCount;
    
    if( numberOfUnreadBadges <= 0 ) {
        return;
    }
    
    //Setup right navigation bar item
    NSMutableArray *rightBarButtonItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
    
    for( int i = 0; i < rightBarButtonItems.count; i++ ) {
        UIBarItem *barItem = rightBarButtonItems[i];
        
        UIView *view = (UIView *)[barItem valueForKey:@"view"];
        if( view == nil )
            continue;
        for( int j = 0; j < view.subviews.count; j++ ) {
            UIButton *button = (UIButton *)[view.subviews objectAtIndex:j];
            
            if( button != nil && button.tag == kTagBadgeButton ) {
                [button setTitle:[NSString stringWithFormat:@"%d", numberOfUnreadBadges] forState:UIControlStateNormal];
                [button setAlpha:1.0f];
            }
        }
    }
}

-(void)leftNavAction {
    [self dismissKeyboard];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft
                                      animated:YES
                                    completion:nil];
}

-(void)backNavAction {
    //Disable side menu swiping
    self.mm_drawerController.shouldUsePanGesture = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(IBAction)onBoneCountButton:(id)sender {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_BonesAndBadges];
    BonesAndBadgesVC *vc = (BonesAndBadgesVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBonesAndBadgesVC storyboardName:kStoryboardBonesAndBadges];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
    [leftNavVC.tableView reloadData];
}

@end
