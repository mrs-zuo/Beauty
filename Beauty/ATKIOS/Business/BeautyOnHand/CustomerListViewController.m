//
//  CustomerListViewController.m
//  customerArray
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerListViewController.h"
#import "CustomerEditViewController.h"
#import "CustomerDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIButton+InitButton.h"
#import "NSString+Additional.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"

#import "UIActionSheet+AddBlockCallBacks.h"
#import "CacheInDisk.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "CustomerDoc.h"
#import "AppDelegate.h"

#import "PermissionDoc.h"
#import "CustomerFilterViewController.h"
#import "CustomerAddViewController.h"
#import "GPBHTTPClient.h"
#import "CusMainViewController.h"
#import "GPNavigationController.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "MJRefresh.h"
#define UPLATE_CUSTOMER_LIST_DATE  @"UPLATE_CUSTOMER_LIST_DATE"
#define TITLE     (type == 0 ? @"我的顾客" : (type == 1 ? @"所有顾客" : @"门店顾客"))
#define SECINDEXWIDTH   50.0f

@interface CustomerListViewController ()<CustomerEcardLevelDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestCustomerListOperation;
@property (weak , nonatomic)AFHTTPRequestOperation * requestUpdateOrderCustomerID;
@property (nonatomic) NavigationView *navigationView;
@property (nonatomic) NSMutableArray *customerArray;
@property (nonatomic) NSMutableArray *searchResultArray;
@property (nonatomic) NSMutableArray *customers;
//顾客类型
@property (nonatomic) NSInteger type; // type=0 我的顾客    type=1 公司顾客
///注册方式
@property (nonatomic,assign) NSInteger registFrom; // 0：商家注册 1：顾客导入 2：自助注册(T站)
//顾客来源
@property (nonatomic,assign) NSInteger sourceType;
//顾客日期标志位  0:全部  1:当日   2 手动输入
@property (nonatomic,assign) NSInteger firstVisitType;
//顾客有效无效标志位  0:全部  1:有效   2 无效
@property (nonatomic,assign) NSInteger effectiveCustomerType;
//顾客日期值
@property (nonatomic,assign) NSString  *firstVisitDateTime;
//顾客姓名
@property (nonatomic,strong) NSString  *customerName;
//顾客电话
@property (nonatomic,strong) NSString  *customerTel;
@property (assign, nonatomic) BOOL isSearching;
@property (nonatomic) CustomerDoc *customer_selected;
@property (nonatomic, assign) NSInteger customerIndex_selected;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (nonatomic, assign) NSInteger ecard;
@property (nonatomic, strong) NSString *respondID;
@property (nonatomic, assign) BOOL refresh;
@property (nonatomic, strong) UILabel   *indexTitleLabel;
@property (nonatomic, strong) NSMutableArray *sectionIndexArray;
@property (nonatomic, assign) BOOL pageFlg;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageIndex;
@property (assign, nonatomic) BOOL isDataMoreFlg;

@end

