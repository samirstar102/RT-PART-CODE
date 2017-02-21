//
//  RTDiscountCommentCell.m
//  RoverTown
//
//  Created by Sonny on 11/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountCommentCell.h"
#import "NSDate+Utilities.h"
#import "RTServerManager.h"
#import "NSDate+DateTools.h"

@interface RTDiscountCommentCell ()

@property (nonatomic) RTComment *comment;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *createdTimeLabel;
@property (nonatomic) UIImageView *commentImageView;

@property (nonatomic) BOOL reported;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL noComment;
@property (nonatomic) BOOL canDelete;

@property (nonatomic) UILabel *votesCount;

@property (nonatomic) UIImageView *reportedImageIcon;

@property (nonatomic) UIView *grayVoteLineView;

@property (nonatomic) UITapGestureRecognizer *imageTapGesture;
@property (nonatomic) UIImage *commentImage;
@property (nonatomic) UITapGestureRecognizer *upvoteRecognizer;
@property (nonatomic) UITapGestureRecognizer *downvoteRecognizer;
@property (nonatomic) UIView *upVoteView;
@property (nonatomic) UIView *downVoteView;

@end

@implementation RTDiscountCommentCell

- (instancetype)initWithComment:(RTComment *)comment delegate:(id<RTDiscountCommentCellDelegate>)delegate
{
    if (self = [super init]) {
        RTComment *commentForCell = [[RTComment alloc] init];
        commentForCell = comment;
        self.comment = commentForCell;
        
        BOOL isEmpty = [self isEmptyString:self.comment.commentString];
        if (isEmpty) {
            self.noComment = YES;
        }
        
        UILabel *userNameLabel = [[UILabel alloc] init];
        self.userNameLabel = userNameLabel;
        [self.userNameLabel setText:[NSString stringWithFormat:@"%@", self.comment.userName]];
        [self.userNameLabel setNumberOfLines:0];
        [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.userNameLabel];
        [self.userNameLabel sizeToFit];
        
        if (!self.noComment) {
            UILabel *commentLabel = [[UILabel alloc] init];
            self.commentLabel = commentLabel;
            [self.commentLabel setText:[NSString stringWithFormat:@"%@", self.comment.commentString]];
            [self.commentLabel setNumberOfLines:0];
            [self.commentLabel setBackgroundColor:[UIColor clearColor]];
            CGFloat maxWidth = self.frame.size.width - 56;
            [self.commentLabel setPreferredMaxLayoutWidth:maxWidth];
            self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [self addSubview:self.commentLabel];
        } else {
            UILabel *commentLabel = [[UILabel alloc] init];
            self.commentLabel = commentLabel;
            [self.commentLabel setText:[NSString stringWithFormat:@"No user comment."]];
            [self.commentLabel setNumberOfLines:0];
            [self.commentLabel setBackgroundColor:[UIColor clearColor]];
            CGFloat maxWidth = self.frame.size.width - 56;
            [self.commentLabel setPreferredMaxLayoutWidth:maxWidth];
            self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [self addSubview:self.commentLabel];
        }
        
        UILabel *createdTimeLabel = [[UILabel alloc] init];
        self.createdTimeLabel = createdTimeLabel;
        [self.createdTimeLabel setText:[self createTimeStringForComment:self.comment]];
        [self.createdTimeLabel setNumberOfLines:0];
        self.createdTimeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.createdTimeLabel];
        
        UIView *voteLineView = [[UIView alloc] init];
        self.grayVoteLineView = voteLineView;
        
        UILabel *votesLabel = [[UILabel alloc] init];
//        [votesLabel setText:[NSString stringWithFormat:@"%i", self.comment.totalVotes]];
        self.votesCount = votesLabel;
        
        UIButton *upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.upVoteButton = upVoteButton;
//        [self.upVoteButton addTarget:self action:@selector(upVoteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.upVoteButton];
        
        UIButton *downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.downVoteButton = downVoteButton;
//        [self.downVoteButton addTarget:self action:@selector(downVoteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downVoteButton];
        
        if (![comment.imageString isEqualToString:@""]) {
            UIImage *imageForcomment = [[UIImage alloc] init];
            self.commentImage = imageForcomment;
            UIImageView *commentImage = [[UIImageView alloc] init];
            self.commentImageView = commentImage;
            NSString *imageUrl = self.comment.imageString;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *dataForImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.commentImage = [UIImage imageWithData:dataForImage];
                    [self.commentImageView setImage:self.commentImage];
                });
            });
            [self addSubview:self.commentImageView];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedByUser:)];
            [tapRecognizer setNumberOfTapsRequired:1];
            self.imageTapGesture = tapRecognizer;
            [self.commentImageView setUserInteractionEnabled:YES];
            [self.commentImageView addGestureRecognizer:self.imageTapGesture];
            self.hasImage = YES;
        }
        else {
            self.hasImage = NO;
        }
        
        UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        reportButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        self.reportButton = reportButton;
        if (self.comment.canDelete) {
            [self.reportButton addTarget:self action:@selector(deleteTappedByUser) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.reportButton addTarget:self action:@selector(reportTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:self.reportButton];
        
        UIImageView *reportIconImage = [[UIImageView alloc] init];
        self.reportedImageIcon = reportIconImage;
        [self addSubview:self.reportedImageIcon];
        
        self.layer.cornerRadius = 2;
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        
        UITapGestureRecognizer *upRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upVoteTappedForRecognizer:)];
        [upRec setNumberOfTapsRequired:1];
        self.upvoteRecognizer = upRec;
        
        UITapGestureRecognizer *downRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downVoteTappedForRecognizer:)];
        [downRec setNumberOfTapsRequired:1];
        self.downvoteRecognizer = downRec;
        
        UIView *upView = [[UIView alloc] init];
        self.upVoteView = upView;
        
        UIView *downView = [[UIView alloc] init];
        self.downVoteView = downView;
    }
    return self;
}

