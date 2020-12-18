//
//  ScanQRCodeViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "PayThirdForWeiXin_ViewController.h"

@interface ScanQRCodeViewController : BaseViewController<ZBarReaderViewDelegate>

@property (nonatomic, assign) NSInteger viewFor; /** 0、右侧导航栏 1、来自第三方支付页 2、打卡*/
@property (nonatomic ,strong) NSDictionary * para;
@property (nonatomic ,assign) NSInteger orderComeFrom;
@property (nonatomic ,assign) NSString * NetTradeNo;
@property (nonatomic,assign) PayType payType;

@end
