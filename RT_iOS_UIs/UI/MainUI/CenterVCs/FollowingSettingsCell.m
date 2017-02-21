//
//  FollowingSettingsCell.m
//  RoverTown
//
//  Created by Robin Denis on 6/22/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "FollowingSettingsCell.h"

@interface FollowingSettingsCell()
{
    UIRectCorner cornerForFrame;
    NSString *settingTitle;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UISwitch *swtSettingsSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblSettingTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSettingDescription;

@property (nonatomic) BOOL sizeCorrected;

@end

@implementation FollowingSettingsCell

+ (CGFloat)heightForCellWithDescription:(NSString *)description {
    static UILabel *descriptionLabel = nil;
    if (descriptionLabel == nil) {
        descriptionLabel = [[UILabel alloc] init];
    }
    
    [descriptionLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel setFont:REGFONT14];
    descriptionLabel.text = description;
    [descriptionLabel sizeToFit];
    
    return MAX(95, 79 + descriptionLabel.frame.size.height);
}

- (void)bind:(NSString *)title description:(NSString *)description isOn:(BOOL)isOn corner:(UIRectCorner)corner {
    cornerForFrame = corner;
    settingTitle = title;
    
    //initialize controls
    [self.swtSettingsSwitch setOn:isOn animated:YES];
    [self.lblSettingTitle setText:title];
    [self.lblSettingDescription setText:description];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //set corner
    if( cornerForFrame != 0 ) {
        UIBezierPath *maskPath;

        CGRect bounds = self.ivFrame.bounds;

        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bounds.origin.x, bounds.origin.y,bounds.size.width, bounds.size.height - 1)
                                         byRoundingCorners:cornerForFrame
                                               cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.ivFrame.layer.mask = maskLayer;
    }
}

#pragma mark - Actions

- (IBAction)onSettingsSwitch:(id)sender {
    if( self.delegate ) {
        [self.delegate onFollowingSettingChanged:self.swtSettingsSwitch.isOn settingTitle:settingTitle];
    }
}

@end
