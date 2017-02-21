//
//  RTSubmitFormView.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitFormView.h"

#define horizontalSpacer 20

@interface RTSubmitFormView() <UITextFieldDelegate>
@property (nonatomic) id<RTSubmitFormViewDelegate> delegate;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UITextField *finePrintTextField;
@property (nonatomic) UITextField *businessNameTextField;
@property (nonatomic) UITextField *discountDescriptionTextField;
@property (nonatomic) UITextField *busniessAddressTextField;
@property (nonatomic) NSArray *optionsArray;
@property (nonatomic) UIButton *foundOption1;
@property (nonatomic) UIButton *foundOption2;
@property (nonatomic) UIButton *foundOption3;
@property (nonatomic) UILabel *finePrintLabel;
@property (nonatomic) UILabel *businessNameLabel;
@property (nonatomic) UILabel *discountDescriptionLabel;
@property (nonatomic) UILabel *busniessAddressLabel;
@property (nonatomic) UILabel *foundLabel;
@property (nonatomic) BOOL firstTime;
@end

@implementation RTSubmitFormView

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<RTSubmitFormViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setCornerRadius:3.0];
        
        [self.detailsTextView setText:@"Know of a student discount that's not on RoverTown yet? Tell us about it and we'll add it to the program."];
        [self.detailsTextView sizeToFit];
        
        self.finePrintTextField = [self formTextField];
        self.finePrintTextField.delegate = self;
        [self.finePrintTextField setPlaceholder:@"i.e. Must show student ID"];
        [self addSubview:self.finePrintTextField];
        
        self.businessNameTextField = [self formTextField];
        self.businessNameTextField.delegate = self;
        [self.businessNameTextField setPlaceholder:@"i.e. Big Kahuna Bar and Grill"];
        [self addSubview:self.businessNameTextField];

        self.busniessAddressTextField = [self formTextField];
        self.busniessAddressTextField.delegate = self;
        [self.busniessAddressTextField setPlaceholder:@"i.e. 555 Main St. Louis MO 63101"];
        [self addSubview:self.busniessAddressTextField];

        self.discountDescriptionTextField = [self formTextField];
        self.discountDescriptionTextField.delegate = self;
        [self.discountDescriptionTextField setPlaceholder:@"i.e. Free drink with purchase"];
        [self addSubview:self.discountDescriptionTextField];
        
        self.foundOption3 = [self optionButtonWithTitle:@"I work at this business"];
        
        self.foundOption2 = [self optionButtonWithTitle:@"I have used this discount before"];
        
        self.foundOption1 = [self optionButtonWithTitle:@"I've heard about it, but never used it"];
        
        self.optionsArray = [NSArray arrayWithObjects:self.foundOption1, self.foundOption2, self.foundOption3, nil];
        
        
        self.businessNameLabel = [self formLabelWithText:@"1. What is the name of the business?"];
        [self addSubview:self.businessNameLabel];
        self.busniessAddressLabel = [self formLabelWithText:@"2. What is the business address?"];
        [self addSubview:self.busniessAddressLabel];
        self.discountDescriptionLabel = [self formLabelWithText:@"3. What is the student discount?"];
        [self addSubview:self.discountDescriptionLabel];
        self.finePrintLabel = [self formLabelWithText:@"4. Any fine print? (Optional)"];
        [self addSubview:self.finePrintLabel];
        self.foundLabel = [self formLabelWithText:@"5. Finally, how did you find this discount?"];
        [self addSubview:self.foundLabel];
        
        _sendButton = [[UIButton alloc]init];
        [_sendButton setTitle:@"Send Discount to RoverTown" forState:UIControlStateNormal];
        [RTUIManager applyRedeemDiscountButtonStyle:_sendButton];
        [_sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_sendButton];
        self.firstTime = YES;
        
    }
    return self;
}

