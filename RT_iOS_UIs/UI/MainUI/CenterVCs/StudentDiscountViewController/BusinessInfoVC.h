//
//  BusinessInfoViewController.h
//  RoverTown
//
//  Created by Robin Denis on 5/21/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"
#import "RTStudentDiscount.h"
#import "RTStore.h"
#import "RTRedeemDiscountView.h"
#import "RTRedeemDiscountModel.h"
#import "RTRedeemDiscountViewController.h"
#import "RTRedeemOnlineDiscountView.h"

@class BusinessInfoVC;

@protocol BusinessInfoVCDelegate <NSObject>

- (void)businessInfoVC:(BusinessInfoVC*)vc onChangeFollowing:(BOOL)isFollowing;

@end

@interface BusinessInfoVC : CenterViewControllerBase <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, RTRedeemDiscountViewDelegate, RTRedeemDiscountViewControllerDelegate, RTRedeemDiscountModelDelegate, RTRedeemOnlineDiscountViewProtocol>

@property (nonatomic, retain) RTStore *store;

@property (nonatomic, retain) NSNumber *storeId;

@property (nonatomic, weak) id<BusinessInfoVCDelegate> delegate;

- (void)loadDiscountsForStore:(int)storeId;

@end
