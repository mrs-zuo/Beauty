//
//  TreatmentGroupTabbarController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/22.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TreatmentGroupTabbarController.h"
#import "TreatmentDetailViewController.h"
#import "TreatmentGroupReview_ViewController.h"
#import "ZXServiceEffectViewController.h"


@interface TreatmentGroupTabbarController ()
{
    TreatmentDetailViewController * detailView;
    TreatmentGroupReview_ViewController * reviewView;
    ZXServiceEffectViewController *effectView;
}
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic)UIScrollView * scrollView;
@end

@implementation TreatmentGroupTabbarController
@synthesize bgView;
@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ((IOS7 || IOS8)){
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.tabBar.hidden = YES ; //隐藏原先的tarbar
    
    [self addCustomElements];
}

-(void)addCustomElements
{
//    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, kSCREN_BOUNDS.size.height-64-49)];
//    scrollView.backgroundColor = [UIColor clearColor];
//    scrollView.contentSize = CGSizeMake(320 *2, kSCREN_BOUNDS.size.height-64-49);
//    scrollView.showsHorizontalScrollIndicator = NO;
//    scrollView.showsVerticalScrollIndicator = NO;
//    [self.view addSubview:scrollView];
//    
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f,kSCREN_BOUNDS.size.height - 64.0f - 49, kSCREN_BOUNDS.size.width, 49.0f);
    bgView.userInteractionEnabled = YES;
    //wugang->
    //bgView.backgroundColor = [UIColor colorWithRed:53/255. green:174/255. blue:255/255. alpha:1.];
    bgView.backgroundColor = [UIColor colorWithRed:105/255. green:105/255. blue:105/255. alpha:1.];
    //<-wugang
    [self.view addSubview:bgView];

    CGFloat width = (kSCREN_BOUNDS.size.width - 20) / 3;
      NSArray * titelArr = [[NSArray alloc] initWithObjects:@"详情",@"效果",@"评价", nil];
    for (int i = 0; i < 3; i++) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width*i, 0,width, 49)];
        button.userInteractionEnabled = YES;
        button.tag = i + 100;
        [bgView addSubview:button];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //wugang->
        //[button setTitleColor:kColor_DarkBlue forState:UIControlStateSelected];
        [button setTitleColor:kColor_BackgroudBlue forState:UIControlStateSelected];
        //<-wugang
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:button];
        button.titleLabel.font = kFont_Light_16;
    }
    
    UIButton *fistBt = (UIButton *)[bgView viewWithTag:100];
    fistBt.selected = YES;

    reviewView= [[TreatmentGroupReview_ViewController alloc] init];
    effectView= [[ZXServiceEffectViewController alloc] init];

    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    detailView = [sb instantiateViewControllerWithIdentifier:@"TreatmentDetailViewController"];
    
    NSArray *viewControllerArray = [NSArray arrayWithObjects:detailView,effectView,reviewView,nil];
    
    super.viewControllers = viewControllerArray;
}

-(void)buttonAction:(UIButton*)sender
{
    UIButton *bt = (UIButton *)[bgView viewWithTag:100];
    UIButton *bt1 = (UIButton *)[bgView viewWithTag:101];
    UIButton *bt2 = (UIButton *)[bgView viewWithTag:102];

    [self setSelectedIndex:sender.tag];
    switch (sender.tag) {
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

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex - 100];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
