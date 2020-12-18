//
//  OrderListViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderDetailViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "PayInfoViewController.h"
#import "NavigationView.h"
#import "UILabel+InitLabel.h"
#import "OrderListCell.h"
#import "DEFINE.h"
#import "NSObject+dictionaryWithProperty.h"
#import "MJRefresh.h"
#import "noCopyTextField.h"
#import "OrderRootViewController.h"
#import "GPNavigationController.h"
#import "OrderFilterViewController.h"
#import "NSDate+Convert.h"

#import "GPBHTTPClient.h"
#import "ZXOrderFilterViewController.h"
#import "ZXOrderSearchViewController.h"


#define REQUEST_ORDER_DATE  @"REQUEST_ORDER_DATE"
#define PICKERVIEW_X  (IOS8 ? -8 : 0)


@interface OrderListViewController () <ZXOrderFilterViewControllerDelegate,ZXOrderSearchViewControllerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestOrderListByCustomerIdOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestOrderListByAccountIdOperation;
@property (strong, nonatomic) NSMutableArray *orderArray;
@property (strong, nonatomic) NSMutableArray *tmpOrderArray;
@property (strong, nonatomic) OrderFilterDoc *orderFilter;
@property (strong, nonatomic) OrderFilterDoc *orderFilterOld;

@property (strong, nonatomic) NSArray *statusArray;
@property (strong, nonatomic) NSArray *paidArray;
@property (strong, nonatomic) NSArray *typeArray;

// --view
@property (nonatomic, strong) UIAlertController *alertController;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *accessoryInputView;

@property (assign, nonatomic) NSInteger temporary_Status;           //-1：全部、1：进行中、2：已完成、3：已取消、4：已终止、5：待确认
@property (assign, nonatomic) NSInteger temporary_Type;             //-1：全部、0：服务、1：商品
@property (assign, nonatomic) NSInteger temporary_IsPaid;           //-1：全部、0：未支付、1：已支付
@property (nonatomic, copy)   NSString *order_creat;
@property (assign, nonatomic) NSInteger view_Type;
@property (assign, nonatomic) NSInteger pageSize;                   //size of every page
@property (assign, nonatomic) NSInteger recordCount;
@property (assign, nonatomic) NSInteger currentPage;                  //current page (if will get the next page , we should send ++pageCount)
@property (assign, nonatomic) BOOL isFirstIn;                      //是否第一次进入当前页面

@property (assign, nonatomic) CGPoint startTouch;                   //gesture
@property (assign, nonatomic) BOOL isMoving;                        //gesture
@property (assign, nonatomic) BOOL isGone;

@property (nonatomic, assign) NSInteger filterByTimeFlag;
//timeSearch
@property (strong, nonatomic) UITextField *textField_Selected;
@property (nonatomic, assign) NSInteger refresh_Flag;
@property (nonatomic, assign) NSInteger theBranch;
@property (strong, nonatomic) NavigationView *navigationView;
@property (nonatomic ,assign ) NSInteger orderObjectID;

@property (nonatomic,copy) NSString *searchFieldText;


@end

@implementation OrderListViewController
@synthesize orderArray,tmpOrderArray;
@synthesize orderID_Selected, productType_Selected;
@synthesize requestStatus;
@synthesize requestType;
@synthesize requestIsPaid;
@synthesize statusArray, paidArray, typeArray;
@synthesize navTitle;
@synthesize temporary_Status;
@synthesize temporary_Type;
@synthesize temporary_IsPaid;
@synthesize lastView;
@synthesize view_Type;
//time Search
@synthesize textField_Selected;
@synthesize filterByTimeFlag = _filterByTimeFlag;
@synthesize refresh_Flag;
@synthesize theBranch;
@synthesize order_creat;
@synthesize searchFieldText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLayout];
    [self initData];
    _comeFromOrderFilter = 0;
    searchFieldText = @"";
