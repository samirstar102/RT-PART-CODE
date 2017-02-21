//
//  RTDiscountSearchModel.h
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTDiscountSearchModelDelegate <NSObject>

-(void)discountSearchSuccess:(NSArray*)discountsArray;
-(void)discountSearchFailedWithSearchTerm:(NSString*)searchTerm;
-(void)discountSearchFailedWithSearchTerm:(NSString*)term andLocation:(NSString*)location andQuery:(NSString*)query;

@end

@interface RTDiscountSearchModel : NSObject

-(id)initWithDelegate:(id<RTDiscountSearchModelDelegate>)delegate;
-(void)initializeSearchWithTerm:(NSString*)term andCategory:(NSString*)category andLocation:(NSString*)location;

@property (nonatomic, weak) id<RTDiscountSearchModelDelegate>delegate;

@end
