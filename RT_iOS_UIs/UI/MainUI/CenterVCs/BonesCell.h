//
//  BonesCell.h
//  RoverTown
//
//  Created by Robin Denis on 7/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "StudentDiscountsCell.h"
#import "RTBone.h"

@interface BonesCell : UITableViewCell

+ (CGFloat)heightForCellWithBone : (RTBone *)bone;

- (void)bind : (RTBone *)bone;

@end