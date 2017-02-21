//
//  CustomRefreshControl.m
//  RoverTown
//
//  Created by Robin Denis on 22/05/15.
//  Copyright (c) 2015 rovertown.com. All rights reserved.
//

#import "CustomRefreshControl.h"

#define REFRESH_CONTROL_HEIGHT 65.0f
#define HALF_REFRESH_CONTROL_HEIGHT (REFRESH_CONTROL_HEIGHT / 2.0f)

#define DEFAULT_FOREGROUND_COLOR [UIColor whiteColor]
#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithWhite:0.10f alpha:1.0f]

#define DEFAULT_TOTAL_HORIZONTAL_TRAVEL_TIME_FOR_BALL 0.75f

#define TRANSITION_ANIMATION_DURATION 0.2f

typedef enum {
    CustomRefreshControlStateIdle = 0,
    CustomRefreshControlStateRefreshing = 1,
    CustomRefreshControlStateResetting = 2
} CustomRefreshControlState;

@interface CustomRefreshControl () {
    CustomRefreshControlState state;
    
    CGFloat originalTopContentInset;
    UIView* gameView;

    UIImageView* imageView;
}

@property (assign, nonatomic) UIScrollView* scrollView;
@property (assign, nonatomic) id refreshTarget;
@property (nonatomic) SEL refreshAction;
@property (nonatomic, readonly) CGFloat distanceScrolled;

@property (nonatomic) BOOL animating;

@end

@implementation CustomRefreshControl

#pragma mark - Attaching a pong refresh control to a UIScrollView or UITableView

#pragma mark UITableView

+ (CustomRefreshControl *)attachToTableView:(UITableView*)tableView
                          withRefreshTarget:(id)refreshTarget
                           andRefreshAction:(SEL)refreshAction {
    return [self attachToScrollView:tableView
              withRefreshTarget:refreshTarget
               andRefreshAction:refreshAction];
}

#pragma mark UIScrollView

+ (CustomRefreshControl *)attachToScrollView:(UIScrollView*)scrollView
                           withRefreshTarget:(id)refreshTarget
                            andRefreshAction:(SEL)refreshAction
{
    CustomRefreshControl* existingPongRefreshControl = [self findCustomRefreshControlInScrollView:scrollView];
    if(existingPongRefreshControl != nil) {
        return existingPongRefreshControl;
    }
    
    //Initialized height to 0 to hide it
    CustomRefreshControl* customRefreshControl = [[CustomRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, scrollView.frame.size.width, 0.0f)
                                                                               andScrollView:scrollView
                                                                            andRefreshTarget:refreshTarget
                                                                            andRefreshAction:refreshAction];
    
    [scrollView addSubview:customRefreshControl];
    
    return customRefreshControl;
}


+ (CustomRefreshControl *)findCustomRefreshControlInScrollView:(UIScrollView*)scrollView
{
    for (UIView* subview in scrollView.subviews) {
        if ([subview isKindOfClass:[CustomRefreshControl class]]) {
            return (CustomRefreshControl *)subview;
        }
    }
    
    return nil;
}

#pragma mark - Initializing a new pong refresh control

- (id)initWithFrame:(CGRect)frame
      andScrollView:(UIScrollView*)scrollView
   andRefreshTarget:(id)refreshTarget
   andRefreshAction:(SEL)refreshAction
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        self.scrollView = scrollView;
        self.refreshTarget = refreshTarget;
        self.refreshAction = refreshAction;
        
        originalTopContentInset = scrollView.contentInset.top;
        
        [self setUpGameView];
        [self setUpImageView];
        
        state = CustomRefreshControlStateIdle;
        
        self.foregroundColor = DEFAULT_FOREGROUND_COLOR;
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(handleOrientationChange)
//                                                     name:UIDeviceOrientationDidChangeNotification
//                                                   object:nil];
        
    }
    return self;
}

- (void)setUpGameView
{
    gameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, REFRESH_CONTROL_HEIGHT)];
    gameView.backgroundColor = [UIColor clearColor];
    [self addSubview:gameView];
}

- (void)setUpImageView
{
    CGFloat imageViewHeight = gameView.frame.size.height * 0.5;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake((gameView.frame.size.width - imageViewHeight) / 2, 4, imageViewHeight, imageViewHeight)];
    imageView.image = [UIImage imageNamed:@"refresh"];
    
    [gameView addSubview:imageView];
}

#pragma mark - Handling various configuration changes

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

- (void)setForegroundColor:(UIColor*)foregroundColor
{
    _foregroundColor = foregroundColor;
}

#pragma mark - Listening to scroll delegate events

#pragma mark Actively scrolling

- (void)scrollViewDidScroll
{
    CGFloat rawOffset = -self.distanceScrolled;
    
    [self offsetGameViewBy:rawOffset];
    
    if(state == CustomRefreshControlStateIdle) {
        CGFloat ballAndPaddlesOffset = MIN(rawOffset / 2.0f, HALF_REFRESH_CONTROL_HEIGHT);
        
        //[self offsetBallAndPaddlesBy:ballAndPaddlesOffset];
        [self rotatePaddlesAccordingToOffset:ballAndPaddlesOffset];
        [self setAlphaPaddlesAccordingToOffset:ballAndPaddlesOffset];
    }
}

- (CGFloat)distanceScrolled
{
    return (self.scrollView.contentOffset.y + self.scrollView.contentInset.top);
}

- (void)offsetGameViewBy:(CGFloat)offset
{
    CGFloat offsetConsideringState = offset;
    if(state != CustomRefreshControlStateIdle) {
        offsetConsideringState += REFRESH_CONTROL_HEIGHT;
    }
    
    [self setHeightAndOffsetOfRefreshControl:offsetConsideringState];
    [self stickGameViewToCenterOfRefreshControl];
}

