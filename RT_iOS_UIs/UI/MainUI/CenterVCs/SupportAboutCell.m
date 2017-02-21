//
//  SupportAboutCell.m
//  RoverTown
//
//  Created by Robin Denis on 6/6/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SupportAboutCell.h"
#import "RTUIManager.h"
#import "RTUserContext.h"

@interface SupportAboutCell()

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;
@property (weak, nonatomic) IBOutlet UILabel *lblAnswer;
@property (nonatomic) UILabel *linkAnswer;

@end

@implementation SupportAboutCell

-(void)layoutSubviews {
    if ([self.lblAnswer.text containsString:@".com"]){
        self.linkAnswer = [[UILabel alloc]init];
        [self.linkAnswer setText:self.lblAnswer.text];
        [self.linkAnswer setFont:self.lblAnswer.font];
        [self.linkAnswer setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        [self.lblAnswer setText:@"Visit"];
        [self.lblAnswer sizeToFit];
        [self.linkAnswer sizeToFit];
        [self.linkAnswer setFrame:CGRectMake(CGRectGetMaxX(self.lblAnswer.frame) + 3, CGRectGetMinY(self.lblAnswer.frame), CGRectGetWidth(self.linkAnswer.frame), CGRectGetHeight(self.linkAnswer.frame))];
        [self addSubview:self.linkAnswer];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openTerms)];
        [self.linkAnswer addGestureRecognizer:tap];
        [self.linkAnswer setUserInteractionEnabled:YES];
        
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)url inRange:(NSRange)characterRange
{
    NSLog(@"clicked");
    return YES;
}

- (void)bind:(NSString*)question answer:(NSString*)answer isLast:(BOOL)isLast {
    //Set font for question and answer
    [self.lblQuestion setFont:BOLDFONT16];
    [self.lblAnswer setFont:REGFONT14];
    
    [self.lblQuestion setText:question];
    [self.lblAnswer setText:answer];
}

+ (CGFloat)heightForCellWithQuestion:(NSString*)question answer:(NSString*)answer {
    static UILabel *questionLabel = nil, *answerLabel = nil;
    if (questionLabel == nil) {
        questionLabel = [[UILabel alloc] init];
    }
    if (answerLabel == nil) {
        answerLabel = [[UILabel alloc] init];
    }
    
    [questionLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 200)];
    questionLabel.numberOfLines = 0;
    [questionLabel setFont:BOLDFONT16];
    [questionLabel setText:question];
    [questionLabel sizeToFit];
    
    [answerLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 200)];
    answerLabel.numberOfLines = 0;
    [answerLabel setFont:REGFONT14];
    [answerLabel setText:answer];
    [answerLabel sizeToFit];
    
    return MAX(119, 82 + questionLabel.frame.size.height + answerLabel.frame.size.height);
}

#pragma mark - Actions
- (IBAction)onBackToTopButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate onBackToTopButton];
    }
}

