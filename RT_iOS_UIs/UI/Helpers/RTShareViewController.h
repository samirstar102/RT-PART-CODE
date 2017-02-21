//
//  RTShareViewController.h
//  RoverTown
//
//  Created by Roger Jones Jr on 9/13/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"

@protocol RTShareViewControllerDelegate <NSObject>
- (void)shareViewControllerDone;
@end

typedef NS_ENUM(NSInteger, RTShareType)
{
    RTShareType_Application = 1,
    RTShareType_Discount
};

@interface RTShareViewController : UIViewController
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithShareType:(RTShareType)shareType;
- (instancetype)initWithDiscount:(RTStudentDiscount *) discount;
- (void)showShareViewFromView:(UIView *)parentView;

@property (nonatomic, weak) id<RTShareViewControllerDelegate> delegate;
@end
