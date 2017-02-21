//
//  RTSubmitViewWithImage.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/30/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitImageView.h"
#import "UIColor+Config.h"


@interface RTSubmitImageView() <UITextFieldDelegate>
@property (nonatomic) UIView *imageBackground;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *tapToAddLabel;
@property (nonatomic) UILabel *additionalOptionsLabel;
@property (nonatomic) UIButton *retakeButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) UIView *additionalOptionsView;
@property (nonatomic) UILabel *finePrintLabel;
@property (nonatomic) UITextField *finePrintTextField;
@property (nonatomic) UILabel *businessNameLabel;
@property (nonatomic) UITextField *businessNameTextField;
@property (nonatomic) UILabel *discountDescriptionLabel;
@property (nonatomic) UITextField *discountDescriptionTextField;
@property (nonatomic) id<RTSubmitImageViewDelegate>delegate;
@property (nonatomic) UIButton *sendButton;
@end

@implementation RTSubmitImageView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RTSubmitImageViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setCornerRadius:3.0];
        
        [self.detailsTextView setText:@"Did you find a student discount that's not on RoverTown yet? Send us a photo and we'll tell everyone"];
        [self.detailsTextView sizeToFit];
        
        _additionalOptionsLabel = [[UILabel alloc]init];
        UIGestureRecognizer *additionalOptionsTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAdditionalOptionsTapped:)];
        [_additionalOptionsLabel addGestureRecognizer:additionalOptionsTap];
        [_additionalOptionsLabel setUserInteractionEnabled:YES];
        [_additionalOptionsLabel setText:@"Show Additional Options"];

        
        _imageBackground = [[UIView alloc]init];
        UITapGestureRecognizer *tapToAddPhoto = [[UITapGestureRecognizer alloc]initWithTarget:self.delegate action:@selector(imageViewTapped)];
        [_imageBackground addGestureRecognizer:tapToAddPhoto];
        
        _imageView = [[UIImageView alloc]init];
        
        _tapToAddLabel = [[UILabel alloc]init];
        [_tapToAddLabel setText:@"+ TAP TO ADD PHOTO OR SCREENSHOT"];
        [self.imageBackground addSubview:_tapToAddLabel];
        
        
        _sendButton = [[UIButton alloc]init];
        [_sendButton setTitle:@"Send Discount to RoverTown" forState:UIControlStateNormal];
        [RTUIManager applyRedeemDiscountButtonStyle:_sendButton];
        [_sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [self.imageBackground addSubview:_imageView];
        [self addSubview:_additionalOptionsLabel];
        [self addSubview:_imageBackground];
        [self addSubview:_sendButton];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
    if (self.selectedImage) {
        [self showWithSelectedImage];
    } else {
        [self showWithoutSelectedImage];
    }
    
    _tapToAddLabel.minimumScaleFactor = 0.0;
    [_tapToAddLabel setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    _tapToAddLabel.adjustsFontSizeToFitWidth = YES;
    [_tapToAddLabel setTextAlignment:NSTextAlignmentCenter];
    _tapToAddLabel.numberOfLines = 1;
    [_tapToAddLabel setTextColor:[UIColor roverTownColorDarkBlue]];
    [_tapToAddLabel sizeToFit];
    [_tapToAddLabel setFrame:CGRectMake(CGRectGetMidX(self.imageView.frame) - CGRectGetWidth(self.imageView.frame)/2, CGRectGetMaxY(self.imageView.frame) + 20, CGRectGetWidth(self.imageView.frame), CGRectGetHeight(_tapToAddLabel.frame))];
    
    [self.additionalOptionsLabel sizeToFit];
    [self.additionalOptionsLabel setFont:[self.additionalOptionsLabel.font fontWithSize:10]];
    [self.additionalOptionsLabel setFrame:CGRectMake(20, CGRectGetMaxY(self.imageBackground.frame) + 15, CGRectGetWidth(self.additionalOptionsLabel.frame), CGRectGetHeight(self.additionalOptionsLabel.frame))];
   
    if (self.additionalOptionsView) {
        [self.sendButton setFrame:CGRectMake(10, CGRectGetMaxY(self.additionalOptionsView.frame) + 10, CGRectGetWidth(self.bounds) - 20, 40)];
    }else {
        [self.sendButton setFrame:CGRectMake(10, CGRectGetMaxY(self.additionalOptionsLabel.frame) + 10, CGRectGetWidth(self.bounds) - 20, 40)];
    }
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(self.sendButton.frame) + 10;
    [self setFrame:frame];
}

- (void)showWithoutSelectedImage {
    [self.imageBackground setBackgroundColor:[UIColor colorWithRed:212.0f/255.0f green:229.0f/255.0f blue:239.0f/255.0f alpha:1.0]];
    [self.imageBackground setFrame:CGRectMake(20, CGRectGetMaxY(self.detailsTextView.frame) + 10, CGRectGetWidth(self.bounds) - 40,220)];
    
    [self.imageView setImage:[UIImage imageNamed:@"submitView"]];
    CGSize imageSize = self.imageView.image.size;
    imageSize.width = CGRectGetWidth(self.imageBackground.frame) - 10;
    float factor = imageSize.width/self.imageView.image.size.width;
    imageSize.height = imageSize.height * factor;
    [self.imageView setFrame:CGRectMake(5, CGRectGetMidY(self.imageBackground.bounds) - imageSize.height/2, imageSize.width, imageSize.height)
     ];
}

- (void)showWithSelectedImage {
    CGRect imageViewFrame  = self.imageBackground.frame;
    imageViewFrame.size.width = CGRectGetWidth(self.frame)/2  - 25;
    [self.imageBackground setFrame:imageViewFrame];
    [self.imageView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.imageBackground.bounds), CGRectGetHeight(self.imageBackground.bounds))];
    [self.imageView setImage:self.selectedImage];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setClipsToBounds:YES];
    [self.tapToAddLabel setHidden:YES];
    
    if (!self.cancelButton) {
        CGRect buttonFrame = CGRectZero;
        buttonFrame.size.width = CGRectGetWidth(self.imageBackground.frame);
        buttonFrame.size.height = 40;
        buttonFrame.origin.x = CGRectGetMidX(self.frame);
        buttonFrame.origin.y = CGRectGetMaxY(self.imageBackground.frame) - buttonFrame.size.height;
        
        self.cancelButton = [[UIButton alloc]initWithFrame:buttonFrame];
        [self addSubview:self.cancelButton];
        [RTUIManager applyDefaultButtonStyle:self.cancelButton];
        [self.cancelButton setBackgroundColor:[UIColor redColor]];
        [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        buttonFrame.origin.y = CGRectGetMinY(self.cancelButton.frame) - (buttonFrame.size.height + 5);
        self.retakeButton = [[UIButton alloc]initWithFrame:buttonFrame];
        [self addSubview:self.retakeButton];
        [RTUIManager applyDefaultButtonStyle:self.retakeButton];
        [self.retakeButton setBackgroundColor:self.tapToAddLabel.textColor];
        [self.retakeButton setTitle:@"RETAKE" forState:UIControlStateNormal];
        [self.retakeButton addTarget:self action:@selector(imageViewTapped) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.cancelButton setAlpha:1.0];
        [self.retakeButton setAlpha:1.0];
    }
}


