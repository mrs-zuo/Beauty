//
//  ContractDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContactDoc.h"
#import "DEFINE.h"

@implementation ContactDoc

- (id)init
{
    self = [super init];
    if (self) {
        _cont_Schedule = [[ScheduleDoc alloc] init];
        self.cont_Remark = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ContactDoc *newContact = [[ContactDoc allocWithZone:zone] init];
    [newContact setCont_ID:_cont_ID];
    [newContact setCont_Remark:_cont_Remark];
    [newContact setCont_Schedule:_cont_Schedule];
    
    return newContact;
}

- (void)setCont_Remark:(NSString *)cont_Remark
{
    _cont_Remark = cont_Remark;
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _cont_Remark;
    textView.font = kFont_Light_16;
    CGFloat currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_cont_Remark = currentHeight;
    textView = nil;
}

@end
