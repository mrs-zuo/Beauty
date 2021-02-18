//
//  PayInfoViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-10-8.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "PayInfoViewController.h"
#import "DEFINE.h"
#import "OrderDoc.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "NavigationView.h"
#import "PayEditCell.h"
#import "PayDoc.h"
#import "WAmountConverter.h"
#import "FooterView.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "GDataXMLNode.h"
#import "ContentEditCell.h"
#import "NSDate+Convert.h"
#import "OrderListViewController.h"
#import "OrderDetailViewController.h"
#import "TwoLabelCell.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "SelectCustomersViewController.h"
#import "TwoTextFieldCell.h"
#import "DFTableAlertView.h"
#import "OrderDetailViewController.h"
#import "OrderPayListViewController.h"

#import "ColorImage.h"
#import "PayThirdForWeiXin_ViewController.h"
#import "PerformanceTableViewCell.h"
#import "UIButton+InitButton.h"


#define SHOWDISCOUNTPRICE (totalMoney != favorable ? YES : NO)

#define SALES_SHOW  (RMO(@"|4|") && self.salesDoc.user_Id != 0)

@interface PayInfoViewController ()<SelectCustomersViewControllerDelegate,PerformanceTableViewCellDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *addPayInfoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getEcardMoneyOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getPaymentInfoOperation;
@property (weak ,nonatomic) AFHTTPRequestOperation *requestCustomerCardListOperation;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

/** 价格 */
@property (assign, nonatomic) long double cashMoney;
@property (assign, nonatomic) long double cardMoney;
@property (assign, nonatomic) long double ticketMoney;
@property (nonatomic ,assign)long double thisPayPrice;
@property (nonatomic ,assign)long double intergralRate;
@property (nonatomic ,assign)long double cashCouponRate;
@property (nonatomic ,assign) long double sendCashCoupon;
@property (nonatomic, assign) long double sendIntergral;
@property (nonatomic ,assign) long double payCashCoupon;
@property (nonatomic ,assign)long double intergralPresentRate;
@property (nonatomic ,assign)long double cashCouponPresentRate;
@property (nonatomic ,assign)long double intergralToMoney;
@property (nonatomic ,assign)long double cashCouponToMoney;
@property (assign, nonatomic) long double favorable;
@property (nonatomic, assign) long double payIntergral;
@property (nonatomic, assign) long double balance;
/* 消费贷款、第三方支付*/
@property (nonatomic ,assign) long double loanMoney;
@property (nonatomic ,assign) long double thirdPartyMoney;

/** 微信支付价格*/
@property (nonatomic ,assign) long double weiXinPayPrice;
@property (nonatomic ,assign) long double zhiFuBaoPayPrice;
/*均分*/
@property (nonatomic ,assign) NSInteger averageFlag;  //0不均分 1均分
@property (nonatomic ,assign) NSInteger averageNum;  //按钮交替点击
/*业绩参与总金额*/
@property (nonatomic ,strong) NSString *branchProfitRate;

//** 数据模型 */
@property (strong, nonatomic) PayDoc *payDoc;
@property (strong, nonatomic) UserDoc *userDoc;
@property (nonatomic, strong) UserDoc *salesDoc;
@property (nonatomic ,strong) OrderDoc *orderDoc;

@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (nonatomic, strong) NSString *eCardExpirationTime;
@property (nonatomic, strong) NSMutableString *slaveID;

@property (nonatomic, strong) NSMutableArray *sectionArray;

/**所选择支付方式的保存状态，储值卡支付占一条，其它各占一条*/
@property (nonatomic, strong) NSMutableArray *choosePaymentMuArr;

@property (nonatomic, strong) NSMutableArray *chooseCardMuArr;
@property (nonatomic,strong) NSMutableArray * customerCardListMuArr;
@property (nonatomic ,strong) NSMutableArray * cardMoneyArr;

@property (nonatomic ,strong) NSDictionary *cashCardDic;
@property (nonatomic ,strong) NSDictionary *intergralCardDic;

@property (nonatomic, assign) BOOL choosePaymentType;
@property (nonatomic ,assign) BOOL sectionIsShow;
@property (nonatomic ,assign) BOOL isPartPay;
@property (nonatomic ,assign) BOOL isEcardPay;

@property (nonatomic ,strong) NSMutableArray * slaveArray;
/*销售顾问提成率array*/
@property (nonatomic ,strong) NSMutableArray * SalesConsultantRateArray;
/*是否显示业绩参与*/
@property (nonatomic ,strong) NSNumber * isComissionCalc;
//销售顾问提成率总计
@property (nonatomic ,assign)double totalcommissionRates;

@end

@implementation PayInfoViewController
@synthesize favorable;
@synthesize orderNumbers;
@synthesize myTableView;
@synthesize cashMoney, cardMoney, ticketMoney;
@synthesize paymentOrderArray;
@synthesize makeStateComplete;
@synthesize balance;
@synthesize customerId,payDoc;
@synthesize comeFrom;
@synthesize slaveArray;
@synthesize SalesConsultantRateArray;
@synthesize slaveID;
@synthesize userDoc;
@synthesize sectionArray;
@synthesize chooseCardMuArr,choosePaymentMuArr,choosePaymentType;
@synthesize cardMoneyArr;
@synthesize sendCashCoupon,sendIntergral,payCashCoupon,cashCardDic,payIntergral,intergralCardDic;
@synthesize customerCardListMuArr,thisPayPrice;
@synthesize cashCouponToMoney,intergralToMoney;
@synthesize orderDoc;
@synthesize weiXinPayPrice,zhiFuBaoPayPrice;
@synthesize isComissionCalc;
@synthesize totalcommissionRates;



//- (NSArray *)slaveID
//{
//    NSMutableArray *slaveIdArray = [NSMutableArray array];
//    NSMutableString *str = [NSMutableString string];
//    if (self.slaveArray.count) {
//        for (UserDoc *user in self.slaveArray) {
//            [slaveIdArray addObject:@(user.user_Id)];
//        }
//        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
//        [str appendString:[NSString stringWithFormat:@"[%@]", tmpIds]];
//    } else {
//        [str appendString:@""];
//    }
//    return slaveIdArray;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChangedPay:) name:UITextFieldTextDidChangeNotification object: nil];
    
    if (makeStateComplete == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
    }
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
    NSLog(@"the PayInfoVIewControll dealloc");
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    if (_addPayInfoOperation && [_addPayInfoOperation isExecuting]) {
        [_addPayInfoOperation cancel];
    }
    
    _addPayInfoOperation = nil;
    
    if (_getEcardMoneyOperation && [_getEcardMoneyOperation isExecuting]) {
        [_getEcardMoneyOperation cancel];
    }
    
    _getEcardMoneyOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.averageFlag = 1;
    self.averageNum = 1;
    //self.branchProfitRate = 100;
    self.baseEditing = YES;
    isComissionCalc = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_isComissionCalc"];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"结账"];
    [self.view addSubview:navigationView];
    
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView  = nil;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 70.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 74.0f);
    }
    _initialTVHeight = myTableView.frame.size.height;
    
    if (orderNumbers>1) {
        FooterView * footerView =[[FooterView alloc] initWithTarget:self submitImg:[ColorImage blueBackgroudImage] submitTitle:@"确    定" submitAction:@selector(submitInfoByJson)];
        [footerView showInTableView:myTableView];
    }else
    {
        FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"确    定" submitAction:@selector(submitInfoByJson) deleteTitle:@"上一步" deleteAction:@selector(goBackView)];
        [footerView.deleteButton setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
        [footerView showInTableView:myTableView];
    }
    
    [self initData];
    
    [self getPaymentInfoByJson];
}

-(void)dismissKeyBoard
{
    [self.view endEditing:YES];
}

-(void)initData
{
    payDoc = [[PayDoc alloc] init];
    orderDoc = [[OrderDoc alloc] init];
    
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    userDoc.user_SelectedState = YES;
    
    //    self.slaveNames = [NSMutableString string];
    self.slaveID = [NSMutableString string];
    self.salesDoc = [[UserDoc alloc] init];
    
    self.slaveArray = [NSMutableArray array];
    self.SalesConsultantRateArray = [NSMutableArray array];
    chooseCardMuArr = [[NSMutableArray alloc] init];
    choosePaymentMuArr = [[NSMutableArray alloc] init];
    cardMoneyArr = [[NSMutableArray alloc] init];
    
    if (orderNumbers >1) {
        choosePaymentType = NO;
    }else choosePaymentType = YES;
    
    self.sectionIsShow = NO;
    
    [[PermissionDoc sharePermission] setRule_IsAccountPayEcard:NO];
    
    totalcommissionRates=0;
    thisPayPrice = 0.0f;
    
    /**
     *现分七种支付方式:1、储值卡支付的方式，2、使用积分，3、使用现金券，4、使用现金，5、使用银行卡，6、其它，7、微信  8、支付宝
     *支付方式数组初始化为0，选中哪种支付方式对应的设置为1
     */
    for (int i=0; i<10; i++) {
        [choosePaymentMuArr addObject:@"0"];
    }
}

-(void)goBackView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 组装Slavers
-(NSMutableArray *)gettingSlavers
{
    NSMutableArray *tempsArrs = [NSMutableArray array];
    if(self.isComissionCalc.boolValue)
    {
        if (self.slaveArray.count >0) {
            for (int i = 0; i < self.slaveArray.count ; i ++) {
                UserDoc *user = self.slaveArray[i];
                if (user.user_ProfitPct == nil) {
                    user.user_ProfitPct = @"0";
                }
                NSLog(@"user.user_ProfitPct == %@ user_Id == %ld",user.user_ProfitPct,(long)user.user_Id);
                NSDictionary *dic;
                if(self.averageFlag == 1){
                    dic = @{@"SlaveID":@(user.user_Id),@"ProfitPct":@((0))};
                }else{
                    dic = @{@"SlaveID":@(user.user_Id),@"ProfitPct":@((user.user_ProfitPct.doubleValue / 100))};
                }
                
                [tempsArrs addObject:dic];
            }
        }
        return tempsArrs;
    }
    else
    {
        return tempsArrs;
    }
}

