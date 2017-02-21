//
//  RTActivityFeedCell.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivityFeedCell.h"
#import "RTActivity.h"
#import "NSDate+Utilities.h"
#import "UIColor+Config.h"
#import "RTStore.h"
#import "RTStudentDiscount.h"
#import "RTServerManager.h"
#import "BusinessInfoVC.h"
#import "RTModelBridge.h"
#import "NSDate+DateTools.h"

#define kLogoDimension 50
#define kLogoDimensionSpacer 10
#define kLogoDimensionSpacerVertical 5

@interface RTActivityFeedCell() <UITextViewDelegate>

@property (nonatomic) NSString *titleString;
@property (nonatomic, strong) UIView *cellView;
@property (nonatomic, strong) RTActivity *activityForCell;
@property (nonatomic, strong) NSMutableArray *subjectArray;
@property (nonatomic) NSInteger discountId;
@property (nonatomic) NSArray *subject;
@property (nonatomic) UITapGestureRecognizer *commentTapRecognizer;
@property (nonatomic) UITapGestureRecognizer *discountTapRecognizer;
@property (nonatomic) UITapGestureRecognizer *storeTapRecognizer;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL hasComment;
@property (nonatomic) BOOL hasLogo;
@property (nonatomic) UIImage *commentImage;
@property (nonatomic) UIImage *logoImage;
@property (nonatomic) NSString *commentString;
@property (nonatomic) RTStore *store;
@property (nonatomic) BOOL hasStoreAttached;
@property (nonatomic) CGFloat frameHeight;
@property (nonatomic) NSInteger storeId;
@property (nonatomic) int userId;


@end

@implementation RTActivityFeedCell

- (instancetype)initWithActivity:(RTActivity *)activity {
    if (self = [super init]) {
        RTActivity *activitySetter = [[RTActivity alloc] init];
        activitySetter = activity;
        _activityForCell = activitySetter;
        _activityType = _activityForCell.activityType;
        self.hasStoreAttached = NO;
        self.subject = [NSArray arrayWithArray:self.activityForCell.subject];
        self.commentImage = self.activityForCell.commentImmage;
        self.layer.cornerRadius = 2;
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    return self;
}

-(void)imageTappedByUser:(UITapGestureRecognizer *)recognizer {
    if (self.delegate != nil) {
        if (self.hasImage && self.hasComment) {
            [self.delegate imageTappedForImage:self.commentImage andComment:self.commentString];
        } else if (self.hasImage && !self.hasComment) {
            [self.delegate imageTappedForImage:self.commentImage andComment:@""];
        } else {
            
        }
    }
}

#pragma mark - Actions

-(void)discountTappedByUser:(UITapGestureRecognizer*)recognizer {
    if (self.delegate != nil) {
        [self.delegate activityCell:self onDiscountTappedWithId:self.discountId andStoreId:self.storeId];
    }
}

-(void)storeTappedByUser:(UITapGestureRecognizer*)recognizer {
    if (self.delegate != nil) {
        [self.delegate activityCell:self onViewBusinessWithID:self.storeId];
    }
}

-(void)userTappedByUser:(UITapGestureRecognizer*)recognizer {
    if (self.delegate != nil) {
        if (self.userId != 0) {
            [self.delegate activityCell:self onUserTappedWithUserId:self.userId];
        }
    }
}

- (void)setActivity:(RTActivity *)activity {
    self.activityType = activity.activityType;
    self.subjectArray = [[NSMutableArray alloc] initWithArray:activity.subject];
    self.activityForCell = activity;
    [self setNeedsLayout];
}

+ (CGFloat)heightForCellBusinessActivity:(RTActivity *)activity andView:(UIView *)view WithImage:(BOOL)hasImage {
    CGRect lastFrame;
    CGFloat width = 0;
    //CGRect labelFrame;
    CGFloat totalHeight = 0;
    //CGFloat maxWidth = view.frame.size.width;
    int lineCount = 0;
    for (NSDictionary *dic in activity.subject) {
        UILabel *label = [[UILabel alloc]init];
        label.text = [dic objectForKey:@"text"];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [label sizeToFit];
        if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(view.frame)) {
            label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
            lineCount += 1;
        } else{
            CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
            CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
            label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
        }
        lastFrame = label.frame;
        width = CGRectGetMaxX(lastFrame);
        totalHeight = lineCount * label.frame.size.height;
    }
    if (![activity.imageString isEqualToString:@""]) {
        totalHeight += kLogoDimension;
        totalHeight -= 10;
    } else {
        UILabel *centerLabel = [[UILabel alloc] init];
        centerLabel.text = [NSString stringWithFormat:@"\"%@\"", activity.comment];
        centerLabel.numberOfLines = 0;
        CGFloat maxWidth = view.frame.size.width - 16;
        centerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        centerLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [centerLabel setFrame:CGRectMake(0, 0, maxWidth, CGRectGetHeight(centerLabel.frame))];
        [centerLabel setPreferredMaxLayoutWidth:maxWidth];
        [centerLabel sizeToFit];
        totalHeight += centerLabel.frame.size.height;
    }
    return totalHeight + 80;
}


