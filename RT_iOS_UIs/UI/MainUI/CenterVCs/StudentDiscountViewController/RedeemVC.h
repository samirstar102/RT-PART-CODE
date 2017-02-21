//
//  RedeemViewController.h
//  RoverTown
//
//  Created by Robin Denis on 5/20/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTStudentDiscount.h"

@class RedeemVC;

@protocol RedeemVCDelegate <NSObject>

- (void)redeemVCDidDone:(RedeemVC *)vc boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged;
- (void)redeemVCDidCancel:(RedeemVC *)vc;
- (void)redeemVC:(RedeemVC *)vc onChangeFollowing:(BOOL)isFollowing storeId:(int)storeId;
- (void)redeemVC:(RedeemVC *)vc onDiscountUnaccepted:(int)discountId boneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged;

@end

@interface RedeemVC : UIViewController

@property (nonatomic, weak) id<RedeemVCDelegate> delegate;
@property (nonatomic, retain) RTStudentDiscount *discount;
@property (nonatomic) BOOL isRewardRedemption;

@end
