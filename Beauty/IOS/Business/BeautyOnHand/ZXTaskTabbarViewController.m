//
//  ZXTaskTabbarViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXTaskTabbarViewController.h"
#import "TaskList_ViewController.h"
#import "ZXVisitViewController.h"

@interface ZXTaskTabbarViewController ()
{
    TaskList_ViewController * taskListVC;
    ZXVisitViewController * visitVC;
}
@property (strong, nonatomic) UIView *bgView;
@end

@implementation ZXTaskTabbarViewController
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
    bgView.backgroundColor = [UIColor colorWithRed:53/255. green:174/255. blue:255/255. alpha:1.];
    [self.view addSubview:bgView];
    
    NSArray * titelArr = [[NSArray alloc] initWithObjects:@"服务预约",@"回访", nil];
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
    
    taskListVC = [[TaskList_ViewController alloc] init];
    visitVC = [[ZXVisitViewController alloc] init];
    NSArray *viewControllerArray = [NSArray arrayWithObjects:taskListVC,visitVC,nil];
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
}@end
