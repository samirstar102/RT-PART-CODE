//
//  RTStoryboardmanager.h
//  RoverTown
//
//  Created by Robin Denis on 18/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTDefine.h"

@interface RTStoryboardManager : NSObject

DEFINE_SINGLETON

- (UIViewController *)getViewControllerWithIdentifierFromStoryboard:(NSString *)viewControllerIdentifier storyboardName:(NSString *)storyboardName;
- (UIViewController *)getViewControllerInitial:(NSString *)storyboardName;

@end
