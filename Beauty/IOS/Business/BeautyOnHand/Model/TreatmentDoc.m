//
//  TreatmentDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentDoc.h"
#import "DEFINE.h"


@implementation TreatmentGroup








@end




@implementation TreatmentDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.treat_Schedule = [[ScheduleDoc alloc] init];
        self.treat_Remark = [[NSString alloc] init];;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TreatmentDoc *newTreatment = [[TreatmentDoc allocWithZone:zone] init];
    [newTreatment setTreat_ID:_treat_ID];
    [newTreatment setTreat_Schedule:[_treat_Schedule copy]];
    [newTreatment setTreat_Remark:_treat_Remark];
    
    return newTreatment;
}

- (void)setTreat_Remark:(NSString *)treat_Remark
{
    _treat_Remark = treat_Remark;
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _treat_Remark;
    textView.font = kFont_Light_16;
    float currentHeight = [textView sizeThatFits:CGSizeMake(310.0f, FLT_MAX)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_Treat_Remark = currentHeight;
    textView = nil;
}

@end