+ (CGFloat)heightForCellActivity:(RTActivity *)activity andView:(UIView*)view withImage:(BOOL)hasImage {
    CGRect lastFrame;
    CGFloat width = 0;
    //CGRect labelFrame;
    CGFloat totalHeight = 0;
    //CGFloat maxWidth = view.frame.size.width;
    CGFloat logoHeight = 0;
    int lineCount = 0;
    
    // is there a logo?
    if (![activity.logoString isEqualToString:@""]) {
        logoHeight = kLogoDimension;
        if (![activity.imageString isEqualToString:@""]) {
            totalHeight += kLogoDimension;
            totalHeight += 20;
        } else if (![activity.comment isEqualToString:@""]) {
            UILabel *centerLabel = [[UILabel alloc] init];
            centerLabel.text = [NSString stringWithFormat:@"\"%@\"", activity.comment];
            centerLabel.numberOfLines = 0;
            CGFloat maxWidth = view.frame.size.width - 16;
            centerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
            centerLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [centerLabel setFrame:CGRectMake(0, 0, maxWidth, CGRectGetHeight(centerLabel.frame))];
            [centerLabel setPreferredMaxLayoutWidth:maxWidth];
            [centerLabel sizeToFit];
            totalHeight += centerLabel.frame.size.height;
            totalHeight += 20;
        } else {
            totalHeight = 30;
        }
        totalHeight += logoHeight;
        return totalHeight + 40;
    } else if (activity.comment) {
        for (NSDictionary *dic in activity.subject) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [dic objectForKey:@"text"];
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            [label sizeToFit];
            if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(view.frame)) {
                label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                lineCount += 1;
            } else{
                CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
                CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
            }
            lastFrame = label.frame;
            width = CGRectGetMaxX(lastFrame);
            totalHeight = lineCount * label.frame.size.height;
        }
        if (![activity.imageString isEqualToString:@""]) {
            totalHeight += kLogoDimension;
            totalHeight -= 10;
        } else {
            UILabel *centerLabel = [[UILabel alloc] init];
            centerLabel.text = [NSString stringWithFormat:@"\"%@\"", activity.comment];
            centerLabel.numberOfLines = 0;
            CGFloat maxWidth = view.frame.size.width - 16;
            centerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
            centerLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [centerLabel setFrame:CGRectMake(0, 0, maxWidth, CGRectGetHeight(centerLabel.frame))];
            [centerLabel setPreferredMaxLayoutWidth:maxWidth];
            [centerLabel sizeToFit];
            totalHeight += centerLabel.frame.size.height;
        }
        return totalHeight + 80;
    } else {
        for (NSDictionary *dic in activity.subject) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [dic objectForKey:@"text"];
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            [label sizeToFit];
            if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(view.frame)) {
                label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                lineCount += 1;
            } else{
                CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
                CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
            }
            lastFrame = label.frame;
            width = CGRectGetMaxX(lastFrame);
            totalHeight = lineCount * label.frame.size.height;
        }
        return totalHeight + 50;
    }
}

