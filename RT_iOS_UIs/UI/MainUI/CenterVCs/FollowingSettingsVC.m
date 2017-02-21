//
//  FollowingSettingsVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "FollowingSettingsVC.h"
#import "FollowingSettingsCell.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTUserContext.h"
#import "RTUIManager.h"
#import "AppDelegate.h"

#define kFollowingSettingDescriptionNewDiscounts         @"Notify me of new discounts from businesses I follow."
#define kFollowingSettingDescriptionNearbyDiscounts      @"Notify me of discounts from nearby businesses."
#define kFollowingSettingDescriptionExpiringDiscounts    @"Notify me when discounts are about to expire at the businesses I follow."

@interface FollowingSettingsVC () <FollowingSettingsCellDelegate>
{
    RTUser *currentUser;
    BOOL isSettingsLoaded;
}

@property (weak, nonatomic) IBOutlet UITableView *tblFollowingSettings;

@end

@implementation FollowingSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblFollowingSettings.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        self.tblFollowingSettings.layoutMargins = UIEdgeInsetsZero;
    self.tblFollowingSettings.tableFooterView = [UIView new];
    
    [RTUIManager showProgressIndicator:self.tblFollowingSettings frameWidth:self.view.frame.size.width];
    
    currentUser = [[RTUser alloc] init];
    isSettingsLoaded = NO;
    
    [self getUser];
    self.navigationController.title = @"Settings";
    [self.view layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server API

- (void)getUser {
    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            currentUser = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
            
            isSettingsLoaded = YES;
            
            [RTUserContext sharedInstance].currentUser = currentUser;
            [RTUserContext sharedInstance].boneCount = currentUser.boneCount;
            [RTUserContext sharedInstance].badgeTotalCount = currentUser.badgeCount;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblFollowingSettings reloadData];
            });
        }
        else {
            //
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [RTUIManager hideProgressIndicator:self.tblFollowingSettings];
        });
    }];
}

- (void)updateUser {
    [[RTServerManager sharedInstance] updateUser:currentUser complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            //
        }
        else {
            //
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView Delegate, DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( !isSettingsLoaded ) {
        return 0;
    }
    
    NSArray *notificationDescriptionArray = @[kFollowingSettingDescriptionNearbyDiscounts, kFollowingSettingDescriptionNewDiscounts, kFollowingSettingDescriptionExpiringDiscounts];
    return [FollowingSettingsCell heightForCellWithDescription:notificationDescriptionArray[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ident = @"FollowingSettingsCell";
    
    FollowingSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        cell.layoutMargins = UIEdgeInsetsZero;
    
    cell.delegate = self;
    
    UIRectCorner corner = 0;
    
    switch( indexPath.row ) {
        case 0: //Nearby Discounts
            corner = UIRectCornerTopLeft | UIRectCornerTopRight;
            [cell bind:kNotificationSettingNearbyDiscounts description:kFollowingSettingDescriptionNearbyDiscounts isOn:[currentUser.settings.notify_nearby_discounts boolValue] corner:corner];
            break;
        case 1: //New Discounts
            [cell bind:kNotificationSettingNewDiscounts description:kFollowingSettingDescriptionNewDiscounts isOn:[currentUser.settings.notify_new_discounts boolValue] corner:corner];
            break;
        case 2: //Expiring Discounts
            corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            [cell bind:kNotificationSettingExpiringDiscounts description:kFollowingSettingDescriptionExpiringDiscounts isOn:[currentUser.settings.notify_expiring_discounts boolValue] corner:corner];
            break;
    }
    
    if( !isSettingsLoaded ) {
        [cell setHidden:YES];
    }
    else {
        [cell setHidden:NO];
    }
    
    return cell;
}

#pragma mark - FollowingSettingsCell delegate

- (void)onFollowingSettingChanged:(BOOL)isOn settingTitle:(NSString *)title {
    [Flurry logEvent:@"user_notifications_edit"];
    if( [title isEqualToString:kNotificationSettingNearbyDiscounts]) {
        currentUser.settings.notify_nearby_discounts = [NSNumber numberWithBool:isOn];
    }
    else if( [title isEqualToString:kNotificationSettingNewDiscounts] ) {
        currentUser.settings.notify_new_discounts = [NSNumber numberWithBool:isOn];
    }
    else if( [title isEqualToString:kNotificationSettingExpiringDiscounts]) {
        currentUser.settings.notify_expiring_discounts = [NSNumber numberWithBool:isOn];
    }
    
    [self updateUser];
    if (isOn) {
        [[AppDelegate getInstance] registerForNotifications];
    }
}

@end
