//
//  LoginViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-1.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "LoginViewController.h"
#import "InitialSlidingViewController.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "NSString+Additional.h"
#import "UITextField+InitLabel.h"
#import "SalesPromotionDoc.h"
#import "UIButton+InitButton.h"
#import "LoginDoc.h"
#import "ChooseCompanyViewController.h"
#import "noCopyTextField.h"
#import "AppDelegate.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "GPCHTTPClient.h"
#import "RSA.h"
#import "UUID.h"
#import "DeviceInfoManager.h"
#import "SalesPromotionViewController.h"
#import "IndexViewController.h"
#import "ZXTabBarController.h"
#import "IndexViewController.h"



#define LAST_LOGIN_CUSTOMID @"LAST_LOGIN_CUSTOMID"

@interface LoginViewController ()
{
    NSInteger textFieldY;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestLoginOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestLoginAgainOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getVersionOperation;
@property (nonatomic) UIButton *changePasswordButton;
@property (nonatomic) UITextField *txtUserName;
@property (nonatomic) noCopyTextField *txtPassword;
@property (strong, nonatomic) NSMutableArray *loginArray;
@property (strong, nonatomic) RSA *RSAPublicKey;
@property (copy, nonatomic)NSString *nameBase64;
@property (copy, nonatomic)NSString *pwdBase64;

@end

@implementation LoginViewController
@synthesize txtUserName;
@synthesize txtPassword;
@synthesize changePasswordButton;
@synthesize loginArray;

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
    [_imageView setFrame:self.view.bounds];
    
    if (kSCREN_BOUNDS.size.height > 480) {
        //        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
        //        [stateView setBackgroundColor:[UIColor blackColor]];
        //        [self.view addSubview:stateView];
        _imageView.image = [UIImage imageNamed:@"login_640x1096"];
        //[self.view addSubview:_imageView];
    } else {
        [self.view setFrame:CGRectMake(0.0f, 0.0f, 320.0f, kSCREN_BOUNDS.size.height)];
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:app_Version forKey:@"CUSTOMER_APPVERSION"];
    _RSAPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [_RSAPublicKey extractPublicFromCertificateFile:certPath];
    
