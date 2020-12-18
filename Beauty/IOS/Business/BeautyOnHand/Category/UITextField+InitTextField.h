//
//  UITextField+InitTextField.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-16.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (InitTextField)

+ (UITextField *)initNormalTextViewWithFrame:(CGRect)rect text:(NSString *)text placeHolder:(NSString *)placeText;

@end
