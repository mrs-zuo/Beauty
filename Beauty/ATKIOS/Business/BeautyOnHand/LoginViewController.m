//
//  LoginViewController.m
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "LoginViewController.h"
#import "InitialSlidingViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "NSString+Additional.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "DEFINE.h"
#import "AccountDoc.h"
#import "noCopyTextField.h"
#import "PermissionDoc.h"
#import "AppDelegate.h"
#import "LoginDoc.h"
#import "ChooseCompanyViewController.h"
#import "GPBHTTPClient.h"
#import "RSA.h"
#import "DeviceInfoManager.h"

#define STATEMENTString @"© 2014 HSquare"


@interface LoginViewController ()
@property (assign, nonatomic) CGRect prevCursorRect;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (weak, nonatomic) AFHTTPRequestOperation *getVersionOperation;
@property (strong ,nonatomic) NSMutableArray *loginArray;
@end

@implementation LoginViewController
@synthesize txtUserName;
@synthesize txtPassword;
@synthesize prevCursorRect;
@synthesize textField_Selected;
@synthesize bgImageView, userNameImageView, passwordImageView, logoImageView, statementLabel;
@synthesize loginButton;

- (void)awakeFromNib
{
    bgImageView.frame = self.view.bounds;
    if(IOS6)
        bgImageView.image = [UIImage imageNamed:@"login_bg"];
    else
        bgImageView.image = [UIImage imageNamed:@"login_bg-568h"];
    
    UIImage *loginImage = [UIImage imageNamed:@"login_logo"];
    CGRect loginRect =  CGRectMake((kSCREN_BOUNDS.size.width - loginImage.size.width)/2, 50.0f, loginImage.size.width, loginImage.size.height);
    
    if (kSCREN_BOUNDS.size.height  != 568.0f && (IOS7 || IOS8)) {
        loginRect.origin.y = 40.0f;
    }
    if (kSCREN_BOUNDS.size.height != 568.0f && IOS6) {
        loginRect.origin.y = 20.0f;
    }
    logoImageView.frame = loginRect;
    logoImageView.image = loginImage;
    logoImageView.contentMode = UIViewContentModeTop;
    
    
    UIImage *userImage = [UIImage imageNamed:@"login_textField_userName"];
    UIImage *pwdImage = [UIImage imageNamed:@"login_textField_password"];
    CGRect userRect = CGRectMake((kSCREN_BOUNDS.size.width - userImage.size.width)/2, logoImageView.frame.origin.y + 200.0f, userImage.size.width, userImage.size.height);
    CGRect pwdRect = CGRectMake((kSCREN_BOUNDS.size.width - pwdImage.size.width)/2, userRect.origin.y + 34.0f, pwdImage.size.width, pwdImage.size.height);
    
    userNameImageView.frame = userRect;
    passwordImageView.frame = pwdRect;
    userNameImageView.image = userImage;
    passwordImageView.image = pwdImage;
    
    userRect.origin.x += 30.0f;
    userRect.size.width -= 30.0f;
    userRect.origin.y -= 2.0f;
    txtUserName.frame = userRect;
    
    pwdRect.origin.x += 30.0f;
    pwdRect.size.width -= 30.0f;
    pwdRect.origin.y -= 2.0f;
    txtPassword.frame = pwdRect;
    
    UIImage *loginButtonImage = [UIImage imageNamed:@"buttonLong_Login"];
    loginButton.frame  = CGRectMake((kSCREN_BOUNDS.size.width - loginButtonImage.size.width)/2 , pwdRect.origin.y + 50.0f, loginButtonImage.size.width, loginButtonImage.size.height);
    [loginButton setBackgroundImage:loginButtonImage forState:UIControlStateNormal];
    
    statementLabel.text = STATEMENTString;
    statementLabel.font = kFont_Light_14;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /// -- 检测版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:app_Version forKey:@"CUSTOMER_APPVERSION"];
    _loginArray = [[NSMutableArray alloc] init];
    [self initeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"CUSTOMER_DATABASE"];
    AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
    if(!appDelegate.isLogin)
        [self requestAppVersion];
    
    txtUserName.text = ACC_LAST_LoginMoblie;//载入上次输入的账号
    //键盘显示、隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [txtPassword setText:@""];//退出界面时清空密码
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - init
- (void)initeView
{
    if ((IOS7 || IOS8)) {
        bgImageView.image = [UIImage imageNamed:@"login_bg-568h@2x"];
    }
    
    //初始化登录框
    txtUserName.placeholder = @"登录名（手机号）";
    txtUserName.font = kFont_Light_16;
    txtUserName.keyboardType = UIKeyboardTypeNumberPad;
    txtUserName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    txtUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 添加textColor值为黑色
    txtUserName.textColor = [UIColor blackColor];
    txtUserName.tag = 100;
    
    //初始化密码框
    txtPassword.placeholder = @"登录密码";
    txtPassword.font = kFont_Light_16;
    txtPassword.keyboardType = UIKeyboardTypeDefault;
    txtPassword.returnKeyType=UIReturnKeyDone;
    txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 添加textColor值为黑色
    txtPassword.textColor = [UIColor blackColor];
    txtPassword.tag = 101;
    
}

#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [textField_Selected resignFirstResponder];//隐藏键盘
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.textField_Selected = textField;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == txtUserName) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"ACC_LAST_LoginMoblie"];
    }
    return YES;
}