//    if ( !kMenu_Type ) {
        [self.tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
        [self.tableView addFooterWithTarget:self action:@selector(footerRefresh)];
        
//    }

}

- (void)setFilterByTimeFlag:(NSInteger)filterByTimeFlag
{
    if (_filterByTimeFlag != filterByTimeFlag) {
        if (self.tableView.footerHidden) {
            self.tableView.footerHidden = NO;
        }
    }
    _filterByTimeFlag = filterByTimeFlag;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.clearStack){
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSInteger count = array.count;
        for(int i = 0; i < count - 1 ; i++) {
            [array removeObjectAtIndex:0];
        }
        [self.navigationController setViewControllers:array];
        self.clearStack = NO;
        GPNavigationController *navigation = (GPNavigationController *)self.navigationController;
        navigation.canDragBack = YES;
        
        if (lastView == 5){
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
            panGesture.delegate = self;
            [self.view addGestureRecognizer:panGesture];
            _isGone = NO;
        }
    }
    if ((lastView == 0 || lastView == 5) && _comeFromOrderFilter == 0) {
        requestStatus = _orderFilter.orderStatus;
        requestType = _orderFilter.orderType;
        requestIsPaid = _orderFilter.orderIsPaid;
        _comeFromOrderFilter = 1;
    }
    if (_isFirstIn){ //仅在此处使用，copy初始状态，从右侧进入order filter使用该copy
        temporary_Type = requestType;
        temporary_Status = requestStatus;
        temporary_IsPaid = requestIsPaid;
        _isFirstIn = NO;
    }
    
    order_creat = @"";
    view_Type = 1;
    self.filterByTimeFlag = 0;
    refresh_Flag = 0 ;

    if (self.tableView.footerHidden) {
        self.tableView.footerHidden = NO;
    }
 
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    if ((IOS7 || IOS8)){
        self.edgesForExtendedLayout= UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //[self done:nil];
    refresh_Flag = 0;
    _currentPage = 0;
    
    if (self.comeFromOrderFilter == 5) {
        _comeFromOrderFilter = 1;
    } else {
        if (orderArray)
            [orderArray removeAllObjects];
        else
            orderArray = [NSMutableArray array];
        [self requestList];
    }
}

- (void)donotRefresh
{
    _orderFilter = _orderFilterOld;
    self.comeFromOrderFilter = 5;
}
//解决手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)panGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
{
   // NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>   %d",gestureRecognizer.state);
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        if(!_isMoving) {
            _startTouch = [gestureRecognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
            _isMoving = YES;
        }
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint point =  [gestureRecognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
        if(point.x - _startTouch.x > 80.f && point.y  - _startTouch.y < 30.f){
            [self gotoPage:lastView];
        }
        _isMoving = NO;
    }else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        _isMoving = NO;
    }
}
-(void)gotoPage:(NSInteger)page
{
    if(lastView == 5 && !_isGone){
        OrderRootViewController *orderRootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderRootViewController"];
        orderRootViewController.clearStack = YES; //清空视图的压栈
        //视图压栈时，进入的方向（由左进入，默认是右）
        CATransition *transition = [CATransition animation];
        transition.duration = .3;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.navigationController.view.layer  addAnimation:transition forKey:nil];
        
        GPNavigationController *navigation = (GPNavigationController *)self.navigationController;
        navigation.canDragBack = NO; //修正偶尔会出现一闪而过的白屏
        
        [self.navigationController pushViewController:orderRootViewController animated:YES];
        _isGone = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestOrderListByCustomerIdOperation && [_requestOrderListByCustomerIdOperation isExecuting]) {
        [_requestOrderListByCustomerIdOperation cancel];
    }
    
    if (_requestOrderListByAccountIdOperation && [_requestOrderListByAccountIdOperation isExecuting]) {
        [_requestOrderListByAccountIdOperation cancel];
    }
    _requestOrderListByCustomerIdOperation = nil;
    _requestOrderListByAccountIdOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    self.tableView.showsInfiniteScrolling = NO;
}

