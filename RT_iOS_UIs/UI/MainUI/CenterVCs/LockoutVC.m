//
//  LockoutVC.m
//  RoverTown
//
//  Created by Robin Denis on 6/25/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "LockoutVC.h"

@interface LockoutVC()

@property (weak, nonatomic) IBOutlet UILabel *lblMiddleText;
@property (weak, nonatomic) IBOutlet UILabel *lblBottomText;

@end

@implementation LockoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set preferred max layout width of UILabels in order not to crash on iOS 7
    if( SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.lblMiddleText setPreferredMaxLayoutWidth:self.view.frame.size.width * 0.6f];
        [self.lblBottomText setPreferredMaxLayoutWidth:self.view.frame.size.width * 0.8f];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end