//
//  RTPublicProfileViewModel.m
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTPublicProfileViewModel.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"

@interface RTPublicProfileViewModel ()

@property (nonatomic) UIImage *profileImage;

@end

@implementation RTPublicProfileViewModel

- (instancetype)initWithUserId:(int)userId andDelegate:(id<RTPublicProfileViewModelDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        [self getPublicUserWithUserId:userId];
    }
    return self;
}

-(void)getPublicUserWithUserId:(int)userId {
    [[RTServerManager sharedInstance] getPublicUserFromUserId:userId complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            RTPublicUser *publicUser = [RTModelBridge getPublicUserFromResponse:response.jsonObject];
            if (self.delegate != nil) {
                [self.delegate publicProfileReturned:publicUser];
            }
        } else {
            if (self.delegate != nil) {
                [self.delegate publicProfileFailed];
            }
        }
    }];
}

@end
