//
//  RTBottomToolbarView.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTBottomViewDelegate <NSObject>
- (void)userSelectedItemAtIndex:(NSInteger)index;
@end

@interface RTBottomToolbarView : UIView
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items delegate:(id<RTBottomViewDelegate>)delegate;
- (void)setSelectedIndex:(NSInteger)index;
@end
