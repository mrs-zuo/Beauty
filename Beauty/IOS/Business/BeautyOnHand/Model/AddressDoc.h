//
//  AddressDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressDoc : NSObject

@property (assign, nonatomic) NSInteger adrs_Id;
@property (copy, nonatomic) NSString *adrs_Address;
@property (copy, nonatomic) NSString *adrs_ZipCode;
@property (assign, nonatomic) NSInteger adrs_Type;      // 住宅1 工作2 其他3
@property (assign, nonatomic) NSInteger ctlFlag;   // 默认0  添加1 更改2  删除3

@property (strong, nonatomic, readonly) NSString *adrsType;
@property (assign, nonatomic, readonly) CGFloat cell_Address_Height;
@end
