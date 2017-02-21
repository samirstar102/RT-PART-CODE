//
//  SubmitDiscountFormVC.h
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubmitDiscountFormVC;

@protocol SubmitDiscountFormVCDelegate <NSObject>

- (void)formVC:(SubmitDiscountFormVC *)vc onSendToRoverTownButtonClicked:(NSString *)businessName businessAddress:(NSString *)businessAddress discount:(NSString *)discount referralSubject:(NSString *)referralSubject;

@end

@interface SubmitDiscountFormVC : UIViewController

@property (nonatomic, weak) id<SubmitDiscountFormVCDelegate> delegate;

@end
