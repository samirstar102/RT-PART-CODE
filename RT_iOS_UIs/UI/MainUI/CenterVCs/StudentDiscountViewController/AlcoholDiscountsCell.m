//
//  AlcoholDiscountsCell.m
//  RoverTown
//
//  Created by Robin Denis on 9/3/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "AlcoholDiscountsCell.h"
#import "RTLocationManager.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "NSDate+Utilities.h"
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AlcoholDiscountsCell()
{
    NSString *birthdayDescriptionCopy;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForIvBackground;
    __weak IBOutlet NSLayoutConstraint *trailingSpaceConstraintForTitle;
    NSDate *birthdate;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UILabel *lblBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscountDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthdayDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblWhenIsYourBirthday;
@property (weak, nonatomic) IBOutlet UIView *vwBirthdayAnswer;
@property (weak, nonatomic) IBOutlet UIButton *btnBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (nonatomic) BOOL shouldReLayout;
@property (nonatomic) BOOL sizeCorrected;

@end

@implementation AlcoholDiscountsCell

@synthesize isAnimating, discount;

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated {
    discount = studentDiscount;
    isAnimating = NO;
    
    //Show or Hide views according to isExpanded
    if( isExpanded ) {
        [heightConstraintForIvBackground setConstant:78.0f];
        trailingSpaceConstraintForTitle.constant = 89.0f;
    }
    else{
        [heightConstraintForIvBackground setConstant:56.0f];
        trailingSpaceConstraintForTitle.constant = 24.0f;
    }
    
    [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:studentDiscount.store.logo]
                   placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    self.ivLogo.layer.cornerRadius = kCornerRadiusDefault;
    self.ivLogo.layer.masksToBounds = YES;
    
    //Initialize the title label
    self.lblBusinessName.text = studentDiscount.store.name;
    self.lblBusinessName.layer.shadowColor = [UIColor blackColor].CGColor;
    self.lblBusinessName.layer.shadowOffset = CGSizeMake(0, 1);
    self.lblBusinessName.layer.shadowOpacity = 0.9;
    
    self.lblDistance.text = [self getDistanceStringToStore:studentDiscount.store];
    
    self.lblDiscountDescription.numberOfLines = 0;
    self.lblDiscountDescription.text = studentDiscount.discountDescription;
    
    // set format for ivFrame
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.cornerRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.shadowRadius = 3;
    self.ivFrame.layer.shadowOpacity = 0.5;
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // set format for ivBackground
    CGRect bounds = self.ivBackground.bounds;
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.ivBackground.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    
    CAShapeLayer *maskLayer = nil;
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    //self.ivBackground.layer.mask = maskLayer;
    
    CAGradientLayer *gradient = nil;
    for (CALayer *layer in self.ivBackground.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            gradient = (CAGradientLayer *)layer;
            break;
        }
    }
    
    if (gradient == nil) {
        gradient = [CAGradientLayer layer];
        gradient.frame = bounds;
        gradient.colors = @[(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
                            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor];
        [self.ivBackground.layer addSublayer:gradient];
    }
    
    [self.ivBackground sd_setImageWithURL:[NSURL URLWithString:studentDiscount.image]
                         placeholderImage:[UIImage imageNamed:@"placeholder_discountbg"]];
    
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, heightConstraintForIvBackground.constant + 20);
    
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnSubmit];

    //Initialize Follow Button
    [RTUIManager applyFollowButtonStyle:self.btnFollow];
    [self setFollowed:[studentDiscount.store.user.following boolValue]];
    
    //Initialize Birthday Button
    [RTUIManager applyDropdownButtonWithBlueBackgroundStyle:self.btnBirthday];
    
    //Initialize Birthday Description Label
    if( ![AlcoholDiscountsCell isUserRestrictedWithDiscount:discount] ) {    //If student is 21 years of age or older
        birthdayDescriptionCopy = NSLocalizedString(@"Discount_Detail_Warning", nil);
    }
    else {
        birthdayDescriptionCopy = NSLocalizedString(@"Discount_Age_Error", nil);
        birthdayDescriptionCopy = [NSString stringWithFormat:birthdayDescriptionCopy, discount.user_restrictions.minimum_age];
        [self.lblBirthdayDescription setTextColor:[UIColor redColor]];
    }
    [self.lblBirthdayDescription setText:birthdayDescriptionCopy];
    
    if( isExpanded && ![AlcoholDiscountsCell isUserRestrictedWithDiscount:discount] ) {
        self.lblBirthdayDescription.hidden = NO;
        self.lblWhenIsYourBirthday.hidden = NO;
        self.vwBirthdayAnswer.hidden = NO;
        self.btnSubmit.hidden = NO;
        self.btnFollow.hidden = NO;
        
        if (animated) {
            [self.lblBirthdayDescription setAlpha:.0f];
            [self.lblWhenIsYourBirthday setAlpha:.0f];
            [self.vwBirthdayAnswer setAlpha:.0f];
            [self.btnSubmit setAlpha:.0f];
            [self.btnFollow setAlpha:.0f];
            
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [self.lblBirthdayDescription setAlpha:1.0f];
                    [self.lblWhenIsYourBirthday setAlpha:1.0f];
                    [self.vwBirthdayAnswer setAlpha:1.0f];
                    [self.btnSubmit setAlpha:1.0f];
                    [self.btnFollow setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    isAnimating = NO;
                }];
            }];
        }
        else {
            //[self layoutIfNeeded];
            gradient.frame = bounds;
        }
    }
    else if( isExpanded && [AlcoholDiscountsCell isUserRestrictedWithDiscount:discount] ) { //if cell is expanded, but the discount is a restricted discount
        self.lblBirthdayDescription.hidden = NO;
        self.lblWhenIsYourBirthday.hidden = YES;
        self.vwBirthdayAnswer.hidden = YES;
        self.btnSubmit.hidden = YES;
        self.btnFollow.hidden = YES;
        
        if (animated) {
            [self.lblBirthdayDescription setAlpha:.0f];
            
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [self.lblBirthdayDescription setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    isAnimating = NO;
                }];
            }];
        }
        else {
            //[self layoutIfNeeded];
            gradient.frame = bounds;
        }
    }
    else {
        if (animated) {
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
                [self.lblBirthdayDescription setAlpha:.0f];
                [self.lblWhenIsYourBirthday setAlpha:.0f];
                [self.vwBirthdayAnswer setAlpha:.0f];
                [self.btnSubmit setAlpha:.0f];
                [self.btnFollow setAlpha:.0f];
                
            } completion:^(BOOL finished) {
                self.lblBirthdayDescription.hidden = YES;
                self.lblWhenIsYourBirthday.hidden = YES;
                self.vwBirthdayAnswer.hidden = YES;
                self.btnSubmit.hidden = YES;
                self.btnFollow.hidden = YES;
                
                isAnimating = NO;
            }];
        }
        else {
            //[self layoutIfNeeded];
            gradient.frame = bounds;
            self.lblBirthdayDescription.hidden = YES;
            self.lblWhenIsYourBirthday.hidden = YES;
            self.vwBirthdayAnswer.hidden = YES;
            self.btnSubmit.hidden = YES;
            self.btnFollow.hidden = YES;
        }
    }
    
    self.shouldReLayout = YES;
}

