//
//  RTDiscountCommentCell.h
//  RoverTown
//
//  Created by Sonny on 11/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTComment.h"

@class RTDiscountCommentCell;

@protocol RTDiscountCommentCellDelegate <NSObject>

-(void)imageTappedForImage:(UIImage *)image;
-(void)imageTappedForImage:(UIImage *)image andComment:(NSString*)comment;
-(void)discountUpdateSuccess;
-(void)votingActivityStarted;
-(void)reportingActvityStarted;
-(void)deleteTappedWithCommentId:(int)commentId;

@end

@interface RTDiscountCommentCell : UITableViewCell

- (instancetype) initWithComment:(RTComment *)comment delegate:(id<RTDiscountCommentCellDelegate>)delegate;
@property (nonatomic) UILabel *commentLabel;
@property (nonatomic, weak) id<RTDiscountCommentCellDelegate>delegate;
@property (nonatomic) IBOutlet UIButton *upVoteButton;
@property (nonatomic) IBOutlet UIButton *downVoteButton;
@property (nonatomic) UIButton *reportButton;
@property (nonatomic) NSIndexPath* privateIndexPath;
-(void)loadVoteCounts;

@end
