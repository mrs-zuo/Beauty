//
//  PayConfirmViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/7/16.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "PayConfirmViewController.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "NormalEditCell.h"
#import "GPBHTTPClient.h"
#import "WAmountConverter.h"
#import "SelectCustomersViewController.h"
#import "UserDoc.h"
#import "OrderDoc.h"
#import "PayInfoViewController.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "ColorImage.h"
#import "PerformanceTableViewCell.h"


@interface PayConfirmViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate,SelectCustomersViewControllerDelegate,UITextFieldDelegate,PerformanceTableViewCellDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *getAllLevelOperation;
@property (weak ,nonatomic) AFHTTPRequestOperation *getPaymentInfoOperation;
@property (weak ,nonatomic) AFHTTPRequestOperation *requestUpdatePrice;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (assign, nonatomic) CGFloat table_Height;
@property (nonatomic,strong) UITextField * selectCardTextField;
@property (nonatomic,strong) NSArray * cardArr;
@property (nonatomic, strong) NSMutableArray *slaveArray;
@property (strong, nonatomic) UserDoc *userDoc;
@property (nonatomic, strong) UserDoc *salesDoc;
//@property (nonatomic, strong) NSMutableString *slaveNames;
//@property (nonatomic, strong) NSMutableString *slaveID;
@property (nonatomic, strong)NSString * cardSelectName;
@property (nonatomic, assign) double needPay;
@property (nonatomic ,assign) double VIPCardPrice;
@property (nonatomic ,assign) double TotalSalePrice;
@property (nonatomic ,strong) NSString * userCardNO;
@property (assign, nonatomic) double totalMoney;
@property (assign, nonatomic) double favorable;//应付款
@property (assign, nonatomic) NSInteger orderId;
@property (assign, nonatomic) NSInteger orderObjectID;
@property (nonatomic ,strong) NSString *  defultCardNo;
@property (nonatomic ,assign) NSInteger MarketingPolicy;
@property (nonatomic ,assign) double PromotionPrice;
@property (nonatomic,assign)  NSInteger Quantity;//商品数量

///业绩参与人字典
@property (nonatomic,strong) NSMutableDictionary *personDic;

@end

@implementation PayConfirmViewController

@synthesize myTableView,pickerView,accessoryInputView;
@synthesize table_Height,selectCardTextField;
@synthesize cardArr,userDoc,cardSelectName;
@synthesize needPay;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification  object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


//- (NSString *)slaveNames
//{
//    NSMutableArray *nameArray = [NSMutableArray array];
//    if (self.slaveArray.count) {
//        for (UserDoc *user in self.slaveArray) {
//            [nameArray addObject:user.user_Name];
//        }
//    }
//    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
//    return [nameArray componentsJoinedByString:@"、"];
//}
//
//- (NSString *)slaveID
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
//    return str;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"结账"];
    [self.view addSubview:navigationView];
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView  = nil;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        myTableView.sectionFooterHeight = 0;
        myTableView.sectionHeaderHeight = 10;
    }
    [self.view addSubview:myTableView];
    myTableView.separatorInset = UIEdgeInsetsZero;
    table_Height = myTableView.frame.size.height;
    
    FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"下一步" submitAction:@selector(gotoNextView) deleteTitle:@"返    回" deleteAction:@selector(goBackView)];
    
    [footerView.deleteButton setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
    [footerView showInTableView:myTableView];
    
    [self initdata];
    [self initPickerView];
    [self initInputAccessoryView];
    [self getPaymentInfoByJson];
}

-(void)goBackView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initdata
{
    needPay = self.TotalSalePrice;
    userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = ACC_ACCOUNTID;
    userDoc.user_Name = ACC_ACCOUNTName;
    userDoc.user_SelectedState = YES;
    _userCardNO = @"";
    _defultCardNo = @"";
    
    self.slaveArray = [NSMutableArray array];
//    self.slaveNames = [NSMutableString string];
//    self.slaveID = [NSMutableString string];
    self.salesDoc = [[UserDoc alloc] init];
    
    [[PermissionDoc sharePermission] setRule_IsAccountPayEcard:NO];
    cardSelectName = @"会员价";
    self.personDic = [NSMutableDictionary dictionary];
}

