//
//  RichTextViewBaseRun.m
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextViewBaseRun.h"

@implementation RichTextViewBaseRun


-(id)init{
    self = [super init];
    if (self) {
        self.isResponseTouchEvent = YES;
    }
    return self;
}

-(void)replaceTextWithAttributedString:(NSMutableAttributedString *)string
{
    [string addAttribute:@"RichTextAttributed" value:self range:self.textRunRange];
}

-(BOOL)drawRunWithRect:(CGRect)rect
{
    return NO;
}
@end
