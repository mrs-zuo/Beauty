//
//  UILabel+InitLabel.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-2.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation UILabel (InitLabel)
+ (MLEmojiLabel *)initMLEmoLabelWithFrame:(CGRect)rect title:(NSString *)title

{
    MLEmojiLabel *label = [[MLEmojiLabel alloc] init];
    label.frame = rect;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.autoresizingMask = UIViewAutoresizingNone;
    label.font = kFont_Light_16;
    return label;
}
+ (UILabel *)initNormalLabelWithFrame:(CGRect)rect title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = rect;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.autoresizingMask = UIViewAutoresizingNone;
    label.font = kFont_Light_16;
    return label;
}

+ (UILabel *)initNormalLabelWithFrame:(CGRect)rect title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = rect;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.autoresizingMask = UIViewAutoresizingNone;
    label.font = font;
    label.textColor = color;
    return label;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
@end
