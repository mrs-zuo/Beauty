//
//  CustomerListViewController.m
//  Customers
//
//  Created by GuanHui on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "SettingViewController.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "GDataXMLNode.h"
#import "LoginDoc.h"
#import "ChooseCompanyViewController.h"
#import "AppDelegate.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "GPBHTTPClient.h"

@interface SettingViewController ()<UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *versionRequest;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSMutableArray *loginArray;
@property (strong, nonatomic) NSMutableArray *settingItem;
@end

@implementation SettingViewController
@synthesize titleArray,loginArray;

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
    titleArray = [NSArray arrayWithObjects:@"个人信息", @"美容院信息", @"部位", @"项目", @"产品", @"账户", @"账户信息", @"账户层级设置", @"账户顾客关联设置", @"从通讯录添加顾客", @"顾客等级分类", nil];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"设置"];
    [self.view addSubview:navigationView];
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg320"] forBarMetrics:UIBarMetricsDefault];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANYLIST"];
    if (loginArray) {
        [self.loginArray removeAllObjects];
    } else {
        self.loginArray = [NSMutableArray array];
    }
    NSInteger count = 0;
    for(NSDictionary *obj in data){
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
        loginDoc.branchList = [NSMutableArray array];
        NSArray *branchArray = [obj objectForKey:@"BranchList"];
        for (NSDictionary * branch in branchArray){
            BranchDoc *branchDoc = [[BranchDoc alloc] init];
            branchDoc.branchId = [[branch objectForKey:@"BranchID"] integerValue];
            branchDoc.branchName = [branch objectForKey:@"BranchName"];
            [loginDoc.branchList addObject:branchDoc];
            count ++;
        }
        [loginArray addObject:loginDoc];
    }
    
     _settingItem = [[NSMutableArray alloc] init];
    [_settingItem addObject:@"操作模式"];
    if([[PermissionDoc sharePermission] rule_MyInfo_Write])
        [_settingItem addObject:@"个人信息"];
    if(count > 1)
        [_settingItem addObject:@"门店切换"];
    
    //追加  时间设置
    [_settingItem addObject:@"自动登出"];

    //GPB-2008 追加 检查更新
//    [_settingItem addObject:@"检查更新"];

    [_settingItem addObject:@"应用下载"];

    [_settingItem addObject:@"关于我们"];

    //GPB-1735 追加 退出登录
    [_settingItem addObject:@"退出当前账号"];
    return _settingItem.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow- 12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.section == (_settingItem.count -1) ) {
        UITableViewCell *oneCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        oneCell.selectionStyle = UITableViewCellAccessoryNone;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 310, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [_settingItem objectAtIndex:indexPath.section];
        label.textColor = kColor_DarkBlue;
        label.font = kFont_Light_16;
        [oneCell.contentView addSubview:label];

        return oneCell;
    }
    
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, (kTableView_HeightOfRow-20) /2, 200, 20)];
    titleLable.font = kFont_Light_16;
    titleLable.textColor = kColor_DarkBlue;
    [cell.contentView addSubview:titleLable];
    titleLable.tag = 1000 +indexPath.section;
    
    UILabel * title = (UILabel *)[cell.contentView viewWithTag:1000+indexPath.section];
    
    title.text = [_settingItem objectAtIndex:indexPath.section];
    
    cell.textLabel.textColor = kColor_DarkBlue;
    cell.textLabel.font = kFont_Light_16;
    
    if ([title.text isEqualToString:@"自动登出"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        int time =  [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_INDATE"] intValue];
        cell.detailTextLabel.text =[NSString stringWithFormat:@"%d分钟", time];
    } else if ([title.text isEqualToString:@"操作模式"]){
        switch ([PermissionDoc getOperationWay]) {
            case 0:
                // 标准模式
                cell.detailTextLabel.text = @"标准模式";
                break;
            case 1:
                // 简易模式
                cell.detailTextLabel.text = @"简易模式";
                break;
            default:
                cell.detailTextLabel.text = @"标准模式";
                break;
        }
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"操作模式"]) {
        NSString *cancelString = @"取消";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"操作模式" message:nil delegate:self cancelButtonTitle:cancelString otherButtonTitles: nil];
        NSArray *operationWayData = [NSArray arrayWithObjects:@"标准模式", @"简易模式", nil];
        for (NSString *str in operationWayData) {
            [alter addButtonWithTitle:str];
        }
        alter.tag = indexPath.section;
        [alter show];
    } else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"个人信息"])
       [self performSegueWithIdentifier:@"goAccountEditViewFromSettingView" sender:self];
    else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"应用下载"])
        [self performSegueWithIdentifier:@"goAppDownloadFromSettingView" sender:self];
    else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"门店切换"])
        [self performSegueWithIdentifier:@"goChooseCompanyFromSettingView" sender:self];
    else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"关于我们"])
        [self performSegueWithIdentifier:@"goAboutUsViewFromSettingView" sender:self];
    else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"检查更新"])
        [self checkVersion];
    else if ([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"自动登出"])
        [self timeSetting: indexPath.section];
    else if([[_settingItem objectAtIndex:indexPath.section] isEqualToString:@"退出当前账号"])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出当前账号" otherButtonTitles: nil];
        
        //        UIView *bgView = [[UIView alloc] init];
        //        CGRect rect = self.view.bounds;
        //        rect.size.height -= 20.0f;
        //        bgView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f];
        
        //[self.view addSubview:bgView];
        
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                // 清空缓存
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_USERID"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_COMPANTID"];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate setCustomer_Selected:nil];
                [appDelegate.serviceArray_Selected removeAllObjects];
                [appDelegate.commodityArray_Selected removeAllObjects];
                [appDelegate.paperStorageOfCustomer removeAllObjects];
                [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/Logout" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
                    
                } failure:^(NSError *error) {
                    
                }];
                double delayInSeconds = 0.8f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    //循环查找最底层模态视图，再退出
                    UIViewController *viewController = self;
                    while(viewController.presentingViewController) {
                        viewController = viewController.presentingViewController;
                    }
                    if(viewController) {
                        [viewController dismissViewControllerAnimated:YES completion:nil];
                    }
                });
                // [self dismissViewControllerAnimated:YES completion:^{}];
                appDelegate.isNeedGetVersion = NO;
            }
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goChooseCompanyFromSettingView"])
    {

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setCustomer_Selected:nil];
        [appDelegate.serviceArray_Selected removeAllObjects];
        [appDelegate.commodityArray_Selected removeAllObjects];
        
        ChooseCompanyViewController *chooseCompanyViewController = segue.destinationViewController;
        chooseCompanyViewController.loginArray = self.loginArray;
        chooseCompanyViewController.switchCompany = YES;
        chooseCompanyViewController.loginType = NO;
    }
}


