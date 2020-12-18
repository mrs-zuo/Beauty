//
//  PayThirdForWeiXin_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//
typedef NS_ENUM(NSInteger, PayType) {
    PayTypeWeiXin = 1,
    PayTypeZhiFuBao = 2
};

#import <UIKit/UIKit.h>
@interface PayThirdForWeiXin_ViewController : BaseViewController
@property (nonatomic , assign) long double thisPayPrice;
@property (nonatomic ,strong) NSDictionary * para;
@property (nonatomic ,assign) NSInteger orderComeFrom;
@property (nonatomic, assign) PayType payType;

@end
