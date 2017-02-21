//
//  DollarsForDownloadsCodeVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTReferral.h"

@class DollarsForDownloadsCodeVC;

@protocol DollarsForDownloadsCodeVCDelegate <NSObject>

- (void)dollarsForDownloadsCodeVC:(DollarsForDownloadsCodeVC *)vc onTermsAndConditionsLinkTappedWithAnimated:(BOOL)animated;
- (void)dollarsForDownloadsCodeVC:(DollarsForDownloadsCodeVC *)vc onShareButtonTappedWithReferralCode:(RTReferral *)referral;

@end

@interface DollarsForDownloadsCodeVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) RTReferral *referral;

@property (nonatomic, weak) id<DollarsForDownloadsCodeVCDelegate> delegate;

@end
