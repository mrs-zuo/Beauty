//
//  OrderDetailModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OrderDetailModel.h"

@implementation OrderDetailModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"GroupList"]) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSDictionary *dic in value) {
            [tmpArray addObject:[[TreatmentGroup alloc] initWithDic:dic]];
        }

        self.GroupList = [tmpArray copy];
    } else if ([key isEqualToString:@"ScdlList"]) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSDictionary *dic in value) {
            [tmpArray addObject:[[TaskModel alloc] initWithDic:dic]];
        }
        self.ScdlList = [tmpArray copy];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (NSInteger)groupCount
{
    _groupCount = 0;
    if (_GroupList.count) {
        [_GroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            _groupCount += obj.treatCount;
        }];
    }
    return _groupCount;
}

- (NSInteger)completionCount
{
    _completionCount = 0;
    if (_CompletionGroupList.count) {
        [_CompletionGroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            _completionCount += obj.treatCount;
            _treatmentCount = obj.treatCount;
        }];
    }
    return _completionCount;
}

- (TreatmentGroup *)fetchTreatmentGroupIndex:(NSIndexPath *)index
{
    NSInteger indexRow = index.row;
    TreatmentGroup *treatGroup = nil;
    for (TreatmentGroup *group in self.GroupList) {
        
        if (indexRow > group.treatCount) {
            indexRow -= group.treatCount;
        } else {
            treatGroup = group;
            break;
        }
    }
    return treatGroup;
}

- (NSString *)payStatus
{
    if (_payStatus == nil) {
        switch (_PaymentStatus) {
            case 1: _payStatus = @"未支付";  break;
            case 2: _payStatus = @"部分付";  break;
            case 3: _payStatus = @"已支付";  break;
            case 4: _payStatus = @"已退款";  break;
            case 5: _payStatus = @"免支付";  break;
        }
    }
    return _payStatus;
}

- (NSString *)progressStatus
{
    if (_progressStatus == nil) {
        switch (_Status) {
            case 1: _progressStatus = @"未完成";  break;
            case 2: _progressStatus = @"已完成";  break;
            case 3: _progressStatus = @"已取消";  break;
            case 4: _progressStatus = @"已终止";  break;
        }
    }
    return _progressStatus;
}

- (NSString *)orderProgressInfo
{
    if (_orderProgressInfo == nil) {
        if (_ProductType == 0) {
            if (_TotalCount ==0) {
                _orderProgressInfo = [NSString stringWithFormat:@"完成%ld次/不限次",(long)_FinishedCount ];
            }else
                _orderProgressInfo = [NSString stringWithFormat:@"完成%ld次/共%ld次",(long)_FinishedCount ,(long)_TotalCount ];
        } else {
            _orderProgressInfo = [NSString stringWithFormat:@"交付%ld件/共%ld件",(long)_FinishedCount,(long)_TotalCount];
        }
    }
    return _orderProgressInfo;
}

+(NSString *)orderProgressStatus:(NSInteger)status
{
    NSString *progress = [[NSString alloc] init];
    switch (status) {
        case 1: progress = @"未完成";  break;
        case 2: progress = @"已完成";  break;
        case 3: progress = @"已取消";  break;
        case 4: progress = @"已终止";  break;
        case 5: progress = @"待确认";  break;

    }
    return progress;
}
- (CGFloat)remarkHeight
{
    if (_remarkHeight == 0) {
        CGSize size = [self.Remark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
        if (size.height < 22) {
            _remarkHeight = kTableView_HeightOfRow;
        } else {
            _remarkHeight = size.height + 10;
        }
    }
    return _remarkHeight;
}
@end