- (void)layoutSubviews {
    if (!self.firstTime) {
        return;
    }
    [super layoutSubviews];
    
    float textFieldWidth = CGRectGetWidth(self.bounds) - horizontalSpacer *2 ;
    float textFieldHeight = CGRectGetHeight(self.businessNameTextField.frame) + 8;
    
    [self setLabelFrame:self.businessNameLabel originY:CGRectGetMaxY(self.detailsTextView.frame) + 10];
    CGRect textFieldFrame = CGRectMake(horizontalSpacer, CGRectGetMaxY(self.businessNameLabel.frame), textFieldWidth, textFieldHeight);
    [self.businessNameTextField setFrame:textFieldFrame];
    
    [self setLabelFrame:self.busniessAddressLabel originY:CGRectGetMaxY(self.businessNameTextField.frame)];
    textFieldFrame.origin.y = CGRectGetMaxY(self.busniessAddressLabel.frame);
    [self.busniessAddressTextField setFrame:textFieldFrame];
    
    [self setLabelFrame:self.discountDescriptionLabel originY:CGRectGetMaxY(self.busniessAddressTextField.frame)];
    textFieldFrame.origin.y = CGRectGetMaxY(self.discountDescriptionLabel.frame);
    [self.discountDescriptionTextField setFrame:textFieldFrame];
    
    [self setLabelFrame:self.finePrintLabel originY:CGRectGetMaxY(self.discountDescriptionTextField.frame)];
    textFieldFrame.origin.y = CGRectGetMaxY(self.finePrintLabel.frame);
    [self.finePrintTextField setFrame:textFieldFrame];
    
    [self setLabelFrame:self.foundLabel originY:CGRectGetMaxY(self.finePrintTextField.frame)];
    CGRect optionFrame = CGRectMake(horizontalSpacer, CGRectGetMaxY(self.foundLabel.frame), CGRectGetWidth(self.foundOption1.frame) + 10, CGRectGetHeight(textFieldFrame));
    [self.foundOption1 setFrame:optionFrame];
    optionFrame.origin.y = CGRectGetMaxY(self.foundOption1.frame) + 5;
    optionFrame.size.width = CGRectGetWidth(self.foundOption2.frame) + 10;
    [self.foundOption2 setFrame:optionFrame];
    optionFrame.origin.y = CGRectGetMaxY(self.foundOption2.frame) + 5;
    optionFrame.size.width = CGRectGetWidth(self.foundOption3.frame) + 10 ;
    [self.foundOption3 setFrame:optionFrame];
    
    [self.foundOption1 setSelected:YES];
    
    [self.sendButton setFrame:CGRectMake(20, CGRectGetMaxY(self.foundOption3.frame) + 10, CGRectGetWidth(self.bounds) - 40, 40)];
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(self.sendButton.frame) + 10;
    [self setFrame:frame];
    self.firstTime = NO;
    
}

- (void)setLabelFrame:(UILabel *)label originY:(float)originY {
    [label setFrame:CGRectMake(horizontalSpacer, originY + 5, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.businessNameTextField) {
        [self.busniessAddressTextField becomeFirstResponder];
    } else if (textField == self.busniessAddressTextField) {
        [self.discountDescriptionTextField becomeFirstResponder];
    } else if (textField == self.discountDescriptionTextField) {
        [textField resignFirstResponder];
    } else if (textField == self.finePrintTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (UIButton *)optionButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"radio_unchecked"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"radio_checked"] forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:self.businessNameTextField.font];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [button sizeToFit];
    [self addSubview:button];
    return button;
}



#pragma mark - action
- (void)sendButtonTapped {
    NSString *name = self.businessNameTextField.text;
    NSString *address = self.busniessAddressTextField.text;
    NSString *discount = self.discountDescriptionTextField.text;
    if(name.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please enter a business name"];
        [self.businessNameTextField becomeFirstResponder];
        return;
    }else if(address.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please enter the business address"];
        [self.busniessAddressTextField becomeFirstResponder];
        return;
    }else if(discount.length == 0 ) {
        [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please enter the discount you are suggesting"];
        [self.discountDescriptionTextField becomeFirstResponder];
        return;
    }else {
        NSString *option;
        for (UIButton *button in self.optionsArray) {
            if (button.isSelected) {
                option = button.titleLabel.text;
            }
        }
        [self.delegate formSendTappedWithName:name address:address discount:discount finePrint:self.finePrintTextField.text option:option];
    }
}


- (void)optionSelected:(UIButton *)sender {
    for (UIButton *button in self.optionsArray) {
        if (button != sender) {
            [button setSelected:NO];
        }
    }
    [sender setSelected:YES];
}



@end