@implementation CustomerListViewController
@synthesize myListView;
@synthesize mySearchBar;
@synthesize navigationView;
@synthesize customers;
@synthesize customerArray;
@synthesize searchResultArray;
@synthesize customer_selected;
@synthesize isSearching;
@synthesize type;
@synthesize registFrom;
@synthesize sourceType;
@synthesize firstVisitType;
@synthesize effectiveCustomerType;
@synthesize firstVisitDateTime;
@synthesize accessoryInputView;
@synthesize ecard;
@synthesize respondID;
@synthesize refresh;
@synthesize indexTitleLabel;
@synthesize sectionIndexArray;
@synthesize pageFlg;
@synthesize pageIndex;
@synthesize pageSize;
@synthesize customerName;
@synthesize customerTel;
@synthesize isDataMoreFlg;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    self.pageFlg = NO;
    self.pageIndex = 1;
    self.pageSize = 200;
    registFrom = -1;
    sourceType=-1;
    firstVisitType = 0;
    effectiveCustomerType = 0;
    firstVisitDateTime = @"";
    self.ecard = -1;
    self.respondID = @"";
    self.refresh = YES;
    __weak CustomerListViewController *customerViewController = self;
    // 初期加载门店顾客
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:[NSString stringWithFormat:@"%ld_%ld_TYPE",(long)ACC_ACCOUNTID, (long)ACC_BRANCHID]];
    // 刷新数据
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (customerViewController.pageIndex > 1) {
                customerViewController.pageIndex = customerViewController.pageIndex - 1;
            }
            [customerViewController pullToRefreshData];
        });
    }];
    // 上拉加载更多
    [self.myListView addFooterWithTarget:self action:@selector(footerRefresh)];
    myListView.showsVerticalScrollIndicator = YES;
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_CUSTOMER_LIST_DATE];
    if (uploadDate) {
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
    
    self.myListView.sectionIndexColor = [UIColor blackColor];
    if ([self.myListView respondsToSelector:@selector(sectionIndexBackgroundColor)]) {
        self.myListView.sectionIndexBackgroundColor = [UIColor whiteColor];
    }
    self.myListView.sectionIndexTrackingBackgroundColor = [UIColor whiteColor];
    
    self.indexTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - SECINDEXWIDTH) / 2, ([UIScreen mainScreen].bounds.size.height - SECINDEXWIDTH) / 2 - 60.0, SECINDEXWIDTH, SECINDEXWIDTH)];
    self.indexTitleLabel.layer.masksToBounds = YES;
    self.indexTitleLabel.layer.cornerRadius = 8.0;
    self.indexTitleLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    self.indexTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.indexTitleLabel.font = [UIFont boldSystemFontOfSize:48.0f];
    self.indexTitleLabel.alpha = 0;
    [self.view addSubview:self.indexTitleLabel];
    self.sectionIndexArray = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pageIndex = 1;

    type = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld_%ld_TYPE",(long)ACC_ACCOUNTID, (long)ACC_BRANCHID]] integerValue];
    
    if (![[PermissionDoc sharePermission] rule_AllCustomer_Read]) {
        type = 0;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:type] forKey:[NSString stringWithFormat:@"%ld_%ld_TYPE",(long)ACC_ACCOUNTID, (long)ACC_BRANCHID]];
    }
    // 所有顾客分页
    if (type == 1) {
        // 隐藏筛选框
        self.mySearchBar.hidden = NO;
        // 分页
        self.pageFlg = YES;
    }else{
        self.pageFlg = NO;
    }
    
    navigationView.titleLabel.text = TITLE;
    if (refresh) {
        [myListView triggerPullToRefresh];
    }
    [self searchAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.searchString) {
        mySearchBar.text = self.searchString;
        [self searchBar:mySearchBar textDidChange:self.searchString];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    mySearchBar.text = @"";
    if (_requestCustomerListOperation && [_requestCustomerListOperation isExecuting]) {
        [_requestCustomerListOperation cancel];
        _requestCustomerListOperation = nil;
    }
    self.refresh = YES;
}

