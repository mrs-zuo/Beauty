        //
//  RechargeViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-14.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RechargeViewController.h"
#import "RechargeAndPayViewController.h"
#import "RechargeCell.h"
#import "RechargeEditCell.h"
#import "StoredValueCardDoc.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "UILabel+InitLabel.h"
#import "UIImageView+WebCache.h"
#import "DEFINE.h"
#import "ECardRechargeViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "ECardOutViewController.h"
#import "GPBHTTPClient.h"
#import "EcardInfo.h"
#import "TwoLabelCell.h"
#import "NSDate+Convert.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AccountIntegralRecharge_ViewController.h"
#import "AccountIntegralOut_ViewController.h"
#import "FooterView.h"
#import "ThirdPatmentRecords_ViewController.h"
#import "UIButton+InitButton.h"
#import "UIButton+WebCache.h"
#import "ChangeECardViewController.h"


#define RECHARGE_FLAG ([[PermissionDoc sharePermission] rule_CustomerLevel_Write])  // ACC_BRANCHID != 0 && PermissionDoc sharePermission] rule_Recharge_Use 20150816 修改充值权限：非总公司账号并有充值权限

@interface RechargeViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getBalanceOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getTwoDimensionalCodeOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getAllLevelOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateExpirationTime;
@property (weak, nonatomic) AFHTTPRequestOperation *setDefaultcardOperation;

@property (nonatomic) UITextField *textField_Selected;
@property (assign, nonatomic) CGFloat tableView_Height;
@property (assign, nonatomic) long double balance;
@property (nonatomic) NSString *level;
@property (nonatomic) NSString *discount;
@property (nonatomic) NSString *eCardExpirationTime;
@property (nonatomic) NSArray *pickerData;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSDate *oldDate;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIToolbar *accessoryInputView;

@property (nonatomic, assign) NSInteger levelId;

@property (retain, nonatomic) NSString *twoDimensionalCodeURL;
@property (nonatomic) UIImageView *TwoDimensionalCodeImageView;
@property (nonatomic) UIImageView *customerHeadImage;

@property (strong, nonatomic) NSArray *levelIdArray;
@property (strong, nonatomic) NSArray *levelNameArray;
@property (strong, nonatomic) NSArray *levelDiscountArray;
@property (strong, nonatomic) UITextField *textField_Editing;
@property(nonatomic,assign)NSString * typeTitle;
@property (nonatomic,strong)NSDictionary * cardInfoDic;
@property (nonatomic,strong)NSArray * accountGradeArr;
@property (strong, nonatomic) NSString *remarkString;
@property(nonatomic)NavigationView *navigationView;


- (NSIndexPath *)indexPathForCell:(UITextField *)textField;
- (int)indexForArray:(NSArray *)array str:(NSString *)str;
@end

@implementation RechargeViewController
@synthesize textField_Selected;
@synthesize tableView_Height;
@synthesize balance, level, discount;
@synthesize pickerData;
@synthesize pickerView, accessoryInputView;
@synthesize levelId;
@synthesize twoDimensionalCodeURL;
@synthesize TwoDimensionalCodeImageView;
@synthesize customerHeadImage;
@synthesize levelIdArray;
@synthesize levelNameArray;
@synthesize levelDiscountArray;
@synthesize datePicker,inputAccessoryView,cardInfoDic,accountGradeArr;
@synthesize remarkString;
@synthesize navigationView;

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
//    [self requestPayInfo];
    [self requestCardInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    if (_getBalanceOperation || [_getBalanceOperation isExecuting]) {
        [_getBalanceOperation cancel];
        _getBalanceOperation = nil;
    }
    
    if (_getTwoDimensionalCodeOperation || [_getTwoDimensionalCodeOperation isExecuting]) {
        [_getTwoDimensionalCodeOperation cancel];
        _getTwoDimensionalCodeOperation = nil;
    }
    
    if (_getAllLevelOperation || [_getAllLevelOperation isExecuting]) {
        [_getAllLevelOperation cancel];
        _getAllLevelOperation = nil;
    }
    
    if (_requestUpdateExpirationTime || [_requestUpdateExpirationTime isExecuting]) {
        [_requestUpdateExpirationTime cancel];
        _requestUpdateExpirationTime = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.type == 2) {
        _typeTitle = @"积分";
    }else if(self.type ==3 ){
        _typeTitle = @"现金券";
    }else
    {
        _typeTitle = @"账户";
    }
    [self initTableView];
   
//    [self requestTwoDimensionalCode];
    
}

