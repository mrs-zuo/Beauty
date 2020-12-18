//
//  ThirdPayResult_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ThirdPayResult_ViewController.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "OrderDetailViewController.h"
#import "OrderPayListViewController.h"
#import "GPNavigationController.h"
#import "RechargeViewController.h"

@interface ThirdPayResult_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong) UITableView * myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestPayForCodeResult;
/**
 * 0 支付失败  1、 支付结果未知  2 、支付成功
 */
@property (nonatomic ,assign) NSInteger payResult;

@property (nonatomic ,strong) NSString * payTime;
@property (nonatomic ,strong) NSString * payMent;
@property (nonatomic ,strong) NSString * payNumber;
@property (nonatomic ,strong) UIView * buttonBackgroudView;
@property (nonatomic ,strong) NSString * promptString;
@property (nonatomic ,strong) NSString * faseReasonString;
@property (assign, nonatomic) CGPoint startTouch;
@property (assign, nonatomic) BOOL isLastTreatment;
@property (assign, nonatomic) BOOL isMoving;
@property (assign, nonatomic) BOOL isGone;

@end

@implementation ThirdPayResult_ViewController
@synthesize myTableView;
@synthesize buttonBackgroudView;
@synthesize faseReasonString;
@synthesize payType;


-(void)viewWillAppear:(BOOL)animated
{

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paySuccessAndGoTo)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"第三方支付结果"];
    
    [self.view addSubview:navigationView];
    
    [self initTableView];
    
    [self requestPayForCodeResultInfo];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.payResult != 2) {
        return NO;
    }
    return  YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
}

-(void)initButton
{
    if (buttonBackgroudView) {
        [buttonBackgroudView removeFromSuperview];
    }
    buttonBackgroudView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f, myTableView.frame.size.width+10 , 49.0f)];
    buttonBackgroudView.backgroundColor = kColor_Background_View;;
    [self.view addSubview:buttonBackgroudView];
    
    if (self.payResult != 1) {
        
        UIButton * buttonConfirm = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(paySuccessAndGoTo) frame:CGRectMake(5, 5 ,310, 39)backgroundImg:ButtonStyleBlue];
        [buttonBackgroudView addSubview:buttonConfirm];

    }else
    {
        UIButton * buttonCancel = [UIButton buttonWithTitle:@"返回" target:self selector:@selector(goBackView) frame:CGRectMake( 5, 5 , 152.5, 39) backgroundImg:ButtonStyleBlue];
        
        UIButton * buttonConfirm = [UIButton buttonWithTitle:@"查询支付结果" target:self selector:@selector(requestPayForCodeResultInfo) frame:CGRectMake(162.5, 5 , 152.5, 39)backgroundImg:ButtonStyleBlue];
        
        [buttonBackgroudView addSubview:buttonCancel];
        [buttonBackgroudView addSubview:buttonConfirm];
    }
    
}

-(void)goBackView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if (self.payResult == 2 ) {
            if (payType == PayTypeWeiXin) {
                return 7;
            }else{
                return 6;
            }
        }else
            return 3;
    }
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
        editCell.valueText.textColor = kColor_Black;
    }
    [editCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section ==1) {
        if (payType == PayTypeWeiXin) {
            switch (indexPath.row) {
                case 0:
                    editCell.titleLabel.text =@"第三方支付编号";
                    editCell.valueText.text = self.NetTradeNo;
                    break;
                case 1:
                    editCell.titleLabel.textColor = kColor_Black;
                    editCell.titleLabel.text = self.productName;
                    break;
                case 2:
                    editCell.titleLabel.text =@"金额";
                    editCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",MoneyIcon,self.payPrice];
                    break;
                case 3:
                    editCell.titleLabel.text =@"时间";
                    editCell.valueText.text = self.payTime;
                    break;
                case 4:
                    editCell.titleLabel.text =@"支付方式";
                    editCell.valueText.text = self.payMent;
                    break;
                case 5:
                    editCell.titleLabel.text =@"交易单号";
                    editCell.valueText.text = @"";
                    break;
                case 6:
                    editCell.titleLabel.text =@"";
                    editCell.valueText.text = self.payNumber;
                    editCell.valueText.frame = CGRectMake(5.0f, kTableView_HeightOfRow/2 - 30.0f/2, 300, 30.0f);
                    editCell.valueText.textAlignment = NSTextAlignmentLeft;
                    break;
                    
                default:
                    break;
            }

        }
        if (payType == PayTypeZhiFuBao) {
            switch (indexPath.row) {
                case 0:
                    editCell.titleLabel.text =@"第三方支付编号";
                    editCell.valueText.text = self.NetTradeNo;
                    break;
                case 1:
                    editCell.titleLabel.textColor = kColor_Black;
                    editCell.titleLabel.text = self.productName;
                    break;
                case 2:
                    editCell.titleLabel.text =@"金额";
                    editCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",MoneyIcon,self.payPrice];
                    break;
                case 3:
                    editCell.titleLabel.text =@"时间";
                    editCell.valueText.text = self.payTime;
                    break;
                case 4:
                    editCell.titleLabel.text =@"交易单号";
                    editCell.valueText.text = @"";
                    break;
                case 5:
                    editCell.titleLabel.text =@"";
                    editCell.valueText.text = self.payNumber;
                    editCell.valueText.frame = CGRectMake(5.0f, kTableView_HeightOfRow/2 - 30.0f/2, 300, 30.0f);
                    editCell.valueText.textAlignment = NSTextAlignmentLeft;
                    break;
                    
                default:
                    break;
            }

        }
    }else
    {
        editCell.titleLabel.text = self.promptString;
        editCell.titleLabel.textColor = kColor_White;
        editCell.titleLabel.frame = CGRectMake(0, 0, 310, kTableView_HeightOfRow);
        editCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (self.payResult == 2) {
            editCell.backgroundColor = [UIColor colorWithRed:84/255. green:168/255. blue:32/255. alpha:1.];
        }else if (self.payResult == 1)
        {
            editCell.backgroundColor = [UIColor colorWithRed:109/255. green:204/255. blue:244/255. alpha:1.];
        }else
        {
            editCell.backgroundColor = KColor_Red;
        }
    }
    return  editCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// --获取二维码支付结果

