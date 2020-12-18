//
//  CustomerFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-24.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "CustomerFilterViewController.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "GPHTTPClient.h"
#import "EcardInfo.h"
#import "SourceType.h"
#import "GPBHTTPClient.h"
#import "PermissionDoc.h"
#import "SelectCustomersViewController.h"
#import "UserDoc.h"
#import "DFUITableView.h"
#import "UIButton+InitButton.h"
#import "DFTableAlertView.h"
#import "DFDateView.h"

#import "CustomerListViewController.h"
@interface CustomerFilterViewController ()<UITableViewDataSource, UITableViewDelegate, SelectCustomersViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak)   AFHTTPRequestOperation *requestLevel;
@property (nonatomic, weak)   AFHTTPRequestOperation *requestSourceType;

@property (nonatomic, strong) DFUITableView *tableView;
@property (nonatomic, strong) NSArray *custData;
@property (nonatomic, strong) NSArray *firstVisitTypeData;
@property (nonatomic, strong) NSArray *effectiveCustomerTypeData;
@property (nonatomic, strong) NSMutableArray *ecardData;
@property (nonatomic, strong) NSMutableArray *sourceTypeData;
@property (nonatomic, strong) NSString *cust;
@property (nonatomic, strong) NSString *firstVisit;
@property (nonatomic, strong) NSString *effectiveCustomer;
@property (nonatomic, strong) EcardInfo *ecard;
@property (nonatomic, strong)  SourceType *st;
@property (nonatomic, strong) UserDoc *userInfo;
@property (nonatomic, strong) NSString *currentDateValue;

@property (nonatomic, strong) NSMutableArray *personArray;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, copy) NSString *personIDs;

@property (nonatomic,strong) NSMutableArray *cusRowArrs;

@property (nonatomic,assign) NSUInteger textLength;

@end

@implementation CustomerFilterViewController
@synthesize cusType;
@synthesize firstVisitType;
@synthesize firstVisitDateTime;
@synthesize effectiveCustomerType;
@synthesize firstVisitTypeData;
@synthesize effectiveCustomerTypeData;
@synthesize ecardData;
@synthesize sourceTypeData;
@synthesize custData;
@synthesize currentDateValue;
@synthesize customerName,customerTel;
@synthesize cust, ecard,st,firstVisit,effectiveCustomer;
@synthesize delegate;
@synthesize textLength;

- (UserDoc *)userInfo {
    if (!_userInfo) {
        _userInfo = [[UserDoc alloc] init];
        _userInfo.user_Id = ACC_ACCOUNTID;
        _userInfo.user_Name = ACC_ACCOUNTName;
    }
    return _userInfo;
}

- (NSString *)personName {
    _personName = @"无";
    
    if (self.personArray.count) {
        NSArray *nameArray = [self.personArray valueForKeyPath:@"@unionOfObjects.user_Name"];
        _personName = [nameArray componentsJoinedByString:@"、"];
    }
    return _personName;
}

- (NSString *)personIDs {
    _personIDs = @"";
    if (self.personArray.count) {
        NSArray *idArray = [self.personArray valueForKeyPath:@"@unionOfObjects.user_Id"];
        _personIDs = [idArray componentsJoinedByString:@","];
    }
    return _personIDs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * arr = [[NSArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditChanged:)
              name:@"UITextFieldTextDidChangeNotification" object:nil];
    self.textLength = 0;
    self.view.backgroundColor = kColor_Background_View;
    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    self.navigationItem.rightBarButtonItem = nil;

    [self initData];
    

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"顾客高级筛选"];
    [self.view addSubview:navigationView];

    _tableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    
    if ((IOS7 || IOS8)) {
        [_tableView setFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f,
                                       kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f + 40.f)]; // kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f - 5.0f
    } else if (IOS6) {
        [_tableView setFrame:CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f,
                                      kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f + 40.f)]; // kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f - 5.0f
    }

    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:_tableView];
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self subTitle:@"筛选" submitAction:@selector(searchCustomer) deleteTitle:@"重置" deleteAction:@selector(resetData)];
                              
    [footerView showInTableView:_tableView];
    
    [self sourceTypeRequest];
}

