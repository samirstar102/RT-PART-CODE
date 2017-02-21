//
//  RTReedemOnlineDiscountView.h
//  RoverTown
//
//  Created by Roger Jones Jr on 9/28/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTRedeemOnlineDiscountViewProtocol <NSObject>
- (void)neverMindButtonTapped;
- (void)redeemOnlineButtonTapped;
- (void)shareButtonTapped;
- (BOOL)enableRedeemButton;
- (NSString *)getInstructionTextForOnlineDiscount;
@end

@interface RTRedeemOnlineDiscountView : UIView

-(instancetype)initWithFrame:(CGRect)frame storeName:(NSString *)storeName description:(NSString *)description middelImageView:(UIImageView *)middleImageView redemptionCode:(NSString *)redemptionCode delegate:(id<RTRedeemOnlineDiscountViewProtocol>)delegate;

@end
