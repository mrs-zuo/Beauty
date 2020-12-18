//
//  AccEditHeadImgView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "AccEditHeadImgView.h"
#import "UIImageView+WebCache.h"
#import "UITextField+InitTextField.h"
#import "UILabel+InitLabel.h"
#import "AccountDoc.h"
#import "DEFINE.h"
#import "AppDelegate.h"
#import "UIImage+Compress.h"
#import "UIImage+fixOrientation.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ORIGINAL_MAX_WIDTH 640.0f

@interface AccEditHeadImgView ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
@property (strong, nonatomic) UIImageView *bgImageView;

@property (strong, nonatomic) AccountDoc *theAccountDoc;
@property (strong, nonatomic) UIImage *localImage;
@property (strong, nonatomic) NSString *localImagType;
@end

@implementation AccEditHeadImgView
@synthesize headImgView;
@synthesize phoneText;
@synthesize titlelabel;
@synthesize accountEditController;
@synthesize theAccountDoc;
@synthesize localImage;
@synthesize localImagType;
@synthesize bgImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        headImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_HeadImg80"]];
        headImgView.frame = CGRectMake(20.0f, 10.0f, 80.0f, 80.0F);
        headImgView.layer.masksToBounds = YES;
        headImgView.layer.cornerRadius = 5.0f;
        headImgView.layer.borderWidth = 0.5f;
        headImgView.layer.borderColor = [kTableView_LineColor CGColor];
        headImgView.userInteractionEnabled = YES;
        [self addSubview:headImgView];
        
        UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 60.0f, 80.0f, 20.0f)];
        promptLabel.backgroundColor = [UIColor blackColor];
        promptLabel.textAlignment = NSTextAlignmentCenter;
        promptLabel.font = kFont_Light_12;
        promptLabel.alpha = 0.3;
        promptLabel.textColor = [UIColor whiteColor];
        promptLabel.text = @"更换头像";
        [headImgView addSubview:promptLabel];
        
        UITapGestureRecognizer *tapGestureRecogizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
        [headImgView addGestureRecognizer:tapGestureRecogizer];
        
        bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customer_Text_bg"]];
        bgImageView.frame = CGRectMake(110.0f, 10.0f, 194.0f, 75.0f);
        bgImageView.userInteractionEnabled = YES;
        [self addSubview:bgImageView];
        
        titlelabel = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 2.0f, 180.0f, 34.0f) title:@"请输入新账号"];
        titlelabel.tag = 98;
        [bgImageView addSubview:titlelabel];
        
        phoneText = [UITextField initNormalTextViewWithFrame:CGRectMake(5.0f, 40.0f, 180.0f, 34.0f) text:@"" placeHolder:@"账号"];
        phoneText.tag = 99;
        phoneText.delegate = self;
        [bgImageView addSubview:phoneText];
    }
    return self;
}


- (void)updateData:(AccountDoc *)accountDoc
{
    theAccountDoc = accountDoc;
    [headImgView setImageWithURL:[NSURL URLWithString:accountDoc.cos_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    [phoneText setText:accountDoc.cos_Mobile];
}

- (void)changeImage
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)done:(id)sender
{
    [phoneText resignFirstResponder];
    [accountEditController dismissKeyBoard];
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        localImage = editedImage;
        [headImgView setImage:localImage];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            [accountEditController presentViewController:controller
                                                 animated:YES
                                               completion:^(void){
                                                   NSLog(@"Picker View Controller is presented");
                                               }];
        }
        
    } else if (buttonIndex == 1) {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            [accountEditController presentViewController:controller
                                                 animated:YES
                                               completion:^(void){
                                                   NSLog(@"Picker View Controller is presented");
                                               }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, accountEditController.view.frame.size.width, accountEditController.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        imgEditorVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [accountEditController presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - camera utility

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickVideosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - image scale utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

/*
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
            cameraController.delegate = self;
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillEnterImagePickerControllerNotification object:nil];
            [accountEditController presentViewController:cameraController animated:YES completion:^{}];
        }
    }  else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.delegate = self;
            photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillEnterImagePickerControllerNotification object:nil];
            [accountEditController presentViewController:photoController animated:YES completion:^{}];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                NSString *fileName = [asset.defaultRepresentation filename];
                NSString *fileType = [[fileName componentsSeparatedByString:@"."] objectAtIndex:1];
                localImagType = [NSString stringWithFormat:@".%@", fileType];
            } failureBlock:^(NSError *error) {
                DLOG(@"Error:%@  Address:%s", error.description, __FUNCTION__);
            }];
        } else {
            localImagType = @".JPG";
        }
        
        GPImageEditorViewController *imageEditorVewController = [[GPImageEditorViewController alloc] init];
        imageEditorVewController.editImage = originImage;
        imageEditorVewController.delegate = self;
        [picker pushViewController:imageEditorVewController animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - GPImageEditorViewControllerDelegate

- (void)imageEditorViewController:(GPImageEditorViewController *)vController didEditedImage:(UIImage *)image
{
    UIImage *pressImg = [image scaleToSize:kImage_CompressSize];
    
    localImage =  [pressImg fixOrientation];
    [headImgView setImage:localImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
}

- (void)saveImage:(UIImage *)image
{
    [headImgView setImage:image];
    localImage = image;
}*/

- (UIImage *)getLocalImage
{
    return localImage;
}

- (NSString *)getImageType
{
    return localImagType;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    switch (textField.tag) {
        case 98: if ([textField.text length] > 30)  return NO;
        case 99: if ([textField.text length] > 20)  return NO;
        default: break;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 99: [theAccountDoc setCos_Mobile:textField.text]; break;
        default: break;
    }
    return YES;
}


@end
