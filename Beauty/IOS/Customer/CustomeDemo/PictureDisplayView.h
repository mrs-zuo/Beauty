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

@protocol PictureDisplayViewDelegate;

@interface PictureDisplayView : UIView <UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) id imgEditViewController;
@property (weak, nonatomic) id<PictureDisplayViewDelegate> delegate;
@property (strong, nonatomic) UIScrollView *picScrollView;
@property (assign, nonatomic) BOOL isEditing;

- (id)initWithFrame:(CGRect)frame picSize:(CGSize)size spacing:(CGFloat)space;
- (void)setPicturesWithURLs:(NSArray *)array;  

- (NSArray *)getDeleteImageURLsArray;
- (NSArray *)getUploadImagesAndTypes;

- (void)scrollToNextPicture;
- (void)scrollToPreviouPicture;
@end

@protocol PictureDisplayViewDelegate <NSObject>
- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost;
@end