-(BOOL)isEmptyString:(NSString*)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedString isEqualToString:@""] || [trimmedString isEqualToString:@"(null)"]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)createTimeStringForComment:(RTComment *)comment{
    NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:[comment.createdTime longValue]];
    NSString *formattedString = [NSString stringWithFormat:@"%@", dateValue.timeAgoSinceNow];
    return formattedString;
}

- (void)layoutSubviews {
    [self.userNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    self.userNameLabel.textColor = [UIColor roverTownColorDarkBlue];
    [self.userNameLabel setFrame:CGRectMake(8, 8, CGRectGetWidth(self.userNameLabel.frame), CGRectGetHeight(self.userNameLabel.frame))];
    
    if (self.hasImage && !self.noComment) { // there's an image and a comment
        [self.commentImageView setFrame:CGRectMake(8, CGRectGetMaxY(self.userNameLabel.frame) + 4, CGRectGetWidth(self.frame) - 56, 40)];
        self.commentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.commentImageView setClipsToBounds:YES];
        [self.commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        self.commentLabel.textColor = [UIColor blackColor];
        [self.commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.userNameLabel.frame) + 50, CGRectGetWidth(self.frame) - 56, CGRectGetHeight(self.commentLabel.frame))];
        [self.commentLabel setBackgroundColor:[UIColor whiteColor]];
        [self.commentLabel setPreferredMaxLayoutWidth:self.commentLabel.frame.size.width];
        [self.commentLabel sizeToFit];
    }
    else if (self.hasImage && self.noComment) { // there's an image but no comment
        [self.commentImageView setFrame:CGRectMake(8, CGRectGetMaxY(self.userNameLabel.frame) + 4, CGRectGetWidth(self.frame) - 56, 40)];
        self.commentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.commentImageView setClipsToBounds:YES];
    }
    
    else if (!self.hasImage && !self.noComment) { // there's no image but a comment
        [self.commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        self.commentLabel.textColor = [UIColor blackColor];
        [self.commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.userNameLabel.frame) + 4, CGRectGetWidth(self.frame) - 56, CGRectGetHeight(self.commentLabel.frame))];
        [self.commentLabel setBackgroundColor:[UIColor whiteColor]];
        [self.commentLabel setPreferredMaxLayoutWidth:self.commentLabel.frame.size.width];
        [self.commentLabel sizeToFit];
    }
    
    else if (!self.hasImage && self.noComment) { // there's no image and no comment
        // This code should never run on dev because of my removal of ability to enter null string on submit
        [self.commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        self.commentLabel.textColor = [UIColor blackColor];
        [self.commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.userNameLabel.frame) + 4, CGRectGetWidth(self.frame) - 56, CGRectGetHeight(self.commentLabel.frame))];
        [self.commentLabel setBackgroundColor:[UIColor whiteColor]];
        [self.commentLabel setPreferredMaxLayoutWidth:self.commentLabel.frame.size.width];
        [self.commentLabel sizeToFit];
    }
    
    [self.grayVoteLineView setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:self.grayVoteLineView];
    [self.grayVoteLineView setFrame:CGRectMake(CGRectGetWidth(self.frame) - 40, 0, 1, CGRectGetHeight(self.frame))];
    
    [self.votesCount setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
    [self.votesCount setText:[NSString stringWithFormat:@"%i", self.comment.totalVotes]];
    if (self.comment.totalVotes < 0) {
        self.votesCount.textColor = [UIColor redColor];
    } else {
        self.votesCount.textColor = [UIColor blackColor];
    }
    [self.votesCount sizeToFit];
    [self addSubview:self.votesCount];
    [self.votesCount setFrame:CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.votesCount.frame)/2 - 20, CGRectGetHeight(self.frame)/2 - CGRectGetHeight(self.votesCount.frame)/2, CGRectGetWidth(self.votesCount.frame), CGRectGetHeight(self.votesCount.frame))];
    
    [self.upVoteButton setFrame:CGRectMake(CGRectGetWidth(self.frame) - 25, CGRectGetHeight(self.frame)/2 - CGRectGetHeight(self.votesCount.frame) - 8, 10, 10)];
    
    [self.upVoteView setFrame:CGRectMake(CGRectGetWidth(self.frame) - 40, 0, 40, CGRectGetHeight(self.frame)/2 - 10)];
    [self.upVoteView setBackgroundColor:[UIColor clearColor]];
    [self.upVoteView setUserInteractionEnabled:YES];
    [self.upVoteView addGestureRecognizer:self.upvoteRecognizer];
    [self addSubview:self.upVoteView];
    
    [self.downVoteButton setFrame:CGRectMake(CGRectGetWidth(self.frame) - 25, CGRectGetHeight(self.frame)/2 + CGRectGetHeight(self.votesCount.frame), 10, 10)];
    
    [self.downVoteView setFrame:CGRectMake(CGRectGetWidth(self.frame) - 40, CGRectGetHeight(self.frame)/2 + 10, 40, CGRectGetHeight(self.frame)/2 - 10)];
    [self.downVoteView setBackgroundColor:[UIColor clearColor]];
    [self.downVoteView setUserInteractionEnabled:YES];
    [self.downVoteView addGestureRecognizer:self.downvoteRecognizer];
    [self addSubview:self.downVoteView];
    
    if (self.comment.canDelete) {
        self.reportButton.userInteractionEnabled = YES;
        [self.reportButton setTitle:@"Delete" forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.reportedImageIcon setImage:[UIImage imageNamed:@"report_set"]];
    } else if (self.comment.reported) {
        self.reportButton.userInteractionEnabled = NO;
        [self.reportButton setTitle:@"Reported" forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.reportedImageIcon setImage:[UIImage imageNamed:@"report_set"]];
    } else {
        self.reportButton.userInteractionEnabled = YES;
        [self.reportButton setTitle:@"Report" forState:UIControlStateNormal];
        [self.reportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.reportedImageIcon setImage:[UIImage imageNamed:@"report_not_yet"]];
    }
    
    [self.reportButton sizeToFit];
    
    [self.createdTimeLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
    self.createdTimeLabel.textColor = [UIColor blackColor];
    [self.createdTimeLabel sizeToFit];
    
    if (self.hasImage && !self.noComment) { // image and comment
        [self.createdTimeLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.commentLabel.frame) + 4, CGRectGetWidth(self.createdTimeLabel.frame), CGRectGetHeight(self.createdTimeLabel.frame))];
        
        [self.reportedImageIcon setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + 10, CGRectGetMaxY(self.commentLabel.frame) + 7.5, 10, 10)];
        [self.reportButton setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + CGRectGetWidth(self.reportedImageIcon.frame) + 12, CGRectGetMaxY(self.commentLabel.frame) - 2.5, CGRectGetWidth(self.reportButton.frame), CGRectGetHeight(self.reportButton.frame))];
    }
    else if (self.hasImage && self.noComment) { // image and no comment
        [self.createdTimeLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.commentImageView.frame) + 4, CGRectGetWidth(self.createdTimeLabel.frame), CGRectGetHeight(self.createdTimeLabel.frame))];
        
        [self.reportedImageIcon setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + 10, CGRectGetMaxY(self.commentImageView.frame) + 7.5, 10, 10)];
        [self.reportButton setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + CGRectGetWidth(self.reportedImageIcon.frame) + 12, CGRectGetMaxY(self.commentImageView.frame) - 2.5, CGRectGetWidth(self.reportButton.frame), CGRectGetHeight(self.reportButton.frame))];
    }
    else if (!self.hasImage && !self.noComment) { //comment no image
        [self.createdTimeLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.commentLabel.frame) + 4, CGRectGetWidth(self.createdTimeLabel.frame), CGRectGetHeight(self.createdTimeLabel.frame))];
        
        [self.reportedImageIcon setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + 10, CGRectGetMaxY(self.commentLabel.frame) + 7.5, 10, 10)];
        [self.reportButton setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + CGRectGetWidth(self.reportedImageIcon.frame) + 12, CGRectGetMaxY(self.commentLabel.frame) - 2.5, CGRectGetWidth(self.reportButton.frame), CGRectGetHeight(self.reportButton.frame))];
    }
    else if (!self.hasImage && self.noComment) { // no comment no image
        // this should never be called, but needed for dev environment
        [self.createdTimeLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.commentLabel.frame) + 4, CGRectGetWidth(self.createdTimeLabel.frame), CGRectGetHeight(self.createdTimeLabel.frame))];
        
        [self.reportedImageIcon setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + 10, CGRectGetMaxY(self.commentLabel.frame) + 7.5, 10, 10)];
        [self.reportButton setFrame:CGRectMake(CGRectGetWidth(self.createdTimeLabel.frame) + CGRectGetWidth(self.reportedImageIcon.frame) + 12, CGRectGetMaxY(self.commentLabel.frame) - 2.5, CGRectGetWidth(self.reportButton.frame), CGRectGetHeight(self.reportButton.frame))];
    }
    if (self.comment.voted == 1) {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_blue"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];
    } else if (self.comment.voted == 0) {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];
    } else if (self.comment.voted == -1) {
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_red"] forState:UIControlStateNormal];
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];
    }
}

