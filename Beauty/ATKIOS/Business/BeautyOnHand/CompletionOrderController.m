//
//  CompletionOrderController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/16.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CompletionOrderController.h"
#import "DFUITableView.h"
#import "OperatingOrder.h"
#import "SVProgressHUD.h" 
#import "NavigationView.h"
#import "CompletionOrderCell.h"
#import "UIButton+InitButton.h"
#import "FilterComOrderController.h"
#import "ComOrderFilter.h"
#import "AppDelegate.h" 
#import "GPBHTTPClient.h"
#import "OrderDetailViewController.h"
#import "ComputerSginViewController.h"

@interface CompletionOrderController ()<UITableViewDataSource, UITableViewDelegate, FilterComOrderControllerDelegate, OperatingOrderDelegate>
@property (nonatomic, strong) NSMutableArray *originList;
@property (nonatomic, strong) NSMutableArray *orderList;
@property (nonatomic, weak) NavigationView *navigaView;
@property (nonatomic, weak) DFUITableView *tableView;
@property (nonatomic, weak) UIButton *checkAllButton;
@property (nonatomic, strong) NSArray *customerArray;
@property (nonatomic, strong) NSArray *accountArray;
@property (nonatomic, strong) NSArray *selectArray;
@property (nonatomic, strong) ComOrderFilter *orderFilter;
@property (nonatomic, strong) NSPredicate *selectPredicate;

// 是否需要签名
@property (nonatomic,assign) BOOL isAllowSign;
@property (nonatomic,copy) NSString *signImgStr;

@end

@implementation CompletionOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

static NSString *completionCell = @"completionCell";

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    self.tableView.frame = CGRectMake(5.0f, self.navigaView.frame.origin.y + self.navigaView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 36.0f);

    UIButton *subBut = [UIButton buttonWithTitle:@"结单" target:self selector:@selector(confirmAction) frame:CGRectMake(5.0f,CGRectGetMaxY(self.tableView.frame)+2.5, 310.0f , 36.0f) backgroundImg:ButtonStyleBlue];
    [self.view addSubview:subBut];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initData
{
    self.orderFilter = [[ComOrderFilter alloc] init];
    _signImgStr = @"";
    [OperatingOrder requestGetCustomerUnfinishListCompletionBlock:^(NSArray *array, NSString *mesg, NSInteger code) {
        if (array) {
            self.originList = [[NSMutableArray alloc] initWithArray:array];
            self.orderList = [self.originList mutableCopy];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
        }
    }];
}

- (void)checkAllAction:(UIButton *)button
{
    if (self.orderList.count == 0) {
        return;
    }
    NSLog(@"the start time");
    button.selected = !button.selected;

    [self.orderList enumerateObjectsUsingBlock:^(OperatingOrder *obj, NSUInteger idx, BOOL *stop) {
        if (obj.editStatus != OperatingOrderEditNone) {
            obj.isSelect = button.selected;
        }
    }];
    [self updateCheckAllButtonStatus];
    NSLog(@"the end time");

    [self.tableView reloadData];
}

- (void)filterAction
{
    FilterComOrderController *filterVC = [[FilterComOrderController alloc] init];
    filterVC.customerList = self.customerArray;
    filterVC.accountList = self.accountArray;
    filterVC.originFilter = self.orderFilter;
    filterVC.delegate = self;
    [self.navigationController pushViewController:filterVC animated:YES];
}

