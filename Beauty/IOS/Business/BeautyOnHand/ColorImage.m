//
//  ColorImage.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/8/2.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ColorImage.h"

@implementation ColorImage

+ (UIImage *)blueBackgroudImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, KColor_Blue.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)redBackgroudImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, KColor_Red.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
