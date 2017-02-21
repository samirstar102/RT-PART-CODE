//
//  SubmitDiscountFormSuccessVC.m
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SubmitDiscountFormSuccessVC.h"

#import "RTUIManager.h"
#import "RTUserContext.h"

@interface SubmitDiscountFormSuccessVC ()

@property (weak, nonatomic) IBOutlet UIView *vwContainer;

@end

@implementation SubmitDiscountFormSuccessVC

@synthesize boneCountChanged;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [RTUIManager applyContainerViewStyle:self.vwContainer];
    
    if( boneCountChanged ) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
