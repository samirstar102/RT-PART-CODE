//
//  RTPublicProfileTableHeaderView.m
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/15/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTPublicProfileTableHeaderView.h"

#define kIconSpacerFromHorizontal 24
#define kIconSpacerFromTop 16
#define kLabelSpacerFromIcon 8
#define kIconSpacerFromIcon 4
#define kIconDimension 16
#define kEditButtonHeight 40
#define kGrayThickness 2

@interface RTPublicProfileTableHeaderView ()

@property (nonatomic, weak) UIView *grayBackgroundView;
@property (nonatomic, weak) UIImageView *genderImageView;
@property (nonatomic, weak) UILabel *genderLabel;
@property (nonatomic, weak) UIImageView *birthdayImageView;
@property (nonatomic, weak) UILabel *birthdayLabel;
@property (nonatomic, weak) UIImageView *majorImageView;
@property (nonatomic, weak) UILabel *majorLabel;
@property (nonatomic, weak) UIImageView *discountImageView;
@property (nonatomic, weak) UILabel *discountLabel;
@property (nonatomic, weak) UIImageView *commentImageView;
@property (nonatomic, weak) UILabel *commentLabel;
@property (nonatomic, weak) UIImageView *votesImageView;
@property (nonatomic, weak) UILabel *votesLabel;

@property (nonatomic, weak) UIView *grayBottomLine;

@property (nonatomic) UIButton *editProfileButton;

@end

@implementation RTPublicProfileTableHeaderView

- (instancetype)initWithDelegate:(id<RTPUblicProfileHeaderViewDelegate>)delegate {
    self = [super init];
    
    self.delegate = delegate;
    
    UIView *backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor roverTownLightGray]];
    self.grayBackgroundView = backgroundView;
    [self addSubview:self.grayBackgroundView];
    
    UIView *grayView = [[UIView alloc] init];
    [grayView setBackgroundColor:[UIColor lightGrayColor]];
    self.grayBottomLine = grayView;
    [self addSubview:self.grayBottomLine];
    
    UIImageView *genderView = [[UIImageView alloc] init];
    self.genderImageView = genderView;
    [self.grayBackgroundView addSubview:self.genderImageView];
    
    UILabel *genderLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:genderLabel];
    [genderLabel setText:@"Unspecified"];
    self.genderLabel = genderLabel;
    [self.grayBackgroundView addSubview:self.genderLabel];
    
    UIImageView *birthdayView = [[UIImageView alloc] init];
    self.birthdayImageView = birthdayView;
    [self.birthdayImageView setImage:[UIImage imageNamed:@"birthday_icon"]];
    [self.grayBackgroundView addSubview:self.birthdayImageView];
    
    UILabel *birthdayLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:birthdayLabel];
    [birthdayLabel setText:@"Birthday"];
    self.birthdayLabel = birthdayLabel;
    [self.grayBackgroundView addSubview:self.birthdayLabel];
    
    UIImageView *majorView = [[UIImageView alloc] init];
    self.majorImageView = majorView;
    [self.majorImageView setImage:[UIImage imageNamed:@"major_icon"]];
    [self.grayBackgroundView addSubview:self.majorImageView];
    
    UILabel *majorLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:majorLabel];
    [majorLabel setText:@"Major"];
    self.majorLabel = majorLabel;
    [self.grayBackgroundView addSubview:self.majorLabel];
    
    UIImageView *discountView = [[UIImageView alloc] init];
    self.discountImageView = discountView;
    [self.discountImageView setImage:[UIImage imageNamed:@"discounts_added_icon"]];
    [self.grayBackgroundView addSubview:self.discountImageView];
    
    UILabel *discountLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:discountLabel];
    [discountLabel setText:@"0"];
    self.discountLabel = discountLabel;
    [self.grayBackgroundView addSubview:self.discountLabel];
    
    UIImageView *commentView = [[UIImageView alloc] init];
    self.commentImageView = commentView;
    [self.commentImageView setImage:[UIImage imageNamed:@"comments_icon"]];
    [self.grayBackgroundView addSubview:self.commentImageView];
    
    UILabel *commentsLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:commentsLabel];
    [commentsLabel setText:@"0"];
    self.commentLabel = commentsLabel;
    [self.grayBackgroundView addSubview:self.commentLabel];
    
    UIImageView *votesView = [[UIImageView alloc] init];
    self.votesImageView = votesView;
    [self.votesImageView setImage:[UIImage imageNamed:@"upvotes_icon"]];
    [self.grayBackgroundView addSubview:self.votesImageView];
    
    UILabel *votesLabel = [[UILabel alloc] init];
    [self setUpLabelsForView:votesLabel];
    [votesLabel setText:@"0"];
    self.votesLabel = votesLabel;
    [self.grayBackgroundView addSubview:self.votesLabel];
    
    return self;
}

