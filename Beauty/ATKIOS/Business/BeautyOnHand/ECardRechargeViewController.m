//
//  ECardRechargeViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-10-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ECardRechargeViewController.h"
#import "WAmountConverter.h"
#import "DEFINE.h"
#import "UITextField+InitTextField.h"
#import "UIPlaceHolderTextView.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "UILabel+InitLabel.h"
#import "AppDelegate.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "FooterView.h"
#import "UserDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "NSData+Base64.h"
#import "AccountCellTableViewCell.h"
#import "PayThirdForWeiXin_ViewController.h"
#import "PerformanceTableViewCell.h"

typedef NS_ENUM(NSInteger, COUNSELORTYPE) {
    COUNSELORPERSON = 0,
    COUNSELORSLAVE = 1
};
@interface ECardRechargeViewController ()<PerformanceTableViewCellDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestRechargeOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetBasicInfoOperation;

@property (assign, nonatomic) long double rechargeMoney;
@property (assign, nonatomic) long

double presentedMoney;
@property (nonatomic, assign) NSInteger cusCount;
@property (assign, nonatomic) NSInteger rechargeWay;//DepositMode0/1/2/3分别应对应：赠送/现金/银行卡/余额转入
@property (strong, nonatomic) NSString *rechargeRemark;
@property (strong, nonatomic) UserDoc *userDoc;
@property (nonatomic, strong) NSArray *rechargeArray;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (nonatomic, assign) COUNSELORTYPE type;
@property (nonatomic, strong) NSMutableArray *slaveArray;
//@property (nonatomic, strong) NSMutableString *slaveNames;
//@property (nonatomic, strong) NSMutableString *slaveID;
@property (nonatomic ,assign) long double integralDouble;
@property (nonatomic ,assign) long double cashCouponDouble;
@property (nonatomic,assign) NSInteger selectionNumber;
@property (nonatomic , assign) NSInteger selectIndex;
@property (nonatomic, assign)  BOOL showWeChat;
@property (nonatomic, assign)  BOOL showAliPay;

@end

@implementation ECardRechargeViewController
@synthesize myTableView;
@synthesize eCardBalance;
@synthesize presentedMoney;
@synthesize rechargeMoney, rechargeRemark, rechargeWay, userDoc;
@synthesize cusCount;
@synthesize rechargeArray;
@synthesize type;
@synthesize slaveArray;
//@synthesize slaveNames, slaveID;
@synthesize  cashCouponDouble,integralDouble;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];


}

- (void)keyboardDidShown:(NSNotification *)obj
{
    NSLog(@"keyboardDidShown:");
}
- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    if (_requestRechargeOperation || [_requestRechargeOperation isExecuting]) {
        [_requestRechargeOperation cancel];
        _requestRechargeOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [self initTableView];
    [self initData];
    [self requesCustomertList];
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"账户充值"];
    [self.view addSubview:navigationView];
    
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView  = nil;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    if (IOS7 || IOS8) {
        myTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(requestRecharge)];
    [footerView showInTableView:myTableView];
    
    _initialTVHeight = myTableView.frame.size.height;
}

- (void)initData
{
    self.rechargeArray = @[@"现金", @"银行卡",@"微信",@"支付宝", @"余额转入"];
    cusCount = 1;
    rechargeWay = 1;
    if (RMO(@"|5|"))
    {
        self.showWeChat = YES;
    }else
    {
        self.showWeChat = NO;
    }
    if (RMO(@"|6|"))
    {
        self.showAliPay = YES;
    }else
    {
        self.showAliPay = NO;
    }

    self.selectIndex = 0;
    rechargeMoney = 0.00f;
    presentedMoney = 0.00f;
    rechargeRemark = @"";
    integralDouble = 0.00f;
    cashCouponDouble = 0.00f;
    
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    
    userDoc.user_SelectedState = YES;
    
    self.slaveArray = [[NSMutableArray alloc] init];
    
//    self.slaveNames = [NSMutableString string];
//    self.slaveID = [NSMutableString string];
}

