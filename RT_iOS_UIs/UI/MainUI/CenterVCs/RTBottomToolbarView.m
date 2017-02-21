//
//  RTBottomToolbarView.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/21/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTBottomToolbarView.h"
#import "RTBottomToolBarButton.h"

@interface RTBottomToolbarView()<RTBottomToolBarButtonDelegate>
@property (nonatomic) NSArray *items;
@property (nonatomic, weak) id<RTBottomViewDelegate> delegate;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSInteger selectedButtonIndex;
@end

@implementation RTBottomToolbarView

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items delegate:(id<RTBottomViewDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        _items = [NSArray arrayWithArray:items];
        _delegate = delegate;
        _buttons = [NSMutableArray array];

    }
    return self;
}

- (void)highlightButtonAtIndex:(NSInteger)index {
    for (RTBottomToolBarButton  *button in self.buttons) {
        if (button.tag == index) {
            [button selected];
            self.selectedButtonIndex = index;
        }else {
            [button deselected];
        }
    }
}

-(void)layoutSubviews {
    if (!self.buttons.count) {
        int index = 0;
        CGFloat buttonWidth = CGRectGetWidth(self.frame)/self.items.count;
        for (NSString *title in self.items) {
            CGRect frame = CGRectMake(buttonWidth * index, 0, buttonWidth, CGRectGetHeight(self.frame));
            RTBottomToolBarButton *button = [[RTBottomToolBarButton alloc]initWithFrame:frame title:title delegate:self];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonTapped:)];
            [button addGestureRecognizer:tap];
            button.tag = index;
            [self addSubview:button];
            [self.buttons addObject:button];
            index++;
        }
    }
    [self highlightButtonAtIndex:self.selectedButtonIndex];
}

- (void)buttonTapped:(UITapGestureRecognizer *)recognizer {
    NSInteger index = [(UIGestureRecognizer *)recognizer view].tag;
    [self.delegate userSelectedItemAtIndex:index];
    [self highlightButtonAtIndex:index];
}

#pragma mark public
- (void)setSelectedIndex:(NSInteger)index {
    self.selectedButtonIndex = index;
    [self setNeedsLayout];
}


@end
