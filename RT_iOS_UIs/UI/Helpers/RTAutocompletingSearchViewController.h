#import <UIKit/UIKit.h>
#import "RTAutocompletingSearchViewControllerDelegate.h"
#import "RTAutocompletingSearchViewControllerDataSource.h"

@interface RTAutocompletingSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) NSObject<RTAutocompletingSearchViewControllerDelegate>* delegate;
@property (weak, nonatomic) NSObject<RTAutoCompletingSearchViewControllerDataSource>* dataSource;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

+ (RTAutocompletingSearchViewController*) autocompletingSearchViewController;

- (void) resetSelection;
- (void) setSearchBarTextAndPerformSearch:(NSString*)query;
- (NSDictionary*) resultForRowAtIndex:(NSUInteger)resultIndex;

@end
