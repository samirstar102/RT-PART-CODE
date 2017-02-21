#import "StudentDiscountsCell.h"
#import "RTUIManager.h"
#import "RTLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface StudentDiscountsCell()
{
    __weak IBOutlet NSLayoutConstraint *trailingSpaceConstraintForTitle;
}

@property (weak, nonatomic) IBOutlet UIButton *redeemDiscountButton;
@property (weak, nonatomic) IBOutlet UIButton *viewBusinessInfoButton;
@property (nonatomic) UIButton *commentsButton;
@property (nonatomic) UIButton *viewBusinessButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *dayOfWeekView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayOfWeekViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelFinePrint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraintForVerifyIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivVerify;
@property (weak, nonatomic) IBOutlet UILabel *labelVerifyText;
@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForIvBackground;
@property (weak, nonatomic) IBOutlet UILabel *onlineDiscountLabel;
@property (nonatomic) int commentsCount;
@property (nonatomic) BOOL shouldReLayout;
@property (nonatomic) BOOL sizeCorrected;
@property (nonatomic) BOOL outOfGeo;
@property (nonatomic) BOOL savedAlready;

- (IBAction)onFollow:(id)sender;

@end

@implementation StudentDiscountsCell

@synthesize isAnimating;


-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated {
    _discount = studentDiscount;
    isAnimating = NO;
    //Show or Hide views according to isExpanded
    if( isExpanded ) {
        [self.heightConstraintForIvBackground setConstant:78.0f];
        trailingSpaceConstraintForTitle.constant = 89.0f;
        
        if (studentDiscount.isAlwaysAvailable && !studentDiscount.isOnlineDiscount)
            self.dayOfWeekViewHeightConstraint.constant = 0.0f;
        else
            self.dayOfWeekViewHeightConstraint.constant = 40.0f;
        
    } else {
        [self.heightConstraintForIvBackground setConstant:56.0f];
        trailingSpaceConstraintForTitle.constant = 24.0f;
    }
    
    [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:studentDiscount.store.logo]
                         placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    self.ivLogo.layer.masksToBounds = YES;
    
    //Initialize the title label
    self.labelTitle.text = studentDiscount.store.name;
    self.labelTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.labelTitle.layer.shadowOffset = CGSizeMake(0, 1);
    self.labelTitle.layer.shadowOpacity = 0.9;
    self.labelDistance.text = [self getDistanceStringToStore:studentDiscount.store];
    if (studentDiscount.isOnlineDiscount) {
        [self.labelDistance.layer setHidden:YES];
    }
    self.labelDescription.numberOfLines = 0;
    self.labelDescription.text = studentDiscount.discountDescription;
    
    self.labelFinePrint.text = studentDiscount.finePrint;
    
    // set format for ivFrame
    
    self.ivFrame.layer.masksToBounds = NO;
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
//        gradient = [CAGradientLayer layer];
//        gradient.frame = bounds;
//        gradient.colors = @[(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
//                        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor];
//        [self.ivBackground.layer addSublayer:gradient];
    }
    
    [self.ivBackground sd_setImageWithURL:[NSURL URLWithString:studentDiscount.image]
                   placeholderImage:[UIImage imageNamed:@"placeholder_discountbg"]];

    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.heightConstraintForIvBackground.constant + 20);
    
    [RTUIManager applyRedeemDiscountButtonStyle:_redeemDiscountButton];
    [RTUIManager applyDefaultButtonStyle:_viewBusinessInfoButton];
    [RTUIManager applyDefaultButtonStyle:_shareButton];
    
    //Initialize Verify Text
    [self setVerified:studentDiscount.statistics.verified redeem_count:studentDiscount.statistics.redeem_count];

    //Initialize Follow Button
    [RTUIManager applyFollowButtonStyle:_followButton];
    [self setFollowed:[studentDiscount.store.user.following boolValue]];
    
    [self setDaysOfWeeks:studentDiscount.days_valid];
    
    if( isExpanded ) {
        _labelFinePrint.hidden = NO;
        _ivVerify.hidden = NO;
        _labelVerifyText.hidden = NO;
        _redeemDiscountButton.hidden = NO;
        _viewBusinessButton.hidden = NO;
        _commentsButton.hidden = NO;
        _shareButton.hidden = NO;
        
        if (studentDiscount.isOnlineDiscount) {
            self.dayOfWeekView.hidden = YES;
            self.onlineDiscountLabel.hidden = NO;
        } else {
            self.onlineDiscountLabel.hidden = YES;
            self.dayOfWeekView.hidden = studentDiscount.isAlwaysAvailable;
        }
        
        _followButton.hidden = NO;
        
        if (animated) {
            [_labelFinePrint setAlpha:.0f];
            [_ivVerify setAlpha:.0f];
            [_labelVerifyText setAlpha:.0f];
            [_redeemDiscountButton setAlpha:.0f];
            [_viewBusinessInfoButton setAlpha:.0f];
            [_commentsButton setAlpha:0.0f];
            [_viewBusinessButton setAlpha:0.0f];
            [_shareButton setAlpha:.0f];
            [_dayOfWeekView setAlpha:.0f];
            self.onlineDiscountLabel.alpha = 0.0f;
            [_followButton setAlpha:.0f];
            
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_labelFinePrint setAlpha:1.0f];
                    [_ivVerify setAlpha:1.0f];
                    [_labelVerifyText setAlpha:1.0f];
                    [_redeemDiscountButton setAlpha:1.0f];
                    [_commentsButton setAlpha:1.0f];
                    [_viewBusinessButton setAlpha:1.0f];
                    [_shareButton setAlpha:1.0f];
                    [_dayOfWeekView setAlpha:1.0f];
                    self.onlineDiscountLabel.alpha = 1.0f;
                    [_followButton setAlpha:1.0f];
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
            
            [UIView animateWithDuration:0.2 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
                
                [_labelFinePrint setAlpha:0.0f];
                [_ivVerify setAlpha:0.0f];
                [_labelVerifyText setAlpha:0.0f];
                [_commentsButton setAlpha:0.0f];
                [_viewBusinessButton setAlpha:0.0f];
                [_shareButton setAlpha:0.0f];
                [_redeemDiscountButton setAlpha:0.0f];
                [_dayOfWeekView setAlpha:0.0f];
                self.onlineDiscountLabel.alpha = 0.0f;
                [_followButton setAlpha:0.0f];
                
            } completion:^(BOOL finished) {
                _labelFinePrint.hidden = YES;
                _ivVerify.hidden = YES;
                _labelVerifyText.hidden = YES;
                _redeemDiscountButton.hidden = YES;
                _commentsButton.hidden = YES;
                _viewBusinessButton.hidden = YES;
                _shareButton.hidden = YES;
                _dayOfWeekView.hidden = YES;
                self.onlineDiscountLabel.hidden = YES;
                _followButton.hidden = YES;
                
                isAnimating = NO;
            }];
        }
        else {
            //[self layoutIfNeeded];
            gradient.frame = bounds;
            
            _labelFinePrint.hidden = YES;
            _ivVerify.hidden = YES;
            _labelVerifyText.hidden = YES;
            _redeemDiscountButton.hidden = YES;
            _commentsButton.hidden = YES;
            _viewBusinessButton.hidden = YES;
            _shareButton.hidden = YES;
            _dayOfWeekView.hidden = YES;
            self.onlineDiscountLabel.hidden = YES;
            _followButton.hidden = YES;
        }
    }
    
    if (!self.commentsButton && isExpanded) {
        CGRect commentsButtonFrame = self.viewBusinessInfoButton.frame;
        commentsButtonFrame.size.width = commentsButtonFrame.size.width/2 - 5;
        commentsButtonFrame.origin.y = self.shareButton.frame.origin.y;
        [self.commentsButton setFrame:commentsButtonFrame];
        CGRect viewBusinessFrame = commentsButtonFrame;
        viewBusinessFrame.origin.x = CGRectGetMaxX(commentsButtonFrame) + 10;
        [self.viewBusinessButton setFrame:viewBusinessFrame];
        
        self.commentsButton = [[UIButton alloc]initWithFrame:commentsButtonFrame];
        [self.commentsButton addTarget:self action:@selector(commentsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.viewBusinessButton = [[UIButton alloc]initWithFrame:viewBusinessFrame];
        [self.viewBusinessButton addTarget:self action:@selector(viewBusiness) forControlEvents:UIControlEventTouchUpInside];
        [self.commentsButton setBackgroundColor:self.viewBusinessInfoButton.backgroundColor];
        [self.viewBusinessButton setBackgroundColor:self.viewBusinessInfoButton.backgroundColor];
        [self.commentsButton.titleLabel setFont:self.viewBusinessInfoButton.titleLabel.font];
        [self.viewBusinessButton.titleLabel setFont:self.viewBusinessInfoButton.titleLabel.font];
        if (self.discount.commentCount > 0) {
            [self.commentsButton setTitle:[NSString stringWithFormat:@"Comments (%i)", self.discount.commentCount] forState:UIControlStateNormal];
        } else {
           [self.commentsButton setTitle:@"Comments" forState:UIControlStateNormal];
        }
        [self.viewBusinessButton setTitle:@"View Business" forState:UIControlStateNormal];
        [self.commentsButton.layer setCornerRadius:self.viewBusinessInfoButton.layer.cornerRadius];
        [self.viewBusinessButton.layer setCornerRadius:self.viewBusinessInfoButton.layer.cornerRadius];
        [self addSubview:self.commentsButton];
        [self addSubview:self.viewBusinessButton];
        
        if (animated) {
            [_commentsButton setAlpha:0.0f];
            [_viewBusinessButton setAlpha:0.0f];
            isAnimating = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [self layoutIfNeeded];
                gradient.frame = bounds;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    [_commentsButton setAlpha:1.0f];
                    [_viewBusinessButton setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    isAnimating= NO;
                }];
            }];
        }
    }
    
    if (![studentDiscount isOnlineDiscount]) {
        if (self.discount.enforceGeo) {
            if (!self.isOutOfGeo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setSaveForLater];
                });
            }
        }
    } else {
        [self.labelDistance setAlpha:0];
    }
    
    if (studentDiscount.isOnline) {
        [self.labelDistance setAlpha:0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.commentsButton.frame.origin.y == self.shareButton.frame.origin.y) {
        CGRect commentsButtonFrame = self.commentsButton.frame;
        commentsButtonFrame.origin.y = self.shareButton.frame.origin.y;
        [self.commentsButton setFrame:commentsButtonFrame];
        CGRect viewBusinessFrame = commentsButtonFrame;
        viewBusinessFrame.origin.x = CGRectGetMaxX(commentsButtonFrame) + 10;
        [self.viewBusinessButton setFrame:viewBusinessFrame];
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
//        gradient = [CAGradientLayer layer];
//        gradient.frame = bounds;
//        gradient.colors = @[(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
//                            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor];
//        [self.ivBackground.layer addSublayer:gradient];

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
    if (![self.discount isOnlineDiscount]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setSaveForLater];
        });
    }
    
}

