//
//  RTRedeemDiscountView.m
//  RoverTown
//
//  Created by Roger Jones Jr on 8/4/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTRedeemDiscountView.h"
#import "NSDate+Utilities.h"
#import "RTUIManager.h"
#import "UIColor+Config.h"
#import <AudioToolbox/AudioToolbox.h>

#define kItemSpacer  10
#define kFollowButtonHeight 40
#define kFollowButtonWidth 300

#define IS_IPHONE_4_OR_4S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5_OR_5S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface RTRedeemDiscountView () <UITextViewDelegate>
@property (weak, nonatomic) UIImageView *businessLogoImageView;
@property (weak, nonatomic) UIImageView *barCodeImageView;
@property (weak, nonatomic) UIButton *followButton;
@property (weak, nonatomic) UIButton *doneButton;
@property (weak, nonatomic) UIButton *notAcceptedButton;
@property (nonatomic) UILabel *redeemedTimeLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) UILabel *storeNameLabel;
@property (weak, nonatomic) UILabel *extraTextLabel;
@property (weak, nonatomic) UITextView *finePrintTextView;
@property (weak, nonatomic) UIImageView *animationImageView1;
@property (weak, nonatomic) UIImageView *animationImageView2;
@property (nonatomic) NSTimer *animationTimer;
@property (nonatomic) UIView *studentIdView;
@property (nonatomic) BOOL following;
@property (nonatomic) UIImage *barCode;

@property (nonatomic) BOOL isTapToRedeem;

@end

@implementation RTRedeemDiscountView

-(instancetype)initWithFrame:(CGRect)frame logo:(UIImageView *)logo storeName:(NSString *)storeName description: (NSString *)description finePrint:(NSString *)finePrint barCode:(UIImage *)barCode following:(BOOL)following tapToRedeem:(BOOL)tapToRedeem delegate:(id<RTRedeemDiscountViewDelegate>)delegate{
    
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.isTapToRedeem = NO;
        self.businessLogoImageView = logo;
        [self addSubview:self.businessLogoImageView];
        
        UILabel *storNameLabel = [[UILabel alloc]init];
        self.storeNameLabel = storNameLabel;
        [self.storeNameLabel setText:storeName];
        [self.storeNameLabel setNumberOfLines:1];
        [self.storeNameLabel setFont:[UIFont fontWithName:self.storeNameLabel.font.fontName size:16]];
        [self addSubview:self.storeNameLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc]init];
        self.descriptionLabel = descriptionLabel;
        [self.descriptionLabel setText:description];
        [self.descriptionLabel setNumberOfLines:5];
        [self.descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [self.descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.descriptionLabel setFont:[UIFont fontWithName:self.descriptionLabel.font.fontName size:14]];
        
        [self addSubview:self.descriptionLabel];
        
        UITextView *finePrintView = [[UITextView alloc]init];
        self.finePrintTextView = finePrintView;
        self.finePrintTextView.delegate = self;
        [self.finePrintTextView setText:finePrint];
        self.finePrintTextView.editable = NO;
        [self.finePrintTextView setFont:[UIFont fontWithName:self.finePrintTextView.font.fontName size:14]];
        [self.finePrintTextView setUserInteractionEnabled:YES];
        [self addSubview:self.finePrintTextView];
        
        UILabel *redeemedTimeLabel = [[UILabel alloc]init];
        self.redeemedTimeLabel = redeemedTimeLabel;
        [self.redeemedTimeLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.redeemedTimeLabel setNumberOfLines:0];
        [self.redeemedTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.redeemedTimeLabel];
        
        UIButton *doneButton = [[UIButton alloc]init];
        self.doneButton = doneButton;
        [self.doneButton addTarget:self.delegate action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
        
        self.barCode = barCode;
        self.following = following;
        if (tapToRedeem) {
            self.isTapToRedeem = YES;
            [self setupForTapToRedeem];
        } else {
            self.isTapToRedeem = NO;
            //[self switchToRedeem];
        }
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

-(void)setupForTapToRedeem {
    UIImageView *animationView1 = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"redeem_tap1"]];
    UIImageView *animationView2 = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"redeem_tap2"]];
    self.animationImageView1 = animationView1;
    self.animationImageView2 = animationView2;
    [self addSubview:animationView1];
    [self addSubview:animationView2];
    
    [self.doneButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.doneButton addTarget:self.delegate action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [RTUIManager applyCancelRedeemButtonStyle:self.doneButton];
    
    [self.redeemedTimeLabel setText:@"Tap your phone to the beacon near the cash register to redeem this student discount."];
}