-(void)textFiledEditDidChanged:(NSNotification *)obj
{
    if(textField_Selected.text.length > 20)
        textField_Selected.text = [NSString stringWithString:[textField_Selected.text substringToIndex:20]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //if ([txtUserName.text length] != 0 && [txtPassword.text length] != 0) {
    //    [self performSelector:@selector(login:) withObject:nil afterDelay:0.0f];
    //}
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@ = %d", string, *ch);
    
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    if ([textField.text length] >= 20) {
        return NO;
    }
    
    __block BOOL result = YES;
    if (textField.tag == 100) {
        [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            if ([substring rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
                result = NO;
                *stop = YES;
            }
        }];
    }
    return result;
}

#pragma mark - overwrite
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardValue getValue:&keyboardRect];
    
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect cursorRect = [self.textField_Selected caretRectForPosition:self.textField_Selected.selectedTextRange.start];
    CGRect tmpCursorRect = [self.view convertRect:cursorRect fromView:self.textField_Selected];
    
    
    DLOG(@"%f", tmpCursorRect.origin.y + tmpCursorRect.size.height + 10.0f);
    if (tmpCursorRect.origin.y + tmpCursorRect.size.height + 30.0f > keyboardRect.origin.y) {
        [UIView beginAnimations:@"showKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        CGRect rect = self.view.frame;
        
        rect.origin.y = - (tmpCursorRect.origin.y + tmpCursorRect.size.height + 15.0f - keyboardRect.origin.y);
        self.view.frame = rect;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if (IOS6) {
        if (self.view.frame.origin.y != 20) {
            [UIView beginAnimations:@"showKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            CGRect rect = self.view.frame;
            rect.origin.y = 20.0f;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    } else {
        if (self.view.frame.origin.y != 0) {
            [UIView beginAnimations:@"showKeyboard" context:nil];
            [UIView setAnimationDuration:animationDuration];
            CGRect rect = self.view.frame;
            rect.origin.y = 0.0f;
            self.view.frame = rect;
            [UIView commitAnimations];
        }
    }
}

#pragma mark - CustomMethod
- (IBAction)login:(id)sender
{
    if ([txtUserName.text length] < 1 ) {
        [SVProgressHUD showErrorWithStatus2:@"请输入用户名" touchEventHandle:^{}];
        return;
    } else if ( [txtPassword.text length] < 1) {
        [SVProgressHUD showErrorWithStatus2:@"请输入密码" touchEventHandle:^{}];
        return;
    }
    [self.view endEditing:YES];
    [self requestLogin];
}

#pragma mark - 接口
- (void)requestLogin
{
    self.view.userInteractionEnabled = NO;
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"Account_GPBasicURLString"];
    
    // 版本更新 和 获取NewCount信息
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"VERSION_UPDATE"] boolValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"版本发生重大改变,请下载更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
        }];
        return;
    }
    
    __block NSString *userName = [[txtUserName text] stringByTrimmingTrailEmpty];
    __block NSString *userPwd  = [[txtPassword text] stringByTrimmingTrailEmpty];
    
    if ([userName isEqualToString:@""]) {
        [SVProgressHUD showSuccessWithStatus2:@"请输入登录账号" touchEventHandle:^{}];
    }
    
    if ([userName isEqualToString:@""]) {
        [SVProgressHUD showSuccessWithStatus2:@"请输入密码" touchEventHandle:^{}];
    }
    RSA   *rsaPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [rsaPublicKey extractPublicFromCertificateFile:certPath];
    NSString *name = [rsaPublicKey RSAEncryptByPublicKeyWithString:userName];
    NSString *pwd = [rsaPublicKey RSAEncryptByPublicKeyWithString:userPwd];

    [self requestLoginWithUserName:name userPwd:pwd];

    /*
    [[GPHTTPClient shareClient] requestAccountLoginWithMobile:userName passwd:userPwd success:^(id xml) {
        //[SVProgressHUD dismiss];
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
            [self requestLoginWithUserName:userName userPwd:userPwd errorMsg:resultMsgStr];
            
        }else{
            origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
            
            NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
            if ((NSNull *)dataDic == [NSNull null] || dataDic.count == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
                [self requestLoginWithUserName:userName userPwd:userPwd errorMsg:resultMsgStr];
            }else{
                NSArray *data = [dataDic objectForKey:@"Data"];
                int code = [[dataDic objectForKey:@"Code"] intValue];
                
                if([[dataDic objectForKey:@"Code"] integerValue] == 1)
                {
                    [self setAccountDataJson:data];
                }else {
                    if([[dataDic objectForKey:@"Code"] integerValue] == -1)
                        [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
                    else if (code == -3) //[[dataDic objectForKey:@"Code"] integerValue]
                    {
                        if ([SVProgressHUD isVisible]) {
                            [SVProgressHUD dismiss];
                        }
                        self.view.userInteractionEnabled = YES;
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                            }
                        }];
                    }
                    else{
                        resultMsgStr = [dataDic objectForKey:@"Message"];
                        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
                        [self requestLoginWithUserName:userName userPwd:userPwd errorMsg:resultMsgStr];
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
        [self requestLoginWithUserName:userName userPwd:userPwd errorMsg:resultMsgStr];
    }];
     */

}

