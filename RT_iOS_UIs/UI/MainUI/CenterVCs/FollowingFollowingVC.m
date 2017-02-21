//
//  FollowingFollowingVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//


#import "FollowingFollowingVC.h"
#import "RTStoryboardManager.h"
#import "BusinessInfoVC.h"
#import "SessionMgr.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUIManager.h"
#import "RTUnfollowAlertViewController.h"
#import "RTFollowingStoresModel.h"

@interface FollowingFollowingVC() <RTFollowingStoresModelDelegate>
{
    NSMutableArray *followingStoresArray;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *viewForNoFollowingBusinessMessage;
@property (weak, nonatomic) IBOutlet UIImageView *ivNoFollowingBusinessMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnStaticFollow;

@property (nonatomic) RTFollowingStoresModel *followingModel;
@property (nonatomic) NSArray *followingArray;

@end

@implementation FollowingFollowingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:@"user_following_view"];
    self.followingModel = [[RTFollowingStoresModel alloc] initWithDelegate:self];
    [self initViews];
//    [self loadData];
//    followingStoresArray = [NSMutableArray array];
    self.navigationController.title = @"Following";
    [RTUIManager showProgressIndicator : self.mainTableView frameWidth:self.view.frame.size.width];
    [self.followingModel getFollowingStores];
}

- (void)viewDidAppear:(BOOL)animated
{
//    [self loadData];
}

- (void)initViews {
    //Add an empty header to table view in order to set padding to refresh animation icon
    self.mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    
    //Set the appearance for No Following Business Message view
    [self.ivNoFollowingBusinessMessage.layer setCornerRadius:kCornerRadiusDefault];
    
    //Set the appearance for static follow button
    [RTUIManager applyFollowButtonStyle:self.btnStaticFollow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)followingStoresSuccess:(NSArray *)stores {
    self.followingArray = [NSArray arrayWithArray:stores];
    if (stores == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoFollowingBusinessMessageWithAnimated:NO];
            [self.mainTableView reloadData];
            [self.view layoutSubviews];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator:self.mainTableView];
            [self.mainTableView reloadData];
        });
    }
}

- (void)followingStoresFailure {
    [self showNoFollowingBusinessMessageWithAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view layoutSubviews];
    });
}

#pragma mark - Server APIs

- (void)loadData {
    //Hides the No Following Business Message view
    [self hideNoFollowingBusinessMessageWithAnimated:NO];
    
    //Start the refresh animation
    [RTUIManager showProgressIndicator : self.mainTableView frameWidth:self.view.frame.size.width];
    
    [[RTServerManager sharedInstance] followingStores:^(BOOL success, RTAPIResponse *response){
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator : self.mainTableView];
        });
        
        if (success) {
            followingStoresArray = [[NSMutableArray alloc] init];
            NSArray *stores = [response.jsonObject objectForKey:@"stores"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( stores.count == 0 ) { //if there is no business following
                    [self showNoFollowingBusinessMessageWithAnimated:YES];
                }
                else {
                    [self hideNoFollowingBusinessMessageWithAnimated:YES];
                    
                    NSArray *arrayRet = [RTModelBridge getStoresFromFollowingStores:stores];
                    for (RTStudentDiscount *store in arrayRet) {
                        [followingStoresArray addObject:store];
                    }
                }
                
                [self.mainTableView reloadData];
            });
        }
        else {
            //
        }
    }];
}

#pragma mark - Custom methods

- (void)showNoFollowingBusinessMessageWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    //Hides the table view if there is no business following.
    [UIView animateWithDuration:duration animations:^{
        [self.mainTableView setAlpha:0.0f];
        [self.viewForNoFollowingBusinessMessage setAlpha:1.0f];
    }];
}

- (void)hideNoFollowingBusinessMessageWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    //Shows the table view if there is more than one business following.
    [UIView animateWithDuration:duration animations:^{
        [self.mainTableView setAlpha:1.0f];
        [self.viewForNoFollowingBusinessMessage setAlpha:0.0f];
    }];
}

#pragma mark - UITableView Delegate, Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followingArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RTStore *store = nil;
    if (self.followingArray.count) {
        store = [self.followingArray objectAtIndex:indexPath.row];
        return [FollowingCell heightForCellWithLabelText:store.name];
    } else {
        return 0;
    }
    //    if( [store.user.following boolValue] == NO )    //Hides if is not following store.
    //        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.followingArray.count) {
        RTStore *store = [self.followingArray objectAtIndex:indexPath.row];
        NSString *ident = @"FollowingCellId";
        
        FollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        
        [cell bind:store];
        
        cell.delegate = self;
        
        return cell;
    } else {
        return nil;
    }
}

#pragma mark - FollowingCell Delegate

- (void)followingCell:(FollowingCell *)cell onViewBusinessInfoButton:(RTStore *)store {
    // show business info
    [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.store = store;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)followingCell:(FollowingCell *)cell onUnFollowForDiscount:(RTStore *)studentDiscount
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shouldNotShow = [defaults boolForKey:@"showFollowAlerts"];
    if (!shouldNotShow) {
        RTUnfollowAlertViewController *alertVC = (RTUnfollowAlertViewController *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"unfollowAlert" storyboardName:kStoryboardFollowing];
        alertVC.storeForSegue = studentDiscount;
        alertVC.delegate = self;
        self.definesPresentationContext = NO;
        alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:alertVC animated:YES completion:nil];
        [alertVC viewDidLoad];
        [alertVC reloadInputViews];
    } else {
        [[RTUIManager sharedInstance] showToastMessageWithView:self.view labelText:nil descriptionText:@"Unfollowing business..."];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", studentDiscount.storeId],@"storeId", nil];
        [Flurry logEvent:@"user_unfollows_store" withParameters:params];
        NSString *storeToUnfollow = [NSString stringWithFormat:@"%d", studentDiscount.storeId];
        [[RTServerManager sharedInstance] followStore:storeToUnfollow isEnabling:NO complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                [self.followingModel getFollowingStores];
                
                
//                [self loadData];
            } else {
                // show alert that network cannot connect with ok: dismiss
            }
        }];
    }
}

- (void)dismissedUnfollowingAlert {
    [self.followingModel getFollowingStores];
}

#pragma mark - BusinessInfoVC Delegate

- (void)businessInfoVC:(BusinessInfoVC *)vc onChangeFollowing:(BOOL)isFollowing {
    
    [self.followingModel getFollowingStores];
//    [self loadData];
}

@end