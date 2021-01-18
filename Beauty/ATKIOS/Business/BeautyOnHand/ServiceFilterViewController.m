//
//  ServiceFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ServiceFilterViewController.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIButton+InitButton.h"
#import "NSString+Additional.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "NSDate+Convert.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "UserDoc.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "OrderFilterDoc.h"
#import "UILabel+InitLabel.h"
#import "SVProgressHUD.h"
#import "OrderFilterDoc.h"
#import "noCopyTextField.h"
#import "UIAlertView+AddBlockCallBacks.h"

#define UPLATE_CUSTOMER_LIST_DATE  @"UPLATE_CUSTOMER_LIST_DATE"


@interface ServiceFilterViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,SelectCustomersViewControllerDelegate>

@property (nonatomic) NavigationView *navigationView;
@property (nonatomic,strong) UITableView *serviceFilterTableView;
@property (nonatomic,strong) NSMutableArray *serviceFilterDatas;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;

@property (strong, nonatomic) UITextField *textField_Selected;

@property (assign, nonatomic) CGFloat initialTVHeight;

@property (strong, nonatomic) UITextField *statusTextField;               //保留一个引用
@property (strong, nonatomic) UITextField *productTypeTextField;               //保留一个引用
@property (strong, nonatomic) UITextField *userTextField;               //保留一个引用
@property (strong, nonatomic) UITextField *accountTextField;               //保留一个引用
@property (strong, nonatomic) UITextField *startTime;                   //保留一个引用
@property (strong, nonatomic) UITextField *endTime;                     //保留一个引用



@end