- (void)requestLoginWithUserName:(NSString *)rsaName userPwd:(NSString *)rsaPwd {

    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *str = [NSString stringWithFormat:@"{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"ImageHeight\":%d,\"ImageWidth\":%d}", rsaName, rsaPwd, 160, 160];

    __unused AFHTTPRequestOperation *request = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList" andParameters:str failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            if (!data) {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
                [self requestLoginWithUserName:rsaName userPwd:rsaPwd messageString:message];
                
            } else {
                [PermissionDoc saveUserRsa:rsaName andPassword:rsaPwd];
                [self setAccountDataJson:data];
            }
        } failure:^(NSInteger code, NSString *error) {
            if (code == -3)
            {
                self.view.userInteractionEnabled = YES;
                
                if ([SVProgressHUD isVisible]) {
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                    }
                }];
            }else if( code == -1 || code == 0){
                self.view.userInteractionEnabled = YES;
                //                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
                [SVProgressHUD showErrorWithStatus2:@"账户或密码错误，请重新输入！" touchEventHandle:^{}];
                
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
                [self requestLoginWithUserName:rsaName userPwd:rsaPwd messageString:error];

            }
        }];
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"Account_GPBasicURLString"];
        [self requestLoginWithUserName:rsaName userPwd:rsaPwd messageString:error.localizedDescription];
    }];
}

