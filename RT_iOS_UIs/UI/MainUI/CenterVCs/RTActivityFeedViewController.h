//
//  RTActivityFeedViewController.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTActivityFeedViewControllerDelegate <NSObject>

-(void)userIdTappedForUserId:(int)userId;

@end

@interface RTActivityFeedViewController : UIViewController

-(instancetype)initWithStoreId:(NSString*)storeId;
-(instancetype)initWithUserId:(int)userId;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, weak) id<RTActivityFeedViewControllerDelegate> delegate;

@end
