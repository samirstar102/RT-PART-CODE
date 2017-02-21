//
//  RTDiscountSearchViewController.m
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountSearchViewController.h"
#import "RTDiscountSearchView.h"
#import "RTDiscountSearchModel.h"

@interface RTDiscountSearchViewController () <RTDiscountSearchModelDelegate, RTDiscountSearchViewDelegate>

@property (nonatomic) RTDiscountSearchModel *model;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSString *searchCategory;
@property (nonatomic) NSString *searchLocation;

@end

@implementation RTDiscountSearchViewController

- (instancetype)initWithDelegate:(id<RTDiscountSearchViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.model = [[RTDiscountSearchModel alloc]initWithDelegate:self];
        self.searchView = [self buildDiscountSearchView];
        self.view = self.searchView;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (RTDiscountSearchView*)buildDiscountSearchView {
    RTDiscountSearchView *searchView = [[RTDiscountSearchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50) delegate:self];
    return searchView;
}

- (void)returnCategoryFromUser:(NSString *)category {
    [self.searchView searchCategorySelectedForCategory:category];
}


#pragma mark - RTDiscountSearchViewDelegate
- (void)searchCancelled {
    if (self.delegate != nil) {
        [self.delegate searchCancelledFromViewController];
    }
}

- (void)searchStartedWithTerm:(NSString *)term category:(NSString *)category location:(NSString *)location {
    self.searchTerm = term;
    self.searchCategory = category;
    self.searchLocation = location;
    [self.model initializeSearchWithTerm:term andCategory:category andLocation:location];
    if (self.delegate != nil) {
        [self.delegate searchInitializedByUser];
    }
    self.isInitialSearch = YES;
}

- (void)retrieveMoreSearchResults {
    [self.model initializeSearchWithTerm:self.searchTerm andCategory:self.searchCategory andLocation:self.searchLocation];
    self.isInitialSearch = NO;
}

- (void)hideAdditionalOptionsWhileSearching {
    [self.searchView collapseWhileSearching];
}

- (void)viewWasExpandedForSearchView {
    // add the bottom view and frame
    self.isExpanded = YES;
    if (self.delegate != nil) {
        [Flurry logEvent:@"user_search_options_view"];
        [self.delegate userOptionsViewHasChangedWithExpanded:YES];
    }
}

- (void)viewWasCollapsedForSearchView {
    // remove the bottom view and frame
    self.isExpanded = NO;
    if (self.delegate != nil) {
        [self.delegate userOptionsViewHasChangedWithExpanded:NO];
    }
}

- (void)categoryButtonTapped {
    if (self.delegate != nil) {
        [self.delegate categoryButtonTappedFromViewController];
    }
}

#pragma mark - RTDiscountSearchModelDelegate
- (void)discountSearchSuccess:(NSArray *)discountsArray {
    if (self.delegate != nil) {
        [self.delegate searchFinishedWithResults:discountsArray];
    }
}

- (void)discountSearchFailedWithSearchTerm:(NSString *)searchTerm {
    if (self.delegate != nil) {
        [self.delegate searchFailedWithMessage:searchTerm];
        [self.searchView resetCustomSearchParameters];
    }
}

- (void)discountSearchFailedWithSearchTerm:(NSString *)term andLocation:(NSString *)location andQuery:(NSString *)query {
    if (self.delegate != nil) {
        [self.delegate searchFailedWithQuery:query andLocation:location andTerm:term];
        [self.searchView resetCustomSearchParameters];
    }
}

@end
