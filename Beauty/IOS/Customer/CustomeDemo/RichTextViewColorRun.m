//
//  RichTextViewColorRun.m
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-17.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextViewColorRun.h"

@implementation RichTextViewColorRun

- (id)init
{
    self = [super init];
    if (self) {
        self.textRunType = richTextViewColorRun;
        self.isResponseTouchEvent = YES;
        self.textColor = [UIColor redColor];
    }
    return self;
}

+ (NSString *)analyzeText:(NSString *)originalString
                runsArray:(NSMutableArray **)runArray
andReplaceTextColorRunArray:(NSArray *)runReplaceTextColorArray
{
     NSMutableString *newString = [[NSMutableString alloc] initWithString:originalString];
    for (NSString* string in runReplaceTextColorArray) {
        NSRange range = [newString rangeOfString:string];
        RichTextViewColorRun *textColorRun = [[RichTextViewColorRun alloc]init];
        textColorRun.textRunRange = range;
        textColorRun.originalText = string;
        [*runArray addObject:textColorRun];
    }
    return newString;
}

//-- 替换基础文本
- (void)replaceTextWithAttributedString:(NSMutableAttributedString*) attributedString
{
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.textColor range:self.textRunRange];
    [super replaceTextWithAttributedString:attributedString];
}

- (BOOL)drawRunWithRect:(CGRect)rect
{
    return NO;
}
@end
