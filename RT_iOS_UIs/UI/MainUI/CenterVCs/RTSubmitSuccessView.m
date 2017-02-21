//
//  RTSubmitSuccessView.m
//  RoverTown
//
//  Created by Roger Jones Jr on 11/8/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitSuccessView.h"
#import "UIColor+Config.h"

@interface RTSubmitSuccessView()
@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIImageView *topImageView;
@property (nonatomic) UITextView *topTextView;
@property (nonatomic) UIImageView *middleImageView;
@property (nonatomic) UITextView *middleTextView;
@property (nonatomic) UIImageView *bottomImageView;
@property (nonatomic) UITextView *bottomTextView;

@end

@implementation RTSubmitSuccessView
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self.backgroundView.layer setCornerRadius:3.0];
        
        self.topImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success"]];
        self.topTextView = [[UITextView alloc]init];
        [self.topTextView setText:@"Discount submited.\nThanks for your help!"];
        [self.topTextView setTextAlignment:NSTextAlignmentCenter];
        [self.topTextView setFont:[self.topTextView.font fontWithSize:20.0]];
        [self.topTextView setTextColor:[UIColor roverTownColorGreen]];
        [self.topTextView setUserInteractionEnabled:NO];
        
        self.middleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"review_icon"]];
        self.middleTextView = [[UITextView alloc]init];
        self.middleTextView.text = @"Your discount will be posted as an unverified discount for students to find and use.";
        [self.middleTextView setUserInteractionEnabled:NO];
        [self.middleTextView setFont:[self.topTextView.font fontWithSize:14.0]];
        [self.middleTextView setTextColor:[UIColor roverTownColorDarkBlue]];
        
        self.bottomImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"verified_icon_large"]];
        self.bottomTextView = [[UITextView alloc]init];
        self.bottomTextView.text = @"If students use your discount succesfully, it becames a verified discount!";
        [self.bottomTextView setUserInteractionEnabled:NO];
        [self.bottomTextView setFont:self.middleTextView.font];
        [self.bottomTextView setTextColor:[UIColor roverTownColorGreen]];
        
        [self addSubview:self.backgroundView];
        [self.backgroundView addSubview:self.topImageView];
        [self.backgroundView addSubview:self.topTextView];
        [self.backgroundView addSubview:self.middleImageView];
        [self.backgroundView addSubview:self.middleTextView];
        [self.backgroundView addSubview:self.bottomImageView];
        [self.backgroundView addSubview:self.bottomTextView];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.topImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - 30, 20, 60, 60)];
    [self.topTextView sizeToFit];
    [self.topTextView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.topTextView.frame)/2, CGRectGetMaxY(self.topImageView.frame) + 10, CGRectGetWidth(self.topTextView.frame), CGRectGetHeight(self.topTextView.frame))];
    
    CGRect middleImageFrame = CGRectMake(CGRectGetMinX(self.topTextView.frame) - 30, CGRectGetMaxY(self.topTextView.frame), 60, 30);
    [self.middleTextView setFrame:CGRectMake(CGRectGetMaxX(middleImageFrame) + 15, CGRectGetMaxY(self.topTextView.frame), CGRectGetWidth(self.topTextView.frame), 50)];
    [self.middleTextView sizeToFit];
    middleImageFrame.origin.y = CGRectGetMidY(self.middleTextView.frame) - CGRectGetHeight(middleImageFrame)/2;
    [self.middleImageView setFrame:middleImageFrame];
    
    CGRect bottomTextViewFrame = self.middleTextView.frame;
    bottomTextViewFrame.origin.y = CGRectGetMaxY(self.middleTextView.frame);
    [self.bottomTextView setFrame:bottomTextViewFrame];
    
    [self.bottomImageView setFrame:CGRectMake(CGRectGetMidX(middleImageFrame) - 25, CGRectGetMidY(self.bottomTextView.frame) - 25, 50, 50)];
    
    CGRect frame = self.backgroundView.frame;
    frame.size.height = CGRectGetMaxY(self.bottomTextView.frame) + 20;
    [self.backgroundView setFrame:frame];
}


@end
