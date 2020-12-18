//
//  AppointmenCreat_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmenCreat_ViewController.h"
#import "NormalEditCell.h"
#import "UIButton+InitButton.h"
#import "AppointmentDoc.h"
#import "ServiceListViewController.h"
#import "RemarkEditCell.h"
#import "AppointmentExecutingOrderList_ViewController.h"
#import "SelectServicePersonnal_ViewController.h"
#import "UserDoc.h"
#import "NSDate+Convert.h"
#import "AppointmentList_ViewController.h"

@interface AppointmenCreat_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITextViewDelegate,ContentEditCellDelegate,SelectServiceControllerDelegate,SelectExecutingControllerDelegate,SelectCustomersViewControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestHttp;
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic ,strong) NSString * dateForStartStr;
@property (assign, nonatomic) CGFloat table_Height;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign ,nonatomic) NSInteger flag;
@property (strong, nonatomic) UITextField *textField_Editing;

@end

@implementation AppointmenCreat_ViewController

@synthesize myTableView,datePicker;
@synthesize dateForStartStr,table_Height;
@synthesize inputAccessoryView;
@synthesize  appointmentDoc;

- (void)viewWillAppear:(BOOL)animated
{
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
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"创建预约";
    
    [self initTableView];
    [self initdata];
    
    //点击收起键盘
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    //    [self.view addGestureRecognizer:tap];
}
- (void)tapClick
{
    [self.view endEditing:YES];
}
//点击收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark -init

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 5)style:UITableViewStyleGrouped];
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
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44 - 49, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    
    
    UIButton *add_Button= [UIButton buttonWithTitle:@"确定"
                                     target:self
                                   selector:@selector(creatAppointment)
                                      frame:CGRectMake(5,5,kSCREN_BOUNDS.size.width - 10, 39)
                              backgroundImg:nil
                           highlightedImage:nil];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
}

-(void)initdata
{
    
    dateForStartStr = @"";
    appointmentDoc = [[AppointmentDoc alloc] init];
    
    [myTableView reloadData];
}

-(void)creatAppointment
{
    self.hidesBottomBarWhenPushed = YES;
    if (appointmentDoc.Appointment_date.length < 10 ) {
        [SVProgressHUD showSuccessWithStatusWithToch:@"请选择到店时间！" touchEventHandle:^{}];
        return;
    }
    
    [self httpCreatAppointment];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==1 && indexPath.row==1) {
        if (appointmentDoc.Appointment_remark.length > 0) {
            NSInteger height = [appointmentDoc.Appointment_remark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(310, 500) lineBreakMode:NSLineBreakByCharWrapping].height + 20;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
        }
    }
    
    return kTableView_DefaultCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section== 0) {
        return 4;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.enabled = NO;
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        arrowsImage.tag = 1000 + indexPath.row;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section ==0) {
        
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"选择门店";
                cell.valueText.textColor = [UIColor blackColor];
                cell.valueText.text = self.branchName;
                break;
            }
            case 1:{
                cell.valueText.enabled = NO ;
                cell.titleLabel.text = @"到店时间";
                cell.valueText.placeholder = @"选择到店时间";
                [cell.valueText setValue:kColor_Editable forKeyPath:@"_placeholderLabel.textColor"];
                cell.valueText.text = appointmentDoc.Appointment_date;
                cell.valueText.userInteractionEnabled = NO;
                UIImageView * image  = (UIImageView *)[cell.contentView viewWithTag:1000+indexPath.row];
                [cell.contentView addSubview:image];
                
            }
                break;
            case 2:
                cell.titleLabel.text = @"预约服务";
                cell.valueText.text = self.serviceName;
                cell.valueText.textColor = [UIColor blackColor];
                
                break;
            case 3:{
                cell.titleLabel.text = @"指定顾问";
                cell.valueText.text = appointmentDoc.Appointment_servicePersonalID ==0 ? @"到店指定":appointmentDoc.Appointment_servicePersonal;
                UIButton * deleteButton = (UIButton *)[cell.contentView viewWithTag:89];
                if (!deleteButton) {
                    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(320-35,10, 30, 30)];
                    deleteButton.backgroundColor = [UIColor clearColor];
                    [deleteButton setImage:[UIImage imageNamed:@"DesignaedDelete"] forState:UIControlStateNormal];
                    deleteButton.tag = 89 ;
                    [deleteButton addTarget:self action:@selector(deleteServicePerson:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:deleteButton];
                }
                deleteButton.hidden = YES;
                if (appointmentDoc.Appointment_servicePersonalID >0) {
                    deleteButton.hidden = NO;
                    cell.valueText.frame = CGRectMake(125.0f,15, 155, 20.0f);
                }
            }
                break;
            default:
                break;
        }
    }else if(indexPath.section ==1)
    {
        if(indexPath.row ==0)
            cell.titleLabel.text = @"留言";
        else
        {
         
            cell.titleLabel.text = @"" ;
            static NSString *editCellIdentifier = @"editCell";
            
            RemarkEditCell  *editCell = [[RemarkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
            editCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect rect=editCell.contentEditText.frame;
            rect.origin.x=5;
            rect.origin.y=0;
            editCell.contentEditText.frame=rect;
            if ( [appointmentDoc.Appointment_remark isEqualToString:@""] || appointmentDoc.Appointment_remark.length == 0) {
                
                editCell.contentEditText.placeholder = @"请输入留言...";
            } else {
                editCell.contentEditText.text = appointmentDoc.Appointment_remark;
            }
            editCell.contentEditText.tag = 1000;
            editCell.contentEditText.font = kNormalFont_14;
            editCell.delegate = self;
            return editCell;

        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==0) {
        switch (indexPath.row) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                [self initialKeyboard];
                self.textField_Editing  = [(NormalEditCell *)[tableView cellForRowAtIndexPath:indexPath] valueText];
                NSDate *theDate = [NSDate stringToDate:self.textField_Editing.text dateFormat:@"yyyy年MM月dd日 HH:mm"];
                if (theDate != nil && ![theDate  isEqual: @""]) {
                    [datePicker setDate:theDate];
                }
            }
                break;
            case 2:
            {
                //               if (self.viewTag != 2) {
                //                   [self GetExecutingOrderList];
                //               }
            }
                break;
            case 3:
            {
                SelectServicePersonnal_ViewController *selectCustomer = [[SelectServicePersonnal_ViewController alloc] init];
                selectCustomer.delegate = self;
                selectCustomer.BracnID = self.BranchID;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
                [self presentViewController:navigationController animated:YES completion:^{}];
            }
                break;
            default:
                break;
        }
    }
}


