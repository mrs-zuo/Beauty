//
//  CustomerBasicViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "CustomerListViewController.h"
#import "SourceType.h"
#import "UILabel+InitLabel.h"
#import "CusEditHeadImgView.h"
#import "CusEditComplexCell.h"
#import "CusEditNormalCell.h"
#import "CusEditAddressCell.h"
#import "OrderAddCell.h"
#import "UIPlaceHolderTextView.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CustomerDoc.h"
#import "PhoneDoc.h"
#import "EmailDoc.h"
#import "AddressDoc.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "FooterView.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AppDelegate.h"
#import "noCopyTextField.h"
#import "GPBHTTPClient.h"
#import "NSData+Base64.h"
#import "DFTableCell.h"
#import "DFTableAlertView.h"


@interface CustomerEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *addCustomerOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *updateCustomerOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *deleteCustomerOpreation;
@property (nonatomic, weak)   AFHTTPRequestOperation *requestSourceType;

@property (assign, nonatomic) CGFloat table_Height;
@property (strong, nonatomic) CusEditHeadImgView *cusEditHeadImgView;

// 该三个数组 只是负责显示
@property (strong, nonatomic) NSMutableArray *phoneArray;
@property (strong, nonatomic) NSMutableArray *emailArray;
@property (strong, nonatomic) NSMutableArray *addressArray;

//--view
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (strong, nonatomic) NSArray *pickerData;

//--
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (assign, nonatomic) CGRect prevCaretRect;

@property (assign, nonatomic) NSInteger chooseFlag;
@property (nonatomic ,assign) NSInteger chooseGirl;
@property (nonatomic, strong) NSMutableArray *sourceTypeList;


@end

@implementation CustomerEditViewController
@synthesize customerDoc;
//@synthesize isEditing;
@synthesize table_Height;
@synthesize cusEditHeadImgView;
@synthesize phoneArray, emailArray, addressArray;
@synthesize pickerView, accessoryInputView;
@synthesize pickerData;
@synthesize chooseFlag;
@synthesize sourceTypeList;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLayout];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    if ((IOS7 || IOS8)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else if (IOS6) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    [super viewWillAppear:animated];
    //解决ios8调用相机然后裁剪图片后，状态栏消失（调用拍照页面时，会自动隐藏状态栏，所有只要页面还在拍照页及后续调用的图片裁剪页，以下代码无效，所以需要在此处调用以显示状态栏）
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_addCustomerOperation && [_addCustomerOperation isExecuting]) {
        [_addCustomerOperation cancel];
    }
    
    if (_updateCustomerOperation && [_updateCustomerOperation isExecuting]) {
        [_updateCustomerOperation cancel];
    }
    
    if (_deleteCustomerOpreation && [_deleteCustomerOpreation isExecuting]) {
        [_deleteCustomerOpreation cancel];
    }
    
    _addCustomerOperation = nil;
    _deleteCustomerOpreation = nil;
    _updateCustomerOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Layout

- (void)initLayout
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑基本信息"];
    [self.view addSubview:navigationView];
    
    _tableView.allowsSelection = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
       self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView.separatorInset = UIEdgeInsetsZero; 
    } else if (IOS6) {
       _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    table_Height = _tableView.frame.size.height;
    
    // --HeaderView
    cusEditHeadImgView = [[CusEditHeadImgView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f)];
    cusEditHeadImgView.customerEditController = self;
    [cusEditHeadImgView updateData:customerDoc];
    _tableView.tableHeaderView = cusEditHeadImgView;
    
    // --FooterView

    FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"确定" submitAction:@selector(submitInfo) deleteTitle:@"关闭" deleteAction:@selector(deleteAction)];
    
    [footerView showInTableView:_tableView];
    

    _initialTVHeight = _tableView.frame.size.height;
    
    self.chooseGirl = customerDoc.cus_gender;//选择性别默认为女
    sourceTypeList=[NSMutableArray array];
    [self getSourceTypeList];
}

- (void)deleteAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定关闭该顾客?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self requestDeleteCustomer];
        }
    }];
}

- (void)initPickerView
{
    if (pickerView == nil) {
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        pickerView.backgroundColor = [UIColor whiteColor];
        [pickerView setShowsSelectionIndicator:YES];
        [pickerView sizeThatFits:CGSizeZero];
        pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        pickerView.delegate = self;
        pickerView.dataSource = self;
    }
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)done
{
    [self dismissKeyBoard];
}

#pragma mark -
#pragma mark - Set Method

- (void)setCustomerDoc:(CustomerDoc *)newCustomerDoc
{
    if (customerDoc) {
        customerDoc = nil;
    }
    customerDoc = newCustomerDoc;
    if (!phoneArray) {
        phoneArray = [NSMutableArray array];
        emailArray = [NSMutableArray array];
        addressArray = [NSMutableArray array];
    } else {
        [phoneArray removeAllObjects];
        [emailArray removeAllObjects];
        [addressArray removeAllObjects];
    }
    phoneArray = [customerDoc.cus_PhoneArray mutableCopy];
    emailArray = [customerDoc.cus_EmailArray mutableCopy];
    addressArray = [customerDoc.cus_AdrsArray mutableCopy];
}

#pragma mark -
#pragma mark - Public Method
- (NSIndexPath *)indexPathForCellWithTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textView.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    }
    return [_tableView indexPathForRowAtPoint:cell.center];
}

- (void)dismissKeyBoard
{
    [self.view endEditing:YES];
    
    [cusEditHeadImgView dismissKeyboard];
   
    if (_initialTVHeight != 0) {
        CGRect tableFrame = _tableView.frame;
        tableFrame.size.height =  _initialTVHeight;
        _tableView.frame = tableFrame;
    }
}

- (void)setCustomKeyboardWithSection:(NSInteger)type textField:(UITextField *)textField selectedText:(NSString *)selectedText
{
    [self initPickerView];
    [self initInputAccessoryView];
    switch (type) {
        case 1:
            pickerData = [NSArray arrayWithObjects:@"手机", @"住宅", @"工作", @"其他", nil];
            [pickerView reloadAllComponents];
            [pickerView selectRow: [self returnIndexWithSelectedText:selectedText] inComponent:0 animated:YES];
            textField.inputAccessoryView = accessoryInputView;
            textField.inputView = pickerView;
            break;
        case 4:
            pickerData = [NSArray arrayWithObjects: @"住宅", @"工作", @"其他", nil];
            [pickerView reloadAllComponents];
            [pickerView selectRow: [self returnIndexWithSelectedText:selectedText] inComponent:0 animated:YES];
            textField.inputAccessoryView = accessoryInputView;
            textField.inputView = pickerView;
            break;
        case 5:
            pickerData = [NSArray arrayWithObjects: @"住宅", @"工作", @"其他", nil];
            [pickerView reloadAllComponents];
            [pickerView selectRow: [self returnIndexWithSelectedText:selectedText] inComponent:0 animated:YES];
            textField.inputAccessoryView = accessoryInputView;
            textField.inputView = pickerView;
            break;
        case 3:
//            pickerData = [self retrunMobileArray];
//            [pickerView reloadAllComponents];
//        
//            int index = [self returnIndexWithSelectedText:selectedText];
//            [pickerView selectRow:index inComponent:0 animated:YES];
//            textField.text = [pickerData objectAtIndex:index];
//            textField.inputAccessoryView = accessoryInputView;
//            textField.inputView = pickerView;
            [self chooseMobileAcc];
            break;
        case  2:
            [self customerSourceType];
            break;
        /*case 5:
        {
            // 选择美丽顾问 跳转
            SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            if (customerDoc.cus_ResponsiblePersonID == 0) {
                [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
            } else {
                UserDoc *userDoc = [[UserDoc alloc] init];
                [userDoc setUser_Id:customerDoc.cus_ResponsiblePersonID];
                [userDoc setUser_Name:customerDoc.cus_ResponsiblePersonName];
                [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
            }
            [selectCustomer setDelegate:self];
            [selectCustomer setPersonType:CustomePersonGroup];
            [selectCustomer setNavigationTitle:@"选择专属顾问"];
            UINavigationController *navigaitonController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
            [self presentViewController:navigaitonController animated:YES completion:^{}];
        }
            break;*/
            
        default:
            break;
    }
}


