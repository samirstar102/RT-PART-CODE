//
//  RTRedeemDiscountModel.h
//  RoverTown
//
//  Created by Roger Jones Jr on 8/6/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTStudentDiscount.h"
#import "RTRedeemDiscountView.h"
#import "RTRedeemOnlineDiscountView.h"

typedef NS_ENUM(NSInteger, RTDiscountType) {
    RTDiscountType_InStore = 0,
    RTDiscountType_Online
};


@protocol RTRedeemDiscountModelDelegate <NSObject>
- (void)discountRedeemed:(NSDate *)redeemDate;
- (void)showStudentIdImage:(UIImage *)studentIdImage;
- (void)showRedeemView;
- (void)followStatusChanged;
- (void)bluetoothOff;
- (void)dismissWithBoneCountChanged:(BOOL)boneCountChanged badgeCountChanged:(BOOL)badgeCountChanged;
- (void)canRedeem;
- (void)discountNotAccepted:(RTStudentDiscount *)discount boneCountChanged:(BOOL)changed badgeCountChanged:(BOOL)changed;
- (void)onStartRedeem;
- (void)onFinishRedeem;
- (void)shareDiscount:(RTStudentDiscount *)discount;
@end


@interface RTRedeemDiscountModel : NSObject <RTRedeemDiscountViewDelegate, RTRedeemOnlineDiscountViewProtocol>

- (id)initWithDiscount:(RTStudentDiscount *)discount;
- (void)willRotateToOrientation:(UIInterfaceOrientation)orientation;
- (UIImageView *)discountStoreLogo;
- (NSString *)discountStoreName;
- (NSString *)discountDescription;
- (NSString *)discountFinePrint;
- (UIImage *)discountBarcode;
- (BOOL)folllowingDiscountStore;
- (BOOL)discountRequiresTap;
- (BOOL)isBluetoothOn;
- (NSString *)bluetoothState;
- (BOOL)userHasIdPicture;
- (RTDiscountType)discountType;
- (NSString *)redemptionCode;

@property (nonatomic, weak) id<RTRedeemDiscountModelDelegate> delegate;

@end
