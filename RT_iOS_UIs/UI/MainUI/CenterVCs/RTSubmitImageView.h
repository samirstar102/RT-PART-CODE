//
//  RTSubmitViewWithImage.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitContentViewBase.h"

@protocol RTSubmitImageViewDelegate <NSObject>
- (void)imageViewTapped;
- (void)adjustContentSize;
- (void)disableScrolling;
- (void)imageSendTappedWithImage:(UIImage *)image businessName:(NSString *)businessName discount:(NSString *)discount finePrint:(NSString *)finePrint;
- (void)additionalOptionsStarted;
- (void)additionalOptionsEnded;
@end

@interface RTSubmitImageView : RTSubmitContentViewBase
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RTSubmitImageViewDelegate>)delegate;
- (void)setSelectedImage:(UIImage *)selectedImage;
- (void)cancelButtonTapped;
@end
