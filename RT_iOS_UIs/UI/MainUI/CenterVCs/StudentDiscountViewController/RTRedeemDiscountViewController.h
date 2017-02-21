//
//  RTRedeemDiscountViewController.h
//  RoverTown
//
//  Created by Roger Jones Jr on 8/4/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"
#import "RTRedeemDiscountModel.h"
#import "CenterViewControllerBase.h"

@protocol RTRedeemDiscountViewControllerDelegate <NSObject>
- (void)boneAndBadgeCountChangedWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged;
- (void)discountUnaccepted:(RTStudentDiscount *)discount boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged;
- (void)shareDiscount:(RTStudentDiscount *)discount;
- (void)changeFollowing:(BOOL)isFollowing;
@end

@interface RTRedeemDiscountViewController : CenterViewControllerBase
- (id)initWithModel:(RTRedeemDiscountModel *)model;

@property (nonatomic, weak) id<RTRedeemDiscountViewControllerDelegate> delegate;
@end