    //_imageView.image = [UIImage imageNamed:@"loginbg.png"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"CUSTOMER_DATABASE"];
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
    if(!appDelegate.isLogin)
        [self requestAppVersion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self autoLogin];
}
-(void)autoLogin
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
    NSString *userPwd  =[defaults objectForKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
    if ((userPwd == nil) || (userName == nil)) {
        [self initView];
    } else {
        _nameBase64=userName;
        _pwdBase64=userPwd;
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isAutoLogin"];
        [self requestLogin];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (_requestLoginOperation || [_requestLoginOperation isExecuting]) {
        [_requestLoginOperation cancel];
        _requestLoginOperation = nil;
    }
    
    if (_requestLoginAgainOperation || [_requestLoginAgainOperation isExecuting]) {
        [_requestLoginAgainOperation cancel];
        _requestLoginAgainOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
}

- (void)initView
{
    UIButton *login_Button = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(login)
                                                 frame:CGRectMake((320-240)/2-3, kSCREN_BOUNDS.size.height/2+75, 240.0f, 40.0f)
                                         backgroundImg:[UIImage imageNamed:@"LoginButtonClient"]
                                      highlightedImage:nil];
    [self.view addSubview:login_Button];
    
    UILabel *login_Find = [[UILabel alloc] initWithFrame:CGRectMake((320-50)/2, kSCREN_BOUNDS.size.height/2+120, 50.0f, 20.0f)];
    login_Find.text = @"忘记密码？";
    login_Find.font = kFont_Light_10;
    login_Find.backgroundColor = [UIColor clearColor];
    login_Find.userInteractionEnabled = YES;
    login_Find.textColor = [UIColor grayColor];
    [self.view addSubview:login_Find];
    UITapGestureRecognizer *tapGestureRecognozer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FindPassword)];
    tapGestureRecognozer.numberOfTapsRequired = 1;
    tapGestureRecognozer.numberOfTouchesRequired = 1;
    [login_Find addGestureRecognizer:tapGestureRecognozer];
    
    UIImageView *userNameImage = [[UIImageView alloc] initWithFrame:CGRectMake((320-245)/2, kSCREN_BOUNDS.size.height/2-10, 245.0f, 34.0f)];
    userNameImage.image = [UIImage imageNamed:@"logininput-username"];
    [self.view addSubview:userNameImage];
    
    UIImageView *passWordImage = [[UIImageView alloc] initWithFrame:CGRectMake((320-245)/2, kSCREN_BOUNDS.size.height/2+30, 245.0f, 34.0f)];
    passWordImage.image = [UIImage imageNamed:@"logininput-password"];
    [self.view addSubview:passWordImage];
    
    self.txtUserName = [[UITextField alloc] initWithFrame:CGRectMake((320-245)/2+30, kSCREN_BOUNDS.size.height/2-11.5, 210.0f, 34.0f)];
    self.txtUserName.placeholder = @"登录名（手机号）";
    self.txtUserName.font = kFont_Light_16;
    self.txtUserName.textColor = kColor_Editable;
    self.txtUserName.delegate = self;
    self.txtUserName.keyboardType = UIKeyboardTypeNumberPad;
    self.txtUserName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtUserName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:txtUserName];
    self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOGIN_CUSTOMID];
    AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
    if (self.txtUserName.text)
        appDelegate.loginMobile = [NSString stringWithString: self.txtUserName.text];
    
    self.txtPassword = [[noCopyTextField alloc] initWithFrame:CGRectMake((320-245)/2+30, kSCREN_BOUNDS.size.height/2+28, 210.0f, 34.0f)];
    self.txtPassword.placeholder = @"登录密码";
    self.txtPassword.font = kFont_Light_16;
    self.txtPassword.textColor = kColor_Editable;
    self.txtPassword.secureTextEntry = YES;
    self.txtPassword.keyboardType = UIKeyboardTypeDefault;
    self.txtPassword.returnKeyType=UIReturnKeyDone;
    self.txtPassword.delegate = self;
    self.txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:txtPassword];
    self.txtPassword.text = @"";
    
    if ((IOS7 || IOS8)) {
        [self.txtUserName setTintColor:[UIColor blueColor]];
        [self.txtPassword setTintColor:[UIColor blueColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"in");
    
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    NSInteger offset = 0;
    
    if ((IOS7 || IOS8)) {
        offset = 0;//状态栏高度
    } else {
        offset = 20;//状态栏高度
    }
    
    if (textFieldY > keyboardBounds.origin.y) {
        offset = offset + keyboardBounds.origin.y - textFieldY;
    }
    [UIView beginAnimations:@"anim" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    CGRect listFrame = CGRectMake(0.0f, offset, self.view.frame.size.width, self.view.frame.size.height);//处理移动事件，将各视图设置最终要达到的状态
    self.view.frame = listFrame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"out");
    
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [self.txtUserName resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

#pragma mark - 页面切换

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goInitialSlidingViewFromLoginView"]) {
        InitialSlidingViewController *inistialController = segue.destinationViewController;
        //  if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_PROMOTION"] integerValue] != 0) {
        inistialController.tagetView = @"PtomotionNavigation";
        // } else {
        //     inistialController.tagetView = @"FirstTopNavigation";
        //  }
    }
    
    if ([segue.identifier isEqualToString:@"goChooseCompanyViewFromLoginView"]) {
        ChooseCompanyViewController *detailController = segue.destinationViewController;
        detailController.loginArray = loginArray;
        detailController.nameBase64 = _nameBase64;
        detailController.pwdBase64 = _pwdBase64;
        detailController.loginType = YES;
    }
}

#pragma mark - button

- (void)login
{
    NSString *userName = [[txtUserName text] stringByTrimmingTrailEmpty];
    NSString *userPwd = [[txtPassword text] stringByTrimmingTrailEmpty];
    if ([userName isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入登录账号"];
        return;
    }
    
    if ([userPwd isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入密码"];
        return;
    }
    _nameBase64 = [_RSAPublicKey RSAEncryptByPublicKeyWithString:userName];
    _pwdBase64 = [_RSAPublicKey RSAEncryptByPublicKeyWithString:userPwd];
    
    [self  requestLogin];
}

- (void)FindPassword
{
    [self performSegueWithIdentifier:@"goFindPasswordViewFromLoginView" sender:self];
}

#pragma mark - textFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ((IOS7 || IOS8)) {
        textFieldY = textField.frame.origin.y + textField.frame.size.height + 0;
    }else {
        textFieldY = textField.frame.origin.y + textField.frame.size.height + 20;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == txtUserName) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:LAST_LOGIN_CUSTOMID];
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.loginMobile = [NSString stringWithString:textField.text];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    //if (*ch == 32) return NO;
    if ([textField.text length] >= 20) {
        return NO;
    }
    return YES;
}

#pragma mark - 状态栏颜色，状态

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - 接口


