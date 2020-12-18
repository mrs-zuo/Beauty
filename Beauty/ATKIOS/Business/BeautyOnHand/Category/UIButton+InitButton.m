//
//  UIButton+InitButton.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UIButton+InitButton.h"
#import "ColorImage.h"  

@implementation UIButton (InitButton)

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(UIImage *)image highlightedImage:(UIImage *)lightedImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:lightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setAdjustsImageWhenDisabled:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setShowsTouchWhenHighlighted:NO];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

+ (UIImage *)blueBackgroudImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    CGContextSetFillColorWithColor(ctx, KColor_Blue.CGColor);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font textAlignment:(NSTextAlignment)Alignment target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(UIImage *)image highlightedImage:(UIImage *)lightedImage
{
   UIButton *button = [self buttonWithTitle:title target:target selector:selector frame:frame backgroundImg:image highlightedImage:lightedImage];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.titleLabel.textAlignment = Alignment;
    
    return button;
    
}
+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame titleColor:(UIColor *)titleColor backgroudColor:(UIColor *)backgroudColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[titleColor colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [button setBackgroundColor:backgroudColor];
    [button setAdjustsImageWhenDisabled:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setShowsTouchWhenHighlighted:NO];

    return button;
}
//圆角button
+ (UIButton *)buttonTypeRoundedRectWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame titleColor:(UIColor *)titleColor backgroudColor:(UIColor *)backgroudColor cornerRadius:(CGFloat)radius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateHighlighted];
    button.layer.cornerRadius = radius ;
    
    [button setBackgroundColor:backgroudColor];
    [button setAdjustsImageWhenDisabled:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setShowsTouchWhenHighlighted:NO];
    
    return button;
}

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(ButtonStyle)style
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
    if (style == ButtonStyleRed ) {
        [button setBackgroundImage:[ColorImage redBackgroudImage] forState:UIControlStateNormal];
    }

    [button setAdjustsImageWhenDisabled:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setShowsTouchWhenHighlighted:NO];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.0f;
    
    return button;
}
     
@end
