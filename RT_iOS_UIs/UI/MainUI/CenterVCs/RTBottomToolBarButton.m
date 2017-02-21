//
//  RTBottomToolBarButton.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTBottomToolBarButton.h"
#import "UIColor+Config.h"

@interface RTBottomToolBarButton()
@property (nonatomic) UILabel *label;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *deselectedView;

@end

@implementation RTBottomToolBarButton
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title delegate:(id<RTBottomToolBarButtonDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc]init];
        [_label setText:title];
        [_label sizeToFit];
        [_label setFont:[_label.font fontWithSize:14]];
        [_label setTextColor:[UIColor whiteColor]];
        [self addSubview:_label];
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:title]];
        [self addSubview:_imageView];

        _deselectedView = [[UIView alloc]initWithFrame:self.bounds];
        [_deselectedView setBackgroundColor:[UIColor whiteColor]];
        [_deselectedView setAlpha:0.0];
        [self addSubview:_deselectedView];
        
        [self setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    }
    return self;
}

- (void)layoutSubviews {
    [_label setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(_label.frame)/2 + 20, 10, CGRectGetWidth(_label.frame), 25)];
    [_imageView setFrame:CGRectMake(CGRectGetMinX(_label.frame) - 17, 15, 12, 12)];
    [_deselectedView setFrame:self.bounds];
}

#pragma mark public
-(void)deselected {
    [UIView animateWithDuration:0.1 animations:^{
        [self.label setAlpha:0.5];
        [self.imageView setAlpha:0.5];
    }];
}

- (void)selected {
    [UIView animateWithDuration:0.1 animations:^{
        [self.label setAlpha:1.0];
        [self.imageView setAlpha:1.0];
    }];
}

@end