- (void)initData
{
    typeArray = [NSMutableArray arrayWithObjects: @"全部", @"服务", @"商品", nil];
    paidArray = [NSMutableArray arrayWithObjects: @"全部", @"未支付", @"部分付", @"已支付", nil];
    statusArray = [NSMutableArray arrayWithObjects: @"全部", @"未完成", @"待确认", @"已完成", @"已取消", nil];
    _orderFilter = [[OrderFilterDoc alloc] init];
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 0) {
        NSData *date =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ACCOUNT-%ld-BRANCH-%ld",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
        _orderFilter = [NSKeyedUnarchiver unarchiveObjectWithData:date];
        if (!_orderFilter) {
            _orderFilter = [OrderFilterDoc new];
//            UserDoc *user = [[UserDoc alloc] init];
//            user.user_Name = ACC_ACCOUNTName;
//            user.user_Id = ACC_ACCOUNTID;
//            [_orderFilter.accountArray addObject:user];
        }
    }
    _pageSize = 10;
    _isFirstIn = YES;
}

- (void)initLayout
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    navTitle = [appDelegate.customer_Selected.cus_Name stringByAppendingString:@"的订单"];

    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0 ? ([[PermissionDoc sharePermission] rule_BranchOrder_Read] ? @"订单" : @"与我相关的订单") : navTitle];

    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterButton:)];
    _navigationView.tag = 10;
    [self.view addSubview:_navigationView];
    
    [_navigationView addButton1WithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Search"] selector:@selector(searchButton:)];
    _navigationView.tag = 11;
    [self.view addSubview:_navigationView];

    
    
    _tableView.frame = CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + _navigationView.frame.size.height) - 5.0f);
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor whiteColor];
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    if (self.viewTag == 1) {
         _tableView.frame = CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + _navigationView.frame.size.height)-49);
    }
    
    if ((IOS7 || IOS8)){
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
}
#pragma mark -refresh
- (void)headerRefresh
{
    [orderArray removeAllObjects];
    _currentPage = 0;
    order_creat = @"";
    view_Type = 1;

    if (self.tableView.footerHidden == YES) {
        self.tableView.footerHidden = NO;
        refresh_Flag = 0;
    }

    [self requestList];
}

- (void)footerRefresh
{
    OrderDoc *orderDoc = [orderArray firstObject];
    order_creat = orderDoc.order_CreateTime;
    view_Type = 0;
    
    if (refresh_Flag == 3 || orderArray.count == _recordCount) {
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus2:@"没有更多数据了" touchEventHandle:^{}];
        self.tableView.footerHidden = YES;
    } else {
        [self requestList];
    }
}

#pragma mark - Action

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -orderfilter
-(void)dismissViewControllerWithDoc:(OrderFilterDoc *)orderFilter
{
//    NSLog(@"%ld %ld %ld, account %@  user %@ time %@  %@",orderFilter.orderType, orderFilter.orderStatus, orderFilter.orderIsPaid
//          ,orderFilter.account_Name,orderFilter.user_Name,orderFilter.startTime,orderFilter.endTime);
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%ld",(long)ACC_ACCOUNTID]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 0){
//        NSMutableDictionary *dict = [orderFilter dictionaryWithProperty]; ACCOUNTID-%ld-BRANCHID-%ld
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:orderFilter];

        [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"ACCOUNT-%ld-BRANCH-%ld",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    }
    searchFieldText = @"";
    _orderFilter = orderFilter;
    requestType = orderFilter.orderType;
    requestStatus = orderFilter.orderStatus;
    requestIsPaid = orderFilter.orderIsPaid;
    _comeFromOrderFilter = 1;
}
#pragma mark -  ZXOrderSearchViewControllerDelegate

