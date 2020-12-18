//
//  GPImageEditorView.h
//  GPImageEditorView.m
//
//  Created by TRY-MAC01 on 13-10-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GPImageEditorViewController;
@interface GPImageEditorView : UIView

@property (weak, nonatomic) GPImageEditorViewController *viewController;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGSize maxSize;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, readonly) UIImage *output;

- (id)initWithImage:(UIImage *)theImage;

@end