- (void)showAdditionalOptions {
    if (!self.additionalOptionsView) {
        
        CGRect additionalFrame = CGRectMake(20, CGRectGetMaxY(self.additionalOptionsLabel.frame) + 20, CGRectGetWidth(self.bounds) - 40, CGRectGetHeight(self.imageBackground.frame));
        self.additionalOptionsView = [[UIView alloc]initWithFrame: additionalFrame];
        [self addSubview:self.additionalOptionsView];
        
        UILabel *businessNameLabel = [self formLabelWithText:@"1. What is the name of the business?"];
        [businessNameLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(businessNameLabel.frame) + 5, CGRectGetHeight(businessNameLabel.frame) + 5)];
        [self.additionalOptionsView addSubview:businessNameLabel];
        
        self.businessNameTextField = [self formTextField];
        [self.businessNameTextField setPlaceholder:@"i.e. Big Kahuna Bar and Grill"];
        [self.businessNameTextField setFrame:CGRectMake(0, CGRectGetMaxY(businessNameLabel.frame), CGRectGetWidth(self.additionalOptionsView.bounds), CGRectGetHeight(self.businessNameTextField.frame) + 8)];
        [self.additionalOptionsView addSubview:self.businessNameTextField];
        
        self.discountDescriptionLabel = [self formLabelWithText:@"2. What is the student discount?"];
        [self.discountDescriptionLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.businessNameTextField.frame) + 5, CGRectGetWidth(self.discountDescriptionLabel.frame), CGRectGetHeight(self.discountDescriptionLabel.frame))];
        [self.additionalOptionsView addSubview:self.discountDescriptionLabel];
        
        self.discountDescriptionTextField = [self formTextField];
        [self.discountDescriptionTextField setPlaceholder:@"i.e. Free drink with purchase"];
        [self.discountDescriptionTextField setFrame:CGRectMake(0, CGRectGetMaxY(self.discountDescriptionLabel.frame), CGRectGetWidth(self.additionalOptionsView.bounds), CGRectGetHeight(self.businessNameTextField.frame))];
        [self.additionalOptionsView addSubview:self.discountDescriptionTextField];
        
        UILabel *finePrintLabel = [self formLabelWithText:@"3. Any fine print? (Optional)"];
        [finePrintLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.discountDescriptionTextField.frame) + 5, CGRectGetWidth(self.discountDescriptionLabel.frame), CGRectGetHeight(self.discountDescriptionLabel.frame))];
        [self.additionalOptionsView addSubview:finePrintLabel];
        
        self.finePrintTextField = [self formTextField];
        [self.finePrintTextField setPlaceholder:@"i.e. Must show student ID"];
        [self.finePrintTextField setFrame:CGRectMake(0, CGRectGetMaxY(finePrintLabel.frame), CGRectGetWidth(self.additionalOptionsView.bounds), CGRectGetHeight(self.businessNameTextField.frame) )];
        [self.additionalOptionsView addSubview:self.finePrintTextField];
        
        additionalFrame.size.height = CGRectGetHeight(self.businessNameTextField.frame)*3 + CGRectGetHeight(businessNameLabel.frame) * 3 + 15;
        [self.additionalOptionsView setFrame:additionalFrame];
        self.businessNameTextField.delegate = self;
        self.discountDescriptionTextField.delegate = self;
        self.finePrintTextField.delegate = self;
    }
    [self.additionalOptionsView setAlpha:0.0];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.businessNameTextField) {
        [self.discountDescriptionTextField becomeFirstResponder];
    } else if (textField == self.discountDescriptionTextField) {
        [self.finePrintTextField becomeFirstResponder];
    } else if (textField == self.finePrintTextField) {
        [self.finePrintTextField resignFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark public

-(void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    [self setNeedsLayout];
}

#pragma mark actions

- (void)showAdditionalOptionsTapped:(UITapGestureRecognizer *)recognizer {
    if ([((UILabel *)recognizer.view).text containsString:@"Hide"]) {
        if (self.delegate != nil) {
            [self.delegate additionalOptionsStarted];
        }
        [UIView animateWithDuration:0.3 animations:^{
            [self.additionalOptionsView setAlpha:0.0];
        } completion:^(BOOL finished) {
            CGRect frame = self.sendButton.frame;
            frame.origin.y = frame.origin.y - CGRectGetHeight(self.additionalOptionsView.frame);
            [UIView animateWithDuration:0.3 animations:^{
                [self.sendButton setFrame:frame];
            } completion:^(BOOL finished) {
                self.additionalOptionsView = nil;
                [self.additionalOptionsLabel setText:@"Show Additional Options"];
                [self setNeedsLayout];
                [self.delegate disableScrolling];
            }];
            if (self.delegate != nil) {
                [self.delegate additionalOptionsEnded];
            }
            
        }];
    } else {
        
        [self showAdditionalOptions];
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(frame) + CGRectGetHeight(self.additionalOptionsView.frame);
        if (self.delegate != nil) {
            [self.delegate additionalOptionsStarted];
        }
        [UIView animateWithDuration:0.4 animations:^{
            [self setFrame:frame];
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.additionalOptionsView setAlpha:1.0];
                [self.additionalOptionsLabel setText:@"Hide Additional Options"];
            } completion:^(BOOL finished) {
                [self.delegate adjustContentSize];
            }];
        }];
        if (self.delegate != nil) {
            [self.delegate additionalOptionsEnded];
        }
    }

}