- (void)didnotRefresh
{
    self.refresh = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init

- (UIImage *)backgroundImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, kColor_Background_View.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)initView
{
    if (self.returnViewTag ==1) {
        UIButton *goBackButton = [UIButton 	buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(goBackView)
                                                     frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                             backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                          highlightedImage:nil];
        
        UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
        self.navigationItem.leftBarButtonItem = goBackBarButton;
    }


    isSearching = NO;
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    mySearchBar.placeholder = @"来搜索你想要找的人吧!";
    mySearchBar.hidden = YES;
    mySearchBar.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 44);
    mySearchBar.delegate = self;
    [mySearchBar setBackgroundImage:[self backgroundImage]];
    [mySearchBar setBackgroundImage:[self backgroundImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [self.view addSubview:mySearchBar];
    if ((IOS7 || IOS8)) {
        mySearchBar.barTintColor = kColor_Background_View;//[UIColor clearColor];
    }
    
    /*
    if (![[PermissionDoc sharePermission] rule_AllCustomer_Read] ) {
        if (![[PermissionDoc sharePermission] rule_CustomerInfo_Write] || ACC_BRANCHID == 0) {
            // search Button
            UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                        target:self
                                                      selector:@selector(searchAction)
                                                         frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                                 backgroundImg:[UIImage imageNamed:@"icon_Search"]
                                              highlightedImage:nil];
            
            navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:TITLE];
            [navigationView addSubview:searchButton];
            [self.view addSubview:navigationView];
        } else {
            //addCustomer Button
            UIButton *addCusButton = [UIButton buttonWithTitle:@""
                                                        target:self
                                                      selector:@selector(addCustomerAction)
                                                         frame:CGRectMake( 314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                                 backgroundImg:[UIImage imageNamed:@"icon_AddUser"]
                                              highlightedImage:nil];
            
            // search Button
            UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                        target:self
                                                      selector:@selector(searchAction)
                                                         frame:CGRectMake(CGRectGetMinX(addCusButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                                 backgroundImg:[UIImage imageNamed:@"icon_Search"]
                                              highlightedImage:nil];
            
            navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:TITLE];
            [navigationView addSubview:addCusButton];
            [navigationView addSubview:searchButton];
            [self.view addSubview:navigationView];
        }
    } else {  
     */
    
//    if (![[PermissionDoc sharePermission] rule_CustomerInfo_Write] || ACC_BRANCHID == 0) {
//            // filterButton
//            UIButton *filterButton = [UIButton buttonWithTitle:@""
//                                                        target:self
//                                                      selector:@selector(filterAction)
//                                                         frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
//                                                 backgroundImg:[UIImage imageNamed:@"orderAdvancedFilterIcon"]
//                                              highlightedImage:nil];
//            
//            // search Button
////            UIButton *searchButton = [UIButton buttonWithTitle:@""
////                                                        target:self
////                                                      selector:@selector(searchAction)
////                                                         frame:CGRectMake(CGRectGetMinX(filterButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
////                                                 backgroundImg:[UIImage imageNamed:@"icon_Search"]
////                                              highlightedImage:nil];
//        
//            navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:TITLE];
//            [navigationView addSubview:filterButton];
////            [navigationView addSubview:searchButton];
//            [self.view addSubview:navigationView];
//        } else {
            //addCustomer Button
            UIButton *addCusButton = [UIButton buttonWithTitle:@""
                                                        target:self
                                                      selector:@selector(addCustomerAction)
                                                         frame:CGRectMake( 314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                                 backgroundImg:[UIImage imageNamed:@"icon_AddUser"]
                                              highlightedImage:nil];
            
            // filterButton
            UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                        target:self
                                                      selector:@selector(filterAction)
                                                         frame:CGRectMake(CGRectGetMinX(addCusButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                                 backgroundImg:[UIImage imageNamed:@"orderAdvancedFilterIcon"]
                                              highlightedImage:nil];
            
            // search Button
//            UIButton *searchButton = [UIButton buttonWithTitle:@""
//                                                        target:self
//                                                      selector:@selector(searchAction)
//                                                         frame:CGRectMake(CGRectGetMinX(filterButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
//                                                 backgroundImg:[UIImage imageNamed:@"icon_Search"]
//                                              highlightedImage:nil];
            
            navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:TITLE];
            [navigationView addSubview:filterButton];
            [navigationView addSubview:addCusButton];
//            [navigationView addSubview:searchButton];
            [self.view addSubview:navigationView];
//        }
//    }
    
    myListView.delegate = self;
    myListView.dataSource = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = NO;
    myListView.autoresizingMask = UIViewAutoresizingNone;
    myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 20.0f - (navigationView.frame.size.height + 5.0f) - 49.0f);
}

- (void)goBackView
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - titleButton
- (void)setCustomerEcardLevel:(NSInteger)level responID:(NSString *)personID registFrom:(NSInteger)regFrom sourceType:(NSInteger)stID stIDInt:(NSInteger)firstVisitTypeValue firstVisitTypeInt:(NSString *)firstVisitDateTimeValue firstVisitDateTimeString:(NSInteger) effectiveCustomerTypeValue
    searchCustomerName:(NSString *) customerName searchCustomerTel:(NSString *) customerTel
{
    self.registFrom = regFrom;
    self.ecard = level;
    self.respondID = personID;
    self.refresh = YES;
    self.sourceType=stID;
    self.firstVisitType = firstVisitTypeValue;
    self.firstVisitDateTime = firstVisitDateTimeValue;
    self.effectiveCustomerType = effectiveCustomerTypeValue;
    self.customerName = customerName;
    self.customerTel = customerTel;
//    int64_t delayInSeconds = 0.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//    });
}

- (void)filterAction
{
    [mySearchBar resignFirstResponder];
    mySearchBar.text = @"";
    isSearching = NO;
//    [self requesCustomertList];
    [UIView beginAnimations:@"" context:nil];
    mySearchBar.hidden = YES;
    mySearchBar.frame = CGRectMake(0.0f, kORIGIN_Y - 44.0f, kSCREN_BOUNDS.size.width, 44.0f);
    navigationView.frame = CGRectMake(0.0f, kORIGIN_Y + 5.0f, 320.0f, HEIGHT_NAVIGATION_VIEW);
    myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 20.0f - (navigationView.frame.size.height + 5) - 49.0f);
    [UIView commitAnimations];
    
    
    CustomerFilterViewController *cusFilter = [[CustomerFilterViewController alloc] init];
    cusFilter.registFrom = registFrom;
    cusFilter.cusType = type;
    cusFilter.sourceType=sourceType;
    cusFilter.firstVisitType = firstVisitType;
    cusFilter.effectiveCustomerType = effectiveCustomerType;
    cusFilter.firstVisitDateTime = firstVisitDateTime;
    cusFilter.customerName = customerName;
    cusFilter.customerTel = customerTel;
    cusFilter.delegate = self;
    [self.navigationController pushViewController:cusFilter animated:YES];
}

