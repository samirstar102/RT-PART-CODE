//
//  RTBusinessActivityViewController.h
//  RoverTown
//
//  Created by Sonny on 10/31/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RTBusinessActivityViewControllerDelegate <NSObject>

@end

@interface RTBusinessActivityViewController : UIViewController

- (instancetype)initWithStore:(NSString *)store delegate:(id<RTBusinessActivityViewControllerDelegate>)delegate;

@end
