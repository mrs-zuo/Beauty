//
//  TitleView.h
//  CustomeDemo
//
//  Created by macmini on 13-9-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//  2013.9.13 吴旭 可重用的页面头部

#import <UIKit/UIKit.h>

@interface TitleView : UIView
@property (strong, nonatomic) UILabel *titleLabel;                  //文字显示
@property (strong, nonatomic) UIImageView *backgroundImageView;     //图片显示
- (UIView *)getTitleView:(NSString *)title;
@end
