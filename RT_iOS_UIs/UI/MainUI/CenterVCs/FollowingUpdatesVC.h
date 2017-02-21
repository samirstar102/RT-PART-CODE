//
//  FollowingUpdatesVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"
#import "RTStore.h"

typedef NS_ENUM(NSInteger, RTFollowingViewControllerpage) {
    RTFollowingViewControllerpage_DiscountPage,
    RTFollowingViewControllerpage_ActivityPage,
    RTFollowingViewControllerpage_SubmitPage
};
@interface FollowingUpdatesVC : CenterViewControllerBase
- (void)showPage:(RTFollowingViewControllerpage)page;
@end
