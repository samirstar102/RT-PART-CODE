//
//  FollowerRewardsVC.m
//  RoverTown
//
//  Created by Robin Denis on 8/9/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "FollowerRewardsVC.h"
#import "RTStudentDiscount.h"   //#import "RTFollwerReward.h"
#import "FollowerRewardsCell.h"
#import "FollowerArchivesCell.h"
#import "RTUIManager.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "RTModelBridge.h"
#import "RTStoryboardManager.h"
#import "SessionMgr.h"
#import "BusinessInfoVC.h"
#import "RedeemVC.h"
#import "RTUserContext.h"
#import <MessageUI/MessageUI.h>
#import <TwitterKit/TwitterKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FollowerRewardsVC () <FollowerRewardsCellDelegate, FollowerArchivesCellDelegate, BusinessInfoVCDelegate, RedeemVCDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>
{
    int indexOfExpandedRewardCell;
    BOOL isRewardCellExpanded;    //Indicates one of the table view cells of reward table is expanded
    
    int indexOfExpandedArchiveCell;
    BOOL isArchiveCellExpanded;    //Indicates one of the table view cells of archive table is expanded
    
    RTStudentDiscount *rewardToBeShared;
    
    NSMutableArray *arrayRewards;
    NSMutableArray *arrayArchives;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForShareView;
}

@property (weak, nonatomic) IBOutlet UITableView *tvRewards;
@property (weak, nonatomic) IBOutlet UITableView *tvArchives;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIView *vwShare;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelSharing;
@property (weak, nonatomic) IBOutlet UIButton *btnShareMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnShareMail;
@property (weak, nonatomic) IBOutlet UIButton *btnShareTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnShareFacebook;
@property (nonatomic) UIView *viewToCaptureTaps;

@end

@implementation FollowerRewardsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getNearbyDiscountsWithIsInitialize:YES];
    
    indexOfExpandedRewardCell = -1;
    isRewardCellExpanded = NO;
    
    indexOfExpandedArchiveCell = -1;
    isArchiveCellExpanded = NO;
}