-(void)loadVoteCounts {
    if (self.comment.voted == 1) {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_blue"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];

    } else if (self.comment.voted == 0) {
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];

    } else if (self.comment.voted == -1) {
        [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_red"] forState:UIControlStateNormal];
        [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];

    }
}

- (void)updateVoteButtons {
        if (self.comment.voted == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_blue"] forState:UIControlStateNormal];
                [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];
                self.votesCount.textColor = [UIColor roverTownColorDarkBlue];
                [self.votesCount setText:[NSString stringWithFormat:@"%i", self.comment.totalVotes]];
            });
        }
        else if (self.comment.voted == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];
                [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_neutral"] forState:UIControlStateNormal];
                self.votesCount.textColor = [UIColor blackColor];
                [self.votesCount setText:[NSString stringWithFormat:@"%i", self.comment.totalVotes]];
            });
            
        } else if (self.comment.voted == -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.upVoteButton setImage:[UIImage imageNamed:@"up_vote_neutral"] forState:UIControlStateNormal];
                [self.downVoteButton setImage:[UIImage imageNamed:@"down_vote_red"] forState:UIControlStateNormal];
                self.votesCount.textColor = [UIColor redColor];
                [self.votesCount setText:[NSString stringWithFormat:@"%i", self.comment.totalVotes]];
            });
        }
}

