//
//  ThirdPayForCode_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PayThirdForWeiXin_ViewController.h"

@interface ThirdPayForCode_ViewController : BaseViewController

@property (nonatomic,strong)NSDictionary * para;
@property (nonatomic,assign)long double payPrice;
@property (nonatomic ,assign) NSInteger orderComeFrom;
@property (nonatomic,assign) PayType payType;
@end
