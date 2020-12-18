//
//  UIImage+Compress.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-26.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end