#pragma mark - 组装SalesConsultantRate
-(NSMutableArray *)gettingSalesConsultantRates
{
    NSMutableArray *tempsArrs = [NSMutableArray array];
    if (self.SalesConsultantRateArray.count >0) {
        for (int i = 0; i < self.SalesConsultantRateArray.count ; i ++) {
            UserDoc *user = self.SalesConsultantRateArray[i];
            if (user.user_commissionRate == nil) {
                user.user_commissionRate = @"0";
            }
            NSLog(@"user.user_commissionRate == %@ user_Id == %ld",user.user_commissionRate,(long)user.user_Id);
            NSString *userName =user.user_Name;
            NSDictionary *dic;
            dic = @{@"SalesConsultantID":@(user.user_Id),@"SalesConsultantName":userName,@"commissionRate":@((user.user_commissionRate.doubleValue / 100))};
            [tempsArrs addObject:dic];
        }
    }
    return tempsArrs;
}

#pragma mark - 支付相关
/**确定支付判断*/

- (void)submitInfoByJson
{
    [self.view endEditing:YES];
    
    const double d = 0.01;
    
    if (thisPayPrice == 0) {
        [SVProgressHUD showSuccessWithStatus2:@"请输入支付金额" touchEventHandle:^{}];
        return;
    }
    if (thisPayPrice - orderDoc.order_UnPaidPrice >= d) {
        [SVProgressHUD showErrorWithStatus2:@"付款金额大于应付款金额！" touchEventHandle:^{
            
        }];
        return;
    }else if( thisPayPrice < 0 )
    {
        [SVProgressHUD showSuccessWithStatus2:@"输入金额不合法,请重新输入。" touchEventHandle:^{}];
        return;
    }
    if ( !(thisPayPrice - orderDoc.order_UnPaidPrice > -d && thisPayPrice - orderDoc.order_UnPaidPrice < d)){//多订单支付时的判断
        if (![[PermissionDoc sharePermission] rule_Part_Pay]) {//有部分付的权限
            [SVProgressHUD showErrorWithStatus2:@"支付金额与ß应付金额不一致" touchEventHandle:^{
                
            }];
            return;
            
        }
    }
    
    NSString *alterMessage = [NSString string];
    if(self.slaveArray.count == 0)
    {
        alterMessage = @"本次支付的业绩参与人为空,是否继续进行支付?";
    }
    else
    {
        alterMessage = @"业绩参与比例≠100%， 是否继续？";
    }
    
    
    if ([self needProfitRateAlter]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alterMessage
                                                           delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                if ([[choosePaymentMuArr objectAtIndex:8] integerValue] || [[choosePaymentMuArr objectAtIndex:9] integerValue]) {
                    /* 进入第三方支付页*/
                    [self goToPayThirdForWeiXin];
                }else{
                    [self makePaymentInfoJsonString];
                }
            }
        }];
        
    } else {
        
        if ([[choosePaymentMuArr objectAtIndex:8] integerValue] || [[choosePaymentMuArr objectAtIndex:9] integerValue]) {
            /* 进入第三方支付页*/
            [self goToPayThirdForWeiXin];
        }else{
            [self makePaymentInfoJsonString];
        }
    }
}

//检查是否需要提示框
-(BOOL)needProfitRateAlter
{
    double rate=0;
    
    //不显示提成比例时不提示
    if(!self.isComissionCalc.boolValue)
    {
        return NO;
    }
    
    if(self.slaveArray.count == 0)
    {
        return YES;
    }
    else
    {
        //业绩参与不均分
        if(self.averageFlag == 0)
        {
            
            for (UserDoc *user in self.slaveArray) {
                rate += [user.user_ProfitPct doubleValue];
            }
            
            if(rate !=100)
            {
                return YES;
            }
            else
            {
                return  NO;
                
            }
            
        }
        else
        {
            return  NO;
        }
    }
}

-(void)goToPayThirdForWeiXin
{
    if (thisPayPrice != orderDoc.order_UnPaidPrice) {
        [SVProgressHUD showErrorWithStatus2:@"支付金额必须和订单金额一致！" touchEventHandle:^{
            
        }];
        return;
    }
    //构造order ID string eg: 110,111,112...
    NSMutableArray *orderIdJsonArr = [[NSMutableArray alloc] init];
    for (OrderDoc *order in paymentOrderArray) {
        if([order isEqual:[paymentOrderArray lastObject]])
            
            [orderIdJsonArr addObject:@((long)order.order_ID)];
        else
            [orderIdJsonArr addObject:@((long)order.order_ID)];
    }
    
    NSDictionary * par = @{
                           @"CustomerID":@((long)customerId),
                           @"AverageFlag":@(self.averageFlag),
                           //@"BranchProfitRate":self.branchProfitRate,
                           @"OrderID":orderIdJsonArr,
                           @"Slavers":[self gettingSlavers],
                           //@"SalesConsultantRates":[self gettingSalesConsultantRates],
                           @"TotalAmount":@((double)thisPayPrice),
                           @"PointAmount":@((double)sendIntergral),
                           @"CouponAmount":@((double)sendCashCoupon),
                           @"Remark":payDoc.Pay_Remark
                           };
    PayThirdForWeiXin_ViewController * payThird = [[PayThirdForWeiXin_ViewController alloc] init];
    payThird.thisPayPrice = thisPayPrice;
    payThird.para = par;
    if ([[choosePaymentMuArr objectAtIndex:8] integerValue]){
        payThird.payType = PayTypeWeiXin;
    }
    if ([[choosePaymentMuArr objectAtIndex:9] integerValue]){
        payThird.payType = PayTypeZhiFuBao;
    }
    payThird.orderComeFrom = comeFrom;
    [self.navigationController pushViewController:payThird animated:YES];
}

