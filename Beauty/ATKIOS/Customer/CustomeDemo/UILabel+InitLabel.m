//
//  UILabel+InitLabel.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-2.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation UILabel (InitLabel)

+ (UILabel *)initNormalLabelWithFrame:(CGRect)rect title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.frame = rect;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = kFont_Light_16;
    return label;
}
@end
