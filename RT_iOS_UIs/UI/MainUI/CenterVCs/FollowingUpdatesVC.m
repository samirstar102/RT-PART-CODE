//
//  FollowingUpdatesVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "FollowingUpdatesVC.h"
#import "FollowingUpdatesCell.h"
#import "RTModelBridge.h"
#import "RTUIManager.h"
#import "BusinessInfoVC.h"
#import "RTStoryboardManager.h"
#import "SessionMgr.h"
#import "RTActivityFeedModel.h"
#import "RTActivityFeedView.h"
#import "RTBottomToolbarViewController.h"
#import "FollowingFollowingVC.h"
#import "FollowingSettingsVC.h"
#import "StudentDiscountsViewController.h"
#import "RTSubmitViewController.h"
#import "RTActivityFeedViewController.h"
#import "RTUserContext.h"
#import "RTServerManager.h"
#import "RTUser.h"

@interface FollowingUpdatesVC () <RTBottomToolbarViewControllerDelegate, RTActivityFeedViewDelegate, StudentDiscountViewControllerDelegate, RTSubmitViewControllerDelegate>
{
    NSMutableArray *arrayNotifications;
}

@property (nonatomic) RTBottomToolbarViewController *bottomToolbarViewController;
@property (nonatomic) RTActivityFeedView *activityFeedView;
@property (nonatomic) RTFollowingViewControllerpage activePage;
@property (nonatomic) FollowingFollowingVC *followingViewController;
@property (nonatomic) FollowingSettingsVC *settingsViewController;
@property (nonatomic) StudentDiscountsViewController *studentDiscountViewController;
@property (nonatomic) RTSubmitViewController *submitViewController;
@property (nonatomic) RTActivityFeedViewController *activityFeedViewController;
@property (nonatomic) RTUser *currentUserObject;
@end

@implementation FollowingUpdatesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityFeedView = [[RTActivityFeedView alloc]initWithFrame:self.view.frame delegate:self];
    [self.view addSubview:_activityFeedView];
   
    self.bottomToolbarViewController = [[RTBottomToolbarViewController alloc]initWithDelegate:self superView:_activityFeedView];
    [self addChildViewController:self.bottomToolbarViewController];
    
    self.activityFeedViewController = [[RTActivityFeedViewController alloc]init];
    [self.activityFeedViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150)]; 
    [self.activityFeedViewController.tableView setFrame:self.activityFeedViewController.view.frame];
    
    self.followingViewController = (FollowingFollowingVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowingFollowingVC storyboardName:kStoryboardFollowing];
    
    self.settingsViewController = (FollowingSettingsVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIFollowingSettingsVC storyboardName:kStoryboardFollowing];
    
    UIStoryboard *studentStoryboard = [UIStoryboard storyboardWithName:@"StudentDiscountsStoryboard" bundle:nil];
    self.studentDiscountViewController = [studentStoryboard instantiateViewControllerWithIdentifier:@"StudentDiscountsViewController"];
    self.studentDiscountViewController.delegate = self;
    
    self.submitViewController = [[RTSubmitViewController alloc]init];
    self.submitViewController.delegate = self;
    [self getUser];
    
    [self showActivePage];
}

- (void)showActivePage {
    UIViewController *viewControllerToShow;
    NSString * title;
    [self.bottomToolbarViewController setSelectedIndex:self.activePage];
    if (self.activePage == RTFollowingViewControllerpage_SubmitPage) {
        viewControllerToShow = self.submitViewController;
        [self.bottomToolbarViewController addChildViewController:self.submitViewController];
        title = @"Submit a Discount";
    }else if (self.activePage == RTFollowingViewControllerpage_ActivityPage){
        [self showPageAtIndex:0 animated:YES];
        title = @"Activity Feed";
    } else if (self.activePage == RTFollowingViewControllerpage_DiscountPage) {
        viewControllerToShow = self.studentDiscountViewController;
        title = @"Student Discounts";
    }
    if (viewControllerToShow) {
        [self showViewController:viewControllerToShow withSegmentControl:NO];
    }
    [self.navigationController.navigationBar.topItem setTitle:title];
}