- (void)makePaymentInfoJsonString {
    
    //构造order ID string eg: 110,111,112...
    NSMutableArray *orderIdJsonArr = [[NSMutableArray alloc] init];
    for (OrderDoc *order in paymentOrderArray) {
        if([order isEqual:[paymentOrderArray lastObject]])
            
            [orderIdJsonArr addObject:@((long)order.order_ID)];
        else
            [orderIdJsonArr addObject:@((long)order.order_ID)];
    }
    
    NSMutableString *paymentJsonStr = [NSMutableString string];
    [paymentJsonStr appendString:@"["];
    if (cashMoney != 0) {
        // 现金
        [paymentJsonStr appendFormat:@"{\"PaymentMode\":%d,",0];
        [paymentJsonStr appendFormat:@"\"PaymentAmount\":%.2Lf},",cashMoney];
    }
    if (cardMoney != 0) {
        // 银行卡
        [paymentJsonStr appendFormat:@"{\"PaymentMode\":%d,",2];
        [paymentJsonStr appendFormat:@"\"PaymentAmount\":%.2Lf},",cardMoney];
    }
    
    if (ticketMoney != 0) {
        [paymentJsonStr appendFormat:@"{\"PaymentMode\":%d,",3];
        [paymentJsonStr appendFormat:@"\"PaymentAmount\":%.2Lf}",ticketMoney];
    }
    if (_loanMoney != 0) {
        [paymentJsonStr appendFormat:@"{\"PaymentMode\":%d,",100];
    }
    if (_thirdPartyMoney != 0) {
        [paymentJsonStr appendFormat:@"{\"PaymentMode\":%d,",101];
    }
    if([[paymentJsonStr substringFromIndex:paymentJsonStr.length -1] isEqual:@","])
        [paymentJsonStr deleteCharactersInRange:NSMakeRange(paymentJsonStr.length - 1, 1)];
    [paymentJsonStr appendString:@"]"];
    
    payDoc.OrderNumber = orderNumbers;
    payDoc.pay_TotalPrice =  thisPayPrice;//本次支付的总价格
    [self addEcardInfo:payDoc paymentJson:paymentJsonStr orderJson:orderIdJsonArr];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
            //            case 0: return 3;
        case 0:
        {
            //显示提成
            if(self.isComissionCalc.boolValue)
            {
                return 5 + self.SalesConsultantRateArray.count + self.slaveArray.count;
            }
            else
            {
                return  2;
            }
        }
        case 1: return 1;
        case 2: return 3;
        case 3: return ([[PermissionDoc sharePermission] rule_IsAccountPayEcard] && customerCardListMuArr.count)>0? customerCardListMuArr.count+1 :0; //--card
        case 4: return 3;//--积分现金券
        case 5: return 6;//--现金、银行卡、其它方式
        case 6://--第三方支付
        {
            if (RMO(@"|5|") && RMO(@"|6|"))
            {
                return 3;
            }else if(RMO(@"|5|") || RMO(@"|6|")) {
                return 2;
            }else{
                return 0;
            }
            //                if (RMO(@"|5|"))
            //                {
            ////                    return 2;
            //                    return 3;
            //                }
            //                    return 0;
        }
        case 7: return self.sectionIsShow ? 3:1;//--赠送积分、现金券
        case 8: return 2;//--备注
        default: return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [NSString stringWithFormat:@"payCell%ld%ld",(long)indexPath.section,(long)indexPath.row];
    PayEditCell *payCell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (payCell == nil) {
        payCell = [[PayEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }else
    {
        [payCell removeFromSuperview];
        payCell = [[PayEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    [payCell setDelegate:self];
    [payCell.contentText setDelegate:self];
    payCell.contentText.enabled = NO;
    
    NSString *string = [NSString stringWithFormat:@"editCell%ld",(long)indexPath.row];
    NormalEditCell *editCell = [tableView dequeueReusableCellWithIdentifier:string];
    if (!editCell) {
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    }else
    {
        [editCell removeFromSuperview];
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    }
    editCell.valueText.delegate = self;
    editCell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    [payCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [editCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"订单数量", [NSString stringWithFormat: @"%ld", (long)orderNumbers]]];
        }else if (indexPath.row == 1){
            return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"总计",  [NSString stringWithFormat: @"%@ %.2Lf", MoneyIcon, orderDoc.order_calcPrice]]];
        }
        else if (indexPath.row == 2){
            return [self configBranchSalesConsultantCell:tableView indexPath:indexPath];
        }
        else if (self.SalesConsultantRateArray.count >0 && indexPath.row >2 &&  indexPath.row <= 2 + self.SalesConsultantRateArray.count){
            return [self configBranchSalesConsultantRateCell:tableView indexPath:indexPath];
        }
        else if (indexPath.row == 3 + self.SalesConsultantRateArray.count){
            return [self configBranchPofitRateCell:tableView indexPath:indexPath];
        }
        else if (indexPath.row == 4 + self.SalesConsultantRateArray.count){
            return [self configPerformanceCell:tableView];
        }else{
            return [self configPerformanceProportionCell:tableView indexPath:indexPath];
        }
    } else if(indexPath.section == 1) {
        return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"会员价", [NSString stringWithFormat: @"%@ %.2Lf", MoneyIcon,orderDoc.order_calcPrice]]];
    } else if(indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"应付款", [NSString stringWithFormat: @"%@ %.2Lf", MoneyIcon,orderDoc.order_UnPaidPrice]]];
            }break;
            case 1:
            {
                NSString *valueStr = [NSString stringWithFormat: @"%@ %.2Lf", MoneyIcon,thisPayPrice];
                return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"本次支付", valueStr]];
            }
            case 2:
            {
                NSString *valueStr =  [self convertByPayTotal:thisPayPrice];
                return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"大写", valueStr]];
            }
        }
    }else if(indexPath.section == 3)
    {
        
        UIButton * choosePaymentBt;
        if(indexPath.row ==0)
        {
            if ([[choosePaymentMuArr objectAtIndex:0] integerValue]) {
                choosePaymentBt.selected = YES;
            }
            payCell.titleNameLabel.text = @"储值卡支付";
            payCell.contentText.text = @"余额";
            payCell.payButton.hidden = YES;
        }else
        {
            payCell.titleNameLabel.frame = CGRectMake(30.0f, 0.0f, 150.0f, kTableView_HeightOfRow);
            UIButton * chooseCardBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [chooseCardBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
            [chooseCardBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
            chooseCardBt.selected = NO;
            chooseCardBt.tag = indexPath.row-1;
            [chooseCardBt addTarget:self action:@selector(chooseCard:) forControlEvents:UIControlEventTouchUpInside];
            [payCell.contentView addSubview:chooseCardBt];
            
            if ([[chooseCardMuArr objectAtIndex:indexPath.row-1] integerValue ]== 1) {
                chooseCardBt.selected = YES;
                payCell.contentText.enabled = YES;
            }
            payCell.titleNameLabel.text = [NSString stringWithFormat:@"%@",[[customerCardListMuArr objectAtIndex:indexPath.row-1] objectForKey:@"CardName"]];
            payCell.contentText.text =  [[cardMoneyArr objectAtIndex:indexPath.row-1] doubleValue] == 0.0f ? @"" : [NSString stringWithFormat:@"%.2f", [[cardMoneyArr objectAtIndex:indexPath.row-1] doubleValue]];
            payCell.tag = 500+indexPath.row-1;
        }
        return payCell;
    }
    else if (indexPath.section ==4)//--用积分或者现金券
    {
        
        TwoTextFieldCell * cellText = [self configTwoTextFeildTableViewCell:tableView indexPath:indexPath];
        cellText.titleNameLabel.frame = CGRectMake(30.0f, 0.0f, 120.0f, kTableView_HeightOfRow);
        
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = indexPath.row;
        [choosePaymentBt addTarget:self action:@selector(choosePayment:) forControlEvents:UIControlEventTouchUpInside];
        [cellText addSubview:choosePaymentBt];
        
        if ([[choosePaymentMuArr objectAtIndex:indexPath.row] integerValue]== 1 ) {
            choosePaymentBt.selected = YES;
            cellText.payTextField.enabled = YES;
        }else
            choosePaymentBt.selected = NO;
        
        switch (indexPath.row) {
            case 0:
            {
                editCell.titleLabel.text = @"积分现金券支付";
                editCell.valueText.text = @"余额";
                editCell.valueText.userInteractionEnabled = NO;
                return editCell;
            }
                break;
            case 1:
            {
                cellText.titleNameLabel.text = @"积分";
                cellText.payTextField.text = payIntergral ==0.0f? @"": [NSString stringWithFormat:@"%.2Lf",payIntergral];
                cellText.payTextField.tag = 660;
                cellText.lable.text = @"抵";
                
                cellText.contentText.tag = 661;
                cellText.contentText.text = payIntergral == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",intergralToMoney];
                cellText.tag = 600;
                
                if ([[choosePaymentMuArr objectAtIndex: 1] integerValue]== 1 ) {
                    cellText.payTextField.enabled = YES;
                }else choosePaymentBt.selected = NO;
            }
                break;
            case 2:
            {
                cellText.titleNameLabel.text = @"现金券";
                cellText.payTextField.text = payCashCoupon ==0.0f? @"":[NSString stringWithFormat:@"%.2Lf",payCashCoupon];
                cellText.payTextField.tag = 662;
                cellText.contentText.tag = 663;
                
                cellText.contentText.text = payCashCoupon == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",cashCouponToMoney];
                cellText.tag = 601;
                cellText.lable.text = @"抵";
                
                if ([[choosePaymentMuArr objectAtIndex:2] integerValue]== 1 ) {
                    cellText.payTextField.enabled = YES;
                }
            }
                break;
            default:
                break;
        }
        return cellText;
    }
    else if (indexPath.section == 5){
        
        payCell.titleNameLabel.frame = CGRectMake(30.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = indexPath.row+2;
        [choosePaymentBt addTarget:self action:@selector(choosePayment:) forControlEvents:UIControlEventTouchUpInside];
        [payCell.contentView addSubview:choosePaymentBt];
        
        if ([[choosePaymentMuArr objectAtIndex:indexPath.row+2] integerValue]== 1 ) {
            choosePaymentBt.selected = YES;
            payCell.contentText.enabled = YES;
        }else
            choosePaymentBt.selected = NO;
        
        payCell.titleNameLabel.frame = CGRectMake(30.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        switch (indexPath.row) {
            case 0:
                editCell.titleLabel.text = @"现金，银行卡，其它支付";
                editCell.valueText.userInteractionEnabled = NO;
                return editCell;
                break;
            case 1:
                payCell.tag = 1000;
                payCell.titleNameLabel.text = @"现金";
                payCell.contentText.text = cashMoney == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", cashMoney];
                break;
            case 2:
                payCell.tag = 1001;
                payCell.titleNameLabel.text = @"银行卡";
                payCell.contentText.text = cardMoney == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", cardMoney];
                break;
            case 3:
                payCell.tag = 1003;
                payCell.titleNameLabel.text = @"其他";
                payCell.contentText.text = ticketMoney == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", ticketMoney];
                break;
            case 4:
                payCell.tag = 1004;
                payCell.titleNameLabel.text = @"消费贷款";
                payCell.contentText.text = _loanMoney == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", _loanMoney];
                break;
            case 5:
                payCell.tag = 1005;
                payCell.titleNameLabel.text = @"第三方付款";
                payCell.contentText.text = _thirdPartyMoney == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", _thirdPartyMoney];
                break;
            default:
                break;
        }
        return payCell;
        
    }
    else if (indexPath.section == 6)//--第三方支付方式选择
    {
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        //        choosePaymentBt.tag = 5+indexPath.row;
        [choosePaymentBt addTarget:self action:@selector(chooseThirdPartPayment:) forControlEvents:UIControlEventTouchUpInside];
        [payCell.contentView addSubview:choosePaymentBt];
        
        
        //        if (RMO(@"|5|") && RMO(@"|6|")){
        //            choosePaymentBt.tag = 5+indexPath.row;
        //            if ([[choosePaymentMuArr objectAtIndex:5+indexPath.row] integerValue]== 1 ) {
        //                choosePaymentBt.selected = YES;
        //                payCell.contentText.enabled = YES;
        //            }else
        //                choosePaymentBt.selected = NO;
        //        }else if(RMO(@"|5|")) {
        //            choosePaymentBt.tag = 6;
        //            if ([[choosePaymentMuArr objectAtIndex:6] integerValue]== 1 ) {
        //                choosePaymentBt.selected = YES;
        //                payCell.contentText.enabled = YES;
        //            }else if(RMO(@"|6|")) {
        //                choosePaymentBt.tag = 7;
        //                if ([[choosePaymentMuArr objectAtIndex:7] integerValue]== 1 ) {
        //                    choosePaymentBt.selected = YES;
        //                    payCell.contentText.enabled = YES;
        //                }else
        //                    choosePaymentBt.selected = NO;
        //            }
        //        }
        if (RMO(@"|5|") && RMO(@"|6|")){
            choosePaymentBt.tag = 7+indexPath.row;
            if ([[choosePaymentMuArr objectAtIndex:7+indexPath.row] integerValue]== 1 ) {
                choosePaymentBt.selected = YES;
                payCell.contentText.enabled = YES;
            }else
                choosePaymentBt.selected = NO;
        }else if(RMO(@"|5|")) {
            choosePaymentBt.tag = 8;
            if ([[choosePaymentMuArr objectAtIndex:8] integerValue]== 1 ) {
                choosePaymentBt.selected = YES;
                payCell.contentText.enabled = YES;
            }else
                choosePaymentBt.selected = NO;
        }else if(RMO(@"|6|")) {
            choosePaymentBt.tag = 9;
            if ([[choosePaymentMuArr objectAtIndex:9] integerValue]== 1 ) {
                choosePaymentBt.selected = YES;
                payCell.contentText.enabled = YES;
            }else
                choosePaymentBt.selected = NO;
        }
        
        //
        //        if ([[choosePaymentMuArr objectAtIndex:5+indexPath.row] integerValue]== 1 ) {
        //            choosePaymentBt.selected = YES;
        //            payCell.contentText.enabled = YES;
        //        }else
        //            choosePaymentBt.selected = NO;
        
        payCell.titleNameLabel.frame = CGRectMake(30.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        
        switch (indexPath.row) {
            case 0:
                editCell.titleLabel.text = @"第三方支付";
                editCell.valueText.userInteractionEnabled = NO;
                return editCell;
                break;
            case 1:
                if(RMO(@"|5|")) {
                    payCell.tag = 1011;
                    payCell.titleNameLabel.text = @"微信";
                    payCell.contentText.text = weiXinPayPrice == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", weiXinPayPrice];
                }else if(RMO(@"|6|")){
                    payCell.tag = 1012;
                    payCell.titleNameLabel.text = @"支付宝";
                    payCell.contentText.text = zhiFuBaoPayPrice == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", zhiFuBaoPayPrice];
                }
                //                payCell.tag = 1011;
                //                payCell.titleNameLabel.text = @"微信";
                //                payCell.contentText.text = weiXinPayPrice == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", weiXinPayPrice];
                break;
            case 2:
                payCell.tag = 1012;
                payCell.titleNameLabel.text = @"支付宝";
                payCell.contentText.text = zhiFuBaoPayPrice == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", zhiFuBaoPayPrice];
                break;
            default:
                break;
        }
        return payCell;
    }
    else if(indexPath.section == 7)//--赠送积分现金券
    {
        switch (indexPath.row) {
            case 0:
            {
                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                if (self.sectionIsShow) {
                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
                }else
                {
                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                }
                selectImageView.tag = 3004;
                [editCell.contentView addSubview:selectImageView];
                
                editCell.valueText.userInteractionEnabled = NO;
                editCell.titleLabel.text = @"赠送";
            }
                break;
            case 1:
                editCell.titleLabel.text = @"积分";
                editCell.valueText.text = sendIntergral ==0.0f? @"": [NSString stringWithFormat:@"%.2Lf",sendIntergral];
                editCell.valueText.placeholder = @"0.00";
                editCell.tag = 602;
                break;
            case 2:
                editCell.titleLabel.text = @"现金券";
                editCell.valueText.text = sendCashCoupon ==0.0f? @"":[NSString stringWithFormat:@"%.2Lf",sendCashCoupon];
                editCell.valueText.placeholder = @"0.00";
                editCell.tag = 603;
                break;
                
            default:
                break;
        }
        return editCell;
    }else if (indexPath.section == 8) {
        switch (indexPath.row) {
            case 0:
                return [self configTableViewCell:tableView indexPath:indexPath objects:@[@"备注",@""]];
            case 1:
            {
                NSString *cellIdentity = @"Remark";
                ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
                if (cell == nil)
                    cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                cell.contentEditText.placeholder = @"请输入备注...";
                cell.contentEditText.returnKeyType = UIReturnKeyDefault;
                cell.contentEditText.textColor = kColor_Editable;
                cell.contentEditText.tag = 1004;
                cell.delegate = self;
                return cell;
            }
        }
    }
    
    return nil ;
}

#pragma mark -  配置Cell

- (UITableViewCell *)configTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath objects:(NSArray *)objects
{
    NSString *cellIdentifier = @"twoLabelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:101];
    titleLable.frame = CGRectMake(5, 0, 140, kTableView_HeightOfRow);
    valueLabel.frame = CGRectMake(145, 0, 160, kTableView_HeightOfRow);
    [titleLable setFont:kFont_Light_16];
    [valueLabel setFont:kFont_Light_16];
    [titleLable setTextColor:kColor_DarkBlue];
    [valueLabel setTextColor:[UIColor blackColor]];
    [valueLabel setTextAlignment:NSTextAlignmentRight];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        valueLabel.textColor = [UIColor redColor];
    } else {
        valueLabel.textColor = [UIColor blackColor];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([objects count] != 2)
        return cell;
    else {
        titleLable.text = [objects objectAtIndex:0];
        valueLabel.text = [objects objectAtIndex:1];
        return cell;
    }
}

- (TwoTextFieldCell *)configTwoTextFeildTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *string = [NSString stringWithFormat:@"twotextfeild%ld%ld",(long)indexPath.row,(long)indexPath.section];
    TwoTextFieldCell *cellText = [tableView dequeueReusableCellWithIdentifier:string];
    if (!cellText) {
        cellText = [[TwoTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
        
    }else
    {
        [cellText removeFromSuperview];
        cellText = [[TwoTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string];
    }
    cellText.contentText.delegate = self;
    cellText.payTextField.delegate = self;
    cellText.contentText.enabled = NO;
    cellText.payTextField.enabled = NO;
    cellText.selectionStyle = UITableViewCellSelectionStyleNone;
    //
    //    UIButton * button1 = (UIButton *)[cellText.contentView viewWithTag:indexPath.row];
    //    [button1 removeFromSuperview];
    //
    return cellText;
}

//业绩参与
- (UITableViewCell *)configPerformanceCell:(UITableView *)tableView {
    NSString *cellindity = @"performance";
    TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTitle: @"业绩参与"];
    }
    //    [cell setValue:([self.slaveNames isEqualToString:@""] ? @"请选择业绩参与者": self.slaveNames) isEditing:NO];
    [cell setValue:@"请选择业绩参与者" isEditing:NO];
    cell.valueText.textColor = kColor_Editable;
    //均分按钮
    UIButton * averageButton;
    averageButton = [UIButton buttonTypeRoundedRectWithTitle:@"均分" target:self selector:@selector(chickAverageBtn) frame:CGRectMake(80.0f,(kTableView_HeightOfRow - 20.0f)/2,35.0f,20.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:5];
    [[cell contentView] addSubview:averageButton];
    return cell;
}
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    UserDoc *userdoc;
    if (self.slaveArray.count > 0) {
        userdoc = self.slaveArray[indexPath.row - 5 - self.SalesConsultantRateArray.count];
        performanceCell.nameLab.text = userdoc.user_Name;
        
        performanceCell.numText.hidden = NO;
        performanceCell.percentLab.hidden = NO;
        performanceCell.numText.enabled = YES;
        performanceCell.numText.keyboardType = UIKeyboardTypeDecimalPad;
        //选择业绩参与人前已经选择了均分 那么后面再选择的业绩参与人也是均分的
        if(self.averageFlag == 1){
            performanceCell.numText.text = @"均分";
            performanceCell.numText.enabled =NO;
            
        }else{
            performanceCell.numText.enabled =YES;
            performanceCell.numText.text = userdoc.user_ProfitPct;
        }
    }
    return performanceCell;
}
//分店业绩参与金额
- (PerformanceTableViewCell *)configBranchPofitRateCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"BranchPofitRateCell%@",indexPath];
    PerformanceTableViewCell *branchProfitRatecell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!branchProfitRatecell) {
        branchProfitRatecell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    branchProfitRatecell.delegate = self;
    branchProfitRatecell.nameLab.text = @"业绩参与金额";
    [branchProfitRatecell.nameLab setFont:kFont_Light_16];
    [branchProfitRatecell.nameLab setTextColor:kColor_DarkBlue];
    CGRect tempFrame = branchProfitRatecell.nameLab.frame;
    tempFrame.origin.x -=43;
    branchProfitRatecell.nameLab.frame = tempFrame;
    branchProfitRatecell.numText.hidden = NO;
    branchProfitRatecell.numText.enabled =NO;
    branchProfitRatecell.percentLab.hidden = YES;
    branchProfitRatecell.numText.text = self.branchProfitRate;
    return branchProfitRatecell;
}

//分店销售顾问提成
- (PerformanceTableViewCell *)configBranchSalesConsultantCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantCell%@",indexPath];
    PerformanceTableViewCell *branchSalesConsultantRateCell= [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!branchSalesConsultantRateCell) {
        branchSalesConsultantRateCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    branchSalesConsultantRateCell.delegate = self;
    branchSalesConsultantRateCell.nameLab.text = @"销售顾问提成比例";
    [branchSalesConsultantRateCell.nameLab setFont:kFont_Light_16];
    [branchSalesConsultantRateCell.nameLab setTextColor:kColor_DarkBlue];
    CGRect tempFrame = branchSalesConsultantRateCell.nameLab.frame;
    tempFrame.origin.x -=43;
    tempFrame.size.width =branchSalesConsultantRateCell.nameLab.frame.size.width+5;
    branchSalesConsultantRateCell.nameLab.frame = tempFrame;
    branchSalesConsultantRateCell.numText.hidden = YES;
    branchSalesConsultantRateCell.percentLab.hidden = YES;
    branchSalesConsultantRateCell.numText.enabled = NO;
    
    return branchSalesConsultantRateCell;
}

//分店销售顾问提成比例
- (PerformanceTableViewCell *)configBranchSalesConsultantRateCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    //
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantRateCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    UserDoc *userdoc;
    if (self.SalesConsultantRateArray.count > 0) {
        userdoc = self.SalesConsultantRateArray[indexPath.row - 3];
        performanceCell.nameLab.text = userdoc.user_Name;
        
        performanceCell.numText.hidden = NO;
        performanceCell.percentLab.hidden = NO;
        performanceCell.numText.enabled=NO;
        NSString *displayStr= userdoc.user_commissionRate;
        double displayNum = [displayStr doubleValue];
        userdoc.user_commissionRate =[NSString stringWithFormat:@"%.2f", displayNum];
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f", displayNum];
        
    }
    return performanceCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == (tableView.numberOfSections -1) && indexPath.row == 1){
        CGFloat height = payDoc.Pay_RemarkHeight;
        return kTableView_HeightOfRow > height ? kTableView_HeightOfRow : height;
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3 ) {
        if (![[PermissionDoc sharePermission] rule_IsAccountPayEcard] && customerCardListMuArr.count ==0) {
            return 0.1f;
        }
    }
    if (section == 6 && !RMO(@"|5|") && !RMO(@"|6|")) {
        return 0.1f;
    }
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==6 && !RMO(@"|5|")&& !RMO(@"|6|")) {
        return 0.1f;
    }
    if (section == 3 ) {
        if (![[PermissionDoc sharePermission] rule_IsAccountPayEcard] && customerCardListMuArr.count ==0) {
            return 0.1f;
        }
    }
    return kTableView_Margin_TOP;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0 && indexPath.row == ([tableView numberOfRowsInSection:0] - 1 - self.slaveArray.count)) {
        [self choosePerson];
    }/**查看余额*/
    else if (indexPath.section ==3 || indexPath.section ==4) {
        if (indexPath.row == 0) {
            [self checkCardBalance:indexPath.section];
        }
    }
    
    if (indexPath.section == 7) {
        self.sectionIsShow = !self.sectionIsShow;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)sectionIsShow:(UIButton *)sender
{
    self.sectionIsShow = !self.sectionIsShow;
    
    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - choosePaymenAndChooseCard

/**显示卡的余额*/
-(void)checkCardBalance:(NSInteger)chooseSection
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"账户余额" NumberOfRows:^NSInteger(NSInteger section) {
        return chooseSection == 4? 2:customerCardListMuArr.count;
        
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        NSString *ecardCell = [NSString stringWithFormat:@"ecardCell %@",indexPath];
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:ecardCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecardCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 130.0f, 40.0f)];
            label.tag = 100;
            label.textColor = kColor_DarkBlue;
            label.font = kFont_Light_16;
            [cell.contentView addSubview:label];
            
            UILabel *balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0f, 0.0f, 130.0f, 40.0f)];
            balanceLabel.tag = 101;
            balanceLabel.textAlignment = NSTextAlignmentRight;
            balanceLabel.textColor = kColor_SysBlue;
            balanceLabel.font = kFont_Light_16;
            
            [cell.contentView addSubview:balanceLabel];
            
            if (chooseSection ==4) {
                if (indexPath.row == 0) {
                    label.text = [NSString stringWithFormat:@"积分(%.2Lf)",_intergralPresentRate];
                    balanceLabel.text =[NSString stringWithFormat:@"%.2f",[[intergralCardDic objectForKey:@"Balance"] doubleValue]];
                }else
                {
                    label.text = [NSString stringWithFormat:@"现金券(%.2Lf)",_cashCouponPresentRate];
                    balanceLabel.text =[NSString stringWithFormat:@"%@ %.2f",MoneyIcon,[[cashCardDic objectForKey:@"Balance"]doubleValue]];
                }
            }else
            {
                label.text = [[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"CardName"];
                balanceLabel.text =[NSString stringWithFormat:@"%@ %.2f",MoneyIcon,[[[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"Balance"] doubleValue]];
            }
        }
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        
    } Completion:^{
        
    }];
    
    [alert show];
    
}

