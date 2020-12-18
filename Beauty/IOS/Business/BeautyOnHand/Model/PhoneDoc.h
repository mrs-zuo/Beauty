//
//  PhoneDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneDoc : NSObject
@property (assign, nonatomic) NSInteger ph_ID;
@property (copy, nonatomic) NSString *ph_PhoneNum;
@property (assign, nonatomic) NSInteger ph_Type;      // 手机0  住宅1 工作2 其他3

@property (strong, nonatomic, readonly) NSString *phoneType;
@property (assign, nonatomic) NSInteger ctlFlag;   // 默认0  添加1 更改2  删除3

@end
