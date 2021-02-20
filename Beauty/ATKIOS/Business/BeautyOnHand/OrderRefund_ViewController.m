//
//  OrderRefund_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/11/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OrderRefund_ViewController.h"
#import "NavigationView.h"
#import "NormalEditCell.h"
#import "AFHTTPClient.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"
#import "GPBHTTPClient.h"
#import "TwoTextFieldCell.h"
#import "ContentEditCell.h"
#import "UserDoc.h"
#import "OverallMethods.h"
#import "SelectCustomersViewController.h"
#import "DFTableAlertView.h"
#import "FooterView.h"
#import "ColorImage.h"
#import "PerformanceTableViewCell.h"
#import "ProfitListRes.h"
#import "SalesConsultantListRes.h"
#import "TwoLabelCell.h"
#import "UIButton+InitButton.h"
#import "UIAlertView+AddBlockCallBacks.h"

@interface OrderRefund_ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ContentEditCellDelegate,SelectCustomersViewControllerDelegate,PerformanceTableViewCellDelegate>

@property(nonatomic,strong)UITableView * stopOrderTableView;
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetOrderPaymentDetailOperation;
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetRefundOrderInfo;
@property(weak, nonatomic) AFHTTPRequestOperation *RefundPayOperation;

/* 数组 */
@property (nonatomic,strong)NSMutableArray * performanceArr;
@property (nonatomic,strong)NSMutableArray * customerCardListMuArr;
@property (nonatomic ,strong) NSDictionary *cashCardDic;
@property (nonatomic ,strong) NSDictionary *intergralCardDic;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (nonatomic ,strong) NSMutableArray * slaveArray;
@property (nonatomic ,strong) NSMutableArray * salesConsultantArray;
@property (nonatomic ,strong) NSMutableArray * paymentRefundOperationArray;
@property (nonatomic ,strong) NSArray *cardListArr;

//所选择支付方式的保存状态
@property (nonatomic, strong) NSMutableArray *choosePaymentMuArr;
@property (nonatomic, strong) NSMutableArray *chooseCardMuArr;
@property (nonatomic ,strong) NSMutableArray * cardMoneyArr;

/* cell的收起展开 */
@property (nonatomic ,strong) NSMutableArray * sectionIsShowArr;

/* 退款总额 */
@property(nonatomic,assign)long double refundAmout;
/* 应退金额*/
@property(nonatomic,assign)long double shouldRefundAmout;
/* 退款比例 */
@property(nonatomic,assign)double refundRate;

/* 退款 */
@property(nonatomic,assign)long double cashMoney;
@property(nonatomic,assign)long double otherMoney;
@property(nonatomic,assign)long double supremeCardMoney;

/* 业绩参与金额 */
@property(nonatomic,assign)long double salesConsultantMonery;
@property(nonatomic,assign)long double salesConsultantMoneryRate;

/*均分*/
@property (nonatomic ,assign) NSInteger averageFlag;  //0不均分 1均分
@property (nonatomic ,assign) NSInteger averageNum;  //按钮交替点击

/* 退款方式 、积分现金券 */
@property(nonatomic,assign)long double cashCoupon;
@property(nonatomic,assign)long double integral;

/* 抵用的现金*/
@property(nonatomic,assign)long double cashCouponArriveMoney;
@property(nonatomic,assign)long double integralArriveMoney;

/* 消费赠送退还 、积分现金券 */
@property(nonatomic,assign)long double sendCashCoupon;
@property(nonatomic,assign)long double sendIntegral;
@property(nonatomic,assign)long double defultSendCashCoupon;
@property(nonatomic,assign)long double defultSendIntegral;

/*积分现金券的退还和扣除比例 */
@property (nonatomic ,assign)long double intergralRate;
@property (nonatomic ,assign)long double cashCouponRate;
@property (nonatomic ,assign)long double intergralPresentRate;
@property (nonatomic ,assign)long double cashCouponPresentRate;
@property (nonatomic ,assign)long double returnMoneyPoints;

/* string */
@property (nonatomic ,strong)NSString * refundRemark;

/*flaot*/
@property (assign, nonatomic) CGFloat initialTVHeight;

/*是否显示业绩参与*/
@property (nonatomic ,strong) NSNumber * isComissionCalc;
@end

@implementation OrderRefund_ViewController
@synthesize stopOrderTableView,performanceArr;
@synthesize refundAmout,refundRate,shouldRefundAmout;
@synthesize cashMoney,otherMoney,salesConsultantMonery,supremeCardMoney,salesConsultantMoneryRate,returnMoneyPoints;
@synthesize cashCouponArriveMoney,cashCoupon,integralArriveMoney,integral,sendCashCoupon,sendIntegral;
@synthesize customerCardListMuArr;
@synthesize cashCardDic,intergralCardDic;
@synthesize refundRemark;
@synthesize choosePaymentMuArr,chooseCardMuArr,cardMoneyArr;
@synthesize isComissionCalc;
@synthesize slaveArray;
@synthesize salesConsultantArray;
@synthesize paymentHistoryArray;
@synthesize paymentRefundOperationArray;
@synthesize cardListArr;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChangedPay:) name:UITextFieldTextDidChangeNotification object: nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderPaymentDetailOperation || [_requestGetOrderPaymentDetailOperation isExecuting]) {
        [_requestGetOrderPaymentDetailOperation cancel];
        _requestGetOrderPaymentDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化均分
    self.averageFlag = 1;
    self.averageNum = 1;
    
    isComissionCalc = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_isComissionCalc"];
    [self inittableView];
    
    [self initdata];
    
     [self RequestRefundOrderInfo];
}

-(void)inittableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"订单退款"];
    [self.view addSubview:navigationView];
    
    stopOrderTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f)style:UITableViewStyleGrouped];
    stopOrderTableView.separatorColor = kTableView_LineColor;
    stopOrderTableView.backgroundView = nil;
    stopOrderTableView.backgroundColor = nil;
    stopOrderTableView.delegate = self;
    stopOrderTableView.dataSource = self;
    _initialTVHeight = stopOrderTableView.frame.size.height;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        stopOrderTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        stopOrderTableView.sectionFooterHeight = 0;
        stopOrderTableView.sectionHeaderHeight = 10;
    }
    [self.view addSubview:stopOrderTableView];
    
    FooterView * footerView =[[FooterView alloc] initWithTarget:self submitImg:[ColorImage blueBackgroudImage] submitTitle:@"确    定" submitAction:@selector(refundPay)];
    [footerView showInTableView:stopOrderTableView];
}

-(void)initdata
{
    
    performanceArr = [[NSMutableArray alloc] init];
    chooseCardMuArr = [[NSMutableArray alloc] init];
    choosePaymentMuArr = [[NSMutableArray alloc] init];
    cardMoneyArr = [[NSMutableArray alloc] init];
    slaveArray = [[NSMutableArray alloc] init];
    salesConsultantArray = [[NSMutableArray alloc] init];
    paymentRefundOperationArray = [[NSMutableArray alloc] init];
    cardListArr = [[NSArray alloc]init];
    refundRate = 1.00;
    
    /**
     *现分七种支付方式:0、现金，1、其它，2、退还积分，3、退还现金券，4、积分赠送扣除，5、现金券赠送 扣除。
     *支付方式数组初始化为0，选中哪种支付方式对应的设置为1
     */
    for (int i=0; i<6; i++) {
        [choosePaymentMuArr addObject:@"0"];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section < self.paymentHistoryArray.count){
        if (![[self.sectionIsShowArr objectAtIndex:section] integerValue]) {
            return 1;
        }
        PaymentHistoryDoc *paymentHistory = [self.paymentHistoryArray objectAtIndex:section];
//        return  7 + paymentHistory.paymentMode.count  + (paymentHistory.paymentRemark.length > 0 ? 2 : 0);
        return  10 + paymentHistory.paymentMode.count  + (paymentHistory.paymentRemark.length > 0 ? 2 : 0) + paymentHistory.profitListArrs.count+paymentHistory.salesConsultantListArrs.count;
    }else if(section  == self.paymentHistoryArray.count)
    {
        //应退余额
        return 1;
    }
    else if(section  == (self.paymentHistoryArray.count + 1 ))
    {
        //退款方式、现金、其它
        return 2;
    }
    else if(section  == (self.paymentHistoryArray.count + 2))
    {
        //退款方式。储值卡
        return customerCardListMuArr.count;
    }
    else if(section  == (self.paymentHistoryArray.count+ 3))
    {
        //退还积分现金券
        return 2;
    }
    else if(section  == (self.paymentHistoryArray.count +4))
    {
        //消费赠送退还
        return 3;
    }
    else if(section  == (self.paymentHistoryArray.count +5))
    {
        if(self.isComissionCalc.boolValue){
            //销售顾问
            return 1 + self.salesConsultantArray.count;
        }
        
    }
    else if(section  == (self.paymentHistoryArray.count +6))
    {
        if(self.isComissionCalc.boolValue){
            //业绩参与金额
            return 1;
        }
        
    }
    else if(section  == (self.paymentHistoryArray.count +7))
    {
        if(self.isComissionCalc.boolValue){
            //业绩参与人
            return 1 + self.slaveArray.count;
        }
        
    }
    else if(section  == (self.paymentHistoryArray.count +8 ))
    {
        //备注
        return 2;
    }
    
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return self.paymentHistoryArray.count+9;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.paymentHistoryArray.count) {
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7){
            NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < 38 ? 38 : height;
        }