-(void)choosePayment:(UIButton *)sender
{
    /**
     *重置第三方支付数据
     *不管是单选还是双选，第三方支付方式都要重置
     */
    weiXinPayPrice = 0.0f;
    [choosePaymentMuArr replaceObjectAtIndex:8 withObject:@"0"];
    
    zhiFuBaoPayPrice = 0.0f;
    [choosePaymentMuArr replaceObjectAtIndex:9 withObject:@"0"];
    
    
    //多订单一起支付时单选，单订单支付可多选
    if (choosePaymentType) {//--多选
        if ([[choosePaymentMuArr objectAtIndex:sender.tag] integerValue]) {
            //--取消选择要把数据清除
            [choosePaymentMuArr replaceObjectAtIndex:sender.tag withObject:@"0"];
            [self clear:sender.tag];
        }else
            [choosePaymentMuArr replaceObjectAtIndex:sender.tag withObject:@"1"];
    }else//--单选
    {
        for (int i=0;i<chooseCardMuArr.count;i++) {//清除储存卡的数据
            [chooseCardMuArr replaceObjectAtIndex:i withObject:@"0"];
            [cardMoneyArr replaceObjectAtIndex:i withObject:@"0"];
        }
        for (int i=0; i<choosePaymentMuArr.count; i++) {
            if (i == sender.tag) {
                if ([[choosePaymentMuArr objectAtIndex:sender.tag] integerValue]) {
                    //取消选择要把数据清除
                    [choosePaymentMuArr replaceObjectAtIndex:sender.tag withObject:@"0"];
                    [self clear:sender.tag];
                }else
                    [choosePaymentMuArr replaceObjectAtIndex:sender.tag withObject:@"1"];
            }else
            {
                if ([[choosePaymentMuArr objectAtIndex:i] integerValue]) {
                    //取消选择要把数据清除
                    [self clear:i];
                }
                [choosePaymentMuArr replaceObjectAtIndex:i withObject:@"0"];
            }
        }
    }
    [self countThistPayMoney];
    [myTableView reloadData];
}

