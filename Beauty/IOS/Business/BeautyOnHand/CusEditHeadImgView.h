//
//  CustomerHeadImgView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-13.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "CustomerEditViewController.h"

@class CustomerDoc;
@interface CusEditHeadImgView : UIView<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate>//GPImageEditorViewControllerDelegate
@property (strong, nonatomic) UIImageView *headImgView;
@property (strong, nonatomic) UITextField *nameText;
@property (strong, nonatomic) UITextField *titleText;
@property (weak, nonatomic) CustomerEditViewController *customerEditController;

- (void)updateData:(CustomerDoc *)customerDoc;

- (void)dismissKeyboard;

- (UIImage *)getLocalImage;
- (NSString *)getImageType;
@end
