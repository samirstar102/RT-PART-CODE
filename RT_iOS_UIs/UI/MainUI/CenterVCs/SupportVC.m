//
//  SupportVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "SupportVC.h"
#import "SupportSupportVC.h"
#import "SupportAboutVC.h"
#import "SupportChangelogVC.h"
#import "RTStoryboardManager.h"
#import "SupportAfterSubmissionVC.h"

#define kPageIndexAboutVC     (0)
#define kPageIndexSupportVC   (1)
#define kPageIndexChangelogVC    (2)

@interface SupportVC () <SupportSupportVCDelegate>
{
    SupportSupportVC *supportVC;
    SupportAboutVC *aboutVC;
    SupportChangelogVC *changelogVC;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segNavigation;
@property (weak, nonatomic) IBOutlet UIView *vwContent;

@end

@implementation SupportVC

@synthesize vwContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    [super initViews];
    
    if( supportVC == nil ) {
        supportVC = (SupportSupportVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportSupportVC storyboardName:kStoryboardSupport];
        if( self.discount != nil )
            [supportVC setDiscount:self.discount];
        supportVC.delegate = self;
        [supportVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:supportVC.view];
        [self addChildViewController:supportVC];
    }
    
    if( aboutVC == nil ) {
        aboutVC = (SupportAboutVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportAboutVC storyboardName:kStoryboardSupport];
        [aboutVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:aboutVC.view];
        [self addChildViewController:aboutVC];
    }
    
    if( changelogVC == nil ) {
        changelogVC = (SupportChangelogVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportChangelogVC storyboardName:kStoryboardSupport];
        [changelogVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:changelogVC.view];
        [self addChildViewController:changelogVC];
    }
    
    if( self.discount != nil ) {
        [self.segNavigation setSelectedSegmentIndex:kPageIndexSupportVC];
        [self showPageAtIndex:kPageIndexSupportVC animated:NO];
    }
    else {
        [self showPageAtIndex:kPageIndexAboutVC animated:NO];
    }
}

- (void)initEvents {
    [super initEvents];
}

- (void)setDefaultSelection:(int)nIndex {
    if( supportVC == nil ) {
        supportVC = (SupportSupportVC*) [[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportSupportVC storyboardName:kStoryboardSupport];
        if( self.discount != nil )
            [supportVC setDiscount:self.discount];
        [supportVC setDefaultSelection:nIndex];
        supportVC.delegate = self;
        [supportVC.view setFrame:vwContent.bounds];
        [vwContent addSubview:supportVC.view];
        [self addChildViewController:supportVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @brief  It shows a page among FollowingVC, UpdatesVC and SettingsVC with its index
 
 @param  index       The index of the view controller
 @param  animated    Flag indicating whether should be animated while appearing
 */
- (void)showPageAtIndex : (NSUInteger)index animated:(BOOL)animated {
    UIViewController *vc;
    switch( index ) {
        case kPageIndexSupportVC:
            vc = supportVC;
            break;
        case kPageIndexAboutVC:
            vc = aboutVC;
            break;
        case kPageIndexChangelogVC:
            vc = changelogVC;
            break;
    }
    
    float duration = 0.0f;
    if( animated )
        duration = kAnimationDurationDefault;
    
    [UIView animateWithDuration:duration animations:^{
        //Hides all child view controllers before appearance
        supportVC.view.alpha = 0.0f;
        aboutVC.view.alpha = 0.0f;
        changelogVC.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            //Shows the child view controller at index
            vc.view.alpha = 1.0f;
        }];
    }];
}

/*!
 @brief     Move to Support after Submission view controller with store info
 
 @param     store       Store which should be shown
 @param     animated    Flag indicates whether to be animated
 */
- (void)bringupSupportAfterSubmissionControllerWithBoneCountChanged:(BOOL)boneCountChanged {
    // show business info
    SupportAfterSubmissionVC *vc = (SupportAfterSubmissionVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportAfterSubmissionVC storyboardName:kStoryboardSupport];
    vc.boneCountChanged = boneCountChanged;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)onNavigationSegmentValueChanged:(id)sender {
    [self.view endEditing:YES];
    
    NSUInteger nSelectedSegmentIndex = [self.segNavigation selectedSegmentIndex];
    
    [self showPageAtIndex:nSelectedSegmentIndex animated:YES];
}

#pragma mark - SupportSupportVC Delegate

- (void)supportSupportVC:(SupportSupportVC *)vc onSubmissionWithSubject:(NSString *)subject {
    [self bringupSupportAfterSubmissionControllerWithBoneCountChanged:NO];
}

- (void)supportSupportVC:(SupportSupportVC *)vc onReportDiscountWithSubject:(NSString *)subject boneCountChanged:(BOOL)boneCountChanged {
    [self bringupSupportAfterSubmissionControllerWithBoneCountChanged:boneCountChanged];
}

@end
