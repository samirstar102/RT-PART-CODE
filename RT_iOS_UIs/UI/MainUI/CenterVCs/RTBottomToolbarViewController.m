//
//  RTBottomToolbarViewController.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTBottomToolbarViewController.h"


@interface RTBottomToolbarViewController ()<RTBottomViewDelegate>
@property (nonatomic, weak) id<RTBottomToolbarViewControllerDelegate> delegate;
@end

@implementation RTBottomToolbarViewController

- (instancetype)initWithDelegate:(id<RTBottomToolbarViewControllerDelegate>)delegate superView:(UIView *)superView {
    if (self = [super init]) {
        _delegate = delegate;
        self.view = superView;
        CGRect frame = CGRectMake(0, CGRectGetHeight(superView.frame) - 105, CGRectGetWidth(superView.frame), 45);
        self.toolbarView = [[RTBottomToolbarView alloc]initWithFrame:frame items:@[@"Discounts", @"Activity", @"Submit"] delegate:self];
        [superView addSubview:self.toolbarView];
    
    }
    return self;
}

#pragma mark public
- (void)setSelectedIndex:(NSInteger)index {
    [self.toolbarView setSelectedIndex:index];
}

#pragma  mark RTBottomViewDelegate
- (void)userSelectedItemAtIndex:(NSInteger)index {
    [self.delegate userSelectedBottomButtonAtIndex:index];
}
@end
