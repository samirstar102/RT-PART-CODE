//
//  AlcoholDiscountsCell.h
//  RoverTown
//
//  Created by Robin Denis on 9/3/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTStudentDiscount.h"

@class AlcoholDiscountsCell;

@protocol AlcoholDiscountsCellDelegate <NSObject>

- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onFollow:(RTStudentDiscount *)studentDiscount;
- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onTapBirthdayButton:(RTStudentDiscount *)studentDiscount;
- (void)alcoholDiscountCell:(AlcoholDiscountsCell *)cell onSubmitBirthday:(NSDate *)birthday;

@end

@interface AlcoholDiscountsCell : UITableViewCell

@property (nonatomic, retain) RTStudentDiscount *discount;
@property (nonatomic)   BOOL followed;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, weak) id<AlcoholDiscountsCellDelegate> delegate;

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated;
- (void)recalculateDistance;
+ (BOOL)isUserRestrictedWithDiscount:(RTStudentDiscount *)studentDiscount;
+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded;

@end
