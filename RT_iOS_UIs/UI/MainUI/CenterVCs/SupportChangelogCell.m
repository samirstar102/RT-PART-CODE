//
//  SupportChangelogCell.m
//  RoverTown
//
//  Created by Robin Denis on 6/8/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//


#import "SupportChangelogCell.h"

#define kParagraphIndentSize (7);

@interface SupportChangelogCell()
{
    BOOL bShouldRelayout;
    BOOL bAddedBulletLabels;
    
    __weak IBOutlet NSLayoutConstraint *topSpaceforDescriptionLabel;
    __weak IBOutlet NSLayoutConstraint *topSpaceForChangeLinesLabel;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblChangelines;

@end

@implementation SupportChangelogCell

- (void)bind : (RTUpdates*)updatesData {
    if( updatesData != nil ) {
        bShouldRelayout = YES;
        
        [self.lblVersion setText:updatesData.version];
        [self.lblDate setText:[NSString stringWithFormat:@"(%@)", updatesData.dateString]];
        
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.headIndent = kParagraphIndentSize;
        
        self.lblDescription.attributedText = [[NSAttributedString alloc] initWithString:updatesData.changeDescription attributes:@{NSParagraphStyleAttributeName:ps}];
        [self.lblDescription sizeToFit];
    }

    //Set corner and shadow of the cell
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.cornerRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.shadowRadius = 3;
    self.ivFrame.layer.shadowOpacity = 0.5;
    
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if( bShouldRelayout ) {
        [self setNeedsLayout];
        bShouldRelayout = NO;
    }
}

+ (CGFloat)heightForCellWithUpdates : (RTUpdates*)updatesData {
    static UILabel *lblDescription = nil;
    if (lblDescription == nil) {
        lblDescription = [[UILabel alloc] init];
    }
    
    [lblDescription setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    lblDescription.numberOfLines = 0;
    [lblDescription setFont:REGFONT14];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.headIndent = kParagraphIndentSize;
    
    lblDescription.attributedText = [[NSAttributedString alloc] initWithString:updatesData.changeDescription attributes:@{NSParagraphStyleAttributeName:ps}];
    [lblDescription sizeToFit];
    
    return MAX(111, 94 + lblDescription.frame.size.height);
}

@end