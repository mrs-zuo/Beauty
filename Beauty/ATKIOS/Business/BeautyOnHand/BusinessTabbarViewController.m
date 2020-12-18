//
//  BusinessTabbarViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/15.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "BusinessTabbarViewController.h"
#import "OrderListViewController.h"
#import "DoServiceToday_ViewController.h"
#import "GPNavigationController.h"

@interface BusinessTabbarViewController ()
{
    OrderListViewController * orderListView;
    DoServiceToday_ViewController * doServiceView;
}
@property (strong, nonatomic) UIView *bgView;
@end

@implementation BusinessTabbarViewController
@synthesize bgView;

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
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f,kSCREN_BOUNDS.size.height - 64.0f - 49, kSCREN_BOUNDS.size.width, 49.0f);
    bgView.userInteractionEnabled = YES;
    //wugang->
    //bgView.backgroundColor = [UIColor colorWithRed:53/255. green:174/255. blue:255/255. alpha:1.];
    bgView.backgroundColor = [UIColor colorWithRed:73/255. green:75/255. blue:81/255. alpha:1.];
    //<-wugang
    [self.view addSubview:bgView];
    
    NSArray * titelArr = [[NSArray alloc] initWithObjects:@"服务",@"订单", nil];
    for (int i = 0; i < 2; i++) {

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(160*i, 0,160, 49)];
        button.userInteractionEnabled = YES;
        button.tag = i + 100;
        [bgView addSubview:button];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:kColor_DarkBlue forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:button];
    }
    
    UIButton *fistBt = (UIButton *)[bgView viewWithTag:100];
    fistBt.selected = YES;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    orderListView= [sb instantiateViewControllerWithIdentifier:@"OrderListView"];
    orderListView.viewTag = 1;
    doServiceView= [[DoServiceToday_ViewController alloc] init];
    NSArray *viewControllerArray = [NSArray arrayWithObjects:doServiceView,orderListView,nil];
    super.viewControllers = viewControllerArray;
}

-(void)buttonAction:(UIButton*)sender
{
    UIButton *bt = (UIButton *)[bgView viewWithTag:100];
    UIButton *bt1 = (UIButton *)[bgView viewWithTag:101];
   [self setSelectedIndex:sender.tag];
    switch (sender.tag) {
        case 100:
        {
            bt.selected = YES;
            bt1.selected = NO;
        }
            break;
        case 101:
        {
            bt.selected = NO;
            bt1.selected = YES;
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
