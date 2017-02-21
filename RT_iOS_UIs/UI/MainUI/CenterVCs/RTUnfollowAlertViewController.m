//
//  RTUnfollowAlertViewController.m
//  RoverTown
//
//  Created by Sonny on 10/23/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTUnfollowAlertViewController.h"
#import "RTServerManager.h"

@interface RTUnfollowAlertViewController ()

@property (nonatomic, weak) RTStore *storeForSettings;
@property (nonatomic) int storeIdForUnfollow;
@property (nonatomic) BOOL disableAlertMessages;
@property (weak, nonatomic) IBOutlet UIButton *dontAskMeButton;
@property (weak, nonatomic) IBOutlet UILabel *unfollowAlertSubject;
@property (weak, nonatomic) IBOutlet UIImageView *checkedImageView;
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIView *alertSubView;
@property (nonatomic) UITapGestureRecognizer *unfollowRecognizer;

@end

@implementation RTUnfollowAlertViewController

- (id)initWithDiscount:(RTStore *)store
{
    if (self = [super init]) {
        self.storeForSettings = store;
        _storeIdForUnfollow = self.storeForSettings.storeId;
        [self initializeAlertSubjectForBusinessName:store.name];
        self.disableAlertMessages = NO;
        [self.checkedImageView setUserInteractionEnabled:YES];
        self.unfollowRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dontAskMeAgainTappedByUser)];
        [self.checkedImageView addGestureRecognizer:self.unfollowRecognizer];
    }
    return self;
}

- (id)initWithDiscount:(RTStore *)store nibName:(NSString *)nib
{
    if (self = [super initWithNibName:nib bundle:[NSBundle mainBundle]])
    {
        self.storeForSettings = store;
        _storeIdForUnfollow = self.storeForSettings.storeId;
        [self initializeAlertSubjectForBusinessName:store.name];
        self.disableAlertMessages = NO;
        [self.checkedImageView setUserInteractionEnabled:YES];
        self.unfollowRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dontAskMeAgainTappedByUser)];
        [self.checkedImageView addGestureRecognizer:self.unfollowRecognizer];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.disableAlertMessages = NO;
    self.storeForSettings = self.storeForSegue;
    _storeIdForUnfollow = self.storeForSettings.storeId;
    [self initializeAlertSubjectForBusinessName:self.storeForSettings.name];
    self.alertSubView.layer.cornerRadius = kCornerRadiusLarge;
    [self.checkedImageView setUserInteractionEnabled:YES];
    self.unfollowRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dontAskMeAgainTappedByUser)];
    [self.checkedImageView addGestureRecognizer:self.unfollowRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeAlertSubjectForBusinessName:(NSString *)storeName
{
    self.unfollowAlertSubject.text = [NSString stringWithFormat:@"Are you sure you want to unfollow %@? You will no longer receive push notifications about discounts.",storeName];
    self.unfollowAlertSubject.textAlignment = NSTextAlignmentCenter;
}
- (IBAction)dontAskMeButtonPressed:(UIButton *)sender {
    if (!self.disableAlertMessages) {
        [self.checkedImageView setImage:[UIImage imageNamed:@"checked"]];
        self.disableAlertMessages = YES;
    } else {
        [self.checkedImageView setImage:[UIImage imageNamed:@"unchecked"]];
        self.disableAlertMessages = NO;
    }
}
- (IBAction)cancelButtonTapped:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)dontAskMeAgainTappedByUser {
    if (!self.disableAlertMessages) {
        [self.checkedImageView setImage:[UIImage imageNamed:@"checked"]];
        self.disableAlertMessages = YES;
    } else {
        [self.checkedImageView setImage:[UIImage imageNamed:@"unchecked"]];
        self.disableAlertMessages = NO;
    }
}

- (IBAction)okButtonTapped:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.disableAlertMessages forKey:@"showFollowAlerts"];
    NSString *storeToUnfollow = [NSString stringWithFormat:@"%d", self.storeIdForUnfollow];
    [[RTServerManager sharedInstance] followStore:storeToUnfollow isEnabling:NO complete:^(BOOL success, RTAPIResponse *response) {
        if (success) {
            // dismiss VC
            if (self.navigationController) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self.delegate dismissedUnfollowingAlert];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate dismissedUnfollowingAlert];
            }
        } else {
            // show alert that network cannot connect with ok: dismiss
        }
    }];
    if (self.delegate != nil) {
        [self.delegate loadData];
    }
}

@end
