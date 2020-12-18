//
//  CustomTabBarController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTabBarController: UITabBarController
@property (nonatomic, strong) UIImageView *orderInfoImgView;
@property (nonatomic, strong) UIImageView *effectDisplayImgView;
@property (nonatomic, strong) UIImageView *commentImgView;

//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic,strong)UILabel * tabLable1;
@property (nonatomic,strong)UILabel * tabLable2;
@property (nonatomic,strong)UILabel * tabLable3;

-(void) addCustomElements;
-(void) selectTab:(NSInteger)tabID;
@end
