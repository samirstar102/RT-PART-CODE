//
//  RTPublicProfileViewController.m
//  RoverTown
//
//  Created by Sonny Rodriguez on 12/11/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTPublicProfileViewController.h"
#import "RTPublicProfileTopView.h"
#import "RTPublicProfileTableHeaderView.h"
#import "RTUser.h"
#import "RTUserContext.h"
#import "RTPublicUser.h"
#import "RTActivityFeedViewController.h"
#import "NSDate+Utilities.h"

#define kPublicProfileTopViewHeight 125
#define kPublicProfileHeaderHeight 100
#define kPublicProfileHeaderForPrivateHeight 150

@interface RTPublicProfileViewController () <RTPublicProfileTopViewDelegate, RTPublicProfileViewModelDelegate, RTPUblicProfileHeaderViewDelegate>

@property (nonatomic) RTPublicProfileTopView *profileTopView;
@property (nonatomic) RTPublicProfileViewModel *profileModel;
@property (nonatomic) RTPublicProfileTableHeaderView *profileHeaderView;
@property (nonatomic) RTPublicUser *user;
@property (nonatomic) RTActivityFeedViewController *activityViewController;
@property (nonatomic) BOOL isPrivate;

@end

@implementation RTPublicProfileViewController

- (id)initWithUserId:(int)userId {
    self.isPrivate = NO;
    self = [super init];
    self.profileModel = [[RTPublicProfileViewModel alloc] initWithUserId:userId andDelegate:self];
    self.activityViewController = [[RTActivityFeedViewController alloc] initWithUserId:userId];
    self.profileTopView = [[RTPublicProfileTopView alloc] initWithDelegate:self];
    self.profileHeaderView = [[RTPublicProfileTableHeaderView alloc] initWithDelegate:self];
    [self.view addSubview:self.profileTopView];
    
    return self;
}

- (id)initForPrivateUser {
    self.isPrivate = YES;
    self = [super init];
    self.profileModel = [[RTPublicProfileViewModel alloc] initWithUserId:[RTUserContext sharedInstance].userId andDelegate:self];
    self.activityViewController = [[RTActivityFeedViewController alloc] initWithUserId:[RTUserContext sharedInstance].userId];
    self.profileTopView = [[RTPublicProfileTopView alloc] initWithDelegate:self];
    self.profileHeaderView = [[RTPublicProfileTableHeaderView alloc] initForPrivateUserWithDelegate:self];
    [self.view addSubview:self.profileTopView];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackableNavBar];
    
    [self.profileTopView setFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), kPublicProfileTopViewHeight)];
    
    CGFloat remainingHeight;
    
    if (self.isPrivate) {
        remainingHeight = self.view.frame.size.height - self.profileTopView.frame.size.height - 110;
    } else {
        remainingHeight = self.view.frame.size.height - self.profileTopView.frame.size.height - 65;
    }
    
    if (self.isPrivate) {
        [self.profileHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, kPublicProfileHeaderForPrivateHeight)];
    } else {
        [self.profileHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, kPublicProfileHeaderHeight)];
    }
    
    [self.activityViewController.view setFrame:CGRectMake(0, kPublicProfileTopViewHeight, self.view.frame.size.width, self.view.frame.size.height - self.profileTopView.frame.size.height)];
    
    [self.activityViewController.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, remainingHeight)];
    
    self.activityViewController.tableView.tableHeaderView = self.profileHeaderView;
    
    [self.view addSubview:self.activityViewController.view];
}

- (void)profileImageReturned:(UIImage *)profileImage {

}

- (void)publicProfileReturned:(RTPublicUser *)publicUser {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTitle:publicUser.nickName];
    });
    [self.profileTopView setUserName:publicUser.nickName school:publicUser.school bones:publicUser.boneCount badges:publicUser.badgeCount];
    [self.profileTopView setProfileImageFromUrl:publicUser.userProfilePicture];
    [self.profileHeaderView setGender:publicUser.gender birthday:[publicUser.birthday stringWithFormat:@"MM/dd/yyyy"] major:publicUser.major discounts:publicUser.totalDiscountsAdded comments:publicUser.totalComments votes:publicUser.totalVotes];
}

- (void)publicProfileFailed {
    
}

- (void)editButtonTapped {
    if (self.delegate != nil) {
        [self.delegate editEnabled];
    }
}

@end
