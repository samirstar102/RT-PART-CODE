//
//  SubmitDiscountFormMessageVC.h
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubmitDiscountFormMessageVC;

@protocol SubmitDiscountFormMessageVCDelegate <NSObject>

- (void)formMessageVC:(SubmitDiscountFormMessageVC *)vc onSubmitDiscountButtonClicked:(BOOL)animated;

@end

@interface SubmitDiscountFormMessageVC : UIViewController

@property (nonatomic, weak) id<SubmitDiscountFormMessageVCDelegate> delegate;

@end