//        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 5) {
//            NSString *accString = [paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
//            NSInteger height = [accString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height + 18;
//            return height < 38 ? 38 :height;
//        }
    }else if(indexPath.section == self.paymentHistoryArray.count)
    {
        //应退金额
        return kTableView_HeightOfRow + 20;
        
    }else if(indexPath.section == (self.paymentHistoryArray.count +6 ) && indexPath.row == 1){
        //备注
        ContentEditCell *cell = [[ContentEditCell alloc] init];
        cell.contentEditText.text = refundRemark;
        CGFloat currentHeight = [cell.contentEditText sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
        return kTableView_HeightOfRow > currentHeight ? kTableView_HeightOfRow : currentHeight;
    }
    
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if((section  == (self.paymentHistoryArray.count +2) ) && customerCardListMuArr.count ==0)
    {
        //退款方式。储值卡
        return 0.1f;
        
    }else if(section  == (self.paymentHistoryArray.count +1))
    {
        //退款方式。储值卡
        return 30;
        
    }else if(section  == (self.paymentHistoryArray.count +4))
    {
        //消费赠送退还
        return 30;
    }

    return kTableView_Margin_TOP;
}

-(UIView * )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
    view.backgroundColor = [UIColor clearColor];
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10 , 5, 200, 20)];
    lable.font = kFont_Light_16;
    [view addSubview:lable];
    
     if(section  == (self.paymentHistoryArray.count +1))
    {
        //退款方式。储值卡
        lable.text = @"退款方式";
    }
    else if(section  == (self.paymentHistoryArray.count +4))
    {
        //消费赠送退还
        lable.text = @"消费赠送退还";
    }

    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //初始化cell
    NormalEditCell * payCell = [self configPayEditCell:tableView indexPath:indexPath];
    TwoTextFieldCell * cellText = [self configTwoTextFeildTableViewCell:tableView indexPath:indexPath];

    if (indexPath.section < self.paymentHistoryArray.count ) {//订单支付信息
        UITableViewCell * cell = [self configTableViewCell:tableView indexPath:indexPath];
        return cell;
    }
    //应退金额
    else if(indexPath.section == self.paymentHistoryArray.count)
    {
        payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        payCell.titleLabel.text = @"应退金额";
        payCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,shouldRefundAmout];
        payCell.valueText.textColor = kColor_Black;
        UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(5, kTableView_HeightOfRow-5, 300, 20)];
        lable.text = @"*不限次数服务的应退金额请自行计算";
        lable.font = kFont_Light_12;
        lable.textColor = [UIColor redColor];
        [payCell.contentView addSubview:lable];
        
        return payCell;
    }
    //退款方式 现金
    else if(indexPath.section ==(self.paymentHistoryArray.count +1))
    {
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = 1000+indexPath.row;
        [choosePaymentBt addTarget:self action:@selector(choosePayment:) forControlEvents:UIControlEventTouchUpInside];
        [payCell.contentView addSubview:choosePaymentBt];
        
        if ([[choosePaymentMuArr objectAtIndex:indexPath.row] integerValue]== 1 ) {
            choosePaymentBt.selected = YES;
            payCell.valueText.enabled = YES;
        }else
            choosePaymentBt.selected = NO;
        
        payCell.tag = 5000+indexPath.row;
        switch (indexPath.row) {
            case 0:
                payCell.titleLabel.text = @"现金";
                payCell.valueText.text = cashMoney == 0.00f ? @"" : [NSString stringWithFormat:@"%.2Lf", cashMoney];
                break;
            case 1:
                payCell.titleLabel.text = @"其它";
                payCell.valueText.text = otherMoney == 0.00f ? @"" : [NSString stringWithFormat:@"%.2Lf", otherMoney];
                break;
                
            default:
                break;
        }
        /*payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        switch (indexPath.row) {
            case 0:
                payCell.titleLabel.text = @"现金";
                payCell.valueText.text = cashMoney == 0.00f ? @"" : [NSString stringWithFormat:@"%.2Lf", cashMoney * refundRate];
                break;
            case 1:
                payCell.titleLabel.text = @"其它";
                payCell.valueText.text = otherMoney == 0.00f ? @"" : [NSString stringWithFormat:@"%.2Lf", otherMoney * refundRate];
                break;
                
            default:
                break;
        }
        payCell.valueText.textColor = kColor_Black;*/
        return payCell;
    }
    //退款方式 储值卡
    else if(indexPath.section ==(self.paymentHistoryArray.count+2))
    {
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = 2000+indexPath.row;
        [choosePaymentBt addTarget:self action:@selector(chooseCard:) forControlEvents:UIControlEventTouchUpInside];
        [payCell.contentView addSubview:choosePaymentBt];
        
        if ([[chooseCardMuArr objectAtIndex:indexPath.row] integerValue] == 1 ) {
            choosePaymentBt.selected = YES;
            payCell.valueText.enabled = YES;
        }else
            choosePaymentBt.selected = NO;
        
        payCell.titleLabel.text = [NSString stringWithFormat:@"%@",[[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"CardName"]];
        payCell.valueText.text =  [[cardMoneyArr objectAtIndex:indexPath.row] doubleValue] == 0.0f ? @"" : [NSString stringWithFormat:@"%.2f", [[cardMoneyArr objectAtIndex:indexPath.row] doubleValue]];
        
        payCell.tag = 6000+indexPath.row;
        /*payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        payCell.titleLabel.text = [NSString stringWithFormat:@"%@",[[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"CardName"]];
         payCell.valueText.text =  [[cardMoneyArr objectAtIndex:indexPath.row] doubleValue] == 0.0f ? @"" : [NSString stringWithFormat:@"%.2f", [[cardMoneyArr objectAtIndex:indexPath.row] doubleValue] * refundRate];
        //payCell.valueText.text = self.supremeCardMoney == 0.00f ? @"" : [NSString stringWithFormat:@"%.2Lf", self.supremeCardMoney];
        payCell.valueText.textColor = kColor_Black;*/
        return payCell;
    }
    //退款方式 积分现金券
    else if(indexPath.section ==(self.paymentHistoryArray.count+ 3))
    {
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = 1002+indexPath.row;
        [choosePaymentBt addTarget:self action:@selector(choosePayment:) forControlEvents:UIControlEventTouchUpInside];
        [cellText.contentView addSubview:choosePaymentBt];
        
        if ([[choosePaymentMuArr objectAtIndex:2+indexPath.row] integerValue]== 1 ) {
            choosePaymentBt.selected = YES;
            payCell.valueText.enabled = YES;
        }else
            choosePaymentBt.selected = NO;
        switch (indexPath.row) {
            case 0:
            {
                cellText.titleNameLabel.text = @"积分";
                cellText.payTextField.text = integral ==0.0f? @"": [NSString stringWithFormat:@"%.2Lf",integral];
                cellText.payTextField.tag = 3001;
                cellText.lable.text = @"抵";
                
                cellText.contentText.tag = 3002;
                cellText.contentText.text = integral == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",integralArriveMoney];
                cellText.tag = 600;
                
                if ([[choosePaymentMuArr objectAtIndex: 2] integerValue]== 1 ) {
                    cellText.payTextField.enabled = YES;
                }else
                    choosePaymentBt.selected = NO;
            }
                
                return cellText;
            case 1:
            {
                cellText.titleNameLabel.text = @"现金券";
                cellText.payTextField.text = cashCoupon ==0.0f? @"":[NSString stringWithFormat:@"%.2Lf",cashCoupon];
                cellText.payTextField.tag = 3003;
                cellText.contentText.tag = 3004;
                
                cellText.contentText.text = cashCoupon == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",cashCouponArriveMoney];
                cellText.tag = 601;
                cellText.lable.text = @"抵";
                
                if ([[choosePaymentMuArr objectAtIndex: 3] integerValue]== 1 ) {
                    cellText.payTextField.enabled = YES;
                }else
                    choosePaymentBt.selected = NO;
            }
                return cellText;
            default:
                break;
        }
        return payCell;
        /*payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
        switch (indexPath.row) {
            case 0:
            {
                payCell.titleLabel.text = @"积分";
                payCell.valueText.text = integral ==0.0f? @"": [NSString stringWithFormat:@"%.2Lf",integral * refundRate];
                payCell.valueText.textColor = kColor_Black;
                return payCell;
            }
            case 1:
            {
                payCell.titleLabel.text = @"现金券";
                payCell.valueText.text = cashCoupon ==0.0f? @"":[NSString stringWithFormat:@"%.2Lf",cashCoupon * refundRate];
                payCell.valueText.textColor = kColor_Black;
                return payCell;
            }
            default:
                break;
        }*/

    }
    //消费赠送退还
    else if(indexPath.section ==(self.paymentHistoryArray.count+ 4))
    {
        UIButton * choosePaymentBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
        [choosePaymentBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
        choosePaymentBt.tag = 1004+indexPath.row-1;
        [choosePaymentBt addTarget:self action:@selector(choosePayment:) forControlEvents:UIControlEventTouchUpInside];
        [cellText.contentView addSubview:choosePaymentBt];
        
        if ([[choosePaymentMuArr objectAtIndex:3+indexPath.row] integerValue]== 1 ) {
            choosePaymentBt.selected = YES;
        }else
            choosePaymentBt.selected = NO;
        
        switch (indexPath.row) {
            case 0:
            {
                payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 200.0f, kTableView_HeightOfRow);
                payCell.titleLabel.text = @"积分现金券";
                payCell.valueText.text= @"余额";
                payCell.valueText.userInteractionEnabled = NO;
                return payCell;
            }
                break;
            case 1:
            {
                cellText.titleNameLabel.text = @"积分";
                cellText.payTextField.text = [NSString stringWithFormat:@"%.2Lf",self.defultSendIntegral];
                cellText.payTextField.textColor = kColor_Black;
                cellText.lable.text = @"扣除";
                
                cellText.contentText.tag = 4002;
                cellText.contentText.text = sendIntegral == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",sendIntegral];
                cellText.tag = 602;
                
                if ([[choosePaymentMuArr objectAtIndex: 4] integerValue]== 1 ) {
                    cellText.contentText.enabled = YES;
                }else
                    choosePaymentBt.selected = NO;
            }
                return cellText;
            case 2:
            {
                cellText.titleNameLabel.text = @"现金券";
                cellText.payTextField.text = [NSString stringWithFormat:@"%.2Lf",self.defultSendCashCoupon];
                cellText.payTextField.textColor = kColor_Black;
                cellText.contentText.tag = 4004;
                
                cellText.contentText.text = sendCashCoupon == 0.0f? @"": [NSString stringWithFormat:@"%.2Lf",sendCashCoupon];
                cellText.tag = 603;
                cellText.lable.text = @"扣除";
                
                if ([[choosePaymentMuArr objectAtIndex: 5] integerValue]== 1 ) {
                    cellText.contentText.enabled = YES;
                }else
                    choosePaymentBt.selected = NO;
            }
                return cellText;
            default:
                break;
        }
        return payCell;
        /*payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 200.0f, kTableView_HeightOfRow);
        switch (indexPath.row) {
            case 0:
            {
                payCell.titleLabel.text = @"积分现金券";
                payCell.valueText.text= @"余额";
                payCell.valueText.userInteractionEnabled = NO;
                return payCell;
            }
                break;
            case 1:
            {
                payCell.titleLabel.text = @"积分";
                payCell.valueText.text = [NSString stringWithFormat:@"%.2Lf",self.defultSendIntegral];
                payCell.valueText.textColor = kColor_Black;
                return payCell;
            }
            case 2:
            {
                payCell.titleLabel.text = @"现金券";
                payCell.valueText.text = [NSString stringWithFormat:@"%.2Lf",self.defultSendCashCoupon];
                payCell.valueText.textColor = kColor_Black;
                return payCell;
            }
            default:
                break;
        }*/
    }
    //退款销售顾问
    else if(indexPath.section ==(self.paymentHistoryArray.count+ 5))
    {
        if(self.isComissionCalc.boolValue){
            if (indexPath.row == 0) {
                //payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
                //payCell.titleLabel.text = @"销售顾问提成比例";
                //payCell.valueText.placeholder = @"请选择业绩参与人";
                //payCell.valueText.userInteractionEnabled = NO;
                // payCell.valueText.textColor = kColor_Black;
                //return payCell;
                return  [self configBranchSalesConsultantCell:tableView indexPath:indexPath];
                
            }else{
                return  [self configBranchSalesConsultantRateCell:tableView indexPath:indexPath];
            }
        }
    }
    //业绩参与金额
    else if(indexPath.section ==(self.paymentHistoryArray.count+ 6)){
        if(self.isComissionCalc.boolValue){
            payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 120.0f, kTableView_HeightOfRow);
            payCell.titleLabel.text = @"业绩参与金额";
            payCell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,salesConsultantMonery];
            payCell.valueText.textColor = kColor_Black;
            return payCell;
        }
    }
    //退款业绩参与人
    else if(indexPath.section ==(self.paymentHistoryArray.count+ 7))
    {
        if(self.isComissionCalc.boolValue){
            if (indexPath.row == 0) {
                /*payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
                 payCell.titleLabel.text = @"业绩参与";
                 payCell.valueText.placeholder = @"请选择业绩参与人";
                 payCell.valueText.userInteractionEnabled = NO;
                 payCell.valueText.textColor = kColor_Black;
                 return payCell;*/
                return  [self configPerformanceCell:tableView];
            }else{
                return [self configPerformanceProportionCell:tableView indexPath:indexPath];
            }
        }
    }else if(indexPath.section ==(self.paymentHistoryArray.count+ 8))
    {
        switch (indexPath.row) {
            case 0:
                payCell.titleLabel.frame = CGRectMake(5.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
                payCell.titleLabel.text = @"备注";
                payCell.valueText.hidden = YES;
                return payCell;
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
    
    return payCell;
}
#pragma mark - PerformanceTableViewCellDelegate
-(void)PerformanceTableViewCellWithDidEndEditing:(UITextField *)textField
{
    PerformanceTableViewCell *cell;
    if (IOS7) {
        cell = (PerformanceTableViewCell *)textField.superview.superview.superview;
    }else{
        cell = (PerformanceTableViewCell *)textField.superview.superview;
    }
    NSIndexPath *indexPath = [stopOrderTableView indexPathForCell:cell];
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (indexPath.row > 0) {
        UserDoc *user =self.slaveArray[indexPath.row - 1];
        user.user_ProfitPct = textField.text;
    }

    
}

/*
 * 选择均分按钮后  交替点击
 */
-(void)chickAverageBtn
{
    if(self.averageNum % 2 ==0){
        self.averageFlag = 1;
        if (self.slaveArray.count > 0) {
            for(UserDoc *user in slaveArray){
                user.user_ProfitPct = @"均分";
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
    [stopOrderTableView reloadData];
    self.averageNum ++;
}

#pragma mark - 配置cell
//业绩参与
- (UITableViewCell *)configPerformanceCell:(UITableView *)tableView {
    NSString *cellindity = @"performance";
    TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTitle: @"业绩参与"];
    }
    //cell.valueText.hidden =YES；
    [cell setValue:@"请选择业绩参与者" isEditing:NO];
    cell.valueText.textColor = kColor_Editable;
    //均分按钮
    UIButton * averageButton;
    averageButton = [UIButton buttonTypeRoundedRectWithTitle:@"均分" target:self selector:@selector(chickAverageBtn) frame:CGRectMake(80.0f,(kTableView_HeightOfRow - 20.0f)/2,35.0f,20.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:5];
    [[cell contentView] addSubview:averageButton];
    return cell;
}

#pragma mark - 配置cell
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    performanceCell.numText.hidden = NO;
    performanceCell.percentLab.hidden = NO;
    performanceCell.numText.enabled = NO;
    UserDoc *userDoc;
    
    if (self.slaveArray.count > 0) {
        userDoc = self.slaveArray[indexPath.row - 1];
        performanceCell.nameLab.text = userDoc.user_Name;
        //选择业绩参与人前已经选择了均分 那么后面再选择的业绩参与人也是均分的
        if(self.averageFlag == 1){
            performanceCell.numText.text = @"均分";
            performanceCell.numText.enabled =NO;
            if (self.slaveArray.count == 1) {
                performanceCell.numText.text = @"100";
            }
        }else{
            performanceCell.numText.enabled =YES;
            performanceCell.numText.text = userDoc.user_ProfitPct;
        }
    }
    return performanceCell;
}
//订单支付详情
-(UITableViewCell *)configTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"Remark";
    UITableViewCell *cell = nil;
    NSString *identify1 =[NSString stringWithFormat:@"TwoElement_%ld_%ld",(long)indexPath.row,(long)indexPath.section];
    cell = [tableView dequeueReusableCellWithIdentifier:identify1];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify1];
    else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify1];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;

    UILabel *title = (UILabel *)[ cell viewWithTag:1000];
    if(!title){
        title = [[UILabel alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 8, 120, 20)];
        [cell addSubview:title];
    }
    title.textColor = kColor_DarkBlue;
    title.tag = 1000;
    title.font = kFont_Light_16;
    
    UILabel *value = (UILabel *)[ cell viewWithTag:1001];
    if(!value){
        value = [[UILabel alloc] init];
        [cell addSubview:value];
    }
    value.frame = CGRectMake(160 + ((IOS6) ? 20.f : 10.f), 8, 135, 20);
    value.textColor = kColor_Black;
    value.font = kFont_Light_16;
    value.tag = 1001;
    value.textAlignment  = NSTextAlignmentRight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section < self.paymentHistoryArray.count){
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        //备注内容部分
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 10 + paymentHistoryDoc.profitListArrs.count + paymentHistoryDoc.salesConsultantListArrs.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
            NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 0, ((IOS6) ? 310.f : 300.f), (height <= 38 ? 34 : height))];
            textView.font = kFont_Light_16;
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.text = paymentHistoryDoc.paymentRemark;
            textView.backgroundColor = [UIColor clearColor];
            cell = [[UITableViewCell alloc]init];
            cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell addSubview:textView];
            cell.backgroundColor = kColor_White;
            return cell;
        }
        else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.profitListArrs.count + paymentHistoryDoc.salesConsultantListArrs.count)
        {
            title.text = @"备注";
            value.text = @"";
            return cell;
        }
        /*else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 6){
            title.text = @"业绩参与";
            value.text = paymentHistoryDoc.profitListArrs.count == 0 ?@"无":@"";
            return cell;
        }else if((indexPath.row > paymentHistoryDoc.paymentMode.count + 6)  && (indexPath.row < paymentHistoryDoc.paymentMode.count + 7 + paymentHistoryDoc.profitListArrs.count) ){
            return [self configPerformanceProportionCell:tableView indexPath:indexPath paymentHistoryDoc:paymentHistoryDoc];
        }*/
        else if(indexPath.row == 0){
            
            UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
            if ([[self.sectionIsShowArr objectAtIndex:indexPath.section] integerValue]) {
                selectImageView.image = [UIImage imageNamed:@"jiantous"];
            }else
            {
                selectImageView.image = [UIImage imageNamed:@"jiantoux"];
            }
            
            selectImageView.tag = 3004;
            [cell.contentView addSubview:selectImageView];
            value.frame = CGRectMake(130 + ((IOS6) ? 20.f : 10.f), 8, 145, 20);
            title.text = @"交易编号";
            value.text = paymentHistoryDoc.paymentCodeString;
            return cell;
        }else if (indexPath.row == 1){
            title.text = @"交易时间";
            value.text = paymentHistoryDoc.paymentTime;
            return cell;
        }else if(indexPath.row ==2){
            title.text = @"交易门店";
            value.text = paymentHistoryDoc.BranchName;
            return cell;
        }else if(indexPath.row ==3){
            title.text = @"交易类型";
            value.text = paymentHistoryDoc.TypeName;
            return cell;
        }
        else if (indexPath.row == 4) {
            title.text = @"操作人";
            value.text = paymentHistoryDoc.paymentOperator;
            return cell;
        }else if (indexPath.row == 5) {
            value.frame = CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 215, 20);
            title.text = @"交易总金额";
            value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon, paymentHistoryDoc.paymentTotalMoney];
            return cell;
        }else if(indexPath.row>5 && indexPath.row < 6 + paymentHistoryDoc.paymentMode.count )
        {
            PayInfoDoc *payInfoDoc = [paymentHistoryDoc.paymentMode objectAtIndex:indexPath.row-6];
            title.text = [NSString stringWithFormat:@"%@",payInfoDoc.card_name];
            title.textColor = kColor_Black;
            value.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,payInfoDoc.pay_Amount];
            
            if (payInfoDoc.pay_Mode == 6 || payInfoDoc.pay_Mode ==7) {
                UILabel *lableRemove = (UILabel *)[cell viewWithTag:indexPath.section*100+indexPath.row];
                [lableRemove removeFromSuperview];
                UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(50 + ((IOS6) ? 20.f : 10.f), 8, 110, 20)];
                lable.textColor = kColor_Black;
                lable.font = kFont_Light_16;
                lable.textAlignment  = NSTextAlignmentRight;
                lable.tag = indexPath.section*100+indexPath.row;
                [cell addSubview:lable];
                
                
                if (payInfoDoc.pay_Mode == 6){
                    
                    lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.pay_Amount];
                }
                
                if (payInfoDoc.cardType ==2) {
                    
                    lable.text = [NSString stringWithFormat:@"%.2f 抵",payInfoDoc.cardPay_Amount];
                }else
                    lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.cardPay_Amount];
            }
        }
        else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 6){
            return [self configBranchSalesConsultantCell:tableView indexPath:indexPath];
        }else if((indexPath.row > paymentHistoryDoc.paymentMode.count + 6)  && (indexPath.row < paymentHistoryDoc.paymentMode.count + 7 + paymentHistoryDoc.salesConsultantListArrs.count) ){
            return [self configBranchSalesConsultantRateCell:tableView indexPath:indexPath paymentHistoryDoc:paymentHistoryDoc];
        }
        else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7 + paymentHistoryDoc.salesConsultantListArrs.count){
            value.frame = CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 215, 20);
            title.text = @"业绩参与金额";
            
            value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon,[self countSalesConsultantMonery:paymentHistoryDoc]];
            return cell;
        }
        else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 8 + paymentHistoryDoc.salesConsultantListArrs.count){
            title.text = @"业绩参与";
            value.text = paymentHistoryDoc.profitListArrs.count == 0 ?@"无":@"";
            //            NSString *name = [paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
            //            NSInteger height = [name sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height;
            //            if (height > 20) {
            //                value.frame = CGRectMake(130 + ((IOS6) ? 20.f : 10.f), 8, 160, height);
            //                value.numberOfLines = 0;
            //                value.textAlignment = NSTextAlignmentLeft;
            //            }
            //            value.text = (name.length > 0 ? name:@"无");
            return cell;
        }else if((indexPath.row > paymentHistoryDoc.paymentMode.count + 8+ paymentHistoryDoc.salesConsultantListArrs.count)  && (indexPath.row < paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.salesConsultantListArrs.count + paymentHistoryDoc.profitListArrs.count) ){
            return [self configPerformanceProportionCell:tableView indexPath:indexPath paymentHistoryDoc:paymentHistoryDoc];
        }
    }
    
    return cell;
}

