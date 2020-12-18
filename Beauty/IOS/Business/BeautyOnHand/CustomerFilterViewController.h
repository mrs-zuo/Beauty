//
//  CustomerFilterViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomerEcardLevelDelegate;
@interface CustomerFilterViewController : UIViewController
///注册方式
@property (nonatomic, assign) NSInteger registFrom;
//顾客来源
@property (nonatomic, assign) NSInteger sourceType;
//顾客类型
@property (nonatomic, assign) NSInteger cusType;
//顾客日期标志位  0:全部  1:当日   2 手动输入
@property (nonatomic,assign) NSInteger firstVisitType;
//顾客有效无效标志位  0:全部  1:有效   2 无效
@property (nonatomic,assign) NSInteger effectiveCustomerType;
//顾客日期值
@property (nonatomic,assign) NSString  *firstVisitDateTime;
//顾客姓名
@property (nonatomic,strong) NSString  *customerName;
//顾客电话
@property (nonatomic,strong) NSString  *customerTel;

@property (nonatomic, strong) NSNumber *ecarLevel;
@property (nonatomic, weak)   id<CustomerEcardLevelDelegate>  delegate;

@end
@protocol CustomerEcardLevelDelegate <NSObject>

- (void)setCustomerEcardLevel:(NSInteger)level responID:(NSString *)personID registFrom:(NSInteger)regFrom sourceType:(NSInteger)stID stIDInt:(NSInteger)firstVisitTypeValue firstVisitTypeInt:(NSString *)firstVisitDateTimeValue firstVisitDateTimeString:(NSInteger) effectiveCustomerTypeValue searchCustomerName:(NSString *) customerName searchCustomerTel:(NSString *) customerTel;
- (void)didnotRefresh;
@end

