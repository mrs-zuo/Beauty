//
//  .f_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentDetail_ViewController.h"
#import "AppointmentDoc.h"
#import "AppointmentList_ViewController.h"
#import "ContentEditCell.h"
#import "OrderDoc.h"
#import "OrderDetailAboutServiceViewController.h"
#import "RemarkEditCell.h"
#import "SelectServicePersonnal_ViewController.h"
#include "UserDoc.h"


@interface AppointmentDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextViewDelegate,ContentEditCellDelegate,SelectCustomersViewControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentDetail;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentCancel;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong,nonatomic) AppointmentDoc * appointmentDoc;
@property (strong ,nonatomic) NSString * orderNUmber;
@property (strong ,nonatomic) NSString * orderName;
@property (assign ,nonatomic) double totleSale;
@property (assign, nonatomic) NSInteger orderID;
@property (assign, nonatomic) NSInteger orderObjectID;
@property (strong ,nonatomic) UIButton * buttonCancel;
@property (strong ,nonatomic) UIButton * buttonConfirm;
@property (strong ,nonatomic) UIButton * buttonEdit;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) CGFloat table_Height;
@property (nonatomic, strong) NSMutableArray *orderArray;
@property (nonatomic ,assign) long long ProductCode;
@property (nonatomic,assign)NSInteger editAppointment;
@property (nonatomic,strong)OrderDoc * orderDoc;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) UITextField *textField_Editing;
@property (assign, nonatomic) NSInteger branchID;
@end

@implementation AppointmentDetail_ViewController
@synthesize myTableView;
@synthesize appointmentDoc;
@synthesize buttonCancel,buttonConfirm,buttonEdit;
@synthesize table_Height;
@synthesize editAppointment;
@synthesize orderDoc;
@synthesize inputAccessoryView,datePicker;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

-(void)goBack
{
    self.tabBarController.tabBar.hidden = NO;
    [super goBack];
}
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.title = @"预约详情";
    self.orderName = @"";
    self.orderNUmber = @"" ;
    self.totleSale = 0;
    
    [self initTableView];
    [self requestDetail];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 49 + 20)style:UITableViewStyleGrouped];
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
    
    table_Height = myTableView.frame.size.height+49;
    
    [self initButton];
}

-(void)initButton
{
    
    table_Height = myTableView.frame.size.height+49;
    
    if (appointmentDoc.Appointment_status == 3 || appointmentDoc.Appointment_status == 4) {
        
        myTableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - 45);

    }else if(appointmentDoc.Appointment_status == 1 || appointmentDoc.Appointment_status == 2){
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
        footView.backgroundColor = kColor_FootView;
        [self.view addSubview:footView];
        
        UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
        [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
        [footView addSubview:footViewImage];
        [footView setUserInteractionEnabled:YES];
        [self.view bringSubviewToFront:footView];
        
        if (editAppointment) {
            [buttonCancel removeFromSuperview];
            [buttonEdit removeFromSuperview];
        
            buttonConfirm = [UIButton buttonWithTitle:@"编辑保存"
                                                      target:self
                                                    selector:@selector(confirmAction)
                                                       frame:CGRectMake(5.0f, 5.0f, kSCREN_BOUNDS.size.width - 10, 39.0f)
                                               backgroundImg:nil
                                            highlightedImage:nil];
            buttonConfirm.titleLabel.font=kNormalFont_14;
            [footView addSubview:buttonConfirm];
            buttonConfirm.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
            
        }else{
            [buttonConfirm removeFromSuperview];
            
            if (appointmentDoc.Appointment_status == 1 ) {

                buttonCancel= [UIButton buttonWithTitle:@"预约取消"
                                                          target:self
                                                        selector:@selector(cancelAction)
                                                           frame:CGRectMake( 5, 5 , 152.5, 39)
                                                   backgroundImg:nil
                                                highlightedImage:nil];
                buttonCancel.backgroundColor = kButtonColor_Pink;
                buttonCancel.titleLabel.font=kNormalFont_14;
                [footView addSubview:buttonCancel];
                
                buttonEdit = [UIButton buttonWithTitle:@"预约编辑"
                                                          target:self
                                                        selector:@selector(editAction)
                                                           frame:CGRectMake(162.5, 5 , 152.5, 39)
                                                   backgroundImg:nil
                                                highlightedImage:nil];
                buttonEdit.titleLabel.font=kNormalFont_14;
                [footView addSubview:buttonEdit];
                
                buttonEdit.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
            }else if (appointmentDoc.Appointment_status == 2)
            {
                buttonCancel= [UIButton buttonWithTitle:@"预约取消"
                                                 target:self
                                               selector:@selector(cancelAction)
                                                  frame:CGRectMake( 5, 5 , kSCREN_BOUNDS.size.width - 10, 39)
                                          backgroundImg:nil
                                       highlightedImage:nil];
                buttonCancel.backgroundColor = kButtonColor_Pink;
                buttonCancel.titleLabel.font=kNormalFont_14;
                [footView addSubview:buttonCancel];
            }
        }
    }
}

