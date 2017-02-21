//
//  PlaceholderTextView.h
//  RoverTown
//
//  Created by Robin Denis on 5/26/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

@interface PlaceholderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)setPlaceholderText:(NSString *)text;
-(void)textChanged:(NSNotification*)notification;

@end
