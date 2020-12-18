//
//  PayInfo_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/10.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "PayInfo_ViewController.h"
#import "GPHTTPClient.h"
#import "OrderDoc.h"
#import <ShareSDK/ShareSDK.h>
#import "PaymentInfoDoc.h"
#import "WAmountConverter.h"
#import "PayWayTableViewCell.h"

@interface PayInfo_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString *login_Advanced;
    BOOL flag[2];
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestPaymentInfo;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCapitalMoneyOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestLogoutOperation;
@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) PaymentInfoDoc * paymentInfo;
@property (assign,nonatomic)float table_Height;
@property (nonatomic,strong) NSMutableArray *payWayArrs;
@property (nonatomic,strong) NSMutableDictionary *payWayDic;

@end

@implementation PayInfo_ViewController

@synthesize myTableView;
@synthesize table_Height;
@synthesize paymentInfo;

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"订单支付";
    [self initData];
    [self initTableView];
    [self getPaymentInfo];
}

-(BOOL)isHaveCardID
{
    BOOL isHaveCardID = NO;
    for (OrderDoc *orderDoc in self.selectOrderPayArr) {
        if (orderDoc.cardID) {
            isHaveCardID = YES;
            break;
        }
    };
    return isHaveCardID;
}
- (NSArray *)permissionDatas
{
    NSArray *defaultArrs;
    if ([self isHaveCardID]) {
        defaultArrs = @[@"储值卡",@"余额",@"有效期",@"应付款",@"大写"];
    }else{
       login_Advanced=  [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_ADVANCED"];
        if (!login_Advanced) {
            NSAssert(login_Advanced == nil, @"login_Advanced不能为空");
        }
        if([login_Advanced containsString:@"|5|6|"]) {
            defaultArrs = @[@"支付宝",@"微信",@"应付款",@"大写"];
        }else if ([login_Advanced containsString:@"|5|"]) {
            defaultArrs = @[@"微信",@"应付款",@"大写"];
            
        }else if ([login_Advanced containsString:@"|6|"]) {
            defaultArrs = @[@"支付宝",@"应付款",@"大写"];
        }
    }
    return defaultArrs;
}
#pragma mark -init
-(void)initData
{
    NSArray *arrs = [self permissionDatas];
    self.payWayArrs = [NSMutableArray arrayWithArray:arrs];
    NSDictionary *dic;
    if([login_Advanced containsString:@"|5|6|"]) {
        dic = @{@"微信":@"NO",@"支付宝":@"YES"};
    }else{
        dic = @{@"微信":@"YES",@"支付宝":@"YES"};
    }
    self.payWayDic = [NSMutableDictionary dictionaryWithDictionary:dic];
}
-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 49 + 20)style:UITableViewStyleGrouped];
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
    
    table_Height = myTableView.frame.size.height +44;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    UIButton *add_Button = [UIButton buttonWithTitle:@"支付"
                                              target:self
                                            selector:@selector(PayOrderAction:)
                                               frame:CGRectMake(5,5,kSCREN_BOUNDS.size.width - 10,39)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
}

