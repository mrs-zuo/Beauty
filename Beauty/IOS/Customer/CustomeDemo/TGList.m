//
//  TGList.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/7.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "TGList.h"

@implementation TGList


-(void)setStatus_0:(NSString *)status_0{
    _status_0 = status_0;
    

switch ([_status_0 integerValue]) {
    case 1: _order_StatusStrForCommodity = @"未完成";  break;
    case 2: _order_StatusStrForCommodity = @"已完成";  break;
    case 3: _order_StatusStrForCommodity = @"已取消";  break;
    case 4: _order_StatusStrForCommodity = @"已终止";  break;
    default: break;
}
}
@end