-(void)gotoNextView
{
    if ( needPay < 0) {
        [SVProgressHUD showSuccessWithStatus2:@"支付金额不合法,请重新输入。" touchEventHandle:^{}];
        return;
    }
    if (needPay ==0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"成交价格为0确认修改？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self updateTotalSalePrice:needPay];
            }
        }];
    }else
    {
        NSLog(@"nedepay =%f ,  totalsale =%f",needPay,self.TotalSalePrice);
        [self updateTotalSalePrice:needPay];
    }
    
}
-(void)gotoPayInfoView
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PayInfoViewController *payInfoController = [sb instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
    payInfoController.orderNumbers = 1;
    payInfoController.makeStateComplete = 0;
    payInfoController.paymentOrderArray =self.paymentOrderArray;
    payInfoController.customerId = self.customerId;
    payInfoController.comeFrom = self.comeFrom;
    payInfoController.singleOrderSlaveArray = self.slaveArray;
//    payInfoController.slaveArray = self.slaveArray ;
    [self.navigationController pushViewController:payInfoController animated:YES];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
            return 2;
    }
    else if(section ==1)
        return 2;
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kTableView_HeightOfRow;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [NSString stringWithFormat:@"NormalEditCell_NotEditing%@",indexPath];
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.valueText.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.textColor = [UIColor blackColor];
    if (indexPath.section ==0) {
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"订单数量";
            cell.valueText.text = [NSString stringWithFormat:@"%ld",(long)self.orderNumbers];

        }else if (indexPath.row == 1) {
            cell.titleLabel.text =@"总计金额";
            cell.valueText.text  = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,self.VIPCardPrice];
        }
        /*
        else if (indexPath.row == 2) {
            cell.titleLabel.text =@"业绩参与";
            cell.valueText.text  = @"请选择业绩参与人";
        }else{
            return [self configPerformanceProportionCell:tableView indexPath:indexPath];
        }
         */

    }else if(indexPath.section ==1)
    {
        if (indexPath.row == 0) {
            if (self.payStatus == 1) {
                selectCardTextField  = [[UITextField alloc] initWithFrame:CGRectMake(310-100, kTableView_HeightOfRow/2 - 20.0f/2, 100, 20.0f)];
                selectCardTextField.font = kFont_Light_16;
                selectCardTextField.delegate = self;
                selectCardTextField.tag = 103;
                if (IOS7 || IOS8) {
                    selectCardTextField.tintColor = [UIColor clearColor];
                }
                
                if (self.payStatus == 1) {
                    selectCardTextField.userInteractionEnabled = YES;
                }
                [selectCardTextField setInputView:pickerView];
                [selectCardTextField setInputAccessoryView:accessoryInputView];
                [cell.contentView addSubview:selectCardTextField];
            }
            if (cardArr.count ==0) {
                selectCardTextField.userInteractionEnabled = NO;
            }
            cell.titleLabel.text = @"e卡账户";
            cell.valueText.textColor = kColor_Editable;
            cell.valueText.text = [NSString stringWithFormat:@"%@", [cardSelectName isEqualToString:@""]?  @"不使用e账户":cardSelectName];
            
        } else {
            cell.titleLabel.text = @"会员价";
            cell.valueText.text  = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,self.VIPCardPrice];
            
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                /*
                if (self.payStatus == 1) {
                    cell.valueText.userInteractionEnabled = YES ;
                    cell.valueText.enabled = YES;
                    cell.valueText.textColor = kColor_Editable;
                    cell.valueText.delegate = self;
                    cell.valueText.keyboardType = UIKeyboardTypeDecimalPad;
                    cell.valueText.tag = 102;
                }
                */
                cell.titleLabel.text =  @"应付款";
                cell.valueText.userInteractionEnabled = NO;
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor redColor];
                cell.valueText.placeholder = @"0.00";
                cell.valueText.text  = needPay > 0?[NSString stringWithFormat:@"%@ %.2f",MoneyIcon,needPay]:@"";
                cell.valueText.clearButtonMode = UITextFieldViewModeWhileEditing;
                break;
            case 1:{
                NSString *valueStr =  [self convertByPayTotal:needPay];
                cell.titleLabel.text =@"大写";
                cell.valueText.text  = valueStr;
            }
                break;
                
            default:
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self choosePerson];
    }
}

