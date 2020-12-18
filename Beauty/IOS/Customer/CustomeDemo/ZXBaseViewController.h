//
//  ZXBaseViewController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/28.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//
// 封装需要改的视图坐标太多.所以没有用
#import <UIKit/UIKit.h>

@interface ZXBaseViewController : UIViewController

///只有back
@property (nonatomic,assign) BOOL isOnlyShowBackButton;

///是否要按钮  tab -- nav -  vc 结构
@property (nonatomic,assign) BOOL isShowButton;

///是否要按钮 tab -- nav -- tab - vc 结构
@property (nonatomic,assign) BOOL isShow_tab_nav_tab_vcButton;

- (void)homeAction;
- (void)goBack;

@end
