//
//  RTPublicProfileTopView.h
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTPublicProfileTopViewDelegate <NSObject>

@end

@interface RTPublicProfileTopView : UIView

-(instancetype)initWithDelegate:(id<RTPublicProfileTopViewDelegate>)delegate;

-(void)setProfileImage:(UIImage*)profileImage;
-(void)setUserName:(NSString*)userName school:(NSString*)school bones:(int)bones badges:(int)badges;
-(void)setProfileImageFromUrl:(NSString*)profileUrl;
-(void)setProfilePicture:(UIImage*)profilePicture;

@property (nonatomic, weak) id<RTPublicProfileTopViewDelegate> viewDelegate;

@end
