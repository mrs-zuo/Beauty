//
//  SalesPromotionViewController.h
//  CustomeDemo
//
//  Created by macmini on 13-9-4.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ZXBaseViewController.h"

@interface SalesPromotionViewController : ZXBaseViewController <UIScrollViewDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate>
@property (strong,nonatomic) NSMutableArray *salesPromotionList;
@property (assign, nonatomic) NSInteger promotionSource; //1 登录 0 查看促销
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
