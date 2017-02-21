//
//  RTDiscountSearchView.m
//  RoverTown
//
//  Created by Sonny on 11/17/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTDiscountSearchView.h"
#import <QuartzCore/QuartzCore.h>

#define IS_IPHONE_4_OR_4S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5_OR_5S (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define kApiSearchViewPadding 8
#define kApiSearchViewItemHeight 46

@interface RTDiscountSearchView () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *searchTermTextField;
@property (weak, nonatomic) UIButton *optionsButton;
@property (weak, nonatomic) UIButton *searchButton;
@property (weak, nonatomic) UIView *totalSearchView;
@property (weak, nonatomic) UIView *topSearchView;
@property (strong, nonatomic) UIView *bottomSearchView;


@property (weak, nonatomic) UILabel *categoryLabel;
@property (weak, nonatomic) UIButton *categoryButton;

@property (weak, nonatomic) NSString *searchCategory;
@property (weak, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UITextField *locationTextField;
@property (weak, nonatomic) UIButton *applySearchParametersButton;
@property (nonatomic) BOOL isExpanded;

@property (nonatomic) NSString *locationString;
@property (nonatomic) NSString *categoryForSearch;

@end

@implementation RTDiscountSearchView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<RTDiscountSearchViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.isExpanded = NO;
        
        UIButton *options = [UIButton buttonWithType:UIButtonTypeCustom];
        [options addTarget:self action:@selector(optionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [options setBackgroundColor:[UIColor clearColor]];
        [options setTitle:@"Options" forState:UIControlStateNormal];
        [options setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        options.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        options.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.optionsButton = options;
        
        UIButton *search = [UIButton buttonWithType:UIButtonTypeCustom];
        [search addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [search setTitle:@"Close" forState:UIControlStateNormal];
        [search setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [search setBackgroundColor:[UIColor clearColor]];
        search.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.searchButton = search;
        
        UITextField *searchField = [[UITextField alloc] init];
        searchField.placeholder = @"Search for discounts...";
        searchField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        searchField.backgroundColor = [UIColor whiteColor];
        [searchField setReturnKeyType:UIReturnKeySearch];
        
        self.searchTermTextField = searchField;
        self.searchTermTextField.delegate = self;
        
        UIView *topView = [[UIView alloc] init];
        [topView setBackgroundColor:[UIColor clearColor]];
        self.topSearchView = topView;
        
        
        UITextField *locationField = [[UITextField alloc] init];
        locationField.placeholder = @"Denver, CO or 63110";
        locationField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        locationField.backgroundColor = [UIColor whiteColor];
        [locationField setReturnKeyType:UIReturnKeySearch];
        self.locationTextField = locationField;
        self.locationTextField.delegate = self;
        
        UILabel *locationLabel = [[UILabel alloc] init];
        locationLabel.text = @"City/ZIP";
        [locationLabel setAlpha:0.8f];
        locationLabel.textColor = [UIColor whiteColor];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        self.locationLabel = locationLabel;
        
        UILabel *categoryLabel = [[UILabel alloc] init];
        categoryLabel.text = @"All";
        [categoryLabel setAlpha:0.8f];
        categoryLabel.textColor = [UIColor whiteColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        self.categoryLabel = categoryLabel;
        
        UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [categoryButton setTitle:@"Category" forState:UIControlStateNormal];
        [categoryButton setImage:[UIImage imageNamed:@"picker_arrows"] forState:UIControlStateNormal];
        categoryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [categoryButton addTarget:self action:@selector(categoryTappedForSender:) forControlEvents:UIControlEventTouchUpInside];
        [categoryButton setBackgroundColor:[UIColor clearColor]];
        self.categoryButton = categoryButton;
        
        UIButton *searchApplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchApplyButton setBackgroundColor:[UIColor whiteColor]];
        [searchApplyButton setTitle:@"Search" forState:UIControlStateNormal];
        [searchApplyButton setTitleColor:[UIColor roverTownColorDarkBlue] forState:UIControlStateNormal];
        searchApplyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [searchApplyButton addTarget:self action:@selector(searchButtonTappedWithOptions:) forControlEvents:UIControlEventTouchUpInside];
        self.applySearchParametersButton = searchApplyButton;
        
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setBackgroundColor:[UIColor clearColor]];
        self.bottomSearchView = bottomView;
        [self.bottomSearchView addSubview:self.categoryLabel];
        [self.bottomSearchView addSubview:self.categoryButton];
        [self.bottomSearchView addSubview:self.locationLabel];
        [self.bottomSearchView addSubview:self.locationTextField];
        [self.bottomSearchView addSubview:self.applySearchParametersButton];
        
        UIView *wholeView = [[UIView alloc] init];
        [wholeView setBackgroundColor:[UIColor clearColor]];
        self.totalSearchView = wholeView;
        
        //[self.totalSearchView addSubview:self.bottomSearchView];
        [self addSubview:self.totalSearchView];
        [self.topSearchView addSubview:self.optionsButton];
        [self.topSearchView addSubview:self.searchButton];
        [self.topSearchView addSubview:self.searchTermTextField];
        [self.totalSearchView addSubview:self.topSearchView];
        [self.totalSearchView addSubview:self.topSearchView];
        [self.totalSearchView setAlpha:0.0f];
        
        [self.searchTermTextField becomeFirstResponder];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [self.totalSearchView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 4*kApiSearchViewItemHeight)];
    [self.topSearchView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kApiSearchViewItemHeight)];
    CGFloat buttonWidth = 75;
    CGFloat buttonHeight = kApiSearchViewItemHeight;
    [self.searchTermTextField setFrame:CGRectMake(8, kApiSearchViewPadding, CGRectGetWidth(self.frame) - 2*buttonWidth, kApiSearchViewItemHeight - 2 * kApiSearchViewPadding)];
    self.searchTermTextField.layer.sublayerTransform = CATransform3DMakeTranslation(6.0f, 1.0f, 0.0f);
    self.searchTermTextField.layer.cornerRadius = 5.0f;
    [self.searchButton setFrame:CGRectMake(CGRectGetMaxX(self.searchTermTextField.frame), 0, buttonWidth, buttonHeight)];
    [self.optionsButton setFrame:CGRectMake(CGRectGetMaxX(self.searchButton.frame), 0, buttonWidth, buttonHeight)];
    [self.topSearchView setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    
    [self.bottomSearchView setFrame:CGRectMake(0, kApiSearchViewItemHeight, CGRectGetWidth(self.frame), 3* kApiSearchViewItemHeight)];
    
    [self.categoryLabel sizeToFit];
    NSArray *objects = [[NSArray alloc] initWithObjects:self.categoryButton.titleLabel.textColor, [NSNumber numberWithInt:NSUnderlineStyleSingle], nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:NSForegroundColorAttributeName, NSUnderlineStyleAttributeName, nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.categoryButton.titleLabel.text attributes:linkAttributes];
    [self.categoryButton.titleLabel setAttributedText:attributedString];
    [self.categoryLabel setFrame:CGRectMake(CGRectGetWidth(self.frame)/4 - CGRectGetWidth(self.categoryLabel.frame)/2 , 0, CGRectGetWidth(self.categoryLabel.frame), kApiSearchViewItemHeight - 2*kApiSearchViewPadding)];
    [self.categoryButton setFrame:CGRectMake(kApiSearchViewPadding, kApiSearchViewItemHeight, CGRectGetWidth(self.frame)/2 - 2 *kApiSearchViewPadding, kApiSearchViewItemHeight - 2*kApiSearchViewPadding)];
    self.categoryButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.categoryButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.categoryButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [self.locationLabel sizeToFit];
    [self.locationLabel setFrame:CGRectMake(CGRectGetWidth(self.frame)/2 + kApiSearchViewPadding , 0, CGRectGetWidth(self.frame)/2 - 2 *kApiSearchViewPadding, kApiSearchViewItemHeight - 2*kApiSearchViewPadding)];
    [self.locationTextField setFrame:CGRectMake(CGRectGetWidth(self.frame)/2 + kApiSearchViewPadding, kApiSearchViewItemHeight, CGRectGetWidth(self.frame)/2 - 2 *kApiSearchViewPadding, kApiSearchViewItemHeight - 2*kApiSearchViewPadding)];
    [self.locationTextField textRectForBounds:CGRectMake(12, 1, self.locationTextField.frame.size.width, self.locationTextField.frame.size.height)];
    [self.locationTextField editingRectForBounds:CGRectMake(12, 1, self.locationTextField.frame.size.width, self.locationTextField.frame.size.height)];
    self.locationTextField.layer.sublayerTransform = CATransform3DMakeTranslation(6.0f, 1.0f, 0.0f);
    self.locationTextField.layer.cornerRadius = 5.0f;
    
    [self.applySearchParametersButton setFrame:CGRectMake(kApiSearchViewPadding, 2*kApiSearchViewItemHeight, CGRectGetWidth(self.frame) - 2*kApiSearchViewPadding, kApiSearchViewItemHeight - 2*kApiSearchViewPadding)];
    self.applySearchParametersButton.layer.cornerRadius = 5.0f;
    [self.bottomSearchView setBackgroundColor:[UIColor roverTownColorDarkBlue]];
    [self.totalSearchView setAlpha:1.0f];
}

-(void)searchViewExpandedForOptions {
    if (self.delegate !=nil) {
        [self.totalSearchView addSubview:self.bottomSearchView];
        [self.bottomSearchView setAlpha:1.0f];
        [self.optionsButton setTitle:@"Hide" forState:UIControlStateNormal];
        self.isExpanded = YES;
        [self.searchTermTextField becomeFirstResponder];
        [self.delegate viewWasExpandedForSearchView];
    }
}

- (void)searchViewCollapsedForOptions {
    if (self.delegate != nil) {
//        [self.bottomSearchView removeFromSuperview];
        [self.bottomSearchView setAlpha:0.0f];
        [self.optionsButton setTitle:@"Options" forState:UIControlStateNormal];
        self.isExpanded = NO;
        [self.delegate viewWasCollapsedForSearchView];
    }
}

- (void)collapseWhileSearching {
    if (self.delegate != nil) {
        [self.bottomSearchView setAlpha:0.0f];
        [self.optionsButton setTitle:@"Options" forState:UIControlStateNormal];
    }
}

-(IBAction)optionsButtonTapped:(id)sender {
    if (!self.isExpanded) {
        [self searchViewExpandedForOptions];
    } else {
        [self searchViewCollapsedForOptions];
    }
}

-(IBAction)searchButtonTapped:(id)sender {
    if (self.delegate != nil) {
        [self.delegate searchCancelled];
        [self resetCustomSearchParameters];
        self.searchTermTextField.text = @"";
    }
}

-(IBAction)searchButtonTappedWithOptions:(id)sender {
    if (self.delegate != nil) {
        if (!self.categoryForSearch) {
            [self searchCategorySelectedForCategory:@"All"];
            if ([self.locationTextField.text isEqualToString:@""]) {
                [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:@"All" location:@""];
            } else {
                [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:@"All" location:self.locationTextField.text];
            }
        } else {
            [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:self.categoryForSearch location:self.locationTextField.text];
        }
    }
}

-(IBAction)categoryTappedForSender:(id)sender {
    if (self.delegate != nil) {
        [self.delegate categoryButtonTapped];
    }
}

-(void)searchCategorySelectedForCategory:(NSString *)category {
    self.categoryForSearch = category;
    [self.categoryButton setTitle:category forState:UIControlStateNormal];
    NSArray *objects = [[NSArray alloc] initWithObjects:self.categoryButton.titleLabel.textColor, [NSNumber numberWithInt:NSUnderlineStyleSingle], nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:NSForegroundColorAttributeName, NSUnderlineStyleAttributeName, nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.categoryButton.titleLabel.text attributes:linkAttributes];
    [self.categoryButton.titleLabel setAttributedText:attributedString];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate != nil) {
        
        if (!self.categoryForSearch) {
            if ([self.locationTextField.text isEqualToString:@""]) {
                [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:@"All" location:@""];
            } else {
                [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:@"All" location:self.locationTextField.text];
            }
        } else
        {
            [self.delegate searchStartedWithTerm:self.searchTermTextField.text category:self.categoryForSearch location:self.locationTextField.text];
        }
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)resetCustomSearchParameters {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationTextField.text = @"";
        self.categoryForSearch = @"All";
    });
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.searchTermTextField) {
        [self.searchTermTextField becomeFirstResponder];
    } else {
        [self.locationTextField becomeFirstResponder];
    }
}

@end
