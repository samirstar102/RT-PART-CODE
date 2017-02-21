#import "BusinessInfoContactCell.h"
#import "RTUIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BusinessInfoContactCell()

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UILabel *lblContact;
@property (weak, nonatomic) IBOutlet UIButton *btnContact;
@property (nonatomic) BOOL shouldReLayout;

- (IBAction)onContact:(id)sender;

@end

@implementation BusinessInfoContactCell

- (void)bind:(RTStore *)store buttonName:(NSString*) buttonName labelText:(NSString*) labelText {
    _store = store;
    
    // set format for ivFrame
    
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.shadowRadius = 3;
    self.ivFrame.layer.shadowOpacity = 0.5;
    
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.lblContact.text = labelText;
    [self.btnContact setTitle:buttonName forState:UIControlStateNormal];
    [RTUIManager applyDefaultButtonStyle:self.btnContact];
    
    //[self layoutIfNeeded];
    
    self.shouldReLayout = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = [BusinessInfoContactCell heightForContactWithLabelText:self.lblContact.text];
    
    //set mask
    CGRect bounds = self.ivFrame.bounds;
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, height - 1);

    if (self.shouldReLayout) {
        [self setNeedsLayout];
        self.shouldReLayout = NO;
    }
    
    if( self.tag == 0 ) {
        UIBezierPath *maskPath;
        
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.ivFrame.layer.mask = maskLayer;
    }
    else if( self.tag == 1) {
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                         byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                               cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.ivFrame.layer.mask = maskLayer;
    }
    [self sendSubviewToBack:self.ivFrame];
    [self bringSubviewToFront:self.lblContact];
    [self bringSubviewToFront:self.btnContact];
}

+ (CGFloat)heightForContactWithLabelText:(NSString *)labelText {
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] init];
    }
    
    [label setFrame:CGRectMake(0, 0, 180, 100)];
    label.numberOfLines = 0;
    [label setFont:REGFONT16];
    label.text = labelText;
    [label sizeToFit];
    
    return MAX(111, 91 + label.frame.size.height);
}

//Actions
- (IBAction)onContact:(id)sender {
    if (self.delegate != nil) {
        [self.delegate businessInfoContactCell:self onContactButton:self.store];
    }
}
@end