#pragma mark - Actions

- (IBAction)onRedeem:(id)sender {
    if (self.delegate != nil) {
        
        if (self.discount.enforceGeo) {
            if (self.isOutOfGeo) {
                if (self.discount.userSaved) {
                    self.discount.userSaved = NO;
                    [self.delegate studentDiscountCell:self unsaveForLater:self.discount];
                } else {
                    self.discount.userSaved = YES;
                    [self.delegate studentDiscountCell:self onSaveForLater:self.discount];
                }
            } else {
                [self.delegate studentDiscountCell:self onRedeem:self.discount];
            }
        } else {
            [self.delegate studentDiscountCell:self onRedeem:self.discount];
        }
    }
}

- (void)commentsButtonTapped {
    if (self.delegate != nil) {
    [self.delegate studentDiscountCell:self commentsTappedForDiscount:self.discount];
    }
}

- (void)viewBusiness {
    if (self.delegate != nil) {
        [self.delegate studentDiscountCell:self onViewBusiness:self.discount];
    }
}

- (IBAction)onFollow:(id)sender {
    if (self.delegate != nil) {
        [self.delegate studentDiscountCell:self onFollow:self.discount];
    }
}

- (IBAction)onShare:(id)sender {
    if (self.delegate != nil) {
        [self.delegate studentDiscountCell:self onShare:self.discount];
    }
}

