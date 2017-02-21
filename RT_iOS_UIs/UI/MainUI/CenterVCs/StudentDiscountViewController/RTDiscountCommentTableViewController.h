//
//  RTDiscountCommentTableViewController.h
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTDiscountCommentModel.h"

@protocol RTDiscountCommentTableViewDelegate <NSObject>

@end

@interface RTDiscountCommentTableViewController : UITableViewController <RTDiscountCommentModelDelegate>

-(instancetype)initWithModel:(RTDiscountCommentModel *)model delegate:(id<RTDiscountCommentTableViewDelegate>)delegate;
- (void)commentsSegmentTapped;
- (void)activitySegmentTapped;

@property (nonatomic, weak) id<RTDiscountCommentTableViewDelegate> delegate;

@end
