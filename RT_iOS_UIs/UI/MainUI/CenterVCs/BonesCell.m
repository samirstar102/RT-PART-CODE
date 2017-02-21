//
//  BonesCell.m
//  RoverTown
//
//  Created by Robin Denis on 7/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "BonesCell.h"
#import "UIColor+Config.h"
#import "NSDate+Utilities.h"

@interface BonesCell()

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UILabel *lblBones;

@end

@implementation BonesCell

- (void)bind : (RTBone *)bone {
    //Binds cell with data
    if( bone != nil ) {
        //Defines general attributes for the entire text
        NSDictionary *attribs = @{
                                  NSFontAttributeName: REGFONT14
                                  };
        
        //Generate a string of earned bone date
        NSString *dateString = [bone.received_date stringWithFormat:@"hh:mm a MM/dd/yyyy"];
        
        NSString *bonesText = [NSString stringWithFormat:@"%@ %@.\n%@", bone.subject, bone.message, dateString];
        
        NSMutableAttributedString *attributedBonesText = [[NSMutableAttributedString alloc] initWithString:bonesText attributes:attribs];
        
        //Set the number of bones as bold font
        UIFont *boldFont = [UIFont boldSystemFontOfSize:14.0f];
        NSRange boldTextRange = [bonesText rangeOfString:bone.subject];
        [attributedBonesText setAttributes:@{NSFontAttributeName:boldFont} range:boldTextRange];
        
        //Set the text color of time stamp as 60% grey
        UIColor *greyColor = [UIColor roverTownColor999999];

        NSRange greyTextRange = [bonesText rangeOfString:dateString];
        [attributedBonesText setAttributes:@{NSForegroundColorAttributeName:greyColor, NSFontAttributeName: REGFONT14   } range:greyTextRange];
        
        self.lblBones.attributedText = attributedBonesText;
    }
    
    //Set corner and shadow of the cell
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.cornerRadius = kCornerRadiusDefault;
//    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
//    self.ivFrame.layer.shadowRadius = kCornerRadiusDefault;
//    self.ivFrame.layer.shadowOpacity = 0.5;
    
    self.ivFrame.layer.borderWidth = 1;
    self.ivFrame.layer.borderColor = [UIColor whiteColor].CGColor;
}

+ (CGFloat)heightForCellWithBone:(RTBone *)bone {
    
    UILabel *bonesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
    
    //Generate a string of earned bone date
    NSString *dateString = [bone.received_date stringWithFormat:@"hh:mm a MM/dd/yyyy"];
    
    NSString *bonesText = [NSString stringWithFormat:@"%@ %@.\n%@", bone.subject, bone.message, dateString];
    
    [bonesLabel setNumberOfLines:0];
    [bonesLabel setText:bonesText];
    [bonesLabel setFont:REGFONT14];
    [bonesLabel sizeToFit];

    return 44 + bonesLabel.bounds.size.height;
}

@end