#pragma mark - 配置业绩参与人比例Cell
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    UserDoc *userdoc;
    performanceCell.numText.enabled = NO;
    performanceCell.numText.hidden = YES;
    performanceCell.percentLab.hidden = YES;
    if (self.slaveArray.count > 0) {
        userdoc = self.slaveArray[indexPath.row - 3];
        performanceCell.nameLab.text = userdoc.user_Name;
        performanceCell.numText.text = userdoc.user_ProfitPct;
    }
    return performanceCell;
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
    NSIndexPath *indexPath = [myTableView indexPathForCell:cell];
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (indexPath.row > 0) {
        UserDoc *user =self.slaveArray[indexPath.row - 3];
        user.user_ProfitPct = textField.text;
    }
}

#pragma mark - 选择业绩参与者
- (void)choosePerson {
    
    [self.view endEditing:YES];
    
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

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.slaveArray = [NSMutableArray arrayWithArray:userArray];
    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)initPickerView
{
    if (pickerView == nil) {
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [pickerView setShowsSelectionIndicator:YES];
        [pickerView sizeThatFits:CGSizeZero];
        pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        pickerView.delegate = self;
        pickerView.dataSource = self;
    }
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 30.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)done
{
    [self dismissKeyBoard];
}

- (void)dismissKeyBoard
{
    [self.view endEditing:YES];
    [selectCardTextField resignFirstResponder];
    [self restoreHeightOfTableView];
}

//恢复tableView的高度
- (void)restoreHeightOfTableView
{
    if (myTableView.frame.size.height != table_Height) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = myTableView.frame;
        tableFrame.size.height =  table_Height;
        myTableView.frame = tableFrame;
        [UIView commitAnimations];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag ==102)//本次支付
    {
        textField.text = [NSString stringWithFormat:@"%.2f",needPay];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag ==102)//本次支付
    {
        needPay = [textField.text doubleValue];
        
    }else{//选卡
        NSInteger row = [pickerView selectedRowInComponent:0];
        if(row == 0){
            cardSelectName = @"不使用e账户";
            self.VIPCardPrice = self.totalMoney;//会员价格
            needPay = self.totalMoney;//会员价格
            self.userCardNO = @"";
        }else{
            if (self.MarketingPolicy ==2) {//促销价格
                cardSelectName = [[cardArr objectAtIndex:row-1] objectForKey:@"CardName"];
                float discount = [[[cardArr objectAtIndex:row-1] objectForKey:@"Discount"] doubleValue];
                self.VIPCardPrice = (self.PromotionPrice * discount)*self.Quantity;//会员价格
                needPay = self.VIPCardPrice;//会员价格
                self.userCardNO = [[cardArr objectAtIndex:row-1] objectForKey:@"UserCardNo"];
            }else{
                cardSelectName = [[cardArr objectAtIndex:row-1] objectForKey:@"CardName"];
                float discount = [[[cardArr objectAtIndex:row-1] objectForKey:@"Discount"] doubleValue];
                self.VIPCardPrice = self.totalMoney * discount;//会员价格
                needPay = self.totalMoney * discount;//会员价格
                self.userCardNO = [[cardArr objectAtIndex:row-1] objectForKey:@"UserCardNo"];
            }
        }
    }
    [myTableView reloadData];
}

