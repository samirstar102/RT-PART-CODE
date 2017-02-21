//
//  RTDiscountCommentModel.h
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

@class RTStore;

@protocol RTDiscountCommentModelDelegate <NSObject>

-(void)commentsFailed;
-(void)commentsSuccess:(NSArray *)comments;
-(void)commentsUpdateSuccess:(NSArray *)comments;
-(void)activitiesFailed;
-(void)activitiesSuccess:(NSArray *)activities;
-(void)storeSuccessful:(RTStore*)store;

@end

#import <Foundation/Foundation.h>
#import "RTStudentDiscount.h"
#import "RTDiscountCommentView.h"

@interface RTDiscountCommentModel : NSObject <RTDiscountCommentViewDelegate>

-(instancetype)initWithStudentDiscount:(RTStudentDiscount*)studentDiscount;
-(instancetype)initWithDelegate:(id<RTDiscountCommentModelDelegate>)delegate;
-(void)getComments;
-(void)getActivities;
-(void)updateCommentsFromAction;
-(void)refreshCommentsFromPost;
-(void)getStoreByStoreId:(NSInteger)storeId;
-(void)updateActivities;
@property (nonatomic) int storeId;
@property (nonatomic) int discountId;
@property (nonatomic) NSMutableArray *commentsArray;
@property (nonatomic) NSMutableArray *activitiesArray;
@property (nonatomic) BOOL maxReachedForComments;
@property (nonatomic) BOOL maxReachedForActivities;

-(NSString *)discountStoreName;
-(NSString *)discountTitle;
-(UIImageView *)storeLogo;
-(UIImageView *)discountImage;
-(BOOL)isFollowing;
@property (nonatomic, readonly) RTStudentDiscount *discount;


@property (nonatomic, weak) id<RTDiscountCommentModelDelegate> delegate;

@end