- (void)requestLogin
{
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"CUSTOMER_DATABASE"];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"LoginMobile":_nameBase64,
                           @"Password":_pwdBase64,
                           @"ImageHeight":@160,
                           @"ImageWidth":@160
                           };
    
    _requestLoginOperation =  [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList"  showErrorMsg:NO  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
//         
//            [[NSUserDefaults standardUserDefaults] setObject:_pwdBase64 forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
//            [[NSUserDefaults standardUserDefaults] setObject:_nameBase64 forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
            self.loginArray = [NSMutableArray array];
            NSLog(@"self.loginArray------------%@",self.loginArray);
            [self setCustomerWithJson:data];
            
            
        } failure:^(NSInteger code, NSString *error) {
            if(code == -3){
                [SVProgressHUD dismiss];
                self.txtPassword.text = nil;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSOTRELINK]];
                    }
                }];
                
            }else
                [self requestLoginAgain];
            NSLog(@"--------------again----------");
        }];
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"CUSTOMER_DATABASE"];
        [self requestLoginAgain];
        
    }];
}

- (void)requestLoginAgain
{
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Demo forKey:@"CUSTOMER_DATABASE"];
    NSDictionary *para = @{@"LoginMobile":_nameBase64,
                           @"Password":_pwdBase64,
                           @"ImageHeight":@160,
                           @"ImageWidth":@160};
    _requestLoginOperation =  [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList"  showErrorMsg:NO  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
//            [[NSUserDefaults standardUserDefaults] setObject:_pwdBase64 forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
//            [[NSUserDefaults standardUserDefaults] setObject:_nameBase64 forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
            self.loginArray = [NSMutableArray array];
            
            [self setCustomerWithJson:data];
            
        } failure:^(NSInteger code, NSString *error) {
            if(code == -3){
                [SVProgressHUD dismiss];
                self.txtPassword.text = nil;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSOTRELINK]];
                    }
                }];
                
            }else{
                NSLog(@"---------------test-----------");
                
                [self requestLoginTest];
                
            }
            
        }];
    } failure:^(NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"CUSTOMER_DATABASE"];
        [self requestLoginTest];
    }];
}

- (void)requestLoginTest
{
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString_Test forKey:@"CUSTOMER_DATABASE"];
    NSDictionary *para = @{@"LoginMobile":_nameBase64,
                           @"Password":_pwdBase64,
                           @"ImageHeight":@160,
                           @"ImageWidth":@160};
    _requestLoginOperation =  [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/getCompanyList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            self.loginArray = [NSMutableArray array];
            
            [self setCustomerWithJson:data];
            
        } failure:^(NSInteger code, NSString *error) {
            if(code == -3){
                [SVProgressHUD dismiss];
                self.txtPassword.text = nil;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSOTRELINK]];
                    }
                }];
            }else{
                [self initView];
            }
        }];
    } failure:^(NSError *error) {
        [self initView];
    }];
}

-(void)setCustomerWithJson:(NSArray *)data
{
    
    NSMutableArray *mutableData = [NSMutableArray array];
    
    for (NSDictionary *dict in data) {
        NSMutableDictionary *mutableObj = [NSMutableDictionary dictionaryWithDictionary:dict];
        LoginDoc *loginDoc = [[LoginDoc alloc] init];
        [loginDoc setValuesForKeysWithDictionary:dict];
        if ((NSNull *)dict[@"BranchName"] == [NSNull null])
            [mutableObj setValue:nil forKey:@"BranchName"];
        [mutableData addObject:mutableObj];
        [self.loginArray addObject:loginDoc];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableData forKey:@"CUSTOMER_COMPANYLIST"];

    //[IOS-Customer] 顾客属于多个商家时，登录，选择任意商家，关闭APP，重新启动APP，自动登录后，页面应转入上次所选的商家促销页，目前停留在商家选择页
    NSData *docData = [[NSUserDefaults standardUserDefaults]objectForKey:@"login_selected_compmay"];
    LoginDoc *doc = [NSKeyedUnarchiver unarchiveObjectWithData:docData];
    
    
    NSString *temp =  [[NSUserDefaults standardUserDefaults]objectForKey:@"isAutoLogin"];
    if ([temp isEqualToString:@"YES"]) {
        if (doc != nil) {
            BOOL isExistsCompany = NO;
            for (int i = 0 ; i < self.loginArray.count; i++) {
                LoginDoc *loginDoc = self.loginArray[i];
                if (loginDoc.login_CompanyID == doc.login_CompanyID) {
                    isExistsCompany = YES;
                    [self param:doc];
                    break;
                }
            }
            if (!isExistsCompany) {
                [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"isAutoLogin"];
                double delayInSeconds = 0.5f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    //循环查找最底层模态视图，再退出
                    UIViewController *viewController = self;
                    while(viewController.presentingViewController) {
                        viewController = viewController.presentingViewController;
                    }
                    if(viewController) {
                        [self initView];
                        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
                        appDelegate.isNeedGetVersion = NO;
                    }
                });
                [self initView];
            }
        }
    }else{
        
        if (loginArray.count == 1) {
            LoginDoc *  loginDoc = [loginArray objectAtIndex:0];
           
            [self param:loginDoc];
        } else {
            
            self.txtPassword.text = nil;
            
            [SVProgressHUD dismiss];
         
            [self performSegueWithIdentifier:@"goChooseCompanyViewFromLoginView" sender:self];
        }
        
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.isLogin = YES;
    }
   
    
    
}

