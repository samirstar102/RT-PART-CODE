//
//  FollowingCell.h
//  RoverTown
//
//  Created by Robin Denis on 5/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTStore.h"

@class FollowingCell;

@protocol FollowingCellDelegate <NSObject>

- (void)followingCell:(FollowingCell *)cell onViewBusinessInfoButton:(RTStore *)studentDiscount;
- (void)followingCell:(FollowingCell *)cell onUnFollowForDiscount:(RTStore *)studentDiscount;

@end

@interface FollowingCell : UITableViewCell

@property (nonatomic, readonly) RTStore *store;
@property (nonatomic, weak) id<FollowingCellDelegate> delegate;

- (void)bind:(RTStore *)store;

+ (CGFloat)heightForCellWithLabelText:(NSString *)labelText;

@end