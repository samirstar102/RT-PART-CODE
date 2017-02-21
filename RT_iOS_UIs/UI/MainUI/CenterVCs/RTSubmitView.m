//
//  RTSubmitView.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitView.h"
#import "RTUIManager.h"
#import "RTSubmitFormView.h"
#import "RTSubmitImageView.h"
#import "RTSubmitSuccessView.h"
#import "UIColor+Config.h"

@interface RTSubmitView()<RTSubmitImageViewDelegate, RTSubmitFormViewDelegate>
@property (nonatomic) UISegmentedControl *segmentControl;
@property (nonatomic) UIView *segmentBackgroundView;
@property (nonatomic) RTSubmitFormView *submitAsFormView;
@property (nonatomic) RTSubmitImageView *submitAsImageView;
@property (nonatomic) RTSubmitSuccessView *submitSuccessView;
@property (nonatomic, weak) id<RTSubmitViewObserver> observer;
@end

@implementation RTSubmitView

- (instancetype)initWithFrame:(CGRect)frame observer:(id<RTSubmitViewObserver>)observer{
    self = [super initWithFrame:frame];
    if (self) {
        _observer = observer;
                
        self.segmentBackgroundView = [[UIView alloc]init];
        [self.segmentBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.segmentBackgroundView];
        
        _segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"Take A Photo", @"Submit A Form"]];
        [_segmentControl setTintColor:[UIColor roverTownColor6DA6CE]];
        [_segmentControl addTarget:self
                            action:@selector(action:)
                  forControlEvents:UIControlEventValueChanged];
        [_segmentControl setSelectedSegmentIndex:0];
        
        [_segmentBackgroundView addSubview:self.segmentControl];
    }
    return self;
}

- (void)layoutSegmentControl {
    [self.segmentBackgroundView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 40)];
    [self.segmentControl setFrame:CGRectMake(10, 5, CGRectGetWidth(self.bounds) - 20 , 30)];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutSegmentControl];
    
    CGRect contentFrame = CGRectMake(10, CGRectGetHeight(self.segmentBackgroundView.frame) + 10, CGRectGetWidth(self.bounds) - 20, CGRectGetHeight(self.bounds));
    if (!self.submitAsImageView) {
        self.submitAsImageView  = [[RTSubmitImageView alloc]initWithFrame:contentFrame delegate:self];
        [self addSubview:self.submitAsImageView];
    }
    
    if (!self.submitAsFormView) {
        self.submitAsFormView  = [[RTSubmitFormView alloc]initWithFrame:contentFrame delegate:self];
        [self addSubview:self.submitAsFormView];
        [self.submitAsFormView setAlpha:0.0];
    }
    
}

- (void)action:(UISegmentedControl *)control {
    if (control.selectedSegmentIndex == 0) {
        [self.observer imageViewIsShowing];
        [self showImageView];
    } else if (control.selectedSegmentIndex == 1) {
        [self.observer imageViewIsNotShowing];
        [self showFormView];
    }
}

- (void)showImageView {
    if (![self isImageViewVisible]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.submitAsFormView setAlpha:0.0];
            [self.submitSuccessView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [self.submitAsImageView setAlpha:1.0];
            } completion:^(BOOL finished) {
                [self adjustContentSize];
            }];
        }];
    }
}


- (void)showFormView {
    if (![self isFormViewVisible]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.submitAsImageView setAlpha:0.0];
            [self.submitSuccessView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [self.submitAsFormView setAlpha:1.0];
            } completion:^(BOOL finished) {
                [self adjustContentSize];

            }];
        }];
    }
}

- (BOOL)isImageViewVisible {
    if (self.submitAsImageView.alpha == 1.0) {
        return YES;
        
    }
    return NO;
}

- (BOOL)isFormViewVisible {
    if (self.submitAsFormView.alpha == 1.0) {
        return YES;
    }
    return NO;
}
- (void)stopSpinner {
    if ([self isFormViewVisible]) {
        [self.submitAsFormView hideSpinner];
    } else {
        [self.submitAsImageView hideSpinner];
    }
}

#pragma mark - public

- (void)showSelectedImage:(UIImage *)image {
    [self.submitAsImageView setSelectedImage:image];
}
- (void)showSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopSpinner];
            if(!self.submitSuccessView) {
            self.submitSuccessView = [[RTSubmitSuccessView alloc]initWithFrame:self.submitAsImageView.frame];
            [self.submitSuccessView setAlpha:0.0];
            [self addSubview:self.submitSuccessView];
        }
        [UIView animateWithDuration:0.3f animations:^{
            if ([self isFormViewVisible]) {
                [self.submitAsFormView setAlpha:0.0];
                [self.submitAsFormView clear];
            }else {
                [self.submitAsImageView setAlpha:0.0];
                [self.submitAsImageView cancelButtonTapped];
                [self.submitAsFormView clear];
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [self.submitSuccessView setAlpha:1.0];
            } completion:^(BOOL finished) {
                [self adjustContentSize];
            }];
        }];
    });
    [self.submitAsImageView setSelectedImage:nil];
}

- (void)showFail {
    [self stopSpinner];
    [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:@"Something went wrong" descriptionText:@"There was an error submitting your discount"];
}

#pragma mark - RTSubmitImageViewDelegate

- (void)imageViewTapped {
    [self.observer imageViewTapped];
}

- (void)imageSendTappedWithImage:(UIImage *)image businessName:(NSString *)businessName discount:(NSString *)discount finePrint:(NSString *)finePrint {
    [self.submitAsImageView showSpinner];
    [self.observer sendTappedWithImage:image businessName:businessName businessAddress:nil discount:discount finePrint:finePrint option:nil];
}

-(void)adjustContentSize {
    if ([self isFormViewVisible]) {
        [self setContentSizeWithHeight:CGRectGetHeight(self.submitAsFormView.frame)];
    }else if ([self isImageViewVisible]) {
        [self setContentSizeWithHeight:CGRectGetHeight(self.submitAsImageView.frame)];
    }else {
        [self setContentSizeWithHeight:CGRectGetHeight(self.submitSuccessView.frame)];
    }
    [self setScrollEnabled:YES];
}

- (void)setContentSizeWithHeight:(CGFloat)height {
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.segmentBackgroundView.frame) + height + 120);
}

- (void)disableScrolling {
    [self setContentOffset:CGPointZero animated:YES];
    [self setScrollEnabled:NO];
}

- (void)additionalOptionsStarted {
    if (self.observer != nil) {
        [self.observer additionalsStarted];
    }
}

- (void)additionalOptionsEnded {
    if (self.observer != nil) {
        [self.observer additionalsEnded];
    }
}

#pragma mark - RTSubmitFormViewDelegate

- (void)formSendTappedWithName:(NSString *)name address:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint option:(NSString *)option {
    [self.submitAsFormView showSpinner];
    [self.observer sendTappedWithImage:nil businessName:name businessAddress:address discount:discount finePrint:finePrint option:option];
}

@end
