//
//  ProfileQuestionVC.m
//  RoverTown
//
//  Created by Robin Denis on 8/29/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "ProfileQuestionVC.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "RTUser.h"

#import "NSDate+Utilities.h"

#define INDEX_QUESTION_NAME (0)
#define INDEX_QUESTION_GENDER (1)
#define INDEX_QUESTION_BIRTHDAY (2)
#define INDEX_QUESTION_MAJOR (3)

@interface ProfileQuestionVC () <UITextFieldDelegate> {
    int indexOfQuestion;
    
    NSString *firstName, *lastName, *gender;
    NSDate *birthdate;
    NSString *major;
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIView *vwName;
@property (weak, nonatomic) IBOutlet UIView *vwGender;
@property (weak, nonatomic) IBOutlet UIView *vwBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnMajor;
@property (weak, nonatomic) IBOutlet UIView *vwMajor;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;
@property (weak, nonatomic) IBOutlet UIButton *btnFillOutMyProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnDismiss;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;

@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;
@property (weak, nonatomic) IBOutlet UIButton *btnUnspecified;

@end

@implementation ProfileQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    indexOfQuestion = INDEX_QUESTION_NAME;
    gender = kGenderUnspecified;
    
    [self initView];
}

- (void)initView {
    [RTUIManager applyContainerViewStyle:self.ivFrame];
    [RTUIManager applyRateUsPositiveButtonStyle:self.btnSubmit];
    [RTUIManager applyRateUsNegativeButtonStyle:self.btnDismiss];
    
    [RTUIManager applyDefaultTextFieldStyle:self.tfFirstName placeholderText:@"First name"];
    [RTUIManager applyDefaultTextFieldStyle:self.tfLastName placeholderText:@"Last name"];
    
    RTUser *currentUser = [RTUserContext sharedInstance].currentUser;
    [self.tfFirstName setText:currentUser.firstName];
    [self.tfFirstName setDelegate:self];
    [self.tfLastName setText:currentUser.lastName];
    [self.tfLastName setDelegate:self];
    gender = currentUser.gender;
    [self setRadioButtonWithGender:gender];
    
    //Initializes the birthday button with users birthday
    NSString *birthday = [currentUser.birthday stringWithFormat:@"MM/dd/yyyy"];
    if( birthday.length != 0 )
        [self.btnBirthday setTitle:birthday forState:UIControlStateNormal];
    else {
        [self.btnBirthday setTitle:NSLocalizedString(@"Profile_Tap_To_Add_Birthday", nil) forState:UIControlStateNormal];
    }
    
    //Initialize the major button
    if( currentUser.major.length > 0 )
        [self.btnMajor setTitle:currentUser.major forState:UIControlStateNormal];
    
    [self showNameQuestionWithAnimated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [RTUIManager applyDropdownButtonWithBlueBackgroundStyle:self.btnBirthday];
    [RTUIManager applyDropdownButtonWithBlueBackgroundStyle:self.btnMajor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)showNameQuestionWithAnimated:(BOOL)animated {
    indexOfQuestion = INDEX_QUESTION_NAME;
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration / 2 animations:^{
        [self.lblQuestion setAlpha:0.0f];
        [self hideAllAnswers];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            self.lblQuestion.text = NSLocalizedString(@"Profile_Question_Name", nil);
            [self.lblQuestion setAlpha:1.0f];
            [self.vwName setAlpha:1.0f];
        }];
    }];
}

- (void)showGenderQuestionWithAnimated:(BOOL)animated {
    indexOfQuestion = INDEX_QUESTION_GENDER;
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration / 2 animations:^{
        [self.lblQuestion setAlpha:0.0f];
        [self hideAllAnswers];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            self.lblQuestion.text = NSLocalizedString(@"Profile_Question_Gender", nil);
            [self.lblQuestion setAlpha:1.0f];
            [self.vwGender setAlpha:1.0f];
        }];
    }];
}

- (void)showBirthdayQuestionWithAnimated:(BOOL)animated {
    indexOfQuestion = INDEX_QUESTION_BIRTHDAY;
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration / 2 animations:^{
        [self.lblQuestion setAlpha:0.0f];
        [self hideAllAnswers];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            self.lblQuestion.text = NSLocalizedString(@"Profile_Question_Birthday", nil);
            [self.lblQuestion setAlpha:1.0f];
            [self.vwBirthday setAlpha:1.0f];
        }];
    }];
}