//- (NSString *)slaveNames
//{
//    NSMutableArray *nameArray = [NSMutableArray array];
//    if (self.slaveArray.count) {
//        for (UserDoc *user in self.slaveArray) {
//            [nameArray addObject:user.user_Name];
//        }
//    }
//    return [nameArray componentsJoinedByString:@"、"];
//}
//
//
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
//    NSLog(@"str is %@", str);
//    return slaveIdArray;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.selectionNumber = 5;
    if (rechargeWay ==3) {
        self.selectionNumber = 4;
        return 4;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (self.rechargeWay == 3 ? 1 : (2 + self.slaveArray.count));
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return (self.rechargeWay == 3 ? 2: 4);
    }
    else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.rechargeWay == 3) {
       if (indexPath.section == 3 && indexPath.row == 1)
           return 90.0f;
    }
    if (indexPath.section == 4 && indexPath.row == 1) {
        return 90.0f;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentity = @"NormalEditCell_NotEditing";
    NSString *cellIdentity = [NSString stringWithFormat:@"NormalEditCell_NotEditing%@",indexPath];
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.valueText.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.valueText.textColor = [UIColor blackColor];
    }
    
//    static NSString *editIdentity = @"NormalEditCell_Editing";
    NSString *editIdentity =  [NSString stringWithFormat:@"NormalEditCell_Editing%@",indexPath];
    NormalEditCell *editCell = [tableView dequeueReusableCellWithIdentifier:editIdentity];
    if (editCell == nil) {
        editCell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        editCell.valueText.delegate = self;
        editCell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
        editCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    AccountCellTableViewCell *accountCell = [tableView dequeueReusableCellWithIdentifier:editIdentity];
    if (accountCell == nil) {
        accountCell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        accountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        accountCell.titleNameLabel.textColor = kColor_DarkBlue;
        accountCell.titleNameLabel.font = kFont_Medium_16;
        accountCell.contentText.textColor = [UIColor blackColor];
        accountCell.contentText.font = kFont_Light_16;
        accountCell.contentText.userInteractionEnabled = NO;
        accountCell.contentText.textColor = kColor_Editable;
        [accountCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
            cell.titleLabel.text = @"顾客";
            cell.valueText.text = customer.cus_Name;
            return cell;
        }if (indexPath.row == 1) {
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [accountCell.contentView addSubview:arrowsImage];
            accountCell.titleNameLabel.text = @"业绩参与";
//            accountCell.contentText.text = ([self.slaveNames isEqualToString:@""] ? @"请选择业绩参与者  ": self.slaveNames);
            accountCell.contentText.text = @"请选择业绩参与者  ";
            return accountCell;
        }else{
            return [self configPerformanceProportionCell:tableView indexPath:indexPath];
        }
    }else if (indexPath.section == 1) {
        cell.titleLabel.text = @"余额";
        cell.valueText.text = MoneyFormat(eCardBalance);
        return cell;
    }else if (indexPath.section == 2) {
        if (self.rechargeWay == 3) {
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"充值方式";
                    cell.valueText.textColor = kColor_Editable;
                    cell.valueText.text = [self.rechargeArray objectAtIndex:4];
                    return cell;
                case 1:
                    editCell.titleLabel.text = @"转入金额";
                    editCell.valueText.text = rechargeMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", rechargeMoney];
                    editCell.valueText.placeholder = @"请输入转入金额";
                    editCell.valueText.tag = 1000;
                    if ((IOS7 || IOS8)) {
                        [editCell.valueText setTintColor:[UIColor blueColor]];
                    }
                    return editCell;
            }
        } else {
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"充值方式";
                    cell.valueText.textColor = kColor_Editable;
                    cell.valueText.text = [self.rechargeArray objectAtIndex:self.selectIndex];
                    return cell;
                case 1:
                    editCell.titleLabel.text = @"充值金额";
                    editCell.valueText.text =  rechargeMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", rechargeMoney];
                    editCell.valueText.placeholder = @"请输入充值金额";
                    editCell.valueText.tag = 1000 + TAG(indexPath);
                    if ((IOS7 || IOS8)) {
                        [editCell.valueText setTintColor:[UIColor blueColor]];
                    }
                    return editCell;
                case 2:
                    editCell.titleLabel.text = @"赠送金额";
                    editCell.valueText.text =  presentedMoney == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", presentedMoney];
                    editCell.valueText.placeholder = @"请输入赠送金额";
                    editCell.valueText.tag = 2000 + TAG(indexPath);
                    if ((IOS7 || IOS8)) {
                        [editCell.valueText setTintColor:[UIColor blueColor]];
                    }
                    return editCell;
                case 3:
                    cell.titleLabel.text = @"合计";
                    cell.valueText.text = [NSString stringWithFormat:@"%@ %.2Lf", MoneyIcon, rechargeMoney + presentedMoney];
                    cell.valueText.textColor = kColor_Black;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;

            }
        }
    }else {
        if (self.rechargeWay !=3) {
            if (indexPath.section ==3) {
                switch (indexPath.row) {
                    case 0:
                        editCell.titleLabel.text = @"赠送积分";
                        editCell.valueText.text =  integralDouble == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", integralDouble];
                        editCell.valueText.placeholder = @"请输入积分";
                        editCell.valueText.tag = 2000 + TAG(indexPath);
                        if ((IOS7 || IOS8)) {
                            [editCell.valueText setTintColor:[UIColor blueColor]];
                        }
                        return editCell;

                        break;
                        
                    case 1:
                        editCell.titleLabel.text = @"赠送现金券";
                        editCell.valueText.text =  cashCouponDouble == 0 ? @"" : [NSString stringWithFormat:@"%.2Lf", cashCouponDouble];
                        editCell.valueText.placeholder = @"请输入赠送现金券金额";
                        editCell.valueText.tag = 2000 + TAG(indexPath);
                        if ((IOS7 || IOS8)) {
                            [editCell.valueText setTintColor:[UIColor blueColor]];
                        }
                        return editCell;
                        break;
                        
                    default:
                        break;
                }
            }
        }
        if (indexPath.section == self.selectionNumber-1) {
            if (indexPath.row == 0) {
                cell.titleLabel.text = @"备注";
                cell.valueText.text = @"";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else {
                
                UILabel *accessoryLabel = [UILabel initNormalLabelWithFrame:CGRectMake(200.0f, 75.0f, 100.0f, 15.0f) title:[NSString stringWithFormat:@"%lu/200", (unsigned long)[rechargeRemark length]]];
                accessoryLabel.textColor = [UIColor blackColor];
                accessoryLabel.font = kFont_Light_14;
                accessoryLabel.textAlignment = NSTextAlignmentRight;
                accessoryLabel.tag = 101;
                
                static NSString *cellIdentity = @"ss";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
                cell.backgroundColor = [UIColor whiteColor];
                
                UIPlaceHolderTextView *textView = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(5.0f, 0.0f, 300.0f, 75.0f)
                                                                                                text:@""
                                                                                         placeHolder:@""];
                textView.tag = 102;
                textView.delegate = self;
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                    [cell.contentView addSubview:accessoryLabel];
                    [cell.contentView addSubview:textView];
                }
                return cell;
            }
        }
    }
    
    return cell;
}

