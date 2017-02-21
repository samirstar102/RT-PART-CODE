#import "HowItWorksViewController.h"

@implementation HowItWorksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) initViews {
    [super initViews];
    
    self.whiteBackLabel.clipsToBounds = YES;
    self.whiteBackLabel.layer.cornerRadius = 3;
    
    self.nextButton.layer.cornerRadius = 3;
}

- (void) initViewsIPhone35{
    self.ScrollViewTopConstraint.constant = 40;
    self.FirstConstraint.constant = 10;
    self.SecondConstraint.constant = 10;
    self.ThirdConstraint.constant = 10;
}
@end
