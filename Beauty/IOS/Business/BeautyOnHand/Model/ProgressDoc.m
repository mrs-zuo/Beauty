//
//  ProgressHistoryDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ProgressDoc.h"
#import "DEFINE.h"

@implementation ProgressDoc

- (id)init
{
    self = [super init];
    if (self) {
        [self setPrg_Describle:@""];
    }
    return self;
}

- (void)setPrg_Describle:(NSString *)prg_Describle
{
    _prg_Describle = prg_Describle;
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _prg_Describle;
    textView.font = kFont_Light_16;
    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_Prg_Describle = currentHeight;
    textView = nil;
    
}

@end
