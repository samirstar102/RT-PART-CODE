//
//  RTDiscountCommentView.m
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountCommentView.h"
#import "RTUIManager.h"
#import "NSDate+Utilities.h"

#define kFollowButtonHeight 30
#define kFollowButtonWidth 60

@interface RTDiscountCommentView ()

@property (weak, nonatomic) UIImageView *businessLogoImageView;
@property (weak, nonatomic) UIImageView *discountImageView;
@property (weak, nonatomic) UIButton *followingButton;
@property (weak, nonatomic) UILabel *storeNameLabel;
@property (weak, nonatomic) UILabel *discountTitleLabel;
@property (weak, nonatomic) UIView *imageContainerView;
@property (weak, nonatomic) UIView *discountTitleContainerView;
@property (strong, nonatomic) UISegmentedControl *discountSegmentControl;
@property (weak, nonatomic) UIView *tableContainerView;
@property (nonatomic) RTStudentDiscount *discount;

@property (nonatomic) BOOL following;

@end

@implementation RTDiscountCommentView

- (instancetype) initWithFrame:(CGRect)frame logo:(UIImageView *)logo discountImage:(UIImageView *)discountImage storeName:(NSString *)storeName discountTitle:(NSString *)discountTitle discount:(RTStudentDiscount *)discount following:(BOOL)following delegate:(id<RTDiscountCommentViewDelegate>) delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        RTStudentDiscount *discountForModel = [[RTStudentDiscount alloc] init];
        discountForModel = discount;
        self.discount = discountForModel;
        
        // set up top view
        UIView *topContainerView = [[UIView alloc] init];
        self.imageContainerView = topContainerView;
        
        // set up discount image
        self.discountImageView = discountImage;
        [self.imageContainerView addSubview:self.discountImageView];
        
        // set up business logo image
        self.businessLogoImageView = logo;
        [self.imageContainerView addSubview:self.businessLogoImageView];
        
        // set up store name
        UILabel *storeNameLabel = [[UILabel alloc] init];
        self.storeNameLabel = storeNameLabel;
        [self.storeNameLabel setText:storeName];
        self.storeNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        self.storeNameLabel.textColor = [UIColor whiteColor];
        [self.imageContainerView addSubview:self.storeNameLabel];
        
        // set up the follow button
        UIButton *followingButton = [[UIButton alloc] init];
        self.followingButton = followingButton;
        [RTUIManager applyFollowForUpdatesButtonStyle:self.followingButton];
        [self setFollowButtonEnabled:[self.discount.store.user.following boolValue]];
        [self.followingButton addTarget:self action:@selector(onFollowTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageContainerView addSubview:self.followingButton];
        [self.imageContainerView setBackgroundColor:[UIColor whiteColor]];
        
        // add the top view to parent
        [self addSubview:self.imageContainerView];
        
        // set up title view
        UIView *titleView = [[UIView alloc] init];
        self.discountTitleContainerView = titleView;
        
        // set up discount title
        UILabel *discountNameLabel = [[UILabel alloc] init];
        self.discountTitleLabel = discountNameLabel;
        [self.discountTitleLabel setText:discountTitle];
        [self.discountTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [self.discountTitleLabel setNumberOfLines:0];
        [self.discountTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.discountTitleLabel setPreferredMaxLayoutWidth:CGRectGetWidth(self.frame)];
        [self.discountTitleLabel sizeToFit];
        [self.discountTitleContainerView setBackgroundColor:[UIColor whiteColor]];
        [self.discountTitleContainerView addSubview:self.discountTitleLabel];
        
        // add discount title view to parent
        [self addSubview:self.discountTitleContainerView];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)layoutSubviews {
    // size the top container view
    [self.imageContainerView setFrame:CGRectMake(0, 0, self.frame.size.width, 70)];
    [self.discountImageView setFrame:CGRectMake(0, 0, self.imageContainerView.frame.size.width, 70)];
    
    // let's add shadow to the background image
    CGRect bounds = self.discountImageView.bounds;
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.discountImageView.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    CAShapeLayer *maskLayer = nil;
    maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    CAGradientLayer *gradient = nil;
    for (CALayer *layer in self.discountImageView.layer.sublayers) {
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
        [self.discountImageView.layer addSublayer:gradient];
    }
    
    [self.businessLogoImageView setFrame:CGRectMake(16, 12, 50, 50)];
    
    [self.storeNameLabel sizeToFit];
    [self.storeNameLabel setFrame:CGRectMake(72, 24, CGRectGetWidth(self.storeNameLabel.frame), CGRectGetHeight(self.storeNameLabel.frame))];
    [self.followingButton setFrame:CGRectMake(self.frame.size.width - kFollowButtonWidth - 16, 32, kFollowButtonWidth, kFollowButtonHeight)];
    [self.discountTitleContainerView setFrame:CGRectMake(0, self.discountImageView.frame.size.height, self.imageContainerView.frame.size.width, 70)];
    self.discountTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.discountTitleLabel setFrame:CGRectMake(4, 4, CGRectGetWidth(self.discountTitleContainerView.frame) - 16, CGRectGetHeight(self.discountTitleContainerView.frame) - 8)];
    [self.discountTitleLabel setPreferredMaxLayoutWidth:self.frame.size.width - 16];
    self.discountTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.discountTitleLabel.minimumScaleFactor = 0.75;
    [self.discountTitleLabel setBackgroundColor:[UIColor whiteColor]];
}

- (void)setFollowButtonEnabled:(BOOL)isEnabled {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isEnabled) {
            // make the button say "check mark" for following
            [self.followingButton setImage:[UIImage imageNamed:@"check_icon"] forState:UIControlStateNormal];
            [self.followingButton setTitle:nil forState:UIControlStateNormal];
        } else {
            // make button say "Follow"
            [self.followingButton setImage:nil forState:UIControlStateNormal];
            [self.followingButton setTitle:@"Follow" forState:UIControlStateNormal];
            self.followingButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    });
}

- (IBAction)onFollowTapped:(id)sender {
    if (self.delegate != nil) {
        [self.delegate onFollowTappedForDiscount:self.discount];
    }
}

@end
