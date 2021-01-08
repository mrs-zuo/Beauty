//
//  OrderFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-23.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderFilterViewController.h"
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

@interface OrderFilterViewController ()

@property (nonatomic) NavigationView *navigationView;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextField *startTime;                   //保留一个引用
@property (strong, nonatomic) UITextField *endTime;                     //保留一个引用
@property (strong, nonatomic) UITextField *responsePerson;              //保留一个引用
@property (strong, nonatomic) UITextField *user;                        //保留一个引用
@property (strong, nonatomic) UITextField *requestStatus;               //保留一个引用
@property (strong, nonatomic) UITextField *requestOrderSoure;                 //保留一个引用
@property (strong, nonatomic) UITextField *requestType;                 //保留一个引用
@property (strong, nonatomic) UITextField *requestIsPaid;               //保留一个引用
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (assign, nonatomic) CGFloat initialTVHeight;

@end

@implementation OrderFilterViewController
@synthesize navigationView;
@synthesize orderFilterDoc;

#pragma  mark -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.orderFilterDoc = [[OrderFilterDoc alloc] init];
    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,kORIGIN_Y + 5.0f) title:@"订单筛选"];
    [self.view addSubview:navigationView];
    
    // ---TableView
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.allowsSelection = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    if(IOS7 || IOS8) _tableView.separatorInset = UIEdgeInsetsZero;
    
    NSInteger heightOffset = kMenu_Type == 1 ? kTableView_HeightOfRow : 0;
    
    if (kSCREN_568)
        _tableView.frame = CGRectMake( 5.0f, HEIGHT_NAVIGATION_VIEW + 5.f, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 256.f - heightOffset + 44.0f); //加了一个订单来源高
    else
        _tableView.frame = CGRectMake( -5.0f + (IOS6 ? 0 : 10), HEIGHT_NAVIGATION_VIEW + 5.f, 310.0f + (IOS6 ? 20 : 0), kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 168.f - heightOffset + 44.0f);//加了一个订单来源高
    _initialTVHeight = _tableView.frame.size.height;
    
    //---footView
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _tableView.frame.origin.y + _tableView.frame.size.height + 10, 320.0f, 44.0f)];
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

