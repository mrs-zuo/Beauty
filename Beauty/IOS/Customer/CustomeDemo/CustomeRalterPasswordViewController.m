//
//  CustomeRalterPasswordViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-9-9.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "CustomeRalterPasswordViewController.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "NSString+Additional.h"
#import "GDataXMLDocument+ParseXML.h"
#import "noCopyTextField.h"
#import "RSA.h"
#import "LoginViewController.h"
@interface CustomeRalterPasswordViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestChangeCustomerPasswordOperation;
@property (strong, nonatomic) UITextField *textField_selected;
@property (copy, nonatomic) NSString *oldPassword;
@property (copy, nonatomic) NSString *nPassword;
@property (copy, nonatomic) NSString *nPasswordWriteAgain;
@property (strong, nonatomic) RSA *RSAPublicKey;
@end

@implementation CustomeRalterPasswordViewController
@synthesize myTableView;
@synthesize textField_selected;

@synthesize oldPassword;
@synthesize nPassword;
@synthesize nPasswordWriteAgain;

int textFieldY;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width - 10, 60.0f)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footerButton setFrame:CGRectMake(0, 10, kSCREN_BOUNDS.size.width, 40)];
    [footerButton setBackgroundImage:nil forState:UIControlStateNormal];
    footerButton.backgroundColor = kColor_BtnBackground;
    [footerButton setTitle:@"确定" forState:UIControlStateNormal];
    footerButton.titleLabel.font = kNormalFont_14;
    [footerButton setTitleColor:kColor_White forState:UIControlStateNormal];
    [footerButton addTarget:self action:@selector(submitNewPassword) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:footerButton];
    myTableView.tableFooterView = footerView;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [myTableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
    self.title = @"密码修改";
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    [myTableView setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:@"dismissKeyboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestChangeCustomerPasswordOperation || [_requestChangeCustomerPasswordOperation isExecuting]) {
        [_requestChangeCustomerPasswordOperation cancel];
        _requestChangeCustomerPasswordOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
    }
    
    UILabel *Label = (UILabel *)[cell.contentView viewWithTag:100];
    noCopyTextField *myTextField = (noCopyTextField *)[cell.contentView viewWithTag:101];
    [Label setFont:kNormalFont_14];
    [myTextField setFont:kNormalFont_14];
    myTextField.secureTextEntry = YES;
    myTextField.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row == 0) {
        [Label setText:@"旧密码"];
        [myTextField setPlaceholder:@"旧密码"];
    } else if (indexPath.row == 1) {
        [Label setText:@"新密码"];
        [myTextField setPlaceholder:@"6~20位新密码"];
    } else {
        [Label setText:@"新密码确认"];
        [myTextField setPlaceholder:@"重复6~20位新密码"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    
}

- (void)dismissKeyboard
{
    [textField_selected resignFirstResponder];
}

#pragma mark - textField

-(BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField_selected = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSIndexPath *theIndexPath = [self indexPathForCellWithTextFiled:textField];
    switch (theIndexPath.row) {
        case 0:
            oldPassword = textField.text;
            break;
        case 1:
            nPassword = textField.text;
            break;
        case 2:
            nPasswordWriteAgain = textField.text;
            break;
        default:
            break;
    }
    return YES;
}

- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField
{
    if(IOS7){
        UITableViewCell *cell = (UITableViewCell *)[[[textField superview] superview] superview];
        return [myTableView indexPathForCell:cell];
    } else {
        UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
        return [myTableView indexPathForCell:cell];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    if (range.location >= 20){
        [SVProgressHUD showErrorWithStatus2:@"新密码长度大于20位"];
        return NO;
    }
    return YES;
}

#pragma mark - button

- (void)submitNewPassword
{
    for (int i = 0; i < 3; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [myTableView cellForRowAtIndexPath:index];
        UITextField *textField = (UITextField *)[cell viewWithTag:101];
        switch (i) {
            case 0:
                oldPassword = textField.text;
                break;
            case 1:
                nPassword = textField.text;
                break;
            case 2:
                nPasswordWriteAgain = textField.text;
                break;
            default:
                break;
        }
    }
    
    if (oldPassword != nil && nPassword != nil && nPasswordWriteAgain != nil && ![oldPassword  isEqualToString: @""] && ![nPassword  isEqualToString: @""] && ![nPasswordWriteAgain  isEqualToString: @""]) {
        BOOL nPasswordIsEqual = [nPassword isEqualToString:nPasswordWriteAgain];
        if (nPasswordIsEqual != true) {
            [SVProgressHUD showErrorWithStatus2:@"两次输入的新密码不同"];
            return;
        } else {
            if (nPassword.length < 6) {
                [SVProgressHUD showErrorWithStatus2:@"新密码长度小于6位"];
            } else {
                [self requestSubmitPassword:oldPassword];
            }
        }
        
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请输入完整信息"];
        return;
    }
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
    [self.textField_selected resignFirstResponder];
}

#pragma mark - 接口

- (void)requestSubmitPassword:(NSString *)oPassword
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _RSAPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [_RSAPublicKey extractPublicFromCertificateFile:certPath];

    NSString *pwdBase64 = [_RSAPublicKey RSAEncryptByPublicKeyWithString:nPassword];
    NSDictionary *para = @{@"UserID":@(CUS_CUSTOMERID),
                           @"OldPassword":[_RSAPublicKey RSAEncryptByPublicKeyWithString:oPassword],
                           @"NewPassword":pwdBase64};
    _requestChangeCustomerPasswordOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/login/updateUserPassword"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [[NSUserDefaults standardUserDefaults] setObject:pwdBase64 forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:[message length] > 0 ? @"密码修改成功！" : message];
            
            [self clearAndOut];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


-(void)clearAndOut
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_USERID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHID"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DISCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DATABASE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYSCALE"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PROMOTION"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_REMINDCOUNT"];//
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYLIST"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CONFIRMCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_ADVANCED"];
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"isAutoLogin"];
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"login_selected_compmay"];
    

    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginVC animated:YES completion:^{
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.isNeedGetVersion = NO;
    }];
 
    [SVProgressHUD dismiss];
}

@end