+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded {
    static UILabel *lblDiscountDescription = nil, *lblBirthdayDescription = nil;
    if( lblDiscountDescription == nil ) {
        lblDiscountDescription = [[UILabel alloc] init];
    }
    if( lblBirthdayDescription == nil ) {
        lblBirthdayDescription = [[UILabel alloc] init];
    }
    
    BOOL isAgeTooYoung;
    if( [RTUserContext sharedInstance].currentUser.birthday != nil && [AlcoholDiscountsCell isUserRestrictedWithDiscount:studentDiscount]) {
        isAgeTooYoung = YES;
    }
    else {
        isAgeTooYoung = NO;
    }
    NSString *birthdayDescriptionCopy = @"";
    
    if( !isAgeTooYoung ) {    //If student is not too young
        birthdayDescriptionCopy = NSLocalizedString(@"Discount_Detail_Warning", nil);
    }
    else {
        birthdayDescriptionCopy = NSLocalizedString(@"Discount_Age_Error", nil);
    }
    
    [lblDiscountDescription setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    lblDiscountDescription.numberOfLines = 0;
    [lblDiscountDescription setFont:BOLDFONT16];
    lblDiscountDescription.text = studentDiscount.discountDescription;
    [lblDiscountDescription sizeToFit];
    
    [lblBirthdayDescription setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    lblBirthdayDescription.numberOfLines = 0;
    [lblBirthdayDescription setFont:REGFONT13];
    lblBirthdayDescription.text = birthdayDescriptionCopy;
    [lblBirthdayDescription sizeToFit];
    
    if( isAgeTooYoung ) {
        if( isExpanded ) {
            return MAX(180, 145 + lblDiscountDescription.frame.size.height + lblBirthdayDescription.frame.size.height);
        }
        
        return MAX(124, 105 + lblDiscountDescription.frame.size.height);
    }
    else {
        if (isExpanded) {
            //Height when cell is expanded.
            return MAX(326, 291 + lblDiscountDescription.frame.size.height + lblBirthdayDescription.frame.size.height);
        }
        
        return MAX(124, 105 + lblDiscountDescription.frame.size.height);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Check if the size is already corrected
    if (self.sizeCorrected) {
        return;
    }
    
    if (self.shouldReLayout) {
        [self setNeedsLayout];
        self.shouldReLayout = NO;
    }
    else {
        if (self.sizeCorrected == NO) {
            self.sizeCorrected = YES;
        }
    }
    
    CGRect bounds = self.ivBackground.bounds;
    
    CAGradientLayer *gradient = nil;
    for (CALayer *layer in self.ivBackground.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            gradient = (CAGradientLayer *)layer;
            break;
        }
    }
    
    //Add gradient effect to background image
    if (gradient == nil) {
        gradient = [CAGradientLayer layer];
        gradient.frame = bounds;
        gradient.colors = @[(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
                            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor];
        [self.ivBackground.layer addSublayer:gradient];
        
    }
    else {
        gradient.frame = bounds;
    }
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.ivBackground.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    //self.ivBackground.layer.mask = maskLayer;
}

- (void)setFollowed:(BOOL)followed {
    _followed = followed;
    
    if( followed ) {
        [self.btnFollow setSelected:YES];
        [self.btnFollow setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        [self.btnFollow setSelected:NO];
        [self.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

- (void)recalculateDistance {
    self.lblDistance.text = [self getDistanceStringToStore:self.discount.store];
}

+ (BOOL)isUserRestrictedWithDiscount:(RTStudentDiscount *)studentDiscount {
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    
    if(
       currentUser.birthday != nil &&
       [NSDate getAgeWithBirthdate:currentUser.birthday] < studentDiscount.user_restrictions.minimum_age ) {
        return YES;
    }
    
    return NO;
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

#pragma mark - Actions

- (IBAction)onBirthdayButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate alcoholDiscountCell:self onTapBirthdayButton:self.discount];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivesBirthdaySetNotification:) name:@"BirthdaySetNotification" object:nil];
    }
}

- (void)receivesBirthdaySetNotification:(NSNotification *)notification {
    birthdate = [[notification userInfo] objectForKey:@"birthday"];
    [self.btnBirthday setTitle:[birthdate stringWithFormat:@"MM/dd/yyyy"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onFollowButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate alcoholDiscountCell:self onFollow:self.discount];
    }
}

- (IBAction)onSubmitButton:(id)sender {
    if( self.delegate != nil && birthdate != nil ) {
        [self.delegate alcoholDiscountCell:self onSubmitBirthday:birthdate];
    }
}

@end
