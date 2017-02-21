//
//  SupportAfterSubmissionVC.m
//  RoverTown
//
//  Created by Robin Denis on 5/19/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "SupportAfterSubmissionVC.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "SessionMgr.h"
#import "StudentDiscountsViewController.h"
#import "RTStoryboardManager.h"
#import "UIViewController+MMDrawerController.h"
#import "LeftNavViewController.h"

@interface SupportAfterSubmissionVC()

@property (weak, nonatomic) IBOutlet UITextView *thanksLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToStudentDiscountsButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)onGoToStudentDiscounts:(id)sender;

@end

@implementation SupportAfterSubmissionVC

@synthesize boneCountChanged;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up Go To Student Discounts button
    [RTUIManager applyDefaultButtonStyle:self.goToStudentDiscountsButton];
    self.goToStudentDiscountsButton.layer.cornerRadius = 2;
    [self.goToStudentDiscountsButton setClipsToBounds:YES];
    
    //Initialize Comment textview
    NSString *comment = self.commentLabel.text;
    if( ![[RTUserContext sharedInstance].email isEqualToString:@""] ) {
        self.commentLabel.text = [comment stringByReplacingOccurrencesOfString:@"name@university.edu" withString:[RTUserContext sharedInstance].email];
    }
    else {
        self.commentLabel.text = [comment stringByReplacingOccurrencesOfString:@"name@university.edu" withString:@"your email address"];
    }
    
    self.thanksLabel.editable = NO;
    self.commentLabel.editable = NO;
    
    //Initialize container view
    [RTUIManager applyContainerViewStyle:self.commentLabel];
    [RTUIManager applyContainerViewStyle:self.containerView];
}

- (void)initViews {
    [super initViews];
    
    if( boneCountChanged ) {
        [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
        [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:nil];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onGoToStudentDiscounts:(id)sender {
    [SessionMgr transitionSystemStateRequest:SessionMgrState_StudentDiscounts];
    StudentDiscountsViewController *vc = (StudentDiscountsViewController *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSIStudentDiscountsVC storyboardName:kStoryboardStudentDiscounts];
    [self.navigationController pushViewController:vc animated:YES];
    
    LeftNavViewController *leftNavVC = (LeftNavViewController*)[self.mm_drawerController leftDrawerViewController];
    [leftNavVC.tableView reloadData];
}
@end