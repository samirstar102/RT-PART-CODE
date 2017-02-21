//
//  RTSubmitViewController.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

@class RTSubmitViewController;

#import <UIKit/UIKit.h>
#import "CenterViewControllerBase/CenterViewControllerBase.h"

@protocol RTSubmitViewControllerDelegate <NSObject>

-(void)updateBonesFromSubmit;

@end

@interface RTSubmitViewController : CenterViewControllerBase

@property (nonatomic, weak) id<RTSubmitViewControllerDelegate>delegate;

@end