- (void)initViews {
    [super initViews];
    
    //Initialize discounts table view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tvRewards.frame.size.width, 8)];
    [headerView setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    self.tvRewards.tableHeaderView = headerView;
    self.tvArchives.tableHeaderView = headerView;
    
    //Show/Hide Rewards and Archives table views
    [self showRewardsTableWithAnimated:NO];
    
    //Initialize Share View
    [self hideShareViewWithAnimated:NO];
}

- (void)initEvents {
    [super initEvents];
    
    self.viewToCaptureTaps = [[UIView alloc] initWithFrame:self.view.frame];
    CGRect frame = self.viewToCaptureTaps.frame;
    [self.viewToCaptureTaps setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.vwShare.bounds.size.height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideShareView)];
    [self.viewToCaptureTaps addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    //Initialize Share View
    [RTUIManager applyBlurView:self.vwShare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate, data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( tableView == self.tvRewards )
        return arrayRewards.count;
    else if( tableView == self.tvArchives )
        return arrayArchives.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( tableView == self.tvRewards ) {
        RTStudentDiscount *reward = [arrayRewards objectAtIndex:indexPath.row];
        
        if( isRewardCellExpanded && [indexPath row] == indexOfExpandedRewardCell ) {
            //Height when cell is expanded.
            return [FollowerRewardsCell heightForCellWithReward:reward isExpanded:YES];
        }
        
        return [FollowerRewardsCell heightForCellWithReward:reward isExpanded:NO];
    }
    else if( tableView == self.tvArchives ){
        RTStudentDiscount *archive = [arrayRewards objectAtIndex:indexPath.row];
        
        if( isArchiveCellExpanded && [indexPath row] == indexOfExpandedArchiveCell ) {
            //Height when cell is expanded.
            return [FollowerArchivesCell heightForCellWithArchive:archive isExpanded:YES];
        }
        
        return [FollowerArchivesCell heightForCellWithArchive:archive isExpanded:NO];
    }
    else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ident;
    
    if( tableView == self.tvRewards ) {
        RTStudentDiscount *reward = [arrayRewards objectAtIndex:indexPath.row];
        ident = @"FollowerRewardsCellId";
        FollowerRewardsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if( isRewardCellExpanded && [indexPath row] == indexOfExpandedRewardCell ) {
            [cell bind:reward isExpanded:YES animated:NO];
        }
        else {
            [cell bind:reward isExpanded:NO animated:NO];
        }
        cell.delegate = self;
        
        return cell;
    }
    else if( tableView == self.tvArchives ) {
        RTStudentDiscount *archive = [arrayArchives objectAtIndex:indexPath.row];
        ident = @"FollowerArchivesCellId";
        FollowerArchivesCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
        if( isArchiveCellExpanded && [indexPath row] == indexOfExpandedArchiveCell ) {
            [cell bind:archive isExpanded:YES animated:NO];
        }
        else {
            [cell bind:archive isExpanded:NO animated:NO];
        }
        cell.delegate = self;
        
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( tableView == self.tvRewards ) {
        FollowerRewardsCell *cell = (FollowerRewardsCell *)[self.tvRewards cellForRowAtIndexPath:indexPath];
        
        if( cell.isAnimating )
            return;
        
        RTStudentDiscount *discount = [arrayRewards objectAtIndex:indexPath.row];
        
        if( isRewardCellExpanded == YES && indexOfExpandedRewardCell == [indexPath row] ) {
            isRewardCellExpanded = NO;
            indexOfExpandedRewardCell = -1;
            [[self tvRewards] beginUpdates];
            
            [cell bind:discount isExpanded:NO animated:YES];
            [[self tvRewards] endUpdates];
        }
        else {
            int indexOfOldExpandedCell = indexOfExpandedRewardCell;
            indexOfExpandedRewardCell = (int)[indexPath row];
            isRewardCellExpanded = YES;
            
            [[self tvRewards] beginUpdates];
            
            if( indexOfOldExpandedCell != -1 ) {
                RTStudentDiscount *expandedDiscount = [arrayRewards objectAtIndex:indexOfOldExpandedCell];
                cell = (FollowerRewardsCell *)[self.tvRewards cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [cell bind:expandedDiscount isExpanded:NO animated:YES];
            }
            cell = (FollowerRewardsCell *)[self.tvRewards cellForRowAtIndexPath:indexPath];
            [cell bind:[arrayRewards objectAtIndex:indexPath.row] isExpanded:YES animated:YES];
            
            [[self tvRewards] endUpdates];
        }
    }
    else if ( tableView == self.tvArchives) {
        FollowerArchivesCell *cell = (FollowerArchivesCell *)[self.tvArchives cellForRowAtIndexPath:indexPath];
        
        if( cell.isAnimating )
            return;
        
        RTStudentDiscount *discount = [arrayArchives objectAtIndex:indexPath.row];
        
        if( isArchiveCellExpanded == YES && indexOfExpandedArchiveCell == [indexPath row] ) {
            isArchiveCellExpanded = NO;
            indexOfExpandedArchiveCell = -1;
            [[self tvArchives] beginUpdates];
            
            [cell bind:discount isExpanded:NO animated:YES];
            [[self tvArchives] endUpdates];
        }
        else {
            int indexOfOldExpandedCell = indexOfExpandedArchiveCell;
            indexOfExpandedArchiveCell = (int)[indexPath row];
            isArchiveCellExpanded = YES;
            
            [[self tvArchives] beginUpdates];
            
            if( indexOfOldExpandedCell != -1 ) {
                RTStudentDiscount *expandedDiscount = [arrayArchives objectAtIndex:indexOfOldExpandedCell];
                cell = (FollowerArchivesCell *)[self.tvArchives cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfOldExpandedCell inSection:0]];
                [cell bind:expandedDiscount isExpanded:NO animated:YES];
            }
            cell = (FollowerArchivesCell *)[self.tvArchives cellForRowAtIndexPath:indexPath];
            [cell bind:[arrayArchives objectAtIndex:indexPath.row] isExpanded:YES animated:YES];
            
            [[self tvArchives] endUpdates];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if( tableView == self.tvRewards ) {
        if (indexOfExpandedRewardCell == indexPath.row) {
            //Check if the table is being scrolled
            if( tableView.isDragging || tableView.isDecelerating ) {
                indexOfExpandedRewardCell = -1;
                isRewardCellExpanded = NO;
            }
        }
    }
    else if(  tableView == self.tvArchives ) {
        if (indexOfExpandedArchiveCell == indexPath.row) {
            //Check if the table is being scrolled
            if( tableView.isDragging || tableView.isDecelerating ) {
                indexOfExpandedArchiveCell = -1;
                isArchiveCellExpanded = NO;
            }
        }
    }
}

#pragma mark - FollowerRewardTableView Delegate

- (void)followerRewardsCell:(FollowerRewardsCell *)cell onRedeemRewards:(RTStudentDiscount *)reward {
    RedeemVC *vc = (RedeemVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIRedeemVC storyboardName:kStoryboardRedeem];
    [vc setIsRewardRedemption:YES];
    [vc setDiscount:reward];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)followerRewardsCell:(FollowerRewardsCell *)cell onViewBusinessInfo:(RTStudentDiscount *)reward {
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.delegate = self;
    vc.storeId = [NSNumber numberWithInt:reward.store.storeId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)followerRewardsCell:(FollowerRewardsCell *)cell onShare:(RTStudentDiscount *)reward {
    rewardToBeShared = reward;
    [self showShareViewWithAnimated:YES];
}

#pragma mark - FollowerArchiveTableView Delegate

- (void)followerArchivesCell:(FollowerArchivesCell *)cell onViewBusinessInfo:(RTStudentDiscount *)archive {
    BusinessInfoVC *vc = (BusinessInfoVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIBusinessInfoVC storyboardName:kStoryboardBusinessInfo];
    vc.delegate = self;
    vc.storeId = [NSNumber numberWithInt:archive.store.storeId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)followerArchivesCell:(FollowerArchivesCell *)cell onShare:(RTStudentDiscount *)archive {
    rewardToBeShared = archive;
    [self showShareViewWithAnimated:YES];
}

#pragma mark - BusinessInfoVC Delegate

- (void)businessInfoVC:(BusinessInfoVC *)vc onChangeFollowing:(BOOL)isFollowing {
    //TODO: Implement this
}

#pragma mark - Server API

//TODO: Delete this (For test)
- (void)getNearbyDiscountsWithIsInitialize : (BOOL)isInitialize {
    [RTUIManager showProgressIndicator : self.tvRewards frameWidth:self.view.frame.size.width];
    [RTUIManager showProgressIndicator : self.tvArchives frameWidth:self.view.frame.size.width];
    
    [[RTServerManager sharedInstance] nearbyDiscountsWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude start:0 limit:20 complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSArray *discounts = [response.jsonObject objectForKey:@"discounts"];
            NSArray *arrayRet = [RTModelBridge getStudentDiscountsFromResponseForGetDiscounts:discounts];
            dispatch_async(dispatch_get_main_queue(), ^{
                arrayRewards = [[NSMutableArray alloc] initWithArray:arrayRet];
                arrayArchives = [[NSMutableArray alloc] initWithArray:arrayRet];
                [self.tvRewards reloadData];
                [self.tvArchives reloadData];
            });
            
        }
        else {
            // TO DO
            // show error
//            [self showNoDiscountErrorViewWithAnimated:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator : self.tvRewards];
            [RTUIManager hideProgressIndicator : self.tvArchives];
        });
    }];
}

#pragma mark - RedeemVC Delegate

- (void)redeemVCDidDone:(RedeemVC *)vc boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    [vc dismissViewControllerAnimated:YES completion:nil];
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

- (void)redeemVCDidCancel:(RedeemVC *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)redeemVC:(RedeemVC *)vc onDiscountUnaccepted:(int)discountId boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged {
    
}

- (void)redeemVC:(RedeemVC *)vc onChangeFollowing:(BOOL)isFollowing storeId:(int)storeId {
    //TODO: Implement this
}

#pragma mark - Segment action

- (IBAction)onSegmentChanged:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) {
        [self showRewardsTableWithAnimated:YES];
    } else {
        [self showArchivesTableWithAnimated:YES];
    }
}

#pragma mark - Share Action

- (IBAction)onCancelSharing:(id)sender {
    [self hideShareViewWithAnimated:YES];
}

- (void)showRewardsTableWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.tvArchives setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.tvRewards setAlpha:1.0f];
        }];
    }];
}