- (instancetype)initForPrivateUserWithDelegate:(id<RTPUblicProfileHeaderViewDelegate>)delegate {
    self = [self initWithDelegate:delegate];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitle:@"EDIT MY PROFILE" forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    editButton.titleLabel.textColor = [UIColor whiteColor];
    [editButton setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    self.editProfileButton = editButton;
    [self.grayBackgroundView addSubview:self.editProfileButton];
    
    return self;
}

- (void)layoutSubviews {
    [self.grayBackgroundView setFrame:self.frame];
    
    [self.genderImageView setFrame:CGRectMake(kIconSpacerFromHorizontal, kIconSpacerFromTop, kIconDimension, kIconDimension)];
    [self.genderImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.genderImageView setClipsToBounds:YES];
    [self.genderLabel sizeToFit];
    if (self.genderImageView.image == nil) {
        [self.genderLabel setFrame:CGRectMake(kIconSpacerFromHorizontal, CGRectGetMaxY(self.genderImageView.frame) - self.genderLabel.frame.size.height, self.genderLabel.frame.size.width, self.genderLabel.frame.size.height)];
    } else {
        [self.genderLabel setFrame:CGRectMake(CGRectGetMaxX(self.genderImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.genderImageView.frame) - self.genderLabel.frame.size.height, self.genderLabel.frame.size.width, self.genderLabel.frame.size.height)];
    }
    
    [self.birthdayImageView setFrame:CGRectMake(kIconSpacerFromHorizontal, CGRectGetMaxY(self.genderImageView.frame) + kIconSpacerFromIcon, kIconDimension, kIconDimension)];
    [self.birthdayImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.birthdayImageView setClipsToBounds:YES];
    [self.birthdayLabel sizeToFit];
    [self.birthdayLabel setFrame:CGRectMake(CGRectGetMaxX(self.birthdayImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.birthdayImageView.frame) - self.birthdayLabel.frame.size.height, self.birthdayLabel.frame.size.width, self.birthdayLabel.frame.size.height)];
    
    [self.majorImageView setFrame:CGRectMake(kIconSpacerFromHorizontal, CGRectGetMaxY(self.birthdayImageView.frame) + kIconSpacerFromIcon, kIconDimension, kIconDimension)];
    [self.majorImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.majorImageView setClipsToBounds:YES];
    
    [self.majorLabel sizeToFit];
    [self.majorLabel setFrame:CGRectMake(CGRectGetMaxX(self.majorImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.majorImageView.frame) - self.majorLabel.frame.size.height, self.majorLabel.frame.size.width, self.majorLabel.frame.size.height)];
    
    [self.discountImageView setFrame:CGRectMake(CGRectGetMidX(self.frame), kIconSpacerFromTop, kIconDimension, kIconDimension)];
    [self.discountImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.discountImageView setClipsToBounds:YES];
    [self.discountLabel sizeToFit];
    [self.discountLabel setFrame:CGRectMake(CGRectGetMaxX(self.discountImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.discountImageView.frame) - self.discountLabel.frame.size.height, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height)];
    
    [self.commentImageView setFrame:CGRectMake(CGRectGetMinX(self.discountImageView.frame), CGRectGetMaxY(self.discountImageView.frame) + kIconSpacerFromIcon, kIconDimension, kIconDimension)];
    [self.commentImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.commentImageView setClipsToBounds:YES];
    [self.commentLabel sizeToFit];
    [self.commentLabel setFrame:CGRectMake(CGRectGetMaxX(self.commentImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.commentImageView.frame) - self.commentLabel.frame.size.height, self.commentLabel.frame.size.width, self.commentLabel.frame.size.height)];
    
    [self.votesImageView setFrame:CGRectMake(CGRectGetMinX(self.discountImageView.frame), CGRectGetMaxY(self.commentImageView.frame) + kIconSpacerFromIcon, kIconDimension, kIconDimension)];
    [self.votesImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.votesImageView setClipsToBounds:YES];
    [self.votesLabel sizeToFit];
    [self.votesLabel setFrame:CGRectMake(CGRectGetMaxX(self.votesImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.votesImageView.frame) - self.votesLabel.frame.size.height, self.votesLabel.frame.size.width, self.votesLabel.frame.size.height)];
    
    CGFloat widthBetweenMajorLabel = CGRectGetMinX(self.votesImageView.frame) - CGRectGetMinX(self.birthdayLabel.frame);
    [self.majorLabel setNumberOfLines:0];
    [self.majorLabel setPreferredMaxLayoutWidth:widthBetweenMajorLabel];
    [self.majorLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.majorLabel sizeToFit];
    [self.majorLabel setFrame:CGRectMake(CGRectGetMaxX(self.majorImageView.frame) + kLabelSpacerFromIcon, CGRectGetMaxY(self.majorImageView.frame) - self.votesLabel.frame.size.height, widthBetweenMajorLabel, CGRectGetHeight(self.majorLabel.frame))];
    
    if (self.editProfileButton) {
        CGFloat totalWidthForButton = self.frame.size.width - 2*kIconSpacerFromHorizontal;
        [self.editProfileButton setFrame:CGRectMake(CGRectGetMinX(self.majorImageView.frame), CGRectGetMaxY(self.frame) - kEditButtonHeight - kLabelSpacerFromIcon, totalWidthForButton, kEditButtonHeight)];
        [self.editProfileButton addTarget:self action:@selector(editTappedByUser) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.grayBottomLine setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, kGrayThickness)];
}

- (void)setGender:(NSString *)gender birthday:(NSString *)birthday major:(NSString *)major discounts:(int)discounts comments:(int)comments votes:(int)votes {
    if ([gender isEqualToString:@""] || gender == nil) {
        [self.genderLabel setText:@"Unspecified"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([gender isEqualToString:@"female"]) {
                [self.genderLabel setText:@"Girl"];
                [self.genderImageView setImage:[UIImage imageNamed:@"female_icon"]];
            } else {
                [self.genderLabel setText:@"Dude"];
                [self.genderImageView setImage:[UIImage imageNamed:@"male_icon"]];
            }

        });
    }
    
    if ([birthday isEqualToString:@""] || birthday == nil) {
        [self.birthdayLabel setText:@"Unspecified"];
    } else {
        [self.birthdayLabel setText:birthday];
    }
    
    if ([major isEqualToString:@""] || major == nil) {
        [self.majorLabel setText:@"Unspecified"];
    } else {
        [self.majorLabel setText:major];
    }
    
    if (discounts == 1) {
        [self.discountLabel setText:[NSString stringWithFormat:@"%i Discount Added", discounts]];
    } else {
        [self.discountLabel setText:[NSString stringWithFormat:@"%i Discounts Added", discounts]];
    }
    
    if (comments == 1) {
        [self.commentLabel setText:[NSString stringWithFormat:@"%i Comment", comments]];
    } else {
        [self.commentLabel setText:[NSString stringWithFormat:@"%i Comments", comments]];
    }
    
    if (votes == 1) {
        [self.votesLabel setText:[NSString stringWithFormat:@"%i Vote", votes]];
    } else {
        [self.votesLabel setText:[NSString stringWithFormat:@"%i Votes", votes]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

-(void)editTappedByUser {
    if (self.delegate != nil) {
        [self.delegate editButtonTapped];
    }
}


-(void)setUpLabelsForView:(UILabel *)label {
    label.textColor = [UIColor roverTownColorDarkBlue];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    [label setBackgroundColor:[UIColor clearColor]];
}

@end