- (void)requestLoginWithUserName:(NSString *)rsaName userPwd:(NSString *)rsaPwd messageString:(NSString *)message {
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *str = [NSString stringWithFormat:@"{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"ImageHeight\":%d,\"ImageWidth\":%d}", rsaName, rsaPwd, 160, 160];
    
    __unused AFHTTPRequestOperation *request = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList" andParameters:str failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            if (!data) {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
                [self requestLoginDemoWithUserName:rsaName userPwd:rsaPwd messageString:message];
            } else {
                
                [PermissionDoc saveUserRsa:rsaName andPassword:rsaPwd];
                [self setAccountDataJson:data];
            }
        } failure:^(NSInteger code, NSString *error) {
            
//            if( code == -1 || code == 0)
//                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
             if (code == -3)
            {
                self.view.userInteractionEnabled = YES;
                
                if ([SVProgressHUD isVisible]) {
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                    }
                }];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
                [self requestLoginDemoWithUserName:rsaName userPwd:rsaPwd messageString:error];
            }
            
        }];
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
        [self requestLoginDemoWithUserName:rsaName userPwd:rsaPwd messageString:error.localizedDescription];
    }];
}

- (void)requestLoginDemoWithUserName:(NSString *)rsaName userPwd:(NSString *)rsaPwd messageString:(NSString *)message {
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *str = [NSString stringWithFormat:@"{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"ImageHeight\":%d,\"ImageWidth\":%d}", rsaName, rsaPwd, 160, 160];
    
    __unused AFHTTPRequestOperation *request = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList" andParameters:str failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            
            self.view.userInteractionEnabled = YES;

            if (!data) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取公司失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            } else {
                [PermissionDoc saveUserRsa:rsaName andPassword:rsaPwd];
                [self setAccountDataJson:data];
            }
        } failure:^(NSInteger code, NSString *error) {
            
            self.view.userInteractionEnabled = YES;

            if( code == -1 || code == 0)
//                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
                [SVProgressHUD showErrorWithStatus2:@"账户或密码错误，请重新输入！" touchEventHandle:^{}];
            else if (code == -3)
            {
                
                if ([SVProgressHUD isVisible]) {
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
            }
            
        }];
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
        if (message.length) {
            [SVProgressHUD showErrorWithStatus2:message touchEventHandle:^{}];
        }
    }];

}
/*
- (void)requestLoginWithUserName:(NSString *)userName userPwd:(NSString *)userPwd errorMsg:(NSString *)errorMsg
{
    __block NSString *resultMsgStr = nil;
    [[GPHTTPClient shareClient] requestAccountLoginWithMobile:userName passwd:userPwd success:^(id xml) {
        
        //[SVProgressHUD dismiss];
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
            [self requestLoinWithTest:userName userPwd:userPwd errorMsg:resultMsgStr];
        }else{
            origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count] - 1]).range.location + 1)];
            
            NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
            if ((NSNull *)dataDic == [NSNull null] || dataDic.count == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
                [self requestLoinWithTest:userName userPwd:userPwd errorMsg:resultMsgStr];
            }else{
                NSArray *data = [dataDic objectForKey:@"Data"];
                if ((NSNull *)data == [NSNull null] || data.count == 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
                    [self requestLoinWithTest:userName userPwd:userPwd errorMsg:resultMsgStr];
                }else{
                    if([[dataDic objectForKey:@"Code"] integerValue] == 1)
                    {
                        [self setAccountDataJson:data];
                    }else {
                        if([[dataDic objectForKey:@"Code"] integerValue] == -1)
                            [SVProgressHUD showErrorWithStatus2:[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
                        else if ([[dataDic objectForKey:@"Code"] integerValue] == -3)
                        {
                            self.view.userInteractionEnabled = YES;

                            if ([SVProgressHUD isVisible]) {
                                [SVProgressHUD dismiss];
                            }
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                if (buttonIndex == 0) {
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                                }
                            }];
                        } else{
                            resultMsgStr = [dataDic objectForKey:@"Message"];
                            [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
                            [self requestLoinWithTest:userName userPwd:userPwd errorMsg:resultMsgStr];
                        }
                    }
                }
            }
        }
    }failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"Account_GPBasicURLString"];
        [self requestLoinWithTest:userName userPwd:userPwd errorMsg:resultMsgStr];
    }];
}


- (void)requestLoinWithTest:(NSString *)userName userPwd:(NSString *)userPwd errorMsg:(NSString *)errorMsg
{
    [[GPHTTPClient shareClient] requestAccountLoginWithMobile:userName passwd:userPwd success:^(id xml) {
        //[SVProgressHUD dismiss];
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取公司失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            self.view.userInteractionEnabled = YES;
            return;
        }
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        if ((NSNull *)dataDic == [NSNull null] || dataDic.count == 0) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取公司失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            self.view.userInteractionEnabled = YES;
            return;
        }
        NSArray *data = [dataDic objectForKey:@"Data"];
        if ((NSNull *)data == [NSNull null] || data.count == 0) {
            [SVProgressHUD showErrorWithStatus2:(NSString*)[dataDic objectForKey:@"Message"] touchEventHandle:^{}];
            self.view.userInteractionEnabled = YES;
            return;
        }
        [self setAccountDataJson:data];
    } failure:^(NSError *error) {
        if (errorMsg.length > 0) {
            [SVProgressHUD showErrorWithStatus2:errorMsg touchEventHandle:^{}];
        }
        self.view.userInteractionEnabled = YES;
    }];
}
*/

