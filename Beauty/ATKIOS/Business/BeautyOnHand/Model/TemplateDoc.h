//
//  TemplateDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateDoc : NSObject
@property (assign, nonatomic) NSInteger TemplateID;
@property (assign, nonatomic) NSInteger tmp_CompanyID;
@property (assign, nonatomic) NSInteger TemplateType;    // 0公用  1私有
@property (assign, nonatomic) NSInteger tmp_CreatorID;
@property (assign, nonatomic) NSInteger tmp_UpdaterID;
@property (copy, nonatomic) NSString *CreatorName;
@property (copy, nonatomic) NSString *UpdaterName;

@property (copy, nonatomic) NSString *Subject;
@property (copy, nonatomic) NSString *TemplateContent;
@property (copy, nonatomic) NSString *OperateTime;

@property (assign, nonatomic) CGFloat height_Tmp_TemplateContent;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
