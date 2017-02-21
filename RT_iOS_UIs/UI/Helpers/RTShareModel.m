//
//  RTShareModel.m
//  RoverTown
//
//  Created by Roger Jones Jr on 9/20/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTShareModel.h"
#import "RTServerManager.h"
#import "RTUserContext.h"
#import "RTLocationManager.h"

@interface RTShareModel()
@property (nonatomic) RTShareType type;
@property (nonatomic, readwrite) NSString *shareURL;
@property (nonatomic, readwrite) NSString *shareContent;
@property (nonatomic) RTStudentDiscount *discountToShare;
@end

@implementation RTShareModel
- (instancetype)initWithShareType:(RTShareType)shareType delegate:(id<RTSharViewModelDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _type = shareType;
        [self setup];
    }
    
    self.platform = @"iOS";
    return self;
}

- (void)setDiscountToShare:(RTStudentDiscount *)discountToShare {
    _discountToShare = discountToShare;
    [self setup];
}

- (void)setup {
    switch (self.type) {
        case RTShareType_Application:
            [self.delegate setTitleText:@"Share RoverTown via"];
            self.shareURL = @"http://rovertown.com/apps";
            self.shareContent = [NSString stringWithFormat:@"Get the FREE RoverTown Student Discount app now to find hundreds of local discounts.\n%@", self.shareURL];
            break;
        case RTShareType_Discount:
            [self.delegate setTitleText:@"Share discount via"];
            self.shareURL =  [NSString stringWithFormat:@"http://rover.town/%d", self.discountToShare.discountId];
            NSString *discountStoreName = self.discountToShare.store.name;
            NSString *discountDescription = self.discountToShare.discountDescription;
            self.shareContent = [NSString stringWithFormat:@"Check out this discount at %@:\n%@\n%@",discountStoreName, discountDescription, self.shareURL];
            break;
    }
}

- (void)sendShare{
    if (self.type == RTShareType_Application) {
        [[RTServerManager sharedInstance] shareAppWithPlatform:self.platform complete:^(BOOL success, RTAPIResponse *response) {
            [[RTUserContext sharedInstance] updateUserInfoWithCompletion:^(BOOL success, RTAPIResponse *response) {
            }];
        }];
    }
    else if (self.type == RTShareType_Discount) {
        int discountId = self.discountToShare.discountId;
        int storeId = self.discountToShare.store.storeId;
        double longitude = [RTLocationManager sharedInstance].longitude;
        double latitude = [RTLocationManager sharedInstance].latitude;
        
        [[RTServerManager sharedInstance] shareDiscountWithDiscountId:discountId storeId:storeId platform:self.platform longitude:longitude latitude:latitude complete:^(BOOL success, RTAPIResponse *response) {
            int oldBoneCount = [RTUserContext sharedInstance].boneCount;
            int oldBadgeCount = [RTUserContext sharedInstance].badgeTotalCount;
            [[RTUserContext sharedInstance] updateUserInfoWithCompletion:^(BOOL success, RTAPIResponse *response) {
                if (success) {
                    RTUserContext *currentUser = [RTUserContext sharedInstance];
                    BOOL boneDiff = NO;
                    BOOL badgeDiff = NO;
                    int updatedBoneCount = currentUser.boneCount;
                    int updatedBadgeCount = currentUser.badgeTotalCount;
                    if (updatedBadgeCount > oldBadgeCount) {
                        badgeDiff = YES;
                    }
                    if (updatedBoneCount > oldBoneCount) {
                        boneDiff = YES;
                    }
                    [self.delegate boneCountUpdated:boneDiff badgeCountUpdated:badgeDiff];
                }
            }];
        }];
    }
}


@end