- (void)ZXOrderSearchViewController:(ZXOrderSearchViewController *)orderSearchViewController searchBar:(UISearchBar *)searchBar
{
    searchFieldText = searchBar.text;
    
    ///搜索结束默认值
    _orderFilter.OrderSource = - 1;
    _orderFilter.orderType = - 1;
    _orderFilter.orderStatus = - 1;
    _orderFilter.orderIsPaid = - 1;
    requestType = -1;
    requestStatus = -1;
    requestIsPaid = -1;
    _orderFilter.startTime = nil;
    _orderFilter.endTime = nil;
//    if ([[PermissionDoc sharePermission] rule_BranchOrder_Read]) { //查看全部订单
////        [_orderFilter valueForKeyPath:@"account_IDs"];
////
////        [_orderFilter setValue:@"" forKeyPath:@"account_IDs"];
//    }
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        _orderFilter.user_Id = 0;
    }
//    [self requestList];
}

#pragma mark - senior filter
- (void)searchButton:(id)sender
{
    ZXOrderSearchViewController *orderSearchVC = [[ZXOrderSearchViewController alloc]init];
    orderSearchVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:orderSearchVC];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}
- (void)filterButton:(id)sender
{
//    ZXOrderFilterViewController *filterView = [[ZXOrderFilterViewController alloc]init];
    OrderFilterViewController *filterView = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderFilterViewController"];
    filterView.delegate = self;
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"%ld",(long)ACC_ACCOUNTID]];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 1){
        filterView.orderFilterDoc = [OrderFilterDoc new];
        filterView.orderFilterDoc.orderIsPaid = temporary_IsPaid;
        filterView.orderFilterDoc.orderStatus = temporary_Status;
        filterView.orderFilterDoc.orderType = temporary_Type;
        [self getCopy];
    }
    else{
//        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld",(long)ACC_ACCOUNTID]];
//        _orderFilter = [NSKeyedUnarchiver unarchiveObjectWithData:data]; //ACCOUNTID-%ld-BRANCHID-%ld
        NSData *date =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"ACCOUNT-%ld-BRANCH-%ld",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
        [self getCopy];
        _orderFilter = [NSKeyedUnarchiver unarchiveObjectWithData:date];
        if (!_orderFilter) {
            _orderFilter = [OrderFilterDoc new];
        }

        if (_orderFilter.accountArray.count == 0) {
            UserDoc *user = [[UserDoc alloc] init];
            user.user_Name = ACC_ACCOUNTName;
            user.user_Id = ACC_ACCOUNTID;
            [_orderFilter.accountArray addObject:user];
        }

//        [_orderFilter propertyWithDictionary:dict];
//        else
//            NSLog(@"%ld %ld %ld, account %@  user %@ time %@  %@" ,_orderFilter.orderType, _orderFilter.orderStatus, _orderFilter.orderIsPaid, _orderFilter.account_Name, _orderFilter.user_Name, _orderFilter.startTime, _orderFilter.endTime);
        filterView.orderFilterDoc = _orderFilter;
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filterView];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

