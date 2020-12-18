//
//  TreatmentTabBarController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-2.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentTabBarController.h"
#import "DEFINE.h"

#define Line_IMG [UIImage imageNamed:@"tabbar_Line"];

@interface TreatmentTabBarController ()
@property (strong, nonatomic) NSArray *normalImgArray;
@property (strong, nonatomic) NSArray *selectedImgArray;
@property (nonatomic, strong) NSArray *titles;
@property (strong, nonatomic) UIView *bgView;
@end

@implementation TreatmentTabBarController
@synthesize normalImgArray, selectedImgArray;
@synthesize bgView;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)awakeFromNib
{

    self.titles = @[@"详情",@"效果",@"评价"];
//    self.titles = @[@"操作详情",@"操作效果",@"操作评价"];
    
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
    bgView.backgroundColor = kColor_ButtonBlue;
    bgView.userInteractionEnabled = YES;
    [self.view addSubview:bgView];

    CGFloat buttonWidth = kSCREN_BOUNDS.size.width / [self.titles count];

    for (int i = 0; i < self.titles.count; i++) {
        NSString *title = self.titles[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, 49.0f);
        button.tag = 100 + i;
        button.titleLabel.font = kFont_Light_16;
        if (i == 0) {
            button.selected = YES;
        }
        [bgView addSubview:button];
    }
    
    /*
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
     */
}

- (void)tapImageView:(UIGestureRecognizer *)sender
{
    [self setSelectedIndex:sender.view.tag];
}

- (void)tapButton:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    for (int i = 0; i < self.titles.count; i++) {
       UIButton *button = (UIButton *)[self.bgView viewWithTag:100 + i];
        button.selected = NO;
    }
    sender.selected = YES;

    [self setSelectedIndex:sender.tag];
}
// --OverWrite setSelectedIndex
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    // 初始化
//    for (int i = 0; i < [normalImgArray count] ; i++) {
//        UIImageView *tmpImgView = (UIImageView *)[bgView viewWithTag:i + 100];
//        tmpImgView.image = [normalImgArray objectAtIndex:i];
//    }
//    
//    UIImageView *selectedImgView = (UIImageView *)[bgView viewWithTag:selectedIndex];
//    selectedImgView.image = [selectedImgArray objectAtIndex:selectedIndex - 100];
    
    [super setSelectedIndex:selectedIndex - 100];
    
    
    UIButton *bt = (UIButton *)[self.bgView viewWithTag:100];
    UIButton *bt1 = (UIButton *)[self.bgView viewWithTag:101];
    UIButton *bt2 = (UIButton *)[self.bgView viewWithTag:102];
    
    switch (selectedIndex) {
        case 100:
        {
            bt.selected = YES;
            bt1.selected = NO;
            bt2.selected = NO;
            
        }
            break;
        case 101:
        {
            bt.selected = NO;
            bt1.selected = YES;
            bt2.selected = NO;
            
        }
            break;
        case 102:
        {
            bt.selected = NO;
            bt1.selected = NO;
            bt2.selected = YES;
            
        }
            break;
            
        default:
            break;
    }

}

-(void)hiddenTabbar
{
    self.tabBarController.tabBar.hidden = YES;
}


@end