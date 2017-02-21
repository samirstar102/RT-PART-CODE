//
//  RTPublicProfileTopView.m
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTPublicProfileTopView.h"
#import "UIColor+Utilities.h"

#define kProfilePictureHorizontalSpacer 16
#define kProfilePictureVerticalSpacer 8
#define kUsernameSpacer 24
#define kLabelSpacer 4
#define kBoneViewWidth 80
#define kGrayLineThickness 2

@interface RTPublicProfileTopView ()

@property (nonatomic) UIView            *topWhiteView;
@property (nonatomic) UIImageView       *profileImageView;
@property (nonatomic) UIImage           *profileImage;
@property (nonatomic) UILabel           *userNameLabel;
@property (nonatomic) UILabel           *schoolNameLabel;
@property (nonatomic) UILabel           *boneLabel;
@property (nonatomic) UILabel           *badgeLabel;
@property (nonatomic) UIView            *boneView;
@property (nonatomic) UIView            *badgeView;
@property (nonatomic, weak) UIImageView *boneImageView;
@property (nonatomic, weak) UIImageView *badgeImageView;
@property (nonatomic) int               boneCount;
@property (nonatomic) int               badgeCount;
@property (nonatomic) UIView            *grayLineView;

@end

@implementation RTPublicProfileTopView

- (instancetype)initWithDelegate:(id<RTPublicProfileTopViewDelegate>)delegate {
    self = [super init];
    
    self.viewDelegate = delegate;
    UIView *topView = [[UIView alloc] init];
    [topView setBackgroundColor:[UIColor whiteColor]];
    self.topWhiteView = topView;
    [self addSubview:self.topWhiteView];
    
    UIView *grayView = [[UIView alloc] init];
    [grayView setBackgroundColor:[UIColor lightGrayColor]];
    self.grayLineView = grayView;
    [self addSubview:self.grayLineView];
    
    UIImageView *profileImageView = [[UIImageView alloc] init];
    self.profileImageView = profileImageView;
    [self.topWhiteView addSubview:self.profileImageView];
    
    [self setProfilePicture:[UIImage imageNamed:@"person_default_icon"]];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = [UIColor roverTownColorDarkBlue];
    [nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setText:@"Username"];
    self.userNameLabel = nameLabel;
    [self.topWhiteView addSubview:self.userNameLabel];
    
    UILabel *schoolLabel = [[UILabel alloc] init];
    schoolLabel.textColor = [UIColor roverTownColorDarkBlue];
    [schoolLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [schoolLabel setBackgroundColor:[UIColor clearColor]];
    [schoolLabel setText:@"School"];
    self.schoolNameLabel = schoolLabel;
    [self.topWhiteView addSubview:self.schoolNameLabel];
    
    UIView *boneView = [[UIView alloc] init];
    self.boneView = boneView;
    [self.topWhiteView addSubview:self.boneView];
    
    UIImage *boneIcon = [UIImage imageNamed:@"bones_icon"];
    UIImageView *boneImageView = [[UIImageView alloc] initWithImage:boneIcon];
    self.boneImageView = boneImageView;
    [self.boneView addSubview:self.boneImageView];
    
    UILabel *boneLabel = [[UILabel alloc] init];
    boneLabel.textAlignment = NSTextAlignmentRight;
    boneLabel.text = [NSString stringWithFormat:@"0"];
    boneLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    boneLabel.textColor = [UIColor roverTownColorDarkBlue];
    [boneLabel setBackgroundColor:[UIColor clearColor]];
    self.boneLabel = boneLabel;
    [self.boneView addSubview:self.boneLabel];
    
    UIView *badgeView = [[UIView alloc] init];
    self.badgeView = badgeView;
    [self.topWhiteView addSubview:self.badgeView];
    
    UIImage *badgeIcon = [UIImage imageNamed:@"badges_icon"];
    UIImageView *badgeImageView = [[UIImageView alloc] initWithImage:badgeIcon];
    self.badgeImageView = badgeImageView;
    [self.badgeView addSubview:self.badgeImageView];
    
    UILabel *badgeLabel = [[UILabel alloc] init];
    badgeLabel.textAlignment = NSTextAlignmentRight;
    badgeLabel.text = [NSString stringWithFormat:@"0"];
    badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    badgeLabel.textColor = [UIColor roverTownColorDarkBlue];
    [badgeLabel setBackgroundColor:[UIColor clearColor]];
    self.badgeLabel = badgeLabel;
    [self.badgeView addSubview:self.badgeLabel];
    
    return self;
}

- (void)layoutSubviews {
    [self.topWhiteView setFrame:self.frame];
    
    CGFloat profileHeight = CGRectGetHeight(self.frame) - 2*kProfilePictureVerticalSpacer;
    CGFloat heightDifferenceForProfile = CGRectGetHeight(self.frame) - profileHeight;
    
    [self.profileImageView setFrame:CGRectMake(kProfilePictureHorizontalSpacer, heightDifferenceForProfile/2, profileHeight, profileHeight)];
    
    [self.userNameLabel sizeToFit];
    [self.userNameLabel setFrame:CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + kProfilePictureHorizontalSpacer, kUsernameSpacer, CGRectGetWidth(self.userNameLabel.frame), CGRectGetHeight(self.userNameLabel.frame))];
    
    CGFloat remainingWidth = CGRectGetWidth(self.frame) - CGRectGetMaxX(self.profileImageView.frame) - kProfilePictureHorizontalSpacer;
    [self.schoolNameLabel setNumberOfLines:0];
    [self.schoolNameLabel setPreferredMaxLayoutWidth:remainingWidth];
    [self.schoolNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.schoolNameLabel sizeToFit];
    [self.schoolNameLabel setFrame:CGRectMake(CGRectGetMinX(self.userNameLabel.frame), CGRectGetMaxY(self.userNameLabel.frame) + kLabelSpacer, remainingWidth, CGRectGetHeight(self.schoolNameLabel.frame))];
    
    CGFloat heightDifference = CGRectGetMaxY(self.topWhiteView.frame) - CGRectGetMaxY(self.schoolNameLabel.frame);
    CGFloat boneLabelHeight = heightDifference - 2*kProfilePictureVerticalSpacer;
    
    [self.boneView setFrame:CGRectMake(CGRectGetMinX(self.schoolNameLabel.frame), CGRectGetMaxY(self.schoolNameLabel.frame) + heightDifference/2 - boneLabelHeight/2, kBoneViewWidth, boneLabelHeight)];
    [self.badgeView setFrame:CGRectMake(CGRectGetMaxX(self.boneView.frame) + kLabelSpacer, CGRectGetMinY(self.boneView.frame), kBoneViewWidth, boneLabelHeight)];
    
    self.boneView.layer.cornerRadius = 3.0f;
    self.boneView.layer.borderWidth = 1.5f;
    self.boneView.layer.borderColor = [UIColor roverTownColor6DA6CE].CGColor;
    
    self.badgeView.layer.cornerRadius = 3.0f;
    self.badgeView.layer.borderWidth = 1.5f;
    self.badgeView.layer.borderColor = [UIColor roverTownColor6DA6CE].CGColor;
    
    CGFloat iconHeight = 0.6 * boneLabelHeight;
    
    [self.boneImageView setFrame:CGRectMake(2*kLabelSpacer, CGRectGetHeight(self.boneView.frame)/2 - iconHeight/2, iconHeight, iconHeight)];
    [self.boneImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.boneImageView setClipsToBounds:YES];
    
    [self.badgeImageView setFrame:CGRectMake(2*kLabelSpacer, CGRectGetHeight(self.badgeView.frame)/2 - iconHeight/2, iconHeight, iconHeight)];
    [self.badgeImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.badgeImageView setClipsToBounds:YES];
    
    [self.boneLabel sizeToFit];
    [self.boneLabel setFrame:CGRectMake(self.boneView.frame.size.width - CGRectGetWidth(self.boneLabel.frame) - 2*kLabelSpacer, (self.boneView.frame.size.height)/2 - CGRectGetHeight(self.boneLabel.frame)/2, CGRectGetWidth(self.boneLabel.frame), CGRectGetHeight(self.boneLabel.frame))];
    
    [self.badgeLabel sizeToFit];
    [self.badgeLabel setFrame:CGRectMake(self.badgeView.frame.size.width - CGRectGetWidth(self.badgeLabel.frame) - 2*kLabelSpacer, (self.badgeView.frame.size.height)/2 - CGRectGetHeight(self.badgeLabel.frame)/2, CGRectGetWidth(self.badgeLabel.frame), CGRectGetHeight(self.badgeLabel.frame))];
    [self.grayLineView setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, kGrayLineThickness)];
    [super layoutSubviews];
}

