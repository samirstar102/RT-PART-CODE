//
//  RTReedemOnlineDiscountView.m
//  RoverTown
//
//  Created by Roger Jones Jr on 9/28/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTRedeemOnlineDiscountView.h"
#import "UIColor+Config.h"
#import "RTUIManager.h"

#define kItemSpacer  10
#define kFollowButtonHeight 40
#define kFollowButtonWidth 300

#define IS_IPHONE_4_OR_4S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5_OR_5S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

@interface RTRedeemOnlineDiscountView()
@property (nonatomic) UIImageView *rovertownBannerView;
@property (nonatomic) UILabel *discountDescriptionLabel;
@property (nonatomic) UILabel *storeNameLabel;
@property (nonatomic) UIImageView *centerImageView;
@property (nonatomic) UITextView *redemptionCode;
@property (nonatomic) UILabel *instructionsLabel;
@property (nonatomic) UIButton *redeemButton;
@property (nonatomic) UIButton *nevermindButton;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) id<RTRedeemOnlineDiscountViewProtocol>delegate;
@property (nonatomic) UIView *redemptionBorderView;
@property (nonatomic) CAShapeLayer *border;
@end

@implementation RTRedeemOnlineDiscountView

-(instancetype)initWithFrame:(CGRect)frame storeName:(NSString *)storeName description:(NSString *)description middelImageView:(UIImageView *)middleImageView redemptionCode:(NSString *)redemptionCode delegate:(id<RTRedeemOnlineDiscountViewProtocol>)delegate{
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIImage *bannerImage = [UIImage imageNamed:@"logo_blue.png"];
        self.rovertownBannerView = [[UIImageView alloc]initWithImage:bannerImage];
        [self.rovertownBannerView sizeToFit];
        [self addSubview:self.rovertownBannerView];

        self.discountDescriptionLabel = [[UILabel alloc]init];
        [self.discountDescriptionLabel setText:description];
        [self.discountDescriptionLabel setFont:[UIFont boldSystemFontOfSize:22]];
        [self.discountDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [self.discountDescriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self addSubview:self.discountDescriptionLabel];
        
        self.storeNameLabel = [[UILabel alloc]init];
        [self.storeNameLabel setText:storeName];
        [self.storeNameLabel setFont:[UIFont systemFontOfSize:18]];
        [self.storeNameLabel sizeToFit];
        [self addSubview:self.storeNameLabel];
        
        self.redemptionCode = [[UITextView alloc]init];
        [self.redemptionCode setText:redemptionCode];
        [self.redemptionCode setFont:[UIFont boldSystemFontOfSize:28]];
        [self.redemptionCode sizeToFit];
        [self.redemptionCode setEditable:NO];
        
        self.redemptionBorderView = [[UIView alloc]init];
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor roverTownColor6DA6CE].CGColor;
        _border.lineWidth = 3;
        _border.fillColor = nil;
        _border.lineDashPattern = @[@8, @2];
        [self.redemptionBorderView.layer addSublayer:_border];
        [self addSubview:self.redemptionBorderView];

        self.instructionsLabel = [[UILabel alloc]init];
        [self.instructionsLabel setFont:[UIFont systemFontOfSize:14]];
        [self.instructionsLabel setText:[self.delegate getInstructionTextForOnlineDiscount]];
        [self addSubview:self.instructionsLabel];
        
        self.redeemButton = [[UIButton alloc]init];
        [self.redeemButton setTitle:@"Redeem Online" forState:UIControlStateNormal];
        [self.redeemButton addTarget:self.delegate action:@selector(redeemOnlineButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.redeemButton setEnabled:[self.delegate enableRedeemButton]];
        [self addSubview:self.redeemButton];
        
        self.nevermindButton = [[UIButton alloc]init];
        [self.nevermindButton setTitle:@"Nevermind" forState:UIControlStateNormal];
        [self.nevermindButton addTarget:self.delegate action:@selector(neverMindButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.nevermindButton setUserInteractionEnabled:YES];
        [self addSubview:self.nevermindButton];
        
        self.shareButton = [[UIButton alloc]init];
        [self.shareButton addTarget:self.delegate action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shareButton];
        
        UIImage *centerImage;
        if (self.redemptionCode.text.length) {
        } else {
            centerImage = [UIImage imageNamed:@"bone_icon_no_barcode.png"];
            
        }
        
        self.centerImageView = [[UIImageView alloc]initWithImage:centerImage];
        
        [self addSubview:self.centerImageView];
        [self addSubview:self.redemptionCode];
    }
    return self;
}
-(void)layoutSubviews {
    CGFloat totalHeight = CGRectGetHeight(self.rovertownBannerView.frame) + CGRectGetHeight(self.discountDescriptionLabel.frame) + CGRectGetHeight(self.storeNameLabel.frame) + CGRectGetHeight(self.redemptionCode.frame);
    
    CGFloat midX = CGRectGetMidX(self.frame);

    CGSize instructionSize = [self.instructionsLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - 60, CGFLOAT_MAX)];
    CGRect instructionFrame = self.instructionsLabel.frame;
    instructionFrame.size = instructionSize;
    [self.instructionsLabel setFrame:instructionFrame];
    [self.instructionsLabel setNumberOfLines:3];
    [self.instructionsLabel sizeToFit];
    [self.instructionsLabel setFont:[UIFont systemFontOfSize:15]];
    if (IS_IPHONE_5_OR_5S && self.redemptionCode.text.length) {
        [self.instructionsLabel setFrame:CGRectMake(midX - CGRectGetWidth(self.instructionsLabel.frame)/2, CGRectGetMidY(self.frame), CGRectGetWidth(self.instructionsLabel.frame), CGRectGetHeight(self.instructionsLabel.frame))];
    } else {
        [self.instructionsLabel setFrame:CGRectMake(midX - CGRectGetWidth(self.instructionsLabel.frame)/2, CGRectGetMidY(self.frame), CGRectGetWidth(self.instructionsLabel.frame), CGRectGetHeight(self.instructionsLabel.frame))];
    }
    
    
    CGFloat padding = (CGRectGetMinY(self.instructionsLabel.frame) - totalHeight) / 5;
    if (padding > 20) {
        padding = 20;
    }
    CGFloat yPos = 30;
    
    CGFloat bannerWidth = CGRectGetWidth(self.rovertownBannerView.frame) * 1.1;
    CGFloat bannerHeight = CGRectGetHeight(self.rovertownBannerView.frame) * 1.1;
    [self.rovertownBannerView setFrame:CGRectMake(midX - bannerWidth/2, yPos, bannerWidth,bannerHeight)];
    
    yPos = yPos + CGRectGetHeight(self.rovertownBannerView.frame) + padding;
    
    CGSize size = [self.discountDescriptionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - 60, CGFLOAT_MAX)];
    CGRect descriptionFrame = self.discountDescriptionLabel.frame;
    descriptionFrame.size = size;
    [self.discountDescriptionLabel setFrame:descriptionFrame];
    [self.discountDescriptionLabel sizeToFit];
    [self.discountDescriptionLabel setFrame:CGRectMake(midX - CGRectGetWidth(self.discountDescriptionLabel.frame)/2, yPos, CGRectGetWidth(self.discountDescriptionLabel.frame), CGRectGetHeight(self.discountDescriptionLabel.frame))];
    [self.discountDescriptionLabel setNumberOfLines:3];
    
    yPos = yPos + CGRectGetHeight(self.discountDescriptionLabel.frame) + padding;

    [self.storeNameLabel setFrame:CGRectMake(midX - CGRectGetWidth(self.storeNameLabel.frame)/2, yPos, CGRectGetWidth(self.storeNameLabel.frame), CGRectGetHeight(self.storeNameLabel.frame))];
    
    instructionFrame = self.instructionsLabel.frame;
    CGFloat storeNameBottom = CGRectGetMaxY(self.storeNameLabel.frame);
    CGFloat instructionTop = CGRectGetMinY(instructionFrame);
    CGFloat height;

    if (self.redemptionCode.text.length) {
        height = instructionTop - storeNameBottom;
        CGRect redemptionCodeFrame = self.redemptionCode.frame;
        [self.redemptionCode setFrame:CGRectMake(midX - redemptionCodeFrame.size.width/2, storeNameBottom + height/2 - redemptionCodeFrame.size.height/2, redemptionCodeFrame.size.width, redemptionCodeFrame.size.height)];
        [self.redemptionCode setTextAlignment:NSTextAlignmentCenter];

        redemptionCodeFrame.size.height = redemptionCodeFrame.size.height * 1.3;
        redemptionCodeFrame.size.width = redemptionCodeFrame.size.width * 1.3;
        [self.redemptionBorderView setFrame:CGRectMake(midX - redemptionCodeFrame.size.width/2, storeNameBottom + height/2 - redemptionCodeFrame.size.height/2, redemptionCodeFrame.size.width, redemptionCodeFrame.size.height)];
        [self.redemptionBorderView setBackgroundColor:[UIColor whiteColor]];
        _border.path = [UIBezierPath bezierPathWithRect:self.redemptionBorderView.bounds].CGPath;
        _border.frame = self.redemptionBorderView.bounds;
        
        [self.instructionsLabel setTextAlignment:NSTextAlignmentLeft];
    } else {
        height = instructionTop - storeNameBottom - padding *2;
        [self.centerImageView setFrame:CGRectMake(midX - height/2, storeNameBottom + padding, height, height)];
        [self.centerImageView.layer setCornerRadius:3];
        [self.centerImageView setClipsToBounds:YES];
        [self.instructionsLabel setTextAlignment:NSTextAlignmentCenter];

    }
    
    CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.frame) - 40 , 48);
    [self.nevermindButton setFrame:CGRectMake(CGRectGetMinX(self.redeemButton.frame), CGRectGetMaxY(self.frame) - buttonSize.height - 30, buttonSize.width - 60 , buttonSize.height)];
    [RTUIManager applyNeverMindButtonStyle:self.nevermindButton];
    [self.nevermindButton setClipsToBounds:YES];
    
    [self.redeemButton setFrame:CGRectMake(midX - buttonSize.width/2, CGRectGetMinY(self.nevermindButton.frame) - buttonSize.height - 10, buttonSize.width, CGRectGetHeight(self.nevermindButton.frame))];
    [RTUIManager applyRedeemDiscountButtonStyle:self.redeemButton];
    [self.redeemButton setClipsToBounds:YES];
    
    [self.shareButton setFrame:CGRectMake(CGRectGetMaxX(self.nevermindButton.frame) + 10, CGRectGetMinY(self.nevermindButton.frame), buttonSize.height, buttonSize.height)];
    [self.shareButton.layer setCornerRadius:3];
    [self.shareButton setClipsToBounds:YES];
    [self.shareButton.imageView setFrame:CGRectMake(10, 10, self.shareButton.frame.size.width - 20, self.shareButton.frame.size.height - 20)];
    [self.shareButton setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"share_icon"]];
    [imageView setFrame:CGRectMake(8, 6, CGRectGetWidth(self.shareButton.frame) - 16, CGRectGetHeight(self.shareButton.frame) - 16)];
    [self.shareButton addSubview:imageView];
    
}

@end
