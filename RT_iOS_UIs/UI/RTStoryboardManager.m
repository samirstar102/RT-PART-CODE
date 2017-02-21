//
//  RTStoryboardManager.m
//  RoverTown
//
//  Created by Robin Denis on 18/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTStoryboardManager.h"

@implementation RTStoryboardManager

IMPLEMENT_SINGLETON

- (UIViewController *)getViewControllerWithIdentifierFromStoryboard:(NSString *)viewControllerIdentifier storyboardName:(NSString *)storyboardName {
    UIStoryboard *stb = [UIStoryboard storyboardWithName: storyboardName bundle: nil];
    UIViewController *vc = [stb instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    return vc;
}

- (UIViewController *)getViewControllerInitial:(NSString *)storyboardName {
    UIStoryboard *mainView = [UIStoryboard storyboardWithName: storyboardName bundle: nil];
    UIViewController *viewcontroller = [mainView instantiateInitialViewController];
    return viewcontroller;
}

@end
