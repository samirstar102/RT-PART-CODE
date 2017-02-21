//
//  BonesAndBadgesVC.m
//  RoverTown
//
//  Created by Robin Denis on 7/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "BonesAndBadgesVC.h"
#import "BonesCell.h"
#import "LockedBadgesCell.h"
#import "UnlockedBadgesCell.h"
#import "IndividualBadgeVC.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "RTBadge.h"
#import "RTStoryboardManager.h"
#import "SessionMgr.h"

@interface BonesAndBadgesVC() <UnlockedBadgesCellDelegate>
{
    NSMutableArray *arrayBones;
    NSMutableArray *arrayBadges;
    NSMutableArray *arrayLockedBadges;
    NSMutableArray *arrayUnlockedBadges;
}

@property (weak, nonatomic) IBOutlet UIButton *btnBones;
@property (weak, nonatomic) IBOutlet UIButton *btnBadges;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITableView *tvBones;
@property (weak, nonatomic) IBOutlet UITableView *tvBadges;
@property (weak, nonatomic) IBOutlet UIImageView *ivHeaderViewForBadgesTableView;
@property (weak, nonatomic) IBOutlet UILabel *lblNoBadgesMessage;
@property (weak, nonatomic) IBOutlet UIView *viewForUnlockedBadges;
@property (weak, nonatomic) IBOutlet UIView *headerViewForBadgesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForBonesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraintForBadgesTableView;

- (IBAction)onSegmentSelectionChanged:(id)sender;

@end

@implementation BonesAndBadgesVC

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self setUpNavBarWithoutBones];
    [self getBones];
    [self getBadges];
    
    //Initialize the count of unread badges
    [RTUserContext sharedInstance].badgeReadCount = [RTUserContext sharedInstance].badgeTotalCount;
}

-(void)initViews {
    [super initViews];
    
    //Initialize bone button
    [self.btnBones setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].boneCount] forState:UIControlStateNormal];
    [self.btnBones.layer setCornerRadius:kCornerRadiusDefault];
    
    //Initialize badge button
    [self.btnBadges setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].badgeTotalCount] forState:UIControlStateNormal];
    [self.btnBadges.layer setCornerRadius:kCornerRadiusDefault];
    
    //Add an empty header to table view in order to set padding to refresh animation icon
    self.tvBones.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    //Initialize badge button
    [self.btnBadges.layer setCornerRadius:kCornerRadiusDefault];
    
    [self.ivHeaderViewForBadgesTableView.layer setCornerRadius:kCornerRadiusDefault];
    
    //Displays badges table view for the first time.
    [self.segment setSelectedSegmentIndex:1];
    [self showBadgesTableViewWithAnimation:NO];
    
    [self.tvBones setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [self.tvBadges setBackgroundColor:[UIColor roverTownColorDarkBlue]];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)showBonesTableViewWithAnimation : (BOOL)isAnimated {
    float animationDuration = 0.0f;
    
    if( isAnimated )
        animationDuration = 0.2f;
    
    self.leftConstraintForBonesTableView.constant = 0;
    self.leftConstraintForBadgesTableView.constant = self.view.frame.size.width;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)showBadgesTableViewWithAnimation : (BOOL)isAnimated {
    float animationDuration = 0.0f;
    
    if( isAnimated )
        animationDuration = 0.2f;
    
    self.leftConstraintForBonesTableView.constant = -self.view.frame.size.width;
    self.leftConstraintForBadgesTableView.constant = 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)showNoBadgesMessageWithAnimation : (BOOL)isAnimated {
    
    [self.headerViewForBadgesTableView setBounds:CGRectMake(0, 0, self.headerViewForBadgesTableView.bounds.size.width, 128)];
    [self.tvBadges setTableHeaderView:self.headerViewForBadgesTableView];
}

- (void)hideNoBadgesMessageWithAnimation : (BOOL)isAnimated {
    [self.headerViewForBadgesTableView setBounds:CGRectMake(0, 0, self.headerViewForBadgesTableView.bounds.size.width, 57)];
    [self.tvBadges setTableHeaderView:self.headerViewForBadgesTableView];
}

- (void)hideBadgesTableHeaderView : (BOOL) isAnimated{
    [self.headerViewForBadgesTableView setBounds:CGRectMake(0, 0, self.headerViewForBadgesTableView.bounds.size.width, 16)];
    [self.tvBadges setTableHeaderView:self.headerViewForBadgesTableView];
}

#pragma mark - Server API

-(void)getBones {
    [self hideBadgesTableHeaderView:NO];
    [RTUIManager showProgressIndicator:self.tvBones frameWidth:self.view.bounds.size.width];
    
    arrayBones = [[NSMutableArray alloc] init];
    
    [[RTServerManager sharedInstance] getBones:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            NSArray *arrayBonesDicArray = [response.jsonObject objectForKey:@"bones"];
            arrayBones = [[NSMutableArray alloc] initWithArray:[RTModelBridge getBonesFromResponseForGetBones:arrayBonesDicArray]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tvBones reloadData];
            });
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator:self.tvBones];
        });
    }];
}

