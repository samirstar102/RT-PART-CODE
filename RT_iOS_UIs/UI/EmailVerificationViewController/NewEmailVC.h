//
//  NewEmailVC.h
//  RoverTown
//
//  Created by Robin Denis on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RoverTownBaseViewController.h"

@protocol NewEmailVCDelegate <NSObject>
-(void)signUpWithEmail:(NSString *)newEmail;
@end

@interface NewEmailVC : RoverTownBaseViewController
@property (nonatomic, weak) id<NewEmailVCDelegate> delegate;

- (void)dismiss;
- (void)enableButtons;
@end
