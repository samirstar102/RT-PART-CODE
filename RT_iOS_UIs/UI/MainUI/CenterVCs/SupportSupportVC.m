//
//  SupportSupportVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//


#import "SupportSupportVC.h"
#import "RTUIManager.h"
#import "RTServerManager.h"
#import "RTLocationManager.h"
#import "SessionMgr.h"
#import "RTStoryboardManager.h"
#import "RTUserContext.h"
#import "RTModelBridge.h"

#define kPlaceholderCommentQuestion     @"Write your comment or question here, tap submit and we will get back to you!"
#define kPlaceholderSuggestDiscount     @"Tell us what discount you\'d like to see on RoverTown including the name and approximate location of the business."
#define kPlaceholderReportBadDiscount   @"Tell us what happened including the discount and the name of the business."

@interface SupportSupportVC ()
{
    int indexOfSelectedRadio;
    NSArray *arrayReportBadDiscountOptions;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForMessageView;
    __weak IBOutlet NSLayoutConstraint *heightConstraintForBadDiscountOptionButton;
    __weak IBOutlet NSLayoutConstraint *bottomConstraintForBadDiscountPickerView;
    __weak IBOutlet NSLayoutConstraint *rightConstraintToCenterForSpinnerIndicator;
    
    NSTimer *animationTimer;
    NSString *reason;
}

@property (weak, nonatomic) IBOutlet UIImageView *waitSpinner;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnReportBadDiscountOptions;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerBadDiscountOptions;
@property (weak, nonatomic) IBOutlet UIView *viewForBadDiscountOptionsPickerView;

@end

@implementation SupportSupportVC

@synthesize discount;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    
    arrayReportBadDiscountOptions = @[@"Discount was refused by employee",  @"I tapped redeem by accident", @"Discount was missing crucial details", @"Only valid online or with paper coupon", @"Promo code did not work", @"Business has permanently closed"];
    reason = @"";
    [Flurry logEvent:@"user_contact_view"];
    [self initViews];
}

