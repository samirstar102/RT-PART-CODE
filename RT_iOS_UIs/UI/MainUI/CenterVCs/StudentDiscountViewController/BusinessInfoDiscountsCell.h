//
//  BusinessInfoDiscountsCell.h
//  RoverTown
//
//  Created by Robin Denis on 5/23/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"

@class BusinessInfoDiscountsCell;

@protocol BusinessInfoDiscountsCellDelegate <NSObject>

- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell onRedeem:(RTStudentDiscount *)studentDiscount;
- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell commentsTappedForDiscount:(RTStudentDiscount *)discount;
- (void)businessInfoDiscountsCell:(BusinessInfoDiscountsCell *)cell onShare:(RTStudentDiscount *)studentDiscount;

@end

@interface BusinessInfoDiscountsCell : UITableViewCell

@property (nonatomic, readonly) RTStudentDiscount *discount;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, weak) id<BusinessInfoDiscountsCellDelegate> delegate;

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated;
+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded;

@end
