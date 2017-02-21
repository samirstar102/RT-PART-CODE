//
//  RTSubmitFormView.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSubmitContentViewBase.h"

@protocol RTSubmitFormViewDelegate <NSObject>
-(void)formSendTappedWithName:(NSString *)name address:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint option:(NSString *)option;
@end

@interface RTSubmitFormView : RTSubmitContentViewBase
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<RTSubmitFormViewDelegate>)delegate;
@end
