//
//  FollowingSettingsCell.h
//  RoverTown
//
//  Created by Robin Denis on 6/22/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

@class FollowingSettingsCell;

@protocol FollowingSettingsCellDelegate <NSObject>

@optional
- (void)onFollowingSettingChanged:(BOOL)isOn settingTitle:(NSString*)title;

@end

@interface FollowingSettingsCell : UITableViewCell

+ (CGFloat)heightForCellWithDescription:(NSString *)description;

- (void)bind:(NSString*)title description:(NSString*)description isOn:(BOOL)isOn corner:(UIRectCorner)corner;

@property (nonatomic, weak) id<FollowingSettingsCellDelegate> delegate;

@end
