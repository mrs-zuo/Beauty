//
//  ChangeECardViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/22.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "BaseViewController.h"

@interface ChangeECardViewController : BaseViewController
@property (assign ,nonatomic) int cardNumber;
@property (nonatomic,strong) NSDictionary*cardInfoDic;
@property (nonatomic,copy) NSString *userCardNo;

@end
