//
//  FollowerArchivesCell.h
//  RoverTown
//
//  Created by Robin Denis on 8/10/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"   //#import "RTFollowerArchive.h"

@class FollowerArchivesCell;

@protocol FollowerArchivesCellDelegate <NSObject>

- (void) followerArchivesCell:(FollowerArchivesCell *)cell onViewBusinessInfo:(RTStudentDiscount *)archive;
- (void) followerArchivesCell:(FollowerArchivesCell *)cell onShare:(RTStudentDiscount *)archive;

@end

@interface FollowerArchivesCell : UITableViewCell

@property (nonatomic, readonly) RTStudentDiscount *archive;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, weak) id<FollowerArchivesCellDelegate> delegate;

- (void)bind:(RTStudentDiscount *)archive isExpanded:(BOOL)isExpanded animated:(BOOL)animated;
+ (CGFloat)heightForCellWithArchive:(RTStudentDiscount *)archive isExpanded:(BOOL)isExpanded;

@end