- (void)param:(LoginDoc *)loginDoc
{
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_CustomerID) forKey:@"CUSTOMER_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_CompanyID) forKey:@"CUSTOMER_COMPANYID"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_BranchID) forKey:@"CUSTOMER_BRANCHID"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_BranchCount) forKey:@"CUSTOMER_BRANCHCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_PromotionCount) forKey:@"CUSTOMER_PROMOTION"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:loginDoc.login_Discount] forKey:@"CUSTOMER_DISCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_CompanyScale) forKey:@"CUSTOMER_COMPANYSCALE"];
    if (!loginDoc.login_CurrencySymbol || [loginDoc.login_CurrencySymbol isEqualToString:@""]) {
        loginDoc.login_CurrencySymbol = @"￥";
    }
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_CurrencySymbol forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_RemindCount) forKey:@"CUSTOMER_REMINDCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_UnpaidOrderCount) forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(loginDoc.login_UnconfirmedOrderCount) forKey:@"CUSTOMER_CONFIRMCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_CompanyCode forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_CompanyAbbreviation forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_CustomerName forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_HeadImageURL forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject: loginDoc.login_Advanced forKey:@"CUSTOMER_ADVANCED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    [self updateLoginInfoForCustomer:loginDoc];
    
}


-(void)updateLoginInfoForCustomer:(LoginDoc *)loginDoc
{
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceModel = [DeviceInfoManager DeviceInfoOfType];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dict = @{@"LoginMobile":_nameBase64,
                           @"Password":_pwdBase64,
                           @"DeviceID":deviceToken ? deviceToken : @"",
                           @"OSVersion":OSVersion,
                           @"DeviceModel":deviceModel,
                           @"CompanyID":@(loginDoc.login_CompanyID),
                           @"APPVersion":appVersion,
                           @"ClientType":@"2",
                           @"DeviceType":@"1",
                           @"UserID":@(loginDoc.login_CustomerID),
                           @"IsNormalLogin":@YES
                           };
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/login/updateLoginInfo"  showErrorMsg:YES  parameters:dict WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
     
            [[NSUserDefaults standardUserDefaults] setObject:_pwdBase64 forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
            [[NSUserDefaults standardUserDefaults] setObject:_nameBase64 forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
            [UUID setUUID:data[@"GUID"] == [NSNull null] ? @"" : data[@"GUID"]];

            NSData *docData = [NSKeyedArchiver archivedDataWithRootObject:loginDoc];
            [[NSUserDefaults standardUserDefaults]setObject:docData forKey:@"login_selected_compmay"];
    
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ZXTabBarController *tab = [storyboard instantiateViewControllerWithIdentifier:@"ZXTabBarController"];
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            appDelegate.window.rootViewController = tab;
            UINavigationController *indexNav =  [tab.viewControllers objectAtIndex:0];
            IndexViewController *indexVC = [indexNav.viewControllers objectAtIndex:0];
            indexVC.loginDoc = loginDoc;
            
            
//            [self performSegueWithIdentifier:@"goInitialSlidingViewFromLoginView" sender:self];

            [SVProgressHUD dismiss];
            
            NSLog(@"------------------------------------------------------------------------------------------------------------------------------------------");
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
        self.txtPassword.text = nil;
    } failure:^(NSError *error) {
        self.txtPassword.text = nil;
    }];
}

// 获取程序最新版本
- (void)requestAppVersion
{
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSDictionary *para =@{@"DeviceType":@0,
                          @"ClientType":@1,
                          @"CurrentVersion":version};
    _getVersionOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/version/getServerVersion"  showErrorMsg:NO  parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            NSString *version = data[@"Version"] == [NSNull null] ? @"":data[@"Version"];
            NSInteger mustUpgrade = [data[@"MustUpgrade"] integerValue];
            //            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTCOME"] integerValue] == 1){
            appDelegate.isShowVersionUpdate = 0; //需要显示升级提示框（解决不点击升级框，直接切换到后台后再激活程序，会多次弹出升级框）
            
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpgrade == 0 && appDelegate.isShowVersionUpdate < 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSOTRELINK]];
                        }
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                    appDelegate.userChoice = YES;
                } else if (appDelegate.isShowVersionUpdate < 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    alert.tag = 0;
                    appDelegate.isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSOTRELINK]];
                        }else
                            exit(0);
                        appDelegate.isShowVersionUpdate = 0;
                    }];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"CUSTOMER_MUSTUPDATE"];
            }
            //            }
            appDelegate.isNeedGetVersion = YES;
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，\n请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        //        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        //        }];
    }];
}


@end