-(void)getBadges {
    [RTUIManager showProgressIndicator:self.tvBadges frameWidth:self.view.bounds.size.width];
    
    arrayBadges = [[NSMutableArray alloc] init];
    arrayLockedBadges = [[NSMutableArray alloc] init];
    arrayUnlockedBadges = [[NSMutableArray alloc] init];
    
    [[RTServerManager sharedInstance] getBadges:^(BOOL success, RTAPIResponse *response) {
        if( success ) {
            NSArray *arrayBadgesDicArray = [response.jsonObject objectForKey:@"badges"];
            arrayBadges = [[NSMutableArray alloc] initWithArray:[RTModelBridge getBadgesFromResponseForGetBadges:arrayBadgesDicArray]];
            
            //Check if the badge is unlocked for each badge and add them to corresponding arrays
            for ( RTBadge *badge in arrayBadges ) {
                if( badge.earned ) {
                    [arrayUnlockedBadges addObject:badge];
                }
                else {
                    [arrayLockedBadges addObject:badge];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( arrayUnlockedBadges.count == 0 ) {
                    [self showNoBadgesMessageWithAnimation:NO];
                }
                else {
                    [self hideNoBadgesMessageWithAnimation:NO];
                }
                [self.tvBadges reloadData];
            });
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator:self.tvBadges];
        });
    }];
}

#pragma mark - UITableView Data Source, Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if( tableView == self.tvBadges ) {
        return 2;
    }
    else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Returns deferent numbers according to each table view
    if( tableView == self.tvBones ) {
        return arrayBones.count;
    }
    else if( tableView == self.tvBadges ) {
        if( section == 0 ) {
            return (arrayUnlockedBadges.count + 1) / 2;
        }
        else if( section == 1) {
            if( arrayLockedBadges.count == 0 )
                return 0;
            else {
                return arrayLockedBadges.count + 1;
            }
        }
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.tvBones ) {
        return [BonesCell heightForCellWithBone:arrayBones[indexPath.row]];
    }
    else if( tableView == self.tvBadges ) {
        if( indexPath.section == 0 ) {
            NSArray *badgesArray = nil;
            
            if( (indexPath.row + 1) * 2  <= arrayUnlockedBadges.count )   //When the badge is not only last one
                badgesArray = [[NSArray alloc] initWithObjects:arrayUnlockedBadges[indexPath.row * 2], arrayUnlockedBadges[indexPath.row * 2 + 1], nil];
            else
                badgesArray = [[NSArray alloc] initWithObjects:arrayUnlockedBadges[indexPath.row * 2], nil];
            
             return [UnlockedBadgesCell heightForCellWithBadge:badgesArray];
        }
        else if( indexPath.section == 1 ) {
            if( indexPath.row == 0 )
                return 57;
            else {
                return [LockedBadgesCell heightForCellWithBadge:arrayLockedBadges[indexPath.row - 1]];
            }
        }
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.tvBones ) {
        NSString *ident = @"BonesCell";
        
        BonesCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];

        [cell bind:arrayBones[indexPath.row]];
        
        return cell;
    }
    else if( tableView == self.tvBadges ) {
        if( indexPath.section == 0 ) {      //Unlocked badges
            NSString *ident = @"UnlockedBadgesCell";
            
            NSArray *badgesArray = nil;
            
            if( (indexPath.row + 1) * 2  <= arrayUnlockedBadges.count )   //When the badge is not only last one
                badgesArray = [[NSArray alloc] initWithObjects:arrayUnlockedBadges[indexPath.row * 2], arrayUnlockedBadges[indexPath.row * 2 + 1], nil];
            else
                badgesArray = [[NSArray alloc] initWithObjects:arrayUnlockedBadges[indexPath.row * 2], nil];
            
            UnlockedBadgesCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
            
            cell.delegate = self;
            [cell bind:badgesArray];
            
            return cell;
            
        }
        else if( indexPath.section == 1 ) {  //Locked badges
            if( indexPath.row == 0 ) {
                float width = [UIScreen mainScreen].bounds.size.width;
                float height = 57.0f;
                float iconWidth = 25.0f;
    
                UITableViewCell *headerView = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 57)];
                UIImageView *ivLockIcon = [[UIImageView alloc] initWithFrame:CGRectMake((width - iconWidth) / 2, (height - iconWidth) / 2, iconWidth, iconWidth)];
    
                [ivLockIcon setImage:[UIImage imageNamed:@"locked_icon"]];
    
                [headerView setBackgroundColor:[UIColor colorWithRed:148.0f / 255.0f green:149.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f]];
                [headerView addSubview:ivLockIcon];
                
                UIImageView *splitLineLeft = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, height / 2 - 0.5f, (width - iconWidth) / 2 - 16.0f, 1)];
                
                [splitLineLeft setBackgroundColor:[UIColor colorWithRed:85.0f / 255.0f green:85.0f / 255.0f blue:90.0f / 255.0f alpha:1.0f]];
                
                [headerView addSubview:splitLineLeft];
                
                UIImageView *splitLineRight = [[UIImageView alloc] initWithFrame:CGRectMake((width + iconWidth) / 2, height / 2 - 0.5f, (width - iconWidth) / 2 - 16.0f, 1)];
                
                [splitLineRight setBackgroundColor:[UIColor colorWithRed:85.0f / 255.0f green:85.0f / 255.0f blue:90.0f / 255.0f alpha:1.0f]];
                
                [headerView addSubview:splitLineRight];
                
                return headerView;
            }
            else {
                NSString *ident = @"LockedBadgesCell";
                
                LockedBadgesCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
                
                [cell bind:arrayLockedBadges[indexPath.row - 1]];
                
                return cell;
            }
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

#pragma mark - Action

- (IBAction)onSegmentSelectionChanged:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) {
        [self showBonesTableViewWithAnimation:YES];
    }
    else {
        [self showBadgesTableViewWithAnimation:YES];
    }
}

#pragma mark - UnlockedBadgesCellDelegate

- (void)unlockedBadgesCell:(UnlockedBadgesCell *)cell onBadgeClicked:(RTBadge *)badge {
    IndividualBadgeVC *vc = (IndividualBadgeVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIIndividualBadgeVC storyboardName:kStoryboardIndividualBadge];
    [vc setBadge:badge];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

@end
