//
//  CustomTabBarController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ServerTabBarController.h"

#define ITEM0_Normal_IMG [UIImage imageNamed:@"ServerTab_Part0"]
#define ITEM0_Select_IMG [UIImage imageNamed:@"ServerTab_Part1"]

#define ITEM1_Normal_IMG [UIImage imageNamed:@"ServerTab_Item0"]
#define ITEM1_Select_IMG [UIImage imageNamed:@"ServerTab_Item1"]

#define ITEM2_Normal_IMG [UIImage imageNamed:@"ServerTab_Comm0"]
#define ITEM2_Select_IMG [UIImage imageNamed:@"ServerTab_Comm1"]

#define CenterLine_IMG [UIImage imageNamed:@"oppTab_centerLine"];

#define TabBarItem_Width 318.0f/3

@implementation ServerTabBarController
@synthesize bgView;
@synthesize partImageView;
@synthesize itemImageView;
@synthesize commImageView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)awakeFromNib
{
    [self addServerElements];
}

-(void)addServerElements
{
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 49.0f, 320.0f, 49.0f);
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
    partImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TabBarItem_Width, 49.0f)];
    partImageView.userInteractionEnabled = YES;
    partImageView.image = ITEM0_Select_IMG;
    
    itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TabBarItem_Width+1, 0, TabBarItem_Width, 49.0f)];
    itemImageView.userInteractionEnabled = YES;
    itemImageView.image = ITEM1_Normal_IMG;
    
    commImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TabBarItem_Width*2+2, 0, TabBarItem_Width, 49.0f)];
    commImageView.userInteractionEnabled = YES;
    commImageView.image = ITEM2_Normal_IMG;
    
    partImageView.tag = 100;
    itemImageView.tag = 101;
    commImageView.tag = 102;
    
    [bgView addSubview:partImageView];
    [bgView addSubview:itemImageView];
    [bgView addSubview:commImageView];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [partImageView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [itemImageView addGestureRecognizer:tapGestureRecognizer2];
    
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [itemImageView addGestureRecognizer:tapGestureRecognizer3];
    
    for (int i=0; i < 2; i++) {
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(318.0f/3 * (i + 1) - 1, 0, 1, 49)];
        lineImgView.image = CenterLine_IMG;
        [bgView addSubview:lineImgView];
        lineImgView = nil;
    }
}

- (void)tapImageView:(UIGestureRecognizer *)sender
{
    UIImageView *selectedImgView = (UIImageView *)sender.view;
    NSInteger tag = selectedImgView.tag;
    
    [self setSelectedIndex:tag - 100];
}

// -- overwrite setSelectedIndex:
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    
    [partImageView setImage:ITEM0_Normal_IMG];
    [itemImageView setImage:ITEM1_Normal_IMG];
    [commImageView setImage:ITEM2_Normal_IMG];
    
    switch(selectedIndex + 100)
    {
        case 100:
        {
           [partImageView setImage:ITEM0_Select_IMG];
            
//            UINavigationController *navigationController = [self.viewControllers objectAtIndex:1];
//            [navigationController setViewControllers:nil];
        }
           
            break;
        case 101:
        {
          [itemImageView setImage:ITEM1_Select_IMG];
            
//            UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
//            [navigationController setViewControllers:nil];
        }
            break;
        case 102:
        {
            [commImageView setImage:ITEM2_Select_IMG];
            
            //            UINavigationController *navigationController = [self.viewControllers objectAtIndex:0];
            //            [navigationController setViewControllers:nil];
        }
            break;
    }
}

- (void)makeTabBarHidden:(BOOL)hide
{
    if ([self.view.subviews count] < 2 )
    {
        return;
    }
    
    UIView *contentView;
    if ([[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        contentView = [self.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.view.subviews objectAtIndex:0];
    }
    
    if (hide) {
        contentView.frame = self.view.bounds;
        bgView.hidden = YES;
    } else {
        contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                       self.view.bounds.origin.y,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - self.tabBar.frame.size.height);
        bgView.hidden = NO;
    }
    self.tabBar.hidden = hide;
}


@end