- (void)setAccountDataJson:(NSArray *)data
{
    NSMutableArray *mutableData = [NSMutableArray array]; //解决BranchList 为null崩溃的问题
    
    if(_loginArray)
        [ _loginArray removeAllObjects];
    else
        _loginArray = [[NSMutableArray alloc] init];
    
    NSInteger branchCount = 0;
    NSInteger companyCount = 0;
    for(NSDictionary *obj in data){
        NSMutableDictionary *mutableObj = [NSMutableDictionary dictionaryWithDictionary:obj]; //解决BranchList 为null崩溃的问题
        LoginDoc *loginDoc = [[LoginDoc alloc]init];
        loginDoc.accountId = [[obj objectForKey:@"AccountID"] integerValue];
        loginDoc.companyId = [[obj objectForKey:@"CompanyID"] integerValue];
        loginDoc.branchCount  = [[obj objectForKey:@"BranchCount"] integerValue];  // BranchID == 0 则没有BranchID
        loginDoc.userName  = [obj objectForKey:@"AccountName"];
        loginDoc.headImg   = [obj objectForKey:@"HeadImageURL"];
        loginDoc.companyCode = [obj objectForKey:@"CompanyCode"];
        loginDoc.companyScale = [[obj objectForKey:@"CompanyScale"] integerValue];  // 0小店  1大店
        loginDoc.moneyIcon = [obj objectForKey:@"CurrencySymbol"];
        loginDoc.advanced = [obj objectForKey:@"Advanced"];
        loginDoc.companyAbbreviation = [obj objectForKey:@"CompanyAbbreviation"];
        loginDoc.isComissionCalc = [obj objectForKey:@"IsComissionCalc"];
        loginDoc.branchList = [NSMutableArray array];
        NSArray *branchArray = [obj objectForKey:@"BranchList"];
        if ((NSNull *)branchArray == [NSNull null]){
            [mutableObj setValue:nil forKey:@"BranchList"];
            branchArray = nil;
        }
        for (NSDictionary * branch in branchArray){
            BranchDoc *branchDoc = [[BranchDoc alloc] init];
            branchDoc.branchId = [[branch objectForKey:@"BranchID"] integerValue];
            branchDoc.branchName = [branch objectForKey:@"BranchName"];
            [loginDoc.branchList addObject:branchDoc];
            branchCount ++;
        }
        [mutableData addObject:mutableObj];
        companyCount ++;
        [_loginArray addObject:loginDoc];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:@"ACCOUNT_COMPANYLIST"]; //解决BranchList 为null崩溃的问题
    
    if (branchCount == 1 && companyCount == 1) { //一个公司一个门店
        LoginDoc *loginDoc = [_loginArray objectAtIndex:0];
        loginDoc.branchID = [[loginDoc.branchList objectAtIndex:0] branchId];
        //重置权限
        PermissionDoc *permissonDoc = [PermissionDoc sharePermission];
        [permissonDoc resetPermission:[loginDoc advanced]];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"OrderTotalSalePrice_Write"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Money_Out"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.isComissionCalc forKey:@"current_isComissionCalc"];
        [self updateLoginInfoForAccount:loginDoc];
    }else{
        [SVProgressHUD dismiss];
        [self performSegueWithIdentifier:@"goChooseCompanyViewFromLoginView" sender:self];
    }
}

