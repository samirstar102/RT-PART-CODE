//
//  EmailLockOutVC.h
//  RoverTown
//
//  Created by Robin Denis on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RoverTownBaseViewController.h"
#import "RTEmailLockOutModel.h"

@class EmailLockOutVC;

@protocol EmailLockOutVCDelegate <NSObject>

- (void)emailLockOutVC:(EmailLockOutVC*)vc onGoBackButtonTapped:(RTEmailLockOutModel*)model;

@end

@interface EmailLockOutVC : RoverTownBaseViewController

@property (nonatomic, weak) id<EmailLockOutVCDelegate> delegate;
@property (nonatomic, assign) BOOL isAbleToGoBack;

@end