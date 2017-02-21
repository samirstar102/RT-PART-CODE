//
//  IndividualBadgeVC.h
//  RoverTown
//
//  Created by Robin Denis on 7/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTBadge.h"

@class IndividualBadgeVC;

@protocol IndividualBadgeVCDelegate <NSObject>

- (void)individualBadgeVC:(IndividualBadgeVC *)vc onShare:(RTBadge *)badge;
- (void)individualBadgeVC:(IndividualBadgeVC *)vc onExit:(RTBadge *)badge;

@end

@interface IndividualBadgeVC : UIViewController

@property (nonatomic, weak) id<IndividualBadgeVCDelegate> delegate;
@property (nonatomic, retain) RTBadge *badge;

@end
