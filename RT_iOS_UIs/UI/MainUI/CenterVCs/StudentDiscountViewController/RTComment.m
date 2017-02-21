//
//  RTComment.m
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTComment.h"

@interface RTComment()

@property (nonatomic, readwrite) NSString *userName;
@property (nonatomic, readwrite) NSString *commentString;
@property (nonatomic, readwrite) NSString *imageString;
@property (nonatomic, readwrite) NSNumber *createdTime;

@end

@implementation RTComment

- (instancetype)initWithJSON:(NSDictionary *)json {
    if (self = [super init]) {
        NSDictionary *userDict = [json objectForKey:@"user"];
        self.userName = [userDict objectForKey:@"name"];
        self.userNumber = [[userDict objectForKey:@"id"] intValue];
        self.voted = [[userDict objectForKey:@"voted"] intValue];
        self.totalVotes = [[json objectForKey:@"votes"] intValue];
        self.commentString = [NSString stringWithFormat:@"%@", [json objectForKey:@"comment"]];
        self.imageString = [NSString stringWithFormat:@"%@", [json objectForKey:@"image"]];
        self.reported = [[json objectForKey:@"reported"] boolValue];
        self.createdTime = [json objectForKey:@"created"];
        self.commentId = [[json objectForKey:@"id"] intValue];
    }
    return self;
}

@end