- (void)buildActivityCellForType:(NSString *)type withActivity:(RTActivity *)activity
{
    self.frameHeight = 0;
    _activityForCell = activity;
    if (![activity.comment isEqualToString:@""] || [activity.activityType isEqualToString:@"comment"]) {
        self.hasComment = YES;
    }
    
    if (![activity.imageString isEqualToString:@""]) {
        self.hasImage = YES;
    }
    
    if (![activity.logoString isEqualToString:@""] && !activity.isBusinessActivity) {
        self.hasLogo = YES;
    }
    
    for (NSDictionary *subjectDict in self.activityForCell.subject) {
        if ([[subjectDict objectForKey:@"type"] isEqualToString:@"user"]) {
            NSDictionary *userNameDict = [subjectDict objectForKey:@"keys"];
            self.userId = [[userNameDict objectForKey:@"user_id"] intValue];
        }
    }
    
    // if there's no comment, build it with the logo offset
    
    if (self.hasLogo) {
        // there's a logo, but no comment, and no image
        CGRect lastFrame = CGRectZero;
        CGRect logoFrame = CGRectZero;
        CGFloat width = 0;
        int lineCount = 0;
        self.logoImageView = [[UIImageView alloc] init];
        [self.logoImageView setFrame:CGRectMake(kLogoDimensionSpacer, kLogoDimensionSpacer, kLogoDimension, kLogoDimension)];
        [self addSubview:self.logoImageView];
        logoFrame = self.logoImageView.frame;
        width = logoFrame.size.width;
        [self.logoImageView setImage:[UIImage imageNamed:@"placeholder_logo"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *logoUrl = activity.logoString;
            NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.logoImageView setBackgroundColor:[UIColor whiteColor]];
                [self.logoImageView setImage:[UIImage imageWithData:logoData]];
            });
        });
        for (NSDictionary *dic in self.activityForCell.subject) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [dic objectForKey:@"text"];
            if ([label.text isEqualToString:@"on"]) {
                [label setBackgroundColor:[UIColor redColor]];
            }
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            NSString *type = [dic objectForKey:@"type"];
            if ([type isEqualToString:@"discount"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discountTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
                NSDictionary *keys = [dic objectForKey:@"keys"];
                self.storeId = [[keys objectForKey:@"store_id"] integerValue];
                self.discountId = [[keys objectForKey:@"discount_id"] integerValue];
            }else if ([type isEqualToString:@"store"]) {
                NSDictionary *keys = [dic objectForKey:@"keys"];
                self.storeId = [[keys objectForKey:@"store_id"] integerValue];
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(storeTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            } else if ([type isEqualToString:@"user"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            }
            else {
                label.textColor = [UIColor blackColor];
            }
            [label sizeToFit];
            
            if (self.hasLogo) {
                CGFloat maxWidth = self.frame.size.width - 24 - kLogoDimension;
                if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(self.bounds) - 8) { // if the label reaches the end of the line, move it down
                    if (CGRectGetMaxY(lastFrame) >= CGRectGetMaxY(self.logoImageView.frame)) { // if the max Y of last label is >= logo maxY, move all the way to left
                        if (CGRectGetWidth(label.frame) >= maxWidth + kLogoDimensionSpacer) {
                            label.frame = CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(lastFrame), maxWidth + kLogoDimensionSpacer, label.frame.size.height);
                        } else {
                            if (CGRectGetWidth(label.frame) >= maxWidth)
                           label.frame = CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                        }
                        lineCount += 1;
                    } else {
                        if (CGRectGetWidth(label.frame) >= maxWidth) {
                            label.frame  = CGRectMake(kLogoDimension + kLogoDimensionSpacer + 4, CGRectGetMaxY(lastFrame) + 2, maxWidth, label.frame.size.height);
                        } else {
                            label.frame  = CGRectMake(kLogoDimension + kLogoDimensionSpacer + 4, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                        }
                        lineCount += 1;
                    }
                } else {
                    CGFloat startX = CGRectGetMaxX(lastFrame) > CGRectGetMaxX(self.logoImageView.frame) ? CGRectGetMaxX(lastFrame) + 2 : kLogoDimension + kLogoDimensionSpacer + 4;
                    CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                    label.frame  = CGRectMake(startX, startY, label.frame.size.width, label.frame.size.height);
                }
                [label setPreferredMaxLayoutWidth:maxWidth];
                label.lineBreakMode = NSLineBreakByTruncatingTail;
                [self addSubview:label];
                lastFrame = label.frame;
                width = CGRectGetMaxX(lastFrame);
                self.frameHeight = lineCount * label.frame.size.height;
            } else {
                CGFloat maxWidth = self.frame.size.width - 24;
                if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(self.bounds) - 8) {
                    label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                    lineCount += 1;
                } else{
                    CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
                    CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                    label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
                }
                [label setPreferredMaxLayoutWidth:maxWidth];
                label.lineBreakMode = NSLineBreakByTruncatingTail;
                [self addSubview:label];
                lastFrame = label.frame;
                NSLog(@"The line count is %i", lineCount);
                self.frameHeight = lineCount * label.frame.size.height;
            }
            width = CGRectGetMaxX(lastFrame);
        }
        
        
        
        // now if there's comment or image, build the comment or image
        if (self.hasComment || self.hasImage) {
            if (!self.hasImage) {
                self.centerTextLabel = [[UILabel alloc] init];
                [self.centerTextLabel setNumberOfLines:0];
                self.centerTextLabel.text = [NSString stringWithFormat:@"\"%@\"", activity.comment];
                if (![activity.comment isEqualToString:@""]) {
                    self.hasComment = YES;
                }
                CGFloat maxWidth = self.frame.size.width - 24;
                self.centerTextLabel.textColor = [UIColor blackColor];
                self.centerTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
                self.centerTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
                
                if (CGRectGetMaxY(logoFrame) > CGRectGetMaxY(lastFrame)) {
                    [self.centerTextLabel setFrame:CGRectMake(14, CGRectGetMaxY(logoFrame) + 4, maxWidth, CGRectGetHeight(self.centerTextLabel.frame))];
                } else {
                    [self.centerTextLabel setFrame:CGRectMake(14, CGRectGetMaxY(lastFrame) + 4, maxWidth, CGRectGetHeight(self.centerTextLabel.frame))];
                }
                [self.centerTextLabel setPreferredMaxLayoutWidth:maxWidth];
                [self.centerTextLabel sizeToFit];
                self.frameHeight += self.centerTextLabel.frame.size.height;
                // the comments will not have action
                [self addSubview:self.centerTextLabel];
                lastFrame = self.centerTextLabel.frame;
            } else {
                self.centerImageView = [[UIImageView alloc] init];
                self.commentString = activity.comment;
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedByUser:)];
                [tapRecognizer setNumberOfTapsRequired:1];
                self.commentTapRecognizer = tapRecognizer;
                [self.centerImageView setUserInteractionEnabled:YES];
                [self.centerImageView addGestureRecognizer:self.commentTapRecognizer];
                // now set the frame
                CGFloat maxWidth = self.frame.size.width - 24;
                if (CGRectGetMaxY(logoFrame) > CGRectGetMaxY(lastFrame)) {
                    [self.centerImageView setFrame:CGRectMake(14, CGRectGetMaxY(logoFrame) + 4, maxWidth, 2* lastFrame.size.height)];
                } else {
                    [self.centerImageView setFrame:CGRectMake(14, CGRectGetMaxY(lastFrame) + 4, maxWidth, 2* lastFrame.size.height)];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *imageUrl = activity.imageString;
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.commentImage = [UIImage imageWithData:imageData];
                        [self.centerImageView setImage:self.commentImage];
                    });
                });
                self.frameHeight += self.centerImageView.frame.size.height;
                self.centerImageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.centerImageView setClipsToBounds:YES];
                [self addSubview:self.centerImageView];
                lastFrame = self.centerImageView.frame;
            }
            self.createdTimeLabel = [[UILabel alloc] init];
            self.createdTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            self.createdTimeLabel.textColor = [UIColor blackColor];
            [self.createdTimeLabel setText:[self createTimeStringForActivity:activity]];
            [self.createdTimeLabel sizeToFit];
            [self.createdTimeLabel setFrame:CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(self.bounds) - CGRectGetHeight(self.createdTimeLabel.frame) - 8, self.createdTimeLabel.frame.size.width, self.createdTimeLabel.frame.size.height)];
            [self addSubview:self.createdTimeLabel];
        }
        // this is if there's a logo and no image, no comment
        self.createdTimeLabel = [[UILabel alloc] init];
        self.createdTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.createdTimeLabel.textColor = [UIColor blackColor];
        [self.createdTimeLabel setText:[self createTimeStringForActivity:activity]];
        [self.createdTimeLabel sizeToFit];
        if (CGRectGetMaxY(logoFrame) > CGRectGetMaxY(lastFrame)) {
            [self.createdTimeLabel setFrame:CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(self.bounds) - CGRectGetHeight(self.createdTimeLabel.frame) - 8, self.createdTimeLabel.frame.size.width, self.createdTimeLabel.frame.size.height)];
        } else {
            [self.createdTimeLabel setFrame:CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(self.bounds) - CGRectGetHeight(self.createdTimeLabel.frame) - 8, self.createdTimeLabel.frame.size.width, self.createdTimeLabel.frame.size.height)];
        }
        [self addSubview:self.createdTimeLabel];
    }
    else if (self.hasComment || self.hasImage) { // no logo, yes comment, or yes image
        // build it without the logo offset
        CGRect lastFrame = CGRectZero;
        CGFloat width = 0;
        int lineCount = 0;
        for (NSDictionary *dic in self.activityForCell.subject) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [dic objectForKey:@"text"];
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            NSString *type = [dic objectForKey:@"type"];
            if ([type isEqualToString:@"discount"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discountTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
                NSDictionary *keys = [dic objectForKey:@"keys"];
                self.storeId = [[keys objectForKey:@"store_id"] intValue];
                self.discountId = [[keys objectForKey:@"discount_id"] integerValue];
            }else if ([type isEqualToString:@"store"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(storeTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            } else if ([type isEqualToString:@"user"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            }
            else {
                label.textColor = [UIColor blackColor];
            }
            [label sizeToFit];
            CGFloat maxWidth = self.frame.size.width - 24;
            if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(self.bounds) - 8) {
                if (CGRectGetWidth(label.frame) > maxWidth) {
                    label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, maxWidth, label.frame.size.height);
                } else {
                   label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                }
                lineCount += 1;
            } else{
                CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
                CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
            }
            [label setPreferredMaxLayoutWidth:maxWidth];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            [self addSubview:label];
            lastFrame = label.frame;
            width = CGRectGetMaxX(lastFrame);
            self.frameHeight = lineCount * label.frame.size.height;
        }
        
        if (self.hasImage) {
            self.centerImageView = [[UIImageView alloc] init];
            self.commentString = activity.comment;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedByUser:)];
            self.commentTapRecognizer = tapRecognizer;
            [self.centerImageView setUserInteractionEnabled:YES];
            [self.centerImageView addGestureRecognizer:self.commentTapRecognizer];
            // now set the frame
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *imageUrl = activity.imageString;
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.commentImage = [UIImage imageWithData:imageData];
                    [self.centerImageView setImage:self.commentImage];
                });
            });
            CGFloat maxWidth = self.frame.size.width - 24;
            [self.centerImageView setFrame:CGRectMake(14, CGRectGetMaxY(lastFrame) + 4, maxWidth - 8, 2*lastFrame.size.height)];
            self.frameHeight += self.centerImageView.frame.size.height;
            self.centerImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.centerImageView setClipsToBounds:YES];
            [self addSubview:self.centerImageView];
            lastFrame = self.centerImageView.frame;
        } else {
            self.centerTextLabel = [[UILabel alloc] init];
            [self.centerTextLabel setNumberOfLines:0];
            self.centerTextLabel.text = [NSString stringWithFormat:@"\"%@\"", activity.comment];
            CGFloat maxWidth = self.frame.size.width - 24;
            self.centerTextLabel.textColor = [UIColor blackColor];
            self.centerTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
            self.centerTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [self.centerTextLabel setFrame:CGRectMake(14, CGRectGetMaxY(lastFrame) + 4, maxWidth, CGRectGetHeight(self.centerTextLabel.frame))];
            [self.centerTextLabel setPreferredMaxLayoutWidth:maxWidth];
            [self.centerTextLabel sizeToFit];
            self.frameHeight += self.centerTextLabel.frame.size.height;
            // the comments will not have action
            [self addSubview:self.centerTextLabel];
            lastFrame = self.centerTextLabel.frame;
        }
        
        self.createdTimeLabel = [[UILabel alloc] init];
        self.createdTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.createdTimeLabel.textColor = [UIColor blackColor];
        [self.createdTimeLabel setText:[self createTimeStringForActivity:activity]];
        [self.createdTimeLabel sizeToFit];
        [self.createdTimeLabel setFrame:CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(self.bounds) - CGRectGetHeight(self.createdTimeLabel.frame) - 8, self.createdTimeLabel.frame.size.width, self.createdTimeLabel.frame.size.height)];
        [self addSubview:self.createdTimeLabel];
    } else { // no logo, no image, no comment
        // build it without the logo offset
        CGRect lastFrame = CGRectZero;
        CGFloat width = 0;
        int lineCount = 0;
        CGFloat maxWidth = self.frame.size.width - 24;
        for (NSDictionary *dic in self.activityForCell.subject) {
            UILabel *label = [[UILabel alloc]init];
            label.text = [dic objectForKey:@"text"];
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            NSString *type = [dic objectForKey:@"type"];
            if ([type isEqualToString:@"discount"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discountTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
                NSDictionary *keys = [dic objectForKey:@"keys"];
                self.storeId = [[keys objectForKey:@"store_id"] intValue];
                self.discountId = [[keys objectForKey:@"discount_id"] integerValue];
            }else if ([type isEqualToString:@"store"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(storeTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            } else if ([type isEqualToString:@"user"]) {
                label.textColor = [UIColor roverTownColorDarkBlue];
                [label setUserInteractionEnabled:YES];
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedByUser:)];
                [label addGestureRecognizer:tapRecognizer];
            }
            else {
                label.textColor = [UIColor blackColor];
            }
            
            [label sizeToFit];
            if (width + CGRectGetWidth(label.frame) >= CGRectGetMaxX(self.bounds) - 8) {
                if (CGRectGetWidth(label.frame) > maxWidth) {
                    label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, maxWidth, label.frame.size.height);
                } else {
                    label.frame  = CGRectMake(12, CGRectGetMaxY(lastFrame) + 2, label.frame.size.width, label.frame.size.height);
                }
                lineCount += 1;
            } else{
                CGFloat startX = CGRectGetMaxX(lastFrame) > 12 ? CGRectGetMaxX(lastFrame) : 12;
                CGFloat startY = CGRectGetMinY(lastFrame) > 9 ? CGRectGetMinY(lastFrame) : 8;
                label.frame  = CGRectMake(startX + 2, startY, label.frame.size.width, label.frame.size.height);
            }
            [label setPreferredMaxLayoutWidth:maxWidth];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            [self addSubview:label];
            lastFrame = label.frame;
            width = CGRectGetMaxX(lastFrame);
            NSLog(@"The line count is %i", lineCount);
            self.frameHeight = lineCount * label.frame.size.height;
        }
        self.createdTimeLabel = [[UILabel alloc] init];
        self.createdTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.createdTimeLabel.textColor = [UIColor blackColor];
        [self.createdTimeLabel setText:[self createTimeStringForActivity:activity]];
        [self.createdTimeLabel sizeToFit];
        [self.createdTimeLabel setFrame:CGRectMake(kLogoDimensionSpacer, CGRectGetMaxY(self.bounds) - CGRectGetHeight(self.createdTimeLabel.frame) - 8, self.createdTimeLabel.frame.size.width, self.createdTimeLabel.frame.size.height)];
        [self addSubview:self.createdTimeLabel];
        
    }
}

- (NSString *)createTimeStringForActivity:(RTActivity *)activity {
    NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:[activity.createdTime longValue]];
    NSString *returnString = [NSString stringWithFormat:@"%@", dateValue.timeAgoSinceNow];
    return returnString;
}

- (void)prepareForReuse {
    self.commentImage = nil;
    self.logoImage = nil;
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 8;
    frame.size.height -= 8;
    frame.origin.x += 8;
    frame.size.width -= 2*8;
    [super setFrame:frame];
}

- (void)layoutSubviews {
    
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    [self buildActivityCellForType:_activityType withActivity:_activityForCell];
}

@end