#pragma mark -  按钮事件
- (void)changeCard
{
    ChangeECardViewController *changeVC = [[ChangeECardViewController alloc]init];
    if (self.defaultCard) {
        changeVC.cardNumber = self.userCardNo.length > 0 ? 1 : 0;
    }
    changeVC.userCardNo = self.userCardNo;
    changeVC.cardInfoDic = cardInfoDic;
    [self.navigationController pushViewController:changeVC animated:YES];
}
#pragma mark - init

- (void)initTableView
{
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:_typeTitle];
    [self.view addSubview:navigationView];
    
#pragma mark 权限
    if (self.type == 1) { //储值卡
        if ([[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
            [navigationView addButtonWithFrameWithTarget:self backgroundImage:[UIImage imageNamed:@"changeCard"] backGroundColor:nil title:nil frame:CGRectMake(280, 1, 36, 36) tag:1  selector:@selector(changeCard)];
        }
        [self.view addSubview:navigationView];
    }
     
    _tableView.allowsSelection = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
       _tableView.separatorInset = UIEdgeInsetsZero;
       self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  - 5.0f);
    }
     [self setDefultCardView];
    tableView_Height = _tableView.frame.size.height;
}

-(void)setDefultCardView
{
    NSLog(@"self.type =%d",self.type);
#pragma mark 权限 
    if (![[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
        return;
    }
    if (self.type== 1) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"设为默认卡" submitAction:@selector(setDefaultCard)];
        [footerView showInTableView:_tableView];
        
        footerView.hidden = YES;
        if (!self.defaultCard) {
            footerView.hidden = NO;
        }else
        {
            footerView.hidden = YES;
        }
    }
}

#pragma mark - Cutomer Method


- (NSIndexPath *)indexPathForCell:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    return [_tableView indexPathForCell:cell];
}

