//
//  RTUnfollowAlertViewController.h
//  RoverTown
//
//  Created by Sonny on 10/23/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStore.h"

@protocol RTUnfollowAlertViewControllerDelegate <NSObject>

-(void)unfollowBusinessForDiscount:(RTStore *)discount;
-(void)disableAlertsWithBool:(BOOL)dontAskChecked;
-(void)loadData;
-(void)dismissedUnfollowingAlert;

@end

@interface RTUnfollowAlertViewController : UIViewController

-(id)initWithDiscount:(RTStore *)store;
-(id)initWithDiscount:(RTStore *)store nibName:(NSString *)nib;

@property (nonatomic, weak) id<RTUnfollowAlertViewControllerDelegate>delegate;
@property (nonatomic, weak) RTStore *storeForSegue;

@end
