//
//  ChooseCompanyViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ChooseCompanyViewController.h"
#import "InitialSlidingViewController.h"
#import "LoginDoc.h"
#import "UUID.h"
#import "DeviceInfoManager.h"
#import "ZXTabBarController.h"

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
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    loginArray = [[NSMutableArray alloc] init];

    self.title = @"请选择商家";
    
  
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

#pragma mark - init

- (void)initView
{
    UINavigationBar *navigationBar;
    if ((IOS7 || IOS8)) {
        //自己添加状态栏
        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
        [stateView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview: stateView];
        
        //导航栏
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20.0f, 320, 44)];
        [self.view addSubview:navigationBar];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"请选择商家"];
        //字体大小、颜色
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [navigationBar setTitleTextAttributes:attributes];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
        
        [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        
//        //title
//        TitleView *titleView = [[TitleView alloc] init];
//        [titleView setFrame:CGRectMake(kTitle_X, 69.0f, kTitle_Width, kTitle_Height)];
//        [self.view addSubview:[titleView getTitleView:@"请选择商家"]];
        
        [_tableView setFrame:CGRectMake(0, 65.0f, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 50.0f)];
    } else {
        //导航栏
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [self.view addSubview:navigationBar];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"请选择商家"];
        //字体大小、颜色
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName, nil];
        [navigationBar setTitleTextAttributes:attributes];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        
        //title
//        TitleView *titleView = [[TitleView alloc] init];
//        [titleView setFrame:CGRectMake(kTitle_X, 49.0f, kTitle_Width, kTitle_Height)];
//        [self.view addSubview:[titleView getTitleView:@"请选择商家"]];
        
        _tableView.frame = CGRectMake(-5.0f, 45.0f, 330.0f, kSCREN_BOUNDS.size.height  - 50.0f );
    }
    [navigationBar setBarTintColor:KColor_NavBarTintColor];

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = kDefaultBackgroundColor;
    _tableView.backgroundView = nil;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - button

- (void)clickLeftButton
{
//    UIViewController *viewController = self;
//    while(viewController.presentingViewController) {
//        viewController = viewController.presentingViewController;
//    }
//    if(viewController) {
//        [viewController dismissViewControllerAnimated:YES completion:nil];
//    }
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
    [self clearAndOut];
       [[NSUserDefaults standardUserDefaults] setObject:NO forKey:@"isAutoLogin"];
}

-(void)logout
{
    [SVProgressHUD showWithStatus:@"Loading"];
    //退出的时候，注销注册的微博和微信
   
    [self clearAndOut];
}