#pragma mark -  配置cell
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
        userdoc= self.slaveArray[indexPath.row - 2];
        performanceCell.nameLab.text = userdoc.user_Name;
        performanceCell.numText.text = userdoc.user_ProfitPct;
    }
    return performanceCell;
}
#pragma mark - didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    if (indexPath.section == 0 && indexPath.row == 2) {
        self.type = COUNSELORPERSON;
        [self chosePersion:COUNSELORPERSON];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        self.type = 1;
        [self chosePersion:COUNSELORSLAVE];
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self selectionEcardWay];
    }
}
- (void)selectionEcardWay
{
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"现金", @"银行卡", nil];
     
     if (self.showWeChat) {
         [alertView addButtonWithTitle: @"微信"];
     }
     if (self.showAliPay) {
          [alertView addButtonWithTitle: @"支付宝"];
     }
     if([[PermissionDoc sharePermission] rule_BalanceCharge]){
         [alertView addButtonWithTitle: @"余额转入"];
     }
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        self.rechargeWay = buttonIndex;
        [self.myTableView reloadData];
    }];
    
   /*
   if (self.showWeChat && self.showAliPay) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"现金", @"银行卡",@"微信",@"支付宝", @"余额转入", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            self.rechargeWay = buttonIndex;
            [self.myTableView reloadData];
        }];
    }else if (self.showWeChat) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"现金", @"银行卡",@"微信",@"余额转入", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            self.rechargeWay = buttonIndex;
            [self.myTableView reloadData];
        }];

    }else if (self.showAliPay) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"现金", @"银行卡",@"支付宝", @"余额转入", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            self.rechargeWay = buttonIndex;
            [self.myTableView reloadData];
        }];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值方式" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"现金", @"银行卡", @"余额转入", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            self.rechargeWay = buttonIndex;
            [self.myTableView reloadData];
        }];
    }
    */
}

