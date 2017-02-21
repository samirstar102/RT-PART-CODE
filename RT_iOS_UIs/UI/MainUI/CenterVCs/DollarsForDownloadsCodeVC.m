//
//  DollarsForDownloadsCodeVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "DollarsForDownloadsCodeVC.h"
#import "DollarsForDownloadsMessageVC.h"

#import "RTUIManager.h"
#import "UIColor+Config.h"
#import "RTDollarsInstructionsViewController.h"
#import "RTServerManager.h"
#import "RTAPIResponse.h"
#import "RTModelBridge.h"
#import "RTReferral.h"
#import "RTStoryboardManager.h"

@interface DollarsForDownloadsCodeVC () <UITextViewDelegate, DollarsForDownloadsMessageVCDelegate>

{
    __weak IBOutlet NSLayoutConstraint *heightConstraintForTermsAndConditions;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForPaymentInstruction;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForPaymentInstruction;
}

@property (weak, nonatomic) IBOutlet UIView *vwUpperFrame;
@property (weak, nonatomic) IBOutlet UIView *vwBottomFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UILabel *lblReferralCode;
@property (weak, nonatomic) IBOutlet UIProgressView *pvPayoutProgress;
@property (weak, nonatomic) IBOutlet UILabel *lblPayoutProgress;
@property (weak, nonatomic) IBOutlet UIView *vwCurrentBalance;
@property (weak, nonatomic) IBOutlet UIView *vwTotalEarning;
@property (weak, nonatomic) IBOutlet UITextView *txtTermsAndConditions;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentBalanceDollarSymbol;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalEarningDollarSymbol;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalEarning;

@property (weak, nonatomic) DollarsForDownloadsMessageVC *messageVC;
@property (weak, nonatomic) UIView *messageContainerView;

@end

@implementation DollarsForDownloadsCodeVC

@synthesize referral;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    [self initEvents];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pullReferralCodeWithCurrentProgress];
}

- (void)initViews {
    [RTUIManager applyContainerViewStyle:self.vwUpperFrame];
    [RTUIManager applyContainerViewStyle:self.vwBottomFrame];
    [RTUIManager applyRedeemDiscountButtonStyle:self.btnShare];
    [self.btnShare.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.lblReferralCode setText:referral.code];
    [self.lblReferralCode setUserInteractionEnabled:YES];
    
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.lblReferralCode addGestureRecognizer:gestureRecognizer];
    
    self.pvPayoutProgress.layer.cornerRadius = 12.0f;
    self.pvPayoutProgress.layer.masksToBounds = YES;
    self.pvPayoutProgress.clipsToBounds = YES;
    
    self.vwCurrentBalance.layer.borderWidth = 0.5f;
    self.vwCurrentBalance.layer.borderColor = [UIColor roverTownColor6DA6CE].CGColor;
    self.vwCurrentBalance.layer.cornerRadius = 2 * kCornerRadiusDefault;
    
    self.vwTotalEarning.layer.borderWidth = 0.5f;
    self.vwTotalEarning.layer.borderColor = [UIColor roverTownColor6DA6CE].CGColor;
    self.vwTotalEarning.layer.cornerRadius = 2 * kCornerRadiusDefault;
 
    [self setNumberOfRemainingDownloadsWithNumber];
    
    [self buildTermsAndConditionsTextviewFromString:[NSString stringWithFormat:@"Whenever you rack up $%d we\'ll send you cash using Venmo, a free payment service. For more info, view the terms and conditions.", referral.payout_threshold]];
}

- (void)initEvents {
    [self setCurrentBalance:referral.current_balance];
    [self setTotalEarning:referral.total_earned];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Manipulations

- (void)buildTermsAndConditionsTextviewFromString:(NSString *)localizedString {
    [self.txtTermsAndConditions setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:localizedString];
    [str addAttribute:NSLinkAttributeName value:@"http://rovertown.com" range:NSMakeRange(106, 20)];
    [str addAttribute:NSFontAttributeName value:REGFONT15 range:NSMakeRange(0, localizedString.length)];
    self.txtTermsAndConditions.attributedText = str;
    
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 56, 200)];
    [lblTemp setFont:REGFONT15];
    [lblTemp setNumberOfLines:0];
    [lblTemp setText:localizedString];
    [lblTemp sizeToFit];
    
    heightConstraintForTermsAndConditions.constant = lblTemp.bounds.size.height + 16;
    [self.view layoutIfNeeded];
}

- (void)setNumberOfRemainingDownloadsWithNumber {
    [self.pvPayoutProgress setProgress:(float)referral.current_balance / referral.payout_threshold];
    [self.lblPayoutProgress setText:[NSString stringWithFormat:@"%d MORE UNTIL YOUR NEXT PAYOUT!", referral.payout_threshold - referral.current_balance]];
}

