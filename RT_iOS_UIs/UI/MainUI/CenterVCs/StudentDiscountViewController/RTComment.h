//
//  RTComment.h
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTComment : NSObject

@property (nonatomic, readonly) NSString *userName;
@property int userNumber;
@property int voted;
@property int totalVotes;
@property (nonatomic, readonly) NSString *commentString;
@property (nonatomic, readonly) NSString *imageString;
@property (nonatomic) BOOL reported;
@property (nonatomic, readonly) NSNumber *createdTime;
@property int commentId;
@property (nonatomic) BOOL canDelete;

- (instancetype) initWithJSON:(NSDictionary *)json;

@end