- (void)addCustomerAction
{
    CustomerAddViewController *customerAdd = [[CustomerAddViewController alloc] init];
    CustomerDoc *addCustomerDoc = [[CustomerDoc alloc] init];
    addCustomerDoc.cus_ResponsiblePersonID = ACC_ACCOUNTID;
    addCustomerDoc.cus_ResponsiblePersonName = ACC_ACCOUNTName;
    customerAdd.newcustomer = addCustomerDoc;
    
    [self.navigationController pushViewController:customerAdd animated:YES];
    
//    [self performSegueWithIdentifier:@"goCustomerEditViewFromCustomerList" sender:self];
}

- (void)searchAction
{
    NSLog(@"searchAction mySearchBar.isHidden:%@",mySearchBar.isHidden?@"YES":@"NO");
    if (mySearchBar.isHidden) {
        [UIView beginAnimations:@"" context:nil];
        mySearchBar.hidden = NO;
        mySearchBar.frame = CGRectMake(0.0f, kORIGIN_Y, kSCREN_BOUNDS.size.width, 44.0f);
        
        CGRect rect_Search = navigationView.frame;
        rect_Search.origin.y = mySearchBar.frame.origin.y + mySearchBar.frame.size.height;
        navigationView.frame = rect_Search;
        
        myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height , 310.0f, kSCREN_BOUNDS.size.height - 20.0f - (navigationView.frame.size.height + 5.0f) - 43.0f - 44.f);
        [UIView commitAnimations];
    } else {
        [mySearchBar resignFirstResponder];
        //mySearchBar.text = @"";
        isSearching = NO;
        
        //[self requesCustomertList];
        
        
        [UIView beginAnimations:@"" context:nil];
        mySearchBar.hidden = YES;
        mySearchBar.frame = CGRectMake(0.0f, kORIGIN_Y - 44.0f, kSCREN_BOUNDS.size.width, 44.0f);
        navigationView.frame = CGRectMake(0.0f, kORIGIN_Y , 320.0f, HEIGHT_NAVIGATION_VIEW);
        myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 20.0f - (navigationView.frame.size.height + 5) - 43.0f );
        [UIView commitAnimations];
    }
}

