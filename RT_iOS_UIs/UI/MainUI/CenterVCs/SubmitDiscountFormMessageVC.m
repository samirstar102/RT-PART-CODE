//
//  SubmitDiscountFormMessageVC.m
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SubmitDiscountFormMessageVC.h"

#import "RTUIManager.h"

@interface SubmitDiscountFormMessageVC ()

@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmitDiscount;

@end

@implementation SubmitDiscountFormMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [RTUIManager applyContainerViewStyle:self.vwContainer];
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnSubmitDiscount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onSubmitDiscountButton:(id)sender {
    if( self.delegate ) {
        [self.delegate formMessageVC:self onSubmitDiscountButtonClicked:YES];
    }
}


@end