- (void)initData {
    self.customerName = @"";
    self.customerTel = @"";
    if ([[PermissionDoc sharePermission] rule_AllCustomer_Read]) {
        custData = [NSArray arrayWithObjects:@"我的顾客", @"所有顾客", @"门店顾客", nil];
    } else {
        custData = @[@"我的顾客"];
        cusType = 0;
    }
    //设置当前日期
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    currentDateValue = [formatter stringFromDate:[NSDate date]];
    
    
    
    
    firstVisitDateTime = @"请选择自定义日期";
    firstVisitTypeData = [NSArray arrayWithObjects:@"全部", @"当日", @"自定义", nil];
    firstVisitType = 0;
    cust = custData[cusType];
    firstVisit = firstVisitTypeData[firstVisitType];
    effectiveCustomerType = 0;
    effectiveCustomerTypeData = [NSArray arrayWithObjects:@"全部", @"有效", @"无效(一年以上未上门)", nil];
    effectiveCustomer = effectiveCustomerTypeData[effectiveCustomerType];
    ecardData = [NSMutableArray array];
    sourceTypeData=[NSMutableArray array];
    
    NSArray *array =  @[@{@"CardCode":@-1,@"CardName":@"全部"}];
    NSArray *stArray =  @[@{@"ID":@-1,@"Name":@"全部"}];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ecardData addObject:[[EcardInfo alloc] initWithDictionary:obj]];
        
    }];
    [stArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [sourceTypeData addObject:[[SourceType alloc] initWithDictionary:obj]];
        
    }];
    
   NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld_%ld_ECARD",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    if (dic) {
        ecard = [[EcardInfo alloc] initWithDictionary:dic];
    } else {
        ecard = [ecardData firstObject];
    }
    NSDictionary *stDic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld_%ld_SOURCETYPE",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    if (stDic) {
        st = [[SourceType alloc] initWithDictionary:stDic];
    } else {
        st = [sourceTypeData firstObject];
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld_%ld_PERSON",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    
    

    if (data) {
        self.personArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        self.personArray = [NSMutableArray arrayWithObject:self.userInfo];
    }
    
    _cusRowArrs = [NSMutableArray array];
    
    
}