/** 取消选中按钮，清空对应的数据 */
-(void)clear:(NSInteger)index
{
    //--index 为取消选中的按钮tag
    switch (index) {
        case 1://--积分支付
            payIntergral = 0.0f;
            intergralToMoney = 0.0f;
            break;
        case 2://--现金券支付
            payCashCoupon = 0.0f;
            cashCouponToMoney = 0.0f;
            break;
        case 3://--现金支付
            cashMoney = 0.0f;
            break;
        case 4://--银行卡支付
            cardMoney = 0.0f;
            break;
        case 5://--其他支付
            ticketMoney = 0.0f;
            break;
        case 6://--消费贷款
            _loanMoney = 0.0f;
            break;
        case 7://--第三方支付
            _thirdPartyMoney = 0.0f;
            break;
            
        default:
            break;
    }
}

/** 选择储值卡支付*/
-(void)chooseCard:(UIButton *)sender
{
    /**
     *重置第三方支付数据
     *不管是单选还是双选，第三方支付方式都要重置
     */
    weiXinPayPrice = 0.0f;
    [choosePaymentMuArr replaceObjectAtIndex:8 withObject:@"0"];
    
    zhiFuBaoPayPrice =0.0f;
    [choosePaymentMuArr replaceObjectAtIndex:9 withObject:@"0"];
    
    
    if (choosePaymentType) {//多选
        if ([[chooseCardMuArr objectAtIndex:sender.tag] integerValue]) {
            //--取消选中
            [chooseCardMuArr replaceObjectAtIndex:sender.tag withObject:@"0"];
            [cardMoneyArr replaceObjectAtIndex:sender.tag withObject:@"0"];
            [self countThistPayMoney];
        }else
            [chooseCardMuArr replaceObjectAtIndex:sender.tag withObject:@"1"];
    }else//单选
    {
        cashMoney = 0.0f;
        cardMoney = 0.0f;
        ticketMoney = 0.0f;
        payIntergral = 0.0f;
        payCashCoupon = 0.0f;
        cashCouponToMoney = 0.0f;
        intergralToMoney = 0.0f;
        _loanMoney = 0.0f;
        _thirdPartyMoney = 0.0f;
        
        /** 清空支付方式数据*/
        for (int i=0;i<choosePaymentMuArr.count;i++) {
            [choosePaymentMuArr replaceObjectAtIndex:i withObject:@"0"];
        }
        
        for (int i=0; i<chooseCardMuArr.count; i++) {
            if (sender.tag == i) {
                if ([[chooseCardMuArr objectAtIndex:sender.tag] integerValue]) {//取消选中也要清空数据
                    [chooseCardMuArr replaceObjectAtIndex:sender.tag withObject:@"0"];
                    [cardMoneyArr replaceObjectAtIndex:sender.tag withObject:@"0"];
                }else
                {
                    [chooseCardMuArr replaceObjectAtIndex:sender.tag withObject:@"1"];
                }
            }
            else
            {
                [chooseCardMuArr replaceObjectAtIndex:i withObject:@"0"];
                [cardMoneyArr replaceObjectAtIndex:i withObject:@"0"];
            }
        }
        
        [self countThistPayMoney];
    }
    
    [myTableView reloadData];
    
}

/** 第三方支付方式选择*/
-(void)chooseThirdPartPayment:(UIButton *)sender
{
    /** 选择第三方支付方式，其它的支付方式及数据都重置*/
    
    /** 如果选中微信支付 设置状态为1*/
    int flag = 0 ;
    if ([[choosePaymentMuArr objectAtIndex:sender.tag] integerValue] == 0) {
        flag = 1;
        switch (sender.tag) {
            case 8:
            {
                zhiFuBaoPayPrice = 0.0f;
            }
                break;
            case 9:
            {
                weiXinPayPrice = 0.0f;
            }
                break;
                
            default:
                break;
        }
    }else{
        /** 取消选中，价格清零重新计算*/
        weiXinPayPrice = 0.0f;
        zhiFuBaoPayPrice = 0.0f;
    }
    
    /** 重置所有支付方式和价格*/
    [self clearPaymentPrice];
    
    if (flag) {
        
        [choosePaymentMuArr replaceObjectAtIndex:sender.tag withObject:@"1"];
    }
    
    [self countThistPayMoney];
    
    [myTableView reloadData];
}

