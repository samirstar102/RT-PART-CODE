//
//  ProfileQuestionVC.h
//  RoverTown
//
//  Created by Robin Denis on 8/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileQuestionVC;

@protocol ProfileQuestionVCDelegate <NSObject>

- (void) profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onDismiss:(int)indexOfQuestion;
- (void) profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onDone:(int)indexOfQuestion firstName:(NSString *)firstName lastName:(NSString *)lastName gender:(NSString *)gender birthdate:(NSDate *)birthdate major:(NSString *)major;
- (void) profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onFillOutMyProfile:(int)indexOfQuestion;
- (void) profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onPickBirthday:(int)indexOfQuestion;
- (void) profileQuestionVC:(ProfileQuestionVC *)profileQuestionVC onPickMajor:(int)indexOfQuestion;

@end

@interface ProfileQuestionVC : UIViewController

@property (nonatomic, weak) id<ProfileQuestionVCDelegate> delegate;

@end
