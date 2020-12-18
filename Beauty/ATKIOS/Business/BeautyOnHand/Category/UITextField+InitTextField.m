//
//  UITextField+InitTextField.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-16.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "UITextField+InitTextField.h"
#import "DEFINE.h"

@implementation UITextField (InitTextField)

+ (UITextField *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text placeHolder:(NSString *)placeText
{
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setFont:kFont_Light_16];
    [textField setTextColor:kColor_Editable];
    [textField setText:text];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [textField setPlaceholder:placeText];
    [textField setAutoresizingMask:UIViewAutoresizingNone];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setBackgroundColor:[UIColor clearColor]];
    
    return textField;
}

//- (void)drawPlaceholderInRect:(CGRect)rect
//{
//    [[UIColor grayColor] setFill];
//    [[self placeholder] drawInRect:rect withFont:kFont_Light_16];
//}

@end