#pragma mark - pull

- (void)pullToRefreshData
{
    NSLog(@"pullToRefreshData");
    #if defined(DEBUG) || defined(_DEBUG)
        NSLog(@"isSearching =%@",isSearching?@"YES":@"NO");
    #endif
    if (!isSearching) {
        if (_requestCustomerListOperation && [_requestCustomerListOperation isExecuting]) {
            [_requestCustomerListOperation cancel];
        }
        
        [self requesCustomertList];
    } else {
        [self pullToRefreshDone];
    }
}

- (void)pullToRefreshDone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"上次更新时间: MM/dd hh:mm:ss"];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_CUSTOMER_LIST_DATE];
    [myListView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [myListView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.6f];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [customers count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [customers[section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexArray;
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    self.indexTitleLabel.text = title;
//    self.indexTitleLabel.alpha = 0.9;
//    self.indexTitleLabel.font = kFont_Light_16;
//    [UIView animateWithDuration:2.0 animations:^{
//        self.indexTitleLabel.alpha = 0;
//    }];
//    NSUInteger tmpIndex = [self.sectionIndexArray indexOfObject:title];
//    return tmpIndex;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    static NSString *heard = @"Heard";
//    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:heard];
//    headerView.textLabel.font = kFont_Light_16;
//    if (!headerView) {
//        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:heard];
//    }
//    headerView.textLabel.text = self.sectionIndexArray[section];
//    headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.877 alpha:1];
    
    UIView * view  =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 20)];
    view.backgroundColor = [UIColor colorWithWhite:0.877 alpha:1];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 300, 24)];
    lable.font = kFont_Light_16;
    lable.alpha = 0.7;
    lable.text = self.sectionIndexArray[section];
    [view addSubview:lable];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    titleLabel.font = kFont_Light_16;
    //wugang->
    titleLabel.textColor = kColor_SysBlue;
    //<-wugang
    UILabel *subLabel = (UILabel *)[cell.contentView viewWithTag:102];
    [subLabel setTextAlignment:NSTextAlignmentRight];
    //wugang->
    subLabel.textColor = kColor_SysBlue;
    //<-wugang
    
    UIButton *checkButton = (UIButton *)[cell.contentView viewWithTag:103];