/** 重新计算计算本次支付价格、和赠送的积分现金券*/
-(void)countThistPayMoney
{
    //----本次支付价格清零，重新计算本次支付总价格
    thisPayPrice = 0;
    
    for (int i=0; i<cardMoneyArr.count; i++) {
        thisPayPrice = thisPayPrice +[[cardMoneyArr objectAtIndex:i] doubleValue];
    }
    /** 选择第三方支付 */
    //微信支付
    if ([[choosePaymentMuArr objectAtIndex:8] integerValue]) {
        thisPayPrice = weiXinPayPrice;
    }else if ([[choosePaymentMuArr objectAtIndex:9] integerValue]) { //支付宝支付
        thisPayPrice = zhiFuBaoPayPrice;
    }else{
        thisPayPrice = thisPayPrice + cardMoney + cashMoney + ticketMoney +intergralToMoney+cashCouponToMoney+_loanMoney+_thirdPartyMoney;
    }
    //    if ([[choosePaymentMuArr objectAtIndex:6] integerValue]) {
    //        thisPayPrice = weiXinPayPrice;
    //        thisPayPrice = zhiFuBaoPayPrice;
    //    }else{
    //        thisPayPrice = thisPayPrice + cardMoney + cashMoney + ticketMoney +intergralToMoney+cashCouponToMoney;
    //    }
    thisPayPrice =  [OverallMethods notRounding:thisPayPrice afterPoint:2];
    double branchProfitRateNum=0;
    branchProfitRateNum =orderDoc.order_UnPaidPrice - intergralToMoney-cashCouponToMoney - (orderDoc.order_UnPaidPrice - intergralToMoney- cashCouponToMoney)* (totalcommissionRates/100);
    self.branchProfitRate = [NSString stringWithFormat:@"%.2f",branchProfitRateNum];
    //----默认赠送的现金券
    sendCashCoupon = fabsl((thisPayPrice -cashCouponToMoney-intergralToMoney)*self.cashCouponPresentRate);
    sendCashCoupon = [OverallMethods notRounding:sendCashCoupon afterPoint:2];
    
    //----默认赠送的积分
    sendIntergral = fabsl((thisPayPrice -cashCouponToMoney-intergralToMoney)*self.intergralPresentRate);
    sendIntergral = [OverallMethods notRounding:sendIntergral afterPoint:2];
}

/*
 * 选择均分按钮后  交替点击
 */
-(void)chickAverageBtn
{
    if(self.averageNum % 2 ==0){
        self.averageFlag = 1;
        if (self.slaveArray.count > 0) {
            NSString *displayPct = @"均分";
            if (slaveArray.count == 1) {
                displayPct = @"100";
            }
            for(UserDoc *user in slaveArray){
                user.user_ProfitPct = displayPct;
            }
        }
    }else{
        self.averageFlag = 0;
        if (self.slaveArray.count > 0) {
            for(UserDoc *user in slaveArray){
                user.user_ProfitPct = @"0";
            }
        }
    }
    [myTableView reloadData];
    self.averageNum ++;
}
#pragma mark - PayEditCellDelete
/**
 *选择全部支付按钮，选中栏位价格为应付款，其它支付方式的状态全部重置
 */
- (void)chickSelectionBtnWithCell:(UITableViewCell *)_cell
{
    [self.view endEditing:YES];
    
    PayEditCell *cell = (PayEditCell *)_cell;
    cell.contentText.text = [NSString stringWithFormat:@"%.2Lf", orderDoc.order_UnPaidPrice];
    
    //index 为取消选中的按钮tag
    
    /** 重置支付方式和价格*/
    [self clearPaymentPrice];
    weiXinPayPrice = 0.0f;
    zhiFuBaoPayPrice = 0.0f;
    /** 储值卡 */
    if (cell.tag >=500 && cell.tag<600) {
        int index = cell.tag %500;
        
        for (int i=0; i<cardMoneyArr.count; i++) {// 把选中的值设置为需要支付的价钱
            if (index ==i){
                [cardMoneyArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%Lf",orderDoc.order_UnPaidPrice]];
                [chooseCardMuArr replaceObjectAtIndex:i withObject:@"1"];
            }else
                [cardMoneyArr replaceObjectAtIndex:i withObject:@"0"];
        }
    }else
    {
        switch (cell.tag) {
            case 1000:
                cashMoney = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:3 withObject:@"1"];
                break;
            case 1001:
                cardMoney = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:4 withObject:@"1"];
                break;
            case 1003:
                ticketMoney = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:5 withObject:@"1"];
                break;
            case 1011:
                weiXinPayPrice = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:8 withObject:@"1"];
                break;
            case 1012:
                zhiFuBaoPayPrice = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:9 withObject:@"1"];
                break;
            case 1004:
                _loanMoney = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:6 withObject:@"1"];
                break;
            case 1005:
                _thirdPartyMoney = orderDoc.order_UnPaidPrice;
                [choosePaymentMuArr replaceObjectAtIndex:7 withObject:@"1"];
                break;
                
            default:
                break;
        }
    }
    
    [self countThistPayMoney];//获取本次支付价格
    
    [myTableView reloadData];
}

/**
 *重置支付方式和价格
 *不包含重置第三方支付价格，第三方支付价格需要单独清除
 */
-(void)clearPaymentPrice
{
    /**支付方式都清零*/
    for (int i= 0; i<choosePaymentMuArr.count; i++) {
        [choosePaymentMuArr replaceObjectAtIndex:i withObject:@"0"];
    }
    
    /**储蓄卡选中状态都清零*/
    for (int i=0; i< chooseCardMuArr.count; i++) {
        [chooseCardMuArr replaceObjectAtIndex:i withObject:@"0"];
    }
    /**把储蓄卡的价格都清零*/
    for (int i=0; i<cardMoneyArr.count; i++) {
        [cardMoneyArr replaceObjectAtIndex:i withObject:@"0"];
    }
    
    cashMoney = 0.0f;
    cardMoney = 0.0f;
    ticketMoney = 0.0f;
    payIntergral = 0.0f;
    payCashCoupon = 0.0f;
    intergralToMoney = 0.0f;
    cashCouponToMoney = 0.0f;
    _loanMoney = 0.0f;
    _thirdPartyMoney = 0.0f;
    
}

#pragma mark - 选择业绩参与者
- (void)choosePerson {
    
    [self.view endEditing:YES];
    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:1 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:self.slaveArray];
    selectCustomer.navigationTitle = @"选择业绩参与者";
    selectCustomer.delegate = self;
    selectCustomer.customerId = self.customerId;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
    
}

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    //初始化均分
    self.averageFlag = 1;
    self.averageNum = 1;
    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - ContentEditCellDelegate
#pragma mark 备注编辑文本处理
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    self.textField_Selected = nil;
    
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 300;
    textView.frame = rect;
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 300) {
                textView.text = [toBeString substringToIndex:300];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    payDoc.Pay_Remark = contentText.text;
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    
    NSIndexPath *indexRemark = [myTableView indexPathForCell:cell];
    
    payDoc.Pay_Remark = contentText.text;
    
    if (indexRemark.row == 1 ) {
        [myTableView beginUpdates];
        [myTableView endUpdates];
    }
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.myTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(300.0f, 500.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    if (textViewSize.width < 300) {
        textViewSize.width = 300;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
}

#pragma mark - UITextFieldDelegate
#pragma mark 支付金额及人数 输入处理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [myTableView indexPathForCell:cell];
    
    [myTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)updateTextfield:(UITextField *)textField
{
    PayEditCell *cell;
    if (IOS6 || IOS8) {
        cell = (PayEditCell *)textField.superview.superview;}
    else if (IOS7) {
        cell = (PayEditCell *)textField.superview.superview.superview;}
    
    if (cell.tag == 1000) cashMoney = [textField.text doubleValue];
    else if (cell.tag == 1001) cardMoney = [textField.text doubleValue];
    else if (cell.tag == 1003) ticketMoney = [textField.text doubleValue];
    else if (cell.tag == 1004) _loanMoney = [textField.text doubleValue];
    else if (cell.tag == 1005) _thirdPartyMoney = [textField.text doubleValue];
    else if (cell.tag == 1011) weiXinPayPrice = [textField.text doubleValue];
    else if (cell.tag == 1012) zhiFuBaoPayPrice = [textField.text doubleValue];
    else if (cell.tag == 600)
    {
        /**支付积分四舍五入*/
        payIntergral =[textField.text doubleValue];
        intergralToMoney = [OverallMethods notRounding:(payIntergral *self.intergralRate) afterPoint:2];
        
    }else if (cell.tag == 601)
    {
        /**支付现金券*/
        payCashCoupon =[textField.text doubleValue];
        cashCouponToMoney = [OverallMethods notRounding:(payCashCoupon *self.cashCouponRate) afterPoint:2];
        
    }else if(cell.tag == 602){
        /**赠送积分*/
        sendIntergral = [textField.text doubleValue];
    }
    else if(cell.tag == 603) {
        /**赠送现金券*/
        sendCashCoupon = [textField.text doubleValue];
    }
    else if (cell.tag >=500 && cell.tag < 600)
    {
        /**储值卡支付*/
        int index = cell.tag % 500;
        [cardMoneyArr replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%f",[textField.text doubleValue]]];
    }
    /**
     *刷新价格
     *当输入赠送现金券和积分时 不需要刷新本次支付价
     */
    if (cell.tag == 602 || cell.tag == 603) {
        
    }else
        [self countThistPayMoney];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self updateTextfield:textField];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    NSRange decRange = [textField.text rangeOfString:@"."];
    if (decRange.length && (textField.text.length - decRange.location > 2 || [string isEqualToString:@"."])) {
        return NO;
    }
    __block BOOL result = YES;
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [charSet addCharactersInString:@"."];
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring rangeOfCharacterFromSet:charSet].location == NSNotFound) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)textFiledEditChangedPay:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    if (textField.text.length > 10 && textField.markedTextRange == nil) {
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 10)];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (IOS6 || IOS8) {
        
        id cell = textField.superview.superview;
        if ([cell isKindOfClass:[PayEditCell class]]) {
            long  double tmp = [textField.text doubleValue];
            textField.text = (tmp == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", tmp]);
        }
    } else if (IOS7) {
        id cell = textField.superview.superview.superview;
        if ([cell isKindOfClass:[PayEditCell class]]) {
            long double tmp = [textField.text doubleValue];
            textField.text = (tmp == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", tmp]);
        }
    }
    
    [myTableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - PerformanceTableViewCellDelegate
- (void)PerformanceTableViewCellWithDidBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
}
-(void)PerformanceTableViewCellWithDidEndEditing:(UITextField *)textField
{
    PerformanceTableViewCell *cell;
    if (IOS7) {
        cell = (PerformanceTableViewCell *)textField.superview.superview.superview;
    }else{
        cell = (PerformanceTableViewCell *)textField.superview.superview;
    }
    NSIndexPath *indexPath = [myTableView indexPathForCell:cell];
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (indexPath.row > 0) {
        /*
         if(indexPath.row == 2){
         self.branchProfitRate = [textField.text doubleValue];
         }
         */
        if(indexPath.row < 3 + self.SalesConsultantRateArray.count){
            UserDoc *user = self.SalesConsultantRateArray[indexPath.row - 3];
            user.user_commissionRate =textField.text;
        }
        else{
            UserDoc *user =self.slaveArray[indexPath.row - 5 - SalesConsultantRateArray.count];
            user.user_ProfitPct = textField.text;
        }
    }
}

#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification {
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect tvFrame = myTableView.frame;
        tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
        myTableView.frame = tvFrame;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self scrollToTextField:self.textField_Selected];
    if(!self.textField_Selected){
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:[myTableView numberOfSections] - 1];
        [myTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = _initialTVHeight + 20.0f;
    myTableView.frame = tvFrame;
}

#pragma mark - 大小写转换

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
        case 0: return @"零"; break;
        case 1: return @"壹"; break;
        case 2: return @"贰"; break;
        case 3: return @"叁"; break;
        case 4: return @"肆"; break;
        case 5: return @"伍"; break;
        case 6: return @"陆"; break;
        case 7: return @"柒"; break;
        case 8: return @"捌"; break;
        case 9: return @"玖"; break;
        default:break;
    }
    return nil;
}


