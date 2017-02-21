#import "RoverTownBaseViewController.h"

@interface NotificationSettingsViewController : RoverTownBaseViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *whiteBackLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnAllow;
@property (strong, nonatomic) IBOutlet UIImageView *centerImageView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageHeightConstraint;

- (IBAction)allowButtonClicked:(id)sender;

- (void)onDoneNotificationSettingsWithSuccess:(BOOL)isSuccessed;

@end