- (void)setRechargeWay:(NSInteger)reWay
{
    
//    if (!self.showWeChat && reWay ==3) {
//            reWay += 2;
//    }
   
    if (self.showWeChat && self.showAliPay) {
        switch (reWay) {
            case 1:
                rechargeWay = 1;
                self.selectIndex = 0;
                break;
            case 2:
                rechargeWay = 2;
                self.selectIndex = 1;
                break;
            case 3:
                rechargeWay = 8;
                self.selectIndex = 2;
                break;
            case 4:
                rechargeWay = 9;
                self.selectIndex = 3;
                break;
            case 5:
                rechargeWay = 3;
                self.selectIndex = 4;
                break;
            default:
                break;
        }

    }else if (self.showWeChat) {
        switch (reWay) {
            case 1:
                rechargeWay = 1;
                self.selectIndex = 0;
                break;
            case 2:
                rechargeWay = 2;
                self.selectIndex = 1;
                break;
            case 3:
                rechargeWay = 8;
                self.selectIndex = 2;
                break;
            case 4:
                rechargeWay = 3;
                self.selectIndex = 4;
                break;
            default:
                break;
        }

    }else if (self.showAliPay) {
        switch (reWay) {
            case 1:
                rechargeWay = 1;
                self.selectIndex = 0;
                break;
            case 2:
                rechargeWay = 2;
                self.selectIndex = 1;
                break;
            case 3:
                rechargeWay = 9;
                self.selectIndex = 3;
                break;
            case 4:
                rechargeWay = 3;
                self.selectIndex = 4;
                break;
            default:
                break;
        }

    }else{
        switch (reWay) {
            case 1:
                rechargeWay = 1;
                self.selectIndex = 0;
                break;
            case 2:
                rechargeWay = 2;
                self.selectIndex = 1;
                break;
            case 3:
                rechargeWay = 3;
                self.selectIndex = 4;
                break;
            default:
                break;
        }

    }

   
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
//    PerformanceTableViewCell *cell = (PerformanceTableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [myTableView indexPathForCell:cell];
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (indexPath.row > 0) {
        UserDoc *user =self.slaveArray[indexPath.row - 2];
        user.user_ProfitPct = textField.text;
    }
//    [textField resignFirstResponder];
//    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 选择美丽顾问 选择业绩参与者
- (void)chosePersion:(COUNSELORTYPE)choseType
{
    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:self.type userType: (choseType == COUNSELORPERSON) ? 3 : 1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:(self.type == COUNSELORPERSON ? @[userDoc]:self.slaveArray)];
    selectCustomer.navigationTitle = (choseType == COUNSELORPERSON ? @"选择美丽顾问" : @"选择业绩参与者");
    selectCustomer.personType = (choseType == COUNSELORPERSON ? CustomePersonGroup : CustomePersonDefault);
    selectCustomer.delegate = self;
    selectCustomer.customerId = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    if (self.type == COUNSELORPERSON) {
        userDoc = [userArray firstObject];
        if (userDoc == nil)
            userDoc = [[UserDoc alloc] init];
    } else {
        self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    }
    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextField:textField];
    });
}

//add begin by zhangwei map GPB-918
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;

    if([textField text])
    {
        if(textField.text.length > 10)
            textField.text = [NSString stringWithString:[textField.text substringToIndex:10]];
    }
}
//add end by zhangwei map GPB-918
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;

    NSRange decRange = [textField.text rangeOfString:@"."];
    if (decRange.length && (textField.text.length - decRange.location > 2 || [string isEqualToString:@"."])) {
        return NO;
    }
    
    static NSCharacterSet *charSet = nil;
    if (charSet == nil) {
        charSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    __block BOOL result = YES;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring rangeOfCharacterFromSet:charSet].location == NSNotFound) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    if (textField.tag > 2000) {
        indexPath = INDEX((textField.tag % 2000));
    } else if (textField.tag > 1000) {
        indexPath = INDEX((textField.tag % 1000));
    } else {
        indexPath = [myTableView indexPathForCell:cell];
    }
    if (self.rechargeWay == 3) {
        if(indexPath.section == 2 && indexPath.row == 1) {
            rechargeMoney = [textField.text doubleValue];
        }
    } else {
        if(indexPath.section == 2 && indexPath.row == 1) {
            rechargeMoney = [textField.text doubleValue];
        } else if(indexPath.section == 2 && indexPath.row == 2) {
            presentedMoney = [textField.text doubleValue];
        }
    }
    
    if (indexPath.section ==3&&indexPath.row==0) {
        integralDouble = [textField.text doubleValue];
    }else if(indexPath.section ==3  &&indexPath.row==1)
    {
        cashCouponDouble = [textField.text doubleValue];
    }
    
