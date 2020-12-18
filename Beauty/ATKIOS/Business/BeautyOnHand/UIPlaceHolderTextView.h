//
//  UIPlaceHolderTextView.h
//  MLPark
//
//  Created by MLi-A-0002 on 12-11-20.
//  Copyright (c) 2012年 上海名立信息技术服务有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) UIColor *placeholderColor;

@property (assign, nonatomic) CGFloat leftMargin;

@end