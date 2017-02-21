//
//  FollowerRewardsCell.m
//  RoverTown
//
//  Created by Robin Denis on 8/10/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "FollowerRewardsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RTUIManager.h"
#import <CoreLocation/CoreLocation.h>
#import "RTLocationManager.h"

@interface FollowerRewardsCell()
{
    __weak IBOutlet NSLayoutConstraint *heightConstraintForIvBackground;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelFinePrint;
@property (weak, nonatomic) IBOutlet UIView *vwMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelRewardDate;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnRedeemReward;
@property (weak, nonatomic) IBOutlet UIButton *btnViewBusinessInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIView *vwDaysOfWeek;

@end

@implementation FollowerRewardsCell

@synthesize isAnimating;

- (void)bind:(RTStudentDiscount *)reward isExpanded:(BOOL)isExpanded animated:(BOOL)animated {
    
    _reward = reward;
    isAnimating = NO;
    
    //Show or Hide views according to isExpanded
    if( isExpanded ) {
        [heightConstraintForIvBackground setConstant:78.0f];
    } else {
        [heightConstraintForIvBackground setConstant:56.0f];
    }
    
    [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:reward.store.logo]
                   placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    
    self.labelName.text = reward.store.name;
    self.labelDistance.text = [self getDistanceStringToStore:reward.store];
    
    self.labelDescription.numberOfLines = 0;
    self.labelDescription.text = reward.discountDescription;
    
    self.labelFinePrint.text = reward.finePrint;

    //TODO: Correct this
    self.labelRewardDate.text = @"Awarded on 07/25/2015 at 1:15 p.m.";
    self.labelMessage.text = @"\"Thank you for being our loyal follower.\"\n-Bruno\'s Pizza";
    
    CGFloat cornerRadius = kCornerRadiusDefault;
    
    // set format for ivFrame
    
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.cornerRadius = cornerRadius;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.shadowRadius = 3;
    self.ivFrame.layer.shadowOpacity = 0.5;
    
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // set format for ivBackground
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.ivBackground.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CGRect bounds = self.ivBackground.bounds;
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    //self.ivBackground.layer.mask = maskLayer;
    
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, heightConstraintForIvBackground.constant + 20);
    
    [RTUIManager applyRedeemRewardButtonStyle:self.btnRedeemReward];
    [RTUIManager applyDefaultButtonStyle:self.btnViewBusinessInfo];
    [RTUIManager applyDefaultButtonStyle:self.btnShare];
    
    [self setDaysOfWeeks:reward.days_valid];
    
    if( isExpanded ) {
        self.labelFinePrint.hidden = NO;
        self.labelRewardDate.hidden = NO;
        self.vwMessage.hidden = NO;
        self.btnRedeemReward.hidden = NO;
        self.btnViewBusinessInfo.hidden = NO;
        self.btnShare.hidden = NO;
        self.vwDaysOfWeek.hidden = NO;
        
        if (animated) {
            [self.labelFinePrint setAlpha:.0f];
            [self.labelRewardDate setAlpha:.0f];
            [self.vwMessage setAlpha:.0f];
            [self.btnRedeemReward setAlpha:.0f];
            [self.btnViewBusinessInfo setAlpha:.0f];
            [self.btnShare setAlpha:.0f];
            [self.vwDaysOfWeek setAlpha:.0f];
            
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [self.labelFinePrint setAlpha:1.0f];
                    [self.labelRewardDate setAlpha:1.0f];
                    [self.vwMessage setAlpha:1.0f];
                    [self.btnRedeemReward setAlpha:1.0f];
                    [self.btnViewBusinessInfo setAlpha:1.0f];
                    [self.btnShare setAlpha:1.0f];
                    [self.vwDaysOfWeek setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    isAnimating = NO;
                }];
            }];
        }
        else {
            [self layoutIfNeeded];
        }
    }
    else {
        if (animated) {
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                
                [self.labelFinePrint setAlpha:0.0f];
                [self.labelRewardDate setAlpha:0.0f];
                [self.vwMessage setAlpha:0.0f];
                [self.btnRedeemReward setAlpha:0.0f];
                [self.btnViewBusinessInfo setAlpha:0.0f];
                [self.btnShare setAlpha:0.0f];
                [self.vwDaysOfWeek setAlpha:0.0f];
                
            } completion:^(BOOL finished) {
                self.labelFinePrint.hidden = YES;
                self.labelRewardDate.hidden = YES;
                self.vwMessage.hidden = YES;
                self.btnRedeemReward.hidden = YES;
                self.btnViewBusinessInfo.hidden = YES;
                self.btnShare.hidden = YES;
                self.vwDaysOfWeek.hidden = YES;
                
                isAnimating = NO;
            }];
        }
        else {
            [self layoutIfNeeded];
            
            self.labelFinePrint.hidden = YES;
            self.labelRewardDate.hidden = YES;
            self.vwMessage.hidden = YES;
            self.btnRedeemReward.hidden = YES;
            self.btnViewBusinessInfo.hidden = YES;
            self.btnShare.hidden = YES;
            self.vwDaysOfWeek.hidden = YES;
        }
    }
}
- (IBAction)onRedeem:(id)sender {
    if (self.delegate != nil) {
        [self.delegate followerRewardsCell:self onRedeemRewards:self.reward];
    }
}