- (void)timeSetting:(NSInteger)section
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"设置自动登出时间\n(多长时间软件无操作即需重新登录)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = section;
    [alert show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    UITextField *text = [alertView textFieldAtIndex:0];
    text.delegate = self;
    text.keyboardType = UIKeyboardTypeNumberPad;
    text.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *userDefault = nil;
    switch (alertView.tag) {
        case 0:
            // 操作模式
            userDefault = [NSUserDefaults standardUserDefaults];
            switch (buttonIndex) {
                case 1:
                    // 标准模式
                    [userDefault setInteger:0 forKey:@"OperationWay"];
                    // 立即写入
                    [userDefault synchronize];
                    break;
                case 2:
                    // 简易模式
                    [userDefault setInteger:1  forKey:@"OperationWay"];
                    // 立即写入
                    [userDefault synchronize];
                default:
                    break;
            }
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:alertView.tag] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case 3:
            // 自动登出
            if (buttonIndex == 1) {
                UITextField *text = [alertView textFieldAtIndex:0];
                int time = [text.text intValue];

                if ([text.text isEqualToString:@""]) {
                    time = 30;
                }

                NSLog(@"the setting indate time is %d", time);
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:time] forKey:@"ACCOUNT_INDATE"];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:alertView.tag] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        default:
            break;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char * ch=[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (*ch == 0) return YES;

    
    if ((textField.text.length + string.length) > 4 ) {
        return NO;
    }
    
      __block  BOOL result = YES;
      [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
          if ([substring rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
              *stop = YES;
              result = NO;
          }
      }];
    return result;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)checkVersion
{
    
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Version/getServerVersion" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            BOOL mustUpFlag = [[data objectForKey:@"MustUpgrade"] boolValue];
            NSString *version = [data objectForKey:@"Version"];
            
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpFlag == NO ) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                    }];
                } else if(mustUpFlag == YES){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                    }];
                }
            } else {
                [SVProgressHUD showSuccessWithStatus2:@"已经是最新版本！" touchEventHandle:^{}];
            }
        } failure:^(NSInteger code, NSString *error) {}];
    } failure:^(NSError *error) {
    }];

    /*
    _versionRequest = [[GPHTTPClient shareClient] requestGetVersionWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:Nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            NSString *version = [[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue] == nil ? @"":[[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue];
            NSInteger mustUpgrade = [[[[contentData elementsForName:@"MustUpgrade"] objectAtIndex:0] stringValue] integerValue];
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpgrade == 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding-shang-jia-ban/id787142525?ls=1&mt=8"]];
                        }
                    }];

                }
                else if(mustUpgrade == 1 ){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding-shang-jia-ban/id787142525?ls=1&mt=8"]];
                        }
                    }];
                }
            } else {
                [SVProgressHUD showSuccessWithStatus2:@"已经是最新版本！" touchEventHandle:^{}];
            }
            
        }failure:^{}];
        
    } failure:^(NSError *error) {
        
    }];
    */
    
}





@end
