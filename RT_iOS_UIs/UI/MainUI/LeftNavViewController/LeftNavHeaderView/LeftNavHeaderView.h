@interface LeftNavHeaderView :  UIView

@property (nonatomic, strong) UIImageView *logoImgView;
@property (strong, nonatomic) UIButton *btnEditProfile;

+(CGFloat)getPreferredHeightForWidth;

@end
