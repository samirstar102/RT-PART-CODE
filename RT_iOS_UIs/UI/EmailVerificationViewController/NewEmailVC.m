
//
//  NewEmailVC.m
//  RoverTown
//
//  Created by Robin Denis & Roger Jones on 6/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "NewEmailVC.h"
#import "RTUIManager.h"

@interface NewEmailVC()<UITextFieldDelegate>
{
    
    __weak IBOutlet UIButton *goBackButton;
    __weak IBOutlet UIButton *signUpButton;
    __weak IBOutlet UITextField *newEmailTextField;
    __weak IBOutlet UILabel *whiteBackLabel;
    __weak IBOutlet NSLayoutConstraint *ScrollViewTopConstraint;
    __weak IBOutlet UILabel *topLabel;
}

@end

@implementation NewEmailVC

- (void) initViews {
    [super initViews];
    whiteBackLabel.clipsToBounds = YES;
    whiteBackLabel.layer.cornerRadius = kCornerRadiusDefault;
    
    goBackButton.layer.cornerRadius = kCornerRadiusDefault;
    signUpButton.layer.cornerRadius = kCornerRadiusDefault;
    
    ScrollViewTopConstraint.constant = 60;
    
    [RTUIManager applyEmailTextFieldStyle:newEmailTextField placeholderText:@"Enter Your .Edu Email"];
    newEmailTextField.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)signUpButtonTapped {
    [self disableButtons];
    [self.delegate signUpWithEmail: newEmailTextField.text];
}

- (IBAction)goBackButtonTapped {
    [self dismiss];
    
}

- (void)dismiss{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
        [self removeFromParentViewController];
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];

    }];
}

- (void)enableButtons {
    [goBackButton setEnabled:YES];
    [signUpButton setEnabled:YES];
}

#pragma mark - textFieled Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [newEmailTextField resignFirstResponder];
    [self signUpButtonTapped];
    return  NO;
}

#pragma  mark - private

- (void)disableButtons {
    [goBackButton setEnabled:NO];
    [signUpButton setEnabled:NO];
}

@end
