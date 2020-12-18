//
//  OrderDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "ContentEditCell.h"
#import "PermissionDoc.h"

@implementation OrderDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.order_Status = 0;
        
        self.productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
        self.courseArray   = [NSMutableArray array];
        self.contractArray = [NSMutableArray array];
        self.productArray  = [NSMutableArray array];
        self.order_SalesList = [NSMutableArray array];
        self.BenefitListArr = [NSMutableArray array];
    }
    return self;
}

- (void)setOrder_Status:(int)order_Status
{
    if (self.order_ProductType == 0) {
        _order_Status = order_Status;
        switch (_order_Status) {
            case 1: _order_StatusStr = @"未完成";  break;
            case 2: _order_StatusStr = @"已完成";  break;
            case 3: _order_StatusStr = @"已取消";  break;
            case 4: _order_StatusStr = @"已终止";  break;
            default:
                _order_StatusStr = @"";
                break;
        }
    } else {
        _order_Status = order_Status;
        switch (_order_Status) {
            case 1: _order_StatusStr = @"未完成";  break;
            case 2: _order_StatusStr = @"已完成";  break;
            case 3: _order_StatusStr = @"已取消";  break;
            case 4: _order_StatusStr = @"已终止";  break;
            default:
                _order_StatusStr = @"";
                break;
        }
    }
    
}

- (void)setOrder_Ispaid:(int)order_Ispaid
{
    _order_Ispaid = order_Ispaid;
    switch (_order_Ispaid) {
        case 1: _order_IspaidStr = @"未支付";  break;
        case 2: _order_IspaidStr = @"部分付";  break;
        case 3: _order_IspaidStr = @"已支付";  break;
        case 4: _order_IspaidStr = @"已退款";break;
        case 5: _order_IspaidStr = @"免支付";break;
        default:
            break;
    }
}

-(void)setOrder_TGStatus:(int)order_TGStatus
{
    _order_TGStatus = order_TGStatus;
    if (self.order_ProductType == 1) {
        switch (order_TGStatus) {
            case 1:
                self.order_TGStatusStr = @"进行中";
                break;
            case 2:
                self.order_TGStatusStr = @"已完成";
                break;
            case 3:
                self.order_TGStatusStr = @"已取消";
                break;
            case 4:
                self.order_TGStatusStr = @"已终止";
                break;
            case 5:
                self.order_TGStatusStr = @"待确认";
                break;
            default:
                self.order_TGStatusStr = @"";
                break;
        }
    }else
    {
        switch (order_TGStatus) {
            case 1:
                self.order_TGStatusStr = @"进行中";
                break;
            case 2:
                self.order_TGStatusStr = @"已完成";
                break;
            case 3:
                self.order_TGStatusStr = @"已取消";
                break;
            case 4:
                self.order_TGStatusStr = @"已终止";
                break;
            case 5:
                self.order_TGStatusStr = @"待确认";
                break;
            default:
                self.order_TGStatusStr = @"";
                break;
        }
    }
    
}

- (CGFloat)remark_height
{
    __autoreleasing ContentEditCell *cell = [[ContentEditCell alloc] init];
    cell.contentEditText.text = _order_Remark;
    CGFloat currentHeight = [cell.contentEditText sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    return currentHeight;
}

- (BOOL)isMyOrder
{
    if (ACC_ACCOUNTID == self.order_CreatorID || ACC_ACCOUNTID == self.order_AccountID || ACC_ACCOUNTID == self.order_SalesID) {
        _isMyOrder = YES;
    } else {
        _isMyOrder = NO;
        
    }
    return _isMyOrder;
}

- (OrderEditStatus)editStatus
{
    if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        if ([[PermissionDoc sharePermission] rule_MyOrder_Write] && self.isMyOrder) {
            _editStatus = OrderEditStatusIsMy;
        } else if ([[PermissionDoc sharePermission] rule_AllOrder_Write] && (self.order_BranchId == ACC_BRANCHID)) {
            _editStatus = OrderEditStatusBranch;
        } else {
            _editStatus = OrderEditStatusNone;
        }
    } else {
        _editStatus = OrderEditStatusNone;
    }
    return _editStatus;
}

-(NSString *)ThumbnailURL
{
    if (_ThumbnailURL) {
        NSArray *tempArrs = [_ThumbnailURL componentsSeparatedByString:@"&th="];
        _ThumbnailURL = tempArrs.firstObject;
    }
    return _ThumbnailURL;
}




@end
