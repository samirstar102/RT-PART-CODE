//
//  RTDiscountCommentTableViewController.m
//  RoverTown
//
//  Created by Sonny on 11/4/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountCommentTableViewController.h"
#import "RTActivityFeedCell.h"
#import "RTDiscountCommentCell.h"
#import "RTActivity.h"
#import "RTComment.h"

@interface RTDiscountCommentTableViewController () <RTActivityFeedCellDelegate>

@property (nonatomic) RTDiscountCommentModel *model;
@property (nonatomic) UITableView *activitiesTableView;
@property (nonatomic) UITableView *commentsTableView;
@property (nonatomic) NSArray *activitiesArray;
@property (nonatomic) NSArray *commentsArray;
@property (nonatomic) UIImageView *spinnerView;

@end

@implementation RTDiscountCommentTableViewController

- (instancetype)initWithModel:(RTDiscountCommentModel *)model delegate:(id<RTDiscountCommentTableViewDelegate>)delegate {
    if (self = [super init]) {
        self.model = model;
        self.delegate = delegate;
        self.model.delegate = self;
        self.activitiesTableView.delegate = self;
        self.commentsTableView.delegate = self;
        self.activitiesTableView.dataSource = self;
        self.commentsTableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)commentsSuccess:(NSArray *)comments {
    NSArray *commentsArray = [NSArray arrayWithArray:comments];
    [self.commentsTableView.tableFooterView setHidden:YES];
    if (self.commentsArray.count && commentsArray.count > self.commentsArray.count) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSIndexPath *indexPath;
        for (int i=0; i < commentsArray.count - self.commentsArray.count; i++) {
            indexPath = [NSIndexPath indexPathForRow:self.commentsArray.count + i inSection:0];
            [indexPaths addObject:indexPath];
        }
        self.commentsArray = commentsArray;
        [self.commentsTableView beginUpdates];
        [self.commentsTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.commentsTableView endUpdates];
        
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commentsTableView reloadData];
        });
        [self.view addSubview:self.commentsTableView];
    }
    [self hideSpinner];

}

- (void)activitiesSuccess:(NSArray *)activities {
    NSArray *activitiesArray = [NSArray arrayWithArray:activities];
    self.activitiesArray = activitiesArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activitiesTableView reloadData];
    });
    [self.view addSubview:self.activitiesTableView];
    [self hideSpinner];
}

- (void)commentsFailed {
    
}

- (void)activitiesFailed {
    
}

- (void)commentsSegmentTapped {
    [self showCommentsTableViewWithAnimated:YES];
    [self showSpinner];
    [self.model getComments];
    _commentsTableView = [[UITableView alloc] init];
    [_commentsTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40)];
    [_commentsTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)activitySegmentTapped {
    [self showActivitiesTableViewWithAnimated:YES];
    [self showSpinner];
    [self.model getActivities];
    _activitiesTableView = [[UITableView alloc] init];
    [_activitiesTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_activitiesTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)showCommentsTableViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if (animated) {
        duration = 0.2f;
    }
    [UIView animateWithDuration:duration animations:^{
        [self.activitiesTableView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.commentsTableView setAlpha:1.0f];
        }];
    }];
    _activitiesTableView = nil;
}

- (void)showActivitiesTableViewWithAnimated:(BOOL)animated {
    float duration = 0.0f;
    if (animated) {
        duration = 0.2f;
    }
    [UIView animateWithDuration:duration animations:^{
        [self.commentsTableView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            [self.activitiesTableView setAlpha:1.0f];
        }];
    }];
    _commentsTableView = nil;
}

#pragma mark - spinnerView

-(void)showSpinner {
    if (!self.spinnerView) {
        UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinner.png"]];
        [spinner sizeToFit];
        [spinner setFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-CGRectGetWidth(spinner.frame), CGRectGetMidY(self.view.bounds)-CGRectGetHeight(spinner.frame), CGRectGetWidth(spinner.frame)*2, CGRectGetHeight(spinner.frame)*2)];
        [self.view addSubview:spinner];
        self.spinnerView = spinner;
        
        CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        fullRotation.fromValue = [NSNumber numberWithFloat:0];
        fullRotation.toValue = [NSNumber numberWithFloat:MAXFLOAT];
        fullRotation.duration = MAXFLOAT * 0.2;
        fullRotation.removedOnCompletion = YES;
        [self.spinnerView.layer addAnimation:fullRotation forKey:nil];
    }
}

-(void)hideSpinner {
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.activitiesTableView) {
        return self.activitiesArray.count;
    } else if (tableView == self.commentsTableView) {
        return self.commentsArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.activitiesTableView) {
        RTActivity *activity = nil;
        if (self.activitiesArray.count) {
            activity = [self.activitiesArray objectAtIndex:indexPath.row];
        }
        BOOL imageExists = ![activity.imageString isEqualToString:@""];
        return [RTActivityFeedCell heightForCellActivity:activity andView:self.view withImage:imageExists];
    } else if (tableView == self.commentsTableView) {
        return 100;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.activitiesTableView) {
        RTActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCellIdentifier"];
        if (cell == nil) {
            cell = [[RTActivityFeedCell alloc] initWithActivity:self.activitiesArray[indexPath.row]];
        }
        cell.delegate = self;
        [cell setActivity:self.activitiesArray[indexPath.row]];
        return cell;
    } else {
        return nil;
    }
}


@end
