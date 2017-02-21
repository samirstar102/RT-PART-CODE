//
//  RTSubmitView.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSubmitFormView.h"

@protocol RTSubmitViewObserver <NSObject>
- (void)imageViewTapped;
- (void)sendTappedWithImage:(UIImage *)image businessName:(NSString *)name businessAddress:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint option:(NSString *)option;
- (void)additionalsStarted;
- (void)additionalsEnded;
- (void)imageViewIsShowing;
- (void)imageViewIsNotShowing;

@end

@interface RTSubmitView : UIScrollView
- (instancetype)initWithFrame:(CGRect)frame observer:(id<RTSubmitViewObserver>)observer;
- (void)showSelectedImage:(UIImage *)image;
- (UIImage *)selectedImage;
- (void)showSuccess;
- (void)showFail;
@end
