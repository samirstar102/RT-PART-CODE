//
//  RTAlertView.h
//  RoverTown
//
//  Created by Sonny on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTAlertViewProtocol <NSObject>

- (void)doNotRemindMeButtonTapped;
- (void)confirmButtonTapped;
- (void)cancelButtonTapped;

@end

@interface RTAlertView : UIView

-(instancetype)initWithFrame:(CGRect)frame alertTitle:(NSString *)alertTitle alertMessage:(NSString *)alertMessage delegate:(id<RTAlertViewProtocol>)delegate;

-(void)setRTAlertPreferencesForUser;

@property (nonatomic, weak) id<RTAlertViewProtocol> delegate;

@end