- (void)selectOrder
{
    NSMutableArray *selectArrs = [NSMutableArray array];
    if (self.orderList.count > 0) {
        for (int i = 0; i < self.orderList.count; i ++) {
            OperatingOrder *opOrder = self.orderList[i];
            if (opOrder.isSelect) {
                [selectArrs addObject:opOrder];
            }
        }
    }
    if (selectArrs.count > 1) { //选择的是否是同一个顾客
        OperatingOrder *opOrder =  selectArrs.firstObject;
        for (int i = 1 ; i < selectArrs.count; i ++) {
            OperatingOrder *temp = selectArrs[i];
            if (temp.CustomerID != opOrder.CustomerID) {
                
                break;
            }
        }
        
    }else{
        OperatingOrder *opOrder =  selectArrs.firstObject;
        if (opOrder.isSelect) {
            _isAllowSign = YES;
        }
    }
}
- (NSMutableArray *)selectOrderArrs
{
    NSMutableArray *selectArrs = [NSMutableArray array];
    if (self.orderList.count > 0) {
        for (int i = 0; i < self.orderList.count; i ++) {
            OperatingOrder *opOrder = self.orderList[i];
            if (opOrder.isSelect) {
                [selectArrs addObject:opOrder];
            }
        }
    }
    return selectArrs;
}

- (BOOL)isSameCustomerWithSelectOrderArrs:(NSMutableArray *)theSelectOrderArrs
{
    BOOL isSameCustomer = YES;
    OperatingOrder *opOrder =  theSelectOrderArrs.firstObject;
    for (int i = 1 ; i < theSelectOrderArrs.count; i ++) {
        OperatingOrder *tempOrder = theSelectOrderArrs[i];
        if (opOrder.CustomerID  != tempOrder.CustomerID) {
            isSameCustomer = NO;
            break;
        }
    }
    return isSameCustomer;
}

- (BOOL)isConfirmedWithSelectOrderArrs:(NSMutableArray *)theSelectOrderArrs
{
    BOOL isConfirmed = NO;
    for (int i = 0; i <theSelectOrderArrs.count; i ++ ) {
        OperatingOrder *tempOrder = theSelectOrderArrs[i];
        if (tempOrder.IsConfirmed == 2) {
            isConfirmed = YES;
            break;
        }
    }
    return isConfirmed;
}
- (void)confirmAction
{
    _isAllowSign  = NO;
    NSMutableArray *arrs  = [self selectOrderArrs];
    if (arrs.count == 0) {
        [SVProgressHUD showErrorWithStatus2:@"请选择订单!" touchEventHandle:^{
        }];
        return;
    }if (arrs.count == 1){
        _isAllowSign = [self isConfirmedWithSelectOrderArrs:arrs];
    }else{
        if (![self isSameCustomerWithSelectOrderArrs:arrs]) {
            [SVProgressHUD showErrorWithStatus2:@"不同顾客不能一起结单!" touchEventHandle:^{
            }];
            return;
        }
        if ([self isConfirmedWithSelectOrderArrs:arrs]) {
            _isAllowSign = YES;
        }
    }
    if (_isAllowSign) { //签名
        ComputerSginViewController *signVC = [[ComputerSginViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        signVC.computerConfirmSignBlock = ^(NSString *imgString){
            _signImgStr = imgString;
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                
            }];
            [weakSelf requestOrderCompleteTreatGroup];
        };
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:signVC animated:YES completion:^{
            
        }];
    }else{
        [self requestOrderCompleteTreatGroup];
    }
}
- (void)requestOrderCompleteTreatGroup
{
    [SVProgressHUD showWithStatus:@"Loading"];
    if (self.selectArray.count) {
        NSArray *array = [self.selectArray valueForKeyPath:@"@unionOfObjects.tgDetail"];
        NSString *par;
        if (_isAllowSign) {
            par = [NSString stringWithFormat:@"{\"SignImg\":\"%@\",\"ImageFormat\":\".jpg\",\"CustomerID\":%ld,\"TGDetailList\":[%@]}", _signImgStr,(long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID, [array componentsJoinedByString:@","]];
        }else{
            par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"TGDetailList\":[%@]}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID, [array componentsJoinedByString:@","]];
            
        }
        [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CompleteTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
            [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
                if (code == 1) {
                    [SVProgressHUD showSuccessWithStatus2:@"操作成功!" duration:kSvhudtimer touchEventHandle:^{
                        if (self.checkAllButton.selected) {
                            self.checkAllButton.selected = NO;
                        }
                        [self initData];
                    }];
                }else{
                    [SVProgressHUD showErrorWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                        
                    }];
                }
            } failure:^(NSInteger code, NSString *error) {
                [SVProgressHUD showErrorWithStatus2:error duration:kSvhudtimer touchEventHandle:^{
                    
                }];
            }];
        } failure:^(NSError *error) {
        }];
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择订单!" touchEventHandle:^{
        }];
    }

}
#pragma mark FilterComOrderControllerDelegate
- (void)searchCustomer:(NSString *)custName person:(NSString *)personName
{
    if (self.orderFilter.customerName == nil && self.orderFilter.personName == nil) {
        self.orderList = [self.originList mutableCopy];
    } else {
        self.orderList = [[self.originList filteredArrayUsingPredicate:self.orderFilter.filterPred] mutableCopy];
    }
    [self updateCheckAllButtonStatus];
    [self.tableView reloadData];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CompletionOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:completionCell];
    cell.opOrder = self.orderList[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailViewController *orderDetail = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    OperatingOrder *opOrder = self.orderList[indexPath.row];

    orderDetail.orderID = opOrder.OrderID;
    orderDetail.productType = opOrder.ProductType;
    orderDetail.objectID = opOrder.OrderObjectID;
    [self.navigationController pushViewController:orderDetail animated:YES];

}

