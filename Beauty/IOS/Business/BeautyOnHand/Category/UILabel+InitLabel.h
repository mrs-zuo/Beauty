//
//  UILabel+InitLabel.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-2.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"

@interface UILabel (InitLabel)
+ (MLEmojiLabel *)initMLEmoLabelWithFrame:(CGRect)rect title:(NSString *)title;

+ (UILabel *)initNormalLabelWithFrame:(CGRect)rect title:(NSString *)title;
+ (UILabel *)initNormalLabelWithFrame:(CGRect)rect title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color;
@end