- (IBAction)onViewBusinessInfo:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate followerRewardsCell:self onViewBusinessInfo:self.reward];
    }
}

- (IBAction)onShare:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate followerRewardsCell:self onShare:self.reward];
    }
}

-(void)setDaysOfWeeks:(NSArray *)daysOfWeeksArray {
    for( int i = 0; i < daysOfWeeksArray.count; i++ ) {
        UIButton *dayOfWeekButton = [[self.vwDaysOfWeek subviews] objectAtIndex:i];
        
        if( [[daysOfWeeksArray objectAtIndex:i] boolValue] == NO ) {
            [dayOfWeekButton setTitleColor:[UIColor colorWithRed:(188.0/255.0f) green:(190.0/255.0f) blue:(192.0/255.0f) alpha:1.0f] forState:UIControlStateNormal];
            [dayOfWeekButton setBackgroundColor:[UIColor colorWithRed:(241.0/255.0f) green:(242.0/255.0f) blue:(242.0/255.0f) alpha:1.0f]];
            
        } else {
            [dayOfWeekButton setTitleColor:[UIColor colorWithRed:(0.0/255.0f) green:(159.0/255.0f) blue:(78.0/255.0f) alpha:1.0f] forState:UIControlStateNormal];
            [dayOfWeekButton setBackgroundColor:[UIColor colorWithRed:(229.0/255.0f) green:(245.0/255.0f) blue:(237.0/255.0f) alpha:1.0f]];
        }
        
        [dayOfWeekButton.layer setBorderColor:[[UIColor colorWithRed:(188.0/255.0f) green:(190.0/255.0f) blue:(192.0/255.0f) alpha:1.0f] CGColor]];
        [dayOfWeekButton.layer setBorderWidth:0.5];
    }
}

+ (CGFloat)heightForCellWithReward:(RTStudentDiscount *)reward isExpanded:(BOOL)isExpanded {
    static UILabel *descriptionLabel = nil, *finePrintLabel = nil, *rewardDateLabel = nil, *messageLabel = nil;
    if (descriptionLabel == nil) {
        descriptionLabel = [[UILabel alloc] init];
    }
    if (finePrintLabel == nil) {
        finePrintLabel = [[UILabel alloc] init];
    }
    if (rewardDateLabel == nil) {
        rewardDateLabel = [[UILabel alloc] init];
    }
    if (messageLabel == nil) {
        messageLabel = [[UILabel alloc] init];
    }
    

    [descriptionLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel setFont:BOLDFONT16];
    descriptionLabel.text = reward.discountDescription;
    [descriptionLabel sizeToFit];
    
    [finePrintLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    finePrintLabel.numberOfLines = 0;
    [finePrintLabel setFont:REGFONT13];
    finePrintLabel.text = reward.finePrint;
    [finePrintLabel sizeToFit];
    
    [rewardDateLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    rewardDateLabel.numberOfLines = 0;
    [rewardDateLabel setFont:REGFONT13];
    rewardDateLabel.text = @"Awarded on 07/25/2015 at 1:15 p.m.";
    [rewardDateLabel sizeToFit];
    
    [messageLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 64, 100)];
    messageLabel.numberOfLines = 0;
    [messageLabel setFont:REGFONT13];
    messageLabel.text = @"\"Thank you for being our loyal follower.\"\n-Bruno\'s Pizza";
    [messageLabel sizeToFit];
    
    if (isExpanded) {
        //Height when cell is expanded.
        if( reward.finePrint.length == 0 )
            return MAX(379, 359 + descriptionLabel.frame.size.height + finePrintLabel.frame.size.height + rewardDateLabel.frame.size.height + messageLabel.frame.size.height);
        else
            return MAX(395, 359 + descriptionLabel.frame.size.height + finePrintLabel.frame.size.height + rewardDateLabel.frame.size.height + messageLabel.frame.size.height);
    }
    
    return MAX(121, 101 + descriptionLabel.frame.size.height);
}

- (void)recalculateDistance {
    self.labelDistance.text = [self getDistanceStringToStore:self.reward.store];
}

- (NSString*)getDistanceStringToStore:(RTStore *)store {
    CLLocation *locCurrent = [[CLLocation alloc] initWithLatitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude];
    
    CLLocation *locStore = [[CLLocation alloc] initWithLatitude:store.latitude longitude:store.longitude];
    
    CLLocationDistance distanceInMeter = [locCurrent distanceFromLocation:locStore];
    
    CLLocationDistance distanceInMile = distanceInMeter / 1609.344;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:1];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    
    NSString *distanceString = [NSString stringWithFormat:@"%@ miles", [formatter stringFromNumber:[NSNumber numberWithDouble:distanceInMile]]];
    
    return distanceString;
}

@end