- (void)chooseMobileAcc {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"会员登录手机号选择" delegate:self cancelButtonTitle:@"无" destructiveButtonTitle:nil otherButtonTitles:nil];
    NSArray *mobileArray = [self retrunMobileArray];
    for (PhoneDoc *ph in mobileArray) {
        [actionSheet addButtonWithTitle:ph.ph_PhoneNum];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        customerDoc.cus_LoginMobileDoc = nil;
    } else {
        NSArray *mobileArray = [self retrunMobileArray];
        customerDoc.cus_LoginMobileDoc = [mobileArray objectAtIndex:buttonIndex - 1];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
}

- (int)returnIndexWithSelectedText:(NSString *)selectedText
{
    for (int i=0; i < [pickerData count]; i++) {
        NSString *str = [pickerData objectAtIndex:i];
        if ([str isEqualToString:selectedText]) {
            return i;
        }
    }
    return 0;
}

- (NSArray *)retrunMobileArray
{
    NSMutableArray *mobileArray = [NSMutableArray array];
//    [mobileArray addObject:@"无"];
    //add begin by zhangwei map GPB-919
    NSString *regularNumString = @"[0-9]{8}"; //匹配8-13位的数字
  //  NSString *regularCharString =@"[^0-9]"; //配数字之外的字符
    NSRegularExpression *regexNum = [NSRegularExpression regularExpressionWithPattern:regularNumString options:NSRegularExpressionCaseInsensitive error:nil];
  //  NSRegularExpression *regexChar = [NSRegularExpression regularExpressionWithPattern:regularCharString options:NSRegularExpressionCaseInsensitive error:nil];
    for (PhoneDoc *ph in phoneArray) {
        if (ph.ph_Type == 0 && ph.ph_PhoneNum.length > 0 && ph.ph_PhoneNum.length < 14 ) {
            if ( /*[regexChar numberOfMatchesInString:ph.ph_PhoneNum options:0 range:NSMakeRange(0, ph.ph_PhoneNum.length)] == 0 //不能匹配到数字之外的字符
                  && */[regexNum numberOfMatchesInString:ph.ph_PhoneNum options:0 range:NSMakeRange(0, ph.ph_PhoneNum.length)] > 0 //至少匹配成功1次
                ) {
//                [mobileArray addObject:ph.ph_PhoneNum];
                [mobileArray addObject:ph];
            }
        }
    }//add end by zhangwei map GPB-919
    return mobileArray;
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (NSIndexPath *)indexPathForCellWithTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if ((IOS6 || IOS8)) {
        cell = (UITableViewCell *)textField.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    }
    return [_tableView indexPathForRowAtPoint:cell.center];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextField:textField];
    if (textField.tag == 102) {  // 选择类型
        [self setCustomKeyboardWithSection:indexPath_Selected.section textField:textField selectedText:textField.text];
        
    }
    if (indexPath_Selected.section == 1|| indexPath_Selected.section == 2) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
    }
    if (indexPath_Selected.section == 3) { // 选择授权手机号
        // 显示键盘
        [self chooseMobileAcc];
        return NO;
    }
    if (indexPath_Selected.section == 2) { // 选择顾客来源
        [self customerSourceType];
        return NO;
    }
    chooseFlag = 0;
    self.textField_Selected = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}
// 如果有非数字则匹配失败
-(BOOL)phoneNumCheck:(NSString *)phoneNumString
{
    bool result = YES;
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < phoneNumString.length) {
        NSString *string = [phoneNumString substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if(range.length == 0)
        {
            result = NO;
            break;
        }
        i++;
    }
    return  result;
}