@implementation ServiceFilterViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)name:UIKeyboardWillHideNotification object:nil];
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}
- (void)initView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,kORIGIN_Y + 5.0f) title:@"服务筛选"];
    [self.view addSubview:_navigationView];
    
    // ---TableView
    _serviceFilterTableView = [[UITableView  alloc]initWithFrame:CGRectMake(0,_navigationView.frame.origin.y + _navigationView.frame.size.height, kSCREN_BOUNDS.size.width, _serviceFilterDatas.count * 44 + 65) style:UITableViewStyleGrouped];
    _serviceFilterTableView.delegate = self;
    _serviceFilterTableView.dataSource = self;
    _serviceFilterTableView.showsHorizontalScrollIndicator = NO;
    _serviceFilterTableView.showsVerticalScrollIndicator = NO;
    _serviceFilterTableView.allowsSelection = NO;
    _serviceFilterTableView.autoresizingMask = UIViewAutoresizingNone;
    _serviceFilterTableView.backgroundColor = [UIColor clearColor];
    _serviceFilterTableView.backgroundView = nil;
    if(IOS7 || IOS8) _serviceFilterTableView.separatorInset = UIEdgeInsetsZero;
    
    _initialTVHeight = _serviceFilterTableView.frame.size.height;
    [self.view addSubview:_serviceFilterTableView];
    
    //---footView
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _serviceFilterTableView.frame.origin.y + _serviceFilterTableView.frame.size.height - 20, 320.0f, 44.0f)];
    [footView setBackgroundColor:[UIColor clearColor]];
    UIButton *resetButton = [UIButton buttonWithTitle:@""
                                               target:self
                                             selector:@selector(resetAction)
                                                frame:CGRectMake(5.0f, 0.0f, 150.0f , 36.0f)
                                        backgroundImg:[UIImage imageNamed:@"reset"]
                                     highlightedImage:nil];
    [footView addSubview:resetButton];
    
    UIButton *submitButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(confirmAction)
                                                 frame:CGRectMake(165.0f, 0.0f, 150.0f , 36.0f)
                                         backgroundImg:[UIImage imageNamed:@"orderFilter"]
                                      highlightedImage:nil];
    [footView addSubview:submitButton];
    [self.view addSubview:footView];
}
- (void)initData
{
    _serviceFilterDatas = [NSMutableArray arrayWithObjects:@"业务类型",@"业务状态",@"选择顾问",@"选择顾客",@"日期",nil];
}
#pragma mark - 按钮事件
- (void)goBack
{
    self.goBackBlock();
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmAction
{
    if (_servicePara.StartTime.length > 0 || _servicePara.EndTime.length > 0) {
        NSDate *start = [NSDate stringToDate:_servicePara.StartTime dateFormat:@"yyyy-MM-dd"];
        NSDate *end = [NSDate stringToDate:_servicePara.EndTime dateFormat:@"yyyy-MM-dd"];
        if (!start || !end || [start compare:end] == NSOrderedDescending) {
            [SVProgressHUD showErrorWithStatus2:@"日期有误，请重选！" touchEventHandle:^{}];
            return;
        }
    }
    if (_servicePara.StartTime.length > 0 && _servicePara.EndTime.length > 0) {
        _servicePara.FilterByTimeFlag = 1;
    }else{
        _servicePara.FilterByTimeFlag = 0;
    }
    self.filterBlock(_servicePara);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)resetAction
{
    if (_servicePara) {
        _servicePara = nil;
        _servicePara = [[ServicePara alloc]init];
        _servicePara.StartTime = @"";
        _servicePara.EndTime = @"";
        _servicePara.CustomerID = 0;
        _servicePara.CustomerName = @"全部";
    }
    [_serviceFilterTableView reloadData];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(row == _serviceFilterDatas.count -1) return kTableView_HeightOfRow * 2;
    
    return kTableView_HeightOfRow;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _serviceFilterDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;
    NSInteger row = indexPath.row;
    
    if(row == _serviceFilterDatas.count - 1){ //  日期
        UILabel *title1 = [UILabel initNormalLabelWithFrame:CGRectMake(10, 9, 100, 20)
                                                      title:@"开始日期"
                                                       font:kFont_Light_16
                                                  textColor:kColor_DarkBlue ];
        [cell addSubview:title1];
        
        UILabel *title2 = [UILabel initNormalLabelWithFrame:CGRectMake(10, 47, 100, 20)
                                                      title:@"结束日期"
                                                       font:kFont_Light_16
                                                  textColor:kColor_DarkBlue ];
        [cell addSubview:title2];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(70, 37.5, 270, .5)];
        line.backgroundColor = [UIColor colorWithRed:202.0f/255.0f green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
        [cell addSubview:line];
        
        UITextField *value1 =[[noCopyTextField alloc] initWithText:nil
                                                             frame:CGRectMake(150, 7, 145, 28)
                                                               tag:2002
                                                         textColor:kColor_Editable
                                                       placeHolder:@"选择开始日期"
                                                     textAlignment:NSTextAlignmentRight
                                                          delegate:self];
        if (IOS14) {
            [cell.contentView addSubview:value1];
        } else {
            [cell addSubview:value1];
        }
        
        if (IOS6)  value1.frame = CGRectMake(150, 13, 150, 18);
        if (IOS7 || IOS8)  value1.tintColor = [UIColor clearColor];
        
        if (_servicePara.StartTime) {
            value1.text =_servicePara.StartTime;
            _startTime = value1;
        }
        
        UITextField *value2 =[[noCopyTextField alloc] initWithText:nil
                                                             frame:CGRectMake(150, 44, 145, 28)
                                                               tag:2003
                                                         textColor:kColor_Editable
                                                       placeHolder:@"选择结束日期"
                                                     textAlignment:NSTextAlignmentRight
                                                          delegate:self];
        if (IOS14) {
            [cell.contentView addSubview:value2];
        } else {
            [cell addSubview:value2];
        }
        if (IOS6)  value2.frame = CGRectMake(150, 46, 150, 18);
        if (IOS7 || IOS8) value2.tintColor = [UIColor clearColor];
        if (_servicePara.EndTime) {
            value2.text =_servicePara.EndTime;
            _endTime = value2;
        }
    }else{
        UILabel *title = [UILabel initNormalLabelWithFrame:CGRectMake(10, 9, 100, 20)
                                                     title:nil
                                                      font:kFont_Light_16
                                                 textColor:kColor_DarkBlue ];
        [cell addSubview:title];
        title.font = kFont_Light_16;
        title.textColor = kColor_DarkBlue;
        title.text = _serviceFilterDatas[indexPath.row];
        UITextField *value = [[noCopyTextField alloc] initWithText:@"全部"
                                                             frame:CGRectMake(150, 5, 145, 30)
                                                               tag:1000 + row
                                                         textColor:kColor_Editable
                                                       placeHolder:nil
                                                     textAlignment:NSTextAlignmentRight
                                                          delegate:self];
        value.backgroundColor = [UIColor clearColor];
        if (IOS14) {
            [cell.contentView addSubview:value];
        } else {
            [cell addSubview:value];
        }
        
        title.text = _serviceFilterDatas[indexPath.row];
        if ([title.text isEqualToString:@"业务类型"]) {
            value.text = [self getStringWithCategory:0 andIndex:_servicePara.ProductType];
            _productTypeTextField = value;
        }else if ([title.text isEqualToString:@"业务状态"]) {
            value.text = [self getStringWithCategory:1 andIndex:_servicePara.Status];
            _statusTextField = value;
        }else if ([title.text isEqualToString:@"选择顾问"]) {
            value.text = _servicePara.ServicePICName;
            _accountTextField = value;
        }else if ([title.text isEqualToString:@"选择顾客"]) {
            value.text = _servicePara.CustomerName;
            _userTextField = value;
        }
    }
    return cell;
    
}
#pragma mark - UITextFieldDelegate
-(NSString *)getStringWithCategory:(NSInteger)category andIndex:(NSInteger)index
{
    if(category == 0){ //业务类型
        switch (index) {
            case -1: return @"全部";
            case 0: return @"服务";
            case 1: return @"商品";
        }
    }else if (category == 1) //业务状态
    {
        switch (index) {
            case -1: return @"全部";
            case 1: return @"未完成";
            case 5: return @"待确认";
            case 2: return @"已完成";
        }
    }
    return nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1000){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"业务类型" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部",@"服务", @"商品",nil];
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 1: //全部
                    _servicePara.ProductType = -1;
                    break;
                case 2: //服务
                    _servicePara.ProductType = 0;
                    break;
                case 3: //商品
                    _servicePara.ProductType = 1;
                    break;
                default:
                    break;
                }
          _productTypeTextField.text =  [self getStringWithCategory:0 andIndex:_servicePara.ProductType];
        }];
       
        return NO;

    }else if (textField.tag == 1001){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"业务类型" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部",@"未完成", @"待确认",@"已完成",nil];
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 1: //全部
                    _servicePara.Status = -1;
                    break;
                case 2: //未完成
                    _servicePara.Status = 1;
                    break;
                case 3: //待完成
                    _servicePara.Status = 5;
                    break;
                case 4: //已完成
                    _servicePara.Status = 2;
                    break;
                default:
                    break;
            }
           _statusTextField.text =  [self getStringWithCategory:1 andIndex: _servicePara.Status];
        }];

        
        return NO;

    }else if(textField.tag == 1002){
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        SelectCustomersViewController *selectCustomer = [board instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        selectCustomer.accRange = ACCBRANCH;
      #pragma mark 权限 [[PermissionDoc sharePermission] rule_BranchOrder_Read] || kMenu_Type == 1
        if ([[PermissionDoc sharePermission] rule_BranchOrder_Read] || kMenu_Type == 1)
            selectCustomer.accRange = ACCBRANCH;
        else
            selectCustomer.accRange = ACCACCOUNT;

        //默认选择的顾问
        if (_servicePara.accountArray.count == 0) {
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = _servicePara.ServicePICName;
            user.user_Id = _servicePara.ServicePIC;
            [_servicePara.accountArray addObject:user];
        }
        
        [selectCustomer setSelectModel:0
                              userType:2
                         customerRange:(kMenu_Type == 1 ? CUSTOMEROFMINE: ([[PermissionDoc sharePermission] rule_BranchOrder_Read] ? CUSTOMEROFMINE: CUSTOMERINBRANCH))
                  defaultSelectedUsers:_servicePara.accountArray];
        selectCustomer.navigationTitle = @"选择美丽顾问";
        selectCustomer.personType = CustomePersonGroup;
        selectCustomer.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigationController animated:YES completion:^{}];

        return NO;
    }else if (textField.tag == 1003){
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        SelectCustomersViewController *selectCustomer = [board instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        selectCustomer.navigationTitle = @"选择顾客";
        CUSTOMERRANGE customerRange = CUSTOMEROFMINE;
        //if (![[PermissionDoc sharePermission] rule_AllCustomer_Read]) //默认读取全部顾客，如果没有该权限则获取我的顾客
        //    customerRange = CUSTOMEROFMINE;
        
        UserDoc *userDoc = [UserDoc new];
        userDoc.user_Type = 0;
        userDoc.user_Available = 1;
        if(_servicePara.CustomerID != 0){
            userDoc.user_Id = _servicePara.CustomerID;
//            userDoc.user_Name = orderFilterDoc.user_Name;
        }
        
        [selectCustomer setSelectModel:0
                              userType:4
                         customerRange:customerRange
                  defaultSelectedUsers:userDoc.user_Id != 0 ? @[userDoc] : nil];
        selectCustomer.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigationController animated:YES completion:^{}];
        return NO;
    }else if (textField.tag == 2002){
        [self initialKeyboard];
        self.textField_Selected = textField;
        textField.inputAccessoryView = _inputAccessoryView;
        textField.inputView = _datePicker;
        NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy年MM月dd日"];
        if (theDate != nil && ![theDate  isEqual: @""]) {
            [_datePicker setDate:theDate];
        }
    }else if (textField.tag == 2003){
        [self initialKeyboard];
        self.textField_Selected  = textField;
        textField.inputAccessoryView = _inputAccessoryView;
        textField.inputView = _datePicker;
        NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy年MM月dd日"];
        if (theDate != nil && ![theDate  isEqual: @""]) {
            [_datePicker setDate:theDate];
        }
    }
    return YES;
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationDuration:0.45f];
    CGRect tvFrame = _serviceFilterTableView.frame;
    
    NSInteger offset = (kMenu_Type ? 38 : 0);
    offset += (kSCREN_568 ? 84 :0);
    
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 102.0f + offset ;
    _serviceFilterTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardDidHide:(NSNotification*)notification
{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationDuration:0.1f];
    CGRect tvFrame = _serviceFilterTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _serviceFilterTableView.frame = tvFrame;
    [UIView commitAnimations];
}

