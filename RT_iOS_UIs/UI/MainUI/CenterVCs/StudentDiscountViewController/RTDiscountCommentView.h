//
//  RTDiscountCommentView.h
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"

@protocol RTDiscountCommentViewDelegate <NSObject>

- (void)onFollowTappedForDiscount:(RTStudentDiscount *)studentDiscount;
- (void)activityButtonTapped;
- (void)commentsButtonTapped;

@end

@interface RTDiscountCommentView : UIView

- (instancetype) initWithFrame:(CGRect)frame logo:(UIImageView *)logo discountImage:(UIImageView *)discountImage storeName:(NSString *)storeName discountTitle:(NSString *)discountTitle discount:(RTStudentDiscount *)discount following:(BOOL)following delegate:(id<RTDiscountCommentViewDelegate>) delegate;
- (void)setFollowButtonEnabled:(BOOL)isEnabled;

@property (nonatomic, weak) id<RTDiscountCommentViewDelegate> delegate;

@end
