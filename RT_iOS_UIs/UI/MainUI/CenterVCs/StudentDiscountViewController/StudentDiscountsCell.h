//
//  StudentDiscountsCell.h
//  RoverTown
//
//  Created by Robin Denis on 9/3/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTStudentDiscount.h"

@class StudentDiscountsCell;

@protocol StudentDiscountsCellDelegate <NSObject>

- (void)studentDiscountCell:(StudentDiscountsCell *)cell onRedeem:(RTStudentDiscount *)studentDiscount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell onSaveForLater:(RTStudentDiscount *)studentDiscount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell unsaveForLater:(RTStudentDiscount *)studentDiscount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell onViewBusiness:(RTStudentDiscount *)studentDiscount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell onFollow:(RTStudentDiscount *)studentDiscount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell commentsTappedForDiscount:(RTStudentDiscount *)discount;
- (void)studentDiscountCell:(StudentDiscountsCell *)cell onShare:(RTStudentDiscount *)studentDiscount;


@end

@interface StudentDiscountsCell : UITableViewCell

@property (nonatomic, retain) RTStudentDiscount *discount;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic) BOOL isOutOfGeo;
@property (nonatomic) BOOL enforceGeoFlagged;
@property (nonatomic, weak) id<StudentDiscountsCellDelegate> delegate;

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated;
- (void)setFollowed:(BOOL)bFollowed;
- (void)recalculateDistance;
+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded;
- (void)setSaveForLater;
- (void)setUnsaveForLater;
- (void)resetInternalViews;
- (void)setCommentsValue:(int)comments;

@end
