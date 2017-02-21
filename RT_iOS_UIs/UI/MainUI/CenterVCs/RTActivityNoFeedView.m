//
//  RTActivityNoFeedView.m
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/18/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivityNoFeedView.h"

#define kCornerRadiusForNoActivity 2.0f
#define kTitleMessageCornerSpacer 16.0

@interface RTActivityNoFeedView ()

@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *messageLabel;

@end

@implementation RTActivityNoFeedView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title andMessage:(NSString *)message {
    self = [super initWithFrame:frame];
    
    UIView *whiteBackgroundView = [[UIView alloc] initWithFrame:frame];
    [whiteBackgroundView setBackgroundColor:[UIColor whiteColor]];
    self.backgroundView = whiteBackgroundView;
    [self addSubview:self.backgroundView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    self.titleLabel = titleLabel;
    [self.backgroundView addSubview:self.titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = message;
    [messageLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    self.messageLabel = messageLabel;
    [self.backgroundView addSubview:self.messageLabel];
    
    return self;
}

- (void)layoutSubviews {
    self.backgroundView.layer.cornerRadius = kCornerRadiusForNoActivity;
    
    CGFloat maxWidth = CGRectGetWidth(self.frame) - 2*kTitleMessageCornerSpacer;
    [self.titleLabel setNumberOfLines:0];
    [self.titleLabel setPreferredMaxLayoutWidth:maxWidth];
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setFrame:CGRectMake(kTitleMessageCornerSpacer, kTitleMessageCornerSpacer, maxWidth, self.titleLabel.frame.size.height)];
    [self.titleLabel sizeToFit];
    
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel setPreferredMaxLayoutWidth:maxWidth];
    [self.messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.messageLabel setFrame:CGRectMake(kTitleMessageCornerSpacer, CGRectGetMaxY(self.titleLabel.frame) + kTitleMessageCornerSpacer/2, maxWidth, self.messageLabel.frame.size.height)];
    [self.messageLabel sizeToFit];
}

@end
