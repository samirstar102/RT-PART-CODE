//
//  FollowingUpdatesCell.m
//  RoverTown
//
//  Created by Robin Denis on 6/22/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "FollowingUpdatesCell.h"
#import "NSDate+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FollowingUpdatesCell()
{
    RTNotification *notificationForCell;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIImageView *ivLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationText;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationDate;

@end

@implementation FollowingUpdatesCell

+ (CGFloat)heightForCellWithNotification:(RTNotification *)notification {
    return 128.0f; //Padding: +13
}

- (void)bind:(RTNotification *)notification {
    notificationForCell = notification;
    
    //initialize controls
    if( notification != nil ) {
        [self.lblNotificationText setAttributedText:[self makeAttributedStringForNotificationTextLabelWithNotification:notification]];
        [self.lblNotificationDate setText:[self makeNotificationDateStringWithNotification:notification]];
        [self.ivLogo sd_setImageWithURL:[NSURL URLWithString:notification.store.logo]
                       placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    }
    
    self.ivFrame.layer.masksToBounds = NO;
    self.ivFrame.layer.shadowOffset = CGSizeMake(0, 1);
    self.ivFrame.layer.cornerRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowRadius = kCornerRadiusDefault;
    self.ivFrame.layer.shadowOpacity = 0.5;
}

- (NSMutableAttributedString *)makeAttributedStringForNotificationTextLabelWithNotification:(RTNotification *)notification {
    NSString *notificationText = [[notification.subject stringByAppendingString:@"! "] stringByAppendingString:notification.message];
    
    NSMutableAttributedString *retString = [[NSMutableAttributedString alloc] initWithString:notificationText];
    
    NSRange boldTextRange = [notificationText rangeOfString:[notification.subject stringByAppendingString:@"!"]];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
    [retString setAttributes:@{NSFontAttributeName:boldFont} range:boldTextRange];
    
    return retString;
}

- (NSString *)makeNotificationDateStringWithNotification:(RTNotification *)notification {
    NSDate *notificationDate = [NSDate dateWithTimeIntervalSince1970:[notification.sent_date longValue]];
    
    NSString *retString = [notificationDate stringWithFormat:@"hh:mm a 'on' MM/dd/yyyy"];
    
    return retString;
}

@end