-(void)upVoteTappedForRecognizer:(UITapGestureRecognizer*)tapRecognizer {
    if (self.delegate != nil) {
        [Flurry logEvent:@"user_comment_upvote"];
        if (self.comment.voted >= -1) {
            int oldVoted = self.comment.voted;
            self.comment.voted = self.comment.voted == 1 ? 0 : 1;
            if (oldVoted == -1 && self.comment.voted == 1) {
                self.comment.totalVotes += 2;
            }else if (self.comment.voted == 0){
                self.comment.totalVotes -=1;
            }else {
                self.comment.totalVotes +=1;
            }
            [self.delegate votingActivityStarted];
            [[RTServerManager sharedInstance] updateDiscountCommentForComment:self.comment.commentId withReport:0 andVote:self.comment.voted complete:^(BOOL success, RTAPIResponse *response) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setNeedsLayout];
                        [self.delegate discountUpdateSuccess];
                        
                    });
                } else {
                    // give an error about networking
                }
            }];
        }
    }
}

-(void)downVoteTappedForRecognizer:(UITapGestureRecognizer*)tapRecognizer {
    if (self.delegate != nil) {
        [Flurry logEvent:@"user_comment_downvote"];
        if (self.comment.voted <= 1) {
            int oldvoted = self.comment.voted;
            self.comment.voted = self.comment.voted == -1 ? 0 : -1;
            if (oldvoted == 1 && self.comment.voted == -1) {
                self.comment.totalVotes += -2;
            }else if (self.comment.voted == 0) {
                self.comment.totalVotes +=1;
            }else {
                self.comment.totalVotes -=1;
            }
            [self.delegate votingActivityStarted];
            [[RTServerManager sharedInstance] updateDiscountCommentForComment:self.comment.commentId withReport:0 andVote:self.comment.voted complete:^(BOOL success, RTAPIResponse *response) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setNeedsLayout];
                        [self.delegate discountUpdateSuccess];

                    });
                } else {
                    // give an error about networking
                }
            }];
        }
    }
}

