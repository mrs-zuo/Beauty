//
//  AccountRalterPasswordViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-12-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "AccountRalterPasswordViewController.h"
#import "InitialSlidingViewController.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "NSString+Additional.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "GDataXMLNode.h"
#import "FooterView.h"
#import "noCopyTextField.h"
#import "GPBHTTPClient.h"
#import "RSA.h"

@interface AccountRalterPasswordViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestChangeAccountPasswordOperation;
@property (strong, nonatomic) UITextField *textField_selected;
@property (copy, nonatomic) NSString *oldPassword;
@property (copy, nonatomic) NSString *nPassword;
@property (copy, nonatomic) NSString *nPasswordWriteAgain;
@end

@implementation AccountRalterPasswordViewController
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestChangeAccountPasswordOperation && [_requestChangeAccountPasswordOperation isExecuting]) {
        [_requestChangeAccountPasswordOperation cancel];
        _requestChangeAccountPasswordOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, 5.0f) title:@"密码修改"];
    [self.view addSubview:navigationView];
    
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self
                                                      submitImg:[UIImage imageNamed:@"buttonLong_Confirm"]
                                                    submitTitle:@"确定"
                                                   submitAction:@selector(submitNewPassword)];
    [footerView showInTableView:myTableView];
    
    
    UITapGestureRecognizer *tapGestureRecognozer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGestureRecognozer.numberOfTapsRequired = 1;
    tapGestureRecognozer.numberOfTouchesRequired = 1;
    tapGestureRecognozer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognozer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    return kTableView_HeightOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIndentify = @"myCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        UILabel *Label = (UILabel *)[cell.contentView viewWithTag:100];
        noCopyTextField *myTextField = (noCopyTextField *)[cell.contentView viewWithTag:101];
        [Label setText:@"旧密码"];
        [Label setFont:kFont_Light_16];
        [myTextField setFont:kFont_Light_16];
        [myTextField setPlaceholder:@"输入旧密码"];
        myTextField.secureTextEntry = YES;
        myTextField.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *cellIndentify = @"myCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        UILabel *Label = (UILabel *)[cell.contentView viewWithTag:100];
        noCopyTextField *myTextField = (noCopyTextField *)[cell.contentView viewWithTag:101];
        [Label setText:@"新密码"];
        [Label setFont:kFont_Light_16];
        [myTextField setFont:kFont_Light_16];
        [myTextField setPlaceholder:@"输入6~20位新密码"];
        myTextField.secureTextEntry = YES;
        myTextField.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    } else {
        static NSString *cellIndentify = @"myCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        UILabel *Label = (UILabel *)[cell.contentView viewWithTag:100];
        noCopyTextField *myTextField = (noCopyTextField *)[cell.contentView viewWithTag:101];
        [Label setText:@"新密码确认"];
        [Label setFont:kFont_Light_16];
        [myTextField setFont:kFont_Light_16];
        [myTextField setPlaceholder:@"再次输入6~20位新密码"];
        myTextField.secureTextEntry = YES;
        myTextField.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
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
    if (IOS7) {
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
    if (range.location >= 20) {
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
   
    if (oldPassword != nil || nPassword != nil || nPasswordWriteAgain != nil) {
        if (oldPassword.length == 0) {
            [SVProgressHUD showErrorWithStatus2:@"旧密码不能为空！" touchEventHandle:^{}];
            return;
        }
        if (oldPassword.length < 6 || oldPassword.length > 20) {
            [SVProgressHUD showErrorWithStatus2:@"旧密码长度应大于6位并小于20位!" touchEventHandle:^{}];
            return;
        }
        if (nPassword.length == 0) {
            [SVProgressHUD showErrorWithStatus2:@"新密码不能为空！" touchEventHandle:^{}];
            return;
        }
        if (nPassword.length < 6 || nPassword.length > 20) {
            [SVProgressHUD showErrorWithStatus2:@"新密码长度应大于6位并小于20位!" touchEventHandle:^{}];
            return;
        }
        if (nPasswordWriteAgain.length == 0) {
            [SVProgressHUD showErrorWithStatus2:@"确认密码不能为空！" touchEventHandle:^{}];
            return;
        }
        if (nPasswordWriteAgain.length < 6 || nPasswordWriteAgain.length > 20) {
            [SVProgressHUD showErrorWithStatus2:@"确认密码长度应大于6位并小于20位!" touchEventHandle:^{}];
            return;
        }
        BOOL nPasswordIsEqual = [nPassword isEqualToString:nPasswordWriteAgain];
        if (nPasswordIsEqual != true) {
            [SVProgressHUD showErrorWithStatus2:@"新密码两次输入不一致！" touchEventHandle:^{}];
            return;
        } else {
                [self requestSubmitPassword:oldPassword];
        }
    } else {
        [SVProgressHUD showErrorWithStatus2:@"旧密码不允许为空！" touchEventHandle:^{}];
        return;
    }
}

#pragma mark - 接口

- (void)requestSubmitPassword:(NSString *)oPassword
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    RSA   *rsaPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [rsaPublicKey extractPublicFromCertificateFile:certPath];
    
    NSString *oldPwd = [rsaPublicKey RSAEncryptByPublicKeyWithString:oPassword];
    NSString *newPwd = [rsaPublicKey RSAEncryptByPublicKeyWithString:nPassword];

    NSString *par = [NSString stringWithFormat:@"{\"UserID\":%ld,\"OldPassword\":\"%@\",\"NewPassword\":\"%@\"}", (long)ACC_ACCOUNTID, oldPwd, newPwd];

    _requestChangeAccountPasswordOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/updateUserPassword" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
               [SVProgressHUD showErrorWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                   
               }];
            }
         
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

@end
