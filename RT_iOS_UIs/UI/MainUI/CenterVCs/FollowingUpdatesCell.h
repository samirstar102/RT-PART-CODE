//
//  FollowingUpdatesCell.h
//  RoverTown
//
//  Created by Robin Denis on 6/22/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTNotification.h"

@class FollowingUpdatesCell;

@protocol FollowingUpdatesCellDelegate <NSObject>

@end

@interface FollowingUpdatesCell : UITableViewCell

+ (CGFloat)heightForCellWithNotification:(RTNotification *)notification;

- (void)bind:(RTNotification *)notification;

@property (nonatomic, weak) id<FollowingUpdatesCellDelegate> delegate;

@end