- (IBAction)reportTapped:(id)sender {
    if (self.delegate != nil) {
        self.reportButton.userInteractionEnabled = NO;
        [self.delegate reportingActvityStarted];
        [[RTServerManager sharedInstance] updateDiscountCommentForComment:self.comment.commentId withReport:1 andVote:self.comment.voted complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.comment.reported = YES;
                    [self.delegate discountUpdateSuccess];
                    [self setNeedsLayout];
                });
                
            } else {
                
            }
        }];
    }
}

-(void)deleteTappedByUser {
    if (self.delegate != nil) {
        [self.delegate deleteTappedWithCommentId:self.comment.commentId];
    }
}

-(void)imageTappedByUser:(UITapGestureRecognizer*)recognizer {
    if (self.delegate != nil) {
        if (self.noComment) {
            [self.delegate imageTappedForImage:self.commentImage];
        } else {
            [self.delegate imageTappedForImage:self.commentImage andComment:self.comment.commentString];
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.upVoteButton setImage:nil forState:UIControlStateNormal];
    [self.downVoteButton setImage:nil forState:UIControlStateNormal];
    [self loadVoteCounts];
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 12;
    frame.size.height -= 2*6;
    frame.origin.x += 12;
    frame.size.width -= 2*12;
    [super setFrame:frame];
}

@end