-(void)getCopy
{
    _orderFilterOld = [OrderFilterDoc new];
    _orderFilterOld.startTime = [_orderFilter.startTime copy];
    _orderFilterOld.endTime = [_orderFilter.endTime copy];
    _orderFilterOld.account_Name = [_orderFilter.account_Name copy];
    _orderFilterOld.user_Name = [_orderFilter.user_Name copy];
    _orderFilterOld.account_Id = _orderFilter.account_Id;
    _orderFilterOld.account_IDs = [_orderFilter.account_IDs copy];
    _orderFilterOld.user_Id = _orderFilter.user_Id;
    _orderFilterOld.orderType = _orderFilter.orderType;
    _orderFilterOld.orderStatus = _orderFilter.orderStatus;
    _orderFilterOld.orderIsPaid = _orderFilter.orderIsPaid;
    _orderFilterOld.accountArray = _orderFilter.accountArray;
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [orderArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIndentify = @"MyCell";
    OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    UIImageView *newOrderMarkFormCustomer = (UIImageView *)[cell viewWithTag:10010];
    
    if (cell == nil) {
        cell = [[OrderListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width - 25, (62-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    OrderDoc *orderDoc = nil;
    if(orderArray.count > 0)
        orderDoc = [orderArray objectAtIndex:indexPath.row];
    if(!newOrderMarkFormCustomer){
        newOrderMarkFormCustomer= [[UIImageView alloc]init];
        [newOrderMarkFormCustomer setImage:[UIImage imageNamed:@"newOrderMark"]];
        newOrderMarkFormCustomer.tag = 10010;
        newOrderMarkFormCustomer.frame = CGRectMake(0, 0, 10, 10);
        [cell addSubview:newOrderMarkFormCustomer];
    }
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
    NSDate *orderDate = [dateFormatter dateFromString:[orderDoc.order_OrderTime substringToIndex:10]];
    
    if((orderDoc.order_OrderSource == 2 || orderDoc.order_OrderSource == 5) && ([orderDate compare:currentDate] == NSOrderedSame))
        newOrderMarkFormCustomer.hidden = NO;
    else
        newOrderMarkFormCustomer.hidden = YES;
    
    [cell updateData:orderDoc];
    
    cell.selectButton.hidden = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderDoc *order = nil;
    if(orderArray.count > 0)
        order = [orderArray objectAtIndex:indexPath.row];
    orderID_Selected     = order.order_ID;
    productType_Selected = order.productAndPriceDoc.productDoc.pro_Type;
    self.orderObjectID = order.order_ObjectID;
    theBranch = (order.isThisBranch == 0 ? 2 : 1);
    [self performSegueWithIdentifier:@"goOrderDetailViewFromOrderListView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goOrderDetailViewFromOrderListView"]) {
        OrderDetailViewController *detailController = segue.destinationViewController;
        detailController.orderID = orderID_Selected;
        detailController.productType = productType_Selected;
        detailController.isBranch = theBranch;
        detailController.objectID = self.orderObjectID;
    }
}

#pragma mark - 接口
- (void)requestList
{
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        [self requestOrderListViaJson:_orderFilter.user_Id];
    } else if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 1) {
        if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID == 0) {
            [self requestNoCustomer];
        } else {
            [self requestOrderListViaJson:((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
        }
    }
}

- (void)requestNoCustomer
{
    if (orderArray) {
        [orderArray removeAllObjects];
    }
    [_navigationView setSecondLabelText:@""];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未选中顾客，不能查看数据！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alertView show];
}

- (void)requestOrderListViaJsonByCustomerID
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.view.userInteractionEnabled = NO;
    if (orderArray) {
        [orderArray removeAllObjects];
    } else {
        orderArray = [NSMutableArray array];
    }
    NSString *par = [NSString stringWithFormat:@"{\"SerchField\":\"%@\",\"CustomerID\":%ld,\"BranchID\":%ld,\"OrderSource\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"IsBusiness\":%d,\"AccountID\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}",searchFieldText,(long)customer.cus_ID, (long)ACC_BRANCHID,(long)_orderFilter.OrderSource,(long)requestType, (long)requestStatus, (long)requestIsPaid, 1 , (long)_orderFilter.account_Id, _orderFilter.startTime ? _orderFilter.startTime : @"", _orderFilter.endTime ? _orderFilter.endTime :@""];

    _requestOrderListByCustomerIdOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *CustomerName = appDelegate.customer_Selected.cus_Name;
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *orderList = [data objectForKey:@"OrderList"];
            orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
            
            for (NSDictionary *obj in orderList) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                [orderDoc setOrder_ObjectID:[[obj objectForKey:@"OrderObjectID"] integerValue]];
                NSLog(@" id =%ld",(long)orderDoc.order_ObjectID);
                [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                [orderDoc setOrder_CreateTime:[obj objectForKey:@"CreateTime"]];
                [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                [orderDoc setOrder_CustomerName:CustomerName];
                [orderDoc setIsThisBranch:[[obj objectForKey:@"IsThisBranch"] integerValue]];
                
                orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] doubleValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] doubleValue];
                [orderArray addObject:orderDoc];
            }
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        }];
        
    } failure:^(NSError *error) {
        [_tableView reloadData];
        self.view.userInteractionEnabled = YES;

    }];
    
    
    /*
    _requestOrderListByCustomerIdOperation = [[GPHTTPClient shareClient] requestGetOrderListViaJsonByCustomerID:customer.cus_ID
                                                                                                    productType:requestType
                                                                                                         status:requestStatus
                                                                                                         isPaid:requestIsPaid
                                                                                                     acccountId:_orderFilter.account_Id
                                                                                                      startTime:_orderFilter.startTime
                                                                                                        endTime:_orderFilter.endTime
                                                                                                        success:^(id xml) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *CustomerName = appDelegate.customer_Selected.cus_Name;
        
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:NO success:^(id data, id message) {
            [SVProgressHUD dismiss];
            NSArray *orderList = [data objectForKey:@"OrderList"];
            orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
            
            for (NSDictionary *obj in orderList) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                [orderDoc setOrder_CustomerName:CustomerName];
                [orderDoc setIsThisBranch:[[obj objectForKey:@"IsThisBranch"] integerValue]];
                
                orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] floatValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] floatValue];
                [orderArray addObject:orderDoc];
            }
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;
        } failure:^(NSString *error) {
            [SVProgressHUD dismiss];
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [_tableView reloadData];
        self.view.userInteractionEnabled = YES;
    }];
     */
}