//    NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:2];
//    if (self.rechargeWay == 3) {
//        [myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    } else {
//        [myTableView reloadRowsAtIndexPaths:@[path, indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
    [myTableView reloadData];
}

#pragma mark -  UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextView:textView];
    });
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self scrollToTextView:textView];
    
    rechargeRemark = textView.text;
   
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    
    rechargeRemark = textView.text;
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 200) {
                textView.text = [toBeString substringToIndex:200];
                rechargeRemark = textView.text;
            }
            label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 200) {
            textView.text = [toBeString substringToIndex:200];
            rechargeRemark = textView.text;
        }
        label.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)rechargeRemark.length];
    }
}


#pragma mark - Keyboard Notification
-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    myTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    myTableView.frame = tvFrame;
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

- (void)scrollToTextView:(UITextView *)textView
{
    if (self.rechargeWay ==3) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:3];
        [myTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:4];
        [myTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.myTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    [myTableView beginUpdates];
    [myTableView endUpdates];
}

#pragma mark UIScrollViewDelegate
//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
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

#pragma mark - 组装Slavers
-(NSMutableArray *)gettingSlavers
{
    NSMutableArray *tempsArrs = [NSMutableArray array];
    if (self.slaveArray.count >0) {
        for (int i = 0; i < self.slaveArray.count ; i ++) {
            UserDoc *user = self.slaveArray[i];
            if (user.user_ProfitPct == nil) {
                user.user_ProfitPct = @"0";
            }
            NSLog(@"user.user_ProfitPct == %@ user_Id == %ld",user.user_ProfitPct,(long)user.user_Id);
            NSDictionary *dic = @{@"SlaveID":@(user.user_Id),@"ProfitPct":@((user.user_ProfitPct.doubleValue / 100))};
            [tempsArrs addObject:dic];
        }
    }
    return tempsArrs;
}

#pragma mark - 接口

