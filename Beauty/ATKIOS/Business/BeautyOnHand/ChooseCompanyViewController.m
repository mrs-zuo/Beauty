//
//  ChooseCompanyViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-10-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ChooseCompanyViewController.h"
#import "InitialSlidingViewController.h"
#import "LoginDoc.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "GPBHTTPClient.h"
#import "DeviceInfoManager.h"

@interface ChooseCompanyViewController ()
@property (strong, nonatomic) LoginDoc *login_selected;
@end

@implementation ChooseCompanyViewController
@synthesize loginArray;
@synthesize login_selected;
@synthesize loginType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:(UIBarMetricsDefault)];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg"] forBarMetrics:UIBarMetricsDefault];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    if (loginArray == nil) {
        loginArray = [[NSMutableArray alloc] init];
    }
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initView{

    if ((IOS7 || IOS8)) {
        //自己添加状态栏
        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
        [stateView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview: stateView];
        
        //导航栏
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20.0f, 320, 44)];
        [self.view addSubview:navigationBar];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 5.f, 0.0f, 250.0f, HEIGHT_NAVIGATION_VIEW)];
        titleLabel.textColor = kColor_LightBlue;
        titleLabel.text = @"请选择登录门店";
        titleLabel.font = kFont_Light_16;
        UIImageView *viewBack = [[UIImageView alloc]initWithFrame:CGRectMake(4, 70, 312, 38)];
        viewBack.image = [UIImage imageNamed:@"TitleBar"];
        [self.view addSubview:viewBack];
        [viewBack addSubview:titleLabel];
        
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ( self.switchCompany ) {
            [leftButton setFrame:CGRectMake(0.0f, 7, 45.0f, 29.0f)];
            [leftButton setBackgroundImage:[UIImage imageNamed:@"button_GoBack"] forState:UIControlStateNormal];
        } else {
            [leftButton setFrame:CGRectMake(0.0f, 7, 23.0f, 30.0f)];
            [leftButton setBackgroundImage:[UIImage imageNamed:@"backClient"] forState:UIControlStateNormal];
        }

        [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        [_tableView setFrame:CGRectMake(5.0f, 108.0f, 310.0f, kSCREN_BOUNDS.size.height - 118.0f)];
    } else {
        //导航栏
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [self.view addSubview:navigationBar];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake( 5.f, 0.0f, 250.0f, HEIGHT_NAVIGATION_VIEW)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = kColor_LightBlue;
        titleLabel.text = @"请选择登录门店";
        titleLabel.font = kFont_Light_16;
        titleLabel.backgroundColor = [UIColor clearColor];
        UIImageView *viewBack = [[UIImageView alloc]initWithFrame:CGRectMake(4, 50, 312, 38)];
        viewBack.image = [UIImage imageNamed:@"TitleBar"];
        [self.view addSubview:viewBack];
        [viewBack addSubview:titleLabel];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if(self.switchCompany) {
            [leftButton setFrame:CGRectMake(0.0f, 7, 45.0f, 29.0f)];
            [leftButton setBackgroundImage:[UIImage imageNamed:@"button_GoBack"] forState:UIControlStateNormal];
        } else {
            [leftButton setFrame:CGRectMake(0.0f, 7, 23.0f, 30.0f)];
            [leftButton setBackgroundImage:[UIImage imageNamed:@"backClient"] forState:UIControlStateNormal];
        }
        [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        
        _tableView.frame = CGRectMake(-5.0f, 90.0f, 330.0f, kSCREN_BOUNDS.size.height  - 90.0f );
    }
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}
#pragma mark - button

