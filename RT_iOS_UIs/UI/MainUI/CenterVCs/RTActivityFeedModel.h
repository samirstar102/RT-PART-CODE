//
//  RTActivityFeedModel.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTStore;
@class RTStudentDiscount;

@protocol RTActivityFeedModelDelegate <NSObject>
- (void)activitiesFailed;
- (void)activitiesSucess:(NSArray *)activities;

// to-do, refactor out storeRetrieved and discountRetrieved

- (void)storeRetrieved:(RTStore *)store;
- (void)discountRetrieved:(RTStudentDiscount *)discount;
@end

@interface RTActivityFeedModel : NSObject
- (instancetype)initWithDelegate:(id<RTActivityFeedModelDelegate>)delegate;
- (void)getActivities;
- (void)getActivitiesForStore:(NSString *)store;
- (void)getActivitiesForUserId:(int)userId;

// to-do, refactor out getStoreById and retrieveDiscountWithDiscountId
- (void)getStoreById:(NSInteger)storeId;
- (void)retrieveDiscountWithDiscountId:(NSInteger)discountID andStoreId:(NSInteger)storeId;

@property (nonatomic) NSMutableArray *activitiesArray;
@property (nonatomic) NSString *storeId;
@property (nonatomic) int userId;
@property (nonatomic) BOOL doneGettingActivities;
@end
