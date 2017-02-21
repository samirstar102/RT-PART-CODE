//
//  RTShareView.h
//  RoverTown
//
//  Created by Roger Jones Jr on 9/13/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTShareViewDelegate <NSObject>
- (void)cancel;
- (void)message;
- (void)mail;
- (void)twitter;
- (void)facebook;
@end

@interface RTShareView : UIView
@property (nonatomic,weak) id<RTShareViewDelegate> delegate;
- (void)setTitleText:(NSString *)titleText;
@end