#pragma mark - 网络请求
/** 获取用户卡列表 */
-(void)requestCardList
{
    NSDictionary * dic = @{@"CustomerID":@((long)self.customerId)};
    
    _requestCustomerCardListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerCardList" andParameters:dic failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            customerCardListMuArr = [[NSMutableArray alloc] init];
            
            NSArray *arr = data;
            for (int i=0; i<arr.count; i++) {
                int nubmer = [[[arr objectAtIndex:i] objectForKey:@"CardTypeID"] intValue];
                if(nubmer ==1)//--会员卡
                {
                    [customerCardListMuArr addObject:[arr objectAtIndex:i]];
                    [chooseCardMuArr addObject:@"0"];
                    [cardMoneyArr addObject:@"0"];
                }else if(nubmer ==2)//--积分卡
                {
                    intergralCardDic = [arr objectAtIndex:i];
                    
                    self.intergralRate = 1.0;
                    if ([intergralCardDic objectForKey:@"Rate"] != [NSNull null]) {
                        self.intergralRate  = [[intergralCardDic objectForKey:@"Rate"]doubleValue];
                    }
                    if ([intergralCardDic objectForKey:@"PresentRate"] != [NSNull null]) {
                        self.intergralPresentRate  = [[intergralCardDic objectForKey:@"PresentRate"]doubleValue];
                    }
                }else if(nubmer ==3)//--现金券
                {
                    cashCardDic = [arr objectAtIndex:i];
                    
                    self.cashCouponRate = 1.0;
                    if ([cashCardDic objectForKey:@"Rate"] != [NSNull null]) {
                        self.cashCouponRate  = [[cashCardDic objectForKey:@"Rate"]doubleValue];
                    }
                    if ([cashCardDic objectForKey:@"PresentRate"] != [NSNull null]) {
                        self.cashCouponPresentRate  = [[cashCardDic objectForKey:@"PresentRate"]doubleValue];
                    }
                }
            }
            
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [myTableView reloadData];
        }];
    } failure:^(NSError *error) {
        [myTableView reloadData];
    }];
}

/** 获取订单支付详情*/
-(void)getPaymentInfoByJson{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    //--构造order ID list [1212,]
    NSMutableString *orderIdJsonStr = [NSMutableString string];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (OrderDoc *order in paymentOrderArray) {
        if([order isEqual:[paymentOrderArray lastObject]])
            [orderIdJsonStr appendFormat:@"%ld",(long)order.order_ID];
        else
            [orderIdJsonStr appendFormat:@"%ld,",(long)order.order_ID];
        
        NSDictionary * dic = @{
                               @"OrderID":@((long)order.order_ID),
                               @"OrderObjectID":@((long)order.order_ObjectID),
                               @"ProductType":@((long)order.order_ProductType)
                               };
        [arr addObject:dic];
    }
    NSDictionary * par = @{
                           @"CustomerID":@(self.customerId),
                           @"OrderList":arr
                           };
    _getPaymentInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/getPaymentInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            self.isPartPay = [[data objectForKey:@"IsPartPay"] boolValue];
            self.isEcardPay = [[data objectForKey:@"IsPay"] boolValue];
            
            orderDoc.order_totalPrice = [[data objectForKey:@"TotalOrigPrice"] doubleValue];
            orderDoc.order_calcPrice = [[data objectForKey:@"TotalCalcPrice"] doubleValue];//--账户会员价
            orderDoc.order_UnPaidPrice = [[data objectForKey:@"UnPaidPrice"] doubleValue];//--还需要支付的价格
            
            [[PermissionDoc sharePermission] setRule_IsAccountPayEcard:[[data objectForKey:@"IsPay"] boolValue]];
            [[PermissionDoc sharePermission] setRule_Part_Pay:[[data objectForKey:@"IsPartPay"] boolValue]];
            
            [self.slaveArray removeAllObjects];
            /*if (self.singleOrderSlaveArray) { //单订单 业绩参与人
                [self.slaveArray addObjectsFromArray:self.singleOrderSlaveArray];
            }else{
                NSArray *tempArr = [data objectForKey:@"SalesList"];
                if (![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                    for (NSDictionary * dic in [data objectForKey:@"SalesList"]) {
                        UserDoc * user = [[UserDoc alloc] init];
                        user.user_Name = [dic objectForKey:@"SalesName"];
                        user.user_Id = [[dic objectForKey:@"SalesPersonID"] integerValue];
                        [self.slaveArray addObject:user];
                    }
                }
            }*/
            
            [self.SalesConsultantRateArray removeAllObjects];
            NSArray *tempArr1 = [data objectForKey:@"SalesConsultantRates"];
            if (![tempArr1 isKindOfClass:[NSNull class]] && tempArr1.count > 0) {
                for (NSDictionary * dic in [data objectForKey:@"SalesConsultantRates"]) {
                    UserDoc * userRate = [[UserDoc alloc] init];
                    userRate.user_Name = [dic objectForKey:@"SalesConsultantName"];
                    userRate.user_Id = [[dic objectForKey:@"SalesConsultantID"] integerValue];
                    double commissionRateNum = [[dic objectForKey:@"commissionRate"] doubleValue] * 100;
                    totalcommissionRates +=commissionRateNum;
                    userRate.user_commissionRate =  [NSString stringWithFormat:@"%.2f",commissionRateNum];
                    [self.SalesConsultantRateArray addObject:userRate];
                }
            }
            
            //业绩参与金额= 应付款 - 积分 - 现金券 -(应付款-积分-现金券)*销售顾问提成比例
            double branchProfitRateNum=0;
            branchProfitRateNum =orderDoc.order_UnPaidPrice - intergralToMoney-cashCouponToMoney - (orderDoc.order_UnPaidPrice - intergralToMoney- cashCouponToMoney)* (totalcommissionRates/100);
            self.branchProfitRate = [NSString stringWithFormat:@"%.2f",branchProfitRateNum];
            
            [self requestCardList];
            
        } failure:^(NSInteger code, NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:(error.length ? error : @"获取支付信息失败，请重试！") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}