- (void)setUserName:(NSString *)userName school:(NSString *)school bones:(int)bones badges:(int)badges {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.userNameLabel setText:userName];
        if ([school isEqualToString:@""] || school == nil) {
            [self.schoolNameLabel setText:@"No school listed"];
        } else {
            [self.schoolNameLabel setText:school];
        }
        self.boneCount = bones;
        [self.boneLabel setText:[NSString stringWithFormat:@"%i", self.boneCount]];
        self.badgeCount = badges;
        [self.badgeLabel setText:[NSString stringWithFormat:@"%i", self.badgeCount]];
        [self setNeedsLayout];
    });
}

- (void)setProfileImageFromUrl:(NSString *)profileUrl {
    if ([profileUrl isEqualToString:@""] || profileUrl == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profileImage = [UIImage imageNamed:@"person_default_icon"];
            [self setProfilePicture:self.profileImage];
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *profileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profileUrl]];
            UIImage *profile = [UIImage imageWithData:profileData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImage = profile;
                [self setProfilePicture:self.profileImage];
            });
        });

    }
}

- (void)setProfilePicture:(UIImage *)profilePicture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.profileImage = [self getRoundedRectImageFromImage:profilePicture onReferenceView:self.profileImageView withCornerRadius:self.profileImageView.frame.size.width/2];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileImageView setImage:self.profileImage];
            self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.profileImageView setClipsToBounds:YES];
            [self setNeedsLayout];
        });

    });
}

- (UIImage *)getRoundedRectImageFromImage:(UIImage *)image onReferenceView:(UIImageView*)imageView withCornerRadius:(float)cornerRadius {
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 0.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:cornerRadius] addClip];
    [image drawInRect:imageView.bounds];
    UIImage *finalProfileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalProfileImage;
}

@end