- (void)switchToRedeem {
    [UIView animateWithDuration:0.35 animations:^{
        [self setAlpha:0];
    }];
    [self setupForRedeem];
    [UIView animateWithDuration:0.35 animations:^{
        [self setAlpha:1];
    }];
}

- (void)setupForRedeem {
    if (self.animationImageView1) {
        [self.animationImageView2 setHidden:YES];
        [self.animationImageView1 setHidden:YES];
        self.animationImageView1 = nil;
        self.animationImageView2 = nil;
        [self stopTapAnimation];
    }
    
    UIImageView *barCodeView = [[UIImageView alloc]initWithImage:self.barCode];
    self.barCodeImageView = barCodeView;
    [self addSubview:self.barCodeImageView];
    
    UILabel *extraText = [[UILabel alloc]init];
    [extraText setNumberOfLines:2];
    [extraText setTextAlignment:NSTextAlignmentCenter];
    [extraText setText:@"Show your phone to the cashier. \n Turn phone sideways to show student ID"];
    if (IS_IPHONE_5_OR_5S) {
        [extraText setFont:[UIFont systemFontOfSize:12.0f]];
    }
    [extraText sizeToFit];
    self.extraTextLabel = extraText;
    [self addSubview:self.extraTextLabel];
    
    UIButton *notAccepted = [[UIButton alloc]init];
    self.notAcceptedButton = notAccepted;
    [self.notAcceptedButton setTitle:@"Discount not accepted? Tap here." forState:UIControlStateNormal];
    [self.notAcceptedButton addTarget:self.delegate action:@selector(notAcceptedTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.notAcceptedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self addSubview:self.notAcceptedButton];
    
    UIButton *follow = [[UIButton alloc]init];
    self.followButton = follow;
    [RTUIManager applyFollowForUpdatesButtonStyle:self.followButton];
    [self.followButton addTarget:self.delegate action:@selector(followButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self setFollowButtonEnabled:self.following];
    [self addSubview:self.followButton];
    
    [self.doneButton setTitle:@"I'm done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self.delegate action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [RTUIManager applyRedeemDiscountButtonStyle:self.doneButton];
    [self.doneButton.titleLabel setFont:self.followButton.titleLabel.font];
    
    [self layoutIfNeeded];
    
}

- (void)layoutSubviews {
    
    if (IS_IPHONE_5_OR_5S) {
        [self.businessLogoImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - 40, 20, 75, 75)];
    } else if (IS_IPHONE_4_OR_4S) {
        [self.businessLogoImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - 30, 20, 60, 60)];
    } else {
        [self.businessLogoImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - 50, 20, 100, 100)];
    }
    [self.businessLogoImageView setBackgroundColor:[UIColor clearColor]];
    
    [self.storeNameLabel sizeToFit];
    [self.storeNameLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.storeNameLabel.frame)/2 , CGRectGetMaxY(self.businessLogoImageView.frame) + kItemSpacer, CGRectGetWidth(self.storeNameLabel.frame), CGRectGetHeight(self.storeNameLabel.frame))];
    
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMaxY(self.storeNameLabel.frame) + kItemSpacer, kFollowButtonWidth, CGRectGetHeight(self.descriptionLabel.frame))];
    if (IS_IPHONE_5_OR_5S) {
        [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    }
    
    [self.finePrintTextView sizeThatFits:CGSizeMake(kFollowButtonWidth, 80)];
    CGRect finePrintFrame = self.finePrintTextView.frame;
    finePrintFrame.size.height = self.finePrintTextView.contentSize.height;
    
    if (CGRectGetHeight(finePrintFrame) > 80 ) {
        if (IS_IPHONE_5_OR_5S) {
            finePrintFrame.size.height = 60;
            [self.finePrintTextView setTextAlignment:NSTextAlignmentLeft];
        }
        finePrintFrame.size.height = 80;
        [self.finePrintTextView setTextAlignment:NSTextAlignmentLeft];
    } else {
        [self.finePrintTextView setTextAlignment:NSTextAlignmentCenter];
    }
    
    //ROGER: SEE BELOW, HEIGHT IS STATICALLY SET RIGHT NOW BECAUSE CGRectGetHeight(self.finePrintTextView.frame) SUCKS
    
    [self.finePrintTextView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.finePrintTextView.frame)/2, CGRectGetMaxY(self.descriptionLabel.frame) , CGRectGetWidth(self.descriptionLabel.frame), CGRectGetHeight(finePrintFrame))];
    
    //[self.finePrintTextView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.finePrintTextView.frame)/2, CGRectGetMaxY(self.descriptionLabel.frame) , CGRectGetWidth(self.finePrintTextView.frame), CGRectGetHeight(self.finePrintTextView.frame))];
    
    CGRect imgeFrame;
    if (self.animationImageView1) {
        [self.animationImageView1 sizeToFit];
        [self.animationImageView2 sizeToFit];
        [self.animationImageView1 setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.animationImageView1.frame)/2, CGRectGetMaxY(self.finePrintTextView.frame) + kItemSpacer, CGRectGetWidth(self.animationImageView1.frame), CGRectGetHeight(self.animationImageView1.frame))];
        [self.animationImageView2 setFrame:self.animationImageView1.frame];
        imgeFrame = self.animationImageView1.frame;
        [self startTapAnimation];
        [self.redeemedTimeLabel sizeToFit];
        [self.redeemedTimeLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMaxY(imgeFrame) + kItemSpacer, kFollowButtonWidth, CGRectGetHeight(self.redeemedTimeLabel.frame))];
        [self.doneButton setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMaxY(self.bounds) - kFollowButtonHeight  - kItemSpacer * 3, kFollowButtonWidth, kFollowButtonHeight)];
    } else {
        [self.barCodeImageView sizeToFit];
        
        if (IS_IPHONE_5_OR_5S) {
            NSLog(@"You have detected that it's an iPhone5");
            [self.barCodeImageView setFrame:CGRectMake((CGRectGetMidX(self.bounds) - CGRectGetWidth(self.barCodeImageView.frame)/2) + 10, CGRectGetMaxY(self.finePrintTextView.frame) + kItemSpacer, CGRectGetWidth(self.barCodeImageView.frame) - 15, CGRectGetHeight(self.barCodeImageView.frame) - 15)];
            imgeFrame = self.barCodeImageView.frame;
        } else if (IS_IPHONE_4_OR_4S) {
            
        } else {
            [self.barCodeImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.barCodeImageView.frame)/2, CGRectGetMaxY(self.finePrintTextView.frame) + kItemSpacer, CGRectGetWidth(self.barCodeImageView.frame), CGRectGetHeight(self.barCodeImageView.frame))];
            imgeFrame = self.barCodeImageView.frame;
        }
        
        //        [self.barCodeImageView setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.barCodeImageView.frame)/2, CGRectGetMaxY(self.finePrintTextView.frame) + kItemSpacer, CGRectGetWidth(self.barCodeImageView.frame), CGRectGetHeight(self.barCodeImageView.frame))];
        //        imgeFrame = self.barCodeImageView.frame;
        
        [self.redeemedTimeLabel setText:@"Redeeming Discount"];
        [self.redeemedTimeLabel sizeToFit];
        [self.redeemedTimeLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMaxY(imgeFrame) + kItemSpacer, kFollowButtonWidth, CGRectGetHeight(self.redeemedTimeLabel.frame))];
        [self.doneButton setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMaxY(self.bounds) - kFollowButtonHeight  - kItemSpacer * 3, kFollowButtonWidth, kFollowButtonHeight)];
        [self.extraTextLabel setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.extraTextLabel.frame)/2, CGRectGetMaxY(self.redeemedTimeLabel.frame), CGRectGetWidth(self.extraTextLabel.frame), CGRectGetHeight(self.extraTextLabel.frame))];
        
        [self.notAcceptedButton sizeToFit];
        [self.notAcceptedButton setFrame:CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetWidth(self.notAcceptedButton.frame)/2, CGRectGetMaxY(self.extraTextLabel.frame) + kItemSpacer, CGRectGetWidth(self.notAcceptedButton.frame), 10)];
        
        [self.followButton setFrame:CGRectMake(CGRectGetMidX(self.bounds) - kFollowButtonWidth/2, CGRectGetMinY(self.doneButton.frame) - kFollowButtonHeight -  kItemSpacer *2, kFollowButtonWidth, kFollowButtonHeight)];
    }
    
}

