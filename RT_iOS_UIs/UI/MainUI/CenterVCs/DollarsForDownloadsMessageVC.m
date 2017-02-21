//
//  DollarsForDownloadsMessageVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/3/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "DollarsForDownloadsMessageVC.h"

#import "RTUIManager.h"

@interface DollarsForDownloadsMessageVC () <UITextViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *heightConstraintForTermsAndConditions;
}

@property (weak, nonatomic) IBOutlet UIView *vwFrame;
@property (weak, nonatomic) IBOutlet UITextView *txtTermsAndConditions;
@property (weak, nonatomic) IBOutlet UIButton *btnGenerateMyCode;
@property (weak, nonatomic) UIButton *instructionsButton;
@property (nonatomic) BOOL instructionsAreShowing;

@end

@implementation DollarsForDownloadsMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
    [self initEvents];
}

- (void)initViews {
    [RTUIManager applyContainerViewStyle:self.vwFrame];
    [RTUIManager applyRedeemDiscountButtonStyle:self.btnGenerateMyCode];
    [self buildTermsAndConditionsTextviewFromString:NSLocalizedString(@"We\'ll send you cash using Venmo, a free payment service. There\'s no limit to how much you can earn, so start sharing! For more info, view the terms and conditions.", nil)];
}

- (void)initEvents {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildForInstructionsWithoutGenerateCode {
    self.instructionsAreShowing = YES;
    [self.btnGenerateMyCode setTitle:@"SHOW MY CODE" forState:UIControlStateNormal];
    [self.btnGenerateMyCode addTarget:self action:@selector(showMyCodeTapped) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UI Manipulations

- (void)buildTermsAndConditionsTextviewFromString:(NSString *)localizedString {
    [self.txtTermsAndConditions setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:localizedString];
    [str addAttribute:NSLinkAttributeName value:@"http://rovertown.com" range:NSMakeRange(142, 20)];
    [str addAttribute:NSFontAttributeName value:REGFONT15 range:NSMakeRange(0, localizedString.length)];
    self.txtTermsAndConditions.attributedText = str;
    
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 200)];
    [lblTemp setFont:REGFONT15];
    [lblTemp setNumberOfLines:0];
    [lblTemp setText:localizedString];
    [lblTemp sizeToFit];
    
    heightConstraintForTermsAndConditions.constant = lblTemp.bounds.size.height + 16;
    [self.view layoutIfNeeded];
}

#pragma mark - Actions

- (IBAction)onTermsAndConditionsLinkTapped:(id)sender {
    [self buildWebView];
//    if( self.delegate != nil) {
//        [self.delegate dollarsForDownloadsMessageVC:self onTermsAndConditionsLinkTappedWithAnimated:YES];
//    }
}

- (IBAction)onGenerateMyCodeButtonTapped:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate dollarsForDownloadsMessageVC:self onGenerateMyCodeButtonTappedWithAnimated:YES];
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

#pragma mark - UIWebView methods
- (void)buildWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webView.tag = 45;
    [webView setDelegate:self];
    [self.vwFrame addSubview:webView];
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

-(void)showMyCodeTapped {
    if (self.delegate != nil) {
        if (!self.instructionsAreShowing) {
            [self.delegate dismissDollarsForDownloadsMessageVC:self];
        }
    }
}

@end