- (void)goBack
{
    if ([self.delegate respondsToSelector:@selector(donotRefresh)])
    {
        [self.delegate donotRefresh];
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)confirmAction
{
    if (orderFilterDoc.startTime || orderFilterDoc.endTime) {
        NSDate *start = [NSDate stringToDate:orderFilterDoc.startTime dateFormat:@"yyyy年MM月dd日"];
        NSDate *end = [NSDate stringToDate:orderFilterDoc.endTime dateFormat:@"yyyy年MM月dd日"];
        if (!start || !end || [start compare:end] == NSOrderedDescending) {
            [SVProgressHUD showErrorWithStatus2:@"日期有误，请重选！" touchEventHandle:^{}];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithDoc:)])
    {
        [self.delegate dismissViewControllerWithDoc:orderFilterDoc];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)resetAction
{
    orderFilterDoc = [[OrderFilterDoc alloc] init];
    if (kMenu_Type == 0) {
        UserDoc *user = [[UserDoc alloc] init];
        user.user_Name = ACC_ACCOUNTName;
        user.user_Id = ACC_ACCOUNTID;
        [orderFilterDoc.accountArray addObject:user];
    }
    [self reloadData];
}

- (void)reloadData
{
    [_requestIsPaid setText:[self getStringWithCategory:2 andIndex:orderFilterDoc.orderIsPaid]];
    [_requestStatus setText:[self getStringWithCategory:1 andIndex:orderFilterDoc.orderStatus]];
    [_requestType setText:[self getStringWithCategory:0 andIndex:orderFilterDoc.orderType]];
    [_requestOrderSoure setText:[self getStringWithCategory:3 andIndex:orderFilterDoc.OrderSource]];

    [_responsePerson setText:orderFilterDoc.accountArray.count != 0 ? orderFilterDoc.account_Name: @"全部"];
    [_user setText:orderFilterDoc.user_Id ? orderFilterDoc.user_Name: @"全部"];
    [_endTime setText:orderFilterDoc.endTime ? orderFilterDoc.endTime : @""];
    [_startTime setText:orderFilterDoc.startTime ? orderFilterDoc.startTime : @""];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (kMenu_Type == 1) return 6;
    return  7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;

    NSInteger row = indexPath.row;
    if(kMenu_Type == 1 && row == 4 + 1)
        ++ row;
    
    if(row == 5 + 1){
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
        
        if (orderFilterDoc.startTime)
            value1.text = [NSString stringWithFormat:@"%@ ",orderFilterDoc.startTime];
        _startTime = value1;
        
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
        
        if(orderFilterDoc.endTime)
            value2.text = [NSString stringWithFormat:@"%@ ",orderFilterDoc.endTime ];
        _endTime = value2;
    }
    else{
        UILabel *title = [UILabel initNormalLabelWithFrame:CGRectMake(10, 9, 100, 20)
                                                     title:nil
                                                      font:kFont_Light_16
                                                 textColor:kColor_DarkBlue ];
        [cell addSubview:title];
        title.font = kFont_Light_16;
        title.textColor = kColor_DarkBlue;
        
        UITextField *value = [[noCopyTextField alloc] initWithText:@"全部"
                                                             frame:CGRectMake(150, 5, 145, 30)
                                                               tag:1000 + row
                                                         textColor:kColor_Editable
                                                       placeHolder:nil
                                                     textAlignment:NSTextAlignmentRight
                                                          delegate:self];
        if (IOS14) {
            [cell.contentView addSubview:value];
        } else {
            [cell addSubview:value];
        }
        
        if (IOS6)
            value.frame = CGRectMake(150, 9, 150, 30);
        value.backgroundColor = [UIColor clearColor];
        
        if (row == 0) {
            title.text = @"订单来源";
            value.text = [self getStringWithCategory:3 andIndex:orderFilterDoc.OrderSource];
            _requestOrderSoure = value;
        }else if (row == 0 + 1) {
            title.text = @"订单分类";
            value.text = [self getStringWithCategory:0 andIndex:orderFilterDoc.orderType];
            _requestType = value;
        } else if (row == 1 + 1) {
            title.text = @"订单状态";
            value.text = [self getStringWithCategory:1 andIndex:orderFilterDoc.orderStatus];;
            _requestStatus = value;
        } else if (row == 2 + 1) {
            title.text = @"支付状态";
            value.text = [self getStringWithCategory:2 andIndex:orderFilterDoc.orderIsPaid];;
            _requestIsPaid = value;
        }else if (row == 3 + 1) {
            title.text = @"美丽顾问";
            value.text = orderFilterDoc.accountArray.count != 0 ? orderFilterDoc.account_Name :@"全部";
            _responsePerson = value;
        }else if (row == 4 + 1) {
            title.text = @"顾客";
            value.text = orderFilterDoc.user_Id != 0 ? orderFilterDoc.user_Name :@"全部";
            _user = value;
        }
    }
    return cell;
}

-(NSString *)getStringWithCategory:(NSInteger)category andIndex:(NSInteger)index
{
    if(category == 0){ //订单类型
        switch (index) {
            case -1: return @"全部";
            case 0: return @"服务";
            case 1: return @"商品";
        }
    }else if (category == 1) //订单状态
    {
        switch (index) {
            case -1: return @"全部";
            case 1: return @"未完成";
            case 2: return @"已完成";
            case 3: return @"已取消";
            case 4: return @"已终止";
        }
    // 全部  未完成 已完成 已终止 已取消
    } else if (category == 2) //支付状态
{
        switch (index) {
            case -1: return @"全部";
            case 1: return @"未支付";
            case 2: return @"部分付";
            case 3: return @"已支付";
            case 4: return @"已退款";
            case 5: return @"免支付";
        }
    }
    else if (category == 3) //订单来源
    {
        switch (index) {
            case -1: return @"全部";
            case 0: return @"商家";
            case 2: return @"顾客";
            case 3: return @"预约";
            case 4: return @"导入";
            case 5: return @"抢购";
        }
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(kMenu_Type == 1 && row == 4 +1)
        ++ row;
    if(row == 5 +1) return kTableView_HeightOfRow * 2;
    
    return kTableView_HeightOfRow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1003 + 1){
        SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        selectCustomer.accRange = ACCBRANCH;
//        UserDoc *userDoc = [UserDoc new];
//        userDoc.user_Type = 1;
//        userDoc.user_Available = 1;
//        if(orderFilterDoc.account_Id != 0){
//            userDoc.user_Id = orderFilterDoc.account_Id;
//            userDoc.user_Name = orderFilterDoc.account_Name;
//        }
//        else {
//            userDoc.user_Id = ACC_ACCOUNTID;
//            userDoc.user_Name = ACC_ACCOUNTName;
//        }
#pragma mark 权限 [[PermissionDoc sharePermission] rule_BranchOrder_Read] || kMenu_Type == 1
        if ([[PermissionDoc sharePermission] rule_BranchOrder_Read] || kMenu_Type == 1)
            selectCustomer.accRange = ACCBRANCH;
        else
            selectCustomer.accRange = ACCACCOUNT;

        [selectCustomer setSelectModel:1
                              userType:2
                         customerRange:(kMenu_Type == 1 ? CUSTOMEROFMINE: ([[PermissionDoc sharePermission] rule_BranchOrder_Read] ? CUSTOMEROFMINE: CUSTOMERINBRANCH))
                  defaultSelectedUsers:orderFilterDoc.accountArray];
        selectCustomer.navigationTitle = @"选择美丽顾问";
        selectCustomer.personType = CustomePersonGroup;
        selectCustomer.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigationController animated:YES completion:^{}];
        return NO;
    }else if (textField.tag == 1004 + 1){
        SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        selectCustomer.navigationTitle = @"选择顾客";
        CUSTOMERRANGE customerRange = CUSTOMEROFMINE;
        //if (![[PermissionDoc sharePermission] rule_AllCustomer_Read]) //默认读取全部顾客，如果没有该权限则获取我的顾客
        //    customerRange = CUSTOMEROFMINE;

        UserDoc *userDoc = [UserDoc new];
        userDoc.user_Type = 0;
        userDoc.user_Available = 1;
        if(orderFilterDoc.user_Id != 0){
            userDoc.user_Id = orderFilterDoc.user_Id;
            userDoc.user_Name = orderFilterDoc.user_Name;
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
    }else if (textField.tag == 1000){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"订单来源" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部",@"商家", @"顾客",@"预约", @"抢购",@"导入",nil];
        
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 1: //全部
                    orderFilterDoc.OrderSource = -1;
                    break;
                case 2: //商家
                    orderFilterDoc.OrderSource = 0;
                    break;
                case 3: //顾客
                    orderFilterDoc.OrderSource = 2;
                    break;
                case 4: //预约
                    orderFilterDoc.OrderSource = 3;
                    break;
                case 5: //抢购
                    orderFilterDoc.OrderSource = 5;
                    break;
                case 6: //导入
                    orderFilterDoc.OrderSource = 4;
                    break;
                case 7: //取消
                    orderFilterDoc.OrderSource = -1;
                    break;
            }

//            if (buttonIndex == 0) return ;
//            orderFilterDoc.OrderSource = buttonIndex - 2;
            [_requestOrderSoure setText:[self getStringWithCategory:3 andIndex: orderFilterDoc.OrderSource]];
        }];
        return NO;
    } else if (textField.tag == 1000 + 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"订单类型" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部", @"服务", @"商品",nil];
        
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
            orderFilterDoc.orderType = buttonIndex - 2;
            [_requestType setText:[self getStringWithCategory:0 andIndex:buttonIndex - 2]];
        }];
        return NO;
    } else if (textField.tag == 1001 + 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"订单状态" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部", @"未完成", @"已完成", @"已终止",@"已取消", nil];
         // 全部-1  未完成1 已完成2 已终止4 已取消3
        //@"全部", @"未完成", @"待确认", @"已完成", @"已取消"
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
                    switch (buttonIndex) {
                        case 1: //全部
                            orderFilterDoc.orderStatus = -1;
                            break;
                        case 2: //未完成
                            orderFilterDoc.orderStatus = 1;
                            break;
                        case 3: //已完成
                            orderFilterDoc.orderStatus = 2;
                            break;
                        case 4: //已终止
                            orderFilterDoc.orderStatus = 4;
                            break;
                        case 5: //已取消
                            orderFilterDoc.orderStatus = 3;
                            break;
                    }
            [_requestStatus setText:[self getStringWithCategory:1 andIndex:orderFilterDoc.orderStatus]];
        }];
        return NO;
    } else if (textField.tag == 1002 + 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付状态" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部", @"未支付", @"部分付", @"已支付",@"已退款",@"免支付", nil];
        // -1 1 2 3
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
            switch (buttonIndex) {
                case 1:
                    orderFilterDoc.orderIsPaid = -1;
                    break;
                case 2:
                    orderFilterDoc.orderIsPaid = 1;
                    break;
                case 3:
                    orderFilterDoc.orderIsPaid = 2;
                    break;
                case 4:
                    orderFilterDoc.orderIsPaid = 3;
                     break;
                case 5:
                    orderFilterDoc.orderIsPaid = 4;
                    break;
                case 6:
                    orderFilterDoc.orderIsPaid = 5;
                    break;
            }
            [_requestIsPaid setText:[self getStringWithCategory:2 andIndex:orderFilterDoc.orderIsPaid]];
        }];
        return NO;
    }
    
    return YES;
}