- (void)requestOrderListViaJson:(NSInteger)customerID
{
    if (view_Type != 0)
        [SVProgressHUD showWithStatus:@"Loading..."];
    NSInteger filterByTime = (_orderFilter.startTime || _orderFilter.endTime) ? 1 : 0;
    self.view.userInteractionEnabled = NO;
    
    NSInteger branchId = 0;
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 0)  branchId = ACC_BRANCHID;
  
    NSString *par;
    if (searchFieldText.length > 0) { //有搜索内容
        NSString *account_IDs = @"";
        par = [NSString stringWithFormat:@"{\"SerchField\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld,\"OrderSource\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"CreateTime\":\"%@\",\"ViewType\":%ld,\"FilterByTimeFlag\":%ld,\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"PageIndex\":%ld,\"PageSize\":%ld,\"IsShowAll\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}",searchFieldText,(long)ACC_ACCOUNTID, (long)branchId,(long)_orderFilter.OrderSource, (long)requestType, (long)requestStatus, (long)requestIsPaid, order_creat, (long)view_Type, (long)filterByTime,account_IDs, (long)customerID, (long)++_currentPage, (long)_pageSize, (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 1? YES :[[PermissionDoc sharePermission] rule_BranchOrder_Read]), _orderFilter.startTime ? _orderFilter.startTime : @"", _orderFilter.endTime ? _orderFilter.endTime : @""];

    }else{
         par = [NSString stringWithFormat:@"{\"SerchField\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld,\"OrderSource\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"CreateTime\":\"%@\",\"ViewType\":%ld,\"FilterByTimeFlag\":%ld,\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"PageIndex\":%ld,\"PageSize\":%ld,\"IsShowAll\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}",searchFieldText,(long)ACC_ACCOUNTID, (long)branchId,(long)_orderFilter.OrderSource, (long)requestType, (long)requestStatus, (long)requestIsPaid, order_creat, (long)view_Type, (long)filterByTime, _orderFilter.account_IDs, (long)customerID, (long)++_currentPage, (long)_pageSize, (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 1 ? YES :[[PermissionDoc sharePermission] rule_BranchOrder_Read]), _orderFilter.startTime ? _orderFilter.startTime : @"", _orderFilter.endTime ? _orderFilter.endTime : @""];
    }
   //
