
@interface LeftNavCell : UITableViewCell

-(id)initWithReuseIdentifier:(NSString *)identifier;
-(void)configureCell:(NSString *)title image:(UIImage *)image whiteOpacity:(float)opacity;

@end
