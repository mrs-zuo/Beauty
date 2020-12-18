//
//  AppointmenCreat_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmenCreat_ViewController.h"
#import "GPBHTTPClient.h"
#import "NavigationView.h"
#import "NormalEditCell.h"
#import "UIButton+InitButton.h"
#import "DFDateView.h"
#import "NSDate+Convert.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AppointmentDoc.h"
#import "SelectCustomersViewController.h"
#import "ContentEditCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AppointmentExecutingOrderList_ViewController.h"
#import "ServiceListViewController.h"
#import "AppointmentList_ViewController.h"
#import "AppDelegate.h"
#import "WorkSheetViewController.h"
#import "GPNavigationController.h"
#import "AppointmentFilterDoc.h"


@interface AppointmenCreat_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,SelectCustomersViewControllerDelegate,ContentEditCellDelegate,UITextViewDelegate,SelectServiceControllerDelegate,WorkSheetViewControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestHttp;
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic ,strong) NSString * dateForStartStr;
@property (assign, nonatomic) CGFloat table_Height;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) UITextField *textField_Editing;
@property (strong, nonatomic) AppointmentDoc * appointmentDoc;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign ,nonatomic) NSInteger flag;

@end

@implementation AppointmenCreat_ViewController

@synthesize myTableView,datePicker;
@synthesize dateForStartStr,table_Height;
@synthesize inputAccessoryView;
@synthesize  appointmentDoc;

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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"创建预约"];
    [self.view addSubview:navigationView];
    
    //重置
    UIButton *cancelButton = [UIButton buttonWithTitle:@"重置" target:self selector:@selector(initdata) frame:CGRectMake(310-50, 7.5f, 50 ,22.0f)backgroundImg:ButtonStyleBlue];
    [navigationView addSubview:cancelButton];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [self initTableView];
    [self initdata];
}

#pragma mark -init

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49)style:UITableViewStyleGrouped];
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
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
     table_Height = myTableView.frame.size.height +40;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_Background_View;
    [self.view addSubview:footView];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(creatAppointment) frame:CGRectMake(5.0f, 5.0f, 310.0f, 39.0f) backgroundImg:ButtonStyleBlue];
    [footView addSubview:add_Button];

}

-(void)initdata
{
    dateForStartStr = @"";
    appointmentDoc = [[AppointmentDoc alloc] init];

    if (self.viewTag == 1) {
        appointmentDoc.Appointment_customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
        appointmentDoc.Appointment_customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name;
    }
    if (self.viewTag == 2) {
        appointmentDoc.Appointment_ReservedOrderID = self.orderID;
        appointmentDoc.Appointment_ReservedOrderServiceID = self.orderObjectID;
        appointmentDoc.Appointment_ReservedOrderType =  1 ;
        appointmentDoc.Appointment_servicename = self.serveName;
        appointmentDoc.Appointment_customer = self.cusName;
        appointmentDoc.Appointment_customerID = self.cusID ;
    }
    
    [myTableView reloadData];
}

