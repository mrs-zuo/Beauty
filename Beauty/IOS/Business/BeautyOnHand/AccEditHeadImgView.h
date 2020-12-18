//
//  AccEditHeadImgView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-10.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AccountEditViewController.h"
#import "GPImageEditorViewController.h"

@class AccountDoc;
@interface AccEditHeadImgView : UIView<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UIImageView *headImgView;
@property (strong, nonatomic) UITextField *phoneText;
@property (strong, nonatomic) UILabel *titlelabel;
@property (weak, nonatomic) AccountEditViewController *accountEditController;
- (void)updateData:(AccountDoc *)accountDoc;

- (UIImage *)getLocalImage;
- (NSString *)getImageType;
@end
