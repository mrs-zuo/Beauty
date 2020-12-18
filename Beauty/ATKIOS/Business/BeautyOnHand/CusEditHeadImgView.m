//
//  CustomerHeadImgView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-13.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CusEditHeadImgView.h"
#import "UIImageView+WebCache.h"
#import "UITextField+InitTextField.h"
#import "UILabel+InitLabel.h"
#import "CustomerDoc.h"
#import "DEFINE.h"
#import "UIImage+Compress.h"
#import "UIImage+fixOrientation.h"
#import "AppDelegate.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ORIGINAL_MAX_WIDTH 640.0f

@interface CusEditHeadImgView ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) CustomerDoc *theCustomerDoc;
@property (strong, nonatomic) UIImage *localImage;
@property (strong, nonatomic) NSString *localImagType;
@end

@implementation CusEditHeadImgView
@synthesize headImgView;
@synthesize nameText;
@synthesize titleText;
@synthesize customerEditController;
@synthesize theCustomerDoc;
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
        
        nameText = [UITextField initNormalTextViewWithFrame:CGRectMake(5.0f, 2.0f, 180.0f, 34.0f) text:@"" placeHolder:@"姓名"];
        nameText.tag = 98;
        nameText.delegate = self;
        [bgImageView addSubview:nameText];
        
        titleText = [UITextField initNormalTextViewWithFrame:CGRectMake(5.0f, 40.0f, 180.0f, 34.0f) text:@"" placeHolder:@"称呼"];
        titleText.tag = 99;
        titleText.delegate = self;
        [bgImageView addSubview:titleText];
    }
    return self;
}


- (void)updateData:(CustomerDoc *)customerDoc
{
    theCustomerDoc = customerDoc;
    [headImgView setImageWithURL:[NSURL URLWithString:customerDoc.cus_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    [nameText setText:customerDoc.cus_Name];
    [titleText setText:customerDoc.cus_Title];
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
    [titleText resignFirstResponder];
    [customerEditController dismissKeyBoard];
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    if ((IOS7 || IOS8)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else if (IOS6) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        localImage = editedImage;
        [headImgView setImage:localImage];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    if ((IOS7 || IOS8)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else if (IOS6) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [customerEditController presentViewController:controller
                                                 animated:YES
                                               completion:^(void){
                                                   NSLog(@"Picker View Controller is presented");
                                               }];
        }
        
    } else if (buttonIndex == 1) {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [customerEditController presentViewController:controller
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
//    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    portraitImg = [self imageByScalingToMaxSize:portraitImg];
//    // 裁剪
//    VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, customerEditController.view.frame.size.width, customerEditController.view.frame.size.width) limitScaleRatio:3.0];
//    imgEditorVC.delegate = self;
//    [picker pushViewController:imgEditorVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, customerEditController.view.frame.size.width, customerEditController.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        imgEditorVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [customerEditController presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

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
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
            cameraController.delegate = self;
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillEnterImagePickerControllerNotification object:nil];
            [customerEditController presentViewController:cameraController animated:YES completion:^{}];
        }
    }  else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.delegate = self;
            photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
             [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateWillEnterImagePickerControllerNotification object:nil];
            [customerEditController presentViewController:photoController animated:YES completion:^{}];
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
}*/

- (UIImage *)getLocalImage
{
    return localImage;
}

- (NSString *)getImageType
{
    return @".JPG";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setReturnKeyType:UIReturnKeyDone];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledTextEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    
//    switch (textField.tag) {
//        case 98: if ([textField.text length] >= 30)
//                    return NO;
//                else
//                    return YES;
//        case 99: if ([textField.text length] >= 20)
//                    return NO;
//                else
//                    return YES;
//        default: break;
//    }
    
    return YES;
}
-(void)textFiledTextEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString =  textField.text;
    int lenth = 30;
    if (textField.tag == 99) {
        lenth = 20;
    }

    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > lenth) {
                textField.text = [toBeString substringToIndex:lenth];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > lenth) {
            textField.text = [toBeString substringToIndex:lenth];
        }
    }
     
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
//    switch (textField.tag) {
//        case 98: [theCustomerDoc setCus_Name:textField.text];  break;
//        case 99: [theCustomerDoc setCus_Title:textField.text]; break;
//        default: break;
//    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)dismissKeyboard
{
    [nameText resignFirstResponder];
    [titleText resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
}

@end
