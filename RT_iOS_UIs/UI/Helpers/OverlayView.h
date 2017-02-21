//
//  OverlayView.h
//  RoverTown
//
//  Created by Robin Denis on 19/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView

@property (weak, nonatomic) IBOutlet UIView *view;

- (void)setTargetImageSize:(CGSize)size;
- (void)registerOrientationNotification;
- (void)unregisterOrientationNotification;

@end
