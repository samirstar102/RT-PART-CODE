//
//  SupportChangelogVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "SupportChangelogVC.h"
#import "SupportChangelogCell.h"

@interface SupportChangelogVC () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *updatesArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tvChangelog;

@end

@implementation SupportChangelogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:@"user_changes_view"];
    // Do any additional setup after loading the view.
    updatesArray = [[NSMutableArray alloc] init];
    
    RTUpdates *update1 = [[RTUpdates alloc] init];
    update1.version = kUpdates1Version;
    update1.dateString = kUpdates1Date;
    update1.changeDescription = kUpdates1Description;
    
    
    RTUpdates *update2 = [[RTUpdates alloc] init];
    update2.version = kUpdates2Version;
    update2.dateString = kUpdates2Date;
    update2.changeDescription = kUpdates2Description;
    
    RTUpdates *update3 = [[RTUpdates alloc] init];
    update3.version = kUpdates3Version;
    update3.dateString = kUpdates3Date;
    update3.changeDescription = kUpdates3Description;
    
    [updatesArray addObject:update3];
    [updatesArray addObject:update2];
    [updatesArray addObject:update1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Data Source, Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return updatesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int additionalHeight = 0;

    if( indexPath.row == updatesArray.count - 1 )
            additionalHeight = 8;
        
    return [SupportChangelogCell heightForCellWithUpdates:updatesArray[indexPath.row]] + additionalHeight;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ident = @"SupportChangelogCell";
    
    SupportChangelogCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    
    [cell bind:updatesArray[indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
