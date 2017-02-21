//
//  StudentDiscountsViewController.h
//  RoverTown
//
//  Created by Robin Denis on 9/3/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"

@protocol StudentDiscountViewControllerDelegate <NSObject>

-(void)updateBoneCount;

@end

@interface StudentDiscountsViewController : CenterViewControllerBase

@property (nonatomic, weak) id<StudentDiscountViewControllerDelegate>delegate;
-(void)setRedirectToBusinessInfoWithStoreId:(int)storeId;
-(void)redirectToBusinessInfoWithStoreId:(int)storeId;


@end

@class SubmitDiscountCardViewController;

@protocol SubmitDiscountCardViewControllerDelegate <NSObject>

@optional
- (void)submitDiscountCardViewController:(SubmitDiscountCardViewController *)vc onSubmitDiscountButtonClicked:(BOOL)animated;

@end

@interface SubmitDiscountCardViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<SubmitDiscountCardViewControllerDelegate> delegate;

@end
