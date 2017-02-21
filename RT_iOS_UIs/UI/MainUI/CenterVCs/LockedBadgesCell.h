//
//  LockedBadgesCell.h
//  RoverTown
//
//  Created by Robin Denis on 7/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTBadge.h"

@interface LockedBadgesCell : UITableViewCell

+ (CGFloat)heightForCellWithBadge : (RTBadge*)badge;

- (void)bind : (RTBadge*)badge;

@end