- (void)setCurrentBalance:(int)currentBalance {
    if( currentBalance >= referral.payout_threshold ) {
        //Make current balance text green if it is bigger than $10
        UIColor *roverGreenColor = [UIColor colorWithRed:17.0f/255.0f green:159.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
        [self.lblCurrentBalanceDollarSymbol setTextColor:roverGreenColor];
        [self.lblCurrentBalance setTextColor:roverGreenColor];
        
        [heightConstraintForPaymentInstruction setPriority:500];
        [bottomConstraintForPaymentInstruction setPriority:999];
    } else {
        //Make current balance text dark blue if it is smaller than $10
        UIColor *roverDarkBlueColor = [UIColor colorWithRed:4.0f/255.0f green:85.0f/255.0f blue:138.0f/255.0f alpha:1.0f];
        [self.lblCurrentBalanceDollarSymbol setTextColor:roverDarkBlueColor];
        [self.lblCurrentBalance setTextColor:roverDarkBlueColor];
        
        [heightConstraintForPaymentInstruction setPriority:999];
        [bottomConstraintForPaymentInstruction setPriority:500];
    }
    [self.lblCurrentBalance setText:[NSString stringWithFormat:@"%d", currentBalance]];
    [self.view layoutIfNeeded];
}

- (void)setTotalEarning:(int)totalEarning {
    [self.lblTotalEarning setText:[NSString stringWithFormat:@"%d", totalEarning]];
}

-(void)pullReferralCodeWithCurrentProgress {
    [[RTServerManager sharedInstance] getReferralCode:^(BOOL success, RTAPIResponse *response) {
        RTReferral *referralPull = [[RTReferral alloc] init];
        if (success) {
            NSDictionary *dicReferral = [response.jsonObject objectForKey:@"referral"];
            referralPull = [RTModelBridge getReferralWithDictionary:dicReferral];
            referral = referralPull;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setCurrentBalance:referral.current_balance];
                [self setTotalEarning:referral.total_earned];
                [self setNumberOfRemainingDownloadsWithNumber];
            });
        } else {
            
        }
    }];
}

#pragma mark - Actions

- (IBAction)onTermsAndConditionsLinkTapped:(id)sender {
    [self buildWebView];
//    if( self.delegate != nil) {
//        [self.delegate dollarsForDownloadsCodeVC:self onTermsAndConditionsLinkTappedWithAnimated:YES];
//    }
}

- (IBAction)onShareButtonTapped:(id)sender {
    if( self.delegate != nil) {
        [self.delegate dollarsForDownloadsCodeVC:self onShareButtonTappedWithReferralCode:referral];
    }
}

- (IBAction)showInstructionsTapped:(id)sender {
    DollarsForDownloadsMessageVC *vc = (DollarsForDownloadsMessageVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIDollarsForDownloadsMessageVC storyboardName:kStoryboardDollarsForDownloads];
    vc.delegate = self;
    vc.view.frame = self.view.bounds;
    UIView *container = [[UIView alloc] initWithFrame:self.view.bounds];
    [container setBackgroundColor:[UIColor roverTownColor6DA6CE]];
    self.messageContainerView = container;
    [self.view addSubview:self.messageContainerView];
    self.messageVC = vc;
    [self.messageVC buildForInstructionsWithoutGenerateCode];
    [self.messageContainerView addSubview:self.messageVC.view];
    [self addChildViewController:self.messageVC];
    [self.messageVC didMoveToParentViewController:self];
}

-(void)dismissDollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc {
    if (self.messageVC) {
        [self dismissViewControllerAnimated:self.messageVC completion:nil];
        [self.messageContainerView removeFromSuperview];
    }
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if( [[URL absoluteString] isEqualToString:@"http://rovertown.com"] ) {
        [self onTermsAndConditionsLinkTapped:textView];
        
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizer methods

-(void) handleTapGesture:(UIGestureRecognizer *) recognizer
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:self.lblReferralCode.frame inView:self.lblReferralCode];
    [menuController setMenuVisible:YES animated:YES];
    [self becomeFirstResponder];
}

#pragma mark - Clipboard

-(void) copy:(id)sender
{
    NSLog(@"Copy code text: %@", self.lblReferralCode.text);
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.lblReferralCode.text];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:)) {
        return NO;
    }
    return (action == @selector(copy:));
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIWebViewMethods
- (void)buildWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webView.tag = 45; //This is so that the UIButton can tag the webView for dismissal
    [webView setDelegate:self];
    [self.view addSubview:webView];
    NSString *urlString = @"http://rovertown.com/tos";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat height = self.view.frame.size.height - 15;
    CGFloat width = self.view.frame.size.width;
    button.frame = CGRectMake(width/2 - 80, height - 45, 160, 40);
    
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:@"Close" forState:UIControlStateNormal];

    [button setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [button addTarget:self
               action:@selector(close:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [webView addSubview:button];
    
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

-(IBAction)close:(id)sender
{
    [[self.view viewWithTag:45] removeFromSuperview];
}

- (void)dollarsForDownloadsMessageVC:(DollarsForDownloadsMessageVC *)vc onGenerateMyCodeButtonTappedWithAnimated:(BOOL)animated {
    [self.messageVC removeFromParentViewController];
    [self.messageContainerView removeFromSuperview];
}

@end
