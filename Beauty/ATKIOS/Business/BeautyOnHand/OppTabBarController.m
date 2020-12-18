//
//  CustomTabBarController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OppTabBarController.h"
#import "DEFINE.h"

#define Line_IMG [UIImage imageNamed:@"tabbar_Line"];

@interface OppTabBarController ()
@property (strong, nonatomic) NSArray *normalImgArray;
@property (strong, nonatomic) NSArray *selectedImgArray;
@property (strong, nonatomic) UIView *bgView;
@end

@implementation OppTabBarController
@synthesize normalImgArray, selectedImgArray;
@synthesize bgView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)awakeFromNib
{
    selectedImgArray = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"oppTab_SaleProgress_0"],
                        [UIImage imageNamed:@"oppTab_History_0"],
                        nil];
    
    normalImgArray = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"oppTab_SaleProgress_1"],
                      [UIImage imageNamed:@"oppTab_History_1"],
                      nil];
    
    if ([normalImgArray count] != [selectedImgArray count])
        DLOG(@"Error:%s \n %d", __FUNCTION__, __LINE__);
    
    [self addCustomElements];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)addCustomElements
{
    bgView = [[UIView alloc] init];
    
    if (IOS6) {
        bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height  - 49.0f - 64.0f, kSCREN_BOUNDS.size.width, 49.0f);
    } else {
        bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height  - 49.0f - 64.0f, kSCREN_BOUNDS.size.width, 49.0f);
    }
    
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
    float w = kSCREN_BOUNDS.size.width / [normalImgArray count];
    
    for (int i = 0; i < [normalImgArray count]; i++) {
        float x = i * w;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0.0f, w, 49.0f)];
        imageView.userInteractionEnabled = YES;
        imageView.image = [normalImgArray objectAtIndex:i];
        imageView.tag = i + 100;
        [bgView addSubview:imageView];
        
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tapGestureRecognizer1];
    }
    
    UIImageView *firstImgView = (UIImageView *)[bgView viewWithTag:100];
    firstImgView.image = [selectedImgArray firstObject];
    
    for (int i=0; i < [normalImgArray count] - 1; i++) {
        float line_X = w * (i + 1) - 1;
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(line_X, 0, 1, 49)];
        lineImgView.image = Line_IMG;
        lineImgView.userInteractionEnabled = NO;
        [bgView addSubview:lineImgView];
    }
}

- (void)tapImageView:(UIGestureRecognizer *)sender
{
    [self setSelectedIndex:sender.view.tag];
}

// --OverWrite setSelectedIndex
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    // 初始化
    for (int i = 0; i < [normalImgArray count] ; i++) {
        UIImageView *tmpImgView = (UIImageView *)[bgView viewWithTag:i + 100];
        tmpImgView.image = [normalImgArray objectAtIndex:i];
    }
    
    UIImageView *selectedImgView = (UIImageView *)[bgView viewWithTag:selectedIndex];
    selectedImgView.image = [selectedImgArray objectAtIndex:selectedIndex - 100];
    
    [super setSelectedIndex:selectedIndex - 100];
}

- (void)makeTabBarHidden:(BOOL)hide
{
    if ( [self.view.subviews count] < 2 )
    {
        return;
    }
    
    UIView *contentView;
    if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
    {
        contentView = [self.view.subviews objectAtIndex:1];
    }
    else
    {
        contentView = [self.view.subviews objectAtIndex:0];
    }
    if ( hide)
    {
        contentView.frame = self.view.bounds;
        
        bgView.hidden = YES;
        
    }
    else
    {
        contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                       self.view.bounds.origin.y,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - self.tabBar.frame.size.height);
        bgView.hidden = NO;
    }
    
    self.tabBar.hidden = hide;
}



@end