- (void)clickLeftButton
{
    if(self.switchCompany)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIViewController *viewController = self;
        while(viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        }
        if(viewController) {
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow + 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return loginArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[loginArray objectAtIndex:section] branchList] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIndentify = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 1010;
        [cell.contentView addSubview:label];
    }
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1010];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    LoginDoc *loginDoc = [self.loginArray objectAtIndex:indexPath.section];
    if(indexPath.row == 0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(IOS6)
            titleLabel.frame = CGRectMake( 15, 3, 260, 38);
        else
            titleLabel.frame = CGRectMake( 5, 3, 260, 38);
        [titleLabel setTextColor:kColor_DarkBlue];
        [titleLabel setFont:kFont_Light_16];
        [titleLabel setText:loginDoc.companyAbbreviation];
    } else {

        if(IOS6)
            titleLabel.frame = CGRectMake( 30, 0, 260, 38);
        else
            titleLabel.frame = CGRectMake( 20, 0, 260, 38);
        [titleLabel setTextColor:kColor_Black];
        [titleLabel setFont:kFont_Light_14];
        [titleLabel setText:[[loginDoc.branchList objectAtIndex:indexPath.row - 1] branchName]];
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0)
        return;
    login_selected = [self.loginArray objectAtIndex:indexPath.section];
    login_selected.branchID = [[login_selected.branchList objectAtIndex:indexPath.row - 1] branchId];
    //重置权限
    PermissionDoc *permissonDoc = [PermissionDoc sharePermission];
    [permissonDoc resetPermission:[login_selected advanced]];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"OrderTotalSalePrice_Write"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Money_Out"];
    [[NSUserDefaults standardUserDefaults] setObject:login_selected.isComissionCalc forKey:@"current_isComissionCalc"];

    [self updateLoginInfoForAccount:login_selected];
}

-(void)updateLoginInfoForAccount:(LoginDoc *)loginDoc{
    
    [SVProgressHUD setStatus:@"Loading"];
    
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];

    NSString *par = [NSString stringWithFormat:@"{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"DeviceID\":\"%@\",\"DeviceModel\":\"%@\",\"OSVersion\":\"%@\",\"BranchID\":%ld,\"CompanyID\":%ld,\"APPVersion\":\"%@\",\"ClientType\":%d,\"DeviceType\":%d,\"UserID\":%ld,\"IsNormalLogin\":%d}", ACC_RSAUSERID, ACC_RSAPWD, deviceToken ? deviceToken : @"", [DeviceInfoManager DeviceInfoOfType], [[UIDevice currentDevice] systemVersion], (long)loginDoc.branchID, (long)loginDoc.companyId, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 1, 1, (long)loginDoc.accountId, self.loginType];
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
            
            [self performSegueWithIdentifier:@"goInitialSlidingViewFromChooseCompanyView" sender:self];
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
            return;
        }
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        if ((NSNull *)dataDictionary == [NSNull null] || dataDictionary.count == 0) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取登录信息失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            return;
        }
        NSDictionary *dataDic = [dataDictionary objectForKey:@"Data"];
        if ((NSNull *)dataDic == [NSNull null] || dataDic.count == 0) {
            [SVProgressHUD showErrorWithStatus2:(NSString*)[dataDictionary objectForKey:@"Message"] touchEventHandle:^{}];
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.accountId] forKey:@"ACCOUNT_USERID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.companyId] forKey:@"ACCOUNT_COMPANTID"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.branchID]  forKey:@"ACCOUNT_BRANCHID"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.companyCode forKey:@"ACCOUNT_COMPANTCODE"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.userName forKey:@"ACCOUNT_NAME"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.headImg forKey:@"ACCOUNT_HEADIMAGE"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginDoc.companyScale] forKey:@"ACCOUNT_COMPANTSCALE"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"SettlementCurrency"];
        [[NSUserDefaults standardUserDefaults] setObject:(loginDoc.moneyIcon ? loginDoc.moneyIcon : @"¥") forKey:@"ACCOUNT_CURRENCY_ICON"];
        [[NSUserDefaults standardUserDefaults] setObject:loginDoc.companyAbbreviation forKey:@"ACCOUNT_COMPANYABBREVIATION"];
        
        //设置默认时间
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"ACCOUNT_INDATE": @30}];

        
        // --Role permission
        PermissionDoc *permissonDoc = [PermissionDoc sharePermission];
        if((NSNull *)dataDic != [NSNull null] && dataDic.count != 0){
            NSString *sourceString = [dataDic objectForKey:@"Role"];/*@"|1|2|3|4|5|6|7|12|13|11|21|121|35|21|1|22|30|90|12|0|9|28|29|8|15|16|17|32|33|34|";*/ /*
            if(sourceString){
                [permissonDoc setPermission:sourceString];
                permissonDoc.record_marketing_oppotun = loginDoc.advanced;
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_OrderTotalSalePrice_Write ] forKey:@"OrderTotalSalePrice_Write"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:permissonDoc.rule_Money_Out ] forKey:@"Money_Out"];
            }
        }
        
        [self performSegueWithIdentifier:@"goInitialSlidingViewFromChooseCompanyView" sender:self];
        self.view.userInteractionEnabled = YES;
        AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
        appDelegate.isLogin = YES;
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
    }]; */
}

@end
