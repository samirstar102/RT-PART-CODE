//
//  FollowerRewardsCell.h
//  RoverTown
//
//  Created by Robin Denis on 8/10/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"   //#import "RTFollowerReward.h"

@class FollowerRewardsCell;

@protocol FollowerRewardsCellDelegate <NSObject>

- (void) followerRewardsCell:(FollowerRewardsCell *)cell onRedeemRewards:(RTStudentDiscount *)reward;
- (void) followerRewardsCell:(FollowerRewardsCell *)cell onViewBusinessInfo:(RTStudentDiscount *)reward;
- (void) followerRewardsCell:(FollowerRewardsCell *)cell onShare:(RTStudentDiscount *)reward;

@end

@interface FollowerRewardsCell : UITableViewCell

@property (nonatomic, readonly) RTStudentDiscount *reward;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, weak) id<FollowerRewardsCellDelegate> delegate;

- (void)bind:(RTStudentDiscount *)reward isExpanded:(BOOL)isExpanded animated:(BOOL)animated;
- (void)recalculateDistance;

+ (CGFloat)heightForCellWithReward:(RTStudentDiscount *)reward isExpanded:(BOOL)isExpanded;

@end
