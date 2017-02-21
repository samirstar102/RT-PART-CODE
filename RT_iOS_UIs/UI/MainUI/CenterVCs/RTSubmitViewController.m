//
//  RTSubmitViewController.m
//  RoverTown
//
//  Created by Roger Jones Jr. on 10/24/15.
//  Copyright © 2015 rovertown.com. All rights reserved.
//

#import "RTSubmitViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "RTStoryboardManager.h"
#import "SubmitDiscountVC.h"
#import "RTSubmitView.h"
#import "RTSubmitModel.h"
#import "RTUserContext.h"
#import "UIViewController+MMDrawerController.h"


@interface RTSubmitViewController ()<RTSubmitViewObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RTSubmitModelDelegate>
@property (nonatomic) RTSubmitView *submitView;
@property (nonatomic) RTSubmitModel *model;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) BOOL imageViewIsUp;
@property (nonatomic) BOOL viewSlidedUp;
@end

@implementation RTSubmitViewController

- (instancetype)init {
    if (self = [super init]) {
        self.imageViewIsUp = YES;
        _model = [[RTSubmitModel alloc]initWithDelegate:self];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _submitView = [[RTSubmitView alloc]initWithFrame:self.view.frame observer:self];
    [self.view addSubview:_submitView]; 
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - RTSubmitViewDelegate

- (void)sendTappedWithImage:(UIImage *)image businessName:(NSString *)name businessAddress:(NSString *)address discount:(NSString *)discount finePrint:(NSString *)finePrint option:(NSString *)option {
    [self.model submitDiscountWithImage:image businessName:name businessAddress:address discount:discount finePrint:finePrint referralSubject:option];
}

- (void)imageViewTapped {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) { // authorized
        [self showImagePicker];
    }
    else if(status == AVAuthorizationStatusDenied){ // denied
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Camera Not Available" message:@"You have not granted us camera access" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag=103;
        [alert show];
    }
    else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                [self showImagePicker];
            } else {

            }
        }];
    }

}

-(void)showImagePicker {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerCamera =[[UIImagePickerController alloc] init];
        imagePickerCamera.delegate = self;
        imagePickerCamera.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePickerCamera.allowsEditing = YES;
        imagePickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerCamera  animated:YES completion:nil];
    }
    
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePickerAlbum =[[UIImagePickerController alloc] init];
        imagePickerAlbum.delegate = self;
        imagePickerAlbum.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePickerAlbum.allowsEditing = YES;
        imagePickerAlbum.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePickerAlbum animated:YES completion:nil];
    }

}

- (void)additionalsStarted {
    self.mm_drawerController.shouldUsePanGesture = NO;
}

- (void)additionalsEnded {
    self.mm_drawerController.shouldUsePanGesture = YES;
}

-(void)keyboardOnScreen:(NSNotification *)notification {
    if (self.imageViewIsUp && !self.viewSlidedUp) {
        NSDictionary *info = notification.userInfo;
        NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
        
        CGRect rawFrame = [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        int movementDistance = -1 * (keyboardFrame.size.height - 15);
        float movementDuration = 0.2f;
        [UIView beginAnimations:@"animteTextField" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
        [UIView commitAnimations];
        self.viewSlidedUp = YES;
    }
}

-(void)keyboardOffScreen:(NSNotification *)notification {
    if (self.imageViewIsUp && self.viewSlidedUp) {
        NSDictionary *info = notification.userInfo;
        NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
        
        CGRect rawFrame = [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        int movementDistance = (keyboardFrame.size.height - 15);
        float movementDuration = 0.2f;
        [UIView beginAnimations:@"animteTextField" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movementDistance);
        [UIView commitAnimations];
        self.viewSlidedUp = NO;
    }
}

- (void) imageViewIsShowing {
    self.imageViewIsUp = YES;
}

- (void) imageViewIsNotShowing {
    self.imageViewIsUp = NO;
}

#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* selectedImage = nil;
    selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(selectedImage == nil)
    {
        selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(selectedImage == nil)
    {
        selectedImage = [info objectForKey:UIImagePickerControllerCropRect];
    }
    [self.submitView showSelectedImage:selectedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.submitView removeFromSuperview];
    [self viewDidLoad];
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}
#pragma mark - RTSubmitModelDelegate 
- (void) submitSuccessful {
    [self.submitView showSuccess];
    [self.submitView setContentOffset:CGPointMake(0, -self.submitView.contentInset.top) animated:YES];
}

- (void)submitFailed {
    [self.submitView showFail];
}

- (void)submitLimitReached {
    [[RTUIManager sharedInstance] showToastMessageWithViewController:self labelText:@"You have hit the limit for number of submissions in an hour." descriptionText:@"Try again later."];
}

- (void)boneCountUpdated:(BOOL)boneDiff badgeCountUpdated:(BOOL)badgeDiff {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(boneDiff && badgeDiff) {
            [self playBoneAnimationWithComplettion:^{
                [self updaeBoneCount];
                [self playBoneAnimationWithComplettion:^{
                    [self badgeCompletion];
                }];
            }];
        }else if(boneDiff) {
            [self playBoneAnimationWithComplettion:^{
                [self boneCompletion];
            }];
        }
        else if (badgeDiff) {
            [self playBadgeAnimationWithCompletion:^{
                [self badgeCompletion];
            }];
        }
    });
}
- (void)playBoneAnimationWithComplettion:(dispatch_block_t)completeBlock {
    [RTUIManager playEarnBoneAnimationWithSuperview:self.navigationController.view completeBlock:^{
        if (completeBlock) {
            completeBlock();
        }
    }];
    
}

- (void)updaeBoneCount {
    [self setNumberOfBonesWithNumber:[RTUserContext sharedInstance].boneCount];
    [self setUpNavBar];
}

- (void)boneCompletion {
    [self updaeBoneCount];
    if (self.delegate != nil) {
        [self.delegate updateBonesFromSubmit];
    }
}

- (void)playBadgeAnimationWithCompletion:(dispatch_block_t)completeBlock {
    [RTUIManager playEarnBadgeAnimationWithSuperview:self.navigationController.view completeBlock:^{
        if (completeBlock) {
            completeBlock();
        }
    }];
    
}

- (void)badgeCompletion {
    [self setNumberOfBadgesWithNumber:[RTUserContext sharedInstance].badgeTotalCount];
}
@end