- (IBAction)onShareViaMessage:(id)sender {
    //check if the device is able to send sms
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *contentTextForShare = @"";
    
    if( rewardToBeShared != nil ) {
        contentTextForShare = [NSString stringWithFormat:@"Check out this discount at %@:\n%@.", rewardToBeShared.store.name, rewardToBeShared.discountDescription];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:nil];
    [messageController setBody:contentTextForShare];
    messageController.messageComposeDelegate = self;
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)onShareViaEmail:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    NSString *subjectForShare = @"";
    NSString *contentTextForShare = @"";
    
    if( rewardToBeShared != nil ) {
        subjectForShare = [NSString stringWithFormat:@"%@ Discount on RoverTown", rewardToBeShared.store.name];
        contentTextForShare = [NSString stringWithFormat:@"Check out this discount at %@:\n%@.\n%@", rewardToBeShared.store.name, rewardToBeShared.discountDescription, rewardToBeShared.url];
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:subjectForShare];
    [mailController setMessageBody:contentTextForShare isHTML:NO];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)onShareViaTwitter:(id)sender {
    @try {
        NSString *contentTextForShare = @"";
        
        if( rewardToBeShared != nil ) {
            contentTextForShare = [NSString stringWithFormat:@"%@ at %@ via @rovertown", rewardToBeShared.discountDescription, rewardToBeShared.store.name];
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setURL:[NSURL URLWithString:rewardToBeShared.url]];
            [composer setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:rewardToBeShared.store.logo]]]];
            [composer setText:contentTextForShare];
            
            [composer showFromViewController:self completion:^(TWTRComposerResult result){
                if( result == TWTRComposerResultDone ) {
//                    [[RTServerManager sharedInstance] shareDiscountWithDiscountId:rewardToBeShared.discountId storeId:rewardToBeShared.store.storeId platform:kSharingPlatformTwitter complete:^(BOOL success, RTAPIResponse *response) {
//                        if( success ) {
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [RTUserContext sharedInstance].boneCount += 1;
//                                [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
//                                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                                
                                [self hideShareView];
                            });
//                        }
//                    }];
                }
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)onShareViaFacebook:(id)sender {
    @try {
        NSString *contentTextForShare = @"";
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if( rewardToBeShared != nil ) {
            contentTextForShare = [NSString stringWithFormat:@"%@ at %@ via @rovertown", rewardToBeShared.discountDescription, rewardToBeShared.store.name];
            
            content.contentURL = [NSURL URLWithString:rewardToBeShared.url];
            content.contentDescription = contentTextForShare;
            content.imageURL = [NSURL URLWithString:rewardToBeShared.store.logo];
        }
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - MFMailComposeViewController, MFMessageComposeViewController Delegates

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    if( result == MessageComposeResultSent ) {
//        [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformSMS complete:^(BOOL success, RTAPIResponse *response) {
//            if( success ) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [RTUserContext sharedInstance].boneCount += 1;
//                    [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
//                    [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                    [self hideShareView];
                });
//            }
//        }];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if( result == MFMailComposeResultSent ) {
//        [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformEmail complete:^(BOOL success, RTAPIResponse *response) {
//            if( success ) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [RTUserContext sharedInstance].boneCount += 1;
//                    [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
//                    [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                    [self hideShareView];
                });
//            }
//        }];
    }
}

#pragma mark - FBSDKSharingDelegate

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
//    [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountForShare.discountId storeId:discountForShare.store.storeId platform:kSharingPlatformFacebook complete:^(BOOL success, RTAPIResponse *response) {
//        if( success ) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [RTUserContext sharedInstance].boneCount += 1;
//                [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
//                [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
                [self hideShareView];
            });
//        }
//    }];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    return;
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    return;
}

- (void)showArchivesTableWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.tvRewards setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.tvArchives setAlpha:1.0f];
        }];
    }];
}

- (void)showShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    [self.view addSubview:self.viewToCaptureTaps];
    
    if( bottomConstraintForShareView.constant != 0 ) {
        bottomConstraintForShareView.constant = 0;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    [self.viewToCaptureTaps removeFromSuperview];
    
    if( bottomConstraintForShareView.constant == 0 ) {
        bottomConstraintForShareView.constant = 0 - self.vwShare.frame.size.height;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideShareView {
    [self hideShareViewWithAnimated:YES];
}

@end