-(NSString *)NumCheck:(NSString *)NumString andOption:(NSInteger)option
{
    NSMutableString *NumStringDone = [NSMutableString stringWithString:@""];
    
    NSCharacterSet *tmpSet ;
    if(option == 1)
        tmpSet= [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    else if(option == 2)
        tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@-"];
    int i = 0;
    while (i < NumString.length) {
        NSString *string = [NumString substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if(range.length != 0)
        {
            [NumStringDone appendString:string];
        }
        i++;
    }
    return  [NumStringDone copy];
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString =  textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextField:textField];
            switch (indexPath_Selected.section) {
                case 1:  // 手机号码
                    textField.text = toBeString = [self NumCheck:toBeString  andOption:1];
                    if (toBeString.length > 20)
                        textField.text = [toBeString substringToIndex:20];
                    break;
                case 4:  // 邮箱
                    textField.text = toBeString = [self NumCheck:toBeString andOption:2];
                    if (toBeString.length > 50) textField.text = [toBeString substringToIndex:50];
                    break;
                case 5:  // 邮政
                    textField.text = toBeString = [self NumCheck:toBeString andOption:1];
                    if (toBeString.length > 10) textField.text = [toBeString substringToIndex:10];
                    break;
                default:  // others(美丽顾问、授权手机)
                    textField.text = toBeString = [self NumCheck:toBeString andOption:1];
                    if (toBeString.length > 20) textField.text = [toBeString substringToIndex:20];
                    break;
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextField:textField];
        switch (indexPath_Selected.section) {
            case 1:  // 手机号码
                textField.text = toBeString = [self NumCheck:toBeString  andOption:1];
                if (toBeString.length > 20) textField.text = [toBeString substringToIndex:20];
                break;
            case 4:  // 邮箱
                textField.text = toBeString = [self NumCheck:toBeString andOption:2];
                NSLog(@"%lu", (unsigned long)[textField.text length]);
                if (toBeString.length > 50) textField.text = [toBeString substringToIndex:50];
                break;
            case 5:  // 邮政
                textField.text = toBeString = [self NumCheck:toBeString andOption:1];
                if (toBeString.length > 10) textField.text = [toBeString substringToIndex:10];
                break;
            default:  // others(美丽顾问、授权手机)
                textField.text = toBeString = [self NumCheck:toBeString andOption:1];
                if (toBeString.length > 20) textField.text = [toBeString substringToIndex:20];
                break;
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"==%@", textField);
    NSLog(@"==%@", textField.superview.superview.superview);
    
    
    NSLog(@"-------------");
    NSLog(@"+++++End:%@  section:%ld row:%ld", textField,
          (long)[self indexPathForCellWithTextField:textField].section,
          (long)[self indexPathForCellWithTextField:textField].row);
    
    NSLog(@"+++++End:%@  section:%ld row:%ld", self.textField_Selected,
          (long)[self indexPathForCellWithTextField:self.textField_Selected].section,
          (long)[self indexPathForCellWithTextField:self.textField_Selected].row);
    
    if (textField.tag == 102) {
        return YES;
    }
    
    /*
     *  填充数据到对象
     */
    NSIndexPath *temp_IndexPath = [self indexPathForCellWithTextField:textField];
    //_pIndexPath(temp_IndexPath);
    switch (temp_IndexPath.section) {
        case 1:  // 手机号码
        {
            PhoneDoc *phoneDoc = [phoneArray objectAtIndex:temp_IndexPath.row];
            phoneDoc.ph_PhoneNum = [NSString stringWithFormat:@"%@", textField.text];
            
            if (phoneDoc.ph_ID == 0) {
                phoneDoc.ctlFlag = 1;
            } else {
                phoneDoc.ctlFlag = 2;
            }
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            NSLog(@"++++end:%ld  Add PH_PhoneNum:%@",(long)temp_IndexPath.row, phoneDoc.ph_PhoneNum);
        } break;
        case 4:  // 邮箱
        {
            EmailDoc *emailDoc = [emailArray objectAtIndex:temp_IndexPath.row];
            textField.text = [self  NumCheck:textField.text andOption:2];
            emailDoc.email_Email = [NSString stringWithFormat:@"%@", textField.text];
            
            if (emailDoc.email_ID == 0) {
                emailDoc.ctlFlag = 1;
            } else {
                emailDoc.ctlFlag = 2;
            }
        } break;
        case 5:  // 邮政
        {
            AddressDoc *addressDoc = [addressArray objectAtIndex:temp_IndexPath.row - 1];
            addressDoc.adrs_ZipCode = [NSString stringWithFormat:@"%@", textField.text];

            if (addressDoc.adrs_Id == 0) {
                addressDoc.ctlFlag = 1;
            } else {
                addressDoc.ctlFlag = 2;
            }
        } break;
        default: break;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    self.textField_Selected = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
    NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextField:textField];
    if (indexPath_Selected.section == 1) {
        [self checkLoginMob];
    }
}

- (void)checkLoginMob {
    if (customerDoc.cus_LoginMobileDoc.ph_Type != 0 || !(customerDoc.cus_LoginMobileDoc.ph_PhoneNum.length > 7 && customerDoc.cus_LoginMobileDoc.ph_PhoneNum.length < 14)) {
        customerDoc.cus_LoginMobileDoc = nil;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];

}

// 1、数据判断  2、填充对象数据
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*   
     *   数据判断(check)
     */
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextField:textField];
    switch (indexPath_Selected.section) {
        case 1:  // 手机号码
            return [self phoneNumCheck:string]; //如果是输入手机号码，则单独做check，如果不是数字则不接收
        case 4:  // 邮箱
            NSLog(@"%lu", (unsigned long)[textField.text length]);
            if ([textField.text length] > 49 && *ch != 0) return NO;
             break;
        case 5:  // 邮政
            if ([textField.text length] > 9 && *ch != 0) return NO;
             break;
        default:  // others(美丽顾问、授权手机)
            if ([textField.text length] > 19 && *ch != 0) return NO;
             break;
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    chooseFlag = 1;
    
    self.textView_Selected = textView;
  //  [self scrollToTextView:textView];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
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
            NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextView:textView];
            if (indexPath_Selected.section == 4) { // 工作地址
                if (toBeString.length > 100) {
                    textView.text = [toBeString substringToIndex:100];
                }
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else {
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextView:textView];
        if (indexPath_Selected.section == 4) { // 工作地址
            if (toBeString.length > 100) {
                textView.text = [toBeString substringToIndex:100];
            }
        }
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
}

// 1、数据判断  2、填充对象数据
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /*
     *   数据判断(check)
     */
    const char *ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    
    NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextView:textView];
//    if (indexPath_Selected.section == 2) { // 工作地址
//        if ([textView.text length] > 99) {
//            return NO;
//        }
//    }
    
    /*
     *  填充数据到对象
     */
    if (indexPath_Selected.section == 4) { // 工作地址
        AddressDoc *addressDoc = [addressArray objectAtIndex:indexPath_Selected.row - 1];
        addressDoc.adrs_Address = [NSString stringWithFormat:@"%@%@", textView.text, text];
        if (addressDoc.adrs_Id == 0) {
            addressDoc.ctlFlag = 1;
        } else {
            addressDoc.ctlFlag = 2;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    
     NSIndexPath *indexPath_Selected = [self indexPathForCellWithTextView:textView];
    if (indexPath_Selected.section == 4) { // 工作地址
        AddressDoc *addressDoc = [addressArray objectAtIndex:indexPath_Selected.row - 1];
        addressDoc.adrs_Address = textView.text;
        if (addressDoc.adrs_Id == 0) {
            addressDoc.ctlFlag = 1;
        } else {
            addressDoc.ctlFlag = 2;
        }
    }
}

#pragma mark - SelectCustomersViewControllerDelegate

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = [userArray firstObject];
    customerDoc.cus_ResponsiblePersonID = userDoc.user_Id;
    customerDoc.cus_ResponsiblePersonName = userDoc.user_Name;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
    
    if (chooseFlag == 0) {
        [self scrollToTextField:self.textField_Selected];
    } else {
        [self scrollToTextView:self.textView_Selected];
    }
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    self.textField_Selected = nil;
    self.textView_Selected = nil;
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath *path = [_tableView indexPathForRowAtPoint:cell.center];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)scrollToTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview;
    }
    NSIndexPath *path = [_tableView indexPathForRowAtPoint:cell.center];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


