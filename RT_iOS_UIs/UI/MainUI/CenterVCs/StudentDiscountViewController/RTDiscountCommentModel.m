//
//  RTDiscountCommentModel.m
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountCommentModel.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "RTComment.h"
#import "RTActivity.h"
#import "RTStudentDiscount.h"
#import "RTStore.h"
#import "RTModelBridge.h"
#import "RTUserContext.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kCommentsLimit 10
#define kActivitiesLimit 10

@interface RTDiscountCommentModel()

@property (nonatomic) int numberOfComments;
@property (nonatomic) int numberOfActivities;
@property (nonatomic) int maxComments;
@property (nonatomic) int maxActivities;
@property (nonatomic) int commentDifference;
@property (nonatomic) int activityDifference;
@property (nonatomic) int oldCommentsMinimum;
@property (nonatomic) int oldCommentsMaximum;


@property (nonatomic) RTStore *store;
@property (nonatomic, readwrite) RTStudentDiscount *discount;

@end

@implementation RTDiscountCommentModel

- (instancetype)initWithStudentDiscount:(RTStudentDiscount *)studentDiscount {
    if (self = [super init]) {
        RTStudentDiscount *discount = [[RTStudentDiscount alloc] init];
        discount = studentDiscount;
        self.discount = discount;
        self.numberOfComments = 0;
        self.numberOfActivities = 0;
        self.maxComments = kCommentsLimit;
        self.maxActivities = kActivitiesLimit;
        self.commentsArray = [NSMutableArray array];
        self.activitiesArray = [NSMutableArray array];
        self.store = studentDiscount.store;
        self.storeId = self.store.storeId;
        self.discountId = self.discount.discountId;
    }
    return self;
}

- (instancetype)initWithDelegate:(id<RTDiscountCommentModelDelegate>)delegate {
    if (self = [super init]) {
        self.numberOfComments = 0;
        self.delegate = delegate;
        self.commentsArray = [NSMutableArray array];
    }
    return self;
}

- (RTServerManager *)serverManager {
    return [RTServerManager sharedInstance];
}

- (void)getComments {
    if (!self.maxReachedForComments) {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        [[RTServerManager sharedInstance] getDiscountCommentsForStore:self.storeId discount:self.discountId atLongitude:longitude andLatitude:latitude fromStart:self.numberOfComments toLimit:self.maxComments complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                NSArray *comments = [response.jsonObject objectForKey:@"comments"];
                NSMutableArray *commentsArray = [NSMutableArray array];
                for (NSDictionary *commentDict in comments) {
                    RTComment *comment = [[RTComment alloc] initWithJSON:commentDict];
                    if ([RTUserContext sharedInstance].userId == comment.userNumber) {
                        comment.canDelete = YES;
                    } else {
                        comment.canDelete = NO;
                    }
                    [commentsArray addObject:comment];
                }
                int oldCount = (int)[self.commentsArray count];
                self.oldCommentsMinimum = oldCount;
                [self.commentsArray addObjectsFromArray:commentsArray];
                self.numberOfComments = (int)[self.commentsArray count];
                self.oldCommentsMaximum = self.numberOfComments;
                self.commentDifference = self.numberOfComments - oldCount;
                if (self.commentDifference < kCommentsLimit) {
                    self.maxReachedForComments = YES;
                }
                self.maxComments = kCommentsLimit + self.numberOfComments;
                [self.delegate commentsSuccess:[self.commentsArray copy]];
            } else {
                [self.delegate commentsFailed];
            }
        }];
    }
}

-(void)refreshCommentsFromPost {
    self.commentsArray = [NSMutableArray array];
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    [[RTServerManager sharedInstance] getDiscountCommentsForStore:self.storeId discount:self.discountId atLongitude:longitude andLatitude:latitude fromStart:0 toLimit:kCommentsLimit complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSArray *comments = [response.jsonObject objectForKey:@"comments"];
            NSMutableArray *commentsArray = [NSMutableArray array];
            for (NSDictionary *commentDict in comments) {
                RTComment *comment = [[RTComment alloc] initWithJSON:commentDict];
                if ([RTUserContext sharedInstance].userId == comment.userNumber) {
                    comment.canDelete = YES;
                } else {
                    comment.canDelete = NO;
                }
                [commentsArray addObject:comment];
            }
            [self.commentsArray addObjectsFromArray:commentsArray];
            [self.delegate commentsUpdateSuccess:[self.commentsArray copy]];
        }
    }];
}

