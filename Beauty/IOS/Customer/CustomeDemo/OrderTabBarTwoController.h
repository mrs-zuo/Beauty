//
//  OrderTabBarTwoController.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTabBarTwoController : UITabBarController


@property (nonatomic, strong) UIImageView *orderInfoImgView;

@property (nonatomic, strong) UIImageView *commentImgView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic,strong)UILabel * tabLable1;

@property (nonatomic,strong)UILabel * tabLable3;

-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;
@end
