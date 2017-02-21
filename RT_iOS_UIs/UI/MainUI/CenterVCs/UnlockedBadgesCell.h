//
//  UnlockedBadgesCell.h
//  RoverTown
//
//  Created by Robin Denis on 8/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTBadge.h"

@class UnlockedBadgesCell;

@protocol UnlockedBadgesCellDelegate <NSObject>

- (void)unlockedBadgesCell:(UnlockedBadgesCell *)cell onBadgeClicked:(RTBadge *)badge;

@end

@interface UnlockedBadgesCell : UITableViewCell

@property (nonatomic, weak) id<UnlockedBadgesCellDelegate> delegate;

- (void)bind:(NSArray *)badge;

+ (CGFloat)heightForCellWithBadge:(NSArray *)badge;

@end