-(void)deleteServicePerson:(UIButton *)sender
{
    appointmentDoc.Appointment_servicePersonal = @"";
    appointmentDoc.Appointment_servicePersonalID = 0;
    [myTableView reloadData];
}

-(void)gotoServiceList{
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceListViewController *serviceListVC = (ServiceListViewController *)[sb instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
    serviceListVC.delegate = self;
    serviceListVC.returnViewTag = 1;
    
    [self.navigationController pushViewController:serviceListVC animated:YES];
    
}

#pragma mark - dismissViewControllerDelegate

-(void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    if (userArray.count >0) {
        UserDoc * userDoc = [[UserDoc alloc] init];
        userDoc = [userArray objectAtIndex:0];
        if (userDoc.user_Id ==0) {//到店指定
            appointmentDoc.Appointment_assignType = 0;
            appointmentDoc.Appointment_servicePersonal = @"";
            appointmentDoc.Appointment_servicePersonalID = 0;
        }else{
            appointmentDoc.Appointment_servicePersonal = userDoc.user_Name;
            appointmentDoc.Appointment_servicePersonalID = userDoc.user_Id;
        }
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dismissServiceViewControllerWithSelectedService:(NSString *)serviceName userID:(NSDictionary *)serviceDic{
    
    appointmentDoc.Appointment_ReservedOrderType = 2;
    appointmentDoc.Appointment_servicename = serviceName;
    appointmentDoc.Appointment_serviceCode = [[serviceDic objectForKey:@"ID"] longLongValue];
    NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

//存单
- (void)dismissServiceViewControllerWithSelectedExecutingOrder:(NSString *)serviceName userID:(NSDictionary *)serviceIdDic
{
    appointmentDoc.Appointment_servicename = serviceName;
    appointmentDoc.Appointment_ReservedOrderID = [[serviceIdDic objectForKey:@"OrderID"] integerValue];
    appointmentDoc.Appointment_ReservedOrderServiceID = [[serviceIdDic objectForKey:@"OrderObjectID"] integerValue];
    appointmentDoc.Appointment_ReservedOrderType = 1;
    NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
    
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
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
            datePicker.frame = CGRectMake(-10, 30, kSCREN_BOUNDS.size.width, 390);
        else
            datePicker.frame = CGRectMake(-10, 20, kSCREN_BOUNDS.size.width, 390);
        
        if (IOS9) {
            
            datePicker.frame = CGRectMake(-10, 30, kSCREN_BOUNDS.size.width, 250);
        }
        [datePicker setDate:[NSDate date]];
        [datePicker setTimeZone:[NSTimeZone defaultTimeZone]];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    NSDate *theDate = [NSDate stringToDate:[[NSDate date].description substringToIndex:10] dateFormat:@"yyyy-MM-dd HH:mm"];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定 " style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        [cancelBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        flexibleSpaceLeft.width = kSCREN_BOUNDS.size.width-100;
        if(IOS8){
            [inputAccessoryView setFrame:CGRectMake(-8, 0, kSCREN_BOUNDS.size.width, 35)];
        }
        else{
            inputAccessoryView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 35);
        }
        if (IOS9) {
            [inputAccessoryView setFrame:CGRectMake(-10, 0, 320, 35)];
            flexibleSpaceLeft.width = kSCREN_BOUNDS.size.width-85;
        }
        NSArray *array = [NSArray arrayWithObjects:cancelBtn,flexibleSpaceLeft,  doneBtn, nil];
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
        if (IOS9) {
            view.frame = CGRectMake(-10, 30, kSCREN_BOUNDS.size.width , 400);
        }
    }else{
        [_actionSheet addSubview:datePicker];
        [_actionSheet addSubview:inputAccessoryView];
        
        [_actionSheet showInView:self.view];
        [_actionSheet setBounds:CGRectMake(0, 0, 320, 430)];
        [_actionSheet setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)dateChanged:(id)sender
{
    
    
}

- (void)done:(id)sender
{
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSString *dataStr = [NSDate dateToString:datePicker.date dateFormat:@"yyyy-MM-dd HH:mm"];
    
    
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];
    
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];
    if (([newDate compare:currentDate] == NSOrderedAscending) ||([newDate compare:currentDate] == NSOrderedSame)) {
        inputAccessoryView = nil;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"预约时间小于当前时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        
    }else{
        inputAccessoryView = nil;
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dataStr]];
        appointmentDoc.Appointment_date = [NSString stringWithFormat:@"%@", dataStr];
        appointmentDoc.Appointment_servicePersonal= @"";
        appointmentDoc.Appointment_servicePersonalID = 0;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
        [myTableView reloadData];
    }
}