//    [checkButton setBackgroundImage:[UIImage imageNamed:@"icon_unChecked"] forState:UIControlStateNormal];
//    [checkButton setBackgroundImage:[UIImage imageNamed:@"icon_Checked"] forState:UIControlStateSelected];
//    [checkButton addTarget: self action:@selector(checkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    CustomerDoc *custerData = [customers[indexPath.section] objectAtIndex:indexPath.row];
//    if (appDelegate.customer_Selected && appDelegate.customer_Selected.cus_ID == custerData.cus_ID)
//
//    }
    if (appDelegate.customer_Selected) {
        if (appDelegate.customer_Selected.cus_ID == custerData.cus_ID) {
           appDelegate.selCustomerIndexPath = indexPath;
        }
    }
    

    [imageView setImageWithURL:[NSURL URLWithString:custerData.cus_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    [titleLabel setText:custerData.cus_Name];
    [subLabel setText:custerData.cus_LoginMobile];
    
    if (appDelegate.customer_Selected.cus_ID == custerData.cus_ID) {
        checkButton.selected = YES;
    } else {
        checkButton.selected = NO;
    }
    
    
    //上门未上门标志
    UILabel *comeTimeLabel = (UILabel *)[cell.contentView viewWithTag:104];
    if(comeTimeLabel !=nil ){
        [comeTimeLabel setTextAlignment:NSTextAlignmentRight];
        //comeTimeLabel.font = kFont_Light_16;
        if(custerData.cus_ComeTime !=nil && ![custerData.cus_ComeTime isEqualToString:@""]){
            comeTimeLabel.text = [@"最后上门日期:" stringByAppendingString:custerData.cus_ComeTime];
            //comeTimeLabel.text = @"上门";
        }else{
            comeTimeLabel.text = @"未上门";
        }
    }
    comeTimeLabel.textColor = kColor_SysBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CustomerDoc *customerDoc = [customers[indexPath.section] objectAtIndex:indexPath.row];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.selCustomerIndexPath = indexPath;

    if (app.customer_Selected != nil && app.customer_Selected.cus_ID != customerDoc.cus_ID) {
        [app.commodityArray_Selected removeAllObjects];
        [app.serviceArray_Selected removeAllObjects];
        [app.awaitOrderArray removeAllObjects];
    }

    if (self.returnViewTag ==1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"转换顾客确认!" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self UpdateOrderCustomerID:customerDoc];
            }
        }];
    } else if (self.returnViewTag == 2) {
        customerDoc.refreshType = CustomerRefreshTypeAll;
        app.customer_Selected = customerDoc;
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        app.customer_Selected = customerDoc;
        [self moveToCusMainViewController];
    }
}

- (void)moveToCusMainViewController
{
    CusMainViewController *cusMainVC = [[CusMainViewController alloc] init];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
    GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:cusMainVC];
    //navCon.navigationBar.translucent = YES;
    navCon.canDragBack = YES;
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = navCon;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self initInputAccessoryView];
    searchBar.inputAccessoryView = accessoryInputView;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0) {
        [self setIsSearching:YES];
        [self initSearchArrayByText:searchText];
        self.sectionIndexArray = [CustomerDoc sortIndexOfCustomerDoc:searchResultArray];

        customers = [CustomerDoc sortCustomerDocWithFirstLetter:self.sectionIndexArray customerArray:searchResultArray];
//        customers = [NSMutableArray arrayWithArray:searchResultArray];
        [myListView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        [self requesCustomertList];
    }
}

- (void)initSearchArrayByText:(NSString *)text
{
    if (!searchResultArray) {
        searchResultArray = [NSMutableArray array];
    } else {
        [searchResultArray removeAllObjects];
    }
    
    NSString *string = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (CustomerDoc *customerDoc in customerArray) {
        if ([customerDoc.cus_Name containsString:string]        ||
            [customerDoc.cus_QuanPinYin containsString:string]  ||
            [customerDoc.cus_ShortPinYin containsString:string] ||
            [customerDoc.cus_OriginalLoginMobile containsString:string] ||
            [customerDoc.cus_Phones containsString:string])
        {
            [searchResultArray addObject:customerDoc];
        }
    }
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mySearchBar resignFirstResponder];
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)dismissKeyboard
{
    [mySearchBar resignFirstResponder];
}

//废止
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goCustomerEditViewFromCustomerList"]) {
        CustomerEditViewController *customerEditController = segue.destinationViewController;
        CustomerDoc *addCustomerDoc = [[CustomerDoc alloc] init];
        addCustomerDoc.cus_ResponsiblePersonID = ACC_ACCOUNTID;
        addCustomerDoc.cus_ResponsiblePersonName = ACC_ACCOUNTName;
        customerEditController.customerDoc = addCustomerDoc;
        customerEditController.isEditing = NO;
    }
}
*/
#pragma mark - 接口

