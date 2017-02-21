//
//  SupportChangelogCell.h
//  RoverTown
//
//  Created by Robin Denis on 6/8/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTUpdates.h"

@interface SupportChangelogCell : UITableViewCell

+ (CGFloat)heightForCellWithUpdates : (RTUpdates*)updatesData;

- (void)bind : (RTUpdates*)updatesData;

@end
