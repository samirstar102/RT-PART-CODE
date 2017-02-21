//
//  UnlockedBadgesCell.m
//  RoverTown
//
//  Created by Robin Denis on 8/7/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "UnlockedBadgesCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface UnlockedBadgesCell()
{
    RTBadge *leftBadge, *rightBadge;
}

@property (weak, nonatomic) IBOutlet UIView *viewForRightBadge;
@property (weak, nonatomic) IBOutlet UIButton *btnLeftBadge;
@property (weak, nonatomic) IBOutlet UIButton *btnRightBadge;
@property (weak, nonatomic) IBOutlet UIImageView *ivLeftBadge;
@property (weak, nonatomic) IBOutlet UIImageView *ivRightBadge;

@end

@implementation UnlockedBadgesCell

- (void)bind:(NSArray *)badges {
    if( badges != nil ) {
        leftBadge = badges[0];
        
        if( badges.count == 2 ) {   //When both left and right discounts are exist
            rightBadge = badges[1];
        }
        else {
            [self.viewForRightBadge setHidden:YES];
        }
        
        [self.ivLeftBadge sd_setImageWithURL:[NSURL URLWithString:leftBadge.urlForBadgeImage] placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
        [self.btnLeftBadge setTitle:leftBadge.name forState:UIControlStateNormal];
        [self.btnLeftBadge setTag:0];
        [self.btnLeftBadge addTarget:self action:@selector(onBadge:) forControlEvents:UIControlEventTouchUpInside];
        
        if( rightBadge != nil ) {
            [self.btnRightBadge setTitle:rightBadge.name forState:UIControlStateNormal];
            [self.ivRightBadge sd_setImageWithURL:[NSURL URLWithString:rightBadge.urlForBadgeImage] placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
            [self.btnRightBadge setTag:1];
            [self.btnRightBadge addTarget:self action:@selector(onBadge:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.btnLeftBadge.layer setCornerRadius:kCornerRadiusDefault];
        [self.btnRightBadge.layer setCornerRadius:kCornerRadiusDefault];
    }
}

+ (CGFloat)heightForCellWithBadge:(NSArray *)badges {
    return 100;
}

-(IBAction)onBadge:(id)sender {
    UIButton *button = (UIButton *)sender;
    int index = (int)button.tag;
    
    if( self.delegate != nil ) {
        if( index == 0 ) {
            //if badge is left badge
            [self.delegate unlockedBadgesCell:self onBadgeClicked:leftBadge];
        }
        else if ( index == 1 ) {
            //if badge is right badge
            [self.delegate unlockedBadgesCell:self onBadgeClicked:rightBadge];
        }
    }
}

@end