-(void)clearAndOut
{
    
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //循环查找最底层模态视图，再退出
        UIViewController *viewController = self;
        while(viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        }
        if(viewController) {
            [viewController dismissViewControllerAnimated:YES completion:nil];
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            appDelegate.isNeedGetVersion = NO;
        }
        
    });
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return kTableView_WithTitle;
//    } else {
//        return kTableView_Margin;
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return kTableView_Margin;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow + 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return loginArray.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *messageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 2.0f, 18.0f, 16.5f)];
    messageCountLabel.tag = 1000;
    [messageCountLabel setTextColor:[UIColor whiteColor]];
    [messageCountLabel setBackgroundColor:[UIColor clearColor]];
    [messageCountLabel setFont:kFont_Number_Menu_12];
    [messageCountLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIImageView *messageCountImage = [[UIImageView alloc] initWithFrame:CGRectMake(260.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 1.5f, 18.0f, 16.5f)];
    messageCountImage.tag = 1001;
    messageCountImage.image = [UIImage imageNamed:@"remindBackground"];
    
    if (IOS6) {
        [messageCountLabel setFrame:CGRectMake(270.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 2.0f, 18.0f, 16.5f)];
        [messageCountImage setFrame:CGRectMake(270.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 1.5f, 18.0f, 16.5f)];
    }
    
    static NSString *cellIndentify = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell addSubview:messageCountImage];
        [cell addSubview:messageCountLabel];
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    LoginDoc *loginDoc = [self.loginArray objectAtIndex:indexPath.row];
    [titleLabel setFont:kFont_Light_16];
    [titleLabel setTextColor:kColor_TitlePink];
    [titleLabel setText:loginDoc.login_CompanyAbbreviation];
    
    UILabel *countlabel = (UILabel *)[cell viewWithTag:1000];
    if (loginDoc.login_NewMessageCount > 99) {
        countlabel.text = [NSString stringWithFormat:@"n"];
    } else {
        countlabel.text = [NSString stringWithFormat:@"%ld", (long)loginDoc.login_NewMessageCount];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    login_selected = [loginArray objectAtIndex:indexPath.row];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:login_selected];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"login_selected_compmay"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_CustomerID)   forKey:@"CUSTOMER_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_CompanyID)    forKey:@"CUSTOMER_COMPANYID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_BranchID)     forKey:@"CUSTOMER_BRANCHID"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_BranchCount)  forKey:@"CUSTOMER_BRANCHCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble: login_selected.login_Discount]     forKey:@"CUSTOMER_DISCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_CompanyScale) forKey:@"CUSTOMER_COMPANYSCALE"];
    if (login_selected.login_CurrencySymbol.length <= 0) {
        login_selected.login_CurrencySymbol = @"￥";
    }
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_CurrencySymbol forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_PromotionCount) forKey:@"CUSTOMER_PROMOTION"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_RemindCount) forKey:@"CUSTOMER_REMINDCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_UnpaidOrderCount) forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:@(login_selected.login_UnconfirmedOrderCount) forKey:@"CUSTOMER_CONFIRMCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_CompanyCode  forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_CompanyAbbreviation  forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_CustomerName forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_HeadImageURL      forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_LevelName    forKey:@"CUSTOMER_LEVELNAME"];
    [[NSUserDefaults standardUserDefaults] setObject: login_selected.login_Advanced forKey:@"CUSTOMER_ADVANCED"];
   
    [self updateLoginInfoForCustomer:login_selected];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goInitialSlidingViewFromChooseCompanyView"]) {
        InitialSlidingViewController *inistialController = segue.destinationViewController;
        inistialController.tagetView = @"PtomotionNavigation";
    }
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
-(void)updateLoginInfoForCustomer:(LoginDoc *)loginDoc
{
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceModel = [DeviceInfoManager DeviceInfoOfType];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSDictionary * dict = @{@"LoginMobile":_nameBase64,
                            @"Password":_pwdBase64,
                            @"DeviceID":deviceToken ? deviceToken : @"",
                            @"OSVersion":OSVersion,
                            @"DeviceModel":deviceModel,
                            @"CompanyID":@(loginDoc.login_CompanyID),
                            @"APPVersion":appVersion,
                            @"ClientType":@"2",
                            @"DeviceType":@"1",
                            @"UserID":@(loginDoc.login_CustomerID),
                            @"IsNormalLogin":@(self.loginType)
                            };
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/Login/updateLoginInfo"  showErrorMsg:YES  parameters:dict WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [[NSUserDefaults standardUserDefaults] setObject:_pwdBase64 forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
            [[NSUserDefaults standardUserDefaults] setObject:_nameBase64 forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
            
//            [[NSUserDefaults standardUserDefaults] setObject:_nameBase64 forKey:@"LOGIN_MOBILE_BASE64"];
            [UUID setUUID:data[@"GUID"]];
//            [[NSUserDefaults standardUserDefaults] setObject:_pwdBase64 forKey:@"LOGIN_PASSWORD_BASE64"];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ZXTabBarController *tab = [storyboard instantiateViewControllerWithIdentifier:@"ZXTabBarController"];
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            appDelegate.window.rootViewController = tab;
            
//            [self performSegueWithIdentifier:@"goInitialSlidingViewFromChooseCompanyView" sender:self];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}
@end