- (void)openTerms{
    [Flurry logEvent:@"user_faq_view"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rovertown.com/tos"]];
}

@end

#pragma mark - About Using This App Header VC

@interface SupportAboutHeaderVC()
{
    NSMutableArray *questions;
    
    //Referral Code View
    __weak IBOutlet NSLayoutConstraint *heightConstraintForReferralCodeView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForMessageView;
    
    //Question View
    __weak IBOutlet NSLayoutConstraint *heightConstraintForQuestionView;
}

//Referral Code View Outlets

@property (weak, nonatomic) IBOutlet UIView *vwInputContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblReferralCode;
@property (weak, nonatomic) IBOutlet UITextField *tfReferralCode;
@property (weak, nonatomic) IBOutlet UIView *vwMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblSuccess;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

//Question View Outlets
@property (weak, nonatomic) IBOutlet UIView *vwQuestion;
@property (weak, nonatomic) IBOutlet UIImageView *ivQuestionViewFrame;

@end

@implementation SupportAboutHeaderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize Referral Code View Frame
    [RTUIManager applyContainerViewStyle:self.vwInputContainer];
    
    [RTUIManager applyReferralCodeSubmitButtonStyle:self.btnSubmit];
    
    [RTUIManager applyReferralCodeTextFieldStyle:self.tfReferralCode];
    
    heightConstraintForReferralCodeView.constant -= heightConstraintForMessageView.constant;
    heightConstraintForMessageView.constant = 0.0f;
    
    self.lblError.alpha = 0.0f;
    
    [self hideSuccessLabelWithAnimation:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Initialize Header view of Using This App table
    UIBezierPath *maskPathForHeaderView;
    CGRect boundsOfHeaderView = self.ivQuestionViewFrame.bounds;
    maskPathForHeaderView = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(boundsOfHeaderView.origin.x, boundsOfHeaderView.origin.y, boundsOfHeaderView.size.width, boundsOfHeaderView.size.height)
    byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
    cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    CAShapeLayer *maskLayerForHeaderView = [[CAShapeLayer alloc] init];
    maskLayerForHeaderView.frame = boundsOfHeaderView;
    maskLayerForHeaderView.path = maskPathForHeaderView.CGPath;
    self.ivQuestionViewFrame.layer.mask = maskLayerForHeaderView;
}

- (float)getHeightForViewAfterBindingWithQuestionArray:(NSMutableArray *)questionArray {
    questions = questionArray;
    
    CGFloat buttonYPosition = 32.0f;
    
    for( int i = 0; i < questionArray.count; i++ ) {
        UIFont *font = REGFONT16;
        
        //Get estimated height of question button
        UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 48, 100)];
        [lblTemp setText:questionArray[i]];
        [lblTemp setFont:font];
        [lblTemp setNumberOfLines:0];
        [lblTemp sizeToFit];
        
        UIButton *btnQuestion = [[UIButton alloc] init];
        [btnQuestion setTag:i + 1];
        [btnQuestion setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnQuestion setTitle:questionArray[i] forState:UIControlStateNormal];
        [btnQuestion.titleLabel setFont:font];
        [btnQuestion.titleLabel setNumberOfLines:0];
        btnQuestion.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnQuestion.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [btnQuestion addTarget:self action:@selector(onQuestionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btnQuestion setFrame:CGRectMake(16, buttonYPosition, [UIScreen mainScreen].bounds.size.width - 48, lblTemp.bounds.size.height + 16)];
        
        [self.vwQuestion addSubview:btnQuestion];
        buttonYPosition += btnQuestion.bounds.size.height;
    }
    
    buttonYPosition += 32.0f;
    
    heightConstraintForQuestionView.constant = buttonYPosition;
    
    //Hides referral codes input field if referral code is already exist
    if( [RTUserContext sharedInstance].submittedReferralCode ) {
        heightConstraintForReferralCodeView.constant = 0.0f;
    }

    return buttonYPosition + heightConstraintForReferralCodeView.constant;
}

#pragma mark - Actions

- (IBAction)onSubmitButtonClicked:(id)sender {
    [self.view endEditing:YES];
    
    NSString *referralCode = self.tfReferralCode.text;
    
    [self showMessageFieldWithAnimation:YES messageText:@"Submitting" isErrorMessage:NO];
    self.btnSubmit.userInteractionEnabled = NO;
    
    [[RTServerManager sharedInstance] submitReferralCode:referralCode withCompletionBlock:^(BOOL success, RTAPIResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [RTUserContext sharedInstance].submittedReferralCode = YES;
                
                [self showSuccessLabelWithAnimation:YES];
                
                if( self.delegate != nil ) {
                    [self.delegate supportAboutHeaderVC:self onSubmitReferralCode:self.tfReferralCode.text];
                }
                 
            } else {
                if (response.responseCode == 404) { //Case where referral code is invalid
                    [RTUserContext sharedInstance].submittedReferralCode = NO;
                    [self showMessageFieldWithAnimation:YES messageText:@"Sorry, this is an invalid code. Please try again before time runs out." isErrorMessage:YES];
                    
                    NSDate *invalidReferralCodeSubmitDate = [RTUserContext sharedInstance].invalidReferralCodeSubmitDate;
                    
                    if( invalidReferralCodeSubmitDate == nil ) {
                        [RTUserContext sharedInstance].invalidReferralCodeSubmitDate = [NSDate date];
                        
                        if( self.delegate != nil ) {
                            [self.delegate supportAboutHeaderVC:self onReferralCodeInvalidForTheFirstTime:self.tfReferralCode.text];
                        }
                    }
                }
            }
            
            self.btnSubmit.userInteractionEnabled = YES;
        });
    }];
}

