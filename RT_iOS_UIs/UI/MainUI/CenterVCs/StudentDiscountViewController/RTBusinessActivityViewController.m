//
//  RTBusinessActivityViewController.m
//  RoverTown
//
//  Created by Sonny on 10/31/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTBusinessActivityViewController.h"
#import "RTActivityFeedModel.h"
#import "RTActivityFeedCell.h"

@interface RTBusinessActivityViewController ()<UITableViewDataSource, UITableViewDelegate, RTActivityFeedModelDelegate, RTActivityFeedCellDelegate>

@property (nonatomic, strong) NSArray *activities;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) RTActivityFeedModel *activityModel;
@property (nonatomic) NSString *storeId;

@property (nonatomic) UIView *activityImageFullView;
@property (nonatomic) UIImageView *activityImageFullImageView;
@property (nonatomic) UIButton *dismissActivityImageFullViewButton;

@end

@implementation RTBusinessActivityViewController

- (instancetype) initWithStore:(NSString *)store delegate:(id<RTBusinessActivityViewControllerDelegate>)delegate
{
    if (self = [super init]) {
        _activityModel = [[RTActivityFeedModel alloc] initWithDelegate:self];
        _storeId = store;
        [_activityModel getActivitiesForStore:_storeId];
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.allowsSelection = NO;
        [_tableView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RTActivity *activity = nil;
    if (_activities.count) {
        activity = [_activities objectAtIndex:indexPath.row];
    }
    BOOL imageExists = ![activity.imageString isEqualToString:@""];
    return [RTActivityFeedCell heightForCellActivity:activity andView:self.view withImage:imageExists];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RTActivityFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"businessFeedIdentifier"];
    if (cell == nil) {
        cell = [[RTActivityFeedCell alloc] initWithActivity:self.activities[indexPath.row]];
    }
    cell.delegate = self;
    [cell setActivity:self.activities[indexPath.row]];
    return cell;
}

- (void)imageTappedForImage:(UIImage *)image andComment:(NSString *)comment {
    if ([comment isEqualToString:@"(null)"]) {
        [self openFullScreenImage:image];
    } else {
        [self openFullScreenImage:image withComment:comment];
    }
}

-(void)openFullScreenImage:(UIImage*)image withComment:(NSString*)comment {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(imageView.frame)/2 - 140, self.view.frame.size.width, 200)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.activityImageFullImageView = commentImageView;
    [self.activityImageFullImageView setClipsToBounds:YES];
    [self.activityImageFullView addSubview:self.activityImageFullImageView];
    [self.view addSubview:self.activityImageFullView];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    [commentLabel setBackgroundColor:[UIColor clearColor]];
    [commentLabel setAlpha:1.0f];
    [commentLabel setText:comment];
    [commentLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    commentLabel.textColor = [UIColor whiteColor];
    commentLabel.numberOfLines = 0;
    commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [commentLabel setPreferredMaxLayoutWidth:self.view.frame.size.width - 16];
    [commentLabel setFrame:CGRectMake(8, CGRectGetMaxY(self.activityImageFullImageView.frame) + 2, CGRectGetWidth(self.view.frame) - 16, CGRectGetHeight(commentLabel.frame))];
    [commentLabel sizeToFit];
    [self.activityImageFullView addSubview:commentLabel];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissActivityImageFullViewButton = closeImageButton;
    [self.dismissActivityImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissActivityImageFullViewButton sizeToFit];
    [self.activityImageFullView addSubview:self.dismissActivityImageFullViewButton];
    [self.dismissActivityImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(void)openFullScreenImage:(UIImage*)image {
    UIView *imageView = [[UIView alloc] init];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setAlpha:1.0f];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityImageFullView = imageView;
    
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:image];
    [commentImageView setFrame:CGRectMake(0, CGRectGetHeight(imageView.frame)/2 - 140, self.view.frame.size.width, 200)];
    commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.activityImageFullImageView = commentImageView;
    [self.activityImageFullImageView setClipsToBounds:YES];
    [self.activityImageFullView addSubview:self.activityImageFullImageView];
    [self.view addSubview:self.activityImageFullView];
    
    UIButton *closeImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeImageButton setBackgroundColor:[UIColor roverTownColorOrange]];
    [closeImageButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    closeImageButton.layer.cornerRadius = 5.0f;
    [closeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dismissActivityImageFullViewButton = closeImageButton;
    [self.dismissActivityImageFullViewButton addTarget:self action:@selector(closeImageView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissActivityImageFullViewButton sizeToFit];
    [self.activityImageFullView addSubview:self.dismissActivityImageFullViewButton];
    [self.dismissActivityImageFullViewButton setFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2 - 40, CGRectGetHeight(self.view.frame) - 80, 80, 40)];
}

-(IBAction)closeImageView:(id)sender {
    if (self.activityImageFullView) {
        [self.activityImageFullView removeFromSuperview];
    }
}

@end