-(void)creatAppointment
{
    if (appointmentDoc.Appointment_customerID == 0) {
//        [SVProgressHUD showSuccessWithStatus2:@"请选择顾客！" touchEventHandle:^{}];
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客！" touchEventHandle:^{
            
        }];
        return;
    }
    if (appointmentDoc.Appointment_date.length == 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择到店时间！" touchEventHandle:^{
            
        }];
        return;
    }
    if(appointmentDoc.Appointment_ReservedOrderType ==1)
    {
        if (appointmentDoc.Appointment_ReservedOrderID == 0) {
            [SVProgressHUD showErrorWithStatus2:@"请选择预约服务！" touchEventHandle:^{
                
            }];
            return;
        }
    }else
    {
        if (appointmentDoc.Appointment_serviceCode == 0) {
            [SVProgressHUD showErrorWithStatus2:@"请选择预约服务！" touchEventHandle:^{
                
            }];
            return;
        }
    }
    if (appointmentDoc.Appointment_assignType == 1 && appointmentDoc.Appointment_servicePersonalID ==0) {
        
        [SVProgressHUD showSuccessWithStatus2:@"请选择指定顾问！" touchEventHandle:^{}];
        return;
    }
    [self httpCreatAppointment];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==2 && indexPath.row==1) {
        if (appointmentDoc.Appointment_remark.length > 0) {
            NSInteger height = [appointmentDoc.Appointment_remark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 500) lineBreakMode:NSLineBreakByCharWrapping].height + 25;
            return height < kTableView_HeightOfRow ? kTableView_HeightOfRow : height;
        }
    }

    return kTableView_HeightOfRow;
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
        return 3;
    }else if (section == 1) {
        if (appointmentDoc.Appointment_assignType == 0) {
            return 1;
        }else
            return 2;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString * cellIdentify = [NSString stringWithFormat:@"cell_%ld",(long)indexPath.row];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.enabled = NO;
        
    }
    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
    
    if (indexPath.section ==0) {

        switch (indexPath.row) {
            case 0:
                if (!(self.viewTag ==1 || self.viewTag == 2)) {
                     [cell.contentView addSubview:arrowsImage];;
                    [cell setAccessoryText:@"   "];
                }
                cell.titleLabel.text = @"顾客";
                cell.valueText.placeholder = @"选择顾客";
                cell.valueText.text = appointmentDoc.Appointment_customer;
                break;
            case 1:{
                cell.valueText.enabled = NO ;
                cell.titleLabel.text = @"到店时间";
                 [cell.contentView addSubview:arrowsImage];
                cell.valueText.placeholder = @"选择到店时间";
                cell.valueText.text = appointmentDoc.Appointment_date;
                cell.valueText.userInteractionEnabled = NO;
                [cell setAccessoryText:@"   "];
            }
                break;
            case 2:
                if (self.viewTag != 2) {
                     [cell.contentView addSubview:arrowsImage];
                    [cell setAccessoryText:@"   "];
                }
                cell.titleLabel.text = @"预约服务";
                cell.valueText.placeholder = @"选择服务";
                cell.valueText.text = appointmentDoc.Appointment_servicename;
                
                break;
            default:
                break;
        }
    }else if(indexPath.section ==1)
    {
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"是否指定顾问";
                cell.valueText.text = appointmentDoc.Appointment_assignType ==0 ? @"到店指定":@"指定";
                break;
            case 1:
                cell.titleLabel.text = @"指定顾问";
                cell.valueText.placeholder = @"选择员工";
                cell.valueText.text = appointmentDoc.Appointment_servicePersonal;
                break;
            default:
                break;
        }
    }else if(indexPath.section ==2)
    {
        if(indexPath.row ==0)
            cell.titleLabel.text = @"备注";
        else
        {
            cell.titleLabel.text = @"" ;
            static NSString *editCellIdentifier = @"editCell";
            
            ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
            
            if ( [appointmentDoc.Appointment_remark isEqualToString:@""] || appointmentDoc.Appointment_remark.length == 0) {
                editCell.contentEditText.placeholder = @"请输入备注...";
            } else {
                editCell.contentEditText.text = appointmentDoc.Appointment_remark;
            }
            editCell.contentEditText.tag = 1000;
            editCell.contentEditText.font = kFont_Light_16;
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
                if (!(self.viewTag ==1 || self.viewTag == 2)) {
                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                    SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
                    selectCustomer.navigationTitle = @"选择顾客";
                    CUSTOMERRANGE customerRange = CUSTOMEROFMINE;
                    UserDoc *userDoc = [UserDoc new];
                    userDoc.user_Type = 0;
                    userDoc.user_Available = 1;
                    if(appointmentDoc.Appointment_customerID != 0){
                        userDoc.user_Id = appointmentDoc.Appointment_customerID;
                        userDoc.user_Name = appointmentDoc.Appointment_customer;
                    }
                    
                    [selectCustomer setSelectModel:0
                                          userType:4
                                     customerRange:customerRange
                              defaultSelectedUsers:userDoc.user_Id != 0 ? @[userDoc] : nil];
                    selectCustomer.delegate = self;
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
                    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:navigationController animated:YES completion:^{}];
                }

            }
                break;
            case 1:
            {
//                [self initialKeyboard];
//                self.textField_Selected  = [(NormalEditCell *)[tableView cellForRowAtIndexPath:indexPath] valueText];
//                NSDate *theDate = [NSDate stringToDate:self.textField_Selected.text dateFormat:@"yyyy年MM月dd日 HH:mm"];
//                if (theDate != nil && ![theDate  isEqual: @""]) {
//                    [datePicker setDate:theDate];
//                }
                [self gotoWorkSheetWithType:1];
            }
                break;
            case 2:
            {
               if (self.viewTag != 2) {
                   [self GetExecutingOrderList];
               }
            }
                break;
                
            default:
                break;
        }
    }else if(indexPath.section ==1)
    {
//        if (indexPath.row ==0) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否指定顾问" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"指定", @"到店指定", nil];
//            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex == 0) return ;
//                switch (buttonIndex) {
//                    case 1:
//                        appointmentDoc.Appointment_assignType = 1;
//                        break;
//                    case 2:
//                        appointmentDoc.Appointment_assignType = 0;
//                        appointmentDoc.Appointment_servicePersonal = @"";
//                        appointmentDoc.Appointment_servicePersonalID = 0;
//                        break;
//                }
//                [myTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//            }];
//        }else if(indexPath.row ==1)
//        {
//            [self gotoWorkSheetWithType:2];
//            if (appointmentDoc.Appointment_assignType == 1) {
//                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//                SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
//                selectCustomer.accRange = ACCBRANCH;
//                if ([[PermissionDoc sharePermission] rule_BranchOrder_Read] || kMenu_Type == 1)
//                    selectCustomer.accRange = ACCBRANCH;
//                else
//                    selectCustomer.accRange = ACCACCOUNT;
//                
//                [selectCustomer setSelectModel:0
//                                      userType:2
//                                 customerRange:(kMenu_Type == 1 ? CUSTOMEROFMINE: ([[PermissionDoc sharePermission] rule_BranchOrder_Read] ? CUSTOMEROFMINE: CUSTOMERINBRANCH))
//                          defaultSelectedUsers:appointmentDoc.accountArray];
//                selectCustomer.navigationTitle = @"选择顾问";
//                selectCustomer.personType = CustomePersonGroup;
//                selectCustomer.delegate = self;
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
//                [self presentViewController:navigationController animated:YES completion:^{}];
//            }
//        }
    }
}

