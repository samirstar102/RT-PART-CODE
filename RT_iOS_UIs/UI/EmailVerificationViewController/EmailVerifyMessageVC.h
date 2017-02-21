//
//  EmailVerifyMessageVC.h
//  RoverTown
//
//  Created by Robin Denis on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RoverTownBaseViewController.h"

@protocol EmailVerifyMessageVCDelegate <NSObject>
-(void)checkVerificationButtonTapped;
@end

@interface EmailVerifyMessageVC : RoverTownBaseViewController
@property (nonatomic, weak) id<EmailVerifyMessageVCDelegate> delegate;
- (void)enableButtons;

@end