- (void)discountRedeemedAt:(NSDate *)redeemedDate {
    [UIView animateWithDuration:0.3 animations:^{
        [self.redeemedTimeLabel setAlpha:0];
    }];
    NSString *dateString = [redeemedDate stringWithFormat:@"'Redeemed on' M/d/yyyy 'at' hh:mm a"];
    [self.redeemedTimeLabel sizeToFit];
    [self.redeemedTimeLabel setText:dateString];
    [UIView animateWithDuration:0.3 animations:^{
        [self.redeemedTimeLabel setAlpha:1];
    }];
}

- (void)showStudentIdImage:(UIImage *)studentIdImage {
    self.studentIdView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.bounds) + 70, CGRectGetWidth(self.bounds))];
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.studentIdView setBackgroundColor:[UIColor roverTownColor6DA6CE]];

    if (!studentIdImage) {
        studentIdImage = [UIImage imageNamed:@"show_id"];
        [imageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.studentIdView.bounds), CGRectGetHeight(self.studentIdView.bounds))];
        UILabel *instructionsLabel = [[UILabel alloc]init];
        [instructionsLabel setText:@"No Student ID Photo"];
        [instructionsLabel sizeToFit];
        [instructionsLabel setFrame:CGRectMake(CGRectGetMidX(imageView.frame) - CGRectGetWidth(instructionsLabel.frame)/2, CGRectGetMaxY(imageView.frame) + 10, CGRectGetWidth(instructionsLabel.frame), CGRectGetHeight(instructionsLabel.frame))];
        [instructionsLabel setTextColor:[UIColor whiteColor]];
        [self.studentIdView addSubview:instructionsLabel];
    }else {
        if (studentIdImage.size.height > studentIdImage.size.width) {
            self.studentIdView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        [imageView setFrame:self.studentIdView.bounds];
    }
    [imageView setImage:studentIdImage];
    [self.studentIdView addSubview:imageView];
    self.studentIdView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.studentIdView];
}

