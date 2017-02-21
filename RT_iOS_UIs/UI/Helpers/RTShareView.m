//
//  RTShareView.m
//  RoverTown
//
//  Created by Roger Jones Jr on 9/13/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "RTShareView.h"
#import "RTUIManager.h"

@interface RTShareView ()
@property (weak, nonatomic) IBOutlet UIView *shareContainerView;
@property (weak, nonatomic) IBOutlet UIView *buttonsBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *shareTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@end

@implementation RTShareView

-(id)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"RTShareView" owner:self options:nil] lastObject];
        [RTUIManager applyBlurView:self.shareContainerView];
        self.cancelButton.layer.cornerRadius = 3.0f;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelTapped)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}
- (void)setTitleText:(NSString *)titleText {
    [self.shareTitleLabel setText:titleText];
}
- (IBAction)messageButtonTapped {
    [self.delegate message];
}
- (IBAction)mailButtonTapped {
    [self.delegate mail];
}
- (IBAction)twitterButtonTapped {
    [self.delegate twitter];
}
- (IBAction)facebookButtonTapped {
    [self.delegate facebook];
}
- (IBAction)cancelTapped {
    [self.delegate cancel];
}
@end
