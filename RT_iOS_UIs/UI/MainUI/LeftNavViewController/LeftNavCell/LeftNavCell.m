#import "LeftNavCell.h"
#import "UIImage+Config.h"


@interface LeftNavCell ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation LeftNavCell

-(id)initWithReuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    if (self)
    {
        self.badgeView = [[UIImageView alloc] init];
        [self.badgeView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:_badgeView];
        
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 2;
        self.textLabel.font = REGFONT15;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectionColor;
    }
    
    return self;
}

-(void)configureCell:(NSString *)title image:(UIImage *)image whiteOpacity:(float)opacity
{
    self.textLabel.text = title;
    [self.textLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:opacity]];
    
    [_badgeView setImage:image];
    _badgeView.alpha = opacity;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _badgeView.frame = CGRectMake(40,
                                  7.5,
                                  30,
                                  30);
    
    self.textLabel.frame = CGRectMake(90,
                                      self.textLabel.frame.origin.y,
                                      self.textLabel.frame.size.width+30,
                                      self.textLabel.frame.size.height);
    
}

@end
