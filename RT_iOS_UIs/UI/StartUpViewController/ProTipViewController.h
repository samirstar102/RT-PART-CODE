#import "RoverTownBaseViewController.h"

@interface ProTipViewController : RoverTownBaseViewController
@property (strong, nonatomic) IBOutlet UILabel *whiteBackLabel;
@property (strong, nonatomic) IBOutlet UIButton *enterButton;
@property (strong, nonatomic) IBOutlet UIImageView *centerImageView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ImageHeightConstraint;
- (IBAction)enterButtonClicked:(id)sender;

@end