-(void)gotoWorkSheetWithType:(NSInteger )type
{
    
//    if (appointmentDoc.Appointment_customerID == 0) {
//        [SVProgressHUD showSuccessWithStatus2:@"请选择顾客！" touchEventHandle:^{}];
//        return;
//    }
//    if (appointmentDoc.Appointment_ReservedOrderID == 0) {
//        [SVProgressHUD showSuccessWithStatus2:@"请选择服务！" touchEventHandle:^{}];
//        return ;
//    }
//    
//
    self.flag = type;
    
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

-(void)gotoServiceList{

    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceListViewController *serviceListVC = [sb instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
    serviceListVC.delegate = self;
    serviceListVC.returnViewTag = 1;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:serviceListVC];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];

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
            datePicker.frame = CGRectMake(-8, 30, 320, 390);
        else
            datePicker.frame = CGRectMake(0, 20, 320, 390);
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
        if(IOS8)
            [inputAccessoryView setFrame:CGRectMake(-8, 0, 320, 35)];
        else
            inputAccessoryView.frame = CGRectMake(0, 0, 320, 35);
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        [cancelBtn setTintColor:kColor_White];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, cancelBtn, doneBtn, nil];
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
}

- (void)dateChanged:(id)sender
{
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
}

- (void)done:(id)sender
{
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSString *dataStr = [NSDate dateToString:datePicker.date dateFormat:@"yyyy-MM-dd HH:mm"];

    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];

    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
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


-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height - initialFrame.size.height + 5.0f;
    myTableView.frame = tvFrame ;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = table_Height -49;
    myTableView.frame = tvFrame;
}

