//
//  RTAlertViewController.m
//  RoverTown
//
//  Created by Sonny on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTAlertViewController.h"
#import "RTAlertView.h"
#import "AppDelegate.h"

@interface RTAlertViewController () <RTAlertViewProtocol>

@property (nonatomic) RTStore *store;

@property (nonatomic, weak) NSString *alertTitle;
@property (nonatomic, weak) NSString *alertMessage;

@property (nonatomic, weak) UIView *alertView;

@end

@implementation RTAlertViewController

- (id)initWithStore:(RTStore *)store {
    if (self = [super init]) {
        self.store = store;
        self.alertView = [self getAlertViewForStore];
    }
    return self;
}

-(UIView *)getAlertViewForStore {
    self.alertTitle = @"Unfollow business?";
    self.alertMessage = [NSString stringWithFormat:@"Are you sure you want to unfollow %@? You will no longer receive push notifications about this business.", self.store.name];
    return [[RTAlertView alloc] initWithFrame:self.view.bounds alertTitle:self.alertTitle alertMessage:self.alertMessage delegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