-(void)PayOrderAction:(UIButton *)sender
{
    [self addPayment];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==1 || section==2)
        return 45;
    return  kTableView_Margin_TOP;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    headerView.backgroundColor = kColor_Clear;
    NSString * headerStr ;
    if (section ==1) {
        headerStr =  @"支付方式";
    }else if(section ==2)
    {
        headerStr =  @"赠送";
    }else
    {
        headerStr = @"";
    }
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10,8, 300, 30)];
    lable.text = headerStr;
    lable.font = kNormalFont_14;
    lable.textColor = kColor_Black;
    [headerView addSubview:lable];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if(section == 1)
    {
       return  self.payWayArrs.count;
    }else if(section == 2)
    {
        if (([paymentInfo.giveCouponAmount doubleValue] >0.00001 )&& ([paymentInfo.givePointAmount doubleValue]<0.00001))
        {
            return 1;
        }else if (([paymentInfo.giveCouponAmount doubleValue] <0.00001 )&& ([paymentInfo.givePointAmount doubleValue]>0.00001))
        {
            return 1;
        }
        return 2;
    }
    return 1;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([paymentInfo.giveCouponAmount doubleValue] >0.00001 || [paymentInfo.givePointAmount doubleValue]>0.00001) {
         return 3;
    }
    return 2;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
        cell.valueText.textColor = kColor_Editable;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"订单数量";
                cell.valueText.text = [NSString stringWithFormat:@"%ld",(long)paymentInfo.orderNumber];
            }
                break;
            case 1:
            {
                cell.titleLabel.text = @"总计金额";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",CUS_CURRENCYTOKEN,paymentInfo.totalOrigPrice];
            }
                break;
                
            default:
                break;
        }
    }else if(indexPath.section ==1)
    {
        NSString *title= self.payWayArrs[indexPath.row];
        if ([title isEqualToString:@"支付宝"] || [title isEqualToString:@"微信"]) {
            PayWayTableViewCell *payWayCell = [self PayWayCellWithTableView:tableView];
            payWayCell.titleLab.text = title;
            payWayCell.markBtn.titleLabel.text = title;
            if ([[self.payWayDic objectForKey:title]isEqualToString:@"YES"]) {
                [payWayCell.markBtn setImage:[UIImage imageNamed:@"icon_Selected"]forState:UIControlStateNormal];
            }else{
                [payWayCell.markBtn setImage:[UIImage imageNamed:@"icon_unSelected"]forState:UIControlStateNormal];
            }
            __weak typeof(self) weakSelf = self;
            payWayCell.btnClickBlcok = ^(UIButton *button){
                if ([button.titleLabel.text isEqualToString:@"支付宝"]) {
                    [weakSelf.payWayDic setValue:@"YES" forKey:@"支付宝"];
                    [weakSelf.payWayDic setValue:@"NO" forKey:@"微信"];
                }else{
                    [weakSelf.payWayDic setValue:@"NO" forKey:@"支付宝"];
                    [weakSelf.payWayDic setValue:@"YES" forKey:@"微信"];
                }
                //一个section刷新
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                [myTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            payWayCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return payWayCell;
        }else{
            cell.titleLabel.text = title;
            if ([title isEqualToString:@"储值卡"]) {
                cell.valueText.text = paymentInfo.cardName;
            }else if ([title isEqualToString:@"余额"]) {
                cell.valueText.text = [NSString stringWithFormat:@"%@%@",CUS_CURRENCYTOKEN,paymentInfo.balance];
            }else if ([title isEqualToString:@"有效期"]) {
                cell.valueText.text = paymentInfo.expirationDate;
            }else if ([title isEqualToString:@"应付款"]) {
                cell.valueText.text =  [NSString stringWithFormat:@"%@%.2Lf",CUS_CURRENCYTOKEN,paymentInfo.unPaidPrice];
            }else if ([title isEqualToString:@"大写"]) {
                cell.valueText.text = [self convertByPayTotal:paymentInfo.unPaidPrice];
            }
        }
    
    }else if (indexPath.section == 2)
    {
        switch (indexPath.row) {
            case 0:
            {//第一行有送积分显示积分，如无积分显示现金券
                if ([paymentInfo.givePointAmount doubleValue] >0.00001 )
                {
                    cell.titleLabel.text = @"赠送积分";
                    cell.valueText.text = [NSString stringWithFormat:@"%@",paymentInfo.givePointAmount];
                    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                        [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                    }
                } else {
                    cell.titleLabel.text = @"赠送现金券";
                    cell.valueText.text = [NSString stringWithFormat:@"%@%@",CUS_CURRENCYTOKEN,paymentInfo.giveCouponAmount];
                    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                        [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                    }
                }
            }
                break;
            case 1:
            {//第二行显示现金券
                cell.titleLabel.text = @"赠送现金券";
                cell.valueText.text = [NSString stringWithFormat:@"%@%@",CUS_CURRENCYTOKEN,paymentInfo.giveCouponAmount];
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                }
            }
                break;
            default:
                break;
        }
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(PayWayTableViewCell *)PayWayCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"PayWayCell";
    PayWayTableViewCell *payWayCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!payWayCell) {
        payWayCell = [[NSBundle mainBundle]loadNibNamed:@"PayWayTableViewCell" owner:self options:nil].firstObject;
    }
    
    return payWayCell;
}

#pragma mark -大小写转换

- (NSString *)convertByPayTotal:(CGFloat)paytotal
{
    NSString *str = [NSString stringWithFormat:@"%.2f",paytotal];
    if (paytotal < 1) {
        NSString *number1 = [str substringWithRange:NSMakeRange(2, 1)];
        NSString *number2 = [str substringWithRange:NSMakeRange(3, 1)];
        
        NSString *cNumber1 = [self convert:number1];
        NSString *cNumber2 = [self convert:number2];
        
        return [NSString stringWithFormat:@"零元%@角%@分", cNumber1, cNumber2];
    } else {
        NSArray *array = [str componentsSeparatedByString:@"."];
        
        NSMutableString *retStr = [NSMutableString string];
        [retStr appendString:convert(array[0])];
        
        if ([array[1] isEqualToString:@"00"] ) {
            [retStr appendString:@"元整"];
        }else {
            CGFloat decimals = paytotal - (int)paytotal;
            NSString *str1 = [NSString stringWithFormat:@"%.2f",decimals];
            
            NSString *number3 = [str1 substringWithRange:NSMakeRange(2, 1)];
            NSString *number4 = [str1 substringWithRange:NSMakeRange(3, 1)];
            
            NSString *cNumber3 = [self convert:number3];
            NSString *cNumber4 = [self convert:number4];
            
            [retStr appendString:[NSString stringWithFormat:@"元%@角%@分", cNumber3, cNumber4]];
        }
        return retStr;
    }
}