//      NSString *par = [NSString stringWithFormat:@"{\"SerchField\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld,\"OrderSource\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"CreateTime\":\"%@\",\"ViewType\":%ld,\"FilterByTimeFlag\":%ld,\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"PageIndex\":%ld,\"PageSize\":%ld,\"IsShowAll\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}",searchFieldText,(long)ACC_ACCOUNTID, (long)branchId,(long)_orderFilter.OrderSource, (long)requestType, (long)requestStatus, (long)requestIsPaid, order_creat, (long)view_Type, (long)filterByTime, _orderFilter.account_IDs, (long)customerID, (long)++_currentPage, (long)_pageSize, (kMenu_Type == 1 ? YES :[[PermissionDoc sharePermission] rule_BranchOrder_Read]), _orderFilter.startTime ? _orderFilter.startTime : @"", _orderFilter.endTime ? _orderFilter.endTime : @""];
    
    _requestOrderListByAccountIdOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        if (tmpOrderArray)
            [tmpOrderArray removeAllObjects];
        else
            tmpOrderArray = [NSMutableArray array];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            
            NSInteger totalPage = [[data objectForKey:@"PageCount"] integerValue];
            if (_currentPage == totalPage)
                self.tableView.footerHidden = YES;
            _recordCount = [[data objectForKey:@"RecordCount"] integerValue];
            
            if (totalPage > 0)
                [_navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)_currentPage, (long)totalPage]];
            else
                [_navigationView setSecondLabelText:@""];
            
            NSArray *orderList = [data objectForKey:@"OrderList"];
            orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
            
            for (NSDictionary *obj in orderList) {
                OrderDoc *orderDoc = [[OrderDoc alloc] init];
                [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                [orderDoc setOrder_ObjectID:[[obj objectForKey:@"OrderObjectID"] integerValue]];
                [orderDoc setOrder_CustomerName:[obj objectForKey:@"CustomerName"]];
                [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                [orderDoc setOrder_CreateTime:[obj objectForKey:@"CreateTime"]];
                [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                [orderDoc setOrder_OrderSource:[[obj objectForKey:@"OrderSource"] integerValue]];
                [orderDoc setOrder_UnPaidPrice:[[obj objectForKey:@"UnPaidPrice"] doubleValue]];
                orderDoc.IsThisBranch = 1;
                
                orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"]  integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     =[[obj objectForKey:@"TotalOrigPrice"] doubleValue];
                orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] doubleValue];
                [tmpOrderArray addObject:orderDoc];
            }
            if ([tmpOrderArray count] % 10 != 0 || [tmpOrderArray count] == 0) {
                if (view_Type == 0) {
                    refresh_Flag = 3;
                }
            }
            if (view_Type == 1) {
                NSRange range = NSMakeRange(0, [tmpOrderArray count]);
                NSIndexSet *index_set = [NSIndexSet indexSetWithIndexesInRange:range];
                [orderArray insertObjects:tmpOrderArray atIndexes:index_set];
                [self.tableView headerEndRefreshing];
            } else if (view_Type == 0) {
                [orderArray addObjectsFromArray:tmpOrderArray];
                [self.tableView footerEndRefreshing];
            }
            [SVProgressHUD dismiss];
            
            [_tableView reloadData];
            
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            [_navigationView setSecondLabelText:@""];
            if (view_Type == 1)
                [self.tableView headerEndRefreshing];
            else if (view_Type == 0)
                [self.tableView footerEndRefreshing];
            [_tableView reloadData];
            [SVProgressHUD dismiss];
            self.view.userInteractionEnabled = YES;
        }];
        
    } failure:^(NSError *error) {
        [_navigationView setSecondLabelText:@""];
        if (view_Type == 1)
            [self.tableView headerEndRefreshing];
        else if (view_Type == 0)
            [self.tableView footerEndRefreshing];
        [_tableView reloadData];
        self.view.userInteractionEnabled = YES;
    }];
    
    
    /*
    _requestOrderListByAccountIdOperation =
    [[GPHTTPClient shareClient]requestGetOrderListByAccountIDAndProductType:requestType
                                                                     status:requestStatus
                                                                     isPaid:requestIsPaid
                                                                    orderId:order_Id
                                                           responsePersonID:_orderFilter.account_Id
                                                                 customerID:customerID
                                                                   viewType:view_Type
                                                               filterByTime:filterByTime
                                                                  pageIndex:++_currentPage
                                                                   pageSize:_pageSize
                                                                  isShowAll:(kMenu_Type == 1 ? YES :[[PermissionDoc sharePermission] rule_BranchOrder_Read])
                                                                  startTime:_orderFilter.startTime ? _orderFilter.startTime : @""
                                                                    endTime:_orderFilter.endTime ? _orderFilter.endTime : @""
                                                                    success:^(id xml) {
            if (tmpOrderArray)
                [tmpOrderArray removeAllObjects];
            else
                tmpOrderArray = [NSMutableArray array];

            [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, id message) {
                NSInteger totalPage = [[data objectForKey:@"PageCount"] integerValue];
                if (_currentPage == totalPage)
                    self.tableView.footerHidden = YES;
                _recordCount = [[data objectForKey:@"RecordCount"] integerValue];
                
                if (totalPage > 0)
                    [_navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)_currentPage, (long)totalPage]];
                else
                    [_navigationView setSecondLabelText:@""];
                
                NSArray *orderList = [data objectForKey:@"OrderList"];
                orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
                
                for (NSDictionary *obj in orderList) {
                    OrderDoc *orderDoc = [[OrderDoc alloc] init];
                    [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                    [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                    [orderDoc setOrder_CustomerName:[obj objectForKey:@"CustomerName"]];
                    [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                    [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                    [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                    [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                    [orderDoc setOrder_OrderSource:[[obj objectForKey:@"OrderSource"] integerValue]];
                    [orderDoc setOrder_UnPaidPrice:[[obj objectForKey:@"UnPaidPrice"] doubleValue]];
                    orderDoc.IsThisBranch = 1;

                    orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                    orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"]  integerValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     =[[obj objectForKey:@"TotalOrigPrice"] floatValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] floatValue];
                    [tmpOrderArray addObject:orderDoc];
                }
                if ([tmpOrderArray count] % 10 != 0 || [tmpOrderArray count] == 0) {
                    if (view_Type == 0) {
                       refresh_Flag = 3;
                    }
                }
                if (view_Type == 1) {
                    NSRange range = NSMakeRange(0, [tmpOrderArray count]);
                    NSIndexSet *index_set = [NSIndexSet indexSetWithIndexesInRange:range];
                    [orderArray insertObjects:tmpOrderArray atIndexes:index_set];
                    [self.tableView headerEndRefreshing];
                } else if (view_Type == 0) {
                    [orderArray addObjectsFromArray:tmpOrderArray];
                    [self.tableView footerEndRefreshing];
                }
                    [SVProgressHUD dismiss];

                    [_tableView reloadData];

                    self.view.userInteractionEnabled = YES;

            }failure:^(NSString *error) {
                [_navigationView setSecondLabelText:@""];
                if (view_Type == 1)
                    [self.tableView headerEndRefreshing];
                else if (view_Type == 0)
                    [self.tableView footerEndRefreshing];
                [_tableView reloadData];
                [SVProgressHUD dismiss];
                self.view.userInteractionEnabled = YES;
            }];
        } failure:^(NSError *error) {
            [_navigationView setSecondLabelText:@""];
            if (view_Type == 1)
                [self.tableView headerEndRefreshing];
            else if (view_Type == 0)
                [self.tableView footerEndRefreshing];
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;
            [SVProgressHUD dismiss];
        }];
    */
}

@end
