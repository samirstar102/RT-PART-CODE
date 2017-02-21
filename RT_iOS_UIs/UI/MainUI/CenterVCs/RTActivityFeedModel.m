//
//  RTActivityFeedModel.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivityFeedModel.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "RTActivity.h"
#import "RTModelBridge.h"
#import "RTStudentDiscount.h"

#define kActivitiesLimit 10

@interface RTActivityFeedModel()
@property (nonatomic) int numberOfActivities;
@property (nonatomic) int maxActivities;
@property (nonatomic, weak) id<RTActivityFeedModelDelegate>delegate;
@property (nonatomic) BOOL maxReachedForActivities;
@property (nonatomic) BOOL maxReachedForStoreActivities;
@property (nonatomic) BOOL maxReachedForUserActivities;

@end

@implementation RTActivityFeedModel
- (instancetype)initWithDelegate:(id<RTActivityFeedModelDelegate>)delegate {
    if (self = [super init]) {
        self.numberOfActivities = 0;
        self.maxActivities = kActivitiesLimit;
        _delegate = delegate;
        _activitiesArray = [NSMutableArray array];
        self.maxReachedForActivities = NO;
        self.maxReachedForStoreActivities = NO;
        self.maxReachedForUserActivities = NO;
    }
    return self;
}

- (RTServerManager *)serverManager {
    return [RTServerManager sharedInstance];
}


- (void)getActivities {
    if (self.storeId) {
        [self getActivitiesForStore:self.storeId];
    } else if (self.userId) {
        [self getActivitiesForUserId:self.userId];
    } else {
        if (!self.maxReachedForActivities) {
            double longitude = [RTLocationManager sharedInstance].longitude;
            double latitude = [RTLocationManager sharedInstance].latitude;
            [[RTServerManager sharedInstance] getActivitiesFrom:self.numberOfActivities withLimit:kActivitiesLimit atLongitude:longitude andLatitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
                if (success) {
                    NSArray *activities = [response.jsonObject objectForKey:@"activity"];
                    NSMutableArray *activitiesArray = [NSMutableArray array];
                    for (NSDictionary *activityDictionary in activities) {
                        RTActivity * activity = [[RTActivity alloc]initWithJSON:activityDictionary];
                        activity.isBusinessActivity = NO;
                        [activitiesArray addObject:activity];
                    }
                    if (activitiesArray.count < kActivitiesLimit) {
                        self.maxReachedForActivities = YES;
                    }
                    [self.activitiesArray addObjectsFromArray:activitiesArray];
                    self.numberOfActivities = (int)[self.activitiesArray count];
                    self.maxActivities = self.numberOfActivities + kActivitiesLimit;
                    [self.delegate activitiesSucess:[self.activitiesArray copy]];
                }else {
                    [self.delegate activitiesFailed];
                }
            }];
        } else {
            [self.delegate activitiesSucess:nil];
        }
    }
}

- (void)getActivitiesForStore:(NSString *)store {
    
    if (self.maxReachedForStoreActivities) {
        [self.delegate activitiesSucess:nil];
    } else {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        [[RTServerManager sharedInstance] getStoreActivitiesForStore:self.storeId atLongitude:longitude andLatitude:latitude fromStart:self.numberOfActivities toLimit:kActivitiesLimit complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                NSArray *activities = [response.jsonObject objectForKey:@"activity"];
                NSMutableArray *activitiesArray = [NSMutableArray array];
                for (NSDictionary *activityDictionary in activities) {
                    RTActivity *activity = [[RTActivity alloc] initWithJSON:activityDictionary];
//                    activity.logoImage = nil;
//                    activity.logoString = nil;
//                    activity.isBusinessActivity = YES;
                    [activitiesArray addObject:activity];
                }
                if (activitiesArray.count < kActivitiesLimit) {
                    self.maxReachedForStoreActivities = YES;
                }
                [self.activitiesArray addObjectsFromArray:activitiesArray];
                [self.delegate activitiesSucess:[self.activitiesArray copy]];
                self.numberOfActivities = (int)[self.activitiesArray count];
                self.maxActivities = self.numberOfActivities + kActivitiesLimit;
            } else {
                [self.delegate activitiesFailed];
            }
        }];
    }
}

- (void)getActivitiesForUserId:(int)userId {
    if (self.maxReachedForUserActivities) {
        [self.delegate activitiesSucess:nil];
    } else {
        [[RTServerManager sharedInstance] getUserActivitiesForUserId:self.userId fromStart:self.numberOfActivities toLimit:kActivitiesLimit complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                NSArray *activities = [response.jsonObject objectForKey:@"activity"];
                NSMutableArray *userActivities = [NSMutableArray array];
                for (NSDictionary *activityDict in activities) {
                    RTActivity *activity = [[RTActivity alloc] initWithJSON:activityDict];
                    [userActivities addObject:activity];
                }
                if (userActivities.count < kActivitiesLimit) {
                    self.maxReachedForUserActivities = YES;
                }
                [self.activitiesArray addObjectsFromArray:userActivities];
                self.numberOfActivities = (int)[self.activitiesArray count];
                self.maxReachedForActivities = self.numberOfActivities + kActivitiesLimit;
                [self.delegate activitiesSucess:[self.activitiesArray copy]];
            } else {
                [self.delegate activitiesFailed];
            }
        }];
    }
}

- (void)getStoreById:(NSInteger)storeId {
    [[RTServerManager sharedInstance] getStore:[NSString stringWithFormat:@"%ld",storeId] complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSDictionary *dicStore = [[response jsonObject] objectForKey:@"store"];
            RTStore *store = [RTModelBridge getStoreWithDictionary:dicStore];
            [self.delegate storeRetrieved:store];
        }
    }];

}

- (void)retrieveDiscountWithDiscountId:(NSInteger)discountID andStoreId:(NSInteger)storeId {
    [[RTServerManager sharedInstance] getDiscount:[NSString stringWithFormat:@"%ld",discountID] forStore:[NSString stringWithFormat:@"%ld",storeId] complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            RTStudentDiscount *discount = [[RTStudentDiscount alloc] initWithJSON:[response jsonObject]];
            [self.delegate discountRetrieved:discount];
        } else {
            
        }
    }];
}


@end
