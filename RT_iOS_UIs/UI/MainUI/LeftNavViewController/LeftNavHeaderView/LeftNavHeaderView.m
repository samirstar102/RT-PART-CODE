#import "LeftNavHeaderView.h"

@implementation LeftNavHeaderView



+(CGFloat)getPreferredHeightForWidth
{
    return 100.0f;
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor roverTownColor6DA6CE];
        _logoImgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 230.0f) / 2, (frame.size.height - 46.56) / 2, 230.0f, 46.56)];
        [_logoImgView setImage:[UIImage imageNamed:@"sidenav_logo.png"]];
        [self addSubview:_logoImgView];
        
        _btnEditProfile = [[UIButton alloc] initWithFrame:CGRectMake(25.0f, 25.0f, 247.0f, 50.0f)];
        [self addSubview:_btnEditProfile];
    }
    
    return self;
}

@end
