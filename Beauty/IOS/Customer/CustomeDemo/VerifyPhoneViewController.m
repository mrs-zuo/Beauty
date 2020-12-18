//
//  VerifyPhoneViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "VerifyPhoneViewController.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "ChooseCompanyForFindPWViewController.h"
#import "ResetPasswordViewController.h"
#import "NSString+Additional.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "LoginDoc.h"
#import "RSA.h"

#define  REQUEST_NEW_MESSAGE_RATE 1

@interface VerifyPhoneViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getVerificationCodeOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getNextPageOperation;
@property (strong, nonatomic) NSMutableArray *loginArray;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger time;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *getVCodeButton;
@property (strong, nonatomic) UIButton *goNextButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (nonatomic) UITextField *phoneTextField;
@property (nonatomic) UITextField *verificationCodeTextField;
@property (strong, nonatomic) RSA *RSAPublicKey;
@end

@implementation VerifyPhoneViewController
@synthesize loginArray;
@synthesize timer;
@synthesize time;
@synthesize phoneTextField;
@synthesize verificationCodeTextField;

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
    self.isOnlyShowBackButton = YES;
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }

    [self initView];
    
    _RSAPublicKey = [[RSA alloc] init];
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    OSStatus status = [_RSAPublicKey extractPublicFromCertificateFile:certPath];
    
    if(status != errSecSuccess)
        [SVProgressHUD showErrorWithStatus2:@"打开RSA加密证书失败！"];
    time = 60;
}

- (void)initView
{
    self.title = @"身份验证";
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"身份验证"]];
    
    UIImageView *userNameImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 60.0f - 20, 280.0f, 33.0f)];
    userNameImage.image = [UIImage imageNamed:@"findUserName"];
    [self.view addSubview:userNameImage];
    phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 62.0f - 20, 255.0f, 33.0f)];
    phoneTextField.placeholder = @"登录名（手机号）";
    phoneTextField.font = kFont_Light_16;
    phoneTextField.textColor = kColor_Editable;
    phoneTextField.delegate = self;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_LOGIN_CUSTOMID"];
    [self.view addSubview:phoneTextField];
    phoneTextField.text = @"";
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 95.0f - 20, 280.0f, 20.0f)];
    textLabel.font = kFont_Light_12;
    textLabel.textColor = kColor_TitlePink;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = @"该手机号仅用于确认您的身份，以保证账户安全。";
    [self.view addSubview:textLabel];
    
    UIImageView *vCodeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 130.0f - 20,  143.5f, 31.5f)];
    vCodeImage.image = [UIImage imageNamed:@"findVCard"];
    [self.view addSubview:vCodeImage];
    verificationCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 130.0f - 20, 140.0f, 31.5f)];
    verificationCodeTextField.placeholder = @"验证码";
    verificationCodeTextField.font = kFont_Light_16;
    verificationCodeTextField.textColor = kColor_Editable;
    verificationCodeTextField.delegate = self;
    verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    verificationCodeTextField.returnKeyType=UIReturnKeyDone;
    verificationCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    verificationCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:verificationCodeTextField];
    verificationCodeTextField.text = @"";
    
    _getVCodeButton = [UIButton buttonWithTitle:@""
                                         target:self
                                       selector:@selector(getVerificationCode)
                                          frame:CGRectMake(182.5f, 130.0f - 20, 117.5f, 31.5f)
                                  backgroundImg:[UIImage imageNamed:@"findGetVCard"]
                               highlightedImage:nil];
    [self.view addSubview:_getVCodeButton];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 117.5f - 20, 31.5f)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = [NSString stringWithFormat:@"获得验证码"];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = kFont_Light_14;
    [_getVCodeButton addSubview:_timeLabel];
    
    _goNextButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(goNextPage)
                                        frame:CGRectMake(170.0f, 180.0f - 20, 130.0f, 32.0f)
                                backgroundImg:[UIImage imageNamed:@"nextbth"]
                             highlightedImage:nil];
    [self.view addSubview:_goNextButton];
    
    _cancelButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(cancelAction)
                                        frame:CGRectMake(20.0f, 180.0f - 20, 130.0f, 32.0f)
                                backgroundImg:[UIImage imageNamed:@"cancelbth"]
                             highlightedImage:nil];
    [self.view addSubview:_cancelButton];
    
    if ((IOS7 || IOS8)) {
        [phoneTextField setTintColor:[UIColor blueColor]];
        [verificationCodeTextField setTintColor:[UIColor blueColor]];
    }
}
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    verificationCodeTextField.text = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getVerificationCodeOperation || [_getVerificationCodeOperation isExecuting]) {
        [_getVerificationCodeOperation cancel];
        _getVerificationCodeOperation = nil;
    }
    
    if (_getNextPageOperation || [_getNextPageOperation isExecuting]) {
        [_getNextPageOperation cancel];
        _getNextPageOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [phoneTextField resignFirstResponder];
    [verificationCodeTextField resignFirstResponder];
}