-(void)requestPayForCodeResultInfo
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
//    /Payment/GetAliPayRes 支付宝主动查询支付结果
//    所需参数
//    {"NetTradeNo":"12345687456123"}
//    返回参数
//    { "Data": { "NetTradeNo": "NPC16021800000004", "TradeState": "TRADE_SUCCESS", "Code": "10000", "Msg": "Success", "SubMsg": "", "TradeNo": "2016021821001004910297988385", "TotalAmount": 0.00, "ReceiptAmount": 0.0, "InvoiceAmount": 0.0, "BuyerPayAmount": 0.0, "PointAmount": 1000.00, "DisplayResult": "交易支付成功", "OperationTip": null, "ChangeType": 1, "ChangeTypeName": null }, "Code": "1", "Message": "支付成功" }
    
    NSDictionary * par = @{
                           @"NetTradeNo":self.NetTradeNo
                           };
    self.payResult = 0;
    self.promptString = @"支付失败";
    
    NSString *urlPath;
    if (payType == PayTypeWeiXin) {
        urlPath = @"/Payment/GetWeChatPayRes";
    }
    if (payType == PayTypeZhiFuBao) {
        urlPath = @"/Payment/GetAliPayRes";
    }
    
    _requestPayForCodeResult = [[GPBHTTPClient sharedClient] requestUrlPath:urlPath andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            if (payType == PayTypeWeiXin) { // 微信支付
                
                self.payMent = [data objectForKey:@"BankName"];
                self.payNumber = [data objectForKey:@"TransactionID"];
                self.payTime = [data objectForKey:@"CreateTime"];
                self.NetTradeNo = [data objectForKey:@"NetTradeNo"];
                self.productName = [data objectForKey:@"ProductName"];
                self.payPrice = [[data objectForKey:@"CashFee"] doubleValue];
                
                if ([[data objectForKey:@"ResultCode"] isEqualToString:@"SUCCESS"]) {
                    if ([[data objectForKey:@"TradeState"] isEqualToString:@"SUCCESS"]) {
                        self.payResult = 2;
                        self.promptString = @"支付成功";
                    }
                    else if([[data objectForKey:@"TradeState"] isEqualToString:@"CLOSED"])
                    {
                        self.promptString = @"已关闭";
                        
                    }else if([[data objectForKey:@"TradeState"] isEqualToString:@"REVOKED"])
                    {
                        self.promptString = @"已撤销";
                        
                    }else if([[data objectForKey:@"TradeState"] isEqualToString:@"PAYERROR"])
                    {
                        self.promptString = @"支付失败";
                        
                    }
                }else if([[data objectForKey:@"ResultCode"] isEqualToString:@"FAIL"])
                {
                    self.promptString = @"支付失败";
                    
                }else if([[data objectForKey:@"ResultCode"] isKindOfClass:[NSNull class]] || [[data objectForKey:@"ResultCode"] length] ==0)
                {
                    if([[data objectForKey:@"TradeState"] isEqualToString:@"NOTPAY"])
                    {
                        self.payResult = 1;
                        self.promptString = @"未支付";
                        
                    }else if([[data objectForKey:@"TradeState"] isEqualToString:@"USERPAYING"] )
                    {
                        self.payResult = 1;
                        self.promptString = @"用户支付中";
                        
                    }else
                    {
                        self.payResult = 1;
                        self.promptString = @"支付结果未知";
                    }
                    
                }

            }
            
            if (payType == PayTypeZhiFuBao) { //支付宝
                
                self.payNumber = [data objectForKey:@"TradeNo"];
                self.payPrice = [[data objectForKey:@"TotalAmount"] doubleValue];
                self.NetTradeNo = [data objectForKey:@"NetTradeNo"];
                self.productName = [data objectForKey:@"ProductName"];
                self.payTime = [data objectForKey:@"CreateTime"];
                
                if ([[data objectForKey:@"TradeState"] isEqualToString:@"TRADE_SUCCESS"]) {
                    self.payResult = 2;
                    self.promptString = @"支付成功";
                }else if ([[data objectForKey:@"TradeState"] isEqualToString:@""] || [[data objectForKey:@"TradeState"] isEqual:[NSNull class]]) {
                    self.payResult = 1;
                    self.promptString = @"用户支付中";
                }else {
                    self.promptString = @"支付失败";
                }
            }
            
            [self initButton];
            
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus:error];
        }];
    } failure:^(NSError *error) {
        
    }];
}

/** 支付成功或失败后的跳转 */
- (void)paySuccessAndGoTo
{
    if (self.orderComeFrom ==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.orderComeFrom == 1) {//来自订单详情页完成支付直接返回订单详情
        
        for (UIViewController *temp in self.navigationController.viewControllers) {
      
            if ([temp isKindOfClass:[OrderDetailViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else if (self.orderComeFrom ==2)//返回到结账列表页
    {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            
            if ([temp isKindOfClass:[OrderPayListViewController class]]) {
                
                [temp performSelector:@selector(initSelcte) withObject:nil];
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }else if (self.orderComeFrom ==3)//返回账户详情
    {
        for (UIViewController *temp in self.navigationController.viewControllers) {
            
            if ([temp isKindOfClass:[RechargeViewController class]]) {
                
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
    }

}

@end
