//
//  ProfileAboutMeVC.h
//  
//
//  Created by Robin Denis on 8/17/15.
//
//

@class ProfileAboutMeVC;

@protocol ProfileAboutMeVCDelegate <NSObject>

- (void)profileAboutMeVC:(ProfileAboutMeVC *)vc onEditAboutMeWithAnimated:(BOOL)animated;

@end

@interface ProfileAboutMeVC : UIViewController

@property (nonatomic, weak) id<ProfileAboutMeVCDelegate> delegate;

@end
