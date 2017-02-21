#import "WelcomeRoverTownViewController.h"

@implementation WelcomeRoverTownViewController

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
    [self.topLabel setFont:REGFONT13];
    [self.getExeclusiveLabel setFont:REGFONT13];
    [self.neverWorryLabel setFont:REGFONT13];

    NSMutableAttributedString * topString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"You're in! Now you can save money on the things you already do near campus with the RoverTown Student Discount Program!", nil)];
    [topString addAttribute:NSFontAttributeName value:BOLDFONT13 range:NSMakeRange(0,10)];
    [self.topLabel setAttributedText:topString];
    
    NSMutableAttributedString * getExeclusiveString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Get exclusive student discounts on local food, retail, nightlife and more!", nil)];
    [getExeclusiveString addAttribute:NSFontAttributeName value:BOLDFONT13 range:NSMakeRange(0,32)];
    [self.getExeclusiveLabel setAttributedText:getExeclusiveString];
    
    NSMutableAttributedString * neverWorryString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Never worry about paper coupons! All you need is your smartphone to find and redeem discounts.", nil)];
    [neverWorryString addAttribute:NSFontAttributeName value:BOLDFONT13 range:NSMakeRange(0,32)];
    [self.neverWorryLabel setAttributedText:neverWorryString];
}
@end
