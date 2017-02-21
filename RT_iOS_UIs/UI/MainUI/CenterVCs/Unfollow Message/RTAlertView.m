//
//  RTAlertView.m
//  RoverTown
//
//  Created by Sonny on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTAlertView.h"

#define kAlertTitleSpacer 16
#define kAlertButtonWidth 120
#define kAlertButtonHeight 40

@interface RTAlertView ()

@property (nonatomic, weak) UILabel *alertTitleLabel;
@property (nonatomic, weak) UILabel *alertMessageLabel;
@property (nonatomic, weak) UILabel *radioTitleLabel;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *confirmButton;
@property (nonatomic, weak) UIButton *doNotAskButton;
@property (nonatomic, weak) UIView *alertView;

@end

@implementation RTAlertView

- (instancetype)initWithFrame:(CGRect)frame alertTitle:(NSString *)alertTitle alertMessage:(NSString *)alertMessage delegate:(id<RTAlertViewProtocol>)delegate {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:0.85];
        
        UIView *alertView = [[UIView alloc] init];
        self.alertView = alertView;
        [self.alertView setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        
        
        self.delegate = delegate;
        
        UILabel *alertTitleLabel = [[UILabel alloc] init];
        self.alertTitleLabel = alertTitleLabel;
        [self.alertTitleLabel setText:alertTitle];
        [self.alertTitleLabel setNumberOfLines:1];
        [self.alertTitleLabel setFont:[UIFont fontWithName:self.alertTitleLabel.font.fontName
                                                      size:16]];
        [self addSubview:self.alertTitleLabel];
        
        UILabel *alertMessageLabel = [[UILabel alloc] init];
        self.alertMessageLabel = alertMessageLabel;
        [self.alertMessageLabel setText:alertMessage];
        [self.alertMessageLabel setNumberOfLines:3];
        [self.alertMessageLabel setFont:[UIFont fontWithName:self.alertMessageLabel.font.fontName
                                                        size:13]];
        [self addSubview:self.alertMessageLabel];
        
        UIButton *doNotAskButton = [[UIButton alloc] init];
        [doNotAskButton setTitle:@"Don't ask me again" forState:UIControlStateNormal];
        self.doNotAskButton = doNotAskButton;
        self.doNotAskButton.titleLabel.font = [UIFont fontWithName:self.doNotAskButton.titleLabel.font.fontName size:14];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        self.cancelButton = cancelButton;
        self.cancelButton.titleLabel.font = [UIFont fontWithName:self.cancelButton.titleLabel.font.fontName size:15];
        
        UIButton *confirmButton = [[UIButton alloc] init];
        [confirmButton setTitle:@"OK" forState:UIControlStateNormal];
        self.confirmButton = confirmButton;
        self.confirmButton.titleLabel.font = [UIFont fontWithName:self.confirmButton.titleLabel.font.fontName size:15];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
    }
    return self;
}

-(void)layoutSubviews {
    // width constraint to add alertView constrained to superView width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.75
                                                      constant:0]];
    // height constraint to add alertView constrained to superView height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.5
                                                      constant:0]];
    // center Alert view inside superView horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    // center Alert view inside superView vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.alertView addSubview:self.alertTitleLabel];
    // constraint the title to the alertview
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.alertTitleLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:0
                                                                constant:32]];
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.alertTitleLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0]];
    
    [self.alertView addSubview:self.alertMessageLabel];
    // constraint the alert message to the alert title
    // constrain top of messageLabel to bottom of titleLabel
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.alertMessageLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertTitleLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:4]];
    // constrain center of messageLabel to alertView center x coordinate
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.alertMessageLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0]];
    // constrain width of messageLabel to 75% of alertView width
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.alertMessageLabel
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.75
                                                                constant:0]];
    
    [self.alertView addSubview:self.doNotAskButton];
    // constraint the do not ask button to the alert message
    // constrain top of do not ask button to bottom of alert message
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.doNotAskButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertMessageLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:4]];
    // constrain center of do not ask button to center of alertView
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.doNotAskButton
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0]];
    
    [self.alertView addSubview:self.cancelButton];
    // constraint the cancel button to the do not ask button
    // constrain cancel button to leading alert View
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:0
                                                                constant:0]];
    // constrain the cancel button to half of the width of the alertView
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.5
                                                                constant:0]];
    
    // constrain the cancel button top to the bottom of the doNotAsk
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.doNotAskButton
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:0
                                                                constant:4]];
    [self.alertView addSubview:self.confirmButton];
    // constraint the confirm button and cancel button to each other width
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.confirmButton
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.cancelButton
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:0]];
    // constrain the confirm button height to cancel button height
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.confirmButton
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.cancelButton
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:0]];
    // constrain the confirm button trailing to alertView trailing
    [self.alertView addConstraint:[NSLayoutConstraint constraintWithItem:self.confirmButton
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.alertView
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:0
                                                                constant:0]];
    
}

- (void)setRTAlertPreferencesForUser
{
    
}

@end
