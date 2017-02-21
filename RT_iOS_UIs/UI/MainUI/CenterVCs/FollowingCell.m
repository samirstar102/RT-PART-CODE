//
//  FollowingCell.m
//  RoverTown
//
//  Created by Robin Denis on 5/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "FollowingCell.h"
#import "RTUIManager.h"
#import "RTStudentDiscount.h"
#import "RTServerManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RTAlertViewController.h"
#import "RTAlertView.h"

@interface FollowingCell() <RTAlertViewControllerDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UIButton *btnViewBusinessInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblStoreName;
@property (weak, nonatomic) IBOutlet UIButton *unfollowButton;
@property (weak, nonatomic) RTAlertView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation FollowingCell

- (void)bind:(RTStore *)store {
    _store = store;
    
    // set format for ivFrame
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.cornerRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowOpacity = 0.5;
    
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //Initialize store name
    self.lblStoreName.text = store.name;
    
    
    
    //Initialize logo image
    [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:store.logo]
                   placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    self.ivLogo.layer.cornerRadius = kCornerRadiusDefault;
    self.ivLogo.layer.masksToBounds = YES;
    
    self.locationLabel.text = [NSString stringWithFormat:@"%@, %@ %@", store.location.address, store.location.city, store.location.state];
    [self.locationLabel setPreferredMaxLayoutWidth:CGRectGetWidth(self.frame) - CGRectGetWidth(self.ivLogo.frame) - 24];
    self.locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //Initialize View Business Info button
    [self.btnViewBusinessInfo setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    self.unfollowButton.layer.cornerRadius = kCornerRadiusDefault;
    [RTUIManager applyDefaultButtonStyle:self.btnViewBusinessInfo];
    
    //Set Mask
    
    UIBezierPath *maskPath;
    
    CGRect bounds = self.ivFrame.bounds;
    
    maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bounds.origin.x, bounds.origin.y,bounds.size.width, bounds.size.height)
                                     byRoundingCorners:UIRectCornerAllCorners
                                           cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
//    self.ivFrame.layer.mask = maskLayer;
}

+ (CGFloat)heightForCellWithLabelText:(NSString *)labelText {
    return 142;
}

#pragma mark - Actions
- (IBAction)onViewBusinessInfo:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate followingCell:self onViewBusinessInfoButton:self.store];
    }
}

- (IBAction)unfollowButtonTapped:(id)sender {
    if (self.delegate != nil ) {
        [self.delegate followingCell:self onUnFollowForDiscount:self.store];
    }
}

@end