-(void)keyboardDidShow:(NSNotification*)notification
{

    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationDuration:0.45f];
    CGRect tvFrame = _tableView.frame;
    
    NSInteger offset = (kMenu_Type ? 38 : 0);
    offset += (kSCREN_568 ? 84 :0);
    
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 102.0f + offset ;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardDidHide:(NSNotification*)notification
{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationDuration:0.1f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
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
    NSString * dateStr = [NSDate dateToString:newDate dateFormat:@"yyyy年MM月dd日"];

    if(self.textField_Selected.tag == 2002 ){
        self.orderFilterDoc.startTime = [NSString stringWithFormat:@"%@", dateStr];
        [_startTime setText:[NSString stringWithFormat:@"%@ ",self.orderFilterDoc.startTime]];
    }
    else if (self.textField_Selected.tag == 2003){
        self.orderFilterDoc.endTime = [NSString stringWithFormat:@"%@", dateStr];
        [_endTime setText:[NSString stringWithFormat:@"%@ ",self.orderFilterDoc.endTime]];
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

//    self.orderFilterDoc.account_Id = [[userArray firstObject] user_Id];
//    self.orderFilterDoc.account_Name = [[userArray firstObject] user_Name];

    self.orderFilterDoc.accountArray = [userArray mutableCopy];
    
    if (kMenu_Type == 0){
        if (self.orderFilterDoc.accountArray.count == 0) {
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = ACC_ACCOUNTName;
            user.user_Id = ACC_ACCOUNTID;
            [self.orderFilterDoc.accountArray addObject:user];
        }
    }
    [_responsePerson setText:self.orderFilterDoc.account_Name];
}

-(void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.orderFilterDoc.user_Id = [[userArray firstObject] user_Id];
    self.orderFilterDoc.user_Name = [[userArray firstObject] user_Name];
    if (self.orderFilterDoc.user_Id == 0){
        self.orderFilterDoc.user_Name = nil;
        [_user setText:@"全部"];
        return;
    }
    [_user setText:self.orderFilterDoc.user_Name];
}

@end
