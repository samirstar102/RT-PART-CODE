//
//  LockedBadgesCell.m
//  RoverTown
//
//  Created by Robin Denis on 7/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "LockedBadgesCell.h"

@interface LockedBadgesCell()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

@implementation LockedBadgesCell

- (void)bind:(RTBadge *)badge {
    [self.lblName setText:badge.name];
    [self.lblDescription setText:badge.descriptionForBadge];
}

+ (CGFloat)heightForCellWithBadge:(RTBadge *)badge {
    UILabel *lblBadgeName, *lblBadgeDescription;
    
    lblBadgeName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    [lblBadgeName setFont:BOLDFONT14];
    [lblBadgeName setNumberOfLines:0];
    [lblBadgeName setText:badge.name];
    [lblBadgeName sizeToFit];
    
    lblBadgeDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    [lblBadgeDescription setFont:REGFONT14];
    [lblBadgeDescription setNumberOfLines:0];
    [lblBadgeDescription setText:badge.descriptionForBadge];
    [lblBadgeDescription sizeToFit];
    
    return MAX(58.0f, 24.0f + lblBadgeName.frame.size.height + lblBadgeDescription.frame.size.height);
}

@end