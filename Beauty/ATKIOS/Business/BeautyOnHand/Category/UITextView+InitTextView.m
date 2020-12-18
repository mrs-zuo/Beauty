//
//  UITextView+InitTextView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "UITextView+InitTextView.h"
#import "DEFINE.h"

@implementation UITextView (InitTextView)

+ (UITextView *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text
{
    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    [textView setFont:kFont_Light_16];
    [textView setTextColor:kColor_Editable];
    [textView setText:text];
    [textView setAutoresizingMask:UIViewAutoresizingNone];
    [textView setTextAlignment:NSTextAlignmentLeft];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setShowsHorizontalScrollIndicator:NO];
    [textView setShowsVerticalScrollIndicator:NO];
    
    return textView;
}


@end
