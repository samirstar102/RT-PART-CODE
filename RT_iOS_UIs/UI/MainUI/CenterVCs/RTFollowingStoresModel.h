//
//  RTFollowingStoresModel.h
//  RoverTown
//
//  Created by Sonny on 12/2/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

@protocol RTFollowingStoresModelDelegate <NSObject>

-(void)followingStoresSuccess:(NSArray*)stores;
-(void)followingStoresFailure;

@end

#import <Foundation/Foundation.h>

@interface RTFollowingStoresModel : NSObject

-(instancetype)initWithDelegate:(id<RTFollowingStoresModelDelegate>)delegate;
-(void)getFollowingStores;

@property (nonatomic, weak) id<RTFollowingStoresModelDelegate> delegate;

@end
