
#import "NotificationSettingsViewController.h"
#import "ProTipViewController.h"
#import "AppDelegate.h"
#import "RTUser.h"
#import "RTServerManager.h"
#import "RTUIManager.h"

@interface NotificationSettingsViewController()

@property (weak, nonatomic) IBOutlet UIButton *btnDontAllow;

@end

@implementation NotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.notificationVC = self;
}

- (void) initViews {
    [super initViews];
    
    self.whiteBackLabel.clipsToBounds = YES;
    self.whiteBackLabel.layer.cornerRadius = 3;
    
    [RTUIManager applyDefaultButtonStyle:self.btnAllow];
    
    [self.centerImageView setFrame:CGRectMake((self.view.frame.size.width - self.centerImageView.frame.size.width)/2, self.centerImageView.frame.origin.y, self.centerImageView.frame.size.width, self.centerImageView.frame.size.height)];
}

- (void) initViewsIPhone35{
    self.ScrollViewTopConstraint.constant = 40;
    self.ImageHeightConstraint.constant = 177;
    self.ImageWidthConstraint.constant = 177;
    [self.topLabel setFont:REGFONT13];
}

#pragma mark - Actions

- (IBAction)allowButtonClicked:(id)sender {
    [[AppDelegate getInstance]registerForNotifications];
    [Flurry logEvent:@"user_notification_accept"];
    [self notificationSettingOn:YES];
}

- (IBAction)dontAllowTapped:(id)sender {
    [self notificationSettingOn:NO];
//    [self onDoneNotificationSettingsWithSuccess:nil];
}

#pragma mark - Event

- (void) onDoneNotificationSettingsWithSuccess:(BOOL)isSuccessed {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProTipViewController *proTipViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProTipViewController"];
    [self.navigationController pushViewController:proTipViewController animated:YES];
}

- (void)notificationSettingOn:(BOOL)on {
    RTUser *user = [[RTUser alloc]init];
    RTNotificationSettings *notificationSettings = [[RTNotificationSettings alloc]init];
    notificationSettings.notify_expiring_discounts = [NSNumber numberWithBool:on];
    notificationSettings.notify_nearby_discounts = [NSNumber numberWithBool:on];
    notificationSettings.notify_new_discounts = [NSNumber numberWithBool:on];
    user.settings = notificationSettings;
    [[RTServerManager sharedInstance] updateUser:user complete:^(BOOL success, RTAPIResponse *response) {
        // only here because call back doesnt check for nil block
    }];
}
@end
