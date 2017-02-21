//
//  RTBottomToolbarViewController.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTBottomToolbarView.h"
#import "CenterViewControllerBase.h"

@protocol RTBottomToolbarViewControllerDelegate <NSObject>
- (void)userSelectedBottomButtonAtIndex:(NSInteger)index;
@end

@interface RTBottomToolbarViewController : CenterViewControllerBase
@property (nonatomic) RTBottomToolbarView *toolbarView;

- (instancetype)initWithDelegate:(id<RTBottomToolbarViewControllerDelegate>)delegate superView:(UIView *)superView;
- (void)setSelectedIndex:(NSInteger)index;
@end
