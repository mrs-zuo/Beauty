//
//  CustomTabBarController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CusTabBarController.h"
#import "DEFINE.h"

#define Line_IMG [UIImage imageNamed:@"tabbar_Line"];

@interface CusTabBarController ()
@property (strong, nonatomic) NSArray *normalImgArray;
@property (strong, nonatomic) NSArray *selectedImgArray;

@property (strong, nonatomic) UIView *bgView;
@end

@implementation CusTabBarController
@synthesize normalImgArray, selectedImgArray;
@synthesize bgView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)awakeFromNib
{
    selectedImgArray = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"customerInfo1_selected"],
                      [UIImage imageNamed:@"customerInfo2_selected"],
                        [UIImage imageNamed:@"customerInfo3_selected"],
                        [UIImage imageNamed:@"customerInfo4_selected"],
                      nil];//[UIImage imageNamed:@"cusTabBar_Question_1"], @"cusTabBar_Basic_1" cusTabBar_Detail_1
    
    normalImgArray = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"customerInfo1_unSelected"],
                        [UIImage imageNamed:@"customerInfo2_unSelected"],
                      [UIImage imageNamed:@"customerInfo3_unSelected"],
                      [UIImage imageNamed:@"customerInfo4_unSelected"],
                        nil];//[UIImage imageNamed:@"cusTabBar_Question_0"],cusTabBar_Basic_0 cusTabBar_Detail_0
    
    if ([normalImgArray count] != [selectedImgArray count])
        DLOG(@"Error:%s \n %d", __FUNCTION__, __LINE__);
    
    [self addCustomElements];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)addCustomElements
{
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height  - 49.0f - 64.0f, kSCREN_BOUNDS.size.width, 49.0f);
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = [UIColor colorWithRed:62/255.0f green:190/255.0f blue:255/255.0 alpha:1.0];
    [self.view addSubview:bgView];
    
    CGFloat w = kSCREN_BOUNDS.size.width / [normalImgArray count];
    
    for (int i = 0; i < [normalImgArray count]; i++) {
        CGFloat x = i * w;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x+(w-30)/2, 6.0f, 30, 37.0f)];
        imageView.userInteractionEnabled = YES;
        imageView.image = [normalImgArray objectAtIndex:i];
        imageView.tag = i + 100;
        [bgView addSubview:imageView];
        
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tapGestureRecognizer1];
    }
    
    UIImageView *firstImgView = (UIImageView *)[bgView viewWithTag:100];
    firstImgView.image = [selectedImgArray firstObject];
    
//    for (int i=0; i < [normalImgArray count] - 1; i++) {
//        CGFloat line_X = w * (i + 1) - 1;
//        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(line_X, 0, 1, 49)];
//        lineImgView.image = Line_IMG;
//        lineImgView.userInteractionEnabled = NO;
//        [bgView addSubview:lineImgView];
//    }
}

- (void)tapImageView:(UIGestureRecognizer *)sender
{
    [self setSelectedIndex:sender.view.tag];
}

// --OverWrite setSelectedIndex:
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
  //  [UIView beginAnimations:@"" context:nil];
  //  [UIView setAnimationDuration:0.6f];
    
    // 初始化
    for (int i = 0; i < [normalImgArray count] ; i++) {
        UIImageView *tmpImgView = (UIImageView *)[bgView viewWithTag:i + 100];
        tmpImgView.image = [normalImgArray objectAtIndex:i];
    }
    
    UIImageView *selectedImgView = (UIImageView *)[bgView viewWithTag:selectedIndex];
    selectedImgView.image = [selectedImgArray objectAtIndex:selectedIndex - 100];
//    NSLog(@"selectinx =%d",selectedIndex-100);
    [super setSelectedIndex:selectedIndex - 100];
  //  [UIView commitAnimations];
}


@end
