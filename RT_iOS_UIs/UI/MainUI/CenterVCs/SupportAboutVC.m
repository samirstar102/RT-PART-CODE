//
//  SupportAboutVC.m
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "SupportAboutVC.h"
#import "SupportAboutCell.h"
#import "RTStoryboardManager.h"
#import "RTUserContext.h"

@interface SupportAboutVC () <UITableViewDataSource, UITableViewDelegate, SupportAboutHeaderVCDelegate, SupportAboutCellDelegate>
{
    NSMutableArray *questionsArray;
    NSMutableArray *answersArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tvAbout;
@property (weak, nonatomic) IBOutlet UIImageView *ivFrameForAboutFooterView;

@end

@implementation SupportAboutVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReferralCodeTimeout:) name:kNotificationReferralCodeTimeout object:nil];
    [self createReferralCodeExpirationTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    questionsArray = [NSMutableArray arrayWithObjects:kAboutQuestion1, kAboutQuestion2, kAboutQuestion3, kAboutQuestion4, kAboutQuestion5, kAboutQuestion6, kAboutQuestion7, kAboutQuestion8, kAboutQuestion9, kAboutQuestion10, kAboutQuestion11, kAboutQuestion12, kAboutQuestion13, kAboutQuestion14, kAboutQuestion15, kAboutQuestion16, kAboutQuestion17, kAboutQuestion18, nil];
    answersArray = [NSMutableArray arrayWithObjects:kAboutAnswer1, kAboutAnswer2, kAboutAnswer3, kAboutAnswer4, kAboutAnswer5, kAboutAnswer6, kAboutAnswer7, kAboutAnswer8, kAboutAnswer9, kAboutAnswer10, kAboutAnswer11, kAboutAnswer12, kAboutAnswer13, kAboutAnswer14, kAboutAnswer15, kAboutAnswer16, nil];
    
    [self addAboutTableHeaderView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Initialize footer view of Using This App table
    UIBezierPath *maskPathForFooterView;
    
    CGRect frame = self.ivFrameForAboutFooterView.frame;
    frame.origin.y = frame.origin.y - 10;
    frame.size.height = frame.size.height + 10;
    [self.ivFrameForAboutFooterView setFrame:frame];
    
    CGRect boundsOfFooterView = self.ivFrameForAboutFooterView.bounds;
    
    maskPathForFooterView = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(boundsOfFooterView.origin.x, boundsOfFooterView.origin.y, boundsOfFooterView.size.width, boundsOfFooterView.size.height)
                                                  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                        cornerRadii:CGSizeMake(kCornerRadiusDefault, kCornerRadiusDefault)];
    CAShapeLayer *maskLayerForFooterView = [[CAShapeLayer alloc] init];
    maskLayerForFooterView.frame = boundsOfFooterView;
    maskLayerForFooterView.path = maskPathForFooterView.CGPath;
    self.ivFrameForAboutFooterView.layer.mask = maskLayerForFooterView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReferralCodeTimeout:(NSNotification*) notification {
    [self.tvAbout beginUpdates];
    [self addAboutTableHeaderView];
    [self.tvAbout endUpdates];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Data Source, Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return answersArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SupportAboutCell heightForCellWithQuestion:questionsArray[indexPath.row] answer:answersArray[indexPath.row]];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *ident = @"SupportAboutCell";
    
    SupportAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    
    if( indexPath.row == answersArray.count - 1 )
        [cell bind:questionsArray[indexPath.row] answer:answersArray[indexPath.row] isLast:YES];
    else
        [cell bind:questionsArray[indexPath.row] answer:answersArray[indexPath.row] isLast:NO];
    
    cell.delegate = self;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)addAboutTableHeaderView {
    SupportAboutHeaderVC *vc = (SupportAboutHeaderVC *)[[RTStoryboardManager sharedInstance] getViewControllerWithIdentifierFromStoryboard:kSISupportAboutHeaderVC storyboardName:kStoryboardSupport];
    
    vc.delegate = self;
    CGRect bound = vc.view.bounds;
    bound.size.height = [vc getHeightForViewAfterBindingWithQuestionArray:questionsArray];
    
    [vc.view setBounds:bound];
    
    self.tvAbout.tableHeaderView = vc.view;
    self.tvAbout.tableHeaderView = self.tvAbout.tableHeaderView;
    [self addChildViewController:vc];
}

#pragma mark - Actions

- (IBAction)onTapTermsAndServicesLink:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rovertown.com/tos"]];
}

- (IBAction)onTapRoverTownHelpLink:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://help.rovertown.com"]];
}

- (IBAction)onTapBackToTop:(id)sender {
    [self onBackToTopButton];
}

#pragma mark - SupportAboutCell Delegate

-(void)onBackToTopButton {
    [self.tvAbout scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - SupportAboutHeaderVC Delegate

- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onQuestionSelected:(NSString *)question index:(int)index {
    if( index < questionsArray.count - 1 )
        [self.tvAbout scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    else
        [self.tvAbout scrollRectToVisible:self.tvAbout.tableFooterView.frame animated:YES];
}

- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onSubmitReferralCode:(NSString *)referralCode {
//    [self.tvAbout beginUpdates];
//    [self addAboutTableHeaderView];
//    [self.tvAbout endUpdates];
}

- (void)supportAboutHeaderVC:(SupportAboutHeaderVC *)vc onReferralCodeInvalidForTheFirstTime:(NSString *)referralCode {
    [self createReferralCodeExpirationTimer];
}

static BOOL referralCodeTimeRunnng = NO;

- (void)createReferralCodeExpirationTimer {
    double expirationInterval = 60 * 60.0f;
    
    if( [RTUserContext sharedInstance].invalidReferralCodeSubmitDate == nil ) {
        return;
    }
    
    NSDate *invalidReferralCodeSubmitDate = [RTUserContext sharedInstance].invalidReferralCodeSubmitDate;
    
    double intervalSeconds = [invalidReferralCodeSubmitDate timeIntervalSinceNow] + expirationInterval;
    
    if( intervalSeconds < 0 && intervalSeconds > expirationInterval ) {
        [RTUserContext sharedInstance].submittedReferralCode = YES;
        [self onReferralCodeTimeout:nil];
    }
    else {
        if( !referralCodeTimeRunnng ) {
            referralCodeTimeRunnng = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, intervalSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [RTUserContext sharedInstance].submittedReferralCode = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReferralCodeTimeout object:nil];
            });
        }
    }
}

@end