#pragma mark - Button

- (void)getVerificationCode
{
    if (_getVCodeButton.enabled == YES) {
        [self requesGetVerificationCode];
    }
}

- (void)requestMakeButtonUnenable
{
    if (time != 0) {
        _getVCodeButton.enabled = NO;
        _timeLabel.text = [NSString stringWithFormat:@"%ld秒后重新获取", (long)time];
        time--;
    } else{
       _getVCodeButton.enabled = YES;
        time = 60;
        [timer invalidate];
        _timeLabel.text = [NSString stringWithFormat:@"获得验证码"];
    }
}

- (void)goNextPage
{
//    if ([verificationCodeTextField.text isEqualToString:@""] && [phoneTextField.text isEqualToString:@""]) {
//        [SVProgressHUD showErrorWithStatus2:@"请输入账号和验证码"];
//    } else {
        [self requesGoNextPage];
//    }
}

- (void)cancelAction
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissKeyboard" object:nil];
//    
//    UIViewController *viewController = self;
//    while(viewController.presentingViewController) {
//        viewController = viewController.presentingViewController;
//    }
//    if(viewController) {
//        [viewController dismissViewControllerAnimated:YES completion:nil];
//    }
}

#pragma mark - 页面切换

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goChooseCompanyViewFromFindPasswordView"]) {
        ChooseCompanyForFindPWViewController *detailController = segue.destinationViewController;
        detailController.loginArray = loginArray;
        detailController.loginMobile = phoneTextField.text;
    }
    
    if ([segue.identifier isEqualToString:@"goChangePasswordViewFromFindPasswordView"]) {
        ResetPasswordViewController *detailController = segue.destinationViewController;
        detailController.loginArray = loginArray;
        detailController.loginMobile = phoneTextField.text;
    }
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

