//
//  PayDoc.m
//  test1
//
//  Created by macmini on 13-8-9.
//  Copyright (c) 2013年 macmini. All rights reserved.
//

#import "PayDoc.h"
#import "ContentEditCell.h"

@implementation PayDoc
- (id)init{
    self = [super init];
    if(self){
        _Pay_Remark = @"";
    }
    return self;
}

- (CGFloat)Pay_RemarkHeight
{
    ContentEditCell *cell = [[ContentEditCell alloc] init];
    cell.contentEditText.text = _Pay_Remark;
    CGFloat currentHeight = [cell.contentEditText sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    return currentHeight;
}

@end