- (void)UpdateOrderCustomerID:(CustomerDoc *)custumeDoc
{
    [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeClear];
    NSMutableArray *listArr = [[NSMutableArray alloc] init];
    for (OrderDoc *tmpOrderDoc in self.OrderArr) {
        NSDictionary * dic = @{
                                @"OrderID":@((long)tmpOrderDoc.order_ID),
                                @"OrderObjectID":@((long)tmpOrderDoc.order_ObjectID),
                                @"ProductType":@((long)tmpOrderDoc.order_ProductType),
                                @"CustomerID":@((long)custumeDoc.cus_ID)
                               };
        [listArr addObject:dic];
    }
    NSDictionary * par = @{@"List":listArr};
    _requestUpdateOrderCustomerID = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateOrderCustomerID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:2.0 touchEventHandle:^{
                [SVProgressHUD dismiss];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                app.customer_Selected = custumeDoc;//保存选中顾客

                [_delegate dismissViewControllerWithSelectedCustomerName:custumeDoc.cus_Name customerId:custumeDoc.cus_ID];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requesCustomertList
{
    NSString *par = nil;
    par = @"{";
    if (ecard == -1) {
        par = [par stringByAppendingString:[NSString stringWithFormat:@"\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%ld,\"RegistFrom\":%ld,\"CardCode\":\"\",\"AccountIDList\":[%@],\"SourceType\":%ld,\"FirstVisitType\":%ld,\"FirstVisitDateTime\":\"%@\",\"EffectiveCustomerType\":%ld",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)type,(long)registFrom,self.respondID,(long)self.sourceType,(long)self.firstVisitType,self.firstVisitDateTime,(long)self.effectiveCustomerType]];
    } else {
        NSLog(@"(long)ecard =%ld",(long)ecard);
        par = [par stringByAppendingString:[NSString stringWithFormat:@"\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%ld,\"RegistFrom\":%ld,\"CardCode\":%ld,\"AccountIDList\":[%@],\"SourceType\":%ld,\"FirstVisitType\":%ld,\"FirstVisitDateTime\":\"%@\",\"EffectiveCustomerType\":%ld", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)type,(long)registFrom,(long)ecard, self.respondID,(long)self.sourceType,(long)self.firstVisitType,self.firstVisitDateTime,(long)self.effectiveCustomerType]];
    }
    // 分页
    if (self.pageFlg) {
        par = [par stringByAppendingString:[NSString stringWithFormat:@",\"PageFlg\":%@",@"true"]];
        par = [par stringByAppendingString:[NSString stringWithFormat:@",\"PageIndex\":%d",(int)self.pageIndex]];
        par = [par stringByAppendingString:[NSString stringWithFormat:@",\"PageSize\":%d",(int)self.pageSize]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss:SSS"];
        par = [par stringByAppendingString:[NSString stringWithFormat:@",\"SearchDateTime\":\"%@\"",[formatter stringFromDate:[NSDate date]]]];
    }
    // 所有顾客
    if(self.type == 1){
        if (self.customerName.length > 0) {
            par = [par stringByAppendingString:[NSString stringWithFormat:@",\"CustomerName\":\"%@\"",self.customerName]];
        }
        if (self.customerTel.length > 0) {
            par = [par stringByAppendingString:[NSString stringWithFormat:@",\"CustomerTel\":\"%@\"",self.customerTel]];
        }
        
    }
    par = [par stringByAppendingString:@"}"];
    NSLog(@"par =%@",par);
    
    _requestCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson2:json showErrorMsg:NO success:^(id data ,NSUInteger dataCnt ,NSInteger code ,id message) {
            [self pullToRefreshDone];
            self.view.userInteractionEnabled = NO;
            if (!customerArray)
                customerArray = [NSMutableArray array];
            else
                [customerArray removeAllObjects];
            
            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
            for (NSDictionary *dict in data){
                CustomerDoc *customerDoc = [[CustomerDoc alloc] init];
                [customerDoc setCus_ID:[[dict objectForKey:@"CustomerID"] integerValue]];
                [customerDoc setCus_Name:[dict objectForKey:@"CustomerName"]];
                [customerDoc setCus_QuanPinYin:[dict objectForKey:@"PinYin"]];
                [customerDoc setCus_ShortPinYin:[dict objectForKey:@"PinYinFirst"]];
                [customerDoc setCus_HeadImgURL:[dict objectForKey:@"HeadImageURL"]];
                [customerDoc setCus_LoginMobile:[dict objectForKey:@"LoginMobile"]];
                [customerDoc setCus_IsMyCustomer:[[dict objectForKey:@"IsMyCustomer"] boolValue]];
                [customerDoc setCus_Phones:[dict objectForKey:@"Phone"]];
                [customerDoc setCus_ComeTime:[dict objectForKey:@"ComeTime"]];
                [customerArray addObject:customerDoc];
                if (appDelegate.customer_Selected && appDelegate.customer_Selected.cus_ID == customerDoc.cus_ID)
                    _customerIndex_selected = customerArray.count - 1;
            }
            if (customerArray.count > 0)
                if (self.pageFlg) {
                    long startPos = (self.pageIndex - 1) * self.pageSize + 1;
                    long endPos = self.pageIndex * self.pageSize;
                    if (endPos >= dataCnt) {
                        self.isDataMoreFlg = NO;
                        endPos = dataCnt;
                    }else{
                        self.isDataMoreFlg = YES;
                    }
                    if (startPos > endPos) {
                        startPos = endPos;
                    }
                    [navigationView setSecondLabelText:[NSString stringWithFormat:@"（共%zd-%zd/%zd位）", startPos, endPos, (long)dataCnt]];
                }else{
                    [navigationView setSecondLabelText:[NSString stringWithFormat:@"（共%zd位）",(unsigned long)customerArray.count ]];
                }
            else
                [navigationView setSecondLabelText:@""];
            if (!customers)
                customers = [NSMutableArray array];
            else
                [customers removeAllObjects];
            if (self.sectionIndexArray) {
                [self.sectionIndexArray removeAllObjects];
            }
            self.sectionIndexArray = [CustomerDoc sortIndexOfCustomerDoc:customerArray];
            customers = [CustomerDoc sortCustomerDocWithFirstLetter:self.sectionIndexArray customerArray:customerArray];
            // 找索引
            NSInteger sec = 0;
            NSInteger row = 0;
            if (customers.count > 0) {
                for (int i = 0; i <customers.count; i ++) {
                    NSArray *temps = [customers objectAtIndex:i];
                    if (temps.count > 0) {
                        for (int j = 0; j < temps.count; j ++) {
                            CustomerDoc *customerDoc = temps[j];
                            if (appDelegate.customer_Selected) {
                                if (appDelegate.customer_Selected.cus_ID == customerDoc.cus_ID){
                                    sec = i;
                                    row = j;
                                }
                            }
                           
                        }
                    }
                }
            }
            [myListView footerEndRefreshing];
            [myListView reloadData];
            if (appDelegate.customer_Selected && customerArray.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sec];
                [myListView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            self.view.userInteractionEnabled = YES;
        } failure:^(NSInteger code, NSString *error) {
            [navigationView setSecondLabelText:@""];
            [self pullToRefreshDone];
        }];
    } failure:^(NSError *error) {
        [navigationView setSecondLabelText:@""];
        [self pullToRefreshDone];
    }];
}

-(void)footerRefresh
{
    if (self.pageFlg && self.isDataMoreFlg) {
        self.pageIndex = self.pageIndex + 1;
        [self pullToRefreshData];
    }else{
        [myListView footerEndRefreshing];
    }
}

@end
