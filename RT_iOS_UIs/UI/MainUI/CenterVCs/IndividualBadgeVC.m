//
//  IndividualBadgeVC.m
//  RoverTown
//
//  Created by Robin Denis on 7/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "IndividualBadgeVC.h"
#import "RTUIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MessageUI/MessageUI.h>
#import <TwitterKit/TwitterKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface IndividualBadgeVC () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>
{
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForShareView;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivBadgeImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnExit;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (nonatomic) UIView *viewToCaptureTaps;

@end

@implementation IndividualBadgeVC

@synthesize badge;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initEvent];
}

- (void)initView {
    [self.ivBadgeImage sd_setImageWithURL:[NSURL URLWithString:badge.urlForBadgeImage] placeholderImage:[UIImage imageNamed:@"placeholder_logo"]];
    
    //Initialize Badge Name label
    [self.lblName setText:badge.name];
    
    //Initialize Badge Description label
    [self.lblDescription setText:badge.descriptionForBadge];
    
    //Initialize Share button
    [RTUIManager applyWhiteButtonStyle:self.btnShare
                             tintColor:badge.backgroundColor
                                 alpha:1.0f];
    
    //Initialize Exit button
    [RTUIManager applyWhiteButtonStyle:self.btnExit
                             tintColor:badge.backgroundColor
                                 alpha:0.6];
    
    //Initialize share view
    [self hideShareViewWithAnimated:NO];
    
    [self.view setBackgroundColor:badge.backgroundColor];
}

- (void)initEvent {
    self.viewToCaptureTaps = [[UIView alloc] initWithFrame:self.view.frame];
    CGRect frame = self.viewToCaptureTaps.frame;
    [self.viewToCaptureTaps setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.shareView.bounds.size.height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideShareView)];
    [self.viewToCaptureTaps addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    //Initialize share view
    [RTUIManager applyBlurView:self.shareView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (void)showShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    [self.view addSubview:self.viewToCaptureTaps];
    
    if( bottomConstraintForShareView.constant != 0 ) {
        bottomConstraintForShareView.constant = 0;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)hideShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    [self.viewToCaptureTaps removeFromSuperview];
    
    if( bottomConstraintForShareView.constant == 0 ) {
        bottomConstraintForShareView.constant = 0 - self.shareView.frame.size.height;
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}


#pragma mark - Actions

- (IBAction)onTapShareButton:(id)sender {
    [self showShareViewWithAnimated:YES];
}

- (IBAction)onTapExitButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelSharingButton:(id)sender {
    [self hideShareViewWithAnimated:YES];
}

- (void)hideShareView {
    [self hideShareViewWithAnimated:YES];
}

#pragma mark - sharing

- (IBAction)onMessageShareButton:(id)sender {
    //check if the device is able to send sms
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *contentTextForShare = @"";
    
    if( badge != nil ) {
        contentTextForShare = badge.shareCopy;
        contentTextForShare = [contentTextForShare stringByReplacingOccurrencesOfString:@"@rovertown" withString:@"http://www.rovertown.com"];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:nil];
    [messageController setBody:contentTextForShare];
    messageController.messageComposeDelegate = self;
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)onMailShareButton:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    NSString *subjectForShare = @"";
    NSString *contentTextForShare = @"";
    
    if( badge != nil ) {
        subjectForShare = @"Just earned a badge on RoverTown";
        contentTextForShare = badge.shareCopy;
        contentTextForShare = [contentTextForShare stringByReplacingOccurrencesOfString:@"@rovertown" withString:@"http://www.rovertown.com"];
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:subjectForShare];
    [mailController setMessageBody:contentTextForShare isHTML:NO];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)onTwitterShareButton:(id)sender {
    @try {
        if( badge != nil ) {
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:badge.urlForBadgeImage]]]];
            [composer setText:badge.shareCopy];
            
            [composer showFromViewController:self completion:^(TWTRComposerResult result){
                if( result == TWTRComposerResultDone ) {

                }
                
                [self hideShareViewWithAnimated:YES];
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)onFacebookShareButton:(id)sender {
    @try {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if( badge != nil ) {
            content.contentURL = [NSURL URLWithString:@"http://rovertown.com"];
            content.contentDescription = badge.shareCopy;
            content.imageURL = [NSURL URLWithString:badge.urlForBadgeImage];
           // NSLog(badge.urlForBadgeImage);
            
            
        }
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

#pragma mark - Message UI Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if( result == MessageComposeResultSent ) {
        [self hideShareViewWithAnimated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if( result == MFMailComposeResultSent ) {
        [self hideShareViewWithAnimated:YES];
    }
}

#pragma mark - Facebook Delegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

@end
