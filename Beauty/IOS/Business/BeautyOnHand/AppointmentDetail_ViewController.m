//
//  AppointmentDetail_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentDetail_ViewController.h"
#import "NavigationView.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "NormalEditCell.h"
#import "AppointmentDoc.h"
#import "FooterView.h"
#import "ColorImage.h"
#import "CustomerBasicViewController.h"
#import "UIButton+InitButton.h"
#import "OrderDetailViewController.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NSDate+Convert.h"
#import "SelectCustomersViewController.h"
#import "SubOrderViewController.h"
#import "OrderConfirmViewController.h"
#import "OrderDoc.h"
#import "AppDelegate.h"
#import "OpportunityDoc.h"
#import "ServiceDoc.h"
#import "AppointmentList_ViewController.h"
#import "TaskList_ViewController.h"
#import "CusMainViewController.h"
#import "WorkSheetViewController.h"

@interface AppointmentDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,SelectCustomersViewControllerDelegate,ContentEditCellDelegate,WorkSheetViewControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentDetail;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentCancel;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentConfirm;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong,nonatomic) AppointmentDoc * appointmentDoc;
@property (strong ,nonatomic) NSString * orderNUmber;
@property (strong ,nonatomic) NSString * orderName;
@property (assign ,nonatomic) double totleSale;
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) NSInteger orderObjectID;
@property (strong ,nonatomic) UIButton * buttonCancel;
@property (strong ,nonatomic) UIButton * buttonConfirm;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UITextField * textField_selected;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) CGFloat table_Height;
@property (nonatomic, strong) NSMutableArray *orderArray;
@property (nonatomic ,assign) long long ProductCode;
@end

@implementation AppointmentDetail_ViewController
@synthesize myTableView;
@synthesize appointmentDoc;
@synthesize buttonCancel,buttonConfirm;
@synthesize datePicker,table_Height;
@synthesize inputAccessoryView;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"预约详情"];
    [self.view addSubview:navigationView];
    
    self.orderName = @"";
    self.orderNUmber = @"" ;
    self.totleSale = 0;
    
    [self initTableView];
    [self requestList];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49 )style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        myTableView.sectionFooterHeight = 0;
        myTableView.sectionHeaderHeight = 10;
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
    table_Height = myTableView.frame.size.height+40;
    [self initButton];
}

-(void)initButton
{
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
    table_Height = myTableView.frame.size.height+40;
    
    if (appointmentDoc.Appointment_status == 3 || appointmentDoc.Appointment_status == 4) {
        if ((IOS7 || IOS8)) {
            myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
            myTableView.separatorInset = UIEdgeInsetsZero;
            self.automaticallyAdjustsScrollViewInsets = NO;
        } else if (IOS6) {
            myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        }
        table_Height = myTableView.frame.size.height;
    }else if((appointmentDoc.Appointment_status == 1 || appointmentDoc.Appointment_status == 2) && appointmentDoc.appointEditStatus == AppointmentEditExist){ // [[PermissionDoc sharePermission] rule_MyOrder_Write] &&


        UIView * View = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f, myTableView.frame.size.width+10 , 49.0f)];
        View.backgroundColor = kColor_Background_View;;
        [self.view addSubview:View];
        
        buttonCancel = [UIButton buttonWithTitle:@"预约取消" target:self selector:@selector(appointmentCancel) frame:CGRectMake( 5, 5 , 152.5, 39) backgroundImg:ButtonStyleRed];

        buttonConfirm = [UIButton buttonWithTitle:@"预约确认" target:self selector:@selector(appointmentConfirm) frame:CGRectMake(162.5, 5 , 152.5, 39)backgroundImg:ButtonStyleBlue];

        if (appointmentDoc.Appointment_status == 1) {
            
            [buttonConfirm setTitle:@"预约确认" forState:UIControlStateNormal];
            
        }else
        {
            [buttonConfirm setTitle:@"开单" forState:UIControlStateNormal];
        }
        
        [View addSubview:buttonCancel];
        [View addSubview:buttonConfirm];
    } else {
        if ((IOS7 || IOS8)) {
            myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
            myTableView.separatorInset = UIEdgeInsetsZero;
            self.automaticallyAdjustsScrollViewInsets = NO;
        } else if (IOS6) {
            myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        }
        table_Height = myTableView.frame.size.height;
    }
}

