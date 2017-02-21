//
//  RTPublicProfileViewModel.h
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTPublicUser;

@protocol RTPublicProfileViewModelDelegate <NSObject>

-(void)publicProfileReturned:(RTPublicUser*)publicUser;
-(void)publicProfileFailed;

@end

@interface RTPublicProfileViewModel : NSObject

-(instancetype)initWithUserId:(int)userId andDelegate:(id<RTPublicProfileViewModelDelegate>)delegate;

@property (nonatomic, weak) id<RTPublicProfileViewModelDelegate> delegate;

@end
