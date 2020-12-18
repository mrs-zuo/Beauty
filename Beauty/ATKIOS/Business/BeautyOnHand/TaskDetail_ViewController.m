//
//  TaskDetail_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TaskDetail_ViewController.h"
#import "NavigationView.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "NormalEditCell.h"
#import "AppointmentDoc.h"
#import "FooterView.h"
#import "ColorImage.h"
#import "UIButton+InitButton.h"
#import "OrderDetailViewController.h"
#import "NSDate+Convert.h"
#import "SelectCustomersViewController.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "OrderDetailViewController.h"
#import "CustomerBasicViewController.h"
#import "CustomerDoc.h"
#import "AppDelegate.h"
#import "TaskList_ViewController.h"
#import "CusMainViewController.h"
#import "ZXTaskTabbarViewController.h"


@interface TaskDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate,ContentEditCellDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (strong ,nonatomic) UITableView * myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentDetail;
@property (weak, nonatomic) AFHTTPRequestOperation *requestEditVisitTask;
@property (assign, nonatomic) CGFloat table_Height;
@property (strong,nonatomic) AppointmentDoc * appointmentDoc;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (strong ,nonatomic) NSString * createTime;

@end

@implementation TaskDetail_ViewController
@synthesize myTableView;
@synthesize table_Height;
@synthesize appointmentDoc;
@synthesize datePicker;
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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"回访详情"];
    [self.view addSubview:navigationView];
    
    [self initTableView];
    [self requestList];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f)style:UITableViewStyleGrouped];
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
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
    }
    table_Height = myTableView.frame.size.height;
    
    [self initButton];
}

-(void)initButton
{
    FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"完成回访" submitAction:@selector(taskEditConfirm) deleteTitle:@"暂存" deleteAction:@selector(taskEditCancel)];
    
    [footerView.deleteButton setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
    if (appointmentDoc.Appointment_status == 2) {//待回访
        [footerView showInTableView:myTableView];
    }
}

-(void)taskEditCancel
{
    NSDate *newDate;
    NSString *dataStr = appointmentDoc.Appointment_taskBackDate;
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *createTimeStr = self.createTime;
    NSDate * createTime = [NSDate stringToDate:createTimeStr dateFormat:@"yyyy-MM-dd HH:mm"];
    
    if ([newDate compare:createTime] == NSOrderedAscending) {
        [SVProgressHUD showSuccessWithStatus2:@"回访时间不能小于创建时间!" touchEventHandle:^{}];
        return;
    }
    
    if ([currentDate compare:newDate] == NSOrderedAscending) {
        
        [SVProgressHUD showSuccessWithStatus2:@"回访时间不能大于当前时间!" touchEventHandle:^{}];
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否暂存本次回访？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self EditVisitTaskHttpWithTaskStatus:0];
        }
    }];
}

