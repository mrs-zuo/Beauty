//
//  SubOrderViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/10.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SubOrderViewBack){
    SubOrderViewBackNormal,
    SubOrderViewBackDetail,
    SubOrderViewBackOrderMain,
    SubOrderViewBackOrderList
};

@interface SubOrderViewController : UIViewController
@property (nonatomic, strong) NSString *orderList;
@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, assign) NSInteger customerID;
@property (nonatomic, assign) SubOrderViewBack backMode;
@property (nonatomic, assign) long long taskID;
@property (nonatomic, strong) NSDictionary *userDic;
@end