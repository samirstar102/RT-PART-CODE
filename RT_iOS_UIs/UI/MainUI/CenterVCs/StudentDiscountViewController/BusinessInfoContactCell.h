//
//  BusinessInfoContactCell.h
//  RoverTown
//
//  Created by Robin Denis on 5/23/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTStudentDiscount.h"

@class BusinessInfoContactCell;

@protocol BusinessInfoContactCellDelegate <NSObject>

- (void)businessInfoContactCell:(BusinessInfoContactCell *)cell onContactButton:(RTStore *)store;

@end

@interface BusinessInfoContactCell : UITableViewCell

@property (nonatomic, readonly) RTStore *store;

@property (nonatomic, weak) id<BusinessInfoContactCellDelegate> delegate;

- (void)bind:(RTStore *)store buttonName:(NSString*) buttonName labelText:(NSString*) labelText;
+ (CGFloat)heightForContactWithLabelText:(NSString *)labelText;

@end
