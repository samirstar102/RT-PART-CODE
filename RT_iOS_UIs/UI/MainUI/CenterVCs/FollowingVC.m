//
//  FollowingVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "FollowingVC.h"
#import "RTStoryboardManager.h"
#import "FollowingFollowingVC.h"
#import "FollowingSettingsVC.h"
#import "SessionMgr.h"
#import "BusinessInfoVC.h"

#define kPageIndexFollowingVC   (0)
#define kPageIndexSettingsVC    (1)

@interface FollowingVC ()
{
    FollowingFollowingVC *followingVC;
    FollowingSettingsVC *settingsVC;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segNavigation;

@end

@implementation FollowingVC

@synthesize  vwContent;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initViews {
    [super initViews];
    
    if( followingVC == nil ) {
        followingVC = (FollowingFollowingVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowingFollowingVC storyboardName:kStoryboardFollowing];
        [followingVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:followingVC.view];
        [self addChildViewController:followingVC];
    }
    
    if( settingsVC == nil ) {
        settingsVC = (FollowingSettingsVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowingSettingsVC storyboardName:kStoryboardFollowing];
        [settingsVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:settingsVC.view];
        [self addChildViewController:settingsVC];
    }
    
    [self showPageAtIndex:kPageIndexFollowingVC animated:NO];
}

- (void)initEvents {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
    @brief  It shows a page among FollowingVC, UpdatesVC and SettingsVC with its index

    @param  index       The index of the view controller
    @param  animated    Flag indicating whether should be animated while appearing
 */
- (void)showPageAtIndex : (NSUInteger)index animated:(BOOL)animated {
    UIViewController *vc;
    switch( index ) {
        case kPageIndexFollowingVC:
            vc = followingVC;
            break;
        case kPageIndexSettingsVC:
            vc = settingsVC;
            break;
    }
    
    float duration = 0.0f;
    if( animated )
        duration = kAnimationDurationDefault;
    
    [UIView animateWithDuration:duration animations:^{
        //Hides all child view controllers before appearance
        followingVC.view.alpha = 0.0f;
        settingsVC.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            //Shows the child view controller at index
            vc.view.alpha = 1.0f;
        }];
    }];
}



/*!
 @brief     Move to Business Info view controller with store info
 
 @param     store       Store which should be shown
 @param     animated    Flag indicates whether to be animated
 */
- (void)bringupBusinessInfoControllerWithStore:(RTStore*)store animated:(BOOL)animated {
    // show business info
    [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.store = store;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Actions

- (IBAction)onNavigationSegmentValueChanged:(id)sender {
    [self.view endEditing:YES];
    
    NSUInteger nSelectedSegmentIndex = [self.segNavigation selectedSegmentIndex];
    
    [self showPageAtIndex:nSelectedSegmentIndex animated:YES];
}

@end
