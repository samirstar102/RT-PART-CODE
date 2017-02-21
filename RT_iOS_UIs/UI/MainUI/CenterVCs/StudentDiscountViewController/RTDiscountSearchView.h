//
//  RTDiscountSearchView.h
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTDiscountSearchModel.h"


@protocol RTDiscountSearchViewDelegate <NSObject>

-(void)searchStartedWithTerm:(NSString*)term category:(NSString*)category location:(NSString*)location;
-(void)searchCancelled;
-(void)viewWasExpandedForSearchView;
-(void)viewWasCollapsedForSearchView;
-(void)categoryButtonTapped;

@end

@interface RTDiscountSearchView : UIView

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<RTDiscountSearchViewDelegate>)delegate;
-(void)searchViewExpandedForOptions;
-(void)searchViewCollapsedForOptions;
-(void)collapseWhileSearching;
-(void)searchCategorySelectedForCategory:(NSString*)category;
-(void)resetCustomSearchParameters;

@property (nonatomic, weak) id<RTDiscountSearchViewDelegate> delegate;

@end