#pragma mark - Initial Keyboard & Choose Date

- (void)initialKeyboard
{
    if(!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [_datePicker setDate:[NSDate date]];
        [_datePicker setDatePickerMode:UIDatePickerModeDate];
        [_datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        CGRect frame = self.inputView.frame;
        frame.size = [self.datePicker sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!_inputAccessoryView) {
        _inputAccessoryView = [[UIToolbar alloc] init];
        _inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        _inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_inputAccessoryView sizeToFit];
        CGRect frame1 = _inputAccessoryView.frame;
        frame1.size.height = 44.0f;
        _inputAccessoryView.frame = frame1;
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [_inputAccessoryView setItems:array];
    }
}

- (void)dateChanged:(id)sender
{
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([_datePicker.date timeIntervalSinceReferenceDate])];
    NSString * dateStr = [NSDate dateToString:newDate dateFormat:@"yyyy-MM-dd"];
    
    if(self.textField_Selected.tag == 2002 ){
        self.servicePara.StartTime = [NSString stringWithFormat:@"%@", dateStr];
        [_startTime setText:[NSString stringWithFormat:@"%@ ",self.servicePara.StartTime]];
    }
    else if (self.textField_Selected.tag == 2003){
        self.servicePara.EndTime = [NSString stringWithFormat:@"%@", dateStr];
        [_endTime setText:[NSString stringWithFormat:@"%@ ",self.servicePara.EndTime]];
    }
}

