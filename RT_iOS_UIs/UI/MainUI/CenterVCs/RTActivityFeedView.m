//
//  RTActivityFeedView.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivityFeedView.h"
#import "RTBottomToolbarView.h"
#import "UIColor+Config.h"


@interface RTActivityFeedView ()
@property (nonatomic) UIView *contentView;
@property (nonatomic) RTBottomToolbarView  *bottomToolBarView;
@property (nonatomic) UISegmentedControl *segmentControl;
@property (nonatomic) id<RTActivityFeedViewDelegate>delegate;
@property (nonatomic) UIView *viewOnDisplay;
@property (nonatomic) UIView *segmentControlBackground;
@property (nonatomic) BOOL shouldShowSegmentControl;
@end

@implementation RTActivityFeedView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RTActivityFeedViewDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        [self setBackgroundColor:[UIColor roverTownColor6DA6CE]];
       _segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"Activity", @"Following", @"Settings"]];
        [_segmentControl setTintColor:[UIColor roverTownColor6DA6CE]];
        [_segmentControl addTarget:self
                             action:@selector(action:)
                   forControlEvents:UIControlEventValueChanged];
        
        self.contentView = [[UIView alloc]init];
        [self.contentView setBackgroundColor:[UIColor roverTownColor6DA6CE]];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews {
    if (!self.segmentControlBackground && self.shouldShowSegmentControl) {
        [self.contentView setFrame:CGRectMake(0, kSegmentBackgroundView, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kSegmentBackgroundView - 100)];
        
        self.segmentControlBackground  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSegmentBackgroundView)];
        [self.segmentControlBackground setBackgroundColor:[UIColor whiteColor]];
        [self.segmentControl setFrame:CGRectMake(10, 5, CGRectGetWidth(self.frame) - 20 , 30)];
        [self.segmentControlBackground addSubview:self.segmentControl];
        [self addSubview:self.segmentControlBackground];
        [_segmentControl setSelectedSegmentIndex:0];
        [self action:_segmentControl];
    }
}

- (void)action:(UISegmentedControl *)sender {
    [self.delegate segmentSelectedAtIndex:sender.selectedSegmentIndex];
}

#pragma mark Public

- (void)setSelectedSegment:(NSInteger)index {
    [self.segmentControl setSelectedSegmentIndex:index];
}

- (void)showView:(UIView *)viewToShow shouldShowSegmentControl:(BOOL)shouldShowSegmentControl{
    [UIView animateWithDuration:0.3 animations:^{
        if (!shouldShowSegmentControl && self.segmentControl.alpha == 1.0) {
            [self.contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 100)];
            [self.segmentControlBackground setAlpha:0.0];
        }
        [self.viewOnDisplay setAlpha:0.0];
    }completion:^(BOOL finished) {
        [self.viewOnDisplay removeFromSuperview];
        [viewToShow setAlpha:0.0];
        [UIView animateWithDuration:0.3 animations:^{
            if (shouldShowSegmentControl && self.segmentControlBackground.alpha == 0.0) {
                [self.contentView setFrame:CGRectMake(0, kSegmentBackgroundView, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kSegmentBackgroundView - 100)];
                [self.segmentControlBackground setAlpha:1.0];
            }
            [viewToShow setFrame:self.contentView.bounds];
            [self.contentView addSubview:viewToShow];
            [viewToShow setAlpha:1.0];
        }];
        self.viewOnDisplay = viewToShow;
    }];
    self.shouldShowSegmentControl = shouldShowSegmentControl;
}
@end