/** 支付 */
- (void)addEcardInfo:(PayDoc *)payDoc1 paymentJson:(NSString *)paymentJson orderJson:(NSMutableArray *)orderJson
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    if(!payDoc1.Pay_Remark)
        payDoc1.Pay_Remark = @"";
    NSDate *currentDate = [NSDate date];
    currentDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([currentDate timeIntervalSinceReferenceDate] + 8*3600)];
    
    NSMutableArray * paymentArr = [[NSMutableArray alloc] init];
    int selectPayType = 0;
    if ([[PermissionDoc sharePermission] rule_IsAccountPayEcard]) {
        
        for (int i=0; i<chooseCardMuArr.count; i++) {
            if ([[cardMoneyArr objectAtIndex:i] doubleValue]>0) {
                NSDictionary *dic = @{@"UserCardNo":[[customerCardListMuArr objectAtIndex:i] objectForKey:@"UserCardNo"],@"CardType":@1,@"PaymentMode":@1,@"PaymentAmount":@([[cardMoneyArr objectAtIndex:i] doubleValue])};
                [paymentArr addObject:dic];
            }
        }
        
        for (int i=0; i<choosePaymentMuArr.count; i++) {//判断选中的支付方式，选中的列入数组
            if ([[choosePaymentMuArr objectAtIndex:i] integerValue]) {//为1选中
                switch (i) {
                    case 3://--现金
                    {
                        if (cashMoney>0) {
                            NSDictionary *dic = @{@"PaymentMode":@0,@"PaymentAmount":@((double)cashMoney)};
                            [paymentArr addObject:dic];
                            selectPayType = 3;
                        }
                    }
                        break;
                    case 4://--银行卡
                    {
                        if (cardMoney>0) {
                            NSDictionary *dic = @{@"PaymentMode":@2,@"PaymentAmount":@((double)cardMoney)};
                            [paymentArr addObject:dic];
                            selectPayType = 4;
                        }
                    }
                        break;
                    case 5://--其他
                    {
                        if (ticketMoney>0) {
                            NSDictionary *dic = @{@"PaymentMode":@3,@"PaymentAmount":@((double)ticketMoney)};
                            [paymentArr addObject:dic];
                            selectPayType = 5;
                        }
                    }
                        break;
                    case 1://--积分
                    {
                        if (payIntergral>0) {
                            NSDictionary *dic = @{@"UserCardNo":[intergralCardDic objectForKey:@"UserCardNo"] ,@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((double)payIntergral)};
                            [paymentArr addObject:dic];
                            selectPayType = 1;
                        }
                    }
                        break;
                    case 2://--现金券
                    {
                        if (payCashCoupon>0) {
                            NSDictionary *dic = @{@"UserCardNo":[cashCardDic objectForKey:@"UserCardNo"] ,@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((double)payCashCoupon)};
                            [paymentArr addObject:dic];
                            selectPayType = 2;
                        }
                    }
                        break;
                    case 6://--消费贷款
                    {
                        if (_loanMoney>0) {
                            NSDictionary *dic = @{@"PaymentMode":@100,@"PaymentAmount":@((double)_loanMoney)};
                            [paymentArr addObject:dic];
                            selectPayType = 6;
                        }
                    }
                        break;
                    case 7://--第三方付款
                    {
                        if (_thirdPartyMoney>0) {
                            NSDictionary *dic = @{@"PaymentMode":@101,@"PaymentAmount":@((double)_thirdPartyMoney)};
                            [paymentArr addObject:dic];
                            selectPayType = 7;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }else//--不用卡支付
    {
        if (cashMoney>0) {
            NSDictionary *dic = @{@"PaymentMode":@0,@"PaymentAmount":@((double)cashMoney)};
            [paymentArr addObject:dic];
        }
        if (cardMoney>0) {
            NSDictionary *dic = @{@"PaymentMode":@2,@"PaymentAmount":@((double)cardMoney)};
            [paymentArr addObject:dic];
        }
        if (ticketMoney>0) {
            NSDictionary *dic = @{@"PaymentMode":@3,@"PaymentAmount":@((double)ticketMoney)};
            [paymentArr addObject:dic];
        }
        if (_loanMoney>0) {
            NSDictionary *dic = @{@"PaymentMode":@100,@"PaymentAmount":@((double)_loanMoney)};
            [paymentArr addObject:dic];
        }
        if (_thirdPartyMoney>0) {
            NSDictionary *dic = @{@"PaymentMode":@101,@"PaymentAmount":@((double)_thirdPartyMoney)};
            [paymentArr addObject:dic];
        }
    }
    
    NSMutableArray * giveArr = [[NSMutableArray alloc] init];
    if (sendCashCoupon >0) {
        NSDictionary *dicSend = @{@"UserCardNo":[cashCardDic objectForKey:@"UserCardNo"],@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((double)sendCashCoupon)};
        [giveArr addObject:dicSend];
    }
    if (sendIntergral >0) {
        NSDictionary *dicSend = @{@"UserCardNo":[intergralCardDic objectForKey:@"UserCardNo"],@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((double)sendIntergral)};
        [giveArr addObject:dicSend];
    }
    //    NSDictionary * par = @{
    //                           @"OrderCount":@((long)payDoc1.OrderNumber),
    //                           @"TotalPrice": @(payDoc1.pay_TotalPrice),
    //                           @"Remark":payDoc1.Pay_Remark,
    //                           @"CustomerID":@((long)customerId),
    //                           @"SlaveID":self.slaveID,
    //
    //                           @"OrderIDList":orderJson,
    //                           @"PaymentDetailList":paymentArr,
    //                           @"GiveDetailList":giveArr
    //                           };
    NSDictionary * par = @{
                           @"OrderCount":@((long)payDoc1.OrderNumber),
                           @"TotalPrice":[NSString stringWithFormat:@"%.2Lf",payDoc1.pay_TotalPrice],
                           @"Remark":payDoc1.Pay_Remark,
                           @"CustomerID":@((long)customerId),
                           @"AverageFlag":@(self.averageFlag),
                           //@"BranchProfitRate":self.branchProfitRate,
                           @"Slavers":[self gettingSlavers],
                           //@"SalesConsultantRates":[self gettingSalesConsultantRates],
                           @"OrderIDList":orderJson,
                           @"PaymentDetailList":paymentArr,
                           @"GiveDetailList":giveArr
                           };
    
    //订单合并支付修正
    NSMutableArray *parArr = [[NSMutableArray alloc]init];
    
    if(paymentOrderArray.count > 1){
        
        for(int i=0;i<paymentOrderArray.count;i++){
            NSDictionary * par1 = [[NSDictionary alloc] init];
            NSMutableArray *orderIdJsonArr = [[NSMutableArray alloc] init];
            OrderDoc *od = paymentOrderArray[i];
            [orderIdJsonArr addObject:@((long)od.order_ID)];
            ProductAndPriceDoc *ppd = od.productAndPriceDoc;
            ProductDoc *pd = ppd.productDoc;
            NSMutableArray *paymentArrAdds = [[NSMutableArray alloc]init];
            paymentArrAdds = [par objectForKey:@"PaymentDetailList"];
            NSMutableArray *giveArrAdds = [[NSMutableArray alloc]init];
            giveArrAdds = [par objectForKey:@"GiveDetailList"];
            NSMutableArray *paymentArrModel = [[NSMutableArray alloc]init];
            NSMutableArray *giveArrModel = [[NSMutableArray alloc]init];
            //重新修正paymentArr
            for(int j=0;j<paymentArrAdds.count;j++){
                NSDictionary *itemPayment = [paymentArrAdds objectAtIndex:j];
                NSMutableDictionary *paymentModel = [[NSMutableDictionary alloc]init];
                [paymentModel setObject:@((double)pd.pro_UnPaidPrice) forKey:@"PaymentAmount"];
                [paymentModel setObject:@([[itemPayment objectForKey:@"PaymentMode"] integerValue]) forKey:@"PaymentMode"];
                if([itemPayment objectForKey:@"CardType"] !=nil){
                    [paymentModel setObject:@([[itemPayment objectForKey:@"CardType"] integerValue]) forKey:@"CardType"];
                }
                if([itemPayment objectForKey:@"UserCardNo"] !=nil){
                    [paymentModel setObject:[itemPayment objectForKey:@"UserCardNo"] forKey:@"UserCardNo"];
                }
                [paymentArrModel addObject:paymentModel];
            }
            //重新修正giveArr
            for(int k=0;k<giveArrAdds.count;k++){
                NSDictionary *giveModel = [[NSDictionary alloc]init];
                NSDictionary *itemGive = [[NSDictionary alloc]init];
                //积分和现金券支付时不送积分
                if(selectPayType == 1 || selectPayType == 2){
                    itemGive = [giveArrAdds objectAtIndex:k];
                    giveModel = @{@"PaymentAmount":@.00,@"PaymentMode":@([[itemGive objectForKey:@"PaymentMode"] integerValue]),@"CardType":@([[itemGive objectForKey:@"CardType"] integerValue]),@"UserCardNo":[itemGive objectForKey:@"UserCardNo"]};
                }
                else{
                    if([[giveArrAdds[k] objectForKey:@"PaymentMode"]integerValue] == 6){//积分PaymentMode
                        itemGive = [giveArrAdds objectAtIndex:k];
                        giveModel = @{@"PaymentAmount":@((double)(pd.pro_UnPaidPrice*self.intergralPresentRate)),@"PaymentMode":@6,@"CardType":@2,@"UserCardNo":[itemGive objectForKey:@"UserCardNo"]};
                    }
                    if([[giveArrAdds[k] objectForKey:@"PaymentMode"]integerValue] == 7){//现金券
                        itemGive = [giveArrAdds objectAtIndex:k];
                        giveModel = @{@"PaymentAmount":@((double)(pd.pro_UnPaidPrice*self.cashCouponPresentRate)),@"PaymentMode":@7,@"CardType":@3,@"UserCardNo":[itemGive objectForKey:@"UserCardNo"]};
                    }
                    
                }
                [giveArrModel addObject:giveModel];
            }
            
            par1 = @{
                     @"OrderCount":@1,
                     @"TotalPrice":[NSString stringWithFormat:@"%.2Lf",pd.pro_UnPaidPrice],
                     @"Remark":payDoc1.Pay_Remark,
                     @"CustomerID":@((long)customerId),
                     @"AverageFlag":@(self.averageFlag),
                     //@"BranchProfitRate":self.branchProfitRate,
                     @"Slavers":[par objectForKey:@"Slavers"],
                     //@"SalesConsultantRates":[self gettingSalesConsultantRates],
                     @"OrderIDList":orderIdJsonArr,
                     @"PaymentDetailList":paymentArrModel,
                     @"GiveDetailList":giveArrModel
                     };
            [parArr addObject:par1];
        }
    }
    else{
        [parArr addObject:par];
    }
    
    //支付数据
    NSDictionary * parReally = @{
                                 @"PaymentAddOperationList":parArr
                                 };
    
    _addPayInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/AddPayment" andParameters:parReally failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            [self paySuccessAndGoTo:@"支付成功"];
            
        } failure:^(NSInteger code, NSString *error) {
            
            if (code == 5) { //--订单价格发生改变，重新请求订单信息
                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                    [self getPaymentInfoByJson];
                    [SVProgressHUD dismiss];
                }];
            } else if (code == 2) { //--提交的订单部分或全部已经被支付
                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                    [self getPaymentInfoByJson];
                    [self paySuccessAndGoTo:error];
                }];
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:(error.length ?error :@"支付失败，请重试！") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

/** 支付成功或失败后的跳转 */
- (void)paySuccessAndGoTo:(NSString *)mesg
{
    [SVProgressHUD showSuccessWithStatus2:mesg duration:kSvhudtimer touchEventHandle:^{
        if (comeFrom == 1) {//来自订单详情页完成支付直接返回订单详情
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[OrderDetailViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
                }
            }
        }else if (comeFrom ==2)//返回到结账列表页
        {
            for (UIViewController *temp in self.navigationController.viewControllers) {
                if ([temp isKindOfClass:[OrderPayListViewController class]]) {
                    [temp performSelector:@selector(initSelcte) withObject:nil];
                    [self.navigationController popToViewController:temp animated:YES];
                }
            }
        }
    }];
}

@end

