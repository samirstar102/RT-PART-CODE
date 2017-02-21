//
//  DollarsForDownloadsVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "DollarsForDownloadsVC.h"
#import "DollarsForDownloadsMessageVC.h"
#import "DollarsForDownloadsCodeVC.h"

#import "LeftNavViewController.h"
#import "RTStoryboardManager.h"
#import "SessionMgr.h"
#import "RTServerManager.h"
#import "RTUIManager.h"
#import "RTModelBridge.h"
#import "SupportVC.h"
#import "RTUserContext.h"

#import <MessageUI/MessageUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Twitter/Twitter.h>
#import <TwitterKit/TwitterKit.h>

#import "UIViewController+MMDrawerController.h"

#define kReferralShareCopy @"Click to download RoverTown and we get $1!\nSave $ with the app, make $ sharing the love."

@interface DollarsForDownloadsVC () <DollarsForDownloadsMessageVCDelegate, DollarsForDownloadsCodeVCDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>
{
    RTReferral *referralForShare;
    UIViewController *currentViewController;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForShareView;
}

@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIView *vwShare;
@property (weak, nonatomic) IBOutlet UIButton *btnShareCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnShareMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnShareMail;
@property (weak, nonatomic) IBOutlet UIButton *btnShareTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnShareFacebook;


@property (weak, nonatomic) NSString *referralCodeToShare;

@end

@implementation DollarsForDownloadsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"referral"] != nil) {
        [Flurry logEvent:@"user_dollars_view"];
        referralForShare = [self loadReferralObjectFromKey:@"referral"];
        [self showReferralCodeViewWithAnimated:NO referral:referralForShare];
    } else {
    
        [self showReferralMessageViewWithAnimated:NO];
    }
}

- (void)initViews {
    [super initViews];
    
    [self hideShareViewWithAnimated:NO];
}

