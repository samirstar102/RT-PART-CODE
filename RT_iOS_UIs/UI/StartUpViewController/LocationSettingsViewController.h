#import "RoverTownBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "RTLocationManager.h"

@interface LocationSettingsViewController : RoverTownBaseViewController <UIAlertViewDelegate, RTLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *whiteBackLabel;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIImageView *centerImageView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageWidthConstraint;
- (IBAction)okButtonClicked:(id)sender;

@end
