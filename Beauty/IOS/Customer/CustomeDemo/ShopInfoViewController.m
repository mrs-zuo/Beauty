//
//  ShopInfoViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ShopInfoViewController.h"
#import "ShopFirstViewController.h"
#import "ShopSecondViewController.h"
#import "ShopThirdViewController.h"
#import "ShopInfoModel.h"

#import "DEFINE.h"

#define ImageViewHeight     120.0f
#define TableViewBorder     3.0f
#define ButtonFieldHeight   32.0

#define ImageScrollWidth    300.0f
#define PageControlWidth    300.0f

@interface ShopInfoViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *buttonField;
@property (nonatomic, assign) NSInteger currentButton;
@property (nonatomic, assign) NSInteger oldButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *vcArray;
@property (nonatomic, strong) NSMutableArray *imageList;

@property (strong ,nonatomic) UIView * lineView;
@property (nonatomic,assign) NSInteger index;

@end

@implementation ShopInfoViewController
@synthesize lineView;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"门店一览";
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 子控制器初始化
- (void)initData
{
    ShopFirstViewController *first = [[ShopFirstViewController alloc] init];
    first.title = @"门店介绍";
    first.shopInfo = self.currentShop;
    
    ShopSecondViewController *second = [[ShopSecondViewController alloc] init];
    second.title = @"促销一览";
    second.BranchID = self.BranchID;
    
    ShopThirdViewController *third = [[ShopThirdViewController alloc] init];
    third.title = @"服务团队";
    third.shopInfo = self.currentShop;

    self.vcArray = @[first, second, third];
}

#pragma mark - 视图初始化
- (void)initView
{

    [self initSegmentControl];
    [self initMainView];
    self.view.backgroundColor = kDefaultBackgroundColor;
}
-(void)initSegmentControl
{
    NSArray *arr = [[NSArray alloc]initWithObjects:@"门店介绍",@"促销一览",@"服务团队", nil];
    //先创建一个数组用于设置标题
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:arr];
    [segment setApportionsSegmentWidthsByContent:YES];//时，每个的宽度按segment的宽度平分
    segment.frame = CGRectMake(0,kNavigationBar_Height, kSCREN_BOUNDS.size.width, 45);
    segment.selectedSegmentIndex= self.index;
    segment.tintColor = kColor_Clear;
    segment.backgroundColor = kColor_White;
    
    //修改字体的默认颜色与选中颜色
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:kColor_TitlePink,UITextAttributeTextColor,  [UIFont fontWithName:@"Helvetica" size:14.f],UITextAttributeFont ,kColor_TitlePink,UITextAttributeTextShadowColor ,nil];
    [segment setTitleTextAttributes:dic forState:UIControlStateSelected];
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    [self.view addSubview:segment];
    
    segment.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
    [segment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    
    UIView * lightLineView = [[UIView alloc] initWithFrame:CGRectMake(0,45+ kNavigationBar_Height,kSCREN_BOUNDS.size.width, 0.5f)];
    lightLineView.backgroundColor = kTableView_LineColor;
    [self.view addSubview:lightLineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0,45 + kNavigationBar_Height, (kSCREN_BOUNDS.size.width) / 3, 0.5f)];
    lineView.backgroundColor = KColor_NavBarTintColor;
    [self.view addSubview:lineView];
    
    
}
-(void)segmentedAction:(UISegmentedControl *)sender{
    
    self.index = sender.selectedSegmentIndex;
    [self lineViewAnimationsWithIndex:self.index];
    [self updateViewController];
}


#pragma mark 子控制器视图设置
- (void)initMainView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - CGRectGetMaxY(lineView.frame) - (0.5 + 5) + 20)];

    self.scrollView.backgroundColor = kDefaultBackgroundColor;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    
    CGSize size = [self adjustViewLayout];
    
    [self.vcArray enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:obj];
        [obj didMoveToParentViewController:self];
        obj.view.frame = CGRectMake(kSCREN_BOUNDS.size.width * idx + TableViewBorder, 0, size.width - TableViewBorder * 2, size.height);
        [self.scrollView addSubview:obj.view];
    }];
    
    self.scrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width * self.vcArray.count, 0);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (CGSize)adjustViewLayout
{
    return CGSizeMake(kSCREN_BOUNDS.size.width, CGRectGetHeight(self.scrollView.frame));
}


#pragma mark 根据点击按钮调整视图
- (void)updateViewController
{
    self.scrollView.contentOffset = CGPointMake(kSCREN_BOUNDS.size.width * (int)(self.index % 100), 0);
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollView == scrollView) {
        self.oldButton = self.currentButton;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView == scrollView) {
        if (self.oldButton != self.currentButton) {
            [self updateDataWithController];
        }
    }
}

- (void)updateDataWithController
{
    OriginViewController *originVC = [self.vcArray objectAtIndex:self.currentButton % 100];
    [originVC updateData];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point =  scrollView.contentOffset;
    CGFloat i = point.x / kSCREN_BOUNDS.size.width;
    [self lineViewAnimationsWithIndex:@(i).integerValue];
}
- (void)lineViewAnimationsWithIndex:(NSInteger)index;
{
    [UIImageView beginAnimations:@"anim" context:NULL];
    [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIImageView setAnimationBeginsFromCurrentState:YES];
    [UIImageView setAnimationDuration:0.5];
    CGRect listFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    switch (index) {
        case 0:
            listFrame = CGRectMake(10, 44 + kNavigationBar_Height, (kSCREN_BOUNDS.size.width - 20) / 3, 0.5f);
            break;
        case 1:
            listFrame = CGRectMake(10 + ((kSCREN_BOUNDS.size.width - 20) / 3), 44 + kNavigationBar_Height, (kSCREN_BOUNDS.size.width - 20) / 3, 0.5f);
            break;
        case 2:
            listFrame = CGRectMake(10 + 2 *((kSCREN_BOUNDS.size.width - 20) / 3), 44 + kNavigationBar_Height, (kSCREN_BOUNDS.size.width - 20) / 3, 0.5f);
            break;
        default:
            break;
    }
    lineView.frame = listFrame;
    [UIImageView commitAnimations];
    
}


@end
