#import "RoverTownBaseViewController.h"

@interface CenterViewControllerBase : RoverTownBaseViewController

/**
 Initialize the view.
 
 @note Might be overrided.
 */
-(void) initViews;

/**
 Initialize the event of view controller
 
 @note Might be overrided.
 */
-(void) initEvents;

/**
 Set the left navigation bar item as default. The default is menu icon.
 */
-(void)setUpNavBar;

/**
 Set the left navigation bar item as backward arrow icon.
 */
-(void)setUpBackableNavBar;

/**
 Set the navigation bar which has not right navigation item (bones)
 */
-(void)setUpNavBarWithoutBones;

/**
 Set the number of bones which will be displayed on the right side of navigation bar.
 
 @param numberOfBones   Number of bones earned.
 */
-(void)setNumberOfBonesWithNumber:(int)numberOfBones;

/**
 Set the number of badges which will be displayed on the right side of navigation bar.
 
 @param numberOfBadges   Number of badges earned.
 */
-(void)setNumberOfBadgesWithNumber:(int)numberOfBadges;

@end