- (void)setHeightAndOffsetOfRefreshControl:(CGFloat)offset
{
    CGRect newFrame = self.frame;
    newFrame.size.height = offset;
    newFrame.origin.y = -offset;
    self.frame = newFrame;
}

- (void)stickGameViewToCenterOfRefreshControl
{
    CGRect newGameViewFrame = gameView.frame;
    newGameViewFrame.origin.y = (self.frame.size.height - gameView.frame.size.height) / 2;
    gameView.frame = newGameViewFrame;
}

- (void)rotatePaddlesAccordingToOffset:(CGFloat)offset
{
    CGFloat proportionOfMaxOffset = (offset / HALF_REFRESH_CONTROL_HEIGHT);
    CGFloat angleToRotate = 2 * M_PI * proportionOfMaxOffset;
    
    imageView.transform = CGAffineTransformMakeRotation(angleToRotate);
}

- (void)setAlphaPaddlesAccordingToOffset:(CGFloat)offset
{
    CGFloat alpha = (offset / HALF_REFRESH_CONTROL_HEIGHT);
    imageView.alpha = alpha;
}

#pragma mark Letting go of the scroll view, checking for refresh trigger

- (void)scrollViewDidEndDragging
{
    if(state == CustomRefreshControlStateIdle) {
        if([self didUserScrollFarEnoughToTriggerRefresh]) {
            [self beginLoading];
            [self notifyTargetOfRefreshTrigger];
        }
    }
}

- (BOOL)didUserScrollFarEnoughToTriggerRefresh
{
    return (-self.distanceScrolled > REFRESH_CONTROL_HEIGHT);
}

- (void)notifyTargetOfRefreshTrigger
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if ([self.refreshTarget respondsToSelector:self.refreshAction])
        [self.refreshTarget performSelector:self.refreshAction];
    
#pragma clang diagnostic pop
}

#pragma mark - Manually starting a refresh

- (void)beginLoading
{
    [self beginLoadingAnimated:YES];
}

- (void)beginLoadingAnimated:(BOOL)animated
{
    if (state != CustomRefreshControlStateRefreshing) {
        state = CustomRefreshControlStateRefreshing;
        
        [self scrollRefreshControlToVisibleAnimated:animated];
        [self startRefreshing];
    }
}

- (void)scrollRefreshControlToVisibleAnimated:(BOOL)animated
{
    CGFloat animationDuration = 0.0f;
    if(animated) {
        animationDuration = TRANSITION_ANIMATION_DURATION;
    }
    
    
    UIEdgeInsets newInsets = self.scrollView.contentInset;
    newInsets.top = originalTopContentInset + REFRESH_CONTROL_HEIGHT;
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        self.scrollView.contentInset = newInsets;
        self.scrollView.contentOffset = contentOffset;
    }];
}

#pragma mark - Resetting after loading finished

- (void)finishedLoading
{
    if(state != CustomRefreshControlStateRefreshing) {
        return;
    }
    
    state = CustomRefreshControlStateResetting;
    
    [UIView animateWithDuration:TRANSITION_ANIMATION_DURATION animations:^(void)
     {
         [self resetScrollViewContentInsets];
         [self setHeightAndOffsetOfRefreshControl:0.0f];
     }
                     completion:^(BOOL finished)
     {
         [self resetPaddlesAndBall];
         state = CustomRefreshControlStateIdle;
     }];
}

- (void)resetScrollViewContentInsets
{
    UIEdgeInsets newInsets = self.scrollView.contentInset;
    newInsets.top = originalTopContentInset;
    self.scrollView.contentInset = newInsets;
}

- (void)resetPaddlesAndBall
{
    [self removeAnimations];
    
    //leftPaddleView.center = leftPaddleIdleOrigin;
    //rightPaddleView.center = rightPaddleIdleOrigin;
    //ballView.center = ballIdleOrigin;
}

- (void)removeAnimations
{
    [self stopRefreshAnimate];
}

#pragma mark - Playing refreshing

#pragma mark Starting the game

- (void)startRefreshing
{
    
    [self startRefreshAnimate];
}

- (void)startRefreshAnimate {
    if (!self.animating) {
        self.animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void)stopRefreshAnimate {
    if (self.animating) {
        self.animating = NO;
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 1 seconds
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         imageView.transform = CGAffineTransformRotate(imageView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

#pragma mark Playing the game


#pragma mark - Handling orientation changes

- (void)handleOrientationChange {
//    self.frame = CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, 0.0f);
//    CGFloat gameViewWidthBeforeOrientationChange = gameView.frame.size.width;
//    gameView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, REFRESH_CONTROL_HEIGHT);
//    
//    originalTopContentInset = self.scrollView.contentInset.top;
//    
//    [self setUpGamePieceIdleOrigins];
//    
//    if(state == BOZPongRefreshControlStateRefreshing) {
//        originalTopContentInset -= REFRESH_CONTROL_HEIGHT;
//        [self setHeightAndOffsetOfRefreshControl:REFRESH_CONTROL_HEIGHT];
//        
//        [self removeAnimations];
//        CGFloat horizontalScaleFactor = gameView.frame.size.width / gameViewWidthBeforeOrientationChange;
//        [self setGamePiecePositionsForAnimationStop:horizontalScaleFactor];
//        
//        [self animateBallAndPaddlesToDestinations];
//    } else {
//        [self setGamePiecePositionsToIdle];
//    }
}


@end
