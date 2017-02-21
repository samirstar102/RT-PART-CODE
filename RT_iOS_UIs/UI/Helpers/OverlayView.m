//
//  OverlayView.m
//  RoverTown
//
//  Created by Robin Denis on 19/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "OverlayView.h"

@interface OverlayView ()

@property (nonatomic) CGSize targetSize;

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForFrame;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintForFrame;
@property (nonatomic) UIDeviceOrientation orientation;

@end

@implementation OverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self xibSetup];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self xibSetup];
    return self;
}

- (void)xibSetup {
    self.view = [self loadViewFromNib];
    
    self.view.frame = self.bounds;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.ivFrame.backgroundColor = [UIColor clearColor];
    self.ivFrame.layer.borderColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.8].CGColor;
    self.ivFrame.layer.borderWidth = 2;
    
    [self addSubview:self.view];
    
    self.orientation = UIDeviceOrientationPortrait;
   
}

- (void)registerOrientationNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)unregisterOrientationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIView *)loadViewFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil] objectAtIndex:0];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

- (void)setTargetImageSize:(CGSize)size {
    self.targetSize = size;
    
    [self refreshFrame];
}

- (void) orientationChanged:(NSNotification *)notification
{
    NSLog(@"orientation changed");

    self.orientation = [[UIDevice currentDevice] orientation];

    [self refreshFrame];

}

- (void)refreshFrame {
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        CGFloat ratio = 1;
        if (self.targetSize.height != 0)
            ratio = self.targetSize.width / self.targetSize.height;
        
        if (ratio == 0)
            ratio = 1;
        
        self.widthConstraintForFrame.constant = self.view.frame.size.width;
        self.heightConstraintForFrame.constant = self.view.frame.size.width / ratio;
        if (self.heightConstraintForFrame.constant >= self.view.frame.size.height * 0.8) {
            self.heightConstraintForFrame.constant = self.view.frame.size.height * 0.8;
            self.widthConstraintForFrame.constant = self.heightConstraintForFrame.constant * ratio;
        }
        
    }
    else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight) {
        
        CGFloat ratio = 1;
        if (self.targetSize.height != 0)
            ratio = self.targetSize.height / self.targetSize.width;
        
        if (ratio == 0)
            ratio = 1;
        
        self.widthConstraintForFrame.constant = self.view.frame.size.width;
        self.heightConstraintForFrame.constant = self.view.frame.size.width / ratio;
        if (self.heightConstraintForFrame.constant >= self.view.frame.size.height * 0.8) {
            self.heightConstraintForFrame.constant = self.view.frame.size.height * 0.8;
            self.widthConstraintForFrame.constant = self.heightConstraintForFrame.constant * ratio;
        }
    }
    
    [self layoutIfNeeded];
    
}

@end
