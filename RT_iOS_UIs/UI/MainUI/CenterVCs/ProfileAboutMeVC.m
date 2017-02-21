//
//  ProfileAboutMeVC.m
//  
//
//  Created by Robin Denis on 8/17/15.
//
//

#import "ProfileAboutMeVC.h"
#import "RTUIManager.h"
#import "RTUserContext.h"
#import "UIColor+Config.h"
#import "NSDate+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileAboutMeVC ()
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivFrame;
@property (weak, nonatomic) IBOutlet UIView *vwContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnEditAboutMe;
@property (weak, nonatomic) IBOutlet UIButton *btnBones;
@property (weak, nonatomic) IBOutlet UIButton *btnBadges;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblUniversity;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lblMajor;

@end

@implementation ProfileAboutMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initEvent];
}

- (void)initView {
    [RTUIManager applyContainerViewStyle:self.ivFrame];
    [RTUIManager applyDefaultButtonStyle:self.btnEditAboutMe];
    
    [RTUIManager applyDefaultBorderView:self.vwContainer];
    [RTUIManager applyDefaultBorderView:self.btnBones];
    [RTUIManager applyDefaultBorderView:self.btnBadges];
    
    //Initialize with data
    [self.btnBones setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].boneCount] forState:UIControlStateNormal];
    [self.btnBadges setTitle:[NSString stringWithFormat:@"%d", [RTUserContext sharedInstance].badgeTotalCount] forState:UIControlStateNormal];
    //Initialize UI controls for profile info
    if( [RTUserContext sharedInstance].studentProfileImage != nil )
        [self.ivProfilePicture setImage:[RTUserContext sharedInstance].studentProfileImage];
    else
        [self.ivProfilePicture setImage:[UIImage imageNamed:@"person_default_icon"]];
    [self displayUniversity];
    [self displayName];
    [self displayGender];
    [self displayBirthday];
    [self displayMajor];
}

- (void)initEvent {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)onEditAboutMe:(id)sender {
    if( self.delegate != nil ) {
        [self.delegate profileAboutMeVC:self onEditAboutMeWithAnimated:YES];
    }
}

#pragma mark - UI Methods

- (void)displayUniversity {
    NSString *university = [RTUserContext sharedInstance].currentUser.school;
    
    if( university.length != 0 ) {
        [self.lblUniversity setText:university];
    }
}

- (void)displayName {
    NSString *name = [NSString stringWithFormat:@"%@ %@", [RTUserContext sharedInstance].currentUser.firstName, [RTUserContext sharedInstance].currentUser.lastName];
    if( name.length == 1 ) {    //if first name and last name are not specified
        [self.lblName setText:NSLocalizedString(@"Profile_Error_No_Name_Specified", nil)];
        [self.lblName setTextColor:[UIColor redColor]];
    }
    else {
        [self.lblName setText:name];
    }
}

- (void)displayGender {
    NSString *gender = [RTUserContext sharedInstance].currentUser.gender;
    if( gender.length == 0 ) {    //if gender is not specified
        [self.lblGender setText:NSLocalizedString(@"Profile_Error_No_Gender_Specified", nil)];
        [self.lblGender setTextColor:[UIColor redColor]];
    }
    else {
        [self.lblGender setText:[gender capitalizedString]];
    }
}

- (void)displayBirthday {
    NSString *birthday = [[RTUserContext sharedInstance].currentUser.birthday stringWithFormat:@"MM/dd/yyyy"];
    if( birthday.length == 0 ) {    //if birthday is not specified
        [self.lblBirthday setText:NSLocalizedString(@"Profile_Error_No_Birthday_Specified", nil)];
        [self.lblBirthday setTextColor:[UIColor redColor]];
    }
    else {
        [self.lblBirthday setText:birthday];
    }
}

- (void)displayMajor {
    NSString *major = [RTUserContext sharedInstance].currentUser.major;
    if( major.length == 0 ) {    //if major is not specified
        [self.lblMajor setText:NSLocalizedString(@"Profile_Error_No_Major_Specified", nil)];
        [self.lblMajor setTextColor:[UIColor redColor]];
    }
    else {
        [self.lblMajor setText:major];
    }
}

@end
