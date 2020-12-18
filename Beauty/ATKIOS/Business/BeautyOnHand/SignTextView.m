//
//  SignTextView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-18.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "SignTextView.h"

@implementation SignTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)share
{
    static SignTextView *shareTextView = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareTextView = [[SignTextView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, MAXFLOAT)];
        shareTextView.font = kFont_Light_14;
        shareTextView.allowsEditingTextAttributes = YES;

    });
    return shareTextView;
}
@end