-(void)appointmentCancel
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否取消本次预约？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self cancelAppointmentHttp];
        }
    }];
}

-(void)appointmentConfirm
{
    if (appointmentDoc.Appointment_status == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否确认本次预约？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                [self confirmAppointmentHttp];
            }
        }];
    }else if(appointmentDoc.Appointment_status == 2)//开单
    {
        if (self.orderID >0) {//开小单
            CustomerDoc *doc = [[CustomerDoc alloc] init];
            [doc setCus_ID:appointmentDoc.Appointment_customerID];
            [doc setCus_Name:appointmentDoc.Appointment_customer];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.customer_Selected = doc ;//保存选中顾客
            
            SubOrderViewController * sub = [[SubOrderViewController alloc] init];
            sub.orderList = [NSString stringWithFormat:@"%ld",(long)self.orderID];
            sub.customerName = appointmentDoc.Appointment_customer;
            if (self.viewFor == 3) {
                sub.backMode = SubOrderViewBackDetail;
            }else
            {
                sub.backMode = SubOrderViewBackOrderList;
            }
            
            if (appointmentDoc.Appointment_assignType == 1) {
                NSDictionary *dic = @{
                                      @"AccID":@(appointmentDoc.Appointment_servicePersonalID),
                                      @"AccName":appointmentDoc.Appointment_servicePersonal
                                      };
                sub.userDic = dic;
            } else {
                NSDictionary *dic = @{
                                      @"AccID":@(0),
                                      @"AccName":@""
                                      };
                sub.userDic = dic;
            }

            sub.taskID = self.LongID;
            [self.navigationController pushViewController:sub animated:YES];
        }else{//开大单
            
            CustomerDoc *doc = [[CustomerDoc alloc] init];
            [doc setCus_ID:appointmentDoc.Appointment_customerID];
            [doc setCus_Name:appointmentDoc.Appointment_customer];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.customer_Selected = doc ;//保存选中顾客
            
            ServiceDoc * serVice = [[ServiceDoc alloc] init];
            [serVice setCustomer_ID:appointmentDoc.Appointment_customerID];
            [serVice setService_Code:self.ProductCode];
            [serVice setService_ID:self.orderID];
            [serVice setService_ServiceName:self.orderName];
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            [arr addObject:serVice];
            
            OrderConfirmViewController *orderCon = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
            orderCon.orderEditMode = OrderEditModeFavour;
            orderCon.taskID = self.LongID;
            orderCon.favouritestList = arr;
            
            if (appointmentDoc.Appointment_assignType == 1) {
                NSDictionary *dic = @{
                                      @"AccID":@(appointmentDoc.Appointment_servicePersonalID),
                                      @"AccName":appointmentDoc.Appointment_servicePersonal
                                      };
                orderCon.userDic = dic;
            } else {
                NSDictionary *dic = @{
                                      @"AccID":@(0),
                                      @"AccName":@""
                                      };
                orderCon.userDic = dic;
            }
            
            [self.navigationController pushViewController:orderCon animated:YES];
        }
        
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 1 && appointmentDoc.Appointment_remark.length == 0)
    {
        return 0.1;
    }else if(section == 2 && appointmentDoc.Appointment_remark.length == 0)
    {
        return 0.1;
    }
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1 && appointmentDoc.Appointment_remark.length == 0)
    {
        return 0.1;
    }else if(section == 2 && appointmentDoc.Appointment_remark.length == 0)
    {
        return 3;
    }
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==1 && indexPath.section == 1) {
        if (appointmentDoc.Appointment_remark.length > 0) {
            __autoreleasing ContentEditCell *cell = [[ContentEditCell alloc] init];
            cell.contentEditText.text = appointmentDoc.Appointment_remark;
            CGFloat height = [cell.contentEditText sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
            return height < kTableView_HeightOfRow ? kTableView_HeightOfRow : height;
        }
    }
    return kTableView_HeightOfRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 3;
    }else if (section == 0) {
        return 8;
    }else if (appointmentDoc.Appointment_remark.length > 0 || appointmentDoc.Appointment_status == 1) {
        return 2;
    }

    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![self.orderNUmber isKindOfClass:[NSNull class]]) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
        cell.valueText.textColor = [UIColor blackColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section ==0) {
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"预约编号";
                cell.valueText.text = self.LongID == 0?@"": [NSString stringWithFormat:@"%lld",self.LongID];
                break;
            case 1:
            {
                [cell setAccessoryText:@"    "];
                cell.titleLabel.text = @"顾客";
                cell.valueText.text = appointmentDoc.Appointment_customer;
                
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
            }
                break;
            case 2:
                cell.titleLabel.text = @"预约状态";
                cell.valueText.text = appointmentDoc.Appointment_statusStr;
                break;
            case 3:
                cell.titleLabel.text = @"预约门店";
                cell.valueText.text = appointmentDoc.Appointment_branchName;
                break;
            case 4:
                cell.titleLabel.text = @"到店时间";
                cell.valueText.text = appointmentDoc.Appointment_date;
                if (appointmentDoc.Appointment_status ==1){
                    cell.valueText.textColor = kColor_Editable;
                }
                break;
            case 5:
                cell.titleLabel.text = @"预约服务";
                cell.valueText.text = appointmentDoc.Appointment_servicename;
                break;
            case 6:
                if (appointmentDoc.Appointment_status ==1){
                    cell.valueText.textColor = kColor_Editable;
                }
                cell.titleLabel.text = @"是否指定顾问";
                if (appointmentDoc.Appointment_assignType == 1) {
                     cell.valueText.text = @"指定";
                }else
                {
                     cell.valueText.text = @"到店指定";
                }
                break;
            case 7:
            {
                if (appointmentDoc.Appointment_status == 1){
                    cell.valueText.textColor = kColor_Editable;
                    
                }
                cell.titleLabel.text = @"指定顾问";
                cell.valueText.text = appointmentDoc.Appointment_servicePersonal;
            }
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"备注";
                cell.valueText.text = @"";
                break;
            case 1:
                {
                    static NSString *editCellIdentifier = @"editCell";
                    ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                    if ( appointmentDoc.Appointment_remark.length == 0) {
                        editCell.contentEditText.placeholder = @"请输入备注...";
                    }else
                    {
                        editCell.contentEditText.text = appointmentDoc.Appointment_remark;
                    }
                    editCell.contentEditText.tag = 1000;
                    editCell.contentEditText.font = kFont_Light_16;
                    editCell.delegate = self;
                    if(appointmentDoc.Appointment_status == 1)
                    {
                        editCell.contentEditText.userInteractionEnabled = YES ;
                        editCell.contentEditText.textColor = kColor_Editable;
                    }else
                    {
                        editCell.userInteractionEnabled = NO ;
                        editCell.contentEditText.textColor = kColor_Black;
                    }
                    
                    return editCell;
                }
                break;
            
            default:
                break;
        }
    }
    else if(indexPath.section == 2)
    {
        switch (indexPath.row) {
            case 0:
            {
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
                cell.titleLabel.text = @"订单编号" ;
                cell.valueText.text = [self.orderNUmber isKindOfClass:[NSNull class]]?@"":self.orderNUmber ;
                [cell setAccessoryText:@"    "];
            }
                break;
            case 1:
                cell.titleLabel.text = self.orderName ;
                break;
            case 2:
                cell.titleLabel.text = @"订单金额" ;
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,self.totleSale] ;
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
 
    if(indexPath.section ==0){
        if (indexPath.row ==1) {//顾客基本信息页
            CustomerDoc *doc = [[CustomerDoc alloc] init];
            [doc setCus_ID:appointmentDoc.Appointment_customerID];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.customer_Selected = doc ;//保存选中顾客
            
            CusMainViewController *cus = [[CusMainViewController alloc] init];
            ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 1;
            [self.navigationController pushViewController:cus animated:YES];
            
        }else if(indexPath.row == 4){
            [self gotoWorkSheetWithType:1];
        }
    }else if(indexPath.section == 2)
    {
        if (indexPath.row ==0) {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OrderDetailViewController *orderDetail = [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
            orderDetail.orderID = self.orderID;
            orderDetail.productType = 0;
            orderDetail.objectID  = self.orderObjectID;
            [self.navigationController pushViewController:orderDetail animated:YES];
        }
    }
}

-(void)gotoWorkSheetWithType:(NSInteger )type
{
    WorkSheetViewController *workSheetVC = nil;
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    workSheetVC = [sb instantiateViewControllerWithIdentifier:@"WorkSheetViewController"];
    UserDoc *userDoc = [[UserDoc alloc] init];
    if (appointmentDoc.Appointment_servicePersonalID > 0) {
        userDoc.user_Id = appointmentDoc.Appointment_servicePersonalID;
        userDoc.user_Name = appointmentDoc.Appointment_servicePersonal;
        workSheetVC.selected_UserArray = @[userDoc];
    }
    NSDate *newDate =  [NSDate stringToDate:appointmentDoc.Appointment_date dateFormat:@"yyyy-MM-dd HH:mm"];
    workSheetVC.wsDate = appointmentDoc.Appointment_date.length >0? newDate :[NSDate date];
    workSheetVC.delegate = self;
    workSheetVC.multipleSelection = NO;
    workSheetVC.customerId = appointmentDoc.Appointment_customerID;
    workSheetVC.orderId = appointmentDoc.Appointment_orderID;
    workSheetVC.orderObjectId = appointmentDoc.Appointment_orderObjectID;
    workSheetVC.ReservedOrderType = appointmentDoc.Appointment_ReservedOrderType;
    workSheetVC.orderServiceCode = appointmentDoc.Appointment_serviceCode;
    workSheetVC.chooseType = type;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:workSheetVC];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}


