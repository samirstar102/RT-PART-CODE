//
//  RTShareViewController.m
//  RoverTown
//
//  Created by Roger Jones Jr on 9/13/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTShareViewController.h"
#import <TwitterKit/TwitterKit.h>
#import <MessageUI/MessageUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "RTShareView.h"
#import "RTServerManager.h"
#import "RTShareModel.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "CenterViewControllerBase.h"

@interface RTShareViewController ()<RTShareViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate, RTSharViewModelDelegate>

@property (nonatomic) RTShareView *shareView;
@property (nonatomic) RTShareModel *model;
@end

@implementation RTShareViewController

- (instancetype)initWithDiscount:(RTStudentDiscount *) discount {
    if (self = [self initWithShareType:RTShareType_Discount]) {
        [_model setDiscountToShare:discount];
    }
    return self;
}

- (instancetype)initWithShareType:(RTShareType)shareType
{
    self = [super init];
    if (self) {
        
        self.shareView = [[RTShareView alloc]init];
        self.shareView.delegate = self;
        self.view = self.shareView;
        
        if (!self.model) {
            self.model = [[RTShareModel alloc]initWithShareType:shareType delegate:self];
        }
    }
    return self;
}


- (void)setTitleText:(NSString *)titleText {
    [self.shareView setTitleText:titleText];
}

- (void)message {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:nil];
    [messageController setBody:self.model.shareContent];
    messageController.messageComposeDelegate = self;
    self.model.platform = @"sms";
    [self presentViewController:messageController animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent) {
            [self shareSent];
        }
    }];
    
}

-(void)mail {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:@"RoverTown Student Discounts"];
    [mailController setMessageBody:self.model.shareContent isHTML:NO];
    mailController.mailComposeDelegate = self;
    self.model.platform = @"mail";
    [self presentViewController:mailController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            [self shareSent];
        }
    }];
}

-(void)twitter {
    @try {
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setText:self.model.shareContent];
            [composer showFromViewController:self completion:^(TWTRComposerResult result){
                [self dismissViewControllerAnimated:YES completion:^{
                    if (result ==TWTRComposerResultDone) {
                        self.model.platform = @"twitter";
                        [self shareSent];
                    }
                }];
            }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

-(void)facebook {
    @try {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentTitle = @"RoverTown Student Discount App";
        content.contentURL = [NSURL URLWithString:self.model.shareURL];
        content.contentDescription = self.model.shareContent;
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [self shareSent];
}


- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [self showShareViewFromView:self.shareView.superview];
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

-(void)cancel {
    [self hideShareView];
}

- (void)shareSent {
    [self.model sendShare];
    [self  hideShareView];
}

- (void)showShareViewFromView:(UIView *)parentView {
    CGRect shareStartFrame = parentView.bounds;
    shareStartFrame.origin.y = CGRectGetHeight(parentView.frame);
    [self.shareView setFrame:shareStartFrame];
    [parentView addSubview:self.shareView];
    
    CGRect shareEndFrame = parentView.bounds;
    if (shareEndFrame.origin.y != 0 ) {
        shareEndFrame.size.height = shareEndFrame.size.height - shareEndFrame.origin.y;
        shareEndFrame.origin.y = 0;
    }
    [UIView animateWithDuration:0.35 animations:^{
        [self.shareView setFrame:shareEndFrame];
    }];
}

- (void)hideShareView {
    CGRect shareFrame = self.shareView.frame;
    shareFrame.origin.y = CGRectGetMaxY(shareFrame);
    [UIView animateWithDuration:0.35 animations:^{
        [self.shareView setFrame:shareFrame];
    }];
}

- (void)boneCountUpdated:(BOOL)boneDiff badgeCountUpdated:(BOOL)badgeDiff {
    dispatch_async(dispatch_get_main_queue(), ^{
            if(boneDiff && badgeDiff) {
                    [self playBoneAnimationWithComplettion:^{
                        [self updaeBoneCount];
                        [self playBoneAnimationWithComplettion:^{
                            [self badgeCompletion];
                        }];
                    }];
            }else if(boneDiff) {
                [self playBoneAnimationWithComplettion:^{
                    [self boneCompletion];
                }];
            }
            else if (badgeDiff) {
                [self playBadgeAnimationWithCompletion:^{
                    [self badgeCompletion];
                }];
            }
    });
}
- (void)playBoneAnimationWithComplettion:(dispatch_block_t)completeBlock {
    [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:^{
        if (completeBlock) {
            completeBlock();
        }
    }];

}

- (void)updaeBoneCount {
    UIViewController *viewController = self.parentViewController;
    if ([viewController isKindOfClass:[CenterViewControllerBase class]]) {
            [(CenterViewControllerBase *)viewController setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
    }else if([viewController.parentViewController isKindOfClass:[CenterViewControllerBase class]]){
        viewController = viewController.presentingViewController;
        [(CenterViewControllerBase *)viewController setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
    }
    
}

- (void)boneCompletion {
    [self updaeBoneCount];
    [self done];
}

- (void)playBadgeAnimationWithCompletion:(dispatch_block_t)completeBlock {
    [RTUIManager playEarnBadgeAnimationWithSuperview:self.navigationController.view completeBlock:^{
        if (completeBlock) {
            completeBlock();
        }
    }];

}

- (void)badgeCompletion {
    UIViewController *viewController = self.parentViewController;
    if ([viewController isKindOfClass:[CenterViewControllerBase class]]) {
        [(CenterViewControllerBase *)viewController setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
    }else if([viewController.parentViewController isKindOfClass:[CenterViewControllerBase class]]){
        viewController = viewController.presentingViewController;
        [(CenterViewControllerBase *)viewController setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
    }
    [self done];

}

- (void)done {
    if (self.delegate) {
        [self.delegate shareViewControllerDone];
    }

}
@end
