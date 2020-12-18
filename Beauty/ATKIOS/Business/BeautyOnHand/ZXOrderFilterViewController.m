//
//  ZXOrderFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/12/30.
//  Copyright © 2015年 ace-009. All rights reserved.
//

#import "ZXOrderFilterViewController.h"
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
@interface ZXOrderFilterViewController () <UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (nonatomic) NavigationView *navigationView;
@property (nonatomic,strong) UITableView *orderFilterTableView;
@property (nonatomic,strong) NSMutableArray *orderFilterData;

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

@implementation ZXOrderFilterViewController
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

    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,kORIGIN_Y + 5.0f) title:@"订单筛选"];
    [self.view addSubview:_navigationView];
    
    if (kMenu_Type == 1) {
        _orderFilterData  = [NSMutableArray arrayWithObjects:@"订单来源",@"订单分类",@"订单状态",@"支付状态",@"美丽顾问",@"顾客",@"日期", nil];
    }else{
        _orderFilterData  = [NSMutableArray arrayWithObjects:@"订单来源",@"订单分类",@"订单状态",@"支付状态",@"美丽顾问",@"日期", nil];
    }

    // ---TableView
    _orderFilterTableView = [[UITableView  alloc]initWithFrame:CGRectMake(0,0, kSCREN_BOUNDS.size.width, _orderFilterData.count * 44) style:UITableViewStyleGrouped];
    _orderFilterTableView.delegate = self;
    _orderFilterTableView.dataSource = self;
    _orderFilterTableView.showsHorizontalScrollIndicator = NO;
    _orderFilterTableView.showsVerticalScrollIndicator = NO;
    _orderFilterTableView.allowsSelection = NO;
    _orderFilterTableView.autoresizingMask = UIViewAutoresizingNone;
    _orderFilterTableView.backgroundColor = [UIColor clearColor];
    _orderFilterTableView.backgroundView = nil;
    if(IOS7 || IOS8) _orderFilterTableView.separatorInset = UIEdgeInsetsZero;
    
    
    if (kSCREN_568)
        _orderFilterTableView.frame = CGRectMake( 5.0f, HEIGHT_NAVIGATION_VIEW + 5.f, kSCREN_BOUNDS.size.width, _orderFilterData.count * 44);
    else
        _orderFilterTableView.frame = CGRectMake( -5.0f + (IOS6 ? 0 : 10), HEIGHT_NAVIGATION_VIEW + 5.f, kSCREN_BOUNDS.size.width + (IOS6 ? 20 : 0), _orderFilterData.count * 44);
    _initialTVHeight = _orderFilterTableView.frame.size.height;
    [self.view addSubview:_orderFilterTableView];
    
    //---footView
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _orderFilterTableView.frame.origin.y + _orderFilterTableView.frame.size.height + 10, 320.0f, 44.0f)];
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
#pragma mark - 按钮事件
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
    if (_orderFilterDoc.startTime || _orderFilterDoc.endTime) {
        NSDate *start = [NSDate stringToDate:_orderFilterDoc.startTime dateFormat:@"yyyy年MM月dd日"];
        NSDate *end = [NSDate stringToDate:_orderFilterDoc.endTime dateFormat:@"yyyy年MM月dd日"];
        if (!start || !end || [start compare:end] == NSOrderedDescending) {
            [SVProgressHUD showErrorWithStatus2:@"日期有误，请重选！" touchEventHandle:^{}];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithDoc:)])
    {
        [self.delegate dismissViewControllerWithDoc:_orderFilterDoc];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)resetAction
{
    _orderFilterDoc = [[OrderFilterDoc alloc] init];
    if (kMenu_Type == 0) {
        UserDoc *user = [[UserDoc alloc] init];
        user.user_Name = ACC_ACCOUNTName;
        user.user_Id = ACC_ACCOUNTID;
        [_orderFilterDoc.accountArray addObject:user];
    }
    [_endTime setText:_orderFilterDoc.endTime ? _orderFilterDoc.endTime : @""];
    [_startTime setText:_orderFilterDoc.startTime ? _orderFilterDoc.startTime : @""];
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
       if(row == _orderFilterData.count -1) return kTableView_HeightOfRow * 2;
    
    return kTableView_HeightOfRow;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orderFilterData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;
    NSInteger row = indexPath.row;
    
    if(row == _orderFilterData.count - 1){ //  日期
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
        [cell addSubview:value1];
        
        if (IOS6)  value1.frame = CGRectMake(150, 13, 150, 18);
        if (IOS7 || IOS8)  value1.tintColor = [UIColor clearColor];
        
        if (_orderFilterDoc.startTime)
            value1.text = [NSString stringWithFormat:@"%@ ",_orderFilterDoc.startTime];
        _startTime = value1;
        
        UITextField *value2 =[[noCopyTextField alloc] initWithText:nil
                                                             frame:CGRectMake(150, 44, 145, 28)
                                                               tag:2003
                                                         textColor:kColor_Editable
                                                       placeHolder:@"选择结束日期"
                                                     textAlignment:NSTextAlignmentRight
                                                          delegate:self];
        [cell addSubview:value2];
        if (IOS6)  value2.frame = CGRectMake(150, 46, 150, 18);
        if (IOS7 || IOS8) value2.tintColor = [UIColor clearColor];
        
        if(_orderFilterDoc.endTime)
            value2.text = [NSString stringWithFormat:@"%@ ",_orderFilterDoc.endTime ];
        _endTime = value2;
    }else{
        UILabel *title = [UILabel initNormalLabelWithFrame:CGRectMake(10, 9, 100, 20)
                                                     title:nil
                                                      font:kFont_Light_16
                                                 textColor:kColor_DarkBlue ];
        [cell addSubview:title];
        title.font = kFont_Light_16;
        title.textColor = kColor_DarkBlue;
        title.text = _orderFilterData[indexPath.row];
    }
    return cell;

}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 2002){
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
    CGRect tvFrame = _orderFilterTableView.frame;
    
    NSInteger offset = (kMenu_Type ? 38 : 0);
    offset += (kSCREN_568 ? 84 :0);
    
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 102.0f + offset ;
    _orderFilterTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardDidHide:(NSNotification*)notification
{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationDuration:0.1f];
    CGRect tvFrame = _orderFilterTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _orderFilterTableView.frame = tvFrame;
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
