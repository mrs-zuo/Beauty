//
//  ResetPasswordViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBaseViewController.h"

@class LoginDoc;

@interface ResetPasswordViewController : ZXBaseViewController<UITextFieldDelegate>
@property (strong, nonatomic) NSArray *loginArray;
@property (copy, nonatomic) NSString *loginMobile;
@end