- (int)indexForArray:(NSArray *)array str:(NSString *)str
{
    for (int i=0; i< [array count]; i++) {
        NSString *tmpStr = [array objectAtIndex:i];
        if ([tmpStr isEqualToString:str]) {
            return i;
        }
    }
    return 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = [NSString stringWithFormat:@"RechargeEditCell%@",indexPath];
    RechargeEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[RechargeEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.backgroundColor = [UIColor whiteColor];
    }
    UIImageView * imageView = (UIImageView *)[cell viewWithTag:1006];
    imageView.hidden = YES;
    cell.titleNameLabel.textColor = kColor_DarkBlue;
    cell.titleNameLabel.font = kFont_Medium_16;
    cell.contentText.textColor = [UIColor blackColor];
    cell.contentText.font = kFont_Light_16;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    
    NSString *myCell = @"RechargeEditCell1";
    UITableViewCell *cellDefault = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (cellDefault == nil){
        cellDefault = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
        cellDefault.selectionStyle = UITableViewCellSelectionStyleNone;
        cellDefault.accessoryType = UITableViewCellAccessoryNone;
        cellDefault.selected = NO;
    }else
    {
        while ([cellDefault.contentView.subviews lastObject] != nil) {
            [(UIView*)[cellDefault.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    
    switch (indexPath.section) {
        case 0:
        {
            UIImageView *cartCheck = (UIImageView *)[cellDefault viewWithTag:827];
            if (cartCheck == nil) {
                
                UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 205)];
                cardImageView.image = [UIImage imageNamed:@"account_vip_card.png"];
                cardImageView.tag = 827;
                [cellDefault.contentView addSubview:cardImageView];
            }
            UILabel *companyCheck = (UILabel *)[cellDefault viewWithTag:828];
            if (companyCheck == nil) {
                UILabel *companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 42.5, 270, 30)];
                companyNameLabel.backgroundColor = [UIColor clearColor];
                companyNameLabel.text = [cardInfoDic objectForKey:@"CardName"];
                companyNameLabel.font = kFont_Medium_18;
                companyNameLabel.tag = 828;
                companyNameLabel.textColor = kColor_DarkBlue;
                [cellDefault.contentView addSubview:companyNameLabel];
            }
            //实体卡号
            UILabel *RealCardNoLable = (UILabel *)[cellDefault viewWithTag:817];
            if (RealCardNoLable == nil) {
                UILabel *RealCardNoLableTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 120, 270, 20)];
                RealCardNoLableTitleLabel.backgroundColor = [UIColor clearColor];
                
                if (![[cardInfoDic objectForKey:@"RealCardNo"] isKindOfClass:[NSNull class] ] && [[cardInfoDic objectForKey:@"RealCardNo"] length] >0) {
                    RealCardNoLableTitleLabel.text = [NSString stringWithFormat:@"实体卡号: %@",[cardInfoDic objectForKey:@"RealCardNo"]];
                }else
                {
                    RealCardNoLableTitleLabel.text = @" " ;
                }
                RealCardNoLableTitleLabel.font = kFont_Medium_16;
                RealCardNoLableTitleLabel.tag = 817;
                RealCardNoLableTitleLabel.textColor = kColor_DarkBlue;
                [cellDefault.contentView addSubview:RealCardNoLableTitleLabel];
            }
            
            UILabel *customerCheck = (UILabel *)[cellDefault viewWithTag:829];
            if (customerCheck == nil) {
                UILabel *customerCardNumberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, 150, 270, 16)];
                customerCardNumberTitleLabel.backgroundColor = [UIColor clearColor];
                if ([cardInfoDic objectForKey:@"UserCardNo"] != NULL) {
                    customerCardNumberTitleLabel.text = [NSString stringWithFormat:@"NO.%@",[cardInfoDic objectForKey:@"UserCardNo"]];
                }
                customerCardNumberTitleLabel.font = kFont_Medium_16;
                customerCardNumberTitleLabel.tag = 829;
                customerCardNumberTitleLabel.textColor = kColor_DarkBlue;
                [cellDefault.contentView addSubview:customerCardNumberTitleLabel];
            }
            
            return cellDefault;
        }
            break;
        case 1:
            cell.contentText.text = [cardInfoDic objectForKey:@"CardTypeName"];
            cell.contentText.userInteractionEnabled = NO;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            cell.titleNameLabel.text = @"账户类型";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        case 2:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0 ) {
                if (self.type ==2) {
                    cell.contentText.text = [NSString stringWithFormat:@"%.2Lf", balance];
                }else{
                    cell.contentText.text = [NSString stringWithFormat:@"%@ %.2Lf", MoneyIcon, balance];
                }
                cell.contentText.userInteractionEnabled = NO;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                cell.titleNameLabel.text = @"余额";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            } else if(indexPath.row == 1 ) {
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:1006];
                if (!imageView)
                    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"outOfDate"]];
                imageView.frame = CGRectMake(165.0f, (kTableView_HeightOfRow - 30.0f)/2 + 5, 45.0f, 18.0f);
                if (IOS6) {
                    imageView.frame = CGRectMake(170.0f, (kTableView_HeightOfRow - 30.0f)/2 + 5, 45.0f, 18.0f);
                }
                imageView.hidden = YES;
                imageView.tag = 1006;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [dateFormatter dateFromString:_eCardExpirationTime];
                date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date  timeIntervalSinceReferenceDate] + 8*3600)];
                NSDate *currentDate = [NSDate date];
                date = [dateFormatter dateFromString:[date.description substringToIndex:10]];
                currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
                if([date compare:currentDate] == NSOrderedDescending)
                    imageView.hidden = YES;
                else if([date compare:currentDate] == NSOrderedSame)
                    imageView.hidden = YES;
                else
                    imageView.hidden = NO;
                [cell.contentView addSubview:imageView];
                
                cell.contentText.text = _eCardExpirationTime;
                cell.contentText.userInteractionEnabled = NO;
                cell.titleNameLabel.text = @"有效期";
                cell.accessoryType = UITableViewCellAccessoryNone;
                if ([[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
                    cell.contentText.textColor = kColor_Editable;
                }
                if(![[PermissionDoc sharePermission] rule_CustomerLevel_Write])
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else if (indexPath.row == 2) {
#pragma mark 权限 && RECHARGE_FLAG
                //            if(![[PermissionDoc sharePermission] rule_CustomerLevel_Write])
                //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.contentText.text = @"";
                cell.contentText.userInteractionEnabled = NO;
                cell.arrowsImage.hidden = NO;
                cell.titleNameLabel.text = @"充值";
                return cell;
            }else if (indexPath.row ==3) { // && Money_Out
                cell.contentText.text = @"";
                cell.contentText.userInteractionEnabled = NO;
                cell.arrowsImage.hidden = NO;
                cell.titleNameLabel.text = @"支出";
                return cell;
            }

        }
            break;
        case 3:{
            RechargeEditCell *cell = [self configRechargeEditCell:tableView indexPath:indexPath];
            return cell;
        }
            break;
        case 4:
        {
            if (indexPath.row == 0) {
                UILabel * lableName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
                lableName.text =@"描述";
                lableName.textColor = kColor_DarkBlue ;
                lableName.font = kFont_Medium_16 ;
                [cellDefault.contentView addSubview:lableName];
                return cellDefault;
            }else{
                NSInteger height = [remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                UITextView *record = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 2, ((IOS6) ? 310.f : 300.f), height <= 38 ? 34: height)];
                record.font = kFont_Light_16;
                record.scrollEnabled = NO;
                record.editable = NO;
                record.text = remarkString;
                record.backgroundColor = [UIColor clearColor];
                [cellDefault.contentView addSubview:record];
                return cellDefault;
            }

        }
            break;
        case 5:
        {
            cell.contentText.text = @"";
            cell.contentText.userInteractionEnabled = NO;
            cell.arrowsImage.hidden = NO;
            cell.titleNameLabel.text = @"交易明细";
        }
            break;
        case 6:{
            cell.contentText.text = @"";
            cell.contentText.userInteractionEnabled = NO;
            cell.arrowsImage.hidden = NO;
            cell.titleNameLabel.text = @"第三方交易查询";
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (RechargeEditCell *)configRechargeEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static  NSString *cellindity = @"RechargeEditCell2";
     RechargeEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[RechargeEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.titleNameLabel.textColor = kColor_DarkBlue;
    cell.titleNameLabel.font = kFont_Medium_16;
    cell.contentText.textColor = [UIColor blackColor];
    cell.contentText.font = kFont_Light_16;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

    cell.contentText.enabled = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    if(indexPath.row == 0)
    {
        cell.titleNameLabel.textColor = kColor_DarkBlue;
        cell.titleNameLabel.font = kFont_Medium_16;
        cell.titleNameLabel.text = @"折扣信息";
        cell.contentText.text = @"";
    }else
    {
        cell.titleNameLabel.textColor = kColor_DarkBlue;
        cell.titleNameLabel.font = kFont_Medium_16;
        cell.titleNameLabel.text = [NSString stringWithFormat:@"      %@",[[accountGradeArr objectAtIndex:indexPath.row -1] objectForKey:@"DiscountName"]];
        cell.contentText.text = [NSString stringWithFormat:@"%@",[[accountGradeArr objectAtIndex:indexPath.row -1] objectForKey:@"Discount"]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 205.0f;
    }else {
        if (remarkString.length > 0) {
             if (indexPath.section == 4 && indexPath.row ==1)
             {
                 NSInteger height = [remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                 return height < 38 ? 38 : height;
             }
        }
        return kTableView_HeightOfRow;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
    {
        if (![[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
            return 2;
        }
        return 4;
    }else if(section ==3)
    {
        if(self.type == 2 || self.type == 3)
            return 0;
        return accountGradeArr.count+1;
        
    }else if(section == 4)//备注
    {
         if(remarkString.length > 0)
             return 2;
          else
              return 0;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    if ((RMO(@"|5|") || RMO(@"|6|")) && self.type==1) {
        count = 1;
    }
    return 6+count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(remarkString.length == 0 && section ==4)
        return 0.1f;
    if (accountGradeArr.count ==0 && section ==3) {
        return 0.1f;
    }
    
    if(section == 3)
    {
        if(self.type == 2 || self.type == 3)
            return 0.1f;
    }
    return kTableView_Margin_TOP;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (remarkString.length > 0) {
//        if (indexPath.section == 4) {
//            [self performSegueWithIdentifier:@"gotoPayAndRechargeListViewController" sender:self];
//        }
//    }else
//    {
        if (indexPath.section == 5) {
            [self performSegueWithIdentifier:@"gotoPayAndRechargeListViewController" sender:self];
        }
//    }
    if(indexPath.section == 2 && indexPath.row > 0) {
        if (indexPath.row == 1) {
            if ([[PermissionDoc sharePermission] rule_CustomerLevel_Write]) {
                _textField_Editing = [(RechargeEditCell *)[tableView cellForRowAtIndexPath:indexPath] contentText];
                [self initialKeyboard];
            }
            return;
        }
        if (indexPath.row == 2 && RECHARGE_FLAG) {
            if (self.type == 1) {
                
                [self performSegueWithIdentifier:@"gotoECardRechargeViewController" sender:self];
            }else
            {
                AccountIntegralRecharge_ViewController * recharge = [[AccountIntegralRecharge_ViewController alloc] init];
                recharge.accountType = self.type;
                recharge.Balance = balance;
                recharge.IntergralRechargeCardId = self.userCardNo;
                [self.navigationController pushViewController:recharge animated:YES];
            }
            
        } else if(indexPath.row==3 && RECHARGE_FLAG){
            if (self.type==1) {
                ECardOutViewController *ecardOutView = [[ECardOutViewController alloc] init];
                ecardOutView.eCardBalance = balance;
                ecardOutView.ecardOutCardId = self.userCardNo;
                [self.navigationController pushViewController:ecardOutView animated:YES];
            }else{
                AccountIntegralOut_ViewController * integralOut = [[AccountIntegralOut_ViewController alloc] init];
                integralOut.accountType = self.type;
                integralOut.Balance = balance;
                integralOut.intergralOutcardId = self.userCardNo;
                [self.navigationController pushViewController:integralOut animated:YES];
            }
        }
    }
    if (indexPath.section ==6) {
        ThirdPatmentRecords_ViewController * records = [[ThirdPatmentRecords_ViewController alloc] init];
        records.userCardNO = self.userCardNo;
        records.customerID  = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
        records.viewFor = 3 ;
        [self.navigationController pushViewController:records animated:YES];

    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoECardRechargeViewController"]) {
        ECardRechargeViewController *detailController = segue.destinationViewController;
        detailController.eCardBalance = balance;
        detailController.cardId = self.userCardNo;
        detailController.intergralNO = self.intergralNO;
        detailController.cashCouponNO = self.cashCouponNO;
        
    }else if([segue.identifier isEqualToString:@"gotoPayAndRechargeListViewController"]){
        RechargeAndPayViewController * payOut = segue.destinationViewController;
        payOut.accountType = self.type;
        payOut.userCardId = [cardInfoDic objectForKey:@"UserCardNo"];
    }
    
}

#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(IOS7 || IOS6){
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    }
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] init];
        if (IOS8)
            datePicker.frame = CGRectMake(-8, 30, kSCREN_BOUNDS.size.width, 390);
        else
            datePicker.frame = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, 390);
        if (IOS9) {
            datePicker.frame = CGRectMake(-10, 30, kSCREN_BOUNDS.size.width, 390);
            
        }
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    NSDate *theDate = [NSDate stringToDate:[[NSDate date].description substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
 
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
        _oldDate = [NSDate stringToDate:_eCardExpirationTime dateFormat:@"yyyy-MM-dd"] ;
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        if(IOS8)
            [inputAccessoryView setFrame:CGRectMake(-8, 0, kSCREN_BOUNDS.size.width, 35)];
        else
            inputAccessoryView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 35);
        
//        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
//        [doneBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *clearBtn =[[UIBarButtonItem alloc] initWithTitle:@"无有效期" style:UIBarButtonItemStyleDone target:self action:@selector(clear:)];
//        [clearBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
//        [cancelBtn setTintColor:kColor_White];
//        
//        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        
//        if (IOS9) {
//            [inputAccessoryView setFrame:CGRectMake(-10, 0, 320, 35)];
//            flexibleSpaceLeft.width = kSCREN_BOUNDS.size.width-165;
//        }else {
//            flexibleSpaceLeft =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        }
//        
//        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, clearBtn, cancelBtn, doneBtn, nil];
//        [inputAccessoryView setItems:array];
        if (IOS9) {
            [inputAccessoryView setFrame:CGRectMake(-10, 0, kSCREN_BOUNDS.size.width, 35)];
        }
        CGFloat width = kSCREN_BOUNDS.size.width / 3;
        UIButton *doneBtn = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(done:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *clearBtn = [UIButton buttonWithTitle:@"无有效期" target:self selector:@selector(clear:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *canceBtn = [UIButton buttonWithTitle:@"取消" target:self selector:@selector(cancel:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIBarButtonItem *itemDoneBtn= [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
        UIBarButtonItem *itemClearBtn = [[UIBarButtonItem alloc]initWithCustomView:clearBtn];
        UIBarButtonItem *itemCanceBtn = [[UIBarButtonItem alloc]initWithCustomView:canceBtn];
        NSArray *array = @[itemClearBtn,itemCanceBtn,itemDoneBtn];
        [inputAccessoryView setItems:array];
    }
    if(IOS8){
        UIAlertController *alertCtrlr =[UIAlertController  alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(-8, 30, kSCREN_BOUNDS.size.width , 400)];
        view.backgroundColor = [UIColor whiteColor];
        [alertCtrlr.view addSubview:view];
        [alertCtrlr.view addSubview:inputAccessoryView];
        [alertCtrlr.view addSubview:datePicker];
        [self presentViewController:alertCtrlr animated:YES completion:nil];
    }else{
        [_actionSheet addSubview:datePicker];
        [_actionSheet addSubview:inputAccessoryView];
        
        [_actionSheet showInView:self.view];
        [_actionSheet setBounds:CGRectMake(0, 0, 320, 430)];
        [_actionSheet setBackgroundColor:[UIColor whiteColor]];
    }
    [UIView animateWithDuration:.5 animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,  _tableView.frame.size.width , tableView_Height - 150);
        _tableView.contentOffset = CGPointMake(0, (tableView_Height - (kSCREN_480 ? -60 : 120)) /2);
    }];
}

- (void)dateChanged:(id)sender
{
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
}

-(void)clear:(id)sender
{
    [datePicker setDate:[NSDate stringToDate:@"2099-12-31" dateFormat:@"yyyy-MM-dd"] animated:YES];
    _textField_Editing.text = @"2099-12-31";
    _eCardExpirationTime = @"2099-12-31";
}
- (void)done:(id)sender
{
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSString *dataStr = [NSDate dateToString:newDate dateFormat:@"yyyy-MM-dd"];

    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
        inputAccessoryView = nil;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"所选日期不能在今天之前" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }];
              [self updateExpirationTime:_textField_Editing.text];
    }else{
        inputAccessoryView = nil;
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dataStr]];
        [self updateExpirationTime:_textField_Editing.text];
        
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,  _tableView.frame.size.width , tableView_Height);
}



-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1006];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]]; //取出日期比较
    if([_oldDate compare:currentDate] == NSOrderedDescending || [_oldDate compare:currentDate] == NSOrderedSame){
        imageView.hidden = YES;
    }else
        imageView.hidden = NO;
    _textField_Editing.text = [dateFormatter stringFromDate:_oldDate];
    _eCardExpirationTime =[NSString stringWithString: _textField_Editing.text];
    _oldDate = nil;
    inputAccessoryView = nil;
    if(IOS8){
        datePicker = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,  _tableView.frame.size.width , tableView_Height);
}
#pragma mark - 接口 

