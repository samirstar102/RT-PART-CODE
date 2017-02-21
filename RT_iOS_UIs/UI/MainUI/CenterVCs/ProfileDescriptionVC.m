//
//  ProfileDescriptionVC.m
//  RoverTown
//
//  Created by Robin Denis on 8/16/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "ProfileDescriptionVC.h"
#import "RTUIManager.h"

@interface ProfileDescriptionVC ()

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnFillOutMyProfile;

@end

@implementation ProfileDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initEvent];
}

- (void)initView {
    [RTUIManager applyRedeemDiscountButtonStyle:self.btnFillOutMyProfile];
    [RTUIManager applyContainerViewStyle:self.ivFrame];
}

- (void)initEvent {
    
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

#pragma mark - Actions

- (IBAction)onFillOutMyProfile:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileDescriptionVC:self onFillOutMyProfileWithAnimated:YES];
    }
}

@end
