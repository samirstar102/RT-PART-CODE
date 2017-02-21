#import "ProTipViewController.h"
#import "AppDelegate.h"
#import "RTLocationManager.h"

@implementation ProTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) initViews {
    [super initViews];
    
    self.whiteBackLabel.clipsToBounds = YES;
    self.whiteBackLabel.layer.cornerRadius = 3;
    
    self.enterButton.layer.cornerRadius = 3;
    
    [self.centerImageView setFrame:CGRectMake((self.view.frame.size.width - self.centerImageView.frame.size.width)/2, self.centerImageView.frame.origin.y, self.centerImageView.frame.size.width, self.centerImageView.frame.size.height)];
}

- (void) initViewsIPhone35{
    self.ScrollViewTopConstraint.constant = 40;
    self.ImageHeightConstraint.constant = 136;
    self.ImageWidthConstraint.constant = 169;
    [self.topLabel setFont:REGFONT13];
}

- (IBAction)enterButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [RTLocationManager sharedInstance].delegate = (id<RTLocationManagerDelegate>)appDelegate.self;
    [[RTLocationManager sharedInstance] requestAccess];
    [[AppDelegate getInstance] bringupMainUserControllerAnimated:YES];
}
@end
