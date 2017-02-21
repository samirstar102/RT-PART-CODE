//
//  RTPublicProfileTableHeaderView.h
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/15/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTPUblicProfileHeaderViewDelegate <NSObject>

-(void)editButtonTapped;

@end

@interface RTPublicProfileTableHeaderView : UIView

-(instancetype)initWithDelegate:(id<RTPUblicProfileHeaderViewDelegate>)delegate;

-(instancetype)initForPrivateUserWithDelegate:(id<RTPUblicProfileHeaderViewDelegate>)delegate;

-(void)setGender:(NSString*)gender birthday:(NSString*)birthday major:(NSString*)major discounts:(int)discounts comments:(int)comments votes:(int)votes;

@property (nonatomic, weak) id<RTPUblicProfileHeaderViewDelegate> delegate;

@end
