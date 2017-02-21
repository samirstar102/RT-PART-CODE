#import <UIKit/UIKit.h>
#import <HockeySDK/HockeySDK.h>

@interface LeftNavViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, BITFeedbackComposeViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end
