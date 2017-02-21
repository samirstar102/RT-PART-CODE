//
//  FollowingFollowingVC.h
//  RoverTown
//
//  Created by Robin Denis on 10/7/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "FollowingCell.h"
#import "BusinessInfoVC.h"
#import "RTAlertView.h"
#import "RTAlertViewController.h"
#import "RTUnfollowAlertViewController.h"

@interface FollowingFollowingVC : UIViewController <UITableViewDataSource, UITableViewDelegate, FollowingCellDelegate, BusinessInfoVCDelegate, RTAlertViewControllerDelegate, RTAlertViewProtocol, RTUnfollowAlertViewControllerDelegate>

@end