#pragma mark - dismissViewControllerDelegate
//预约
- (void)dismissViewController:(WorkSheetViewController *)workSheetVC userArray:(NSArray *)userArray dateStr:(NSString *)dateStr
{
    UserDoc *userDoc = (UserDoc *)[userArray firstObject];
    appointmentDoc.Appointment_date = dateStr;
    if (userDoc.user_Id  > 0) {
        appointmentDoc.Appointment_assignType = 1;
        appointmentDoc.Appointment_servicePersonalID  = userDoc.user_Id;
        appointmentDoc.Appointment_servicePersonal = userDoc.user_Name;
    }else
    {
        appointmentDoc.Appointment_assignType = 0;
        appointmentDoc.Appointment_servicePersonalID  = 0;
        appointmentDoc.Appointment_servicePersonal = @"";
        
    }
    
    [myTableView reloadData];
}

//Http request
-(void)requestList
{
    NSDictionary * par = @{
                           @"LongID":@(self.LongID),
                           };
    
    _requestAppointmentDetail = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            appointmentDoc = [[AppointmentDoc alloc] init];
            [appointmentDoc setAppointment_customerID:[[data objectForKey:@"TaskOwnerID"]integerValue ]];
            [appointmentDoc setAppointment_customer:[data objectForKey:@"TaskOwnerName"]];
            [appointmentDoc setAppointment_remark:[data objectForKey:@"Remark"]];
            [appointmentDoc setAppointment_status:[[data objectForKey:@"TaskStatus"] intValue]];
            [appointmentDoc setAppointment_date:[data objectForKey:@"TaskScdlStartTime"]];
            [appointmentDoc setAppointment_servicename:[data objectForKey:@"ProductName"]];
            [appointmentDoc setAppointment_servicePersonal:[data objectForKey:@"AccountName"]];
            [appointmentDoc setAppointment_servicePersonalID:[[data objectForKey:@"AccountID"] integerValue]];
            
            [appointmentDoc setAppointment_number:[[data objectForKey:@"TaskID"] longLongValue]];
            
            [appointmentDoc setAppointment_branchName:[data objectForKey:@"BranchName"]];
            if (appointmentDoc.Appointment_servicePersonalID > 0) {
                appointmentDoc.Appointment_assignType =1;
            }
            self.orderNUmber = [data objectForKey:@"OrderNumber"];
            self.orderName = [data objectForKey:@"ProductName"];
            self.totleSale = [[data objectForKey:@"TotalSalePrice"] doubleValue];
            self.orderID = [[data objectForKey:@"OrderID"] integerValue];
            self.orderObjectID = [[data objectForKey:@"OrderObjectID"] integerValue];
            self.ProductCode = [[data objectForKey:@"ProductCode"] longLongValue];
            
            self.orderArray = [[NSMutableArray alloc] init];
            OrderDoc *orderDoc = [[OrderDoc alloc] init];
            [orderDoc setOrder_ID:self.orderID];
            [orderDoc setOrder_ObjectID:self.orderObjectID];
            [self.orderArray addObject:orderDoc];
            
            [self initButton];
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

-(void)cancelAppointmentHttp
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary * par = @{
                           @"LongID":@((long long)self.LongID),
                         };
    
    _requestAppointmentCancel = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/CancelSchedule" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            [SVProgressHUD showSuccessWithStatus2:message duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
                for (UIViewController *temp in self.navigationController.viewControllers) {
                    if ([temp isKindOfClass:[AppointmentList_ViewController class]]) {
                        [temp performSelector:@selector(headerRefresh) withObject:nil];
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                    
                    if ([temp isKindOfClass:[TaskList_ViewController class]]) {
                        [temp performSelector:@selector(headerRefresh) withObject:nil];
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                    if ([temp isKindOfClass:[OrderDetailViewController class]]) {
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                }
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];

}

-(void)confirmAppointmentHttp
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par = @{
                               @"ID":@((long long)self.LongID),
                               @"ExecutorID":@((long)appointmentDoc.Appointment_servicePersonalID),
                               @"TaskScdlStartTime":appointmentDoc.Appointment_date,
                               @"Remark":appointmentDoc.Appointment_remark,
                               @"TaskOwnerID":@((long)appointmentDoc.Appointment_customerID) ,
                           };
    
    _requestAppointmentConfirm = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/ConfirmSchedule" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [SVProgressHUD dismiss];
                
                for (UIViewController *temp in self.navigationController.viewControllers) {
                    if ([temp isKindOfClass:[AppointmentList_ViewController class]]) {
                        [temp performSelector:@selector(headerRefresh) withObject:nil];
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                    if ([temp isKindOfClass:[OrderDetailViewController class]]) {
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                }
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error duration:kSvhudtimer touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark 备注编辑

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
//  g  appointmentDoc.Appointment_remark = @"";
    
    contentText.returnKeyType = UIReturnKeyDefault;
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
            if (toBeString.length >= 300) {
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
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    appointmentDoc.Appointment_remark = textView.text;
    self.textView_Selected = nil;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];

}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 20;
        _prevCaretRect = newCursorRect;
        [myTableView scrollRectToVisible:newCursorRect animated:YES];
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
    
    [myTableView beginUpdates];
    [myTableView endUpdates];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height - initialFrame.size.height + 5.0f;
    myTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height;
    myTableView.frame = tvFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
