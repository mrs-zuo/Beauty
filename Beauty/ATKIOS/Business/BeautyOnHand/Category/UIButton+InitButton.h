//
//  UIButton+InitButton.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ButtonStyle){
    ButtonStyleBlue,
    ButtonStyleRed
};
@interface UIButton (InitButton)

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(UIImage *)image highlightedImage:(UIImage *)lightedImage;
+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font textAlignment:(NSTextAlignment)Alignment target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(UIImage *)image highlightedImage:(UIImage *)lightedImage;
+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame titleColor:(UIColor *)titleColor backgroudColor:(UIColor *)backgroudColor;
//圆角button
+ (UIButton *)buttonTypeRoundedRectWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame titleColor:(UIColor *)titleColor backgroudColor:(UIColor *)backgroudColor cornerRadius:(CGFloat)radius;

/**
 *扁平化Button
 */
+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector frame:(CGRect)frame backgroundImg:(ButtonStyle)style;
@end
