#import "RoverTownBaseViewController.h"
#import "AppDelegate.h"
#import "UIColor+Config.h"

@implementation RoverTownBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    
    [self initViews];
    if ([[UIScreen mainScreen] bounds].size.height == 480)
        [self initViewsIPhone35];
    [self initEvents];
}

- (void)initViews{
    self.view.backgroundColor = [UIColor roverTownColor6DA6CE];
    
    UIImageView *navigationIV = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, ([[UIScreen mainScreen] bounds].size.height == 480) ? 82:82)];
    [navigationIV setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [self.view addSubview:navigationIV];
    
    UIImageView *titleIV = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 206.0f) / 2, navigationIV.frame.size.height - 33.0f - 16.0f, 206.0f, 33.0f)];
    [titleIV setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:titleIV];
}

- (void)initViewsIPhone35{
    
}

- (void)initEvents{
    
}

- (BOOL)shouldAutorotate {
    return YES;

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isAvailableLandscape) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end