-(void)updateLoginInfoForAccount:(LoginDoc *)loginDoc{

    
    [SVProgressHUD setStatus:@"Loading"];
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    
    NSString *par = [NSString stringWithFormat:@"{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"DeviceID\":\"%@\",\"DeviceModel\":\"%@\",\"OSVersion\":\"%@\",\"BranchID\":%ld,\"CompanyID\":%ld,\"APPVersion\":\"%@\",\"ClientType\":%d,\"DeviceType\":%d,\"UserID\":%ld,\"IsNormalLogin\":%d}", ACC_RSAUSERID, ACC_RSAPWD, deviceToken ? deviceToken : @"", [DeviceInfoManager DeviceInfoOfType], [[UIDevice currentDevice] systemVersion], (long)loginDoc.branchID, (long)loginDoc.companyId, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 1, 1, (long)loginDoc.accountId, YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.accountId] forKey:@"ACCOUNT_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.companyId] forKey:@"ACCOUNT_COMPANTID"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.branchID]  forKey:@"ACCOUNT_BRANCHID"];

    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/updateLoginInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [loginDoc loginParameterUserConfig];
            //设置默认时间
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"ACCOUNT_INDATE": @30}];
            
            // --Role permission
            PermissionDoc *permissonDoc = [PermissionDoc sharePermission];
            if(data){ // && data.count != 0
                NSString *sourceString = [data objectForKey:@"Role"];/*@"|1|2|3|4|5|6|7|12|13|11|21|121|35|21|1|22|30|90|12|0|9|28|29|8|15|16|17|32|33|34|";*/
                if(sourceString){
                    [permissonDoc setPermission:sourceString];
                    permissonDoc.record_marketing_oppotun = loginDoc.advanced;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_OrderTotalSalePrice_Write ] forKey:@"OrderTotalSalePrice_Write"];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_Money_Out ] forKey:@"Money_Out"];
                }
                permissonDoc.userGUID = [data objectForKey:@"GUID"];
            }
            
            [self performSegueWithIdentifier:@"goInitialSlidingViewFromLoginView" sender:self];
            self.view.userInteractionEnabled = YES;
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            appDelegate.isLogin = YES;

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取登录信息失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            self.view.userInteractionEnabled = YES;
            
        }];
        
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
    }];
    
    /*
    [[GPHTTPClient shareClient] requestLoginInfoForAccount:loginDoc success:^(id xml) {
        [SVProgressHUD dismiss];
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取登录信息失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            self.view.userInteractionEnabled = YES;
            return;
        }
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        if ((NSNull *)dataDictionary == [NSNull null] || dataDictionary.count == 0) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取登录信息失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            self.view.userInteractionEnabled = YES;
            [alertView show];
            return;
        }
        NSDictionary *dataDic = [dataDictionary objectForKey:@"Data"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.accountId] forKey:@"ACCOUNT_USERID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.companyId] forKey:@"ACCOUNT_COMPANTID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.branchID]  forKey:@"ACCOUNT_BRANCHID"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.companyCode forKey:@"ACCOUNT_COMPANTCODE"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.userName forKey:@"ACCOUNT_NAME"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.headImg forKey:@"ACCOUNT_HEADIMAGE"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.companyScale] forKey:@"ACCOUNT_COMPANTSCALE"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"SettlementCurrency"];
        [[NSUserDefaults standardUserDefaults] setObject:(loginDoc.moneyIcon ? loginDoc.moneyIcon : @"¥") forKey:@"ACCOUNT_CURRENCY_ICON"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.advanced forKey:@"ACCOUNT_ADVANCED"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.companyAbbreviation forKey:@"ACCOUNT_COMPANYABBREVIATION"];
        
        //设置默认登录时间
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"ACCOUNT_INDATE": @30}];

        // --Role permission
        PermissionDoc *permissonDoc = [PermissionDoc sharePermission];
        if((NSNull *)dataDic != [NSNull null] && dataDic.count != 0){
            NSString *sourceString = [dataDic objectForKey:@"Role"]; @"|1|2|3|4|5|6|7|12|13|11|21|121|35|21|1|22|30|90|12|0|9|28|29|8|15|16|17|32|33|34|";*/
    /*   if(sourceString){
                [permissonDoc setPermission:sourceString];
                permissonDoc.record_marketing_oppotun = loginDoc.advanced;
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_OrderTotalSalePrice_Write ] forKey:@"OrderTotalSalePrice_Write"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_Money_Out ] forKey:@"Money_Out"];
            }
        }
        [self performSegueWithIdentifier:@"goInitialSlidingViewFromLoginView" sender:self];
        self.view.userInteractionEnabled = YES;
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.isLogin = YES;
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
    }];

*/
    
}