#pragma mark -  配置cell
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath paymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.numText.enabled = NO;
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (paymentHistoryDoc.profitListArrs.count > 0) {
        ProfitListRes *profitRes = [paymentHistoryDoc.profitListArrs objectAtIndex:indexPath.row - (paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.salesConsultantListArrs.count)];
        performanceCell.nameLab.text = profitRes.accountName;
        double temp =  profitRes.profitPct.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
    }
    return performanceCell;
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
- (PerformanceTableViewCell *)configBranchSalesConsultantRateCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath
{
    
    //
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantRateCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    performanceCell.numText.hidden = NO;
    performanceCell.percentLab.hidden = NO;
    performanceCell.numText.enabled = NO;
    
    if (self.salesConsultantArray.count > 0) {
        SalesConsultantListRes *salesConRes = salesConsultantArray[indexPath.row-1];
        performanceCell.nameLab.text = salesConRes.salesConsultantName;
        double temp =  salesConRes.commissionRate.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
        
    }
    return performanceCell;
}
//分店销售顾问提成比例
- (PerformanceTableViewCell *)configBranchSalesConsultantRateCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath paymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    
    //
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantRateCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    performanceCell.numText.hidden = NO;
    performanceCell.percentLab.hidden = NO;
    performanceCell.numText.enabled = NO;
    
    if (paymentHistoryDoc.salesConsultantListArrs.count > 0) {
        SalesConsultantListRes *salesConRes = [paymentHistoryDoc.salesConsultantListArrs objectAtIndex:indexPath.row - (paymentHistoryDoc.paymentMode.count + 7)];
        performanceCell.nameLab.text = salesConRes.salesConsultantName;
        double temp =  salesConRes.commissionRate.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
        
    }
    return performanceCell;
}


