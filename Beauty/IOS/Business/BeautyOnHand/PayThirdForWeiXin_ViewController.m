//
//  PayThirdForWeiXin_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "PayThirdForWeiXin_ViewController.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "ThirdPayForCode_ViewController.h"
#import "ScanQRCodeViewController.h"
#import "ThirdWeChatWeb_ViewController.h"

@interface PayThirdForWeiXin_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView * myTableView;

@end

@implementation PayThirdForWeiXin_ViewController
@synthesize myTableView;
@synthesize payType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    NavigationView *navigationView;
    if (payType == PayTypeWeiXin) {
       navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"微信第三方支付"];

    }
    if (payType == PayTypeZhiFuBao) {
        navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"支付宝第三方支付"];
    }
   
    [self.view addSubview:navigationView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect ];
    button.frame = CGRectMake(283, 5, 28.0f,28.0f);
    button.layer.cornerRadius = 9;
    [button addTarget:self action:@selector(gotoWebView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:53/255. green:174/255. blue:254/255. alpha:1.];
    [button setTitle:@"?" forState:UIControlStateNormal];
    [button setTitleColor:kColor_White forState:UIControlStateNormal];
    [navigationView addSubview:button];
    
    [self initTableView];
}

-(void)gotoWebView
{
    ThirdWeChatWeb_ViewController * web = [[ThirdWeChatWeb_ViewController alloc] init];
    web.payType = payType;
    [self.navigationController pushViewController:web animated:YES];
    
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
    }
    
    UIView * View = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f, myTableView.frame.size.width+10 , 49.0f)];
    View.backgroundColor = kColor_Background_View;;
    [self.view addSubview:View];
    
    UIButton * buttonCancel = [UIButton buttonWithTitle:@"返回" target:self selector:@selector(goBackView) frame:CGRectMake( 5, 5 , 310, 39) backgroundImg:ButtonStyleBlue];
    [View addSubview:buttonCancel];
}

-(void)goBackView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==1) {
        return 160;
    }
    return kTableView_HeightOfRow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [NSString stringWithFormat:@"editCell%ld",(long)indexPath.row];
    NormalEditCell *editCell = [tableView dequeueReusableCellWithIdentifier:string];
    if (!editCell) {
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
        editCell.valueText.userInteractionEnabled = NO;
    }
    [editCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.section) {
        case 0:
            editCell.valueText.textColor = kColor_Black;
            editCell.titleLabel.text = @"本次应付小计";
            editCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",MoneyIcon,self.thisPayPrice];
            break;
        case 1:
        {
            editCell.titleLabel.text = @"";
            UIButton * codeButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 25,110, 110)];
            if (payType  == PayTypeWeiXin) {
                [codeButton setImage:[UIImage imageNamed:@"payWeChat"] forState:UIControlStateNormal];
            }
            if (payType  == PayTypeZhiFuBao) {
                [codeButton setImage:[UIImage imageNamed:@"aliPay"] forState:UIControlStateNormal];
            }
            [codeButton addTarget:self action:@selector(chooseAction:) forControlEvents:UIControlEventTouchUpInside];
            codeButton.tag = 101;
            [editCell.contentView addSubview:codeButton];
            
            UIButton * cardButton = [[UIButton alloc] initWithFrame:CGRectMake(180, 25, 110, 110)];
            if (payType  == PayTypeWeiXin) {
                [cardButton setImage:[UIImage imageNamed:@"payThirdCard"] forState:UIControlStateNormal];
            }
            if (payType  == PayTypeZhiFuBao) {
                [cardButton setImage:[UIImage imageNamed:@"aliPayCode"] forState:UIControlStateNormal];
            }
            [cardButton addTarget:self action:@selector(chooseAction:) forControlEvents:UIControlEventTouchUpInside];
            cardButton.tag = 102;
            [editCell.contentView addSubview:cardButton];
        
        }
            break;
        default:
            break;
    }
    return editCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)chooseAction:(UIButton *)sender
{
    if (sender.tag == 101) {
       
        /** 二维码支付 */
        ThirdPayForCode_ViewController * code  =[[ThirdPayForCode_ViewController alloc] init];
        code.para = self.para;
        code.payPrice = self.thisPayPrice;
        code.orderComeFrom = self.orderComeFrom;
        code.payType = payType;
        [self.navigationController pushViewController:code animated:YES];
        
    }else
    {
        ScanQRCodeViewController * scan = [[ScanQRCodeViewController alloc] init];
        scan.viewFor = 1;
        scan.para = self.para;
        scan.orderComeFrom = self.orderComeFrom;
        scan.payType = payType;
        [self.navigationController pushViewController:scan animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
