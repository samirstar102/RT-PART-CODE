//
//  RTFollowerReward.h
//  RoverTown
//
//  Created by Robin Denis on 8/10/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStore.h"
#import "RTStatistics.h"
#import "RTCode.h"

@interface RTFollowerReward : NSObject

@property (nonatomic) int rewardId;
@property (nonatomic, retain) NSString *rewardDiscription;
@property (nonatomic, retain) NSString *fine_print;
@property (nonatomic, retain) NSString *image;
@property (nonatomic) BOOL list_hidden;
@property (nonatomic) BOOL tap_to_redeem;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *days_valid;
@property (nonatomic, retain) NSString *messageFromBusinessOwner;
@property (nonatomic, retain) RTCode *code;
@property (nonatomic, retain) NSDate *awardedDate;
@property (nonatomic, retain) RTStore *store;
@property (nonatomic, retain) RTStatistics *statistics;

@end
