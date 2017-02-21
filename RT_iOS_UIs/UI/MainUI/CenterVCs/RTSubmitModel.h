//
//  RTSubmitModel.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTServerManager.h"

@protocol RTSubmitModelDelegate <NSObject>
- (void)submitSuccessful;
- (void)submitFailed;
- (void)boneCountUpdated:(BOOL)boneDiff badgeCountUpdated:(BOOL)badgeDiff;
- (void)submitLimitReached;

@end

@interface RTSubmitModel : NSObject
-(instancetype)initWithDelegate:(id<RTSubmitModelDelegate>)delegate;

- (void)submitDiscountWithImage:(UIImage *)image businessName:(NSString *)name businessAddress:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint referralSubject:(NSString *)referralSubject;
@end