- (NSString *)convert:(NSString *)number
{
    switch ([number integerValue]) {
        case 0: return @"零";
        case 1: return @"壹";
        case 2: return @"贰";
        case 3: return @"叁";
        case 4: return @"肆";
        case 5: return @"伍";
        case 6: return @"陆";
        case 7: return @"柒";
        case 8: return @"捌";
        case 9: return @"玖";
        default:break;
    }
    return nil;
}

#pragma mark - 接口

-(void)getPaymentInfo{
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (OrderDoc *orderDoc in self.selectOrderPayArr) {
        
        [array addObject:@{@"OrderID":@((long long)orderDoc.order_ID),@"OrderObjectID":@((long long)orderDoc.order_ObjectID),@"ProductType":@((long)orderDoc.order_Type)}];
    };
    
    NSDictionary *para = @{@"OrderList":array};
    
    _requestPaymentInfo = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Payment/GetPaymentInfo"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message){

            paymentInfo = [[PaymentInfoDoc alloc] init];
            paymentInfo.orderNumber = self.selectOrderPayArr.count;
            paymentInfo.ProductCode = [[data objectForKey:@"ProductCode"] integerValue];
            paymentInfo.totalOrigPrice = [[data objectForKey:@"TotalOrigPrice"] doubleValue];
            paymentInfo.totalCalcPrice = [[data objectForKey:@"TotalCalcPrice"] doubleValue];
            paymentInfo.totalSalePrice = [[data objectForKey:@"TotalSalePrice"] doubleValue];
            paymentInfo.unPaidPrice = [[data objectForKey:@"UnPaidPrice"] doubleValue];
            paymentInfo.expirationDate = [[data objectForKey:@"ExpirationDate"] substringToIndex:10];
            paymentInfo.cardName = [data objectForKey:@"CardName"];
            paymentInfo.cardID = [[data objectForKey:@"CardID"] integerValue];
            paymentInfo.cardTypeID = [[data objectForKey:@"CardTypeID"] integerValue];
            paymentInfo.userCardNo = [data objectForKey:@"UserCardNo"];
            paymentInfo.giveCouponAmount = [data objectForKey:@"GiveCouponAmount"];
            paymentInfo.givePointAmount = [data objectForKey:@"GivePointAmount"];
            paymentInfo.balance = [data objectForKey:@"Balance"];
            
            [myTableView reloadData];
            
        }failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        
        
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)addPayment
{
    
    NSDictionary * paymentDetaiDic = @{@"UserCardNo":paymentInfo.userCardNo};
    NSMutableArray *orderIdArray = [[NSMutableArray alloc]init];
    
    for (OrderDoc *orderDoc in self.selectOrderPayArr) {
        
        [orderIdArray addObject:@((long)orderDoc.order_ID)];
    };
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *para = @{
                           @"OrderCount":@(self.selectOrderPayArr.count),
                           @"PaymentDetail":paymentDetaiDic,
                           @"TotalPrice":[NSNumber numberWithFloat:paymentInfo.unPaidPrice],
                           @"OrderIDList":orderIdArray
                           };
    _requestCapitalMoneyOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Payment/AddPayment"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


-(void)logout{
    [SVProgressHUD showWithStatus:@"Loading"];
    //退出的时候，注销注册的微博和微信
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiFav];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
    _requestLogoutOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/Logout"  showErrorMsg:NO  parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_USERID"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYID"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHID"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHCOUNT"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYCODE"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYABBREVIATION"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_SELFNAME"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_HEADIMAGE"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DISCOUNT"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DATABASE"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYSCALE"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PROMOTION"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_REMINDCOUNT"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYLIST"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PAYCOUNT"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CONFIRMCOUNT"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CURRENCYTOKEN"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_ADVANCED"];
            double delayInSeconds = 0.8f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                //循环查找最底层模态视图，再退出
                UIViewController *viewController = self;
                while(viewController.presentingViewController) {
                    viewController = viewController.presentingViewController;
                }
                if(viewController) {
                    [viewController dismissViewControllerAnimated:YES completion:nil];
                    AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
                    appDelegate.isNeedGetVersion = NO;
                }
            });
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:@"登出失败！"];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus2:@"登出失败！"];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
