//
//  UITextField+InitLabel.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-16.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UITextField+InitLabel.h"
#import "DEFINE.h"
@implementation UITextField (InitLabel)

+ (UITextField *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text placeHolder:(NSString *)placeText
{
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setFont:kFont_Light_16];
    [textField setTextColor:kColor_Editable];
    [textField setText:text];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setPlaceholder:placeText];
    [textField setAutoresizingMask:UIViewAutoresizingNone];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setBackgroundColor:[UIColor clearColor]];
    
    return textField;
}

@end
