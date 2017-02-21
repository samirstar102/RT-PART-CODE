//
//  RTSubmitVIewBase.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitContentViewBase.h"
#import "UIColor+Config.h"

@interface RTSubmitContentViewBase()
@property (nonatomic) UIImageView *spinnerView;
@property (nonatomic) UIView *blockingView;
@end

@implementation RTSubmitContentViewBase

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setText:@"BE THE HERO YOUR CAMPUS DESERVES"];
        _titleLabel.minimumScaleFactor = 0.0;
        [_titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleLabel.numberOfLines = 1;
        [_titleLabel sizeToFit];
        
        _detailsTextView = [[UITextView alloc]init];
        [_detailsTextView setTextAlignment:NSTextAlignmentCenter];
        [_detailsTextView setUserInteractionEnabled:NO];
        
        [self addSubview: _titleLabel];
        [self addSubview:_detailsTextView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    float titleWidth = CGRectGetWidth(self.titleLabel.frame) > CGRectGetWidth(self.bounds) - 5 ? CGRectGetWidth(self.bounds) - 10 :CGRectGetWidth(self.titleLabel.frame);
    [self.titleLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - titleWidth/2, 10, titleWidth, CGRectGetHeight(self.titleLabel.frame))];
    [self.detailsTextView sizeToFit];
    [self.detailsTextView setFrame:CGRectMake(CGRectGetMidX(self.titleLabel.frame) - CGRectGetWidth(self.titleLabel.frame)/2, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.detailsTextView.frame) + 10)];
}

#pragma mark - actions

#pragma mark - public

- (UITextField *)formTextField {
    UITextField *textField = [[UITextField alloc]init];
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setBackgroundColor:[UIColor colorWithRed:212.0f/255.0f green:229.0f/255.0f blue:239.0f/255.0f alpha:1.0]];
    [textField setTextColor:[UIColor roverTownColorDarkBlue]];
    [textField sizeToFit];
    [textField setFrame:CGRectMake(0, CGRectGetMaxY(textField.frame), CGRectGetWidth(textField.frame), CGRectGetHeight(textField.frame) + 8)];
    [textField.layer setCornerRadius:3.0];
    [textField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [textField.layer setBorderWidth:1.0];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    return textField;
}

- (UILabel *)formLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    [label setText:text];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label sizeToFit];
    [label setFrame:CGRectMake(0, 0, CGRectGetWidth(label.frame) + 5, CGRectGetHeight(label.frame) + 5)];
    return label;
}

- (void)showSpinner {
    if (!self.spinnerView) {
        self.blockingView = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:self.blockingView];
        UIImageView *spinner = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"spinner.png"]];
        [spinner sizeToFit];
        [spinner setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(spinner.frame), CGRectGetMidY(self.bounds) - CGRectGetHeight(spinner.frame), CGRectGetWidth(spinner.frame) *2, CGRectGetHeight(spinner.frame) * 2)];
        
        [self addSubview:spinner];
        self.spinnerView = spinner;
        
        CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
        fullRotation.duration = MAXFLOAT * 0.2;
        fullRotation.removedOnCompletion = YES;
        [self.spinnerView.layer addAnimation:fullRotation forKey:nil];
    }
}


- (void)clear {
    for (UIView *subView in self.subviews) {
        if  ([subView isKindOfClass:[UITextField class]]) {
            [(UITextField *)subView setText:@""];
        }
    }
}

- (void)hideSpinner {
    [self.blockingView removeFromSuperview];
    self.blockingView = nil;
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
}

@end