-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    inputAccessoryView = nil;
    if(IOS8){
        datePicker = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark Http request

- (void)GetExecutingOrderList
{
    
    NSString *para = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)CUS_CUSTOMERID];
    
    
    _requestOrderList = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetExecutingOrderList" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSArray * arr = data;
            appointmentDoc.Appointment_ExecutingOrderNumber = [arr count];
            
            if (appointmentDoc.Appointment_ExecutingOrderNumber== 0) {
                [self gotoServiceList];
            }else
            {
                AppointmentExecutingOrderList_ViewController * order =[[AppointmentExecutingOrderList_ViewController alloc] init];
                order.delegate =self;
                order.customerID = CUS_CUSTOMERID;
                order.customerName =[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_SELFNAME"];
                [self.navigationController pushViewController:order animated:YES];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
            [self gotoServiceList];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

-(void)httpCreatAppointment
{
    if (appointmentDoc.Appointment_ReservedOrderType ==2 ) {
        appointmentDoc.Appointment_ReservedOrderID = 0 ;
        appointmentDoc.Appointment_ReservedOrderServiceID = 0 ;
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par = @{
                           @"BranchID":@((long)self.BranchID),
                           @"ExecutorID":@((long)appointmentDoc.Appointment_servicePersonalID),
                           @"TaskType":@(1),
                           @"Remark":appointmentDoc.Appointment_remark,
                           @"TaskScdlStartTime":appointmentDoc.Appointment_date,
                           @"ReservedOrderType":@((long)self.ReservedOrderType),
                           @"ReservedServiceCode":@((long long)self.serviceCode),
                           @"ReservedOrderID":@((long)self.orderID),
                           @"ReservedOrderServiceID":@((long)self.serviceID),
                           @"TaskSourceType":@(self.taskSourceType)
                           };
    
    _requestHttp = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/AddSchedule" showErrorMsg:YES  parameters:par WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            //                [SVProgressHUD showWithStatus:message maskType:(SVProgressHUDMaskType)]
            //                [SVProgressHUD showSuccessWithStatusWithDuration:message duration:2 touchEventHandle:^{
            //                    AppointmentList_ViewController * list = [[AppointmentList_ViewController alloc] init];
            //                    list.index = 1 ;
            //                    [self.navigationController pushViewController:list animated:YES];
            //                    [SVProgressHUD dismiss];
            //                }];
            [SVProgressHUD showSuccessWithStatusWithToch:message touchEventHandle:^{
            }];
            AppointmentList_ViewController * list = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointmentList_ViewController"];
            list.index = 1;
            self.tabBarController.selectedIndex = 1;
            [self.navigationController popToRootViewControllerAnimated:YES];
//            AppointmentList_ViewController * list = [[AppointmentList_ViewController alloc] init];
//            list.index = 1 ;
//            [self.navigationController pushViewController:list animated:YES];
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD showSuccessWithStatusWithToch:error touchEventHandle:^{
                
            }];
            
        }];
    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];
}


#pragma mark 备注编辑

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDefault;
    
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 310;
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

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (BOOL)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    appointmentDoc.Appointment_remark = textView.text;
}

- (void)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 16;
        _prevCaretRect = newCursorRect;
        [myTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(310.0f, 500.0f)];
    if (textViewSize.height < kTableView_DefaultCellHeight) {
        textViewSize.height = kTableView_DefaultCellHeight;
    }
    if (textViewSize.width < 310) {
        textViewSize.width = 310;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    appointmentDoc.Appointment_remark = textView.text;
    
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
    tvFrame.size.height = table_Height - (initialFrame.size.height + 5.0f);
    myTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    myTableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - 90.0f-44);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
