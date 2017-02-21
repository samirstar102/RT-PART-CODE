//
//  RTDiscountCommentViewController.h
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"
#import "RTDiscountCommentModel.h"
#import "CenterViewControllerBase.h"

@class RTDiscountCommentViewController;

@protocol RTDiscountCommentViewControllerDelegate <NSObject>

-(void)discountCommentViewController:(RTDiscountCommentViewController*)viewController onChangeFollowing:(BOOL)isFollowing;
-(void)discountCommentViewController:(RTDiscountCommentViewController*)viewController onUpdateDiscountComments:(int)incrementalComment;

@end

@interface RTDiscountCommentViewController : CenterViewControllerBase <UITableViewDelegate, UITableViewDataSource>

-(instancetype)initWithModel:(RTDiscountCommentModel *)model;

@property (nonatomic, weak) id<RTDiscountCommentViewControllerDelegate> delegate;

@end