- (void)done:(id)sender
{
    [self dateChanged:nil];
    [self.startTime resignFirstResponder];
    [self.endTime resignFirstResponder];
    [self dismissKeyBoard];
}

#pragma mark - dismissViewControllerDelegate
-(void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    [_servicePara.accountArray removeAllObjects];
    if (kMenu_Type == 0) {
        if (userArray.count > 0) {
            [_servicePara.accountArray removeAllObjects];
            _servicePara.ServicePIC = [[userArray firstObject] user_Id];
            _servicePara.ServicePICName = [[userArray firstObject] user_Name];
            //添加最新选择的顾问
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = _servicePara.ServicePICName;
            user.user_Id = _servicePara.ServicePIC;
            [_servicePara.accountArray addObject:user];
        }else{
            _servicePara.ServicePIC = ACC_ACCOUNTID;
            _servicePara.ServicePICName = ACC_ACCOUNTName;
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = _servicePara.ServicePICName;
            user.user_Id = _servicePara.ServicePIC;
            [_servicePara.accountArray addObject:user];
        }

    }
    [_accountTextField setText:_servicePara.ServicePICName];
}
-(void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    _servicePara.CustomerID = [[userArray firstObject] user_Id];
    _servicePara.CustomerName = [[userArray firstObject] user_Name];
    if (_servicePara.CustomerID == 0){
        _servicePara.CustomerName = nil;
        [_userTextField setText:@"全部"];
        return;
    }
    [_userTextField setText:_servicePara.CustomerName];
}

@end
