//
//  PictureDisplayView.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPImageEditorViewController.h"

@protocol PictureDisplayViewDelegate;
@class EffectImgEditViewController;
@class PictureDisplayView;

@interface GPScrollView : UIScrollView
@property (weak, nonatomic) PictureDisplayView *bindPictureDisplayView;
@end


@interface PictureDisplayView : UIView <UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GPImageEditorViewControllerDelegate>
@property (weak, nonatomic) id imgEditViewController;
@property (weak, nonatomic) id<PictureDisplayViewDelegate> delegate;
@property (strong, nonatomic) GPScrollView *picScrollView;
@property (assign, nonatomic) BOOL isEditing;

- (id)initWithFrame:(CGRect)frame picSize:(CGSize)size spacing:(CGFloat)space;
- (void)setPicturesWithURLs:(NSArray *)array;  

- (NSArray *)getDeleteImageURLsArray;
- (NSArray *)getUploadImagesAndTypes;

- (void)scrollToNextPicture;
- (void)scrollToPreviouPicture;

- (void)bindWithOtherPictureDisplayView:(PictureDisplayView *)otherPictureDisplayView;

@end

@protocol PictureDisplayViewDelegate <NSObject>
- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost;

- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView selectedView:(UIImageView *)selectedView;

@end
