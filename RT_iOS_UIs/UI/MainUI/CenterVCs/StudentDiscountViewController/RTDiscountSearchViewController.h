//
//  RTDiscountSearchViewController.h
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTDiscountSearchModel.h"
#import "RTDiscountSearchView.h"

@protocol RTDiscountSearchViewControllerDelegate <NSObject>

-(void)searchFinishedWithResults:(NSArray*)results;
-(void)searchFailedWithMessage:(NSString*)query;
-(void)searchFailedWithQuery:(NSString*)query andLocation:(NSString*)location andTerm:(NSString*)term;
-(void)searchCancelledFromViewController;
-(void)userOptionsViewHasChangedWithExpanded:(BOOL)expanded;
-(void)categoryButtonTappedFromViewController;
-(void)searchInitializedByUser;

@end

@interface RTDiscountSearchViewController : UIViewController

- (instancetype)initWithDelegate:(id <RTDiscountSearchViewControllerDelegate>) delegate;

-(void)retrieveMoreSearchResults;
-(void)hideAdditionalOptionsWhileSearching;
@property (nonatomic, weak) id<RTDiscountSearchViewControllerDelegate> delegate;
@property (nonatomic) RTDiscountSearchView *searchView;
@property (nonatomic) BOOL isInitialSearch;

-(void)returnCategoryFromUser:(NSString*)category;

@end