#pragma mark OperatingOrderDelegate
- (void)updateCheckButton
{
    [self updateCheckAllButtonStatus];
}

- (void)updateCheckAllButtonStatus
{
    self.checkAllButton.selected = (self.selectArray.count == self.orderList.count && self.selectArray.count != 0);
}

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"结单"];
        
        UIButton *allButton = [UIButton buttonWithTitle:@""
                                                      target:self
                                                    selector:@selector(checkAllAction:)
                                                       frame:CGRectMake(314.0f - HEIGHT_NAVIGATION_VIEW, 0.0f, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                               backgroundImg:[UIImage imageNamed:@"icon_unCheckedTitle"]
                                            highlightedImage:nil];
        [allButton setBackgroundImage:[UIImage imageNamed:@"icon_CheckedTitle"] forState:UIControlStateSelected];

        UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(filterAction)
                                                     frame:CGRectMake(CGRectGetMinX(allButton.frame) - HEIGHT_NAVIGATION_VIEW+5.0f, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                             backgroundImg:[UIImage imageNamed:@"orderAdvancedFilterIcon"]
                                          highlightedImage:nil];
        [nav addSubview: self.checkAllButton = allButton];
        [nav addSubview:filterButton];

        [self.view addSubview:_navigaView = nav];
    }
    return _navigaView;
}

- (DFUITableView *)tableView
{
    if (_tableView == nil) {
        DFUITableView *tab = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        [tab registerNib:[UINib nibWithNibName:@"CompletionOrderCell" bundle:nil] forCellReuseIdentifier:completionCell];
        tab.showsVerticalScrollIndicator = YES;
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
}

- (NSMutableArray *)originList
{
    if (_originList == nil) {
        _originList = [[NSMutableArray alloc] init];
    }
    return _originList;
}
- (NSMutableArray *)orderList
{
    if (_orderList == nil) {
        _orderList = [[NSMutableArray alloc] init];
    }
    return _orderList;
}

- (NSArray *)customerArray
{
    if (_customerArray == nil) {
        _customerArray = [self.originList valueForKeyPath:@"@distinctUnionOfObjects.CustomerName"];
    }
    return _customerArray;
}

- (NSArray *)accountArray
{
    if (_accountArray == nil) {
        _accountArray = [self.originList valueForKeyPath:@"@distinctUnionOfObjects.AccountName"];
    }
    return _accountArray;
}

- (NSPredicate *)selectPredicate
{
    if (_selectPredicate == nil) {
        _selectPredicate = [NSPredicate predicateWithFormat:@"isSelect == YES"];
    }
    return _selectPredicate;
}

- (NSArray *)selectArray
{
    _selectArray = [self.orderList filteredArrayUsingPredicate:self.selectPredicate];
    return _selectArray;
}

@end