- (void)setDaysOfWeeks:(NSArray *)daysOfWeeksArray {
    for( int i = 0; i < daysOfWeeksArray.count; i++ ) {
        UIButton *dayOfWeekButton = [[self.dayOfWeekView subviews] objectAtIndex:i];

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

- (void)setFollowed:(BOOL)bFollowed {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( bFollowed ) {
            [_followButton setSelected:YES];
            [_followButton setTitle:@"" forState:UIControlStateNormal];
        }
        else {
            [_followButton setSelected:NO];
            [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    });
}

- (void)setCommentsValue:(int)comments {
    self.discount.commentCount += comments;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commentsButton setTitle:[NSString stringWithFormat:@"Comments (%i)", self.discount.commentCount] forState:UIControlStateNormal];
    });
}

- (void)setVerified:(BOOL)bVerified redeem_count:(long)redeem_count{
    if( bVerified ) {
        self.widthConstraintForVerifyIcon.constant = 17;
        NSString *verifyText;
        if( redeem_count == 1 ) {
            verifyText = [NSString stringWithFormat:@" Verified, %d redeem", (int)redeem_count];
        }
        else {
            verifyText = [NSString stringWithFormat:@" Verified, %d redeems", (int)redeem_count];
        }
        
        self.labelVerifyText.text = verifyText;
        [self.labelVerifyText setTextColor:[UIColor colorWithRed:1/255.0f green:160/255.0f blue:78/255.0f alpha:1.0f]];
    }
    else {
        self.widthConstraintForVerifyIcon.constant = 0;
        
        NSString *verifyText;
        if( redeem_count == 1 ) {
            verifyText = [NSString stringWithFormat:@"Unverified, %d redeem", (int)redeem_count];
        }
        else {
            verifyText = [NSString stringWithFormat:@"Unverified, %d redeems", (int)redeem_count];
        }
        
        self.labelVerifyText.text = verifyText;
        [self.labelVerifyText setTextColor:[UIColor darkGrayColor]];
    }
}