// 随着textView 滑动光标
- (void)scrollToCursorForTextView: (UITextView*)textView
{
    //20141029 修正输入地址时界面上下滚动，因下面这段代码引起。
//    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
//    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
//    
//    if (_prevCaretRect.size.height != newCursorRect.size.height) {
//        newCursorRect.size.height += 15;
//        _prevCaretRect = newCursorRect;
//        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
//    }
    
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
   
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    UIView *view = nil;
    if (IOS7) {
        view = touch.view.superview.superview;
    } else {
        view = touch.view.superview;
    }
    if ([view isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark - UIPickerViewDelegage && UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *tmpStr = [pickerData objectAtIndex:row];
    UILabel *label = [UILabel initNormalLabelWithFrame:view.bounds title:tmpStr];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20.0f];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [self indexPathForCellWithTextField:self.textField_Selected];
    switch (indexPath.section) {
        case 1:
        {
            PhoneDoc *phone = [phoneArray objectAtIndex:indexPath.row];
            if (phone.ph_ID == 0) {
                [phone setCtlFlag:1];
            } else {
                [phone setCtlFlag:2];
            }
            [phone setPh_Type:row];
        }
            break;
        case 4:
        {
            EmailDoc *email = [emailArray objectAtIndex:indexPath.row];
            if (email.email_ID == 0) {
                [email setCtlFlag:1];
            } else {
                [email setCtlFlag:2];
            }
            [email setEmail_Type:row];
        }
            break;
        case 5:
        {
            AddressDoc *adrs = [addressArray objectAtIndex:indexPath.row - 1];
            if (adrs.adrs_Id == 0) {
                [adrs setCtlFlag:1];
            } else {
                [adrs setCtlFlag:2];
            }
            [adrs setAdrs_Type:row];
        }break;
    default:
//            if (row >= 0 && [[self retrunMobileArray] count] > row)
//                customerDoc.cus_LoginMobile =  [[self retrunMobileArray] objectAtIndex:row];
            break;
            
    }
    
    [self.textField_Selected setText:[pickerData objectAtIndex:row]];
}

#pragma mark -
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;
        case 1: return [phoneArray count] + 1;
        case 4: return [emailArray count] + 1;
        case 5: return [addressArray count] + 2;
        case 2: return 1;
        case 3: return 1;
        default: return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.customerDoc.editStatus & CustomerEditStatusContacts) {
        return 6;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.customerDoc.editStatus & CustomerEditStatusContacts) {
        if (indexPath.section ==0) {
            CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
            return cell;
        }else if (indexPath.section == 1 || indexPath.section == 4) {
            NSInteger count = 0;
            switch (indexPath.section) {
                case 1: count = [phoneArray count]; break;
                case 4: count = [emailArray count]; break;
            }
            
            if (indexPath.row < count) {
                CusEditComplexCell *cell = [self configCusEditComplexCell:tableView indexPath:indexPath];
                return cell;
            } else {
                OrderAddCell *cell = [self configOrderAddCell:tableView indexPath:indexPath];
                return cell;
            }
        } else if (indexPath.section == 5) {
            if (indexPath.row == 0) {
                CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
                return cell;
            } else if (indexPath.row == [addressArray count] + 1) {
                OrderAddCell *cell = [self configOrderAddCell:tableView indexPath:indexPath];
                return cell;
            } else {
                CusEditAddressCell *cell = [self configCusEditAddressCell:tableView indexPath:indexPath];
                return cell;
            }
        } else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
                return cell;
            }
        }
        else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
                return cell;
            }
        }

    } else {
        if (indexPath.section ==0) {
            CusEditNormalCell *cell = [self configCusEditNormalCell:tableView indexPath:indexPath];
            return cell;
        }
    }
    return nil;
}

// address cell
- (CusEditAddressCell *)configCusEditAddressCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditAddressCell";
    CusEditAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.delegate = self;
    cell.zipText.delegate = self;
    cell.adrsText.delegate = self;
    cell.typeText.delegate = self;
    
    AddressDoc *addressDoc = [addressArray objectAtIndex:indexPath.row - 1];
    [cell updateData:addressDoc];
    return cell;
}

// complex cell
- (CusEditComplexCell *)configCusEditComplexCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditComplexCell";
    CusEditComplexCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditComplexCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.delegate = self;
    cell.contentText.delegate = self;
    cell.typeText.delegate = self;
    
    switch (indexPath.section) {
        case 1:
        {
            cell.titleLabel.text = @"电话";
            PhoneDoc *thePhone = [phoneArray objectAtIndex:indexPath.row];
            cell.typeText.text = thePhone.phoneType;
            cell.contentText.text = thePhone.ph_PhoneNum;
            cell.contentText.placeholder = @"输入电话";
        }
            break;
        case 4:
        {
            cell.titleLabel.text = @"邮件";
            EmailDoc *theEmail = [emailArray objectAtIndex:indexPath.row];
            cell.typeText.text = theEmail.emailType;
            cell.contentText.text = theEmail.email_Email;
            cell.contentText.placeholder = @"输入邮件";
        }
            break;
    }
    
    if (indexPath.row == 0) {
        [cell.titleLabel setHidden:NO];
    } else {
        [cell.titleLabel setHidden:YES];
    }
    
    return cell;
}

