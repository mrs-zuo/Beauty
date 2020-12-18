//
//  ResetPasswordViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "InitialSlidingViewController.h"
#import "UIButton+InitButton.h"
#import "UITextField+InitLabel.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "NSString+Additional.h"
#import "LoginDoc.h"
#import "AppDelegate.h"
#import "RSA.h"
#import "LoginViewController.h"

@interface ResetPasswordViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestChangeCustomerPasswordOperation;
@property (nonatomic) UITextField *txtPassword;
@property (nonatomic) UITextField *txtPasswordAgain;
@property (strong, nonatomic) RSA *RSAPublicKey;
@end

@implementation ResetPasswordViewController
@synthesize loginArray;
@synthesize txtPassword;
@synthesize txtPasswordAgain;

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
    self.isOnlyShowBackButton = YES;
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init

- (void)initView
{
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"密码重置"]];
    
    self.title = @"密码重置";

    UILabel *pwLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 60.0f - 20, 70.0f, 33.0f)];
    pwLabel.backgroundColor = [UIColor clearColor];
    pwLabel.font = kFont_Light_16;
    pwLabel.text = @"新密码";
    pwLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:pwLabel];
    
    UIImageView *pwImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 60 - 20, 200.0f, 33.0f)];
    pwImage.image = [UIImage imageNamed:@"findPassword"];
    [self.view addSubview:pwImage];
    txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(105, 60 - 20, 195.0f, 33.0f)];
    txtPassword.backgroundColor = [UIColor clearColor];
    txtPassword.placeholder = @"";
    txtPassword.font = kFont_Light_16;
    txtPassword.textColor = kColor_Editable;
    txtPassword.secureTextEntry = YES;
    txtPassword.keyboardType = UIKeyboardTypeDefault;
    txtPassword.returnKeyType=UIReturnKeyDone;
    txtPassword.delegate = self;
    txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:txtPassword];
    txtPassword.text = @"";
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 85.0f - 20, 200.0f, 45.0f)];
    textLabel.font = kFont_Light_10;
    textLabel.text = @"请输入6-20位新密码";
    textLabel.numberOfLines = 0;
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textLabel];
    
    UILabel *pwaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 140.0f - 20, 70.0f, 33.0f)];
    pwaLabel.font = kFont_Light_16;
    pwaLabel.text = @"再次输入";
    pwaLabel.textAlignment = NSTextAlignmentRight;
    pwaLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pwaLabel];
    
    UIImageView *pwaImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 140 - 20, 200.0f, 33.0f)];
    pwaImage.image = [UIImage imageNamed:@"findPassword"];
    [self.view addSubview:pwaImage];
    txtPasswordAgain = [[UITextField alloc] initWithFrame:CGRectMake(105, 140 - 20, 195.0f, 33.0f)];
    txtPasswordAgain.backgroundColor = [UIColor clearColor];
    txtPasswordAgain.placeholder = @"";
    txtPasswordAgain.font = kFont_Light_16;
    txtPasswordAgain.textColor = kColor_Editable;
    txtPasswordAgain.secureTextEntry = YES;
    txtPasswordAgain.keyboardType = UIKeyboardTypeDefault;
    txtPasswordAgain.returnKeyType=UIReturnKeyDone;
    txtPasswordAgain.delegate = self;
    txtPasswordAgain.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPasswordAgain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:txtPasswordAgain];
    txtPasswordAgain.text = @"";
    
    UIButton *cancelButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(cancelAction)
                                                 frame:CGRectMake(20.0f, 190.0f - 20, 130.0f, 32.0f)
                                         backgroundImg:[UIImage imageNamed:@"cancelbth"]
                                      highlightedImage:nil];
    [self.view addSubview:cancelButton];
    
    UIButton *finishButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(requesChangeCustomerPassword)
                                                 frame:CGRectMake(170.0f, 190.0f - 20, 130.0f, 32.0f)
                                         backgroundImg:[UIImage imageNamed:@"finishbth"]
                                      highlightedImage:nil];
    [self.view addSubview:finishButton];
    
    if ((IOS7 || IOS8)) {
        [txtPassword setTintColor:[UIColor blueColor]];
        [txtPasswordAgain setTintColor:[UIColor blueColor]];
    }
}

#pragma mark - button

- (void)cancelAction
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissKeyboard" object:nil];
       UIViewController *viewController = self;
    while(viewController.presentingViewController) {
        viewController = viewController.presentingViewController;
    }
    if(viewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [txtPassword resignFirstResponder];
    [txtPasswordAgain resignFirstResponder];
}

#pragma mark - textField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= 20){
        return NO;
    }
    return YES;
}

#pragma mark - 接口

- (void)requesChangeCustomerPassword
{
    NSString *userPwd = [[txtPassword text] stringByTrimmingTrailEmpty];
    NSString *userPwdA = [[txtPasswordAgain text] stringByTrimmingTrailEmpty];
    [self.view endEditing:YES];
    
    if ([userPwd isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入新密码"];
        return;
    }
    
    if ([userPwdA isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请再次输入新密码"];
        return;
    }
    
    if (userPwd.length < 6 || userPwd.length > 20) {
        [SVProgressHUD showErrorWithStatus2:@"新密码长度6~20位"];
        return;
    }
    
    if (![userPwd isEqualToString:userPwdA]) {
        [SVProgressHUD showErrorWithStatus2:@"两次密码不同"];
        return;
    }
    NSMutableString *str = [NSMutableString string];
    for (LoginDoc *login in loginArray) {
        if ([loginArray lastObject]  == login)
            [str appendFormat:@"%ld",(long)login.login_CustomerID];
        else
            [str appendFormat:@"%ld,",(long)login.login_CustomerID];
    }
    _RSAPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [_RSAPublicKey extractPublicFromCertificateFile:certPath];

    NSDictionary *para = @{@"CustomerIDs":str,
                           @"LoginMobile":[_RSAPublicKey RSAEncryptByPublicKeyWithString:_loginMobile],
                           @"Password":[_RSAPublicKey RSAEncryptByPublicKeyWithString:txtPassword.text],
                           @"ImageWidth":@160,
                           @"ImageHeight":@160};
    _requestChangeCustomerPasswordOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/login/updateCustomerPassword"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码修改成功，请重新登录！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } failure:^(NSError *error) {
        
    }];
//    _requestChangeCustomerPasswordOperation = [[GPHTTPClient shareClient] requestUpdateCustomerPasswordWithCustomerID:str LoginMobile:_loginMobile NewPassword:txtPassword.text success:^(id xml) {
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData) {
//            
//            UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码修改成功，请重新登录！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        } failure:^{
//        }];
//    } failure:^(NSError *error) {
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DISCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYSCALE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PROMOTION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_REMINDCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DATABASE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYLIST"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CONFIRMCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_ADVANCED"];
    
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginVC animated:YES completion:^{
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.isNeedGetVersion = NO;
    }];
    
//    double delayInSeconds = 0.2f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        //循环查找最底层模态视图，再退出
//        UIViewController *viewController = self;
//        while(viewController.presentingViewController) {
//            viewController = viewController.presentingViewController;
//        }
//        if(viewController) {
//            [viewController dismissViewControllerAnimated:YES completion:nil];
//            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
//            appDelegate.isNeedGetVersion = NO;
//        }
//    });
    
    
    
}



@end
