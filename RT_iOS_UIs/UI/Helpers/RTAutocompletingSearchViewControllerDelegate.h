#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RTAutocompletingSearchViewController;

typedef void (^RTAutocompletingSearchResultsHandler)(NSArray*);

@protocol RTAutocompletingSearchViewControllerDelegate <NSObject>

@required
- (void) searchControllerCanceled:(RTAutocompletingSearchViewController*)searchController;
- (void) searchController:(RTAutocompletingSearchViewController*)searchController
                tableView:(UITableView*)tableView
           selectedResult:(id)result;

@optional
- (BOOL) searchControllerShouldPerformBlankSearchOnLoad:(RTAutocompletingSearchViewController*)searchController;
- (BOOL) searchControllerSearchesPerformedSynchronously:(RTAutocompletingSearchViewController*)searchController;
- (BOOL) searchControllerUsesCustomResultTableViewCells:(RTAutocompletingSearchViewController*)searchController;
- (UITableViewCell*) searchController:(RTAutocompletingSearchViewController*)searchController
                            tableView:(UITableView*)tableView
                cellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat) searchController:(RTAutocompletingSearchViewController*)searchController
                   tableView:(UITableView*)tableView
     heightForRowAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL) searchController:(RTAutocompletingSearchViewController*)searchController shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (dispatch_time_t) searchControllerDelaySearchingUntilQueryUnchangedForTimeOffset:(RTAutocompletingSearchViewController *)searchController;
- (BOOL) searchControllerShouldDisplayNetworkActivityIndicator:(RTAutocompletingSearchViewController*)searchController;
- (void) searchController:(RTAutocompletingSearchViewController*)searchController didChangeActivityInProgressToEnabled:(BOOL)activityInProgress;

@end
