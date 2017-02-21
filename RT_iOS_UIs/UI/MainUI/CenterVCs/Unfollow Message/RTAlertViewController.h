//
//  RTAlertViewController.h
//  RoverTown
//
//  Created by Sonny on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStore.h"

@protocol RTAlertViewControllerDelegate <NSObject>

- (void) doNotAskButtonChecked: (BOOL)doNotAsk;
- (void) unfollowConfirmed;

@end

@interface RTAlertViewController : UIViewController
- (id)initWithStore:(RTStore *)store;

@property (nonatomic, weak) id<RTAlertViewControllerDelegate> delegate;

@end
