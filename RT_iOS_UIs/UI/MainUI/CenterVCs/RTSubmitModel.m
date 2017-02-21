//
//  RTSubmitModel.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitModel.h"
#import "RTServerManager.h"
#import "AWSManager.h"
#import "RTUserContext.h"
#import "Flurry.h"

@interface RTSubmitModel()
@property (nonatomic) id<RTSubmitModelDelegate> delegate;
@end

@implementation RTSubmitModel
-(instancetype)initWithDelegate:(id<RTSubmitModelDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)submitDiscountWithImage:(UIImage *)image businessName:(NSString *)name businessAddress:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint referralSubject:(NSString *)referralSubject {
    NSString *imageString;
    if (image) {
        [Flurry logEvent:@"user_discount_photo_submit"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"userSuggestedDiscountPhoto.png"];
        imageString = [[[AWSManager alloc]init] uploadFile:filePath contentType:@"image/png" bucketFolderName:kBucketFolderNameForDiscount withPublic:YES];
    }
    [[RTServerManager sharedInstance]suggestDiscountWithBusinessName:name businessAddress:address discount:discount referralSubject:referralSubject finePrint:finePrint photo:imageString complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            if (response.responseCode == 200) {
                [Flurry logEvent:@"user_discount_form_submit"];
                [self.delegate submitSuccessful];
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
                        [self.delegate submitSuccessful];
                    }
                }];
            } else if (response.responseCode == 409) {
                [self.delegate submitLimitReached];
            }
        }else {
            [self.delegate submitFailed];
        }
    }];
}
@end