-(void)cancelAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否取消本次预约？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self cancelAppointmentHttp];
        }
    }];
}

-(void)editAction
{
    editAppointment = 1;
    
    [self initButton];
    
    [myTableView reloadData];
}

-(void)confirmAction
{
    
    NSDate *newDate ;;
    NSString *dataStr = appointmentDoc.Appointment_date;

    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];
    
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd HH:mm"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd HH:mm"];
    
    if (([newDate compare:currentDate] == NSOrderedAscending) ||([newDate compare:currentDate] == NSOrderedSame)) {
        
        [SVProgressHUD showErrorWithStatus2:@"预约时间小于当前时间!" ];
        return;
    }
    
    [self editAppointmentHttp];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==1 && indexPath.section == 1) {

        if (appointmentDoc.Appointment_remark.length > 0) {
            NSInteger height = [appointmentDoc.Appointment_remark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(310, 500) lineBreakMode:NSLineBreakByCharWrapping].height + 20;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
        }
    }
    
    return kTableView_DefaultCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 3;
    }else if (section == 0) {
        return 6;
    }else{
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
                cell.titleLabel.text = @"预约状态";
                cell.valueText.text = appointmentDoc.Appointment_statusStr;
                break;
            case 2:
                cell.titleLabel.text = @"预约门店";
                cell.valueText.text = appointmentDoc.Appointment_branchName;
                break;
            case 3:
                if (editAppointment==1) {
                    cell.valueText.textColor = kColor_Editable;
                }else
                {
                    cell.valueText.textColor  =[ UIColor blackColor];
                }
                cell.titleLabel.text = @"到店时间";
                cell.valueText.text = appointmentDoc.Appointment_date;
//                if (appointmentDoc.Appointment_status ==1){
//                    cell.valueText.textColor = kColor_Editable;
//                }
                break;
            case 4:
                cell.titleLabel.text = @"预约内容";
                cell.valueText.text = appointmentDoc.Appointment_servicename;
                break;
//            case 5:
//                if (editAppointment==1) {
//                    
//                    cell.valueText.textColor = kColor_Editable;
//                }else
//                {
//                    cell.valueText.textColor  =[ UIColor blackColor];
//                }
//                cell.titleLabel.text = @"是否指定顾问";
//                if (appointmentDoc.Appointment_assignType == 1) {
//                     cell.valueText.text = @"指定";
//                }else
//                {
//                     cell.valueText.text = @"到店指定";
//                }
//                break;
            case 5:
            {
               
                UIButton * deleteButton = (UIButton *)[cell.contentView viewWithTag:89];
                if (!deleteButton) {
                    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(320-40, 10, 30, 30)];
                    [deleteButton setImage:[UIImage imageNamed:@"DesignaedDelete"] forState:UIControlStateNormal];
                    deleteButton.tag = 89 ;
                    [deleteButton addTarget:self action:@selector(deleteServicePerson:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:deleteButton];
                }
                deleteButton.hidden = YES;
                if (editAppointment==1) {
                    cell.valueText.textColor = kColor_Editable;
                    if (appointmentDoc.Appointment_servicePersonalID >0) {
                        deleteButton.hidden = NO;
                        cell.valueText.frame = CGRectMake(125.0f, (kTableView_DefaultCellHeight- 20.0f)/2 , 155, 20.0f);
                    }else
                    {
                        cell.valueText.frame = CGRectMake(150.0f, (kTableView_DefaultCellHeight- 20.0f)/2 , 155, 20.0f);
                    }

                }else
                {
                    cell.valueText.frame = CGRectMake(150.0f, (kTableView_DefaultCellHeight- 20.0f)/2 , 155, 20.0f);
                    cell.valueText.textColor  =[ UIColor blackColor];
                }
                cell.titleLabel.text = @"指定顾问";
                cell.valueText.placeholder = @"选择员工";
                cell.valueText.text = appointmentDoc.Appointment_servicePersonalID ==0 ? @"到店指定":appointmentDoc.Appointment_servicePersonal;
            }
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"留言";
                cell.valueText.text = @"";
                break;
            case 1:
                {
                    cell.titleLabel.text = @"" ;
                    static NSString *editCellIdentifier = @"editCell";
                    
                    RemarkEditCell  *editCell = [[RemarkEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                     editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if ( editAppointment ==1) {
                        if (appointmentDoc.Appointment_remark.length ==0) {
                            editCell.contentEditText.placeholder = @"请输入留言...";
                        }
                        
                        editCell.contentEditText.textColor = kColor_Editable;
                    } else {
                        if (appointmentDoc.Appointment_remark.length ==0) {
                            editCell.contentEditText.placeholder = @"暂无留言";
                        }
                        
                        editCell.contentEditText.userInteractionEnabled = NO;
                        editCell.contentEditText.textColor = [UIColor blackColor];
                    }
                    CGRect rect=editCell.contentEditText.frame;
                    rect.origin.x=5;
                    rect.origin.y=0;
                    editCell.contentEditText.frame=rect;
                    editCell.contentEditText.text = appointmentDoc.Appointment_remark;
                    editCell.contentEditText.tag = 1000;
                    editCell.contentEditText.font = kNormalFont_14;
                    editCell.delegate = self;
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
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
                
                cell.titleLabel.text = @"订单编号" ;
                cell.valueText.text = [self.orderNUmber isKindOfClass:[NSNull class]]?@"":self.orderNUmber ;
                CGRect rect=cell.valueText.frame;
                rect.origin.x=125;
                cell.valueText.frame=rect;
                [cell setAccessoryText:@"    "];
            }
                break;
            case 1:
                cell.titleLabel.text = self.orderName ;
                break;
            case 2:
                cell.titleLabel.text = @"订单金额" ;
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,self.totleSale] ;
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
    self.hidesBottomBarWhenPushed = YES;
    if(indexPath.section ==0 && editAppointment==1){
        switch (indexPath.row) {
            case 3:
            {
                [self initialKeyboard];
                self.textField_Editing  = [(NormalEditCell *)[tableView cellForRowAtIndexPath:indexPath] valueText];
                NSDate *theDate = [NSDate stringToDate:self.textField_Editing.text dateFormat:@"yyyy年MM月dd日 HH:mm"];
                if (theDate != nil && ![theDate  isEqual: @""]) {
                    [datePicker setDate:theDate];
                }
            }
                break;
//            case 5:
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否指定顾问" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"指定", @"到店指定", nil];
//                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    if (buttonIndex == 0) return ;
//                    switch (buttonIndex) {
//                        case 1:
//                            appointmentDoc.Appointment_assignType = 1;
//                            break;
//                        case 2:
//                            appointmentDoc.Appointment_assignType = 0;
//                            appointmentDoc.Appointment_servicePersonal = @"";
//                            appointmentDoc.Appointment_servicePersonalID = 0;
//                            break;
//                    }
//                    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//                }];
//                
//            }
                break;
            case 5:
            {
//                if (appointmentDoc.Appointment_assignType == 1) {
                    SelectServicePersonnal_ViewController *selectCustomer = [[SelectServicePersonnal_ViewController alloc] init];
                    selectCustomer.delegate = self;
                    selectCustomer.BracnID = appointmentDoc.Appointment_branchID;
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
                    [self presentViewController:navigationController animated:YES completion:^{}];
                    
//                }
            }
                break;
                
            default:
                break;
        }
            
    }
        else if(indexPath.section ==2)
    {
        if (indexPath.row ==0) {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[sb instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
            serve.orderDoc = orderDoc;
            [self.navigationController pushViewController:serve animated:YES];
        }
    }
    
}

-(void)deleteServicePerson:(UIButton *)sender
{
    appointmentDoc.Appointment_servicePersonal = @"";
    appointmentDoc.Appointment_servicePersonalID = 0;
    NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
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
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}


//Http request
-(void)requestDetail
{
    NSDictionary * para = @{
                           @"LongID":@(self.LongID),
                           };
    
    _requestAppointmentDetail = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleDetail" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            appointmentDoc = [[AppointmentDoc alloc] init];
            [appointmentDoc setAppointment_customerID:[[data objectForKey:@"TaskOwnerID"]integerValue ]];
            [appointmentDoc setAppointment_customer:[data objectForKey:@"TaskOwnerName"]];
            [appointmentDoc setAppointment_remark:[data objectForKey:@"Remark"]];
            [appointmentDoc setAppointment_status:[[data objectForKey:@"TaskStatus"] intValue]];
            [appointmentDoc setAppointment_date:[data objectForKey:@"TaskScdlStartTime"]];
            [appointmentDoc setAppointment_servicename:[data objectForKey:@"ProductName"]];
            [appointmentDoc setAppointment_servicePersonal:[data objectForKey:@"AccountName"]];
            [appointmentDoc setAppointment_servicePersonalID:[[data objectForKey:@"AccountID"] integerValue]];
            
            [appointmentDoc setAppointment_longID:[[data objectForKey:@"TaskID"] longLongValue]];
            
            [appointmentDoc setAppointment_branchName:[data objectForKey:@"BranchName"]];
            [appointmentDoc setAppointment_branchID:[[data objectForKey:@"BranchID"]integerValue]];
             
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
            orderDoc = [[OrderDoc alloc] init];
            [orderDoc setOrder_ID:self.orderID];
            [orderDoc setOrder_ObjectID:self.orderObjectID];
            [orderDoc setOrder_Type:0];
            [self.orderArray addObject:orderDoc];
            
            [self initButton];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [myTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

-(void)cancelAppointmentHttp
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSDictionary * para = @{
                           @"LongID":@((long long)self.LongID),
                         };
    
    _requestAppointmentCancel  = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/CancelSchedule" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            

           }failure:^(NSInteger code, NSString *error) {
                 [SVProgressHUD showErrorWithStatus2:error];
           }];
           [SVProgressHUD dismiss];
           [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
       
       
    }];
    
}

-(void)editAppointmentHttp
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * para = @{
                            @"ID":@((long long)appointmentDoc.Appointment_longID),
                            @"TaskScdlStartTime":appointmentDoc.Appointment_date,
                            @"Remark":appointmentDoc.Appointment_remark ,
                            @"ExecutorID":@((long)appointmentDoc.Appointment_servicePersonalID)
                            };
    
    _requestAppointmentCancel  = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/EditTask" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD showErrorWithStatus2:message];
            
            editAppointment = 0;
            
            [self initButton];
            [myTableView reloadData];
            
        }failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error];
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
        
    }];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    //[self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
    myTableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - 90 - 45);
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
        //获取高亮部分[
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
        if (toBeString.length >= 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
    appointmentDoc.Appointment_remark = textView.text;
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
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
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
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
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
        
        NSArray *array = [NSArray arrayWithObjects:cancelBtn, flexibleSpaceLeft, doneBtn, nil];
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
        
        [myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
