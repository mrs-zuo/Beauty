//
//  OrderTabBarTwoController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "OrderTabBarTwoController.h"

#define OrderInfo_Normal_IMG [UIImage imageNamed:@"orderTab_orderInfo_1"]
#define OrderInfo_Select_IMG [UIImage imageNamed:@"orderTab_orderInfo_0"]

#define Comment_Normal_IMG [UIImage imageNamed:@"orderTab_comment_1"]
#define Comment_Select_IMG [UIImage imageNamed:@"orderTab_comment_0"]

#define TabBarItem_Width 320.0f/ 3

@interface OrderTabBarTwoController ()

@end

@implementation OrderTabBarTwoController
@synthesize orderInfoImgView;

@synthesize commentImgView;
@synthesize imageView;
@synthesize tabLable1,tabLable3;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
}


- (void)awakeFromNib
{
    [self addCustomElements];
}


- (void)addCustomElements
{
    UIView *bgView = [[UIView alloc]init];
    bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 49.0f - 44.0f, 320.0f, 49.0f);
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = [UIColor colorWithRed:213/255. green:197/255. blue:181/255. alpha:1.];
    [self.view addSubview:bgView];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TabBarItem_Width, 4.0f)];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = kColor_TitlePink;
    
    tabLable1 = [[UILabel alloc] initWithFrame:CGRectMake(TabBarItem_Width/2-40,0, 80, 49)];
    tabLable1.textColor = [UIColor whiteColor];
    tabLable1.text = @"详情";
    
    tabLable3 = [[UILabel alloc] initWithFrame:CGRectMake(TabBarItem_Width/2-40,0, 80, 49)];
    tabLable3.textColor = [UIColor whiteColor];
    tabLable3.text = @"评价";
    
    orderInfoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TabBarItem_Width, 49.0f)];
    orderInfoImgView.userInteractionEnabled = YES;
    [orderInfoImgView addSubview:tabLable1];
    tabLable1.textColor = kColor_TitlePink;
    
    commentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(TabBarItem_Width * 2, 0, TabBarItem_Width, 49.0f)];
    commentImgView.userInteractionEnabled = YES;
    [commentImgView addSubview:tabLable3];
    
    orderInfoImgView.tag = 100;
   
    commentImgView.tag = 102;
    
    [bgView addSubview:orderInfoImgView];
  
    [bgView addSubview:commentImgView];
    [bgView addSubview:imageView];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [orderInfoImgView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [commentImgView addGestureRecognizer:tapGestureRecognizer3];
    
}

- (void)tapImageView:(UIGestureRecognizer *)sender
{
    UIImageView *selectedImgView = (UIImageView *)sender.view;
    NSInteger tag = selectedImgView.tag;
    [self setSelectedIndex:tag - 100];
    [self selectTab:tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)selectTab:(NSInteger)tabID
{
    //    [orderInfoImgView setImage:OrderInfo_Normal_IMG];
    //    [effectDisplayImgView setImage:EffectDisplay_Normal_IMG];
    //    [commentImgView setImage:Comment_Normal_IMG];
    
    tabLable1.textColor = [UIColor whiteColor];
   
    tabLable3.textColor = [UIColor whiteColor];
    
    [UIImageView beginAnimations:@"anim" context:NULL];
    [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIImageView setAnimationBeginsFromCurrentState:YES];
    [UIImageView setAnimationDuration:0.5];
    CGRect listFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    switch(tabID)
    {
        case 100:
            //          /  [orderInfoImgView setImage:OrderInfo_Select_IMG];
            tabLable1.textColor = kColor_TitlePink;
            listFrame = CGRectMake(0.0f, 0.0f, TabBarItem_Width, 4.0f);
            break;
   
        case 102:
            //            [commentImgView setImage:Comment_Select_IMG];
            tabLable3.textColor = kColor_TitlePink;
            listFrame = CGRectMake(TabBarItem_Width * 2, 0.0f, TabBarItem_Width, 4.0f);
            break;
    }
    
    imageView.frame = listFrame;
    [UIImageView commitAnimations];
}

@end