- (void)initViews {
    //Initialize container view
    [RTUIManager applyContainerViewStyle:_contentView];
    
    //Initialize feedback comment textview
    [self.feedbackCommentTextview.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.feedbackCommentTextview.layer setBorderWidth:1.0];
    [self.feedbackCommentTextview.layer setCornerRadius:5];
    [self.feedbackCommentTextview setPlaceholderColor:[UIColor grayColor]];
    [self.feedbackCommentTextview setPlaceholderText:kPlaceholderCommentQuestion];
    [self.feedbackCommentTextview setDelegate:self];
    
    //Set up submit button
    [RTUIManager applyDefaultButtonStyle:_submitButton];
    _submitButton.layer.cornerRadius = 2;
    _submitButton.clipsToBounds = YES;
    
    if( discount != nil ) {
        [self onBadDiscountCheckButton:self.badDiscountCheckButton];
    }
    else {
        switch( indexOfSelectedRadio ) {
            case kSubjectCommentQuestion:
                [self onCommentQuestionCheckButton:self.commentQuestionCheckButton];
                break;
            case kSubjectReportBadDiscount:
                [self onReportBadDiscountOptionButton:self.badDiscountCheckButton];
                break;
            case kSubjectSuggestDiscount:
                [self onSuggestDiscountCheckButton:self.suggestDiscountCheckButton];
                break;
        }
        
        heightConstraintForBadDiscountOptionButton.constant = 0;
    }
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.btnReportBadDiscountOptions.bounds.size.height - 1.0f, self.btnReportBadDiscountOptions.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.btnReportBadDiscountOptions.layer addSublayer:bottomBorder];
    
    //Hides table view of bad discount options
    bottomConstraintForBadDiscountPickerView.constant = -250;
    [RTUIManager applyBlurView:self.viewForBadDiscountOptionsPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods

- (void)setDefaultSelection:(int)nIndex {
    indexOfSelectedRadio = nIndex;
}

#pragma mark - Actions

- (IBAction)onCommentQuestionCheckButton:(id)sender {
    [self.commentQuestionCheckButton setSelected:YES];
    [self.badDiscountCheckButton setSelected:NO];
    [self.suggestDiscountCheckButton setSelected:NO];
    indexOfSelectedRadio = kSubjectCommentQuestion;
    [self.feedbackCommentTextview setPlaceholderText:kPlaceholderCommentQuestion];
    heightConstraintForBadDiscountOptionButton.constant = 0;
    [self.view layoutIfNeeded];
}

- (IBAction)onBadDiscountCheckButton:(id)sender {
    [self.commentQuestionCheckButton setSelected:NO];
    [self.badDiscountCheckButton setSelected:YES];
    [self.suggestDiscountCheckButton setSelected:NO];
    indexOfSelectedRadio = kSubjectReportBadDiscount;
    
    if( discount != nil ) {
        if (discount.store.name == nil) {
            [self.feedbackCommentTextview setPlaceholder:kPlaceholderReportBadDiscount];
        } else {
            [self.feedbackCommentTextview setPlaceholderText:[NSString stringWithFormat:@"You are reporting \"%@\" at %@. Add any details, comments or questions here and tap submit!", discount.discountDescription, discount.store.name]];
        }
        
        heightConstraintForBadDiscountOptionButton.constant = 20;
    }
    else {
        [self.feedbackCommentTextview setPlaceholderText:kPlaceholderReportBadDiscount];
    }
    [self.view layoutIfNeeded];
}

- (IBAction)onSuggestDiscountCheckButton:(id)sender {
    [self.commentQuestionCheckButton setSelected:NO];
    [self.badDiscountCheckButton setSelected:NO];
    [self.suggestDiscountCheckButton setSelected:YES];
    indexOfSelectedRadio = kSubjectSuggestDiscount;
    [self.feedbackCommentTextview setPlaceholderText:kPlaceholderSuggestDiscount];
    heightConstraintForBadDiscountOptionButton.constant = 0;
    [self.view layoutIfNeeded];
}

- (IBAction)onReportBadDiscountOptionButton:(id)sender {
    if( [self.feedbackCommentTextview isFirstResponder] ) {
        [self.feedbackCommentTextview resignFirstResponder];
    }
    
    if( bottomConstraintForBadDiscountPickerView.constant == 0 ) {
        bottomConstraintForBadDiscountPickerView.constant = -250;
    }
    else {
        bottomConstraintForBadDiscountPickerView.constant = 0;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onReportBadDiscountOptionDoneButton:(id)sender {
    [self.btnReportBadDiscountOptions setTitle:arrayReportBadDiscountOptions[[self.pickerBadDiscountOptions selectedRowInComponent:0]] forState:UIControlStateNormal];
    reason = arrayReportBadDiscountOptions[[self.pickerBadDiscountOptions selectedRowInComponent:0]];
    
    [self onReportBadDiscountOptionButton:self.btnReportBadDiscountOptions];
}

- (IBAction)onSubmitButton:(id)sender {
    
    //Validating comment
    NSString *message = self.feedbackCommentTextview.text;
    
    //Set message as empty string if feedback comment is placeholder text
    if( [message isEqualToString:@""] ) {
        [self showWaitAnimationWithMessage:@"Comment is required." showSpinner:NO];
        return;
    }
    [Flurry logEvent:@"user_comment_or_suggestion"];
    //Make the submit button disabled while submittig
    [self.submitButton setEnabled:NO];
    
    if( heightConstraintForMessageView.constant != 0.0f )
        [self hideWaitAnimation];
    [self showWaitAnimationWithMessage:@"Submitting..." showSpinner:YES];
    
    NSString *subject = @"";
    
    switch( indexOfSelectedRadio ) {
        case 0:
            subject = self.commentQuestionCheckButton.titleLabel.text;
            break;
            
        case 1:
            subject = self.badDiscountCheckButton.titleLabel.text;
            break;
            
        case 2:
            subject = self.suggestDiscountCheckButton.titleLabel.text;
            break;
    }
    
    if( discount == nil || discount.store == nil ) {
        [[RTServerManager sharedInstance] supportTicketWithSubject:subject message:message complete:^(BOOL success, RTAPIResponse *response) {
            if( success ) {
                //Show success screen
                dispatch_async(dispatch_get_main_queue(), ^{
                    if( self.delegate )
                        [self.delegate supportSupportVC:self onSubmissionWithSubject:subject];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showWaitAnimationWithMessage:@"Submission failed." showSpinner:NO];
                    
                    [self.submitButton setEnabled:YES];
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self hideWaitAnimation];
                });
            }
        }];
    }
    else {
        [[RTServerManager sharedInstance] reportDiscountWithSubject:subject reason:reason message:message storeId:discount.store.storeId discountId:discount.discountId latitude:[RTLocationManager sharedInstance].latitude longitude:[RTLocationManager sharedInstance].longitude complete:^(BOOL success, RTAPIResponse *response) {
            if( success ) {
                //Show success screen
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[RTServerManager sharedInstance] getUser:^(BOOL success, RTAPIResponse *response) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            BOOL userBoneCountChanged = NO;
                            if( success ) {
                                RTUser *user = [RTModelBridge getUserWithDictionary:[response.jsonObject objectForKey:@"user"]];
                                if (user.boneCount != [RTUserContext sharedInstance].currentUser.boneCount) {
                                    [RTUserContext sharedInstance].boneCount = user.boneCount;
                                    userBoneCountChanged = YES;
                                }
                                [RTUserContext sharedInstance].currentUser = user;
                            }
                            
                            if( self.delegate )
                                [self.delegate supportSupportVC:self onReportDiscountWithSubject:subject boneCountChanged:userBoneCountChanged];
                        });
                    }];
                });
            }
            else {
                [self showWaitAnimationWithMessage:@"Submission failed." showSpinner:NO];
                
                [self.submitButton setEnabled:YES];
            }
        }];
    }
}

