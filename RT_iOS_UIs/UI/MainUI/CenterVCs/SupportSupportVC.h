//
//  SupportSupportVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "CenterViewControllerBase.h"
#import "PlaceholderTextView.h"
#import "RTStudentDiscount.h"

//Constants
#define kSubjectCommentQuestion         (0)
#define kSubjectReportBadDiscount       (1)
#define kSubjectSuggestDiscount         (2)

@class SupportSupportVC;

@protocol SupportSupportVCDelegate <NSObject>

- (void)supportSupportVC:(SupportSupportVC*)vc onSubmissionWithSubject:(NSString*)subject;

- (void)supportSupportVC:(SupportSupportVC*)vc onReportDiscountWithSubject:(NSString*)subject boneCountChanged:(BOOL)boneCountChanged;

@end

@interface SupportSupportVC : UIViewController <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) id<SupportSupportVCDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *commentQuestionCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *badDiscountCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *suggestDiscountCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *feedbackCommentTextview;
@property (nonatomic, retain) RTStudentDiscount *discount;

- (IBAction)onCommentQuestionCheckButton:(id)sender;
- (IBAction)onBadDiscountCheckButton:(id)sender;
- (IBAction)onSuggestDiscountCheckButton:(id)sender;
- (IBAction)onSubmitButton:(id)sender;

- (void)setDefaultSelection:(int)nIndex;

@end
