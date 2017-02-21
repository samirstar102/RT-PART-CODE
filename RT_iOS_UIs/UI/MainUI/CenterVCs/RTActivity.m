//
//  RTActivity.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/25/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTActivity.h"

@interface RTActivity()
@property (nonatomic, readwrite) NSString *comment;
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSURL *imageURL;
@property (nonatomic, readwrite) NSURL *logoURL;
@property (nonatomic, readwrite) NSArray *subject;
@property (nonatomic, readwrite) NSString *imageString;
@property (nonatomic, readwrite) NSNumber *createdTime;
@property (nonatomic, readwrite) NSString *activityType;
@end

@implementation RTActivity
- (instancetype)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        self.comment = [json objectForKey:@"comment"];
        self.identifier = [json objectForKey:@"id"];
        self.imageString = [json objectForKey:@"image"];
        self.logoString = [json objectForKey:@"logo"];
        self.createdTime = [json objectForKey:@"created"];
        self.subject = [NSArray arrayWithArray:[json objectForKey:@"subject"]];
        self.activityType = [json objectForKey:@"type"];
    }
    return self;
}

@end