-(void)requestCardInfo{//卡的信息
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":\"%ld\",\"UserCardNo\":\"%@\"}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID,self.userCardNo];
    _getBalanceOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            cardInfoDic = data ;
            accountGradeArr = nil;
            accountGradeArr = [cardInfoDic objectForKey:@"DiscountList"];
            balance = [[cardInfoDic objectForKey:@"Balance"] doubleValue];
            remarkString = [cardInfoDic objectForKey:@"CardDescription"];
            _eCardExpirationTime = [cardInfoDic objectForKey:@"CardExpiredDate"];
            navigationView.titleLabel.text = [cardInfoDic objectForKey:@"CardName"];;
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
        
    }];

}

-(void)updateExpirationTime:(NSString *)changeDate
{
    [SVProgressHUD showWithStatus:@"Updating"];
    NSInteger customerId = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] customer_Selected] cus_ID];
    NSDictionary * par = @{
                           @"UserCardNo":self.userCardNo,
                            @"CardExpiredDate":changeDate,
                           @"CustomerID":@((long)customerId)
                           };
    
    _requestUpdateExpirationTime = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/UpdateExpirationDate" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            _eCardExpirationTime = changeDate;
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {

            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {

        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    }];

}

-(void)setDefaultCard
{
    [SVProgressHUD showWithStatus:@"Loading"];
     NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":\"%ld\",\"UserCardNo\":\"%@\"}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID,self.userCardNo];
    _setDefaultcardOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/UpdateCustomerDefaultCard" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                self.defaultCard = !self.defaultCard;
                [self setDefultCardView];
            }];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

@end