//
//  RTRedeemDiscountView.h
//  RoverTown
//
//  Created by Roger Jones Jr on 8/4/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTRedeemDiscountViewDelegate <NSObject>
- (void)followButtonTapped;
- (void)doneButtonTapped;
- (void)notAcceptedTapped;
- (void)cancelButtonTapped;
@end

@interface RTRedeemDiscountView : UIView
-(instancetype)initWithFrame:(CGRect)frame logo:(UIImageView *)logo storeName:(NSString *)storeName description: (NSString *)description finePrint:(NSString *)finePrint barCode:(UIImage *)barCode following:(BOOL)following tapToRedeem:(BOOL)tapToRedeem delegate:(id<RTRedeemDiscountViewDelegate>)delegate;
- (void)setFollowButtonEnabled:(BOOL)isEnable;
- (void)showStudentIdImage:(UIImage *)studentIdImage;
- (void)removeStudentIdImage;
- (void)discountRedeemedAt:(NSDate *)redeemedDate;
- (void)switchToRedeem;

@property (nonatomic, weak) id<RTRedeemDiscountViewDelegate> delegate;
@end
