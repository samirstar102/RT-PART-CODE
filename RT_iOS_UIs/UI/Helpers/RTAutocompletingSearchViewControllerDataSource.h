//
//  RTAutoCompletingSearchViewControllerDataSource.h
//  RoverTown
//
//  Created by Robin Denis on 10/6/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class RTAutocompletingSearchViewController;

@protocol RTAutoCompletingSearchViewControllerDataSource <NSObject>

@required
- (NSArray*) searchControllerDataSourceForSearch;

@end