#pragma mark - ChangePage

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     
    if ([segue.identifier isEqualToString:@"goChooseCompanyViewFromLoginView"]) {
        self.view.userInteractionEnabled = YES;
        ChooseCompanyViewController *detailController = segue.destinationViewController;
        detailController.loginArray = _loginArray;
        detailController.loginType = YES;
    }
}
/*
 // 获取新消息的条目
 - (void)requestTheTotalCountOfNewMessage
 {
 [[GPHTTPClient shareClient] requestTheTotalCountOfNewMessageWithSuccess:^(id xml) {
 [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[[contentData elementsForName:@"Count"] objectAtIndex:0] stringValue] integerValue]];
 } failure:^{}];
 
 } failure:^(NSError *error) {}];
 }*/

// 获取程序最新版本
- (void)requestAppVersion
{
    // self.view.userInteractionEnabled = NO;
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Version/getServerVersion" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            BOOL mustUpFlag = [[data objectForKey:@"MustUpgrade"] boolValue];
            NSString *version = [data objectForKey:@"Version"];
            
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            appDelegate.isShowVersionUpdate = 0;
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpFlag == NO && appDelegate.isShowVersionUpdate < 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                    appDelegate.userChoice = YES;
                } else if(appDelegate.isShowVersionUpdate < 1){
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
            }
            appDelegate.isNeedGetVersion = YES;
        } failure:^(NSInteger code, NSString *error) {}];
    } failure:^(NSError *error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//        [alert show];
        
    }];
    
    /*
    [[GPHTTPClient shareClient] requestGetVersionWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:Nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            NSString *version = [[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue] == nil ? @"":[[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue];
            NSInteger mustUpgrade = [[[[contentData elementsForName:@"MustUpgrade"] objectAtIndex:0] stringValue] integerValue];
            appDelegate.isShowVersionUpdate = 0; //需要显示升级提示框（解决不点击升级框，直接切换到后台后再激活程序，会多次弹出升级框）
            // if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTCOME"] integerValue] == 1){
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpgrade == 0 && appDelegate.isShowVersionUpdate < 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                        }
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                    appDelegate.userChoice = YES;
                } else if(appDelegate.isShowVersionUpdate < 1){
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                        }
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
            }
            //}
            appDelegate.isNeedGetVersion = YES;
            
            // self.view.userInteractionEnabled = YES;
        } failure:^{}];
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // exit(0);
        }];
    }];
     */
}
@end
