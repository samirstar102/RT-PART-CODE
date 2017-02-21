//
//  ProfileEditVC.h
//  RoverTown
//
//  Created by Robin Denis on 8/16/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileEditVC;

@protocol ProfileEditVCDelegate <NSObject>

- (void)profileEditVC:(ProfileEditVC *)vc onSaveProfileWithAnimated:(BOOL)animated;

@end

@interface ProfileEditVC : UIViewController

@property (nonatomic, weak) id<ProfileEditVCDelegate> delegate;

@end