-(void)updateCommentsFromAction {
    double longitude = [RTLocationManager sharedInstance].longitude;
    double latitude = [RTLocationManager sharedInstance].latitude;
    [[RTServerManager sharedInstance] getDiscountCommentsForStore:self.storeId discount:self.discountId atLongitude:longitude andLatitude:latitude fromStart:self.oldCommentsMinimum toLimit:self.oldCommentsMaximum complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSArray *refreshComments = [response.jsonObject objectForKey:@"comments"];
            NSMutableArray *refreshCommentsArray = [NSMutableArray array];
            for (NSDictionary *commentDict in refreshComments) {
                RTComment *comment = [[RTComment alloc] initWithJSON:commentDict];
                if ([RTUserContext sharedInstance].userId == comment.userNumber) {
                    comment.canDelete = YES;
                } else {
                    comment.canDelete = NO;
                }
                [refreshCommentsArray addObject:comment];
            }
            for (int i = self.oldCommentsMaximum - 1; i >= self.oldCommentsMinimum; i--) {
                [self.commentsArray removeObjectAtIndex:i];
            }
            [self.commentsArray addObjectsFromArray:refreshCommentsArray];
            [self.delegate commentsSuccess:[self.commentsArray copy]];
        }
    }];
}

- (void)getActivities {
    if (!self.maxReachedForActivities) {
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        [[RTServerManager sharedInstance] getDiscountActivitiesForStore:self.storeId discount:self.discountId atLongitude:longitude andLatitude:latitude fromStart:self.numberOfActivities toLimit:self.maxActivities complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                NSArray *activities = [response.jsonObject objectForKey:@"activity"];
                NSMutableArray *activitiesArray = [NSMutableArray array];
                for (NSDictionary *activitiesDict in activities) {
                    RTActivity *activity = [[RTActivity alloc] initWithJSON:activitiesDict];
                    [activitiesArray addObject:activity];
                }
                int oldCount = (int)[self.activitiesArray count];
                [self.activitiesArray addObjectsFromArray:activitiesArray];
                self.numberOfActivities = (int)[self.activitiesArray count];
                self.activityDifference = self.numberOfActivities - oldCount;
                if (self.activityDifference < kActivitiesLimit) {
                    self.maxReachedForActivities = YES;
                }
                [self.delegate activitiesSuccess:[self.activitiesArray copy]];
                self.maxActivities = kActivitiesLimit + self.numberOfActivities;
            } else {
                [self.delegate activitiesFailed];
            }
        }];
    }
}

- (void)updateActivities {
    self.activitiesArray = [NSMutableArray array];
    self.maxReachedForActivities = NO;
    self.numberOfActivities = 0;
    self.maxActivities = kActivitiesLimit;
}

- (void)commentsButtonTapped {
    
}

- (void)onFollowTappedForDiscount:(RTStudentDiscount *)studentDiscount {
    
}

- (void)activityButtonTapped {
    
}

- (UIImageView *)storeLogo {
    UIImageView *logo = [[UIImageView alloc] init];
    [logo sd_setImageWithURL:[NSURL URLWithString:self.discount.store.logo] placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    return logo;
}

- (UIImageView *)discountImage {
    UIImageView *image = [[UIImageView alloc] init];
    [image sd_setImageWithURL:[NSURL URLWithString:self.discount.image] placeholderImage:[UIImage imageNamed:@"placeholder_discountbg"]];
    image.contentMode = UIViewContentModeScaleAspectFill;
    [image setClipsToBounds:YES];
    return image;
}

- (NSString *)discountStoreName {
    return self.discount.store.name;
}

- (NSString *)discountTitle {
    return self.discount.discountDescription;
}

- (BOOL)isFollowing {
    return [self.discount.store.user.following boolValue];
}

- (void)getStoreByStoreId:(NSInteger)storeId {
    [[RTServerManager sharedInstance] getStore:[NSString stringWithFormat:@"%ld",storeId] complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            NSDictionary *dicStore = [[response jsonObject] objectForKey:@"store"];
            RTStore *store = [RTModelBridge getStoreWithDictionary:dicStore];
            [self.delegate storeSuccessful:store];
        }
    }];
}

@end
