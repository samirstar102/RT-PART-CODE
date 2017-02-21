#import "LocationSettingsViewController.h"
#import "NotificationSettingsViewController.h"
#import "RTLocationManager.h"
#import "LockoutVC.h"
#import "RTStoryboardManager.h"

@interface LocationSettingsViewController()
{
    UIViewController *vcLockout;
}

@end

@implementation LocationSettingsViewController
{
    
}

bool bNotificationSettingsViewControllerShow = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) initViews {
    [super initViews];
    
    self.whiteBackLabel.clipsToBounds = YES;
    self.whiteBackLabel.layer.cornerRadius = 3;
    
    self.okButton.layer.cornerRadius = 3;
    
    [self.centerImageView setFrame:CGRectMake((self.view.frame.size.width - self.centerImageView.frame.size.width)/2, self.centerImageView.frame.origin.y, self.centerImageView.frame.size.width, self.centerImageView.frame.size.height)];
}

- (void) initViewsIPhone35{
    self.ScrollViewTopConstraint.constant = 40;
    self.ImageHeightConstraint.constant = 177;
    self.ImageWidthConstraint.constant = 177;
    [self.topLabel setFont:REGFONT13];
}

- (void) initEvents{
    [super initEvents];
    
    // init location manager
    [RTLocationManager sharedInstance];
}

- (IBAction)okButtonClicked:(id)sender {
    CLAuthorizationStatus code = [[RTLocationManager sharedInstance] getAuthorizationStatus];
    
    //Check if location service is enabled and getting location is allowed for the app
    if( ![[RTLocationManager sharedInstance] isLocationServiceEnabled] || code == kCLAuthorizationStatusDenied ) {
        NSString *alertMsg = [[RTLocationManager sharedInstance] getMessageForStatus:code];
        if( alertMsg != nil ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enable Location Access to sort student discounts nearest to furthest.", nil) message:alertMsg delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel",nil];
            [alert show];
            return;
        }
    }
    else {
        [RTLocationManager sharedInstance].delegate = self;
        [[RTLocationManager sharedInstance] requestAccess];
    }
}

- (void) moveToNotificationSettingsViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotificationSettingsViewController *notificationViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationSettingsViewController"];
    [self.navigationController pushViewController:notificationViewController animated:YES];
    bNotificationSettingsViewControllerShow = NO;
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    else
    {
        if( vcLockout == nil ) {
            vcLockout = [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"LockoutVC" storyboardName:@"Lockout"];
        }
        [self presentViewController:vcLockout animated:YES completion:nil];
//        [self moveToNotificationSettingsViewController];
    }
}

#pragma mark - RTLocationManger delegates
- (void)locationManagerChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if( status != kCLAuthorizationStatusDenied ) {
        if( vcLockout != nil )
           [vcLockout dismissViewControllerAnimated:YES completion:nil];
        [self moveToNotificationSettingsViewController];
    }
    else {
        if( vcLockout == nil ) {
            vcLockout = [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:@"LockoutVC" storyboardName:@"Lockout"];
        }
        [self presentViewController:vcLockout animated:YES completion:nil];
    }
}

- (void)locationManagerUpdateLocation {
    //
}
@end
