//
//  RTActivityFeedCell.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTActivity.h"
#import "RTStudentDiscount.h"

@class RTActivityFeedCell;

@protocol RTActivityFeedCellDelegate <NSObject>

-(void)activityCell:(RTActivityFeedCell *)cell onViewBusinessWithID:(NSInteger)storeID;
-(void)activityCell:(RTActivityFeedCell *)cell onCommentTapped:(RTStudentDiscount *)discount;
-(void)activityCell:(RTActivityFeedCell *)cell onDiscountTappedWithId:(NSInteger )discountId andStoreId:(NSInteger)storeId;
-(void)activityCell:(RTActivityFeedCell *)cell onUserTappedWithUserId:(int)userId;
-(void)imageTappedForImage:(UIImage *)image andComment:(NSString*)comment;

@end

@interface RTActivityFeedCell : UITableViewCell

@property (nonatomic, weak) id<RTActivityFeedCellDelegate>delegate;

- (instancetype)initWithActivity:(RTActivity *)activity;
- (void)setActivity:(RTActivity *)activity;
+ (CGFloat)heightForCellActivity:(RTActivity*)activity andView:(UIView*)view withImage:(BOOL)hasImage;
+ (CGFloat)heightForCellBusinessActivity:(RTActivity*)activity andView:(UIView*)view WithImage:(BOOL)hasImage;
- (void)bind:(RTStudentDiscount *)studentDiscount;

@property (nonatomic) NSString *activityType;

// This will be a test to make the cell work
@property (nonatomic, strong) UILabel *typeTestLabel;

@property (nonatomic, strong) UILabel *subjectFirstLabel;
@property (nonatomic, strong) UIButton *discountButton;
@property (nonatomic, strong) UILabel *subjectSecondLabel;
@property (nonatomic, strong) UIButton *storeButton;
@property (nonatomic) UILabel *discountLabel;
@property (nonatomic) UILabel *storeLabel;

@property (nonatomic, strong) UIView *centerContentView;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *centerTextLabel;

@property (nonatomic, strong) UILabel *createdTimeLabel;
@property (nonatomic) BOOL isBusinessActivity;

@end
