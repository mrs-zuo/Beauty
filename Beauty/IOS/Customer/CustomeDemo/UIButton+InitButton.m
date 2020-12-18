//
//  UIButton+InitButton.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-17.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UIButton+InitButton.h"

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

@end
