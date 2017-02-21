//
//  RTActivityFeedView.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kSegmentBackgroundView 40 

@protocol RTActivityFeedViewDelegate <NSObject>
-(void)segmentSelectedAtIndex:(NSInteger)index;

@end

@interface RTActivityFeedView : UIView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RTActivityFeedViewDelegate>)delegate;
- (void)showView:(UIView *)viewToShow shouldShowSegmentControl:(BOOL)shouldShowSegmentControl;
- (void)setSelectedSegment:(NSInteger)index;
@end