- (IBAction)onQuestionSelected:(id)sender {
    int nIndex = (int)((UIButton *)sender).tag;
    
    if( self.delegate != nil ) {
        [self.delegate supportAboutHeaderVC:self onQuestionSelected:questions[nIndex - 1] index:nIndex];
    }
}

#pragma mark - UI Animation

- (void)showMessageFieldWithAnimation:(BOOL)animated messageText:(NSString *)text isErrorMessage:(BOOL)isErrorMessage {
    
    float duration = animated ? 0.2f : 0.0f;
    
    if( heightConstraintForMessageView.constant == 0)
        heightConstraintForReferralCodeView.constant += 33.0f;
    
    heightConstraintForMessageView.constant = 33.0f;
    
    [self.vwMessage setAlpha:0.0f];
    [self.lblError setAlpha:0.0f];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if( !isErrorMessage ) {
            [[RTUIManager sharedInstance] showBoneMessageWithParentView:self.vwMessage messageText:text animating:!isErrorMessage textColor:isErrorMessage ? [UIColor redColor] : [UIColor blackColor] textFont:REGFONT14];
            [UIView animateWithDuration:duration animations:^{
                [self.vwMessage setAlpha:1.0f];
            }];
        }
        else {
            [UIView animateWithDuration:duration animations:^{
                self.lblError.alpha = 1.0f;
            }];
        }
    }];
}

- (void)hideMessageFieldWithAnimation:(BOOL)animated {
    float duration = animated ? 0.2f : 0.0f;

    [UIView animateWithDuration:duration animations:^{
        [self.vwMessage setAlpha:0.0f];
        [self.lblError setAlpha:0.0f];
    } completion:^(BOOL finished) {
        heightConstraintForReferralCodeView.constant -= 33.0f;
        heightConstraintForMessageView.constant = 0.0f;
        
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        }];
    }];
}

- (void)showSuccessLabelWithAnimation:(BOOL)animated {
    float duration = animated ? kAnimationDurationDefault : 0.0f;
    
    self.lblSuccess.alpha = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.lblReferralCode.alpha = 0.0f;
        self.tfReferralCode.alpha = 0.0f;
        self.btnSubmit.alpha = 0.0f;
        self.vwMessage.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.lblSuccess.alpha = 1.0f;
        }];
    }];
}

- (void)hideSuccessLabelWithAnimation:(BOOL)animated {
    float duration = animated ? kAnimationDurationDefault : 0.0f;
    
    self.lblReferralCode.alpha = 0.0f;
    self.tfReferralCode.alpha = 0.0f;
    self.btnSubmit.alpha = 0.0f;
    self.vwMessage.alpha = 0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.lblSuccess.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.lblReferralCode.alpha = 1.0f;
            self.tfReferralCode.alpha = 1.0f;
            self.btnSubmit.alpha = 1.0f;
            self.vwMessage.alpha = 1.0f;
        }];
    }];
}

/*!
    @brief  Create timer with interval, and dismiss the referral code view after the interval time
 **/
- (void)createTimerWithInterval:(float)interval {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval * 60 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [RTUserContext sharedInstance].submittedReferralCode = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReferralCodeTimeout object:nil];
    });
}

@end