// normal cell
- (CusEditNormalCell *)configCusEditNormalCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"CusEditNormalCell";
    CusEditNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CusEditNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentText.delegate = self;
    
    switch (indexPath.section) {
        case 0:
        {
            CusEditNormalCell *editCell = [self configCusEditNormalCell1:tableView indexPath:indexPath];
            editCell.titleNameLabel.text = @"性别";
            editCell.contentText.hidden = YES;
            
            UIButton * sexBoyBt =[[UIButton alloc] initWithFrame:CGRectMake(150, 5, 30, 30)];
            [sexBoyBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
            [sexBoyBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
            [sexBoyBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *boylLable = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 20, 20)];
            boylLable.text = @"男";
            [editCell.contentView addSubview:boylLable];
            
            UIButton * sexGirlBt =[[UIButton alloc] initWithFrame:CGRectMake(220, 5, 30, 30)];
            [sexGirlBt setImage:[UIImage imageNamed:@"icon_unChecked.png"] forState:UIControlStateNormal];
            [sexGirlBt setImage:[UIImage imageNamed:@"icon_Checked.png"] forState:UIControlStateSelected];
            [sexGirlBt addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
            sexGirlBt.selected = NO;
            sexGirlBt.tag = 1;
            [editCell.contentView addSubview:sexGirlBt];
            
            UILabel *girlLable = [[UILabel alloc] initWithFrame:CGRectMake(250, 10, 20, 20)];
            girlLable.text = @"女";
            [editCell.contentView addSubview:girlLable];
            
            sexBoyBt.tag = 2;
            sexBoyBt.selected = NO;
            if (self.chooseGirl) {//为1选择为男
                sexBoyBt.selected = YES;
            }else{//为0选择为女
                sexGirlBt.selected = YES;
            }
            [editCell.contentView addSubview:sexBoyBt];
            
            return editCell;
        }
            
            break;
        case 5:
            cell.titleNameLabel.text = @"地址";
            [cell.contentText setHidden:YES];
            [cell.contentText setEnabled:YES];
            break;
        case  2:
            cell.titleNameLabel.text=@"顾客来源";
            [cell.contentText setHidden:NO];
            [cell.contentText setEnabled:YES];
            cell.contentText.text=customerDoc.cus_sourceTypeName;
            break;
        case 3:
        {
            cell.titleNameLabel.text = @"会员登录手机号";
            [cell.contentText setHidden:NO];
            [cell.contentText setEnabled:YES];
            [cell.contentText setText:customerDoc.cus_LoginMobileDoc.ph_PhoneNum.length > 0 ? customerDoc.cus_LoginMobileDoc.ph_PhoneNum : @"无"];
        }
            break;
            
    }
    return cell;
}


// 配置CusEditNormalCell
- (CusEditNormalCell *)configCusEditNormalCell1:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify = @"CusEditNormalCellSex";
    CusEditNormalCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[CusEditNormalCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)chooseAccount
{
    // 选择美丽顾问 跳转
    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    if (customerDoc.cus_ResponsiblePersonID == 0) {
        [selectCustomer setSelectModel:0 userType:3  customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
    } else {
        UserDoc *userDoc = [[UserDoc alloc] init];
        [userDoc setUser_Id:customerDoc.cus_ResponsiblePersonID];
        [userDoc setUser_Name:customerDoc.cus_ResponsiblePersonName];
        [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
        
    }
    [selectCustomer setPersonType:CustomePersonGroup];
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择专属顾问"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

// add cell
- (OrderAddCell *)configOrderAddCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = @"OrderAddCell";
    OrderAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[OrderAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    switch (indexPath.section) {
        case 1:
        {
           cell.promptLabel.text = @"添加新的号码";
            if (indexPath.row == 0) {
                cell.titleLabel.hidden = NO;
                cell.titleLabel.text = @"电话";
                cell.titleLabel.textColor = kColor_DarkBlue;
                cell.titleLabel.font = kFont_Light_16;
            } else {
                cell.titleLabel.hidden = YES;
            }
        }
            break;
        case 4:
        {
            cell.promptLabel.text = @"添加新的电子邮件";
            
            if (indexPath.row == 0) {
                cell.titleLabel.hidden = NO;
                cell.titleLabel.text = @"邮件";
                cell.titleLabel.textColor = kColor_DarkBlue;
                cell.titleLabel.font = kFont_Light_16;
            } else {
                cell.titleLabel.hidden = YES;
            }
        }
            break;
        case 5:
        {
            cell.promptLabel.text = @"添加新的地址";
            if (indexPath.row == 0) {
                cell.titleLabel.hidden = NO;
                cell.titleLabel.text = @"地址";
                cell.titleLabel.textColor = kColor_DarkBlue;
                cell.titleLabel.font = kFont_Light_16;
            } else {
                cell.titleLabel.hidden = YES;
            }
        }
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5) {
        if (indexPath.row != 0 && indexPath.row <= [addressArray count]) {
            AddressDoc *addressDoc = [addressArray objectAtIndex:indexPath.row - 1];
            return addressDoc.cell_Address_Height + 25.0f;
        }
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
    if (indexPath.section == 4) {
        [self choseSalesPerson];
    }
    if (indexPath.section == 5) {
        customerDoc.isImport = !customerDoc.isImport;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
     */
}

#pragma mark 顾客来源设置
- (void)customerSourceType
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"选择顾客来源" NumberOfRows:^NSInteger(NSInteger section) {
        return sourceTypeList.count;
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        static NSString *sourceTypeCell = @"sourceTypeCell";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:sourceTypeCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sourceTypeCell];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
            label.tag = 101;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kColor_SysBlue;//[UIColor blueColor];
            
            label.font = kFont_Light_18;
            
            [cell.contentView addSubview:label];
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
        }
        UILabel *lab = (UILabel *)[cell viewWithTag:101];
        lab.text = ((SourceType *)sourceTypeList[indexPath.row]).Name;
        
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        SourceType *info = [sourceTypeList objectAtIndex:selectedIndex.row];
        customerDoc.cus_sourceType = info.ID;
        customerDoc.cus_sourceTypeName = info.Name;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        
    } Completion:^{
        NSLog(@"Completion");
    }];
    
    [alert show];
}


//choose sex
-(void)chooseSex:(UIButton *)sender
{
    if (sender.tag ==1) {//女
        self.chooseGirl = 0;
    }else//男
    {
        self.chooseGirl = 1;
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark --选择销售顾问
- (void)choseSalesPerson {
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    
    if (customerDoc.cus_SalesID == 0) {
        [selectCustomer setSelectModel:0 userType:2 customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
    } else {
        UserDoc *userDoc = [[UserDoc alloc] init];
        [userDoc setUser_Id:customerDoc.cus_SalesID];
        [userDoc setUser_Name:customerDoc.cus_SalesName];
        [selectCustomer setSelectModel:0 userType:2 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
    }
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择销售顾问"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    UserDoc *userDoc = [userArray firstObject];
    customerDoc.cus_SalesID = userDoc.user_Id;
    customerDoc.cus_SalesName = userDoc.user_Name;
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark - CustomerEditDelegate

- (void)deleteCellWithCell:(UITableViewCell *)cell
{
    [self dismissKeyBoard]; // 恢复tableView高度和keyboard隐藏
    
    // 点击delete 删除的cell
    //NSIndexPath *theIndexPath = [_tableView indexPathForRowAtPoint:cell.center];
    NSIndexPath *theIndexPath = [_tableView indexPathForCell:cell];
    
    if (!theIndexPath) {
        NSLog(@"the index is nil");
        return;
    }
    NSInteger row = 0;
    switch (theIndexPath.section) {
        case 1:
        {
            row = theIndexPath.row;
            PhoneDoc *phone = [phoneArray objectAtIndex:row];
            if (phone.ph_ID == 0) {
                [phone setCtlFlag:0];   // 如果是新添加的对象 现在删除 只需要将ctlFlag改0 因为在提交修改之前 要删除ctlFlag=0的对象（一次性删除,不需要现在一个个删除）
            } else {
                [phone setCtlFlag:3];
            }
            [phoneArray removeObjectAtIndex:row];
            
            if ([customerDoc.cus_LoginMobileDoc.ph_PhoneNum isEqualToString:phone.ph_PhoneNum]) {
                customerDoc.cus_LoginMobileDoc = nil;
            }
            
            [_tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            double delayInSeconds = 0.2f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                [indexSet addIndex:1];
                [indexSet addIndex:3];
                [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            });
            
        } break;
        case 4:
        {
            row = theIndexPath.row;
            EmailDoc *email = [emailArray objectAtIndex:row];
            if (email.email_ID == 0) {
                [email setCtlFlag:0];
            } else {
                [email setCtlFlag:3];
            }
            [emailArray removeObjectAtIndex:row];
            
            [_tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            double delayInSeconds = 0.2f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
            break;
        case 5:
        {
            row = theIndexPath.row - 1;
            AddressDoc *adr = [addressArray objectAtIndex:row];
            if (adr.adrs_Id == 0) {
                [adr setCtlFlag:0];
            } else {
                [adr setCtlFlag:3];
            }
            [addressArray removeObjectAtIndex:row];
            [_tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

#pragma mark - OrderAddCellDelegate

- (void)chickAddButton:(UITableViewCell *)cell
{
    [self dismissKeyBoard]; // 恢复tableView高度和keyboard隐藏
    NSIndexPath *theIndexPath = [_tableView indexPathForRowAtPoint:cell.center];
    switch (theIndexPath.section) {
        case 1:
        {
            PhoneDoc *newPhone = [[PhoneDoc alloc] init];
            [newPhone setPh_ID:0];
            [newPhone setPh_PhoneNum:@""];
            [newPhone setPh_Type:0];
            [newPhone setCtlFlag:1];
            
            [phoneArray addObject:newPhone];
            [customerDoc.cus_PhoneArray addObject:newPhone];
        }
            break;
        case 4:
        {
            EmailDoc *newEmail = [[EmailDoc alloc] init];
            [newEmail setEmail_ID:0];
            [newEmail setEmail_Email:@""];
            [newEmail setEmail_Type:0];
            [newEmail setCtlFlag:1];
            
            [emailArray addObject:newEmail];
            [customerDoc.cus_EmailArray addObject:newEmail];
        }
            break;
        case 5:
        {
            AddressDoc *newAddress = [[AddressDoc alloc] init];
            [newAddress setAdrs_Id:0];
            [newAddress setAdrs_Address:@""];
            [newAddress setAdrs_ZipCode:@""];
            [newAddress setAdrs_Type:0];
            [newAddress setCtlFlag:1];
            
            [addressArray addObject:newAddress];
            [customerDoc.cus_AdrsArray addObject:newAddress];
        }
            break;
    }
    
   [_tableView insertRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    double delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:theIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark UIScrollViewDelegate

//只要滚动了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    //留用
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
    [cusEditHeadImgView.nameText resignFirstResponder];
    [cusEditHeadImgView.titleText resignFirstResponder];
}

#pragma mark -
#pragma mark - Submit

- (void)submitInfo
{
    [self.view endEditing:YES];
    customerDoc.cus_Name = cusEditHeadImgView.nameText.text;
    customerDoc.cus_Title = cusEditHeadImgView.titleText.text;
    
    if ([customerDoc.cus_Name length] == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"姓名不允许为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [customerDoc setCus_Title:customerDoc.cus_Title ? customerDoc.cus_Title : @""];
    customerDoc.cus_LoginMobile = customerDoc.cus_LoginMobileDoc.ph_PhoneNum ? customerDoc.cus_LoginMobileDoc.ph_PhoneNum : @"";;
//    [customerDoc setCus_LoginMobile:[customerDoc.cus_LoginMobile isEqualToString:@"无"] ? @"" : customerDoc.cus_LoginMobile];
    
    UIImage *uploadImag = [cusEditHeadImgView getLocalImage];
    NSString *imageType = [cusEditHeadImgView getImageType];
    [customerDoc setCus_HeadImg:uploadImag];
    [customerDoc setCus_ImgType:imageType];
    [self appendJson];
    [self checkAndRemoveNoChangedItem];
    [customerDoc setCus_ID:customerDoc.cus_ID];
    [self appendJson];
    [self updateCustomerInfo:customerDoc];
}
-(void)appendJson
{
    NSMutableArray *sendPhoneArray = [[NSMutableArray alloc] init];
    for (PhoneDoc *phoneDoc in customerDoc.cus_PhoneArray) {
        if (![phoneDoc.ph_PhoneNum isEqual: @""] && phoneDoc.ph_PhoneNum != nil) {
            [sendPhoneArray addObject:phoneDoc];
        }
    }
    [customerDoc.cus_PhoneArray removeAllObjects];
    [customerDoc.cus_PhoneArray addObjectsFromArray:sendPhoneArray];
    
    NSMutableArray *sendEmailArray = [[NSMutableArray alloc] init];
    for (EmailDoc *emailDoc in customerDoc.cus_EmailArray) {
        if (![emailDoc.email_Email isEqual: @""] && emailDoc.email_Email != nil) {
            [sendEmailArray addObject:emailDoc];
        }
    }
    [customerDoc.cus_EmailArray removeAllObjects];
    [customerDoc.cus_EmailArray addObjectsFromArray:sendEmailArray];
    
    NSMutableArray *sendAddressArray = [[NSMutableArray alloc] init];
    for (AddressDoc *addressDoc in customerDoc.cus_AdrsArray) {
        if ((![addressDoc.adrs_Address isEqual: @""] && addressDoc.adrs_Address != nil) || (![addressDoc.adrs_ZipCode isEqual: @""] && addressDoc.adrs_ZipCode != nil)) {
            [sendAddressArray addObject:addressDoc];
        }
    }
    [customerDoc.cus_AdrsArray removeAllObjects];
    [customerDoc.cus_AdrsArray addObjectsFromArray:sendAddressArray];
    
    
    NSMutableString *sendPhone_SendJson0 = [NSMutableString string];
    [sendPhone_SendJson0 appendString:@"["];
    for (PhoneDoc *phoneDoc in customerDoc.cus_PhoneArray) {
        if ([phoneDoc ctlFlag] != 0) {
            [sendPhone_SendJson0 appendFormat:@"{\"PhoneType\":%ld,",(long)phoneDoc.ph_Type];
            [sendPhone_SendJson0 appendFormat:@"\"PhoneID\":%ld,",(long)phoneDoc.ph_ID];
            [sendPhone_SendJson0 appendFormat:@"\"PhoneContent\":\"%@\",",phoneDoc.ph_PhoneNum];
            [sendPhone_SendJson0 appendFormat:@"\"OperationFlag\":%ld},",(long)phoneDoc.ctlFlag];
        }
    }
    
    if([[sendPhone_SendJson0 substringFromIndex:sendPhone_SendJson0.length -1] isEqual:@","])
        [sendPhone_SendJson0 deleteCharactersInRange:NSMakeRange(sendPhone_SendJson0.length - 1, 1)];
    [sendPhone_SendJson0 appendString:@"]"];
    customerDoc.cus_PhoneSend = sendPhone_SendJson0;
    
    
    NSMutableString *sendEmail_SendJson0 = [NSMutableString string];
    [sendEmail_SendJson0 appendString:@"["];
    for (EmailDoc *emailDoc in customerDoc.cus_EmailArray) {
        if ([emailDoc ctlFlag] != 0) {
            [sendEmail_SendJson0 appendFormat:@"{\"EmailType\":%ld,", (long)emailDoc.email_Type];
            [sendEmail_SendJson0 appendFormat:@"\"EmailID\":%ld,",(long)emailDoc.email_ID];
            [sendEmail_SendJson0 appendFormat:@"\"EmailContent\":\"%@\",",emailDoc.email_Email];
            [sendEmail_SendJson0 appendFormat:@"\"OperationFlag\":%ld},",(long)emailDoc.ctlFlag];

        }
    }
    
    if([[sendEmail_SendJson0 substringFromIndex:sendEmail_SendJson0.length -1] isEqual:@","])
        [sendEmail_SendJson0 deleteCharactersInRange:NSMakeRange(sendEmail_SendJson0.length - 1, 1)];
    [sendEmail_SendJson0 appendString:@"]"];
    customerDoc.cus_EmailSend = sendEmail_SendJson0;
    
    NSMutableString *sendAddress_SendJson0 = [NSMutableString string];
    [sendAddress_SendJson0 appendString:@"["];
    for (AddressDoc *addressDoc in customerDoc.cus_AdrsArray) {
        if ([addressDoc ctlFlag] != 0) {
            [sendAddress_SendJson0 appendFormat:@"{\"AddressType\":%ld,",(long)addressDoc.adrs_Type];
            [sendAddress_SendJson0 appendFormat:@"\"AddressID\":%ld,",(long)addressDoc.adrs_Id];
            [sendAddress_SendJson0 appendFormat:@"\"AddressContent\":\"%@\",",addressDoc.adrs_Address];
            [sendAddress_SendJson0 appendFormat:@"\"ZipCode\":\"%@\",",addressDoc.adrs_ZipCode];
            [sendAddress_SendJson0 appendFormat:@"\"OperationFlag\":%ld},",(long)addressDoc.ctlFlag];

        }
    }
    
    if([[sendAddress_SendJson0 substringFromIndex:sendAddress_SendJson0.length -1] isEqual:@","])
        [sendAddress_SendJson0 deleteCharactersInRange:NSMakeRange(sendAddress_SendJson0.length - 1, 1)];
    [sendAddress_SendJson0 appendString:@"]"];
    
    customerDoc.cus_AddressSend = sendAddress_SendJson0;
    
}

- (void)appendXML
{
    NSMutableArray *sendPhoneArray = [[NSMutableArray alloc] init];
    for (PhoneDoc *phoneDoc in customerDoc.cus_PhoneArray) {
        if (![phoneDoc.ph_PhoneNum isEqual: @""] && phoneDoc.ph_PhoneNum != nil) {
            [sendPhoneArray addObject:phoneDoc];
        }
    }
    [customerDoc.cus_PhoneArray removeAllObjects];
    [customerDoc.cus_PhoneArray addObjectsFromArray:sendPhoneArray];
    
    NSMutableArray *sendEmailArray = [[NSMutableArray alloc] init];
    for (EmailDoc *emailDoc in customerDoc.cus_EmailArray) {
        if (![emailDoc.email_Email isEqual: @""] && emailDoc.email_Email != nil) {
            [sendEmailArray addObject:emailDoc];
        }
    }
    [customerDoc.cus_EmailArray removeAllObjects];
    [customerDoc.cus_EmailArray addObjectsFromArray:sendEmailArray];
    
    NSMutableArray *sendAddressArray = [[NSMutableArray alloc] init];
    for (AddressDoc *addressDoc in customerDoc.cus_AdrsArray) {
        if ((![addressDoc.adrs_Address isEqual: @""] && addressDoc.adrs_Address != nil) || (![addressDoc.adrs_ZipCode isEqual: @""] && addressDoc.adrs_ZipCode != nil)) {
            [sendAddressArray addObject:addressDoc];
        }
    }
    [customerDoc.cus_AdrsArray removeAllObjects];
    [customerDoc.cus_AdrsArray addObjectsFromArray:sendAddressArray];
    
    
    NSMutableString *sendPhone_SendXML0 = [NSMutableString string];
    for (PhoneDoc *phoneDoc in customerDoc.cus_PhoneArray) {
        if ([phoneDoc ctlFlag] != 0) {
            GDataXMLElement *rootElement_Phone = [GDataXMLElement elementWithName:@"Phone"];
            GDataXMLElement *element_PhoneID      =  [GDataXMLElement elementWithName:@"PhoneID"   stringValue:[NSString stringWithFormat:@"%ld", (long)phoneDoc.ph_ID]];
            GDataXMLElement *element_PhoneType    =  [GDataXMLElement elementWithName:@"PhoneType" stringValue:[NSString stringWithFormat:@"%ld", (long)phoneDoc.ph_Type]];
            GDataXMLElement *element_PhoneContent =  [GDataXMLElement elementWithName:@"PhoneContent"  stringValue:phoneDoc.ph_PhoneNum];
            GDataXMLElement *element_PhoneFlag    =  [GDataXMLElement elementWithName:@"OperationFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)phoneDoc.ctlFlag]];
            [rootElement_Phone addChild:element_PhoneID];
            [rootElement_Phone addChild:element_PhoneType];
            [rootElement_Phone addChild:element_PhoneContent];
            [rootElement_Phone addChild:element_PhoneFlag];
            [sendPhone_SendXML0 appendString:[rootElement_Phone XMLString]];
        }
    }
    DLOG(@"+++sendPhone_SendXML:%@", sendPhone_SendXML0);
    NSString *sendPhone_SendXML1 = [sendPhone_SendXML0 stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    NSString *sendPhone_SendXML2 = [sendPhone_SendXML1 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    customerDoc.cus_PhoneSend = sendPhone_SendXML2;
    
    NSMutableString *sendEmailXml0 = [NSMutableString string];
    for (EmailDoc *emailDoc in customerDoc.cus_EmailArray) {
        if ([emailDoc ctlFlag] != 0) {
            GDataXMLElement *rootElement_Email = [GDataXMLElement elementWithName:@"Email"];
            GDataXMLElement *element_EmailID      =  [GDataXMLElement elementWithName:@"EmailID"   stringValue:[NSString stringWithFormat:@"%ld", (long)emailDoc.email_ID]];
            GDataXMLElement *element_EmailType    =  [GDataXMLElement elementWithName:@"EmailType" stringValue:[NSString stringWithFormat:@"%ld", (long)emailDoc.email_Type]];
            GDataXMLElement *element_EmailContent =  [GDataXMLElement elementWithName:@"EmailContent"  stringValue:emailDoc.email_Email];
            GDataXMLElement *element_EmailFlag    =  [GDataXMLElement elementWithName:@"OperationFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)emailDoc.ctlFlag]];
            [rootElement_Email addChild:element_EmailID];
            [rootElement_Email addChild:element_EmailType];
            [rootElement_Email addChild:element_EmailContent];
            [rootElement_Email addChild:element_EmailFlag];
            [sendEmailXml0 appendString:[rootElement_Email XMLString]];
        }
    }
    
     DLOG(@"+++sendEmailXml:%@", sendEmailXml0);
    NSString *sendEmailXml1 = [sendEmailXml0 stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    NSString *sendEmailXml2 = [sendEmailXml1 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    customerDoc.cus_EmailSend = sendEmailXml2;
    
    NSMutableString *sendAddressXML0 = [NSMutableString string];
    for (AddressDoc *addressDoc in customerDoc.cus_AdrsArray) {
        if ([addressDoc ctlFlag] != 0) {
            GDataXMLElement *rootElement_Address = [GDataXMLElement elementWithName:@"Address"];
            GDataXMLElement *element_AddressID      =  [GDataXMLElement elementWithName:@"AddressID"   stringValue:[NSString stringWithFormat:@"%ld", (long)addressDoc.adrs_Id]];
            GDataXMLElement *element_AddressType    =  [GDataXMLElement elementWithName:@"AddressType" stringValue:[NSString stringWithFormat:@"%ld", (long)addressDoc.adrs_Type]];
            GDataXMLElement *element_AddressContent =  [GDataXMLElement elementWithName:@"AddressContent"  stringValue:addressDoc.adrs_Address];
            GDataXMLElement *element_ZipCode        =  [GDataXMLElement elementWithName:@"ZipCode" stringValue:addressDoc.adrs_ZipCode];
            GDataXMLElement *element_AddressFlag    =  [GDataXMLElement elementWithName:@"OperationFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)addressDoc.ctlFlag]];
            [rootElement_Address addChild:element_AddressID];
            [rootElement_Address addChild:element_AddressType];
            [rootElement_Address addChild:element_AddressContent];
            [rootElement_Address addChild:element_ZipCode];
            [rootElement_Address addChild:element_AddressFlag];
            [sendAddressXML0 appendString:[rootElement_Address XMLString]];
        }
    }
    DLOG(@"+++sendAddressXML:%@", sendAddressXML0);
    NSString *sendAddressXML1 = [sendAddressXML0 stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    NSString *sendAddressXML2 = [sendAddressXML1 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    customerDoc.cus_AddressSend = sendAddressXML2;
}

- (void)checkAndRemoveNoChangedItem
{
    for (int i=0; i< [customerDoc.cus_PhoneArray count]; i++) {
        PhoneDoc *phone = [customerDoc.cus_PhoneArray objectAtIndex:i];
        DLOG(@"ph:%p  %ld  %ld", phone, (long)phone.ph_ID, (long)phone.ctlFlag);
        if (phone.ctlFlag == 0) {
            [customerDoc.cus_PhoneArray removeObjectAtIndex:i];
            i--;
        }
    }
    
    for (int i=0; i< [customerDoc.cus_EmailArray count]; i++) {
        EmailDoc *email = [customerDoc.cus_EmailArray objectAtIndex:i];
        if (email.ctlFlag == 0) {
            [customerDoc.cus_EmailArray removeObjectAtIndex:i];
            i--;
        }
    }
    
    for (int i=0; i< [customerDoc.cus_AdrsArray count]; i++) {
        AddressDoc *adrs = [customerDoc.cus_AdrsArray objectAtIndex:i];
        if (adrs.ctlFlag == 0) {
            [customerDoc.cus_AdrsArray removeObjectAtIndex:i];
            i--;
        }
    }
}
//获取顾客来源列表
- (void)getSourceTypeList
{
    NSDictionary * par =@{};
    _requestSourceType = [[GPBHTTPClient sharedClient] requestUrlPath:@"/customer/GetCustomerSourceType" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [(NSArray *)data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [sourceTypeList addObject:[[SourceType alloc] initWithDictionary:obj]];
            }];
            bool hasSourceType=false;
            if(sourceTypeList.count>0){
                for(int i=0;i<sourceTypeList.count;i++){
                    SourceType *sourceType=[sourceTypeList objectAtIndex:i];
                    if(sourceType.ID==customerDoc.cus_sourceType){
                        hasSourceType=true;
                        break;
                    }
                }
                if(!hasSourceType){
                    SourceType *st=[sourceTypeList objectAtIndex:0];
                    customerDoc.cus_sourceType = st.ID;
                    customerDoc.cus_sourceTypeName = st.Name;
                }
            }
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - 接口

-(void)addCustomerInfoWithJson:(CustomerDoc *)newCustomerDoc flag:(NSInteger)flag
{
    [SVProgressHUD showWithStatus:@"Loading"];
    self.view.userInteractionEnabled = NO;
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = newCustomerDoc.cus_HeadImg;
    NSString *imgType = newCustomerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }

    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"IsCheck\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerName\":\"%@\",\"Title\":\"%@\",\"LoginMobile\":\"%@\",\"LevelID\":%ld,\"PhoneList\":%@,\"EmailList\":%@,\"AddressList\":%@,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"HeadFlag\":%d,\"ImageWidth\":%d,\"ImageHeight\":%d}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)flag, (long)newCustomerDoc.cus_ResponsiblePersonID, newCustomerDoc.cus_Name, newCustomerDoc.cus_Title, newCustomerDoc.cus_LoginMobile, (long)newCustomerDoc.cus_Level, newCustomerDoc.cus_PhoneSend, newCustomerDoc.cus_EmailSend, newCustomerDoc.cus_AddressSend, imgStr, imgType, headFlag, 160, 160];

    
    _addCustomerOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/addCustomer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加成功，是否选中该顾客?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    CustomerDoc *customer = [[CustomerDoc alloc] init];
                    [customer setCus_Name:[data objectForKey:@"CustomerName"]];
                    [customer setCus_ID:[[data objectForKey:@"CustomerID"] integerValue]];
                    [customer setCus_QuanPinYin:[data objectForKey:@"PinYin"]];
                    [customer setCus_ShortPinYin:[data objectForKey:@"PinYinFirst"]];
                    [customer setCus_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
                    [customer setCus_LoginMobile:[data objectForKey:@"LoginMobile"]];
                    if (customer.cus_LoginMobile) {
                        PhoneDoc *pho = [[PhoneDoc alloc] init];
                        pho.ph_PhoneNum = customer.cus_LoginMobile;
                        pho.ph_Type = 0;
                        customer.cus_LoginMobileDoc = pho;
                    } else {
                        customer.cus_LoginMobileDoc = nil;
                    }
                    float discount = [[data objectForKey:@"Discount"] integerValue];
                    [customer setCus_Discount:discount == 0 ? 1.0f : discount];
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    app.customer_Selected = customer;
                    
                    [customer setCus_IsMyCustomer:[[data objectForKey:@"IsMyCustomer"] boolValue]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                self.view.userInteractionEnabled = YES;
            }];

        } failure:^(NSInteger code, NSString *error) {
            if (code == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@%@",error,@"是否继续提交?"] delegate:nil cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        self.view.userInteractionEnabled = YES;
                    } else {
                        [self addCustomerInfoWithJson:customerDoc flag:0];
                    }
                }];

            } else if(code == -1){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"新增顾客失败，请重试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {}];
                self.view.userInteractionEnabled = YES;
            } else if(code == -2 || code == -3){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                self.view.userInteractionEnabled = YES;
            }

        }];
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
    }];
    
}

- (void)updateCustomerInfo:(CustomerDoc *)newCustomerDoc
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = newCustomerDoc.cus_HeadImg;
    NSString *imgType = newCustomerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }

    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"CustomerName\":\"%@\",\"Title\":\"%@\",\"LoginMobile\":\"%@\",\"PhoneList\":%@,\"EmailList\":%@,\"AddressList\":%@,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"HeadFlag\":%d,\"Gender\":%ld,\"SourceType\":%ld}",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)newCustomerDoc.cus_ID, newCustomerDoc.cus_Name, newCustomerDoc.cus_Title, newCustomerDoc.cus_LoginMobile, newCustomerDoc.cus_PhoneSend, newCustomerDoc.cus_EmailSend, newCustomerDoc.cus_AddressSend, imgStr, imgType, headFlag,(long)self.chooseGirl,(long)newCustomerDoc.cus_sourceType];

    _updateCustomerOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/updateCustomerBasic" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)requestDeleteCustomer
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerDoc.cus_ID];
    _deleteCustomerOpreation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/deleteCustomer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"关闭顾客成功！" duration:2.0 touchEventHandle:^{
                [((AppDelegate *) [[UIApplication sharedApplication] delegate]) setCustomer_Selected:nil];
                [self goToCustomerList];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];

    } failure:^(NSError *error) {
        
    }];
}

- (void)goToCustomerList
{
    UIViewController *topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomerNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = topViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

@end
