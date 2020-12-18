//
//  UIImage+MW.m
//  涂鸦
//
//  Created by Sino on 16/1/25.
//  Copyright (c) 2016年 夏明伟. All rights reserved.
//

#import "UIImage+MW.h"

@implementation UIImage (MW)

+(instancetype)captureWithView:(UIView *)view
{
    /**
     *  开启上下文
     */
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    
    /**
     *  将控制器的view的layer渲染到上下文
     */
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    /**
     *  取出图片
     */
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    /**
     *  结束上下文
     */
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
@end
