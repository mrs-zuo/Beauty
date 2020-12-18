//
//  AppointmentFilter_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentFilter_ViewController.h"
#import "GPBHTTPClient.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NSDate+Convert.h"
#import "SelectCustomersViewController.h"
#import "AppointmentFilterDoc.h"
#import "UIButton+InitButton.h"

@interface AppointmentFilter_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (strong,nonatomic) UITableView * myTableView;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (strong, nonatomic) UITextField * textField_selected;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

@implementation AppointmentFilter_ViewController
@synthesize myTableView;
@synthesize filterDoc;
@synthesize textField_Selected;
@synthesize datePicker,inputAccessoryView;

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

- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (filterDoc.ResponsiblePersonsArr.count) {
        for (UserDoc *user in filterDoc.ResponsiblePersonsArr) {
            [nameArray addObject:user.user_Name];
        }
    }
    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
    return [nameArray componentsJoinedByString:@"、"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"预约筛选"];
    [self.view addSubview:navigationView];
    //默认
    if (filterDoc.taskTypeArrs) {
        [filterDoc.taskTypeArrs removeAllObjects];
        [filterDoc.taskTypeArrs addObject:@(1)]; // 右边预约
    }
    [self initTableView];
}

-(void)initTableView
{
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )];
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
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
    }
    _initialTVHeight = myTableView.frame.size.height;
    
    FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"筛    选" submitAction:@selector(appointmentConfirm) deleteTitle:@"重    置" deleteAction:@selector(appointmentCancel)];
    [footerView showInTableView:myTableView];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)appointmentCancel
{
    [self initData];
}

-(void)appointmentConfirm
{
    if (filterDoc.startTime.length >0 || filterDoc.endTime.length >0) {
        NSDate *start = [NSDate stringToDate:filterDoc.startTime dateFormat:@"yyyy-MM-dd"];
        NSDate *end = [NSDate stringToDate:filterDoc.endTime dateFormat:@"yyyy-MM-dd"];
        
        if (!start || !end || [start compare:end] == NSOrderedDescending) {
            [SVProgressHUD showErrorWithStatus2:@"日期有误，请重选！" touchEventHandle:^{}];
            return;
        }else
        {
            filterDoc.FilterByTimeFlag = 1;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithDoc:)])
    {
        [self.delegate dismissViewControllerWithDoc:filterDoc];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)initData
{
    filterDoc = [[AppointmentFilterDoc alloc] init];
    UserDoc *user  = [[UserDoc alloc] init];
    user.user_Id = ACC_ACCOUNTID;
    user.user_Name = ACC_ACCOUNTName;
    [filterDoc.ResponsiblePersonsArr addObject:user];
    [myTableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString * cellIdentify = [NSString stringWithFormat:@"cell %@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.enabled = NO;
    }
    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"选择顾客";
            cell.valueText.text = filterDoc.CustomerName;
            [cell setAccessoryText:@"    "];
            cell.valueText.placeholder = @"选择顾客";
            [cell.contentView addSubview:arrowsImage];
            break;
        case 1:
            [cell.contentView addSubview:arrowsImage];
            cell.titleLabel.text = @"指定顾问";
            cell.valueText.text = self.slaveNames.length > 0 ?self.slaveNames:@"全部";
            cell.valueText.placeholder = @"选择顾问";
            [cell setAccessoryText:@"    "];
            break;
        case 2:
            cell.titleLabel.text = @"预约状态";
            cell.valueText.text = filterDoc.statusStr;
            cell.valueText.tag = 1001;
            cell.valueText.placeholder = @"选择预约状态";
            cell.valueText.tintColor = [UIColor clearColor];
            break;
        case 3:
            cell.valueText.enabled = YES;
            cell.titleLabel.text = @"开始时间";
            cell.valueText.text = filterDoc.startTime;
            cell.valueText.tag = 1002;
            cell.valueText.placeholder = @"选择开始时间";
            cell.valueText.tintColor = [UIColor clearColor];
            cell.valueText.delegate = self;
            break;
        case 4:
            cell.valueText.enabled = YES;
            cell.titleLabel.text = @"结束时间";
            cell.valueText.text =filterDoc.endTime;
            cell.valueText.tag = 1003;
            cell.valueText.placeholder = @"选择结束时间";
            cell.valueText.tintColor = [UIColor clearColor];
            cell.valueText.delegate = self;
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            selectCustomer.navigationTitle = @"选择顾客";
            CUSTOMERRANGE customerRange = CUSTOMEROFMINE;
            UserDoc *userDoc = [UserDoc new];
            userDoc.user_Type = 0;
            userDoc.user_Available = 1;
            if(filterDoc.CustomerID!= 0){
                userDoc.user_Id = filterDoc.CustomerID;
                userDoc.user_Name = filterDoc.CustomerName;
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
            break;
        case 1:
        {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            selectCustomer.accRange = ACCBRANCH;
            if ([[PermissionDoc sharePermission] rule_BranchOrder_Read])
                selectCustomer.accRange = ACCBRANCH;
            else
                selectCustomer.accRange = ACCACCOUNT;
            
            [selectCustomer setSelectModel:1
                                  userType:2
                             customerRange:([[PermissionDoc sharePermission] rule_BranchOrder_Read] ? CUSTOMEROFMINE: CUSTOMERINBRANCH)
                      defaultSelectedUsers:filterDoc.ResponsiblePersonsArr];
            selectCustomer.navigationTitle = @"选择顾问";
            selectCustomer.personType = CustomePersonGroup;
            selectCustomer.delegate = self;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navigationController animated:YES completion:^{}];
        }
            break;
        case 2:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预约状态" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部", @"待确认", @"已确认",@"已开单", @"已取消", nil];
            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) return ;
                switch (buttonIndex) {
                    case 1: //全部
                        [filterDoc setStatus:0];
                        break;
                    case 2: //待确认
                        [filterDoc setStatus:1];
                        break;
                    case 3: //确认
                        [filterDoc setStatus:2];
                        break;
                    case 4: //
                        [filterDoc setStatus:3];
                        break;
                    case 5: //已取消
                        [filterDoc setStatus:4];
                        break;
                }
                [myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self initialKeyboard];
    self.textField_Selected  = textField;
    self.textField_Selected.inputAccessoryView = inputAccessoryView;
    self.textField_Selected.inputView = datePicker;
    NSDate *theDate = [NSDate stringToDate:self.textField_Selected.text dateFormat:@"yyyy-MM-dd"];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}


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


