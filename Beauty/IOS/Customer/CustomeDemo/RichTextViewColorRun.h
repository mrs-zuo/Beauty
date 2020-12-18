//
//  RichTextViewColorRun.h
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-17.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextViewBaseRun.h"

@interface RichTextViewColorRun : RichTextViewBaseRun

@property (nonatomic,strong) UIColor *textColor;
+ (NSString *)analyzeText:(NSString *)originalString runsArray:(NSMutableArray **)runArray andReplaceTextColorRunArray:(NSArray *)runReplaceTextColorArray;
@end
