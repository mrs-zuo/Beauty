//
//  TirdPatmentRecords_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/10/28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ThirdPatmentRecords_ViewController.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "SVProgressHUD.h"
#import "ThirdPayResult_ViewController.h"

@interface ThirdPatmentRecords_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView * myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestPayForCodeResult;
@property (nonatomic,strong) NSArray * recordsListArr;

@end

@implementation ThirdPatmentRecords_ViewController
@synthesize myTableView;
@synthesize recordsListArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"第三方支付记录"];
    
    [self.view addSubview:navigationView];

    [self initTableView];
    
    [self requestPayForCodeResultInfo];
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
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
//    if (self.viewFor != 1) {
//        return 5;
//    }
    return 6;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return recordsListArr.count;
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
    NSDictionary * recordsDic = [recordsListArr objectAtIndex:indexPath.section];
    
//    NSInteger index = indexPath.row;
//    if (indexPath.row == 2 && self.viewFor == 1) {
//        index ++ ;
//    }
    switch (indexPath.row) {
        case 0:
        {
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
            editCell.valueText.frame = CGRectMake(85.0f, kTableView_HeightOfRow/2 - 30.0f/2, 200, 30.0f);
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [editCell.contentView addSubview:arrowsImage];
            editCell.titleLabel.text =@"交易单号";
            editCell.valueText.text = [recordsDic objectForKey:@"NetTradeNo"];
        }
            break;
        case 1:
            editCell.titleLabel.text =@"交易方式";
            NSInteger  netTradeVendor =  [[recordsDic objectForKey:@"NetTradeVendor"] integerValue];
            if (netTradeVendor == PayTypeWeiXin) {
                editCell.valueText.text =@"微信";
            }
            if (netTradeVendor == PayTypeZhiFuBao) {
                editCell.valueText.text = @"支付宝";
            }
            break;
        case 2:
            editCell.titleLabel.text =@"交易金额";
            editCell.valueText.text = [NSString stringWithFormat:@"%@%@",MoneyIcon,[recordsDic objectForKey:@"CashFee"]];
            break;
        case 3:
            editCell.titleLabel.text = @"交易类型";
            editCell.valueText.text = [recordsDic objectForKey:@"ChangeTypeName"];
            break;
        case 4:
            editCell.titleLabel.text =@"交易时间";
            editCell.valueText.text = [recordsDic objectForKey:@"CreateTime"];
            break;
        case 5:
        {
            NSString * promptString = @"";

            NSInteger  netTradeVendor =  [[recordsDic objectForKey:@"NetTradeVendor"] integerValue];
            if (netTradeVendor == PayTypeWeiXin) {
                if ( ![[recordsDic objectForKey:@"ResultCode"] isKindOfClass:[NSNull class]] && [[recordsDic objectForKey:@"ResultCode"] isEqualToString:@"SUCCESS"]) {
                    if ([[recordsDic objectForKey:@"TradeState"] isEqualToString:@"SUCCESS"]) {
                        promptString = @"支付成功";

                    }else if(![[recordsDic objectForKey:@"TradeState"] isKindOfClass:[NSNull class]] && [[recordsDic objectForKey:@"TradeState"] isEqualToString:@"CLOSED"])
                    {
                        promptString = @"已关闭";
                        
                    }else if(![[recordsDic objectForKey:@"TradeState"] isKindOfClass:[NSNull class]] && [[recordsDic objectForKey:@"TradeState"] isEqualToString:@"REVOKED"])
                    {
                        promptString = @"已撤销";
                        
                    }else if(![[recordsDic objectForKey:@"TradeState"] isKindOfClass:[NSNull class]] && [[recordsDic objectForKey:@"TradeState"] isEqualToString:@"PAYERROR"])
                    {
                        promptString = @"支付失败";
                    }
                }else if(![[recordsDic objectForKey:@"ResultCode"] isKindOfClass:[NSNull class]] && [[recordsDic objectForKey:@"ResultCode"] isEqualToString:@"FAIL"])
                {
                    promptString = @"支付失败";
                }else if([[recordsDic objectForKey:@"ResultCode"] isKindOfClass:[NSNull class]] || [[recordsDic objectForKey:@"ResultCode"] isEqualToString:@""])
                {
                    if(![[recordsDic objectForKey:@"TradeState"] isKindOfClass:[NSNull class]] &&[[recordsDic objectForKey:@"TradeState"] isEqualToString:@"NOTPAY"])
                    {
                        promptString = @"未支付";
                    }else if(![[recordsDic objectForKey:@"TradeState"] isKindOfClass:[NSNull class]] &&[[recordsDic objectForKey:@"TradeState"] isEqualToString:@"USERPAYING"] )
                    {
                        promptString = @"用户支付中";
                    }else{
                        promptString = @"支付结果未知";
                    }
                }
            }
            if (netTradeVendor == PayTypeZhiFuBao) {
                if (![[recordsDic objectForKey:@"TradeState"] isEqual:[NSNull class]]&& [[recordsDic objectForKey:@"TradeState"] isEqualToString:@"TRADE_SUCCESS"]) {
                    promptString = @"支付成功";
                }else if ([[recordsDic objectForKey:@"TradeState"] isEqualToString:@""] || [[recordsDic objectForKey:@"TradeState"] isEqual:[NSNull class]]) {
                    promptString = @"用户支付中";
                }else {
                    promptString = @"支付失败";
                }
            }
            editCell.titleLabel.text =@"交易状态";
            editCell.valueText.text = promptString;
        }
            break;
        default:
            break;
    }
        return  editCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
          NSDictionary * recordsDic = [recordsListArr objectAtIndex:indexPath.section];
        ThirdPayResult_ViewController * result = [[ThirdPayResult_ViewController alloc] init];
        result.NetTradeNo = [recordsDic objectForKey:@"NetTradeNo"];
        NSInteger  netTradeVendor =  [[recordsDic objectForKey:@"NetTradeVendor"] integerValue];
        result.payType = netTradeVendor;
        [self.navigationController pushViewController:result animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)requestPayForCodeResultInfo
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par ;
    
    if (self.viewFor == 2) {
        par = @{
                @"CustomerID":@((long)self.customerID),
                };
        
    }else if(self.viewFor == 3)
    {
        par = @{
                @"CustomerID":@((long)self.customerID),
                @"UserCardNo":self.userCardNO
                };
    }else
    {
        par = @{
                @"OrderID":@((long)self.orderId),
                };
    }
    _requestPayForCodeResult = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/GetWeChatPayResaultByID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            recordsListArr = data;
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD showSuccessWithStatus:error];

        }];
    } failure:^(NSError *error) {
        
    }];
}

@end