//积分现金券退款
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
    return cellText;
}

- (NormalEditCell *)configPayEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [NSString stringWithFormat:@"payCell%ld%ld",(long)indexPath.section,(long)indexPath.row];
    NormalEditCell *payCell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (payCell == nil) {
        payCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }else
    {
        [payCell removeFromSuperview];
        payCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    
    payCell.titleLabel.frame = CGRectMake(30.0f, 0.0f, 80.0f, kTableView_HeightOfRow);
    payCell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
    payCell.valueText.enabled = NO;
    payCell.valueText.delegate = self;
    payCell.valueText.placeholder = [NSString stringWithFormat:@"%@0.00",@""];
    payCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return payCell;
}
#pragma mark - didSelectRowAtIndexPath
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section < self.paymentHistoryArray.count){
        if ([[self.sectionIsShowArr objectAtIndex:indexPath.section] integerValue]) {
            
            [self.sectionIsShowArr replaceObjectAtIndex:indexPath.section withObject:@"0"];
        }else
            [self.sectionIsShowArr replaceObjectAtIndex:indexPath.section withObject:@"1"];
        
        [stopOrderTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if(indexPath.section ==(self.paymentHistoryArray.count+ 7))
    {
        if (indexPath.row == 0) {
            //选择业绩参与人
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            [selectCustomer setSelectModel:1 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:self.slaveArray];
            selectCustomer.navigationTitle = @"选择业绩参与者";
            selectCustomer.delegate = self;
            selectCustomer.customerId = self.customerId;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navigationController animated:YES completion:^{}];
        }
    }else if((indexPath.section ==(self.paymentHistoryArray.count+ 4)) && indexPath.row ==0)
    {
        [self checkCardBalance:indexPath.section];
    }
    
}

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    //初始化均分
    self.averageFlag = 1;
    self.averageNum = 1;
    [stopOrderTableView reloadSections:[NSIndexSet indexSetWithIndex:self.paymentHistoryArray.count+ 7] withRowAnimation:UITableViewRowAnimationNone];
}


