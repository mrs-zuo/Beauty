//
//  ServerTabBarController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerTabBarController: UITabBarController
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *partImageView;
@property (nonatomic, strong) UIImageView *itemImageView;
@property (nonatomic, strong) UIImageView *commImageView;

- (void)makeTabBarHidden:(BOOL)hide;
@end
