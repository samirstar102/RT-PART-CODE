//
//  RTDollarsInstructionsViewController.m
//  RoverTown
//
//  Created by Sonny on 10/23/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDollarsInstructionsViewController.h"
#import "RTUIManager.h"

@interface RTDollarsInstructionsViewController () <UITextViewDelegate>

{
    __weak IBOutlet NSLayoutConstraint *heightConstraintForTermsAndConditions;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITextView *termsAndConditions;

@end

@implementation RTDollarsInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];
    [self initializeViews];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void) initializeViews {
    [RTUIManager applyContainerViewStyle:self.contentView];
    [self buildTermsAndConditionsTextviewFromString:NSLocalizedString(@"We\'ll send you cash using Venmo, a free payment service. There\'s no limit to how much you can earn, so start sharing! For more info, view the terms and conditions.", nil)];
    UIBarButtonItem *overrideButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(closeButton:)];
    [overrideButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Medium" size:22], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName,  nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = overrideButton;
}

- (void)loadView
{
    [super loadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextView manipulation

- (void)buildTermsAndConditionsTextviewFromString:(NSString *)localizedString {
    [self.termsAndConditions setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:localizedString];
    [str addAttribute:NSLinkAttributeName value:@"http://rovertown.com" range:NSMakeRange(142, 20)];
    [str addAttribute:NSFontAttributeName value:REGFONT15 range:NSMakeRange(0, localizedString.length)];
    self.termsAndConditions.attributedText = str;
    
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 200)];
    [lblTemp setFont:REGFONT15];
    [lblTemp setNumberOfLines:0];
    [lblTemp setText:localizedString];
    [lblTemp sizeToFit];
    
    heightConstraintForTermsAndConditions.constant = lblTemp.bounds.size.height + 16;
    [self.view layoutIfNeeded];
}

- (IBAction)onTermsAndConditionsLinkTapped:(id)sender {
    [self buildWebView];
    //    if( self.delegate != nil) {
    //        [self.delegate dollarsForDownloadsMessageVC:self onTermsAndConditionsLinkTappedWithAnimated:YES];
    //    }
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

- (IBAction)showMyCodePressed:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)close:(id)sender
{
    [[self.view viewWithTag:45] removeFromSuperview];
}

-(IBAction)closeButton:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
