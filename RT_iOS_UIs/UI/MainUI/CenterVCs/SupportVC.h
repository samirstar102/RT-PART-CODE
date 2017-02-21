//
//  SupportVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"
#import "RTStudentDiscount.h"

@interface SupportVC : CenterViewControllerBase

@property (nonatomic, strong) RTStudentDiscount *discount;

- (void)setDefaultSelection:(int)nIndex;
- (IBAction)onNavigationSegmentValueChanged:(id)sender;

@end