- (void)removeStudentIdImage{
    [self.studentIdView removeFromSuperview];
    self.studentIdView = nil;
}

- (void)setFollowButtonEnabled:(BOOL)isEnable {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( isEnable ) {
            [self.followButton setImage:[UIImage imageNamed:@"check_icon"] forState:UIControlStateNormal];
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        } else {
            [self.followButton setImage:nil forState:UIControlStateNormal];
            [self.followButton setTitle:@"Follow for updates" forState:UIControlStateNormal];
        }
    });
}

- (void)startTapAnimation {
    [self.animationImageView1 setImage:[UIImage imageNamed:@"redeem_tap1"]];
    [self.animationImageView2 setAlpha:0.0f];
    [self.animationImageView2 setImage:[UIImage imageNamed:@"redeem_tap2"]];
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(tapAnimation) userInfo:nil repeats:YES];
}

- (void)tapAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        if (self.animationImageView1.alpha == 0.0f) {
            [self.animationImageView1 setAlpha:1.0f];
            [self.animationImageView2 setAlpha:0.0f];
        } else {
            [self.animationImageView1 setAlpha:0.0f];
            [self.animationImageView2 setAlpha:1.0f];
        }
    }];
}

- (void)stopTapAnimation {
    if(self.animationTimer ) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
@end
