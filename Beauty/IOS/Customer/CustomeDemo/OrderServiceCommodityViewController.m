//
//  OrderServiceCommodityViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-11-28.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "OrderServiceCommodityViewController.h"

#define Line_IMG [UIImage imageNamed:@"templateTab_centerLine"];

@interface OrderServiceCommodityViewController ()
@property (strong, nonatomic) NSArray *normalImgArray;
@property (strong, nonatomic) NSArray *selectedImgArray;

@property (strong, nonatomic) UIView *bgView;
@end
@interface OrderServiceCommodityViewController ()

@end

@implementation OrderServiceCommodityViewController

@synthesize normalImgArray, selectedImgArray;
@synthesize bgView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)awakeFromNib
{
    selectedImgArray = [NSArray arrayWithObjects:
                        [UIImage imageNamed:@"orderTabBar_Service_1"],
                        [UIImage imageNamed:@"orderTabBar_Commodity_1"],
                        nil];
    
    normalImgArray = [NSArray arrayWithObjects:
                      [UIImage imageNamed:@"orderTabBar_Service_0"],
                      [UIImage imageNamed:@"orderTabBar_Commodity_0"],
                      nil];
    
    if ([normalImgArray count] != [selectedImgArray count])
        NSLog(@"Error:%s \n %d", __FUNCTION__, __LINE__);
    
    [self addCustomElements];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
}

-(void)addCustomElements
{
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 49.0f - 44.0f, 320.0f, 49.0f);
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];
    
    CGFloat w = kSCREN_BOUNDS.size.width / [normalImgArray count];
    
    for (int i = 0; i < [normalImgArray count]; i++) {
        CGFloat x = i * w;
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
        CGFloat line_X = w * (i + 1) - 1;
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


@end