-(void)taskEditConfirm
{
    NSDate *newDate;
    NSString *dataStr = appointmentDoc.Appointment_taskBackDate;
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *createTimeStr = self.createTime;
    NSDate * createTime = [NSDate stringToDate:createTimeStr dateFormat:@"yyyy-MM-dd HH:mm"];
    
    if ([newDate compare:createTime] == NSOrderedAscending) {
        [SVProgressHUD showSuccessWithStatus2:@"回访时间不能小于创建时间!" touchEventHandle:^{}];
        return;
    }
    
    if ([currentDate compare:newDate] == NSOrderedAscending) {
        [SVProgressHUD showSuccessWithStatus2:@"回访时间不能大于当前时间!" touchEventHandle:^{}];
        return;
    }
    
    if ([appointmentDoc.Appointment_taskBackDate isEqualToString:@""]) {
        [SVProgressHUD showSuccessWithStatus2:@"请输入回访时间!" touchEventHandle:^{}];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成本次回访？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
             [self EditVisitTaskHttpWithTaskStatus:3];
        }
    }];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
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
    if (indexPath.row ==2 && indexPath.section ==1) {
        if (appointmentDoc.Appointment_remark.length > 0) {
            __autoreleasing ContentEditCell *cell = [[ContentEditCell alloc] init];
            cell.contentEditText.text = appointmentDoc.Appointment_remark;
            CGFloat height = [cell.contentEditText sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
            return height < kTableView_HeightOfRow ? kTableView_HeightOfRow : height;
        }
    }
    if (indexPath.section == 0) {
        if (indexPath.row ==4) {
            return 30;
        }
        if (indexPath.row ==5) {
            if (appointmentDoc.Appointment_TaskBackContent.length > 0) {
                NSInteger height = [appointmentDoc.Appointment_TaskBackContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 25;
                return height ;
            }
        }
    }
       return kTableView_HeightOfRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if([appointmentDoc.Appointment_orderNumber  isKindOfClass:[NSNull class]])
        {
            return 6;
        }
        return 7;
    }
    
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString * cellIdentify = [NSString stringWithFormat: @"cell_%@",indexPath];
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
            {
                cell.titleLabel.text = @"回访类型";
                cell.valueText.text = appointmentDoc.Appointment_TaskTypeStr;
            }
                break;
            case 1:
                if (appointmentDoc.Appointment_customerID > 0) {
                    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                    [cell.contentView addSubview:arrowsImage];
                    
                    [cell setAccessoryText:@"    "];
                }
                cell.titleLabel.text = @"回访顾客";
                cell.valueText.text = appointmentDoc.Appointment_customer;
                break;
            case 2:
                cell.titleLabel.text = @"回访期限";
                cell.valueText.text = appointmentDoc.Appointment_date;
                break;
            case 3:
            {
                cell.titleLabel.text = @"回访内容";
                cell.valueText.text = @"";
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                }
            }
                break;
            case 4:
            {
                cell.titleLabel.frame = CGRectMake(10.0f, kTableView_HeightOfRow/2 - 20.0f/2, 300, 20.0f);
                cell.titleLabel.text = appointmentDoc.Appointment_servicename;
                cell.titleLabel.textColor = kColor_Black;
                cell.valueText.text = @" ";
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                }
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [cell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                }
            }
                break;
            case 5:
            {
                static NSString *editCellIdentifier = @"editCell";
                ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                editCell.contentEditText.text = appointmentDoc.Appointment_TaskBackContent;
                editCell.contentEditText.tag = 1000;
                editCell.contentEditText.textColor = kColor_Black;
                editCell.contentEditText.font = kFont_Light_16;
                editCell.delegate = self;
                editCell.userInteractionEnabled = NO;
                return editCell;
            }
                break;
            case 6:
            {
                cell.titleLabel.text = @"相关订单";
                cell.valueText.text = appointmentDoc.Appointment_orderNumber;
                [cell setAccessoryText:@"    "];
                
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
            }
                break;
            default:
                break;
        }
        
    }else if(indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"回访时间" ;
                cell.valueText.placeholder = @"选择回访时间";
                cell.valueText.tintColor = [UIColor clearColor];
                cell.valueText.delegate = self ;
                if (appointmentDoc.Appointment_status == 2) {
                    cell.valueText.userInteractionEnabled = YES ;
                    cell.valueText.textColor = kColor_Editable;
                }
                cell.valueText.text = appointmentDoc.Appointment_taskBackDate ;
            }
                break;
            case 1:
            {
                cell.titleLabel.text = @"回访结果" ;
                cell.valueText.text = @"" ;
            }
                break;
            case 2:
            {
                static NSString *editCellIdentifier = @"editCell";
                ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                if ( appointmentDoc.Appointment_remark.length == 0 && appointmentDoc.Appointment_status ==2) {
                    editCell.contentEditText.placeholder = @"请输入备注...";
                }else
                {
                    editCell.contentEditText.text = appointmentDoc.Appointment_remark;
                }
                editCell.contentEditText.tag = 1000;
                editCell.contentEditText.font = kFont_Light_16;
                editCell.delegate = self;
                if (appointmentDoc.Appointment_status == 2) {
                    editCell.contentEditText.userInteractionEnabled = YES;
                }else
                {
                    editCell.contentEditText.userInteractionEnabled = NO;
                }
                return editCell;
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
    if (indexPath.section ==0) {
        if (indexPath.row == 1) {
            if (appointmentDoc.Appointment_customerID > 0) {
                CustomerDoc *doc = [[CustomerDoc alloc] init];
                [doc setCus_ID:appointmentDoc.Appointment_customerID];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                app.customer_Selected = doc ;//保存选中顾客
                
//                CustomerBasicViewController *customerBasic = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CusTabBarController"];
                CusMainViewController *cusMain = [[CusMainViewController alloc] init];
                ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 1;
                [self.navigationController pushViewController:cusMain animated:YES];
            }
        }else if (indexPath.row == 6) {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OrderDetailViewController *orderDetail = [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
            orderDetail.orderID = appointmentDoc.Appointment_orderID;
            orderDetail.productType = 0;
            orderDetail.objectID  = appointmentDoc.Appointment_orderObjectID;
            [self.navigationController pushViewController:orderDetail animated:YES];
        }
    }
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

-(void)requestList
{
    NSDictionary * par = @{
                           @"LongID":@(self.LongID),
                           };
    
    _requestAppointmentDetail = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            
            appointmentDoc = [[AppointmentDoc alloc] init];
            [appointmentDoc setAppointment_customer:[data objectForKey:@"TaskOwnerName"]];
            [appointmentDoc setAppointment_customerID:[[data objectForKey:@"TaskOwnerID"] integerValue]];
            [appointmentDoc setAppointment_remark:[data objectForKey:@"TaskResult"]];
            [appointmentDoc setAppointment_status:[[data objectForKey:@"TaskStatus"] intValue]];
            [appointmentDoc setAppointment_date:[data objectForKey:@"TaskScdlStartTime"]];
            [appointmentDoc setAppointment_servicename:[data objectForKey:@"ProductName"]];

            [appointmentDoc setAppointment_number:[[data objectForKey:@"TaskID"] longLongValue]];
            [appointmentDoc setAppointment_branchName:[data objectForKey:@"BranchName"]];
            [appointmentDoc setAppointment_orderNumber:[data objectForKey:@"OrderNumber"]];
            [appointmentDoc setAppointment_orderID:[[data objectForKey:@"OrderID"] integerValue]];
            [appointmentDoc setAppointment_orderObjectID:[[data objectForKey:@"OrderObjectID"] integerValue]];
            [appointmentDoc setAppointment_TaskBackContent:[data objectForKey:@"TaskDescription"]];
            [appointmentDoc setAppointment_TaskType:[[data objectForKey:@"TaskType"] integerValue]];
            [appointmentDoc setAppointment_taskBackDate: [[data objectForKey:@"ExecuteStartTime"] isKindOfClass:[NSNull class]]? @"":[data objectForKey:@"ExecuteStartTime"]];
            if (appointmentDoc.Appointment_taskBackDate.length ==0) {
                NSDate *currentDate =  [NSDate date];
                NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *  locationString=[dateformatter stringFromDate:currentDate];
                appointmentDoc.Appointment_taskBackDate = locationString ;
            }
            self.createTime = [data objectForKey:@"CreateTime"];
            
            [self initButton];
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

-(void)EditVisitTaskHttpWithTaskStatus:(NSInteger)TaskStatus
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary * par = @{
                           @"ID":@((long long)self.LongID),
                           @"TaskStatus":@((long)TaskStatus),
                           @"ExecuteStartTime":appointmentDoc.Appointment_taskBackDate,
                           @"TaskResult":appointmentDoc.Appointment_remark
                           };
    _requestEditVisitTask = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/EditVisitTask" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            [SVProgressHUD showSuccessWithStatus2:message duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
//                for (UIViewController *temp in self.navigationController.viewControllers) {
//                    if ([temp isKindOfClass:[TaskList_ViewController class]]) {
//                        [temp performSelector:@selector(headerRefresh) withObject:nil];
//                        [self.navigationController popToViewController:temp animated:YES];
//                    }
//                }
                [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self initialKeyboard];
    self.textField_Selected  = textField;
    self.textField_Selected.inputAccessoryView = inputAccessoryView;
    self.textField_Selected.inputView = datePicker;
    NSDate *theDate = [NSDate stringToDate:self.textField_Selected.text dateFormat:@"yyyy年MM月dd日 HH:mm"];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        CGRect frame = self.inputView.frame;
        frame.size = [self.datePicker sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame1 = inputAccessoryView.frame;
        frame1.size.height = 35.0f;
        inputAccessoryView.frame = frame1;
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        [cancelBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, cancelBtn, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
}

- (void)dateChanged:(id)sender
{
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)self.textField_Selected.superview.superview.superview;
    else
        cell = (UITableViewCell *)self.textField_Selected.superview.superview;
}

- (void)done:(id)sender
{
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSString *dataStr = [NSDate dateToString:datePicker.date dateFormat:@"yyyy-MM-dd HH:mm"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)self.textField_Selected.superview.superview.superview;
    else
        cell = (UITableViewCell *)self.textField_Selected.superview.superview;
    
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];

    
    inputAccessoryView = nil;
    
    [self.textField_Selected setText:[NSString stringWithFormat:@"%@", dataStr]];
    appointmentDoc.Appointment_taskBackDate = [NSString stringWithFormat:@"%@", dataStr];
    
    if(IOS8){
        datePicker = nil;
    }
    else
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    [myTableView reloadData];

    [self.textField_Selected resignFirstResponder];
}

-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)self.textField_Selected.superview.superview.superview;
    else
        cell = (UITableViewCell *)self.textField_Selected.superview.superview;
    
    inputAccessoryView = nil;
    datePicker = nil;
    
    [self.textField_Selected resignFirstResponder];
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