#pragma mark - dismissViewControllerDelegate
-(void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    if (userArray.count >0) {
        UserDoc * userDoc = [[UserDoc alloc] init];
        userDoc = [userArray objectAtIndex:0];
        appointmentDoc.Appointment_servicePersonal = userDoc.user_Name;
        appointmentDoc.Appointment_servicePersonalID = userDoc.user_Id;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:1];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    for (UserDoc * userDoc in userArray) {
        if (userDoc.user_Id != appointmentDoc.Appointment_customerID && appointmentDoc.Appointment_customerID !=0) {
//            appointmentDoc.Appointment_servicePersonal= @"";
//            appointmentDoc.Appointment_servicePersonalID = 0;
            
            appointmentDoc.Appointment_serviceCode = 0;
            appointmentDoc.Appointment_ReservedOrderID = 0;
            appointmentDoc.Appointment_ReservedOrderServiceID = 0 ;
            appointmentDoc.Appointment_servicename = @"" ;
            
        }
        
        appointmentDoc.Appointment_customer = userDoc.user_Name;
        appointmentDoc.Appointment_customerID = userDoc.user_Id;
        
    }

    [myTableView reloadData];
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

#pragma mark Http request

- (void)GetExecutingOrderList
{
    if (appointmentDoc.Appointment_customerID == 0) {
        [self gotoServiceList];
    }else {

        NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)appointmentDoc.Appointment_customerID];
        _requestOrderList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetExecutingOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message){
                    NSArray * arr = data;
                    appointmentDoc.Appointment_ExecutingOrderNumber = [arr count];
                    
                    if (appointmentDoc.Appointment_ExecutingOrderNumber== 0) {
                        [self gotoServiceList];
                    }else
                    {
                        AppointmentExecutingOrderList_ViewController * order =[[AppointmentExecutingOrderList_ViewController alloc] init];
                        order.delegate =self;
                        order.customerID = appointmentDoc.Appointment_customerID;
                        order.customerName = appointmentDoc.Appointment_customer;
                        
                        GPNavigationController * navController = [[GPNavigationController alloc] initWithRootViewController:order];
                        navController.canDragBack = YES;
//                        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:order];
                        navController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:navController animated:YES completion:^{}];
                    }
                    
            } failure:^(NSInteger code, NSString *error) {
                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
            }];
        } failure:^(NSError *error) {
            
        }];
    }
}

-(void)httpCreatAppointment
{
    appointmentDoc.Appointment_TaskType = 1 ;
    if (appointmentDoc.Appointment_ReservedOrderType ==2 ) {
        appointmentDoc.Appointment_ReservedOrderID = 0 ;
        appointmentDoc.Appointment_ReservedOrderServiceID = 0 ;
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par = @{
                               @"ExecutorID":@((long)appointmentDoc.Appointment_servicePersonalID),
                               @"TaskType":@((long)appointmentDoc.Appointment_TaskType),
                               @"Remark":appointmentDoc.Appointment_remark,
                               @"TaskScdlStartTime":appointmentDoc.Appointment_date,
                               @"ReservedOrderType":@((long)appointmentDoc.Appointment_ReservedOrderType),
                               @"ReservedServiceCode":@((long long)appointmentDoc.Appointment_serviceCode),
                               @"TaskOwnerID":@((long)appointmentDoc.Appointment_customerID),
                               @"ReservedOrderID":@((long)appointmentDoc.Appointment_ReservedOrderID),
                               @"ReservedOrderServiceID":@((long)appointmentDoc.Appointment_ReservedOrderServiceID)
                           };
    
    _requestHttp = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/AddSchedule" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            [SVProgressHUD showSuccessWithStatus2:@"创建成功" duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];

                if (self.viewTag == 2) {
                     [self.navigationController popViewControllerAnimated:YES];
                }else
                {
                    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithCus_ID:)])
                    {
                        //[self.delegate dismissViewControllerWithCus_ID:appointmentDoc.Appointment_customerID];
						[self.delegate dismissViewControllerWithCus_ID:0];
                        [self.navigationController popViewControllerAnimated:YES];
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


#pragma mark 备注编辑

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    contentText.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
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
        newCursorRect.size.height += 16;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
