//
//  UITextView+InitTextView.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "UITextView+Additional.h"
#import "DEFINE.h"

@implementation UITextView (Additional)

+ (UITextView *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text
{
    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    [textView setFont:kFont_Light_16];
    [textView setText:text];
    [textView setAutoresizingMask:UIViewAutoresizingNone];
    [textView setTextAlignment:NSTextAlignmentLeft];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setShowsHorizontalScrollIndicator:NO];
    [textView setShowsVerticalScrollIndicator:NO];
    
    return textView;
}


@end