- (IBAction)dismissInputKeyboard:(id)sender {
    [self.feedbackCommentTextview resignFirstResponder];
    
    if( bottomConstraintForBadDiscountPickerView.constant == 0 ) {
        [self onReportBadDiscountOptionButton:self.btnReportBadDiscountOptions];
    }
}

#pragma mark Keyboard state
//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
    CGRect missingLabelRect = [self.feedbackCommentTextview.superview convertRect:self.feedbackCommentTextview.frame toView:self.view];
    if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    [self.scrollView scrollRectToVisible:self.feedbackCommentTextview.frame animated:YES];
}
//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if( bottomConstraintForBadDiscountPickerView.constant == 0 ) {
        [self onReportBadDiscountOptionButton:self.btnReportBadDiscountOptions];
    }
    [self.feedbackCommentTextview becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    //Hides "Comment is required" message if inputting comment started
    if( heightConstraintForMessageView.constant != 0.0f )
        [self hideWaitAnimation];
}

#pragma mark - Animation
- (void)showWaitAnimationWithMessage:(NSString*)message showSpinner:(BOOL)bShowSpinner {
    //Adjust the position of spinner indicator to align center
    
    UILabel *lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [lblTemp setText:message];
    [lblTemp setFont:REGFONT14];
    [lblTemp setNumberOfLines:1];
    [lblTemp sizeToFit];
    rightConstraintToCenterForSpinnerIndicator.constant = lblTemp.bounds.size.width / 2;
    
    [self.view layoutIfNeeded];
    
    heightConstraintForMessageView.constant = 30.0f;
    
    if( bShowSpinner ) {
        //Spinner Animation
        [self.messageLabel setTextColor:[UIColor blackColor]];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.view layoutIfNeeded];
        }];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        rotationAnimation.duration = 1.0f;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = INFINITY;
        
        [self.waitSpinner.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        //Message Text Animation
        if( !animationTimer ) {
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(submitMessageAnimation:) userInfo:nil repeats:YES];
        }
    }
    else {
        if( [animationTimer isValid] ) {
            [animationTimer invalidate];
        }
        animationTimer = nil;
        
        [self.waitSpinner.layer removeAllAnimations];
        [self.messageLabel setTextColor:[UIColor redColor]];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    self.messageLabel.text = message;
}

- (void)hideWaitAnimation {
    heightConstraintForMessageView.constant = .0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)submitMessageAnimation:(NSTimer*) timer {
    static int nValue = 0;
    
    nValue++;
    
    nValue = nValue % 3;
    
    switch (nValue) {
        case 0:
            [self.messageLabel setText:@"Submitting."];
            break;
        case 1:
            [self.messageLabel setText:@"Submitting.."];
            break;
        case 2:
            [self.messageLabel setText:@"Submitting..."];
            break;
        default:
            [self.messageLabel setText:@"Submitting..."];
            break;
    }
}

#pragma mark - Picker view delegate, data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return arrayReportBadDiscountOptions.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 20;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *viewForRow = (UILabel *)view;
    
    if( viewForRow == nil ) {
        viewForRow = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 20)];
        viewForRow.textAlignment = NSTextAlignmentCenter;
        [viewForRow setFont:REGFONT14];
    }
    
    viewForRow.text = [arrayReportBadDiscountOptions objectAtIndex:row];
    
    return viewForRow;
}


@end