//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
}

#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
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
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        
        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        [cancelBtn setTintColor:kColor_White];
        
        UIBarButtonItem *fixidSpaces = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixidSpaces.width = 6.0f;
        
        UIBarButtonItem *flexibleSpaces = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [NSArray arrayWithObjects:fixidSpaces, cancelBtn, flexibleSpaces, doneBtn, fixidSpaces, nil];
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
    NSString *dataStr = [NSDate dateToString:datePicker.date dateFormat:@"yyyy-MM-dd"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)self.textField_Selected.superview.superview.superview;
    else
        cell = (UITableViewCell *)self.textField_Selected.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    newDate =  [NSDate stringToDate:dataStr dateFormat:@"yyyy-MM-dd"];
    currentDate = [NSDate stringToDate:[currentDate.description substringToIndex:16] dateFormat:@"yyyy-MM-dd"];
    
    inputAccessoryView = nil;
    datePicker = nil;
    
    [self.textField_Selected setText:[NSString stringWithFormat:@"%@", dataStr]];
    
    if (self.textField_Selected.tag == 1002) {
        filterDoc.startTime = [NSString stringWithFormat:@"%@", dataStr];
    }else if(self.textField_Selected.tag == 1003)
    {
        filterDoc.endTime = [NSString stringWithFormat:@"%@", dataStr];
    }
  
    [myTableView reloadData];
}

-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)self.textField_Selected.superview.superview.superview;
    else
        cell = (UITableViewCell *)self.textField_Selected.superview.superview;
    
    inputAccessoryView = nil;
    datePicker = nil;
    
    [textField_Selected resignFirstResponder];
}

#pragma mark - dismissViewControllerDelegate
-(void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    [filterDoc.ResponsiblePersonsArr removeAllObjects];
    for (UserDoc * doc in userArray) {
        if (doc) {
             filterDoc.ResponsiblePersonsArr = [NSMutableArray arrayWithArray:userArray];
        }
       
        break;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    if (userArray.count == 0) {
        filterDoc.CustomerName = @"全部";
        filterDoc.CustomerID = 0;
    }else{
        for ( UserDoc * userDoc in userArray) {
            filterDoc.CustomerName = userDoc.user_Name;
            filterDoc.CustomerID = userDoc.user_Id;
        }
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