- (void)goBack
{
    if ([delegate respondsToSelector:@selector(didnotRefresh)]) {
        [delegate didnotRefresh];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetData {
    st=[sourceTypeData firstObject];
    ecard = [ecardData firstObject];
    self.registFrom = -1;
    if ([[PermissionDoc sharePermission] rule_AllCustomer_Read]) {
        cust = @"门店顾客";
        cusType = 2;
    }else{
        cust = @"我的顾客";
        cusType = 0;
    }
    firstVisitType = 0;
    firstVisit = @"全部";
    firstVisitDateTime = @"请选择自定义日期";
    effectiveCustomerType = 0;
    effectiveCustomer =@"全部";
    self.customerName = @"";
    self.customerTel = @"";
    [self.personArray removeAllObjects];
    [self.personArray addObject:self.userInfo];
    
    [self.tableView reloadData];
}

- (void)searchCustomer {
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = @"yyyy-MM-dd";
    
    NSDate *dateStar = [dateFor dateFromString:self.firstVisitDateTime];
    NSDate *currentDate = [dateFor dateFromString:self.currentDateValue];
    
    if (firstVisitType == 2 && dateStar == nil) {
        [SVProgressHUD showErrorWithStatus2:@"自定义日期有误，请重新设置" touchEventHandle:^{ }];
        return;
    }
    if([dateStar timeIntervalSince1970] > [currentDate timeIntervalSince1970]){
        [SVProgressHUD showErrorWithStatus2:@"自定义日期不能大于当前日期，请重新设置" touchEventHandle:^{ }];
        return;
    }
    if(firstVisitType <= 1){
        firstVisitDateTime = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:cusType] forKey:[NSString stringWithFormat:@"%ld_%ld_TYPE",(long)ACC_ACCOUNTID, (long)ACC_BRANCHID]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.personArray];

    NSDictionary *dic = @{@"LevelName":ecard.CardName,
                          @"CardCode":@((long)ecard.CardCode)
                          };
    NSDictionary *stDic = @{@"ID":@(st.ID),
                          @"Name":st.Name
                          };
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%ld_%ld_PERSON",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    [[NSUserDefaults standardUserDefaults] setObject:stDic forKey:[NSString stringWithFormat:@"%ld_%ld_SOURCETYPE",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:[NSString stringWithFormat:@"%ld_%ld_ECARD",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    
    if ([delegate respondsToSelector:@selector(setCustomerEcardLevel:responID:registFrom:sourceType:stIDInt:firstVisitTypeInt:firstVisitDateTimeString:searchCustomerName:searchCustomerTel:)]) {
        [delegate setCustomerEcardLevel:ecard.CardCode responID:(cusType == 0 ? self.personIDs: @"") registFrom:self.registFrom sourceType:self.st.ID stIDInt:self.firstVisitType firstVisitTypeInt:self.firstVisitDateTime firstVisitDateTimeString:self.effectiveCustomerType searchCustomerName:self.customerName searchCustomerTel:self.customerTel];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [_cusRowArrs removeAllObjects];
    if (cusType == 0) {
        NSArray *arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾问",@"顾客状态",@"顾客注册日期"];
        if(firstVisitType == 2){
            arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾问",@"顾客状态",@"顾客注册日期",@"自定义日期选择"];
        }
        [_cusRowArrs addObjectsFromArray:arr];
    }else if(cusType == 1){
        // 所有顾客
        NSArray *arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾客状态",@"顾客注册日期",@"顾客",@"电话"];
        if(firstVisitType == 2){
            arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾客状态",@"顾客注册日期",@"自定义日期选择",@"顾客",@"电话"];
        }
        [_cusRowArrs addObjectsFromArray:arr];
    }else{
        NSArray *arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾客状态",@"顾客注册日期"];
        if(firstVisitType == 2){
            arr = @[@"顾客类型",@"顾客来源",@"注册方式",@"e账户",@"顾客状态",@"顾客注册日期",@"自定义日期选择"];
        }
        [_cusRowArrs addObjectsFromArray:arr];
    }
    return _cusRowArrs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *name = @"name";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:name];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:name];
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.textLabel.font = kFont_Light_16;
        cell.detailTextLabel.textColor = kColor_Editable;
        cell.detailTextLabel.font = kFont_Light_16;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *title = _cusRowArrs[indexPath.row];
    cell.textLabel.text = title;
    if([title isEqualToString:@"顾客来源"]){
        cell.detailTextLabel.text=st.Name;
    }
    if ([title isEqualToString:@"注册方式"]) {
        cell.detailTextLabel.text = [self registFromTitle];
    }
    if ([title isEqualToString:@"顾客类型"]) {
        cell.detailTextLabel.text = cust;
    }
    if ([title isEqualToString:@"e账户"]) {
        cell.detailTextLabel.text = ecard.CardName;
    }
    if ([title isEqualToString:@"顾问"]) {
        cell.detailTextLabel.text = self.personName;
    }
    if ([title isEqualToString:@"顾客状态"]) {
        cell.detailTextLabel.text = effectiveCustomer;
    }
    if ([title isEqualToString:@"顾客注册日期"]) {
        cell.detailTextLabel.text = firstVisit;
    }
    if ([title isEqualToString:@"自定义日期选择"]) {
        cell.detailTextLabel.text = self.firstVisitDateTime.length <=0 ? @"请选择自定义日期":self.firstVisitDateTime;
    }
    if ([title isEqualToString:@"顾客"]) {
        cell.detailTextLabel.text = self.customerName;
    }
    if ([title isEqualToString:@"电话"]) {
        cell.detailTextLabel.text = self.customerTel;
    }
    return cell;
}
- (NSString *)registFromTitle;
{
    NSString *title;
    switch (self.registFrom) {
        case -1:
        {
            title = @"全部";
        }
            break;

        case 0:
        {
            title = @"商家注册";
        }
            break;
        case 1:
        {
            title = @"顾客导入";
        }
            break;
        case 2:
        {
            title = @"自助注册(T站)";
        }
            break;
            
        default:
            break;
    }
    return title;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = _cusRowArrs[indexPath.row];
    if ([title isEqualToString:@"注册方式"]) {
        NSString *cancelString = @"取消";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"顾客类型选择" message:nil delegate:self cancelButtonTitle:cancelString otherButtonTitles: nil];
        NSArray *registFromArr = @[@"全部",@"商家注册",@"顾客导入",@"自助注册(T站)"];
        for (NSString *str in registFromArr) {
            [alter addButtonWithTitle:str];
        }
        alter.tag = 99;
        [alter show];

    }
    if ([title isEqualToString:@"顾客类型"]) {
        NSString *cancelString = @"取消";
        if (![[PermissionDoc sharePermission] rule_AllCustomer_Read]) {
            cancelString = nil;
        }
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"顾客类型选择" message:nil delegate:self cancelButtonTitle:cancelString otherButtonTitles: nil];
        
        for (NSString *str in custData) {
            [alter addButtonWithTitle:str];
        }
        alter.tag = 100;
        
        [alter show];
    }
    
    if ([title isEqualToString:@"e账户"]) {
        [self windowTest];
    }
    if([title isEqualToString:@"顾客来源"]){
        [self sourceTypeWindow];
    }
    if ([title isEqualToString:@"顾问"]) {
        [self chooseResponsiblePerson];
    }
    if ([title isEqualToString:@"顾客状态"]) {
        NSString *cancelString = @"取消";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"顾客状态选择" message:nil delegate:self cancelButtonTitle:cancelString otherButtonTitles: nil];
        
        for (NSString *str in effectiveCustomerTypeData) {
            [alter addButtonWithTitle:str];
        }
        alter.tag = 102;
        
        [alter show];
    }
    if ([title isEqualToString:@"顾客注册日期"]) {
        NSString *cancelString = @"取消";
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"顾客注册日期选择" message:nil delegate:self cancelButtonTitle:cancelString otherButtonTitles: nil];
        
        for (NSString *str in firstVisitTypeData) {
            [alter addButtonWithTitle:str];
        }
        alter.tag = 103;
        
        [alter show];
    }
    if([title isEqualToString:@"自定义日期选择"]){
         [self dateSelector:indexPath];
    }
    if([title isEqualToString:@"顾客"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"顾客姓名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = @"输入顾客姓名";
        self.textLength = 20;
        alert.tag = 104;
        
        [alert show];
    }
    if([title isEqualToString:@"电话"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"顾客电话" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"输入顾客电话";
        self.textLength = 11;
        alert.tag = 105;
        
        [alert show];
    }
}

#pragma mark 日期选择
- (void)dateSelector:(NSIndexPath *)indexPath
{
    DFDateView *dateView = [[DFDateView alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    dateView.startBlock = ^NSDate *{
         return [formatter dateFromString:self.firstVisitDateTime];
    };
    //dateView
    dateView.completionBlock = ^(NSDate *date){
        self.firstVisitDateTime = [formatter stringFromDate:date];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];;
    };
    [dateView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    if (alertView.tag == 99) {
        self.registFrom = buttonIndex - 2;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == 100) {
        cust = [alertView buttonTitleAtIndex:buttonIndex];
        cusType = buttonIndex - 1;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
     }
    if (alertView.tag == 101) {
        ecard = [ecardData objectAtIndex:(buttonIndex - 1)];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == 102) {
        self.effectiveCustomerType = buttonIndex - 1;
        effectiveCustomer = [alertView buttonTitleAtIndex:buttonIndex];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == 103) {
        self.firstVisitType = buttonIndex -1 ;
        firstVisit = [alertView buttonTitleAtIndex:buttonIndex];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == 104) {
        self.textLength = 0;
        self.customerName = [alertView textFieldAtIndex:0].text;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (alertView.tag == 105) {
        self.textLength = 0;
        self.customerTel = [alertView textFieldAtIndex:0].text;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark 美丽顾问选择
- (void)chooseResponsiblePerson
{
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    selectCustomer.accRange = ACCACCOUNT;
    [selectCustomer setSelectModel:1 userType:1 customerRange:CUSTOMERINBRANCH defaultSelectedUsers:self.personArray];
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择顾问"];
    [selectCustomer setPersonType:CustomePersonGroup];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
    
}

#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    self.personArray = [userArray mutableCopy];
    cust = @"我的顾客";
    cusType = 0;

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark WindowTest ---
- (void)windowTest
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"选择e账户" NumberOfRows:^NSInteger(NSInteger section) {
        return ecardData.count;
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        static NSString *ecardCell = @"ecardCell";
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:ecardCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecardCell];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
            label.tag = 100;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kColor_SysBlue;//[UIColor blueColor];
            
            label.font = kFont_Light_18;
            
            [cell.contentView addSubview:label];
            if (IOS8) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
        }
        UILabel *lab = (UILabel *)[cell viewWithTag:100];
        lab.text = ((EcardInfo *)ecardData[indexPath.row]).CardName;
        
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        ecard = ((EcardInfo *)ecardData[selectedIndex.row]);
        NSLog(@"selectedIndex");
        
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    } Completion:^{
        NSLog(@"Completion");
    }];
    
    [alert show];
}

#pragma mark WindowTest ---
- (void)sourceTypeWindow
{
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"选择顾客来源" NumberOfRows:^NSInteger(NSInteger section) {
        return sourceTypeData.count;
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
        lab.text = ((SourceType *)sourceTypeData[indexPath.row]).Name;
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        st= ((SourceType *)sourceTypeData[selectedIndex.row]);
        NSLog(@"selectedIndex");

        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    } Completion:^{
        NSLog(@"Completion");
    }];
    
    [alert show];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"金卡等级row%ld", (long)row];
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"CustomerFilterViewController TouchesBegan Event");

    NSLog(@"touchesBegan~~NSSet *)touches withEvent:(UIEvent *)event");
}
- (void)sourceTypeRequest
{
    NSDictionary * par =@{};
    _requestSourceType= [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/GetCustomerSourceType" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [(NSArray *)data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [sourceTypeData addObject:[[SourceType alloc] initWithDictionary:obj]];
                
            }];
            st = ((SourceType *)sourceTypeData[0]);
            [self levelRequest];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}
- (void)levelRequest
{
    NSDictionary * par =@{
                          @"isOnlyMoneyCard":@YES,
                          @"isShowAll":@YES
                          };
    _requestLevel = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBranchCardList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [(NSArray *)data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [ecardData addObject:[[EcardInfo alloc] initWithDictionary:obj]];
                
            }];
            
            ecard = ((EcardInfo *)ecardData[0]);
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Notification Method
-(void)textFieldEditChanged:(NSNotification *)obj
{
    if (self.textLength <= 0) {
        return;
    }
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])// 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > self.textLength)
            {
                textField.text = [toBeString substringToIndex:self.textLength];
            }
        }

    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > self.textLength)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:self.textLength];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:self.textLength];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.textLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

- (void)dealloc
{
    //当ViewController销毁前删除通知监听器
    NSLog(@"销毁前删除通知监听器");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
}

@end