- (void)showViewController:(UIViewController *)vc withSegmentControl:(BOOL)shouldShowSegmentControl{
    for (UIViewController *childController in self.bottomToolbarViewController.childViewControllers) {
        [childController removeFromParentViewController];
    }
    [self.bottomToolbarViewController addChildViewController:vc];
    [self.activityFeedView showView:vc.view shouldShowSegmentControl:shouldShowSegmentControl];
}

-(void)getUser {
    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            self.currentUserObject = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
            [RTUserContext sharedInstance].currentUser = self.currentUserObject;
            [RTUserContext sharedInstance].boneCount = self.currentUserObject.boneCount;
            [RTUserContext sharedInstance].badgeTotalCount = self.currentUserObject.badgeCount;
            [self updateBoneCount];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getReferralCode];
            });
        }
    }];
}

-(void)getReferralCode {
    [[RTServerManager sharedInstance] getReferralCode:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSDictionary *dicReferral = [response.jsonObject objectForKey:@"referral"];
            RTReferral *referral = [RTModelBridge getReferralWithDictionary:dicReferral];
            [self saveReferral:referral forKey:@"referral"];
        }
    }];
}

-(void)saveReferral:(RTReferral*)referral forKey:(NSString*)key {
    NSData *encodeObject = [NSKeyedArchiver archivedDataWithRootObject:referral];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodeObject forKey:key];
    [defaults synchronize];
}

#pragma mark public
- (void)showPage:(RTFollowingViewControllerpage)page {
    self.activePage = page;
}

#pragma mark - UI
- (void)showPageAtIndex : (NSUInteger)index animated:(BOOL)animated {
    UIViewController *vc;
    switch(index) {
        case 0:
            self.activityFeedViewController = [[RTActivityFeedViewController alloc] init];
            [self.activityFeedViewController.view setFrame:self.activityFeedView.frame];
            [self.activityFeedViewController.tableView setFrame:self.activityFeedViewController.view.frame];
            vc = self.activityFeedViewController;
            break;
        case 1:
            vc = self.followingViewController;
            break;
        case 2:
            vc = self.settingsViewController;
    }
    [self.activityFeedView setSelectedSegment:index];
    [self showViewController:vc withSegmentControl:YES];
    [self.view layoutSubviews];
}

//- (void)showNoUpdatesViewWithAnimated:(BOOL)animated {
//    float duration = 0.0f;
//    
//    if( animated ) {
//        duration = 0.3f;
//    }
//    
//    [UIView animateWithDuration:duration / 2 animations:^{
//        [self.tblFollowingUpdates setAlpha:0.0f];
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration / 2 animations:^{
//            [self.vwNoUpdates setAlpha:1.0f];
//        }];
//    }];
//}
//
//- (void)hideNoUpdatesViewWithAnimated:(BOOL)animated {
//    float duration = 0.0f;
//    
//    if( animated ) {
//        duration = 0.3f;
//    }
//    
//    [UIView animateWithDuration:duration / 2 animations:^{
//        [self.vwNoUpdates setAlpha:0.0f];
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:duration / 2 animations:^{
//            [self.tblFollowingUpdates setAlpha:1.0f];
//        }];
//    }];
//}

- (void)updateBoneCount {
    [self setBonesCount];
}

- (void)updateBonesFromSubmit {
    [self setBonesCount];
}

-(void)setBonesCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
        [self setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
        
    });
}

#pragma mark - RTBottomToolbarViewControllerDelegate
-(void)userSelectedBottomButtonAtIndex:(NSInteger)index {
    if (self.activePage != index) {
        self.activePage = index;
        [self showActivePage];
    }
}


- (void)segmentSelectedAtIndex:(NSInteger)index {
    [self showPageAtIndex:index animated:YES];
}



@end
