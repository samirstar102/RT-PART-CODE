//
//  RTFollowingStoresModel.m
//  RoverTown
//
//  Created by Sonny on 12/2/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTFollowingStoresModel.h"
#import "RTServerManager.h"
#import "RTModelBridge.h"
#import "RTStore.h"
#import "RTStudentDiscount.h"

@interface RTFollowingStoresModel ()

@property (nonatomic) NSMutableArray *followingStoresArray;

@end

@implementation RTFollowingStoresModel

- (instancetype)initWithDelegate:(id<RTFollowingStoresModelDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.followingStoresArray = [NSMutableArray array];
    }
    return self;
}

- (void)getFollowingStores {
    [[RTServerManager sharedInstance] followingStores:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSArray *stores = [response.jsonObject objectForKey:@"stores"];
            if (stores.count == 0) {
                if (self.delegate != nil) {
                    [self.delegate followingStoresSuccess:nil];
                    [self.delegate followingStoresFailure];
                } 
            } else {
                self.followingStoresArray = [NSMutableArray array];
                NSArray *arrayRet = [RTModelBridge getStoresFromFollowingStores:stores];
                for (RTStudentDiscount *store in arrayRet) {
                    [self.followingStoresArray addObject:store];
                }
                if (self.delegate != nil) {
                    [self.delegate followingStoresSuccess:[self.followingStoresArray copy]];
                }
            }
        } else {
            if (self.delegate != nil) {
                [self.delegate followingStoresFailure];
            }
        }
    }];
}

@end