#pragma mark - Keyboard Notification
-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height - initialFrame.size.height + 5.0f;
    myTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height;
    myTableView.frame = tvFrame;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

//add begin by zhangwei map GPB-918
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.text.length > 10)
        return NO;
    
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString =  textField.text;
    
    if (toBeString.length > 10)
        textField.text = [toBeString substringToIndex:10];
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

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - UIPickerDelegate && UIPickerDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (cardArr.count ==0) {
        return 0;
    }
    return [cardArr count]+1;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row ==0) {
        
        return @"不使用e账户";
        
    }else if([[[cardArr objectAtIndex:row-1] objectForKey:@"Discount"] doubleValue] ==1)
    {
        return [NSString stringWithFormat:@"%@",[[cardArr objectAtIndex:row-1] objectForKey:@"CardName"]];
    }
    return [NSString stringWithFormat:@"%@ (%.2f)",[[cardArr objectAtIndex:row-1] objectForKey:@"CardName"],[[[cardArr objectAtIndex:row-1] objectForKey:@"Discount"] doubleValue]];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0f;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

//修改订单优惠价格
- (void)updateTotalSalePrice:(double)price
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    NSLog(@"nedde pay =%f",needPay);
    OrderDoc * orde = [_paymentOrderArray objectAtIndex:0];
    NSDictionary * par = @{
                           @"UserCardNo":self.userCardNO,
                           @"OrderID":@((long)orde.order_ID),
                           @"totalSalePrice":@(needPay),
                           @"OrderObjectID":@((long)orde.order_ObjectID),
                           @"ProductType":@((long)self.productType)
                           };
    _requestUpdatePrice = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTotalSalePrice" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            //            NSLog(@"data price =%@",data);
            if (needPay ==0) {
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [self gotoPayInfoView];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

//获取用户储值卡折扣列表
- (void)GetCardDiscountList:(long long)ProductCode
{
    NSDictionary * par =@{
                          @"CustomerID":@((long)self.customerId),
                          @"ProductCode":@((long long)ProductCode),
                          @"ProductType":@((long)self.productType)
                          };
    _getAllLevelOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardDiscountList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            cardArr = data;
            NSLog(@"card =%@",cardArr);
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [myTableView reloadData];
        }];
    } failure:^(NSError *error) {
        
    }];
}

-(void)getPaymentInfoByJson{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    //构造order ID list [1212,]
    NSMutableString *orderIdJsonStr = [NSMutableString string];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (OrderDoc *order in _paymentOrderArray) {
        
        if([order isEqual:[_paymentOrderArray lastObject]])
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
            self.TotalSalePrice = [[data objectForKey:@"TotalSalePrice"] doubleValue];
            self.VIPCardPrice = [[data objectForKey:@"TotalCalcPrice"] doubleValue];
            self.cardSelectName = [data objectForKey:@"CardName"];
            self.totalMoney = [[data objectForKey:@"TotalOrigPrice"] doubleValue];
            self.needPay = [[data objectForKey:@"TotalSalePrice"] doubleValue];
            self.userCardNO = [data objectForKey:@"UserCardNo"];
            _defultCardNo = [data objectForKey:@"UserCardNo"];
            self.MarketingPolicy = [[data objectForKey:@"MarketingPolicy"] integerValue];
            self.PromotionPrice = [[data objectForKey:@"PromotionPrice"] doubleValue];
            self.Quantity = [[data objectForKey:@"Quantity"] integerValue];
            
            [[PermissionDoc sharePermission] setRule_IsAccountPayEcard:[[data objectForKey:@"IsPay"] boolValue]];
            [[PermissionDoc sharePermission] setRule_Part_Pay:[[data objectForKey:@"IsPartPay"] boolValue]];

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
            [self GetCardDiscountList:[[data objectForKey:@"ProductCode"] longLongValue]];
            
        } failure:^(NSInteger code, NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:(error.length ? error : @"获取支付信息失败，请重试！") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
