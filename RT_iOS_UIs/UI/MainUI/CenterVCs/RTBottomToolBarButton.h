//
//  RTBottomToolBarButton.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTBottomToolBarButtonDelegate <NSObject>


@end

@interface RTBottomToolBarButton : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title delegate:(id<RTBottomToolBarButtonDelegate>)delegate;
- (void)selected;
- (void)deselected;
@end
