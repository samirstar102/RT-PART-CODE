//
//  RTActivity.h
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RTActivity : NSObject
@property (nonatomic, readonly) NSString *comment;
@property (nonatomic, readonly) NSArray *subject;
@property (nonatomic, readonly) NSNumber *createdTime;
@property (nonatomic, readonly) NSString *imageString;
@property (nonatomic, readonly) NSString *activityType;
@property (nonatomic) NSString *logoString;
@property (nonatomic) UIImage *logoImage;
@property (nonatomic) UIImage *commentImmage;
@property (nonatomic) BOOL isBusinessActivity;
@property (nonatomic) int userId;

- (instancetype)initWithJSON:(NSDictionary *)json;

@end
