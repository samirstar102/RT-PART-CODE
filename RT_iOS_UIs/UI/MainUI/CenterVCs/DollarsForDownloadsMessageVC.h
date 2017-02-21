//
//  DollarsForDownloadsMessageVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DollarsForDownloadsMessageVC;

@protocol DollarsForDownloadsMessageVCDelegate <NSObject>

- (void)dollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc onTermsAndConditionsLinkTappedWithAnimated:(BOOL)animated;
- (void)dollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc onGenerateMyCodeButtonTappedWithAnimated:(BOOL)animated;
- (void)dismissDollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc;

@end

@interface DollarsForDownloadsMessageVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<DollarsForDownloadsMessageVCDelegate> delegate;
-(void)buildForInstructionsWithoutGenerateCode;

@end