- (void)showMajorQuestionWithAnimated:(BOOL)animated {
    indexOfQuestion = INDEX_QUESTION_MAJOR;
    
    float duration = 0.0f;
    
    if( animated ) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration / 2 animations:^{
        [self.lblQuestion setAlpha:0.0f];
        [self hideAllAnswers];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration / 2 animations:^{
            self.lblQuestion.text = NSLocalizedString(@"Profile_Question_Major", nil);
            [self.lblQuestion setAlpha:1.0f];
            [self.vwMajor setAlpha:1.0f];
        }];
    }];
}

- (void)hideAllAnswers {
    [self.vwName setAlpha:0.0f];
    [self.vwGender setAlpha:0.0f];
    [self.vwMajor setAlpha:0.0f];
    [self.vwBirthday setAlpha:0.0f];
}

#pragma mark - Actions

- (IBAction)onDismissButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileQuestionVC:self onDismiss:indexOfQuestion];
    }
}

- (IBAction)onSubmitButton:(id)sender {
    [self.view endEditing:YES];
    
    switch (indexOfQuestion) {
        case INDEX_QUESTION_NAME:
            [self showGenderQuestionWithAnimated:YES];
            break;
            
        case INDEX_QUESTION_GENDER:
            [self showBirthdayQuestionWithAnimated:YES];
            break;
            
        case INDEX_QUESTION_BIRTHDAY:
            [self showMajorQuestionWithAnimated:YES];
            break;
            
        case INDEX_QUESTION_MAJOR:
            firstName = self.tfFirstName.text;
            lastName = self.tfLastName.text;
            if( self.delegate != nil ) {
                [self.delegate profileQuestionVC:self onDone:indexOfQuestion firstName:firstName lastName:lastName gender:gender birthdate:birthdate major:major];
            }
            break;
    }
}

- (IBAction)onFillOutMyProfile:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileQuestionVC:self onFillOutMyProfile:indexOfQuestion];
    }
}

- (IBAction)onMajorButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileQuestionVC:self onPickMajor:indexOfQuestion];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMajorSetNotification:) name:@"MajorSetNotification" object:nil];
    }
}

- (IBAction)onBirthdayButton:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileQuestionVC:self onPickBirthday:indexOfQuestion];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBirthdaySetNotification:) name:@"BirthdaySetNotification" object:nil];
    }
}

- (void)receiveBirthdaySetNotification:(NSNotification *)notification {
    NSDate *birthday = [[notification userInfo] objectForKey:@"birthday"];
    
    birthdate = birthday;
    
    [self.btnBirthday setTitle:[birthday stringWithFormat:@"MM/dd/yyyy"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveMajorSetNotification:(NSNotification *)notification {
//    int majorId = [(NSNumber *)[[notification userInfo] objectForKey:@"majorId"] intValue];
    NSString *majorName = [[notification userInfo] objectForKey:@"majorName"];
    
    major = majorName;
    
    [self.btnMajor setTitle:majorName forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Gender buttons actions

- (void)setRadioButtonWithGender:(NSString *)userGender {
    if( [userGender isEqualToString:kGenderMale] ) {
        [self onMaleButton:self.btnMale];
    }
    else if( [userGender isEqualToString:kGenderFemale] ) {
        [self onFemaleButton:self.btnFemale];
    }
    else {
        [self onUnspecifiedButton:self.btnUnspecified];
    }
}

- (IBAction)onMaleButton:(id)sender {
    gender = kGenderMale;
    
    [self.btnMale setSelected:YES];
    [self.btnFemale setSelected:NO];
    [self.btnUnspecified setSelected:NO];
}

- (IBAction)onFemaleButton:(id)sender {
    gender = kGenderFemale;
    
    [self.btnMale setSelected:NO];
    [self.btnFemale setSelected:YES];
    [self.btnUnspecified setSelected:NO];
}

- (IBAction)onUnspecifiedButton:(id)sender {
    gender = kGenderUnspecified;
    
    [self.btnMale setSelected:NO];
    [self.btnFemale setSelected:NO];
    [self.btnUnspecified setSelected:YES];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if( self.tfFirstName == textField ) {
        [self.tfFirstName resignFirstResponder];
        [self.tfLastName becomeFirstResponder];

        return NO;
    }
    else if( self.tfLastName == textField ) {
        [self.tfLastName resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

@end