- (void)requesGetVerificationCode
{
    NSString *phone = [[phoneTextField text] stringByTrimmingTrailEmpty];
    if ([phone isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入登录名"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];

    NSDictionary *para = @{@"LoginMobile":[_RSAPublicKey RSAEncryptByPublicKeyWithString:phone]};
    _getVerificationCodeOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/login/getAuthenticationCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        // 将该viewController的句柄给AppDelegate
        NSInteger code = [[json objectForKey:@"Code"] integerValue];
        NSString *mes = [json objectForKey:@"Message"] == [NSNull null] ? @"验证码获取失败！" : [json objectForKey:@"Message"];
        
        if (code != 1) {
            [SVProgressHUD showErrorWithStatus2:mes];
            return ;
        }
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setVerifyPhoneViewController:self];
        if (timer == nil || timer.isValid == false) {
            timer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_NEW_MESSAGE_RATE target:self selector:@selector(requestMakeButtonUnenable) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {

    }];
//    _getVerificationCodeOperation = [[GPHTTPClient shareClient] requestGetAuthenticationCodeWithMobile:phone success:^(id xml) {
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData) {
//            [SVProgressHUD dismiss];
//            // 将该viewController的句柄给AppDelegate
//            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setVerifyPhoneViewController:self];
//            if (timer == nil || timer.isValid == false) {
//                timer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_NEW_MESSAGE_RATE target:self selector:@selector(requestMakeButtonUnenable) userInfo:nil repeats:YES];
//            }
//        } failure:^{
//            [SVProgressHUD dismiss];
//        }];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}

- (void)requesGoNextPage
{
    NSString *phone = [[phoneTextField text] stringByTrimmingTrailEmpty];
    NSString *verificationCode = [[verificationCodeTextField text] stringByTrimmingTrailEmpty];
    if ([phone isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入登录名"];
        return;
    }

    if ([verificationCode isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus2:@"请输入验证码"];
        return;
    }

    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];

    NSDictionary *para = @{@"LoginMobile":[_RSAPublicKey RSAEncryptByPublicKeyWithString:phone],
                           @"AuthenticationCode":[_RSAPublicKey RSAEncryptByPublicKeyWithString:verificationCode]};
    _getNextPageOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/login/checkAuthenticationCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (loginArray)
                [loginArray removeAllObjects];
            else
                loginArray = [NSMutableArray array];
            
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            if (self.phoneTextField.text)
                appDelegate.loginMobile = [NSString stringWithString: self.phoneTextField.text];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LoginDoc *loginDoc = [[LoginDoc alloc] init];
                loginDoc.login_CustomerID  = [obj[@"UserID"] intValue];
                loginDoc.login_CompanyID   = [obj[@"CompanyID"] intValue];
                loginDoc.login_CompanyAbbreviation = obj[@"CompanyAbbreviation"];
                [loginArray addObject:loginDoc];
            }];

            if (loginArray.count == 1) {
                [self performSegueWithIdentifier:@"goChangePasswordViewFromFindPasswordView" sender:self];
            } else if (loginArray.count > 1){
                [self performSegueWithIdentifier:@"goChooseCompanyViewFromFindPasswordView" sender:self];
            } else
                [SVProgressHUD showErrorWithStatus2:@"获取公司信息失败！"];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
//    _getNextPageOperation = [[GPHTTPClient shareClient] requestCheckAuthenticationCodeWithMobile:phoneTextField.text authenticationCode:verificationCodeTextField.text success:^(id xml) {
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData) {
//            [SVProgressHUD dismiss];
//            if (loginArray) {
//                [loginArray removeAllObjects];
//            } else {
//                loginArray = [NSMutableArray array];
//            }
//            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
//            if (self.phoneTextField.text)
//                appDelegate.loginMobile = [NSString stringWithString: self.phoneTextField.text];
//            for (GDataXMLElement *data in [contentData elementsForName:@"Info"]) {
//                LoginDoc *loginDoc = [[LoginDoc alloc] init];
//                loginDoc.login_CustomerID  = [[[[data elementsForName:@"UserID"] objectAtIndex:0] stringValue] intValue];
//                loginDoc.login_CompanyID   = [[[[data elementsForName:@"CompanyID"] objectAtIndex:0] stringValue] intValue];
//                loginDoc.login_CompanyAbbreviation = [[[data elementsForName:@"CompanyAbbreviation"] objectAtIndex:0] stringValue];
//                [loginArray addObject:loginDoc];
//            }
//            
//            if (loginArray.count == 1) {
//                [self performSegueWithIdentifier:@"goChangePasswordViewFromFindPasswordView" sender:self];
//            } else {
//                [self performSegueWithIdentifier:@"goChooseCompanyViewFromFindPasswordView" sender:self];
//            }
//        } failure:^{
//            [SVProgressHUD dismiss];
//        }];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}


@end
