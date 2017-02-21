//
//  RTPublicProfileViewController.h
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTPublicProfileViewModel.h"
#import "CenterViewControllerBase.h"

@protocol RTPublicProfileViewControllerDelegate <NSObject>

-(void)editEnabled;

@end

@interface RTPublicProfileViewController : CenterViewControllerBase

-(id)initWithUserId:(int)userId;
-(id)initForPrivateUser;

@property (nonatomic, weak) id<RTPublicProfileViewControllerDelegate> delegate;

@end