- (void)initEvents {
    [super initEvents];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideShareView)];
    [self.navigationController.view addGestureRecognizer:tap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [RTUIManager applyBlurView:self.vwShare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Manipulation

- (void)showReferralMessageViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    DollarsForDownloadsMessageVC *vc = (DollarsForDownloadsMessageVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIDollarsForDownloadsMessageVC storyboardName:kStoryboardDollarsForDownloads];
    vc.delegate = self;
    vc.view.frame = self.vwContainer.bounds;
    [vc.view setAlpha:0.0f];
    [self.vwContainer addSubview:vc.view];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = vc;
            
            [UIView animateWithDuration:duration animations:^{
                [vc.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = vc;
        
        [UIView animateWithDuration:duration animations:^{
            [vc.view setAlpha:1.0f];
        }];
    }
}

- (void)showReferralCodeViewWithAnimated:(BOOL)animated referral:(RTReferral *)referral {
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    DollarsForDownloadsCodeVC *vc = (DollarsForDownloadsCodeVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIDollarsForDownloadsCodeVC storyboardName:kStoryboardDollarsForDownloads];
    vc.referral = referral;
    self.referralCodeToShare = referral.code;
    vc.delegate = self;
    vc.view.frame = self.vwContainer.bounds;
    [vc.view setAlpha:0.0f];
    [self.vwContainer addSubview:vc.view];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    
    if( currentViewController != nil ) {
        [UIView animateWithDuration:duration animations:^{
            [currentViewController.view setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            currentViewController = vc;
            
            [UIView animateWithDuration:duration animations:^{
                [vc.view setAlpha:1.0f];
            }];
        }];
    }
    else {
        currentViewController = vc;
        
        [UIView animateWithDuration:duration animations:^{
            [vc.view setAlpha:1.0f];
        }];
    }
}

- (void)moveToSupportVC {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_About];
    SupportVC *aboutVC = (SupportVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportVC storyboardName:kStoryboardSupport];
    [self.navigationController pushViewController:aboutVC animated:YES];
    
    LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
    [leftNavVC.tableView reloadData];
}

- (void)showShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    bottomConstraintForShareView.constant = 0.0f;
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideShareView {
    [self hideShareViewWithAnimated:YES];
}

- (void)hideShareViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    
    if( animated )
        duration = 0.2f;
    
    if( bottomConstraintForShareView.constant == 0 ) {
        bottomConstraintForShareView.constant = 0 - self.vwShare.frame.size.height;
        
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - DollarsForDownloadsMessageVC Delegate

- (void)dollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc onTermsAndConditionsLinkTappedWithAnimated:(BOOL)animated {
    [self moveToSupportVC];
}

-(void)dollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc onGenerateMyCodeButtonTappedWithAnimated:(BOOL)animated {
    [[RTUIManager sharedInstance] showProgressHUDWithViewController:self.navigationController labelText:@"Please wait..."];
    
    [[RTServerManager sharedInstance] getReferralCode:^(BOOL success, RTAPIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[RTUIManager sharedInstance] hideProgressHUDWithViewController:self.navigationController];
            
            if( success ) {
                NSDictionary *dicReferral = [response.jsonObject objectForKey:@"referral"];
                RTReferral *referral = [RTModelBridge getReferralWithDictionary:dicReferral];
                [self saveCustomObject:referral forKey:@"referral"];
                [self showReferralCodeViewWithAnimated:YES referral:referral];
            }
            else {
                //
            }
        });
    }];
}

#pragma mark - DollarsForDownloadsCodeVC Delegate

- (void)dollarsForDownloadsCodeVC:(DollarsForDownloadsCodeVC *)vc onTermsAndConditionsLinkTappedWithAnimated:(BOOL)animated {
    [self moveToSupportVC];
}

- (void)dollarsForDownloadsCodeVC:(DollarsForDownloadsCodeVC *)vc onShareButtonTappedWithReferralCode:(RTReferral *)referral {
    referralForShare = referral;
    [self showShareViewWithAnimated:YES];
}

#pragma mark - Actions

- (IBAction)onShareMessageButtonClicked:(id)sender {
    //check if the device is able to send sms
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support SMS!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *contentTextForShare = @"";
    
    if( referralForShare != nil ) {
        [Flurry logEvent:@"user_dollars_share"];
        contentTextForShare = [NSString stringWithFormat:@"Click to download RoverTown and I get $1! Use referral code %@. Save $ with the app, make $ sharing the love. %@", self.referralCodeToShare, referralForShare.share_url];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:nil];
    [messageController setBody:contentTextForShare];
    messageController.messageComposeDelegate = self;
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)onShareMailButtonClicked:(id)sender {
    
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caution" message:@"Your device doesn't support email!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    NSString *subjectForShare = @"";
    NSString *contentTextForShare = @"";
    
    if( referralForShare != nil ) {
        [Flurry logEvent:@"user_dollars_share"];
        subjectForShare = @"RoverTown Referral";
        contentTextForShare = [NSString stringWithFormat:@"Click to download RoverTown and I get $1! Use referral code %@. Save $ with the app, make $ sharing the love. %@", self.referralCodeToShare, referralForShare.share_url];
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:subjectForShare];
    [mailController setMessageBody:contentTextForShare isHTML:NO];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)onShareTwitterButtonClicked:(id)sender {
    @try {
        NSString *contentTextForShare = [NSString stringWithFormat:@"Click to download RoverTown and I get $1! Use referral code %@. Save $ with the app, make $ sharing the love.", self.referralCodeToShare];
        
        if( referralForShare != nil ) {
//            contentTextForShare = kReferralShareCopy;
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setURL:[NSURL URLWithString:referralForShare.share_url]];
            [composer setText:contentTextForShare];
            
            [composer showFromViewController:self completion:^(TWTRComposerResult result){
                if( result == TWTRComposerResultDone ) {
                    [Flurry logEvent:@"user_dollars_share"];
                    [self hideShareViewWithAnimated:YES];
                }
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)onShareFacebookButtonClicked:(id)sender {
    @try {
        NSString *contentTextForShare = @"";
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        if( referralForShare != nil ) {
            [Flurry logEvent:@"user_dollars_share"];
            contentTextForShare = kReferralShareCopy;
            content.contentURL = [NSURL URLWithString:referralForShare.share_url];
            content.contentDescription = contentTextForShare;
        }
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

- (IBAction)onShareCancelButtonClicked:(id)sender {
    [self hideShareViewWithAnimated:YES];
}

#pragma mark - MFMailComposeViewController, MFMessageComposeViewController Delegates

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    if( result == MessageComposeResultSent ) {
        [self hideShareViewWithAnimated:YES];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    if( result == MFMailComposeResultSent ) {
        [self hideShareViewWithAnimated:YES];
    }
}

#pragma mark - FBSDKSharingDelegate

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [self hideShareViewWithAnimated:YES];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    return;
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    return;
}

#pragma mark - NSUserDefaults

-(void)saveCustomObject:(RTReferral *)object forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

- (RTReferral *)loadReferralObjectFromKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    RTReferral *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
