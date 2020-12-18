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
    ZXServiceEffectViewController *serviceEffectView;
    TreatmentGroupReview_ViewController * reviewView;
    
}
@property (strong, nonatomic) UIView *bgView;
@end

@implementation TreatmentGroupTabbarController
@synthesize bgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }

    
    self.tabBar.hidden = YES ; //隐藏原先的tarbar
    
    [self addCustomElements];
}


-(void)addCustomElements
{
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(0.0f,kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f);
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = [UIColor colorWithRed:213/255. green:197/255. blue:181/255. alpha:1.];
    [self.view addSubview:bgView];
    
    NSArray * titelArr = [[NSArray alloc] initWithObjects:@"详情",@"效果",@"评价", nil];
    CGFloat width = kSCREN_BOUNDS.size.width / 3;
    for (int i = 0; i < titelArr.count; i++) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width *i, 0,width, 49)];
        button.userInteractionEnabled = YES;
        button.tag = i + 100;
        [bgView addSubview:button];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%@",[titelArr objectAtIndex:i]] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:kColor_TitlePink forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:button];
        button.titleLabel.font = kNormalFont_14;
    }
    
    UIButton *fistBt = (UIButton *)[bgView viewWithTag:100];
    fistBt.selected = YES;


//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    detailView = [sb instantiateViewControllerWithIdentifier:@"TreatmentDetailViewController"];

    detailView = [[TreatmentDetailViewController alloc]init];
    serviceEffectView = [[ZXServiceEffectViewController alloc]init];
    reviewView= [[TreatmentGroupReview_ViewController alloc] init];

    NSArray *viewControllerArray = [NSArray arrayWithObjects:detailView,serviceEffectView,reviewView,nil];
    
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
