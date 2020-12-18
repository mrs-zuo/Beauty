//
//  UIPlaceHolderTextView+InitTextView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-13.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "UIPlaceHolderTextView+InitTextView.h"
#import "DEFINE.h"

@implementation UIPlaceHolderTextView (InitTextView)

+ (UIPlaceHolderTextView *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text placeHolder:(NSString *)placeText
{
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] initWithFrame:rect];
    [textView setFont:kFont_Light_16];
    [textView setTextColor:kColor_Editable];
    [textView setText:text];
    [textView setPlaceholder:placeText];
    [textView setPlaceholderColor:[UIColor grayColor]];
    [textView setAutoresizingMask:UIViewAutoresizingNone];
    [textView setTextAlignment:NSTextAlignmentLeft];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setShowsHorizontalScrollIndicator:NO];
    [textView setShowsVerticalScrollIndicator:NO];
    
    return textView;
}

@end