- (void)imageViewTapped {
    [self.delegate imageViewTapped];
}

- (void)cancelButtonTapped {
    self.selectedImage = nil;
    [UIView animateWithDuration:0.4 animations:^{
        [self.imageBackground setAlpha:0.0];
        [self.cancelButton setAlpha:0.0];
        [self.retakeButton setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self setNeedsLayout];
        [UIView animateWithDuration:0.4 animations:^{
            [self.imageBackground setAlpha:1.0];
        }];
    }];
}

- (void)sendButtonTapped {
    if (!self.selectedImage) {
        [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please add a photo"];
        return;
    } else if (self.selectedImage && self.additionalOptionsView.alpha == 1.0){
        NSString *name = self.businessNameTextField.text;
        NSString *discount = self.discountDescriptionTextField.text;
        if(name.length == 0 ) {
            [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please enter a business name"];
            [self.businessNameTextField becomeFirstResponder];
            return;
        }else if(discount.length == 0 ) {
            [[RTUIManager sharedInstance] showToastMessageWithView:self labelText:nil descriptionText:@"Please enter the discount you are suggesting"];
            [self.discountDescriptionTextField becomeFirstResponder];
            return;
        }
    }
    [self.delegate imageSendTappedWithImage:self.selectedImage businessName:self.businessNameTextField.text discount:self.discountDescriptionTextField.text finePrint:self.finePrintTextField.text];
}

@end