- (void)requestRecharge
{
    if (rechargeRemark == nil) {
        rechargeRemark = @" ";
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;
    
    if (kMenu_Type == 1 && customerID == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        return;
    }
    
    if (rechargeMoney == 0 && presentedMoney == 0 && self.rechargeWay != 3) {
        [SVProgressHUD showErrorWithStatus2:@"请输入充值金额!" touchEventHandle:^{}];
        return;
    }
    
    if (rechargeMoney == 0 && self.rechargeWay == 3) {
        [SVProgressHUD showErrorWithStatus2:@"请输入转入金额!" touchEventHandle:^{}];
        return;
    }
    
    /**
     *微信支付
     */
    if (rechargeWay == 8 || rechargeWay == 9) {
        
        if (rechargeMoney <= 0) {
            [SVProgressHUD showErrorWithStatus2:@"请输入充值金额!" touchEventHandle:^{}];
            return;
        }
        NSString *showMes = @"";
        if (self.rechargeWay == 8) {
            showMes = [NSString stringWithFormat:@"本次微信充值合计%@%.2Lf，%@。", MoneyIcon, rechargeMoney, [self convertByPayTotal:rechargeMoney]];
        } else if (self.rechargeWay == 9)  {
            showMes = [NSString stringWithFormat:@"本次支付宝充值合计%@%.2Lf，%@。", MoneyIcon, rechargeMoney, [self convertByPayTotal:rechargeMoney]];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:showMes delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSDictionary * par = @{
                                       @"CustomerID":@((long)customerID),
                                       @"Slavers":[self gettingSlavers],
                                       @"TotalAmount":@((double)rechargeMoney),
                                       @"PointAmount":@((double)integralDouble),
                                       @"CouponAmount":@((double)cashCouponDouble),
                                       @"Remark":[OverallMethods EscapingString:rechargeRemark],
                                       @"MoneyAmount":@((double)presentedMoney),
                                       @"UserCardNo":self.cardId,
                                       @"ResponsiblePersonID":@(0)
                                       };
                
                PayThirdForWeiXin_ViewController * payThird = [[PayThirdForWeiXin_ViewController alloc] init];
                payThird.thisPayPrice = rechargeMoney;
                payThird.para = par;
                payThird.orderComeFrom = 3;
                if (rechargeWay == 8) {
                    payThird.payType = PayTypeWeiXin;
                }
                if (rechargeWay == 9) {
                    payThird.payType = PayTypeZhiFuBao;
                }
                
                [self.navigationController pushViewController:payThird animated:YES];
            }
        }];
    }else {
        NSString *payTypeName = [self.rechargeArray objectAtIndex:self.selectIndex];

        NSString *showMes = @"";
        if (self.rechargeWay == 3) {
            showMes = [NSString stringWithFormat:@"本次转入合计%@%.2Lf，%@。", MoneyIcon, rechargeMoney, [self convertByPayTotal:rechargeMoney]];
        } else {
//            showMes = [NSString stringWithFormat:@"本次%@充值合计%@%.2Lf，%@。",payTypeName,MoneyIcon, rechargeMoney + presentedMoney, [self convertByPayTotal:rechargeMoney + presentedMoney]];
            showMes = [NSString stringWithFormat:@"本次%@充值合计%@%.2Lf，%@。",payTypeName,MoneyIcon, rechargeMoney, [self convertByPayTotal:rechargeMoney]];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:showMes delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [SVProgressHUD showWithStatus:@"Loading"];
                //现金
                NSDictionary * cashDic = @{@"CardType":@1,
                                           @"UserCardNo":self.cardId,
                                           @"Amount":@((double)presentedMoney)
                                           };
                //积分
                NSDictionary * integralDic = @{@"CardType":@2,
                                        @"UserCardNo":self.intergralNO ==nil?@"0":self.intergralNO,
                                        @"Amount":@((double)integralDouble)};
                //现金券
                NSDictionary * cashCouponDic = @{@"CardType":@3,
                                        @"UserCardNo":self.cashCouponNO ==nil?@"0":self.cashCouponNO,
                                        @"Amount":@((double)cashCouponDouble)};
                NSMutableArray * arr = [[NSMutableArray alloc] initWithObjects:cashDic,integralDic,cashCouponDic, nil];
                
                NSDictionary * otherDic;
                if (self.rechargeWay ==3) { // 余额转入不业绩参数人
                    [arr removeAllObjects];
                    otherDic =@{
                                               @"ChangeType":@3,
                                               @"CardType":@1,
                                               @"DepositMode":@(self.rechargeWay),
                                               @"UserCardNo":self.cardId,
                                               @"CustomerID":@((long)customerID),
                                               @"ResponsiblePersonID":@(0),
                                               @"Amount":@((double)rechargeMoney),
                                               @"Remark":[OverallMethods EscapingString:rechargeRemark],
                                               @"GiveList":arr
                                               };
                }else{
                    otherDic =@{
                                @"ChangeType":@3,
                                @"CardType":@1,
                                @"DepositMode":@(self.rechargeWay),
                                @"UserCardNo":self.cardId,
                                @"CustomerID":@((long)customerID),
                                @"ResponsiblePersonID":@(0),
                                @"Amount":@((double)rechargeMoney),
                                @"Remark":[OverallMethods EscapingString:rechargeRemark],
                                @"Slavers":[self gettingSlavers],
                                @"GiveList":arr
                                };
                }
//                NSDictionary * otherDic =@{
//                                            @"ChangeType":@3,
//                                            @"CardType":@1,
//                                            @"DepositMode":@(self.rechargeWay),
//                                            @"UserCardNo":self.cardId,
//                                            @"CustomerID":@((long)customerID),
//                                            @"ResponsiblePersonID":@(0),
//                                            @"Amount":@((double)rechargeMoney),
//                                            @"Remark":[OverallMethods EscapingString:rechargeRemark],
//                                            @"Slavers":[self gettingSlavers],
//                                            @"GiveList":arr
//                                           };
                
                _requestRechargeOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/CardRecharge" andParameters:otherDic failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                    [SVProgressHUD dismiss];
                    [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
                        NSLog(@"cardrecharge =%@",data);
                        [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } failure:^(NSInteger code, NSString *error) {
                    }];
                } failure:^(NSError *error) {
                    
                }];
            }

        }];
    }
}


- (void)requesCustomertList
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    
    if (customerId == 0 && kMenu_Type == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择顾客" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerId];
    
    _requestGetBasicInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerBasic" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [self.slaveArray removeAllObjects];
            NSArray *tempArr = [data objectForKey:@"SalesList"];
            if (![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                for (NSDictionary * dic in [data objectForKey:@"SalesList"]) {
                    UserDoc * user = [[UserDoc alloc] init];
                    
                    user.user_Name = [dic objectForKey:@"SalesName"];
                    user.user_Id = [[dic objectForKey:@"SalesPersonID"] integerValue];
                    
                    [self.slaveArray addObject:user];
                    
                }

            }
            
            [self.myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}




@end