/** 储值卡退款方式选择 */
-(void)chooseCard:(UIButton *)sender{
   
    NSInteger index =  sender.tag - 2000;

    if ([[chooseCardMuArr objectAtIndex:index] integerValue]) {
        //--取消选中
        [chooseCardMuArr replaceObjectAtIndex:index withObject:@"0"];
        [cardMoneyArr replaceObjectAtIndex:index withObject:@"0"];
        [self countThistPayMoney];
    }else
        [chooseCardMuArr replaceObjectAtIndex:index withObject:@"1"];

     [stopOrderTableView reloadSections:[NSIndexSet indexSetWithIndex:(self.paymentHistoryArray.count+2)] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:self.paymentHistoryArray.count];
    [indexSet addIndex:(self.paymentHistoryArray.count+2)];
    [stopOrderTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

//非储值卡退款方式选择
-(void)choosePayment:(UIButton *)sender
{
    NSInteger index =  sender.tag - 1000;

    if ([[choosePaymentMuArr objectAtIndex:index] integerValue]) {
        
        //--取消选择要把数据清除
        [choosePaymentMuArr replaceObjectAtIndex:index withObject:@"0"];
        [self clear:index];
        
    }else{
        
        [choosePaymentMuArr replaceObjectAtIndex:index withObject:@"1"];
    }
    
    [self countThistPayMoney];
    
    [stopOrderTableView reloadData];
}

/** 重新计算计算本次支付价格、和赠送的积分现金券*/
-(void)countThistPayMoney
{
    //----本次支付价格清零，重新计算本次支付总价格
    refundAmout = 0;
    
    for (int i=0; i<cardMoneyArr.count; i++) {
        
        refundAmout = refundAmout +[[cardMoneyArr objectAtIndex:i] doubleValue];
    }
    refundAmout = refundAmout + cashMoney + otherMoney;
    self.defultSendIntegral = refundAmout * self.intergralPresentRate;
    self.defultSendCashCoupon = refundAmout * self.cashCouponPresentRate;
    //重新计算退款里面业绩参与金额
    salesConsultantMonery = [self countSalesConsultantMoneryRefundDetail];
    refundAmout = refundAmout + integralArriveMoney + cashCouponArriveMoney;
}

/* 计算支付详情里面的业绩参与金额  */
-(double)countSalesConsultantMonery:(PaymentHistoryDoc *)paymentHistoryDoc{
    SalesConsultantListRes *salesConRes;
    double tempCommissionRate = 0.0;
    if (paymentHistoryDoc.salesConsultantListArrs.count > 0) {
        for(int i=0;i<paymentHistoryDoc.salesConsultantListArrs.count;i++){
            salesConRes = paymentHistoryDoc.salesConsultantListArrs[i];
            tempCommissionRate = tempCommissionRate + salesConRes.commissionRate.doubleValue;
        }
    }
    //salesConsultantMonery = (paymentHistoryDoc.paymentTotalMoney - integralArriveMoney - cashCouponArriveMoney) * (1 - tempCommissionRate);
    return paymentHistoryDoc.paymentTotalMoney * (1 - tempCommissionRate);;
}
/*重新计算退款里面的业绩参与金额*/
-(double)countSalesConsultantMoneryRefundDetail{
    salesConsultantMonery = 0;
    salesConsultantMoneryRate =0;
    if(self.salesConsultantArray !=nil && self.salesConsultantArray.count >0){
        SalesConsultantListRes *salesConRes = salesConsultantArray[0];
        salesConsultantMonery = refundAmout * (1 - salesConRes.commissionRate.doubleValue);
    }
    return salesConsultantMonery;
}
/** 取消选中按钮，清空对应的数据 */
-(void)clear:(NSInteger)index
{
    //--index 为取消选中的按钮tag
    switch (index) {
        case 0://现金
            cashMoney = 0.0f;
            break;
        case 1://其它
            otherMoney = 0.0f;
            break;
        case 2://退还积分
            integral = 0.0f;
            integralArriveMoney = 0.0f;
            //[self countSalesConsultantMonery];
            break;
        case 3://退还现金券
            cashCoupon = 0.0f;
            cashCouponArriveMoney = 0.0f;
            //[self countSalesConsultantMonery];
            break;
        case 4://积分赠送扣除
            sendIntegral = 0.0f;
            break;
        case 5://现金券赠送扣除
            sendCashCoupon = 0.0f;
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
#pragma mark 支付金额及人数 输入处理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
    
    return YES;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [stopOrderTableView indexPathForCell:cell];
    
    [stopOrderTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)updateTextfield:(UITextField *)textField
{
    NormalEditCell *cell;
    if (IOS6 || IOS8) {
        cell = (NormalEditCell *)textField.superview.superview;}
    else if (IOS7) {
        cell = (NormalEditCell *)textField.superview.superview.superview;}
    
    if (cell.tag == 5000) cashMoney = [textField.text doubleValue];
    else if (cell.tag == 5001) otherMoney = [textField.text doubleValue];
    else if( cell.tag >=6000 && cell.tag < 7000)
    {
        /**储值卡支付*/
        NSInteger index = cell.tag -6000;
        [cardMoneyArr replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%f",[textField.text doubleValue]]];
        
    } else if (cell.tag == 600)
    {
        /**退还积分四舍五入*/
        integral =[textField.text doubleValue];
        integralArriveMoney = [OverallMethods notRounding:(integral *self.intergralRate) afterPoint:2];
        
    }else if (cell.tag == 601)
    {
        /**退还现金券*/
        cashCoupon =[textField.text doubleValue];
        cashCouponArriveMoney = [OverallMethods notRounding:(cashCoupon *self.cashCouponRate) afterPoint:2];
        
    }else if(cell.tag == 602){
        /**扣除赠送积分*/
        sendIntegral = [textField.text doubleValue];
    }
    else if(cell.tag == 603) {
        /**扣除扣除赠送现金券*/
        sendCashCoupon = [textField.text doubleValue];
    }
    
    if (cell.tag == 603 || cell.tag ==602) {
        
    }else{
        [self countThistPayMoney];
        //[self countSalesConsultantMonery];
    }
    
    
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
        if ([cell isKindOfClass:[NormalEditCell class]]) {
            long  double tmp = [textField.text doubleValue];
            textField.text = (tmp == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", tmp]);
        }
    } else if (IOS7) {
        id cell = textField.superview.superview.superview;
        if ([cell isKindOfClass:[NormalEditCell class]]) {
            long double tmp = [textField.text doubleValue];
            textField.text = (tmp == 0.0f ? @"" : [NSString stringWithFormat:@"%.2Lf", tmp]);
        }
    }
    
        [stopOrderTableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification {
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect tvFrame = stopOrderTableView.frame;
        tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
        stopOrderTableView.frame = tvFrame;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self scrollToTextField:self.textField_Selected];
    if(!self.textField_Selected){
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:[stopOrderTableView numberOfSections] - 1];
        [stopOrderTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    CGRect tvFrame = stopOrderTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    stopOrderTableView.frame = tvFrame;
}


#pragma mark - 接口


/** 获取用户卡列表 */
-(void)RequestRefundOrderInfo
{
    NSDictionary * dic = @{@"OrderID":@((long)self.orderID),
                           @"CustomerID":@((long)self.customerId),
                            @"ProductType":@((long)self.productType)};
    
    _requestGetRefundOrderInfo = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/GetRefundOrderInfo" andParameters:dic failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
           
            
            refundAmout = 0;
            shouldRefundAmout = [[data objectForKey:@"RefundAmount"] doubleValue];
            if ([data objectForKey:@"Rate"] != [NSNull null]) {
                refundRate = [[data objectForKey:@"Rate"] doubleValue];
            }
            /*self.defultSendCashCoupon = [[data objectForKey:@"GiveCouponAmount"] doubleValue];
             self.defultSendIntegral = [[data objectForKey:@"GivePointAmount"] doubleValue];*/
            self.defultSendCashCoupon = 0;
            self.defultSendIntegral = 0;
            
            
            if (self.paymentHistoryArray)
                [self.paymentHistoryArray removeAllObjects];
            else
                self.paymentHistoryArray = [[NSMutableArray alloc] init];
            
            self.sectionIsShowArr = [[NSMutableArray alloc] init];
            
            int count = 0;
            for ( NSDictionary *dict in [data objectForKey:@"PaymentList"]){
                PaymentHistoryDoc *payment = [[PaymentHistoryDoc alloc] init];
                payment.paymentTime = [dict objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dict objectForKey:@"PaymentTime"];
                payment.paymentOperator = [dict objectForKey:@"Operator"];
                payment.paymentTotalMoney = [[dict objectForKey:@"TotalPrice"] doubleValue];
                payment.paymentTime = [payment.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                payment.paymentNumber = [[dict objectForKey:@"OrderNumber"] integerValue];
                payment.paymentCodeString = [dict objectForKey:@"PaymentCode"];
                payment.TypeName = [dict objectForKey:@"TypeName"];
                
                NSArray *proList = [dict objectForKey:@"ProfitList"] == [NSNull null] ? nil : [dict objectForKey:@"ProfitList"];
                for (NSDictionary *proDic in proList) {
                    ProfitListRes *profitRes = [[ProfitListRes alloc]init];
                    profitRes.accountID = [proDic objectForKey:@"AccountID"];
                    profitRes.accountName = [proDic objectForKey:@"AccountName"];
                    profitRes.profitPct = [proDic objectForKey:@"ProfitPct"];
                    [payment.profitListArrs addObject:profitRes];
                    if(count==0)
                    {
                        //[self.slaveArray addObject:profitRes];
                    }
                }

                NSArray *salesConsultantList = [dict objectForKey:@"SalesConsultantRates"] == [NSNull null] ? nil : [dict objectForKey:@"SalesConsultantRates"];
                for (NSDictionary *salesConDic in salesConsultantList) {
                    SalesConsultantListRes *salesConRes = [[SalesConsultantListRes alloc]init];
                    salesConRes.salesConsultantID = [salesConDic objectForKey:@"SalesConsultantID"];
                    salesConRes.salesConsultantName = [salesConDic objectForKey:@"SalesConsultantName"];
                    salesConRes.commissionRate = [salesConDic objectForKey:@"commissionRate"];
                    [payment.salesConsultantListArrs addObject:salesConRes];
                    if(count==0)
                    {
                        [self.salesConsultantArray addObject:salesConRes];
                    }
                }
                
                payment.paymentMode = [[NSMutableArray alloc] init];
                
                for (int i=0; i<[[dict objectForKey:@"PaymentDetailList"] count]; i++) {
                    NSDictionary * dic = [[dict objectForKey:@"PaymentDetailList"] objectAtIndex:i];
                    PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                    payInfoDoc.pay_Mode = [[dic objectForKey:@"PaymentMode"] integerValue];
                    payInfoDoc.pay_Amount = [[dic objectForKey:@"PaymentAmount"] doubleValue];
                    payInfoDoc.cardPay_Amount = [[dic objectForKey:@"CardPaidAmount"] doubleValue];
                    payInfoDoc.card_name = [dic objectForKey:@"CardName"];
                    payInfoDoc.cardType = [[dic objectForKey:@"CardType"] integerValue];
                    payInfoDoc.userCardNo = [dic objectForKey:@"UserCardNo"];
                    payment.paymentRemark = [dict objectForKey:@"Remark"];
                    payment.BranchName = [dict objectForKey:@"BranchName"];
                    
                    /*if(payInfoDoc.pay_Mode == 0){//现金
                        self.cashMoney = self.cashMoney + payInfoDoc.pay_Amount;
                    }
                    else if (payInfoDoc.pay_Mode == 1){//至尊卡 金卡 银卡 会员卡 都是1 要区分开
                        //self.supremeCardMoney = self.supremeCardMoney + payInfoDoc.pay_Amount;
                    }
                    else if (payInfoDoc.pay_Mode == 2 || payInfoDoc.pay_Mode == 3 || payInfoDoc.pay_Mode == 8 || payInfoDoc.pay_Mode == 9 || payInfoDoc.pay_Mode == 100 || payInfoDoc.pay_Mode == 101){//银行卡、其他、微信、支付宝、消费贷款、第三方付款都算其他类
                        self.otherMoney = self.otherMoney + payInfoDoc.pay_Amount;
                    }
                    
                    else if (payInfoDoc.pay_Mode == 6){//金豆
                        self.integral = self.integral + payInfoDoc.pay_Amount;
                    }
                    else if (payInfoDoc.pay_Mode == 7){//现金券
                        self.cashCoupon = self.cashCoupon + payInfoDoc.pay_Amount;
                    }*/
                    
                    [payment.paymentMode addObject:payInfoDoc];
                }
                [self.paymentHistoryArray addObject:payment];
                [self.sectionIsShowArr addObject:@"0"];
                count++;
            }

            //计算初业绩参与金额
            salesConsultantMonery = [self countSalesConsultantMoneryRefundDetail];
            
            /*
             * 保存卡列表
             */
            customerCardListMuArr = [[NSMutableArray alloc] init];
            
            NSArray *arr = [data objectForKey:@"CardList"];
            self.cardListArr = arr;
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
            //会员卡的类型和支付方式都是1 但是卡号不同
            /*for(int i=0;i<arr.count;i++){
                if( [[[arr objectAtIndex:i] objectForKey:@"CardTypeID"] intValue] ==1)//--会员卡
                {
                    NSString *UserCardNo = [[arr objectAtIndex:i] objectForKey:@"UserCardNo"] ;
                    for(int j =0;j< paymentHistoryArray.count;j ++){
                        PaymentHistoryDoc *payment = [[PaymentHistoryDoc alloc] init];
                        payment = paymentHistoryArray[j];
                        if (payment.paymentMode.count > 0){
                            PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                            
                            for(int k=0;k <payment.paymentMode.count;k ++){
                                payInfoDoc = payment.paymentMode[k];
                                if([UserCardNo isEqualToString:payInfoDoc.userCardNo]){
                                    [cardMoneyArr replaceObjectAtIndex:i withObject:@([[cardMoneyArr objectAtIndex:i] doubleValue] + payInfoDoc.pay_Amount)];
                                }
                            }
                        }
                    }
                }
            }
            self.integralArriveMoney = self.integral;
            self.cashCouponArriveMoney = self.cashCoupon;
            self.sendIntegral = self.defultSendIntegral;
            self.sendCashCoupon = self.defultSendCashCoupon;*/
            //[self countSalesConsultantMonery];
            [stopOrderTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [stopOrderTableView reloadData];
        }];
    } failure:^(NSError *error) {
        [stopOrderTableView reloadData];
    }];
}

#pragma mark - 组装Slavers
-(NSMutableArray *)gettingSlavers
{
    NSMutableArray *tempsArrs = [NSMutableArray array];
    /*if (self.slaveArray.count >0) {
        for (int i = 0; i < self.slaveArray.count ; i ++) {
            ProfitListRes *profits = self.slaveArray[i];
            if(profits.profitPct == nil){
                profits.profitPct = 0;
            }
            NSLog(@"user.user_ProfitPct == %@ user_Id == %ld",profits.profitPct,(long)profits.accountID);
            NSDictionary *dic = @{@"SlaveID":@(profits.accountID.integerValue),@"ProfitPct":@((profits.profitPct.doubleValue))};
            [tempsArrs addObject:dic];
        }
    }
    return tempsArrs;*/
    if(self.isComissionCalc.boolValue)
    {
        if (self.slaveArray.count >0) {
            for (int i = 0; i < self.slaveArray.count ; i ++) {
                UserDoc *user = self.slaveArray[i];
                if (user.user_ProfitPct == nil) {
                    user.user_ProfitPct = @"0";
                }
                //NSLog(@"user.user_ProfitPct == %@ user_Id == %ld",user.user_ProfitPct,(long)user.user_Id);
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
#pragma mark - 组装每个退款明细的Slavers
-(NSMutableArray *)gettingSlaversPaymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    NSMutableArray *tempsArrs = [NSMutableArray array];
    if (paymentHistoryDoc.profitListArrs.count > 0) {
        ProfitListRes *profits = [[ProfitListRes alloc] init];
        for (int i = 0; i < paymentHistoryDoc.profitListArrs.count ; i ++) {
            profits = paymentHistoryDoc.profitListArrs[i];
            if(profits.profitPct == nil){
                profits.profitPct = 0;
            }
            NSDictionary *dic = @{@"SlaveID":@(profits.accountID.integerValue),@"ProfitPct":@((profits.profitPct.doubleValue))};
            [tempsArrs addObject:dic];
        }
    }
    return tempsArrs;
}
#pragma mark - 组装每个退款明细的paymentArr
-(NSMutableArray *)gettingPaymentArrPaymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    NSMutableArray * paymentArr = [NSMutableArray array];
    
    if(paymentHistoryDoc.paymentMode.count > 0){
        PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
        for (int i = 0; i < paymentHistoryDoc.paymentMode.count; i ++) {
            payInfoDoc = paymentHistoryDoc.paymentMode[i];
            if (payInfoDoc.pay_Mode == 0) {//现金
                NSDictionary *dic = @{@"PaymentMode":@0,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 1){//至尊卡
                NSDictionary *dic = @{@"UserCardNo":payInfoDoc.userCardNo,@"CardType":@1,@"PaymentMode":@1,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 2){//银行卡
                NSDictionary *dic = @{@"PaymentMode":@2,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 3){//其他
                NSDictionary *dic = @{@"PaymentMode":@3,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 6){//积分
                NSDictionary *dic = @{@"UserCardNo":payInfoDoc.userCardNo,@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 7){//现金券
                NSDictionary *dic = @{@"UserCardNo":payInfoDoc.userCardNo,@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 8){//微信
                NSDictionary *dic = @{@"PaymentMode":@8,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 9){//支付宝
                NSDictionary *dic = @{@"PaymentMode":@9,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 100){//消费贷款
                NSDictionary *dic = @{@"PaymentMode":@100,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
            else if(payInfoDoc.pay_Mode == 101){//第三方收款
                NSDictionary *dic = @{@"PaymentMode":@101,@"PaymentAmount":@((long)payInfoDoc.pay_Amount)};
                [paymentArr addObject:dic];
            }
        }
        
    }
    
    return paymentArr;
}
#pragma mark - 组装每个退款明细的giveArr(积分和现金券)
-(NSMutableArray *)gettingGiveArrPaymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    NSMutableArray * giveArr = [NSMutableArray array];
    PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
    double giveMoney = 0.00;  // 每次付款时用积分和现金券的抵扣
    if(paymentHistoryDoc.paymentMode.count > 0){
        for(int i = 0;i<paymentHistoryDoc.paymentMode.count ;i ++){
            payInfoDoc = paymentHistoryDoc.paymentMode[i];
            if(payInfoDoc.pay_Mode == 6 || payInfoDoc.pay_Mode == 7){
                giveMoney = giveMoney + payInfoDoc.pay_Amount;
            }
        }
    }
    if(self.cardListArr.count > 0){
        for (int i = 0; i < self.cardListArr.count; i ++) {
            int carTypeID = [[[cardListArr objectAtIndex:i] objectForKey:@"CardTypeID"] intValue];
            NSString *UserCardNoString = [[cardListArr objectAtIndex:i] objectForKey:@"UserCardNo"] ;
            double presentRate = [[[cardListArr objectAtIndex:i] objectForKey:@"PresentRate"] doubleValue] ;
            if (carTypeID == 2) {
                NSDictionary *dicSend = @{@"UserCardNo":UserCardNoString,@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((paymentHistoryDoc.paymentTotalMoney - giveMoney) * presentRate)};
                [giveArr addObject:dicSend];
            }
            else if (carTypeID == 3) {
                NSDictionary *dicSend = @{@"UserCardNo":UserCardNoString,@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((paymentHistoryDoc.paymentTotalMoney - giveMoney)* presentRate)};
                [giveArr addObject:dicSend];
            }
        }
        
    }
    return giveArr;
}
//组装退款信息数组
-(void)paymentRefundOperationArrayAdd:(PaymentHistoryDoc *)paymentHistoryDoc {
    NSDictionary * par = [[NSDictionary alloc] init];
    NSString *targetPaymentID = [[NSString alloc] init];
    if(paymentHistoryDoc.paymentCodeString.length >0){
        targetPaymentID = [paymentHistoryDoc.paymentCodeString substringWithRange:NSMakeRange(4,6)];
        par = @{
                @"OrderID":@(self.orderID),
                @"TargetPaymentID":targetPaymentID,
                @"TotalPrice": @((double)paymentHistoryDoc.paymentTotalMoney),
                @"Remark":refundRemark,
                @"CustomerID":@((long)self.customerId),
                @"ProductType":@((long)self.productType),
                @"Slavers":[self gettingSlaversPaymentHistoryDoc:paymentHistoryDoc],
                @"PaymentDetailList":[self gettingPaymentArrPaymentHistoryDoc:paymentHistoryDoc],
                @"GiveDetailList":[self gettingGiveArrPaymentHistoryDoc:paymentHistoryDoc]
                };
    }
    [paymentRefundOperationArray addObject:par];
}
//判断实际退款金额与应对金额是否一致
-(BOOL)compareActualRefundAmountAndRefundAmout
{
    if(refundAmout != shouldRefundAmout){
        return YES;
    }
    else{
        return NO;
    }
}

//检查是否需要提示框
-(BOOL)needProfitRateAlter
{
    double rate=0;
    if (refundAmout == 0) {
        return YES;
    }else if([self compareActualRefundAmountAndRefundAmout])//计算实际退款金额与应对金额是否一致
    {
        return YES;
    }else if(self.defultSendIntegral != self.sendIntegral)//判断赠送赠送退还的积分与应扣金额是否一致
    {
        return YES;
    }else if(self.defultSendCashCoupon != self.sendCashCoupon)//判断赠送赠送退还的现金券与应扣金额是否一致
    {
        return YES;
    }else if(!self.isComissionCalc.boolValue)//不显示提成比例时不提示
    {
        return NO;
    }else if(self.slaveArray.count == 0){
        return YES;
    }else if(self.slaveArray.count > 0){
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
    }else{
        return NO;
    }
}

//提示信息返回
-(NSString *)returnMessageByRefund{
    NSString *rerurnAlertMessage = @"";
    double rate=0;
    if (refundAmout == 0) {
        return rerurnAlertMessage = @"退款金额为零,是否继续? ";
    }else if([self compareActualRefundAmountAndRefundAmout])//计算实际退款金额与应对金额是否一致
    {
        return rerurnAlertMessage = @"退款金额≠应退金额 是否继续？";
    }else if(self.defultSendIntegral != self.sendIntegral)//判断赠送赠送退还的积分与应扣金额是否一致
    {
        return rerurnAlertMessage = @"赠送退还的积分与应扣金额不一致， 是否继续？";
    }else if(self.defultSendCashCoupon != self.sendCashCoupon)//判断赠送赠送退还的现金券与应扣金额是否一致
    {
        return rerurnAlertMessage = @"赠送退还的现金券与应扣金额不一致， 是否继续？";
    }else if(!self.isComissionCalc.boolValue)//不显示提成比例时不提示
    {
        return rerurnAlertMessage =  @"";
    }else if(self.slaveArray.count == 0){
        return rerurnAlertMessage = @"本次退款的业绩参与人为空,是否继续? ";
    }else if(self.slaveArray.count > 0){
        //业绩参与不均分
        if(self.averageFlag == 0)
        {
            
            for (UserDoc *user in self.slaveArray) {
                rate += [user.user_ProfitPct doubleValue];
            }
            
            if(rate !=100)
            {
                return rerurnAlertMessage = @"业绩参与比例≠100%， 是否继续？";
            }
            else
            {
                return rerurnAlertMessage = @"";
                
            }
            
        }
        else
        {
            return rerurnAlertMessage = @"";
        }
    }else{
        return rerurnAlertMessage = @"";
    }
    
}
//
///** 退款 */
- (void)refundPay
{
    /*if (refundAmout == 0) {
        [SVProgressHUD showSuccessWithStatus:@"退款金额不能为零！"];
        return;
    }*/
    
    NSString *alterMessage = [NSString string];
    alterMessage = [self returnMessageByRefund];
    BOOL isNeedProfitRateAlter = NO;
    isNeedProfitRateAlter = [self needProfitRateAlter];
    if (isNeedProfitRateAlter) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:alterMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self refundPayReally];
            }
        }];
    }else{
        [self refundPayReally];
    }
    
}

-(void)refundPayReally{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    if(!refundRemark)
        refundRemark = @"";
    //组装退款数据
    /*if(self.paymentHistoryArray.count > 0){
        for(int i=0;i<self.paymentHistoryArray.count;i++){
            [self paymentRefundOperationArrayAdd:self.paymentHistoryArray[i]];
        }
    }*/
    
    NSMutableArray * paymentArr = [[NSMutableArray alloc] init];
    for (int i=0; i<chooseCardMuArr.count; i++) {
        if ([[cardMoneyArr objectAtIndex:i] doubleValue]>0) {
            NSDictionary *dic = @{@"UserCardNo":[[customerCardListMuArr objectAtIndex:i] objectForKey:@"UserCardNo"],@"CardType":@1,@"PaymentMode":@1,@"PaymentAmount":@([[cardMoneyArr objectAtIndex:i] doubleValue])};
            [paymentArr addObject:dic];
        }
    }
    
    for (int i=0; i<choosePaymentMuArr.count; i++) {//判断选中的支付方式，选中的列入数组
        if ([[choosePaymentMuArr objectAtIndex:i] integerValue]) {//为1选中
            switch (i) {
                case 0://--现金
                {
                    if (cashMoney>0) {
                        NSDictionary *dic = @{@"PaymentMode":@0,@"PaymentAmount":@((double)cashMoney)};
                        [paymentArr addObject:dic];
                    }
                }
                    break;
                case 1://--其他
                {
                    if (otherMoney>0) {
                        NSDictionary *dic = @{@"PaymentMode":@3,@"PaymentAmount":@((double)otherMoney)};
                        [paymentArr addObject:dic];
                    }
                }
                    break;
                case 2://--积分
                {
                    if (integral>0) {
                        NSDictionary *dic = @{@"UserCardNo":[intergralCardDic objectForKey:@"UserCardNo"] ,@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((double)integral)};
                        [paymentArr addObject:dic];
                    }
                }
                    break;
                case 3://--现金券
                {
                    if (cashCoupon>0) {
                        NSDictionary *dic = @{@"UserCardNo":[cashCardDic objectForKey:@"UserCardNo"] ,@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((double)cashCoupon)};
                        [paymentArr addObject:dic];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    NSMutableArray * giveArr = [[NSMutableArray alloc] init];
    if (sendCashCoupon >0) {
        NSDictionary *dicSend = @{@"UserCardNo":[cashCardDic objectForKey:@"UserCardNo"],@"CardType":@3,@"PaymentMode":@7,@"PaymentAmount":@((long)sendCashCoupon)};
        [giveArr addObject:dicSend];
    }
    if (sendIntegral >0) {
        NSDictionary *dicSend = @{@"UserCardNo":[intergralCardDic objectForKey:@"UserCardNo"],@"CardType":@2,@"PaymentMode":@6,@"PaymentAmount":@((double)sendIntegral)};
        [giveArr addObject:dicSend];
    }
    //    NSDictionary * par = @{
    //                           @"OrderID":@(self.orderID),
    //                           @"TotalPrice": @((double)refundAmout),
    //                           @"Remark":refundRemark,
    //                           @"CustomerID":@((long)self.customerId),
    //                           @"SlaveID":self.slaveID,
    //                           @"PaymentDetailList":paymentArr,
    //                           @"GiveDetailList":giveArr
    //                           };
    
    NSDictionary * par = @{
                           @"OrderID":@(self.orderID),
                           @"TotalPrice": @((double)refundAmout),
                           @"AverageFlag":@(self.averageFlag),
                           @"Remark":refundRemark,
                           @"CustomerID":@((long)self.customerId),
                           @"Slavers":[self gettingSlavers],
                           @"PaymentDetailList":paymentArr,
                           @"GiveDetailList":giveArr
                           };
    
    /*NSDictionary * par = @{
                           @"PaymentRefundOperationList":paymentRefundOperationArray
                           };*/
    _RefundPayOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/RefundPay" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } failure:^(NSError *error) {
        
    }];
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
    refundRemark = contentText.text;
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
    
    NSIndexPath *indexRemark = [stopOrderTableView indexPathForCell:cell];
    
    refundRemark = contentText.text;
    
    if (indexRemark.row == 1 ) {
        [stopOrderTableView beginUpdates];
        [stopOrderTableView endUpdates];
    }
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [stopOrderTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [stopOrderTableView scrollRectToVisible:newCursorRect animated:YES];
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


/**显示卡的余额*/
-(void)checkCardBalance:(NSInteger)chooseSection
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"账户余额" NumberOfRows:^NSInteger(NSInteger section) {
        return  2;
        
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
            
            if (indexPath.row == 0) {
                label.text = [NSString stringWithFormat:@"积分(%.2Lf)",_intergralPresentRate];
                balanceLabel.text =[NSString stringWithFormat:@"%.2f",[[intergralCardDic objectForKey:@"Balance"] doubleValue]];
            }else
            {
                label.text = [NSString stringWithFormat:@"现金券(%.2Lf)",_cashCouponPresentRate];
                balanceLabel.text =[NSString stringWithFormat:@"%@ %.2f",MoneyIcon,[[cashCardDic objectForKey:@"Balance"]doubleValue]];
            }
//            }else
//            {
//                label.text = [[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"CardName"];
//                balanceLabel.text =[NSString stringWithFormat:@"%@ %.2f",MoneyIcon,[[[customerCardListMuArr objectAtIndex:indexPath.row] objectForKey:@"Balance"] doubleValue]];
//            }
        }
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        
    } Completion:^{
        
    }];
    
    [alert show];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
