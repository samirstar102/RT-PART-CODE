//
//  RTShareModel.h
//  RoverTown
//
//  Created by Roger Jones Jr on 9/20/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTShareViewController.h"
#import "RTStudentDiscount.h"

@protocol RTSharViewModelDelegate <NSObject>
- (void)setTitleText:(NSString *)titleText;
- (void)boneCountUpdated:(BOOL)boneDiff badgeCountUpdated:(BOOL)badgeDiff;

@end

@interface RTShareModel : UIView
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShareType:(RTShareType)shareType delegate:(id<RTSharViewModelDelegate>)delegate;
- (void)setDiscountToShare:(RTStudentDiscount *)discountToShare;
- (void)sendShare;

@property (nonatomic) NSString* platform;
@property (nonatomic, readonly) NSString *shareContent;
@property (nonatomic, readonly) NSString *shareURL;
@property (nonatomic, weak) id<RTSharViewModelDelegate> delegate;
@end
