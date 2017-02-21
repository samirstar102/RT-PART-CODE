//
//  SupportAboutCell.h
//  RoverTown
//
//  Created by Robin Denis on 6/6/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

@class SupportAboutCell;
@class SupportAboutHeaderVC;

#pragma mark - Cell View for About Using This App Table View

@protocol SupportAboutCellDelegate <NSObject>

-(void) onBackToTopButton;

@end

@interface SupportAboutCell : UITableViewCell

+ (CGFloat)heightForCellWithQuestion:(NSString*)question answer:(NSString*)answer;

- (void)bind:(NSString*)question answer:(NSString*)answer  isLast:(BOOL)isLast;

@property (nonatomic, weak) id<SupportAboutCellDelegate> delegate;

@end


#pragma mark - Header View for About Using This App Table View

@protocol SupportAboutHeaderVCDelegate <NSObject>

- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onSubmitReferralCode:(NSString*)referralCode;
- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onQuestionSelected:(NSString*)question index:(int)index;
- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onReferralCodeInvalidForTheFirstTime:(NSString *)referralCode;

@end

@interface SupportAboutHeaderVC : UIViewController

- (float)getHeightForViewAfterBindingWithQuestionArray:(NSMutableArray *)questionArray;

@property (nonatomic, weak) id<SupportAboutHeaderVCDelegate> delegate;

@end
