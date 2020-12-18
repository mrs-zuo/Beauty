//
//  ReportDataDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-10-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportDataDoc.h"

@implementation ReportDataDoc
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
        _sectionDatas = [NSMutableArray arrayWithObjects:@"截止日期",@"人员",@"订单", nil];
        
        _personRowDatas = [NSMutableArray arrayWithObjects:@"有效顾客",@"顾客端用户",@"公众号用户", nil];
        _orderRowDatas = [NSMutableArray arrayWithObjects:@"完成订单数量",@"有效订单数量",@"订单总金额", nil];

    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

}

@end
