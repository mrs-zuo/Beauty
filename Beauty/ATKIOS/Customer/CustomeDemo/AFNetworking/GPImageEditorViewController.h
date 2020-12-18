//
//  GPImageEditorViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GPImageEditorViewControllerDelegate;

@class GPImageEditorView;
@interface GPImageEditorViewController : UIViewController
@property (strong, nonatomic) GPImageEditorView *imageEditorView;
@property (assign, nonatomic) id<GPImageEditorViewControllerDelegate> delegate;

@property (strong, nonatomic) UIImage *editImage;

@end

@protocol GPImageEditorViewControllerDelegate <NSObject>

- (void)imageEditorViewController:(GPImageEditorViewController *)vController didEditedImage:(UIImage *)image;

@end
