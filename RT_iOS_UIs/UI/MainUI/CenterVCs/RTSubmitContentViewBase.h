//
//  RTSubmitVIewBase.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTUIManager.h"

@interface RTSubmitContentViewBase : UIView
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextView *detailsTextView;

- (UITextField *)formTextField;
- (UILabel *)formLabelWithText:(NSString *)text;
- (void)showSpinner;
- (void)hideSpinner;
- (void)clear;
@end
