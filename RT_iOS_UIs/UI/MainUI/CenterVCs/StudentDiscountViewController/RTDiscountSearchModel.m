//
//  RTDiscountSearchModel.m
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountSearchModel.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "RTModelBridge.h"

#define kApiCustomSearchLimit 20

@interface RTDiscountSearchModel()

@property (nonatomic) NSArray *searchCategories;
@property (nonatomic) NSMutableArray *discountsArray;
@property int amountOfDiscounts;
@property int maxOfDiscounts;

@property (nonatomic) NSString *oldLocationString;
@property (nonatomic) NSString *oldSearchString;
@property (nonatomic) NSString *oldCategoryString;

@property (nonatomic) BOOL discountQuerySearchChanged;

@end

@implementation RTDiscountSearchModel

- (id)initWithDelegate:(id<RTDiscountSearchModelDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.discountsArray = [NSMutableArray array];
    }
    return self;
}

- (void)initializeSearchWithTerm:(NSString *)term andCategory:(NSString *)category andLocation:(NSString *)location
{
    if (![self.oldLocationString isEqualToString:location]) {
        self.discountQuerySearchChanged = YES;
    }
    if (![self.oldCategoryString isEqualToString:category]) {
        self.discountQuerySearchChanged = YES;
    }
    if (![self.oldSearchString isEqualToString:term]) {
        self.discountQuerySearchChanged = YES;
    }
    if (self.discountQuerySearchChanged) {
        self.discountsArray = [NSMutableArray array];
    }
    if (!self.discountQuerySearchChanged) {
        self.amountOfDiscounts = (int)[self.discountsArray count];
        self.maxOfDiscounts = self.amountOfDiscounts + kApiCustomSearchLimit;
    } else {
        self.amountOfDiscounts = 0;
        self.maxOfDiscounts = kApiCustomSearchLimit;
    }
    double latitude = [RTLocationManager sharedInstance].latitude;
    double longitude = [RTLocationManager sharedInstance].longitude;
    if (self.maxOfDiscounts >= kApiCustomSearchLimit) {
        [[RTServerManager sharedInstance] searchNearbyDiscountsWithLatitude:latitude longitude:longitude start:self.amountOfDiscounts limit:self.maxOfDiscounts term:term category:category location:location complete:^(BOOL success, RTAPIResponse *response) {
            if (success) {
                self.oldLocationString = location;
                self.oldCategoryString = category;
                self.oldSearchString = term;
                NSArray *discounts = [response.jsonObject objectForKey:@"discounts"];
                NSArray *discountsArray = [RTModelBridge getStudentDiscountsFromResponseForGetDiscounts:discounts];
                if (discountsArray.count == 0) {
                    [[RTServerManager sharedInstance] getSearchQueryForGoogleWithSearchTerm:term latitude:latitude longitude:longitude complete:^(BOOL success, RTAPIResponse *response) {
                        if (success) {
                            id searchData = [response.jsonObject objectForKey:@"search"];
                            NSString *searchQuery = [searchData objectForKey:@"query"];
                            if (self.delegate != nil) {
                                [self.delegate discountSearchFailedWithSearchTerm:self.oldSearchString andLocation:self.oldLocationString andQuery:searchQuery];
                                //[self.delegate discountSearchFailedWithSearchTerm:searchQuery];
                                
                            }
                        }
                    }];
                }
                else {
                    [self.discountsArray addObjectsFromArray:discountsArray];
                    [self.delegate discountSearchSuccess:[self.discountsArray copy]];
                    self.amountOfDiscounts = (int)[self.discountsArray count];
                    self.maxOfDiscounts = self.amountOfDiscounts + kApiCustomSearchLimit;
                
                }
            } else {
            //
            }
        }];
    }
}

@end