- (void)recalculateDistance {
    self.labelDistance.text = [self getDistanceStringToStore:self.discount.store];
}

- (void)setSaveForLater {
    if (self.discount.enforceGeo) {
        CGFloat spacing = 4;
        if (self.isOutOfGeo) {
            if (self.discount.userSaved) {
                [self.redeemDiscountButton setTitle:@"REMINDER SET" forState:UIControlStateNormal];
                [self.redeemDiscountButton setImage:[UIImage imageNamed:@"check_icon"] forState:UIControlStateNormal];
                self.redeemDiscountButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
            } else {
                [self.redeemDiscountButton setTitle:@"REMIND ME TO USE THIS" forState:UIControlStateNormal];
                [self.redeemDiscountButton setImage:nil forState:UIControlStateNormal];
            }
        } else if (!self.isOutOfGeo) {
            [self.redeemDiscountButton setTitle:@"Redeem Discount" forState:UIControlStateNormal];
            [self.redeemDiscountButton setImage:nil forState:UIControlStateNormal];
        }
    } else {
        [self.redeemDiscountButton setTitle:@"Redeem Discount" forState:UIControlStateNormal];
        [self.redeemDiscountButton setImage:nil forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
}

- (void)setUnsaveForLater {
    [self.redeemDiscountButton setTitle:@"REMIND ME TO USE THIS" forState:UIControlStateNormal];
    [self.redeemDiscountButton setImage:nil forState:UIControlStateNormal];
    self.savedAlready = NO;
    self.discount.userSaved = NO;
}

+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded {
    static UILabel *descriptionLabel = nil, *finePrintLabel = nil;
    if (descriptionLabel == nil) {
        descriptionLabel = [[UILabel alloc] init];
    }
    if (finePrintLabel == nil) {
        finePrintLabel = [[UILabel alloc] init];
    }
    
    [descriptionLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel setFont:BOLDFONT16];
    descriptionLabel.text = studentDiscount.discountDescription;
    [descriptionLabel sizeToFit];
    
    [finePrintLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    finePrintLabel.numberOfLines = 0;
    [finePrintLabel setFont:REGFONT13];
    finePrintLabel.text = studentDiscount.finePrint;
    [finePrintLabel sizeToFit];
    
    if (isExpanded) {
        //Height when cell is expanded.
        
        CGFloat cellHeight = 352;
        if (studentDiscount.isAlwaysAvailable && !studentDiscount.isOnlineDiscount)
            cellHeight -= 40;
        
        CGFloat maxCellHeight;
        if( studentDiscount.finePrint.length == 0 ) {
            maxCellHeight = 372;
        } else {
            maxCellHeight = 388;
        }
        
        if (studentDiscount.isAlwaysAvailable && !studentDiscount.isOnlineDiscount)
            maxCellHeight -= 40;
        
        return MAX(maxCellHeight, cellHeight + descriptionLabel.frame.size.height + finePrintLabel.frame.size.height);
    }
    
    return MAX(124, 105 + descriptionLabel.frame.size.height);
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

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.viewBusinessButton removeFromSuperview];
    self.viewBusinessButton = nil;
    [self.commentsButton removeFromSuperview];
    self.commentsButton = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setSaveForLater];
    });
    
    [self setNeedsLayout];
}

- (void)resetInternalViews {
    [self setNeedsLayout];
}

@end
