//
//  SubmitDiscountFormVC.m
//  RoverTown
//
//  Created by Robin Denis on 9/14/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SubmitDiscountFormVC.h"

#import "RTUIManager.h"

@interface SubmitDiscountFormVC () <UITextFieldDelegate>
{
    NSString *referralSubject;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UITextField *tfBusinessName;
@property (weak, nonatomic) IBOutlet UITextField *tfBusinessAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfDiscount;
@property (weak, nonatomic) IBOutlet UITextField *tfFinePrint;
@property (weak, nonatomic) IBOutlet UIButton *radFindDiscountOption1;
@property (weak, nonatomic) IBOutlet UIButton *radFindDiscountOption2;
@property (weak, nonatomic) IBOutlet UIButton *radFindDiscountOption3;
@property (weak, nonatomic) IBOutlet UIButton *btnSendToRoverTown;

@end

@implementation SubmitDiscountFormVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // register keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [RTUIManager applyContainerViewStyle:self.vwContainer];
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnSendToRoverTown];
    
    //Initialize Text Fields
    [RTUIManager applyDefaultTextFieldStyle:self.tfBusinessName placeholderText:@"i.e. Big Kahuna Bar and Grill"];
    [RTUIManager applyDefaultTextFieldStyle:self.tfBusinessAddress placeholderText:@"i.e. 555 main St. St. Louis MO 63101"];
    [RTUIManager applyDefaultTextFieldStyle:self.tfDiscount placeholderText:@"i.e. FREE drink with purchase"];
    [RTUIManager applyDefaultTextFieldStyle:self.tfFinePrint placeholderText:@"i.e. Must show student ID"];
    [self.tfBusinessName setDelegate:self];
    [self.tfBusinessAddress setDelegate:self];
    [self.tfDiscount setDelegate:self];
    [self.tfFinePrint setDelegate:self];
    
    //Select first radio button for the first time
    [self onFindDiscountOption1:self.radFindDiscountOption1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

/**
 *  Deselect all the radio buttons for How did you find this Discount?
 */
- (void)deselectAllRadioButtons {
    [self.radFindDiscountOption1 setSelected:NO];
    [self.radFindDiscountOption2 setSelected:NO];
    [self.radFindDiscountOption3 setSelected:NO];
}

#pragma mark - Actions

- (IBAction)onSendToRoverTownButton:(id)sender {
    NSString *businessName = self.tfBusinessName.text;
    NSString *businessAddress = self.tfBusinessAddress.text;
    NSString *discount = self.tfDiscount.text;
    
    [self.view endEditing:YES];
    
    //TODO: Check the validation of business name, address and discount
    if( businessName.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Please enter a business name"];
        [self.tfBusinessName becomeFirstResponder];
        return;
    }
    if( businessAddress.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Please enter the business address"];
        [self.tfBusinessAddress becomeFirstResponder];
        return;
    }
    if( discount.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:nil descriptionText:@"Please enter the discount you are suggesting"];
        [self.tfDiscount becomeFirstResponder];
        return;
    }
    
    if( self.delegate != nil ) {
        [self.delegate formVC:self onSendToRoverTownButtonClicked:businessName businessAddress:businessAddress discount:discount referralSubject:referralSubject];
    }
}

- (IBAction)onFindDiscountOption1:(id)sender {
    [self.view endEditing:YES];
    [self deselectAllRadioButtons];
    [self.radFindDiscountOption1 setSelected:YES];
    referralSubject = self.radFindDiscountOption1.titleLabel.text;
}

- (IBAction)onFindDiscountOption2:(id)sender {
    [self.view endEditing:YES];
    [self deselectAllRadioButtons];
    [self.radFindDiscountOption2 setSelected:YES];
    referralSubject = self.radFindDiscountOption2.titleLabel.text;
}

- (IBAction)onFindDiscountOption3:(id)sender {
    [self.view endEditing:YES];
    [self deselectAllRadioButtons];
    [self.radFindDiscountOption3 setSelected:YES];
    referralSubject = self.radFindDiscountOption3.titleLabel.text;
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( textField == self.tfBusinessName ) {
        [self.tfBusinessAddress becomeFirstResponder];
    }
    else if( textField == self.tfBusinessAddress ) {
        [self.tfDiscount becomeFirstResponder];
    }
    else if( textField == self.tfDiscount ) {
        [self.tfFinePrint becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
//    CGRect missingLabelRect = [self.tfFinePrint.superview convertRect:self.tfFinePrint.frame toView:self.view];
//    if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
//    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
//    }
    [self.scrollView scrollRectToVisible:self.tfFinePrint.frame animated:YES];
}

//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


@end
