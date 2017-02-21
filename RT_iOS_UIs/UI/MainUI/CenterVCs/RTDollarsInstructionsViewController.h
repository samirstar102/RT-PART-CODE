//
//  RTDollarsInstructionsViewController.h
//  RoverTown
//
//  Created by Sonny on 10/23/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTDollarsInstructionsViewController;

@protocol RTDollarsInstructionsViewDelegate

- (void)dollarsForDownloadsInstructionsVC:(RTDollarsInstructionsViewController *)vc onTermsAndConditionsLinkTappedWithAnimated:(BOOL) animated;

@end

@interface RTDollarsInstructionsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<RTDollarsInstructionsViewDelegate> delegate;

@end
