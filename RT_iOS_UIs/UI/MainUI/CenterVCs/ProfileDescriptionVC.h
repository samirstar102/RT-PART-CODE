//
//  ProfileDescriptionVC.h
//  RoverTown
//
//  Created by Robin Denis on 8/16/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileDescriptionVC;

@protocol ProfileDescriptionVCDelegate <NSObject>

- (void)profileDescriptionVC:(ProfileDescriptionVC *)vc onFillOutMyProfileWithAnimated:(BOOL)animated;

@end

@interface ProfileDescriptionVC : UIViewController

@property (nonatomic, weak) id<ProfileDescriptionVCDelegate> delegate;

@end
