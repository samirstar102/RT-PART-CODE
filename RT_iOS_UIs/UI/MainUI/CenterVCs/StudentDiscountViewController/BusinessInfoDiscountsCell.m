#import "BusinessInfoDiscountsCell.h"
#import "RTUIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BusinessInfoDiscountsCell()

@property (weak, nonatomic) IBOutlet UIButton *redeemDiscountButton;
@property (weak, nonatomic) IBOutlet UIView *dayOfWeekView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayOfWeekViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelFinePrint;
@property (weak, nonatomic) IBOutlet UIButton *mondayButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintForIvBackground;
@property (weak, nonatomic) IBOutlet UILabel *onlineDiscountLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;

@end

@implementation BusinessInfoDiscountsCell

@synthesize isAnimating;

- (void)bind:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded animated:(BOOL)animated {
    
    _discount = studentDiscount;
    isAnimating = NO;
    
    //Show or Hide views according to isExpanded
    if( isExpanded ) {
        [self.heightConstraintForIvBackground setConstant:78.0f];
    } else {
        [self.heightConstraintForIvBackground setConstant:56.0f];
    }
    
    if (studentDiscount.isAlwaysAvailable && !studentDiscount.isOnlineDiscount)
        self.dayOfWeekViewHeightConstraint.constant = 0.0f;
    else
        self.dayOfWeekViewHeightConstraint.constant = 40.0f;
    
    [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:studentDiscount.store.logo]
                   placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    
    self.labelDescription.numberOfLines = 0;
    self.labelDescription.text = studentDiscount.discountDescription;
    
    self.labelFinePrint.text = studentDiscount.finePrint;
    
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
    
    [self.ivBackground sd_setImageWithURL:[NSURL URLWithString:studentDiscount.image]
                         placeholderImage:[UIImage imageNamed:@"placeholder_discountbg"]];
    
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, self.heightConstraintForIvBackground.constant + 20);
    
    [RTUIManager applyRedeemDiscountButtonStyle:_redeemDiscountButton];
    [RTUIManager applyDefaultButtonStyle:self.shareButton];
    [RTUIManager applyDefaultButtonStyle:self.commentsButton];
    [self setDaysOfWeeks:studentDiscount.days_valid];
    
    if (self.discount.commentCount > 0) {
        [self.commentsButton setTitle:[NSString stringWithFormat:@"Comments (%i)", self.discount.commentCount] forState:UIControlStateNormal];
    } else {
        [self.commentsButton setTitle:@"Comments" forState:UIControlStateNormal];
    }
    
    if( isExpanded ) {
        _labelFinePrint.hidden = NO;
        _redeemDiscountButton.hidden = NO;
        self.shareButton.hidden = NO;
        self.commentsButton.hidden = NO;
        
        if (studentDiscount.isOnlineDiscount) {
            self.onlineDiscountLabel.hidden = NO;
            _dayOfWeekView.hidden = YES;
        } else {
            self.onlineDiscountLabel.hidden = YES;
            _dayOfWeekView.hidden = studentDiscount.isAlwaysAvailable;
        }
        
        if (animated) {
            [_labelFinePrint setAlpha:.0f];
            [_redeemDiscountButton setAlpha:.0f];
            [_dayOfWeekView setAlpha:.0f];
            self.onlineDiscountLabel.alpha = 0.0f;
            self.shareButton.alpha = 0.0;
            self.commentsButton.alpha = 0.0f;
            
            isAnimating = YES;
            
            [UIView animateWithDuration:0.5 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [_labelFinePrint setAlpha:1.0f];
                    [_redeemDiscountButton setAlpha:1.0f];
                    [_dayOfWeekView setAlpha:1.0f];
                    self.onlineDiscountLabel.alpha = 1.0f;
                    self.shareButton.alpha = 1.0;
                    self.commentsButton.alpha = 1.0f;
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
                
                [_labelFinePrint setAlpha:0.0f];
                [_redeemDiscountButton setAlpha:0.0f];
                [_dayOfWeekView setAlpha:0.0f];
                self.onlineDiscountLabel.alpha = 0.0f;
                self.shareButton.alpha = 0.0;
                self.commentsButton.alpha = 0.0f;
                
            } completion:^(BOOL finished) {
                _labelFinePrint.hidden = YES;
                _redeemDiscountButton.hidden = YES;
                _dayOfWeekView.hidden = YES;
                self.onlineDiscountLabel.hidden = YES;
                self.shareButton.hidden = YES;
                self.commentsButton.hidden = YES;
                
                isAnimating = NO;
            }];
        }
        else {
            [self layoutIfNeeded];
            
            _labelFinePrint.hidden = YES;
            _redeemDiscountButton.hidden = YES;
            _dayOfWeekView.hidden = YES;
            self.onlineDiscountLabel.hidden = YES;
            self.shareButton.hidden = YES;
            self.commentsButton.hidden = YES;
        }
    }
}
- (IBAction)onRedeem:(id)sender {
    if (self.delegate != nil) {
        [self.delegate businessInfoDiscountsCell:self onRedeem:self.discount];
    }
}

- (IBAction)shareButtonPressed:(UIButton *)sender {
    if (self.delegate)
        [self.delegate businessInfoDiscountsCell:self onShare:self.discount];
}

- (IBAction)commentsButtonPressed:(UIButton *)sender {
    if (self.delegate)
        [self.delegate businessInfoDiscountsCell:self commentsTappedForDiscount:self.discount];
}

-(void)setDaysOfWeeks:(NSArray *)daysOfWeeksArray {
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

+ (CGFloat)heightForDiscount:(RTStudentDiscount *)studentDiscount isExpanded:(BOOL)isExpanded {
    static UILabel *lblDescription = nil, *lblFinePrint = nil;
    if (lblDescription == nil) {
        lblDescription = [[UILabel alloc] init];
    }
    
    //Get the required height for description label
    [lblDescription setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    lblDescription.numberOfLines = 0;
    [lblDescription setFont:BOLDFONT16];
    lblDescription.text = studentDiscount.discountDescription;
    [lblDescription sizeToFit];
    
    if (isExpanded) {   //Get height when cell is expanded
        if( lblFinePrint == nil ) {
            lblFinePrint = [[UILabel alloc] init];
        }
        
        //Get the required height for fine print label
        [lblFinePrint setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
        lblFinePrint.numberOfLines = 0;
        [lblFinePrint setFont:REGFONT13];
        lblFinePrint.text = studentDiscount.finePrint;
        [lblFinePrint sizeToFit];
        
        if (studentDiscount.isAlwaysAvailable && !studentDiscount.isOnlineDiscount)
            return MAX(312, 276 + lblDescription.frame.size.height + lblFinePrint.frame.size.height);
        
        //Height when cell is expanded.
        return MAX(352, 316 + lblDescription.frame.size.height + lblFinePrint.frame.size.height);
    }
    
    //Get height when cell is collapsed
    return MAX(122, 102 + lblDescription.frame.size.height);
}

@end
