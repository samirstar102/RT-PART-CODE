//
//  FollowingVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"

@interface FollowingVC : CenterViewControllerBase
@property (weak, nonatomic) IBOutlet UIView *vwContent;
- (IBAction)onNavigationSegmentValueChanged:(id)sender;

@end
