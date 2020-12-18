//
//  OrderConfirmViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderEditViewController.h"
#import "ContactDetailViewController.h"
#import "TreatmentDetailViewController.h"
#import "EffectDisplayViewController.h"
#import "PayInfoViewController.h"
#import "OrderContactCell.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "NumberEditCell.h"
#import "OrderDateCell.h"
#import "OrderDoc.h"
#import "ServiceDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDoc.h"
#import "CourseDoc.h"
#import "ContactDoc.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "ReviewViewController.h"
#import "PermissionDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "UIButton+InitButton.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "NSDate+Convert.h"
#import "PayInfoDoc.h"
#import "ContentEditCell.h"
#import "AppDelegate.h"
#import "ZWJson.h"
#import "OrderPaymentDetailViewController.h"
#import "OrderListViewController.h"
#import "OrderRootViewController.h"
#import "GPNavigationController.h"
#import "DFTableCell.h"
#import "CustomerDoc.h"
#import "GPBHTTPClient.h"
#import "OrderRefund_ViewController.h"
#import "TreatmentDoc.h"
#import "PayConfirmViewController.h"
#import "SubOrderViewController.h"
#import "CusMainViewController.h"
#import "AppointmentDetail_ViewController.h"
#import "AppointmenCreat_ViewController.h"
#import "TreatmentGroupTabbarController.h"
#import "TreatmentGroupReview_ViewController.h"
#import "ThirdPatmentRecords_ViewController.h"
#import "ZXServiceEffectViewController.h"
#import "WelfareRes.h"
#import "ComputerSginViewController.h"
#import "DeliveryView.h"


#define ACC_ACCOUNTID [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue]
#define ACC_ACCOUNTName [[NSUserDefaults standardUserDefaults]  objectForKey:@"ACCOUNT_NAME"]
#define ORDER_STATUS_HIDDEN     (theOrder.order_Status == 1 || theOrder.order_Status == 2 )
#define ORDER_STATUS_SHOW       (theOrder.order_Status == 0 || theOrder.order_Status == 3 )
#define ORDER_RPN_FLAG          (theOrder.order_Flag == 1 && theOrder.order_Status != 2)
#define ORDER_PAY_FLAG          (ACC_BRANCHID && [[PermissionDoc sharePermission] rule_Payment_Use] && theOrder.order_Status != 2)
#define ORDER_STATUS_FLAG       (theOrder.order_Flag == 1 && (theOrder.order_Ispaid == 0 || theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == 0) && _courseStatus && theOrder.order_Status == 0)
#define ORDER_CONFIRM_FLAG      (theOrder.order_Flag == 1 && theOrder.order_ProductType == 1 && theOrder.order_Status == 0)
#define ORDER_TREAT_FLAG  (theOrder.order_Flag == 1 && [[PermissionDoc sharePermission] rule_MyOrder_Write] && theOrder.order_Status == 0)
#define ORDER_SALES_SHOW  ((theOrder.order_SalesList.count != 0) && RMO(@"|4|")) //((theOrder.order_SalesID != 0) && RMO(@"|4|"))
#define ORDER_DESIGNATED  (treatmentDoc.status_Designated ? @"取消指定" : @"指定")

#define ORDER_ISADD         ([[PermissionDoc sharePermission] rule_MyOrder_Write] && theOrder.order_Status != 2)
#define ORDER_ISCHANGEPRICE ([[PermissionDoc sharePermission] rule_MyOrder_Write] && [[PermissionDoc sharePermission] rule_OrderTotalSalePrice_Write] && theOrder.order_Flag && theOrder.order_Ispaid == 0 && (theOrder.order_Status == 0 || theOrder.order_Status == 1 || theOrder.order_Status == 3))
//rule_Order_Write-->>rule_MyOrder_Write
@interface OrderDetailViewController ()
{
    BOOL bool_edit;
    BOOL bool_save;
    NSInteger _courseStatus;
    DeliveryView *deliveryView;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDeleteOrderOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddTreatmentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDeleteTreaatmentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCompleteTreaatmentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCompleteOrderOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCancelTreaatmentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateOrderRemark;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateExpirationTime;
@property (nonatomic, weak) AFHTTPRequestOperation *requestUpdateTreatmentDesignated;
@property (nonatomic, weak) AFHTTPRequestOperation *requestIsAddUp;
@property (nonatomic, weak) AFHTTPRequestOperation *requestUpdatePrice;
@property (nonatomic, weak) AFHTTPRequestOperation *requestAddTreatment;
@property (nonatomic, weak) AFHTTPRequestOperation *requestDeleteTreatment;
@property (nonatomic, weak) AFHTTPRequestOperation *requestCompleteTreatment;

@property (strong, nonatomic) ProductAndPriceView *productAndPriceView;
@property (strong,nonatomic) ProductAndPriceDoc *theProductAndPriceDoc;
@property (strong, nonatomic) NavigationView *navigationView;

@property (strong, nonatomic) OrderDoc *theOrder;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSDate *oldDate;
@property (nonatomic) ContactDoc *contactDoc_Selected;
@property (nonatomic) TreatmentDoc *treatmentDoc_Selected;
@property (assign, nonatomic) CGPoint startTouch;
@property (assign, nonatomic) BOOL isLastTreatment;
@property (assign, nonatomic) BOOL isMoving;
@property (assign, nonatomic) BOOL isGone;
@property (assign, nonatomic) CGFloat balance;
@property (assign, nonatomic) NSIndexPath *index;
@property (nonatomic, copy) NSMutableArray *payment_Info;

@property (assign, nonatomic) CGRect prevCaretRect;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (strong, nonatomic) UITextField *textField_Editing;

@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, assign) NSInteger unCompleteTreats;
@property (nonatomic, assign) NSInteger treatsCount;
@property (nonatomic, assign) NSInteger groupUncompletion;
@property (nonatomic ,assign) BOOL orderIsShow;
@property (nonatomic ,assign)  BOOL finishServeIsShow;
@property (nonatomic ,assign)  BOOL serveSection1IsShow;
@property (nonatomic, strong) NSMutableArray * finishiServeArr;
@property (nonatomic ,strong) NSMutableArray * unFinishiServeArr;
@property (nonatomic ,assign) NSInteger surplusNUmber;
@property  (nonatomic,assign) NSInteger uncount;
@property (nonatomic,strong)  NSArray * vipPriceArr;
@property (nonatomic ,assign) NSString * payCountStr;
@property (nonatomic,assign) NSDictionary * serveDetailDic;
@property (nonatomic ,strong) NSArray * scdlListArr;
@property (nonatomic ,assign) BOOL scdlShowBool;
@property (nonatomic,assign) BOOL HasNetTrade ;
@property (nonatomic, strong) NSMutableString *slaveNames;
@property (nonatomic, assign) BOOL isMergePay;
@property (nonatomic, assign) BOOL AppointMustPaid;

// 签名string
@property (nonatomic,copy) NSString *signImgStr;

@end

@implementation OrderDetailViewController
@synthesize orderID, productType;
@synthesize theOrder;
@synthesize contactDoc_Selected, treatmentDoc_Selected;
@synthesize isLastTreatment;
@synthesize balance;
@synthesize payment_Info,datePicker,inputAccessoryView;
@synthesize groupArray,orderIsShow,finishServeIsShow;
@synthesize finishiServeArr,unFinishiServeArr,serveSection1IsShow;
@synthesize surplusNUmber,uncount;
@synthesize vipPriceArr;
@synthesize theProductAndPriceDoc,payCountStr,serveDetailDic;
@synthesize scdlListArr,scdlShowBool;
@synthesize AppointMustPaid;


#pragma mark 返回未完成的子服务数量  订单group操作条件 订单有效（非取消）有操作权限
- (NSInteger)unCompleteTreats
{
    _unCompleteTreats = 0;
    for (CourseDoc *course in theOrder.courseArray) {
        for (TreatmentDoc *treatment in course.treatmentArray) {
            if ([treatment isKindOfClass:[TreatmentDoc class]]) {
                if (!treatment.treat_Schedule.sch_Completed)
                    _unCompleteTreats ++;
            }
        }
    }
    return _unCompleteTreats;
}

- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (theOrder.order_SalesList) {
        for (UserDoc *user in theOrder.order_SalesList) {
            [nameArray addObject:user.user_Name];
        }
    }
    return [nameArray componentsJoinedByString:@"、"];
}

#pragma mark 返回课程下子服务的数量
- (NSInteger)treatsCount
{
    _treatsCount = 0;
    for (CourseDoc *course in theOrder.courseArray) {
        for (id treat in course.treatmentArray) {
            if ([treat isKindOfClass:[TreatmentDoc class]]) {
                _treatsCount ++;
            }
        }
    }
    return _treatsCount;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    _courseStatus = 1;
    
    if (_isBranch != 2) {
        _isBranch = 1;
    }
    
    if(_lastView == 1 || _lastView == 2){ //直接跳转到详情页
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        NSInteger count = array.count;
        for(int i = 0; i < count - 1 ; i++) {
            [array removeObjectAtIndex:0];
        }
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
        [self.navigationController setViewControllers:array];
        _isGone = NO;
    } else if (_lastView == 3) {
        GPNavigationController *nav = (GPNavigationController *)self.navigationController;
        [nav cleanScreenShotsFromeVC:[self class] ViewController:[CusMainViewController class]];
    }
    
    
    [super viewWillAppear:animated];
    [self requestGetOrderDetailByJson];
}

-(void)refreshOrder
{
    if (bool_edit && theOrder.order_Flag)
    {
        [SVProgressHUD showErrorWithStatus2:@"请先完成编辑！" touchEventHandle:^{}];
        return;
    }
    [self requestGetOrderDetailByJson];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTableView];
    [self initData];
}

-(void)initTableView
{
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"订单详情"];
    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderRefresh"] selector:@selector(refreshOrder)];
    [self.view addSubview:_navigationView];
    
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    //    _tableView.frame = CGRectMake(-5.0f, 35.0f, 330.0f, kSCREN_BOUNDS.size.height - 20.0f - 35.0f - 44.0f);
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    _initialTVHeight = _tableView.frame.size.height;
}

-(void)initData
{
    self.HasNetTrade  = NO;
    finishServeIsShow = NO;
    orderIsShow = NO;
    scdlShowBool = NO;
    serveSection1IsShow = NO;
    payCountStr = @"0";
    theOrder.order_ServiceOn = 0;
    unFinishiServeArr = [[NSMutableArray alloc] init];
    finishiServeArr = [[NSMutableArray alloc] init];
    _signImgStr = @"";
}

//解决手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)panGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        if(!_isMoving) {
            _startTouch = [gestureRecognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
            _isMoving = YES;
        }
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint point =  [gestureRecognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
        if(point.x - _startTouch.x > 80.f && point.y  - _startTouch.y < 30.f){
            [self gotoPage:_lastView];
        }
        _isMoving = NO;
    }else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        _isMoving = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)gotoPage:(NSInteger)page
{
    if(!_isGone){
        if(_lastView == 1){
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
            
        }else if (_lastView ==  2){
            OrderListViewController * orderListView = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListView"];
            orderListView.clearStack = YES; //清空视图的压栈
            //视图压栈时，进入的方向（由左进入，默认是右）
            CATransition *transition = [CATransition animation];
            transition.duration = .3;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromLeft;
            [self.navigationController.view.layer  addAnimation:transition forKey:nil];
            
            GPNavigationController *navigation = (GPNavigationController *)self.navigationController;
            navigation.canDragBack = NO; //修正偶尔会出现一闪而过的白屏
            
            [self.navigationController pushViewController:orderListView animated:YES];
        }
        _isGone = YES;
    }
}
- (void)reloadData
{
    [_tableView reloadData];
    
    /*
     if (theOrder.order_Flag == 1 && [[PermissionDoc sharePermission] rule_Order_Write] && theOrder.order_Status == 0 && theOrder.order_Ispaid == 0) {
     [_navigationView addButtonWithTarget:self
     backgroundImage:[UIImage imageNamed:@"order_cancel"]
     selector:@selector(cancelOrderAction)];
     } else {
     [_navigationView removeButton];
     }
     */
}

#pragma mark 离开 处理
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderDetailOperation && [_requestGetOrderDetailOperation isExecuting]) {
        [_requestGetOrderDetailOperation cancel];
    }
    
    if (_requestDeleteOrderOperation && [_requestDeleteOrderOperation isExecuting]) {
        [_requestDeleteOrderOperation cancel];
    }
    
    if (_requestDeleteTreaatmentOperation && [_requestDeleteTreaatmentOperation isExecuting]) {
        [_requestDeleteTreaatmentOperation cancel];
    }
    
    if (_requestAddTreatmentOperation && [_requestAddTreatmentOperation isExecuting]) {
        [_requestAddTreatmentOperation cancel];
    }
    
    if (_requestCompleteTreaatmentOperation && [_requestCompleteTreaatmentOperation isExecuting]) {
        [_requestCompleteTreaatmentOperation cancel];
    }
    
    if (_requestCompleteOrderOperation && [_requestCompleteOrderOperation isExecuting]) {
        [_requestCompleteOrderOperation cancel];
    }
    
    if (_requestCancelTreaatmentOperation && [_requestCancelTreaatmentOperation isExecuting]) {
        [_requestCancelTreaatmentOperation cancel];
    }
    
    if (_requestUpdateOrderRemark && [_requestUpdateOrderRemark isExecuting]) {
        [_requestUpdateOrderRemark cancel];
    }
    
    if (_requestUpdateTreatmentDesignated && [_requestUpdateTreatmentDesignated isExecuting]) {
        [_requestUpdateTreatmentDesignated cancel];
    }
    
    if (_requestIsAddUp && [_requestIsAddUp isExecuting]) {
        [_requestIsAddUp cancel];
    }
    if (_requestUpdatePrice && [_requestUpdatePrice isExecuting]) {
        [_requestUpdatePrice cancel];
    }
    if (_requestAddTreatment && [_requestAddTreatment isExecuting]) {
        [_requestAddTreatment cancel];
    }
    if (_requestDeleteTreatment && [_requestDeleteTreatment isExecuting]) {
        [_requestDeleteTreatment cancel];
    }
    if (_requestCompleteTreatment && [_requestCompleteTreatment isExecuting]) {
        [_requestCompleteTreatment cancel];
    }
    
    _requestGetOrderDetailOperation = nil;
    _requestDeleteOrderOperation = nil;
    _requestDeleteTreaatmentOperation = nil;
    _requestAddTreatmentOperation = nil;
    _requestCompleteTreaatmentOperation = nil;
    _requestCompleteOrderOperation = nil;
    _requestCancelTreaatmentOperation = nil;
    _requestUpdateOrderRemark = nil;
    _requestUpdateTreatmentDesignated = nil;
    _requestIsAddUp = nil;
    _requestUpdatePrice = nil;
    _requestAddTreatment = nil;
    _requestDeleteTreatment = nil;
    _requestCompleteTreatment = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    uncount = unFinishiServeArr.count;
    
    if (self.productType == 0) {
        if(section == 0)
        {
            if (orderIsShow) {
                return 7+(ORDER_SALES_SHOW ? 1 : 0);
            }else
            {
                return 1;
            }
        }else if(section == 1){
            if (serveSection1IsShow) {
                //                NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
                //                return 4+(theOrder.order_Ispaid == 2 ? 1 : 0) +count +(theOrder.productAndPriceDoc.productDoc.pro_refundPrice < 0.0001f? 0 : 1) ;
                if (theOrder.BenefitListArr.count > 0) {
                    NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
                    return  4 + 1 + theOrder.BenefitListArr.count +(theOrder.order_Ispaid == 2 ? 1 : 0) +count +(theOrder.productAndPriceDoc.productDoc.pro_refundPrice < 0.0001f? 0 : 1) ;
                }else{
                    NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
                    return 4+(theOrder.order_Ispaid == 2 ? 1 : 0) +count +(theOrder.productAndPriceDoc.productDoc.pro_refundPrice < 0.0001f? 0 : 1) ;
                }
            }
            return 1;
        }else if(section == 2)
        {
            return  ((theOrder.order_Ispaid == 2 || theOrder.order_Ispaid == 3|| theOrder.order_Ispaid == 4) ? 2 : 1)+ (self.HasNetTrade ?1:0);
        }
        else if (section == 3) {
            return uncount +1 ;
            
        }else if(section ==4)//预约
        {
            if (scdlListArr.count >0) {
                if (scdlShowBool) {
                    return scdlListArr.count +1;
                }else
                    return 1;
            }else
            {
                return 0;
            }
            
        }
        else if(section == 5)//已完成
        {
            if (finishServeIsShow) {
                if ((long)theOrder.productAndPriceDoc.productDoc.pro_PastCount <=0) {
                    return finishiServeArr.count +1;
                }
                return finishiServeArr.count +2;
            }else
            {
                if ((long)theOrder.productAndPriceDoc.productDoc.pro_PastCount >0) {
                    return 1;
                }else{
                    if (finishiServeArr.count==0) {
                        return 0;
                    }else
                        return 1;
                }
            }
        }else if(section ==7)
        {
            return 1;
        }
    } else {//商品
        if (section == 0) {
            if (orderIsShow) {
                return 6+(ORDER_SALES_SHOW ? 1 : 0);
            }
            return 1;
        }else if(section ==1)
        {
            
            if (serveSection1IsShow) {
                
                if (theOrder.BenefitListArr.count > 0) {
                    NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
                    return  4 + 1 + theOrder.BenefitListArr.count +(theOrder.order_Ispaid == 2 ? 1 : 0) +count +(theOrder.productAndPriceDoc.productDoc.pro_refundPrice < 0.0001f? 0 : 1);
                }else{
                    NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
                    return 4+(theOrder.order_Ispaid == 2 ? 1 : 0) +count+(theOrder.productAndPriceDoc.productDoc.pro_refundPrice  < 0.0001f ? 0 : 1) ;
                }
                
            }
            return 1;
        }else if(section ==2)
        {
            return  ((theOrder.order_Ispaid == 2 || theOrder.order_Ispaid == 3|| theOrder.order_Ispaid == 4) ? 2 : 1)+ (self.HasNetTrade ?1:0);
        }else if(section == 3)
        {
            return unFinishiServeArr.count+1;
            
        }else if(section ==4)
        {
            return 0;
        }
        else if(section == 5)
        {
            if (finishServeIsShow) {
                return finishiServeArr.count +1;
            }else
            {
                if (finishiServeArr.count==0) {
                    return 0;
                }else
                    return 1;
            }
        }else if(section ==7)
        {
            return 1;
        }
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0)  // 时间section
    {
        int cellRow = (int)indexPath.row;
        if (indexPath.row > 2 && theOrder.order_ProductType == 1) {
            cellRow += 1;
        }
        NormalEditCell * editCell = [self configNormalEditCell:tableView indexPath:indexPath];
        editCell.tableViewLine.hidden = NO;
        switch (cellRow) {
            case 0:
            {
                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                if (orderIsShow) {
                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
                }else
                {
                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                }
                selectImageView.tag = 3001;
                [editCell.contentView addSubview:selectImageView];
                [editCell.titleLabel setText:@"订单编号"];
                [editCell.valueText setText:[NSString stringWithFormat:@"%@",theOrder.order_Number.length ==0 ? @" " :theOrder.order_Number]];
                [editCell setAccessoryText:@"     "];
                editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return editCell;
            }
            case 1:
            {
                [editCell.titleLabel setText:@"下单门店"];
                [editCell.valueText setText:theOrder.order_Branch];
                [editCell setAccessoryText:@""];
                editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return editCell;
            }
            case 2:
            {
                [editCell.titleLabel setText:@"下单时间"];
                [editCell.valueText setText:theOrder.order_OrderTime];
                [editCell setAccessoryText:@""];
                editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return editCell;
            }
            case 3:
            {
                UIButton *addButton = [UIButton buttonWithTitle:@""
                                                         target:self
                                                       selector:@selector(chooseDate:)
                                                          frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                  backgroundImg:[UIImage imageNamed:@"changeDate"]
                                               highlightedImage:nil];
                UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"outOfDate"]];
                imageView.frame = CGRectMake(140.0f, (kTableView_HeightOfRow - 30.0f)/2 + 5, 45.0f, 18.0f);
                if (IOS6)
                    addButton.frame = CGRectMake(285.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                else
                    imageView.frame = CGRectMake(140.0f, (kTableView_HeightOfRow - 30.0f)/2 + 5, 45.0f, 18.0f);
                
                imageView.tag = 1006;
                addButton.tag = 1005;
                imageView.hidden = YES;
                NormalEditCell *cell2 = [self configNormalEditCell2:tableView indexPath:indexPath];
                cell2.tableViewLine.hidden = NO;
                cell2.titleLabel.text = @"服务有效期";
                cell2.valueText.enabled = NO;
                cell2.accessoryType = UITableViewCellAccessoryNone;
                if (theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime) {
                    NSDate *date = nil;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    date = [dateFormatter dateFromString:[theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime substringToIndex:10]];
                    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 8*3600)];
                    cell2.valueText.text = [dateFormatter stringFromDate:date];
                    cell2.valueText.textColor = kColor_Editable;
                    NSDate *currentDate = [NSDate date];
                    date = [dateFormatter dateFromString:[date.description substringToIndex:10]];
                    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
                    
                    if([date compare:currentDate] == NSOrderedDescending || [date compare:currentDate] == NSOrderedSame)
                        imageView.hidden = YES;
                    else{
                        cell2.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 170, 30.0f);
                        imageView.hidden = NO;
                    }
                }else{
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *furtureDate = [dateFormatter dateFromString:@"2099-12-31"];
                    cell2.valueText.text = [dateFormatter stringFromDate:furtureDate];
                    theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime =[NSString stringWithString: cell2.valueText.text];
                }
                if ( theOrder.order_Flag == 1 && theOrder.order_Status == 1) {
                    [cell2 setAccessoryText:@""];
                    cell2.valueText.textColor = kColor_Editable;
                    [cell2 addSubview:addButton];
                    [cell2 setAccessoryText:@"      "];
                }else{
                    [cell2 setAccessoryText:@""];
                    [imageView setFrame:CGRectMake(170.0f, (kTableView_HeightOfRow - 30.0f)/2 + 5, 45.0f, 18.0f)];
                    cell2.valueText.textColor = [UIColor blackColor];
                }
                if(theOrder.order_Status != 1){
                    cell2.selectionStyle = UITableViewCellSelectionStyleNone;
                    imageView.hidden = YES;
                }
                [cell2 addSubview:imageView];
                return cell2;
            }
            case 4:
            {
                //                UIButton *selectButton = (UIButton *)[cell viewWithTag:1000];
                //                if (!selectButton){
                //                    selectButton= [UIButton buttonWithTitle:@""
                //                                                     target:self
                //                                                   selector:@selector(selectCustomer:)
                //                                                      frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                //                                              backgroundImg:[UIImage imageNamed:@"customerSelect"]
                //                                           highlightedImage:nil];
                //                    selectButton.tag = 1000;
                //                    [editCell addSubview:selectButton];
                //                }
                //                if (IOS6) selectButton.frame = CGRectMake(285.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                //                selectButton.hidden = YES;
                //
                //                if (_isBranch == 1){
                //                    selectButton.hidden = NO;
                //                    [editCell setAccessoryText:@"      "];
                //                } else {
                //                    selectButton.hidden = YES;
                //                    [editCell setAccessoryText:@""];
                //                }
                [editCell setAccessoryText:@"   "];
                
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [editCell.contentView addSubview:arrowsImage];
                
                [editCell.titleLabel setText:@"顾客"];
                [editCell.valueText setText:theOrder.order_CustomerName];
                //                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                return editCell;
            }
            case 5:
            {
                [editCell.titleLabel setText:@"创建人"];
                [editCell.valueText setText:theOrder.order_CreatorName];
                [editCell setAccessoryText:@""];
                editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return editCell;
            }
            case 6:
            {
                if (ORDER_RPN_FLAG && (theOrder.order_ResponsiblePersonID == 0)) {
                    UIButton *addButton = [UIButton buttonWithTitle:@""
                                                             target:self
                                                           selector:@selector(changeResponsiblePerson:)
                                                              frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                                      backgroundImg:[UIImage imageNamed:@"order_changeRP"]
                                                   highlightedImage:nil];
                    addButton.tag = 1001;
                    
                    if (IOS6) {
                        addButton.frame = CGRectMake(285.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f);
                    }
                    [editCell.titleLabel setText:@"美丽顾问"];
                    [editCell.valueText setText:theOrder.order_ResponsiblePersonID >0 ?theOrder.order_ResponsiblePersonName:@""];
                    [editCell setAccessoryText:@"      "];
                    editCell.valueText.textColor = kColor_Editable;
                    editCell.accessoryType = UITableViewCellAccessoryNone;
                    UIButton *button = (UIButton *)[cell viewWithTag:1001];
                    if (button == nil) {
                        [editCell addSubview:addButton];
                    }
                } else
                {
                    [editCell.titleLabel setText:@"美丽顾问"];
                    if ((NSNull *)theOrder.order_ResponsiblePersonName != [NSNull null]) {
                        [editCell.valueText setText:theOrder.order_ResponsiblePersonName];
                    }
                    [editCell setAccessoryText:@""];
                    editCell.accessoryType = UITableViewCellAccessoryNone;
                    editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                return editCell;
            }
            case 7:
            {
                [editCell.titleLabel setText:@"销售顾问"];
                [editCell.valueText setText: [NSString stringWithFormat:@"%@",([self.slaveNames isEqualToString:@""] ? @"": self.slaveNames)]];
                [editCell setAccessoryText:@""];
                editCell.accessoryType = UITableViewCellAccessoryNone;
                editCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return editCell;
            }
        }
    }
    
    //-------------------section 1--------------------
    else if (indexPath.section == 2) {
        NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];
        cell.tableViewLine.hidden = NO;
        switch (indexPath.row) {
            case 0:
            {
                // 权限 未支付（支付：支付金额为0） 未完成（服务：_courseStatus（1：未完成 0：待确认或者已完成）
                [cell.titleLabel setText:@"订单状态"];
                [cell.valueText setText:[NSString stringWithFormat:@"%@|%@",theOrder.order_StatusStr.length == 0?@" ":theOrder.order_StatusStr,theOrder.order_IspaidStr .length == 0? @" ":theOrder.order_IspaidStr]];
                
                [cell setAccessoryText:@""];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            case 1:
            {
                if ((theOrder.order_Ispaid == 2 || theOrder.order_Ispaid == 3||theOrder.order_Ispaid == 4)) {
                    [cell.titleLabel setText:@"支付详情"];
                    [cell.valueText setText:@""];
                    [cell setAccessoryText:@""];
                    
                }else if(self.HasNetTrade)
                {
                    [cell.titleLabel setText:@"第三方支付结果"];
                    [cell.valueText setText:@""];
                    [cell setAccessoryText:@""];
                }
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
                
                return cell;
            }
            case 2:{
                [cell.titleLabel setText:@"第三方支付结果"];
                [cell.valueText setText:@""];
                [cell setAccessoryText:@""];
                
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
                return cell;
            }
                break;
                
        }
        
    }
    else if(indexPath.section == 1)
    {
        cell.valueText.enabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tableViewLine.hidden = NO;
        NSInteger count =theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice ? 0:1;
        
        NSInteger row = indexPath.row;
        if (count== 0 && indexPath.row ==4 ) {
            row ++ ;
        }
        if (theOrder.BenefitListArr.count > 0) {
            
            if (row == 0) {
                cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 170, 30.0f);
                
                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                if (serveSection1IsShow) {
                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
                }else
                {
                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                }
                selectImageView.tag = 3002;
                [cell.contentView addSubview:selectImageView];
                
                cell.titleLabel.text = [NSString stringWithFormat:@"%@",theOrder.productAndPriceDoc.productDoc.pro_Name.length == 0?@" ":theOrder.productAndPriceDoc.productDoc.pro_Name];
                
            }else if(row == 1){
                cell.titleLabel.text = @"数量";
                cell.valueText.text =[NSString stringWithFormat:@"%ld", (long)theOrder.productAndPriceDoc.productDoc.pro_quantity];;
                
            }else if(row == 2){
                cell.titleLabel.text =@"原价小计";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalMoney];
            }else if(row == 3){
                cell.titleLabel.text = @"会员价";
                cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice];
            }else if(row == 4){
                cell.titleLabel.text = @"优惠券";
                cell.valueText.text =@"";
            }else if(row == 4 + theOrder.BenefitListArr.count + 1){
                cell.titleLabel.text = @"成交价";
                cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
                
            }else if(row == 5 + theOrder.BenefitListArr.count + 1){
                
                if (theOrder.productAndPriceDoc.productDoc.pro_refundPrice > 0.0001f && theOrder.order_Ispaid == 4 ) {
                    cell.titleLabel.text = @"退款总额";
                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_refundPrice];
                }else
                {
                    cell.titleLabel.text = @"未付余额";
                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_UnPaidPrice];
                }
            }else {
                WelfareRes *welfare = theOrder.BenefitListArr[indexPath.row - 5];
                cell.titleLabel.text = [NSString stringWithFormat:@"    %@",welfare.PolicyName];
                cell.valueText.textColor = RGBA(293, 32, 45, 1);
                cell.valueText.text =[NSString stringWithFormat:@"-%@", welfare.PRValue2];
            }
            
        }else{
            switch (row) {
                case 0:
                {
                    cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 170, 30.0f);
                    
                    UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                    if (serveSection1IsShow) {
                        selectImageView.image = [UIImage imageNamed:@"jiantous"];
                    }else
                    {
                        selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                    }
                    selectImageView.tag = 3002;
                    [cell.contentView addSubview:selectImageView];
                    
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@",theOrder.productAndPriceDoc.productDoc.pro_Name.length == 0?@" ":theOrder.productAndPriceDoc.productDoc.pro_Name];
                }
                    break;
                case 1:
                {
                    cell.titleLabel.text = @"数量";
                    cell.valueText.text =[NSString stringWithFormat:@"%ld", (long)theOrder.productAndPriceDoc.productDoc.pro_quantity];;
                }
                    break;
                case 2:
                {
                    cell.titleLabel.text =@"原价小计";
                    cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalMoney];
                }
                    break;
                case 3:
                {
                    cell.titleLabel.text = @"会员价";
                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice];
                }
                    break;
                case 4:
                {
                    cell.titleLabel.text = @"成交价";
                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
                }
                    break;
                case 5:
                {
                    
                    if (theOrder.productAndPriceDoc.productDoc.pro_refundPrice > 0.0001f && theOrder.order_Ispaid == 4 ) {
                        cell.titleLabel.text = @"退款总额";
                        cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_refundPrice];
                    }else
                    {
                        cell.titleLabel.text = @"未付余额";
                        cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_UnPaidPrice];
                    }
                }
                    break;
                    
                default:
                {
                    cell.titleLabel.text = @"退款总额";
                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_refundPrice];
                }
                    
                    break;
            }
            
        }
        
        //        switch (row) {
        //            case 0:
        //            {
        //                cell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 170, 30.0f);
        //
        //                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
        //                if (serveSection1IsShow) {
        //                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
        //                }else
        //                {
        //                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
        //                }
        //                selectImageView.tag = 3002;
        //                [cell.contentView addSubview:selectImageView];
        //
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",theOrder.productAndPriceDoc.productDoc.pro_Name.length == 0?@" ":theOrder.productAndPriceDoc.productDoc.pro_Name];
        //            }
        //                break;
        //            case 1:
        //            {
        //                cell.titleLabel.text = @"数量";
        //                cell.valueText.text =[NSString stringWithFormat:@"%ld", (long)theOrder.productAndPriceDoc.productDoc.pro_quantity];;
        //            }
        //                break;
        //            case 2:
        //            {
        //                cell.titleLabel.text =@"原价小计";
        //                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalMoney];
        //            }
        //                break;
        //            case 3:
        //            {
        //                cell.titleLabel.text = @"会员价";
        //                cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice];
        //            }
        //                break;
        //            case 4:
        //            {
        //                cell.titleLabel.text = @"成交价";
        //                cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
        //            }
        //                break;
        //            case 5:
        //            {
        //
        //                if (theOrder.productAndPriceDoc.productDoc.pro_refundPrice > 0.0001f && theOrder.order_Ispaid == 4 ) {
        //                    cell.titleLabel.text = @"退款总额";
        //                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_refundPrice];
        //                }else
        //                {
        //                    cell.titleLabel.text = @"未付余额";
        //                    cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_UnPaidPrice];
        //                }
        //            }
        //                break;
        //
        //            default:
        //            {
        //                cell.titleLabel.text = @"退款总额";
        //                cell.valueText.text =[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theOrder.productAndPriceDoc.productDoc.pro_refundPrice];
        //            }
        //
        //                break;
        //        }
    }
    // －－－－－－－－section 2  /3 /4--未完成/已完成
    else if (indexPath.section == 3) {
        cell.tableViewLine.hidden = NO;
        if (self.productType == 0) {
            
            if (indexPath.row == 0) {
                NormalEditCell *normalCell = [self configNormalEditCell:tableView indexPath:indexPath];
                normalCell.titleLabel.textColor = [UIColor blackColor];
                [normalCell setAccessoryType:UITableViewCellAccessoryNone];
                if (theOrder.productAndPriceDoc.productDoc.pro_TotalCount ==0) {
                    [normalCell.titleLabel setText:[NSString stringWithFormat:@"完成%ld次/不限次",(long)theOrder.productAndPriceDoc.productDoc.pro_FinishedCount]];
                    normalCell.valueText.text = @" ";
                }else
                {
                    //===========以下是Ryan修改========
                    long surplusCount = (long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount;
                    //==========以上是Ryan修改=========
                    [normalCell.titleLabel setText:[NSString stringWithFormat:@"进行中%ld次/完成%ld次/共%ld次",(long)theOrder.productAndPriceDoc.productDoc.pro_TotalCount-surplusCount-(long)theOrder.productAndPriceDoc.productDoc.pro_FinishedCount,(long)theOrder.productAndPriceDoc.productDoc.pro_FinishedCount,(long)theOrder.productAndPriceDoc.productDoc.pro_TotalCount]];
                    
                    normalCell.valueText.frame = CGRectMake(155.0f, (kTableView_HeightOfRow - 30.0f)/2, 150.0f, 30.0f);
                    normalCell.valueText.textAlignment = NSTextAlignmentRight;
                    //===========以下是Ryan修改========
                    [normalCell.valueText setText:[NSString stringWithFormat:@"剩余 %ld次", surplusCount]];
                    //==========以上是Ryan修改=========
                    //[normalCell.valueText setText:[NSString stringWithFormat:@"剩余 %ld次", (long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount]];
                }
                
                return normalCell;
            }else {
                NormalEditCell *unfinishCell = [self configNormalEditCell:tableView indexPath:indexPath];
                unfinishCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                unfinishCell.titleLabel.frame =  CGRectMake(20.0f, kTableView_HeightOfRow/2 - 20.0f/2, 170, 20.0f);
                unfinishCell.titleLabel.textColor = [UIColor blackColor];
                [unfinishCell setAccessoryType:UITableViewCellAccessoryNone];
                unfinishCell.valueText.frame = CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 160, 30.0f);
                unfinishCell.valueText.textAlignment = NSTextAlignmentRight;
                
                UIImageView * moreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(288, 9, 20, 20)];
                moreImageView.image = [UIImage imageNamed:@"order_operateButton"];
                moreImageView.tag = indexPath.section+indexPath.row;
                
                NSDictionary * serveDic =[unFinishiServeArr objectAtIndex:(indexPath.row-1)];
                NSString * type = [serveDic objectForKey:@"type"];
                if ([type isEqualToString:@"TG"]) {//顾问
                    [unfinishCell.titleLabel setText:@"服务顾问"];
                    unfinishCell.titleLabel.textColor = kColor_DarkBlue;
                    [unfinishCell.valueText setText:[serveDic objectForKey:@"ServicePicName"]];
                    
                    if (theOrder.order_Status != 1 ||[[serveDic objectForKey:@"Status"] integerValue] !=1 || [self groupByPermission:serveDic] == NO) {
                        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                        [unfinishCell.contentView addSubview:arrowsImage];
                    }else
                    {
                        [unfinishCell addSubview:moreImageView];
                    }
                    
                }else if ([type isEqualToString:@"number"])
                {
                    unfinishCell.titleLabel.frame =  CGRectMake(20.0f, kTableView_HeightOfRow/2 - 20.0f/2, 170, 20.0f);
                    unfinishCell.tableViewTopLine.hidden = NO;
                    //结单.完成本次服务
                    UIButton *endOrderBt = [UIButton buttonTypeRoundedRectWithTitle:@"结单" target:self selector:@selector(completeGroup:) frame:CGRectMake(200.0f, 9, 50.0f, 22.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:8.0f];
                    endOrderBt.tag = 200+indexPath.row;
                    
                    //撤销
                    UIButton *cancelBt = [UIButton buttonTypeRoundedRectWithTitle:@"撤销" target:self selector:@selector(deleteGroup:) frame:CGRectMake(255.0f, 9, 50.0f, 22.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Red cornerRadius:8.0f];
                    cancelBt.tag = 300+indexPath.row;
                    
#pragma mark 权限
                    if ([self groupByPermission:serveDic]) { //theOrder.editStatus == OrderEditStatusNone
                        endOrderBt.hidden = NO;
                        cancelBt.hidden = NO;
                    } else {
                        endOrderBt.hidden = YES;
                        cancelBt.hidden = YES;
                    }
                    
                    [unfinishCell.titleLabel setText:[serveDic objectForKey:@"StartTime"]];
                    [unfinishCell.valueText setText:@""];
                    if(theOrder.order_Status ==1){
                        [unfinishCell addSubview:endOrderBt];
                        [unfinishCell addSubview:cancelBt];
                    }
                }
                else
                {
                    //                        UIImageView * desineImageView = (UIImageView *)[unfinishCell.contentView viewWithTag:4000+indexPath.row];
                    //                        if (!desineImageView) {
                    //////                            //指定
                    //                        UIImageView * desineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 13, 12, 12)];
                    //                        desineImageView.image = nil;
                    //                        desineImageView.tag = 4001;
                    //                        [unfinishCell addSubview:desineImageView];
                    ////                        }
                    //                        desineImageView.hidden = YES;
                    //
                    //                        if ([[serveDic objectForKey:@"IsDesignated"] integerValue]) {
                    //                            desineImageView.hidden = NO;
                    //                            desineImageView.image = [UIImage imageNamed:@"order_designated"];
                    //                        }
                    
                    //指定
                    UIImageView * zhiDingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 13, 12, 12)];
                    zhiDingImageView.image = [UIImage imageNamed:@"order_designated"];
                    zhiDingImageView.hidden = YES;
                    zhiDingImageView.tag = 2001;
                    [unfinishCell addSubview:zhiDingImageView];
                    if ([[serveDic objectForKey:@"IsDesignated"] integerValue]) {
                        zhiDingImageView.hidden = NO;
                    }
                    
                    
                    UIImageView * imageQuan = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 6, 6)];
                    imageQuan.image = [UIImage imageNamed:@"yuan"];
                    imageQuan.tag = 1181;
                    [unfinishCell.contentView addSubview:imageQuan];
                    
                    unfinishCell.titleLabel.frame =  CGRectMake(30.0f, kTableView_HeightOfRow/2 - 20.0f/2, 170, 20.0f);
                    unfinishCell.titleLabel.textColor = [UIColor blackColor];
                    [unfinishCell.titleLabel setText:[NSString stringWithFormat:@"%@", [[serveDic objectForKey:@"SubServiceName"] isEqualToString:@""] ? @"服务操作" : [serveDic objectForKey:@"SubServiceName"]]];
                    [unfinishCell.valueText setText:[serveDic objectForKey:@"ExecutorName"]];
                    
                    if (theOrder.order_Status != 1 || [[serveDic objectForKey:@"Status"] integerValue] !=1 || [self groupByPermission:serveDic] == NO) {
                        
                        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                        [unfinishCell.contentView addSubview:arrowsImage];
                    }else
                    {
                        [unfinishCell addSubview:moreImageView];
                    }
                }
                return unfinishCell;
            }
        }else {//商品
            //                ORDER_STATUS_SHOW
            if  (1 ) {
                NormalEditCell *normalCell = [self configNormalEditCell:tableView indexPath:indexPath];
                [normalCell setAccessoryType:UITableViewCellAccessoryNone];
                normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
                normalCell.titleLabel.textColor = [UIColor blackColor];
                
                if (indexPath.row == 0) {
                    normalCell.titleLabel.text = [NSString stringWithFormat:@"已交付 %ld 件/共%ld件",(long)theOrder.productAndPriceDoc.productDoc.pro_FinishedCount,(long)theOrder.productAndPriceDoc.productDoc.pro_TotalCount];
                    
                    normalCell.valueText.text = [NSString stringWithFormat:@"剩余 %ld 份",(long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount];
                    return normalCell;
                }else
                {
                    normalCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                    NSDictionary * dic =[unFinishiServeArr objectAtIndex:indexPath.row-1];
                    if ([[dic objectForKey:@"type"] isEqualToString:@"one"]) {
                        normalCell.tableViewTopLine.hidden = NO;
                        normalCell.titleLabel.text = [dic objectForKey:@"StartTime"] ;
                        //结单
                        UIButton *endOrderBt = [UIButton buttonTypeRoundedRectWithTitle:@"结单" target:self selector:@selector(paycommodity:) frame:CGRectMake(200.0f, 9, 50.0f, 22.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:8.0f];
                        endOrderBt.tag = 400+indexPath.row-1;;
                        //撤销
                        UIButton *cancelBt = [UIButton buttonTypeRoundedRectWithTitle:@"撤销" target:self selector:@selector(productCancel:) frame:CGRectMake(255.0f, 9, 50.0f, 22.0f) titleColor:[UIColor whiteColor] backgroudColor:KColor_Red cornerRadius:8.0f];
                        cancelBt.tag = 200+indexPath.row-1;
                        
                        if(theOrder.order_Status ==1 && theOrder.editStatus != OrderEditStatusNone){
                            [normalCell.contentView addSubview:endOrderBt];
                            [normalCell.contentView addSubview:cancelBt];
                        }
                    }else
                    {
                        normalCell.titleLabel.text = @"本次交付数量";
                        normalCell.valueText.text = [NSString stringWithFormat:@"%@件",[dic objectForKey:@"Quantity"]];
                    }
                    return normalCell;
                }
            }
        }
    }
    else if (indexPath.section ==4 && scdlListArr.count>0)//预约
    {
        cell.tableViewLine.hidden = NO;
        if (indexPath.row ==0) {
            cell.titleLabel.text = @"已确认预约";
            UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
            if (scdlShowBool) {
                selectImageView.image = [UIImage imageNamed:@"jiantous"];
            }else
            {
                selectImageView.image = [UIImage imageNamed:@"jiantoux"];
            }
            selectImageView.tag = 2118;
            [cell.contentView addSubview:selectImageView];
            
        }else
        {
            cell.titleLabel.frame = CGRectMake(5.0f,5, 20, 20.0f);
            cell.titleLabel.font = [UIFont systemFontOfSize:11.];
            UILabel * TGStartTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 150, kTableView_HeightOfRow)];
            TGStartTimeLable.font = kFont_Light_16;
            TGStartTimeLable.tag = 2119;
            TGStartTimeLable.text = [NSString stringWithFormat:@"%@",[[scdlListArr objectAtIndex:indexPath.row-1] objectForKey:@"ResponsiblePersonName"]];
            [cell addSubview:TGStartTimeLable];
            
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%ld.",(long)indexPath.row];
            cell.valueText.text = [[scdlListArr objectAtIndex:indexPath.row-1] objectForKey:@"TaskScdlStartTime"];
            [cell setAccessoryText:@"    "];
        }
        return cell;
    }
    else if(indexPath.section == 5 )//已完成
    {
        NormalEditCell *NormalEditCell = [self configNormalEditCell:tableView indexPath:indexPath];
        
        NSInteger pastCount = theOrder.productAndPriceDoc.productDoc.pro_PastCount >0? 1:0;
        if (theOrder.order_ProductType == 0) {
            if (indexPath.row == 0) {
                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                if (finishServeIsShow) {
                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
                }else
                {
                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                }
                selectImageView.tag = 3003;
                [NormalEditCell.contentView addSubview:selectImageView];
                
                [NormalEditCell.titleLabel setText:@"已完成服务记录"];
                [NormalEditCell.valueText setText:@""];
                [NormalEditCell setAccessoryText:@""];
                return NormalEditCell;
            }else if(indexPath.row == 1 && (long)theOrder.productAndPriceDoc.productDoc.pro_PastCount >0){
                NormalEditCell.tableViewTopLine.hidden = NO;
                NormalEditCell.titleLabel.textColor = [UIColor blackColor];
                [NormalEditCell.titleLabel setText:[NSString stringWithFormat:@"过去完成次数%ld",(long)theOrder.productAndPriceDoc.productDoc.pro_PastCount]];
                [NormalEditCell.valueText setText:@""];
                return NormalEditCell;
            }else{
                NormalEditCell.titleLabel.frame = CGRectMake(20.0f, kTableView_HeightOfRow/2 - 20.0f/2, 160, 20.0f);
                NormalEditCell.valueText.frame = CGRectMake(150.0f, kTableView_HeightOfRow/2 - 30.0f/2, 130, 30.0f);
                NormalEditCell.valueText.textAlignment = NSTextAlignmentRight;
                NSDictionary * serveDic =[finishiServeArr objectAtIndex:(indexPath.row-1-pastCount)];
                NSString * type = [serveDic objectForKey:@"type"];
                if ([type isEqualToString:@"number"])
                {
                    NormalEditCell.tableViewTopLine.hidden = NO;
                    NormalEditCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                    UILabel * TGStartTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 150, kTableView_HeightOfRow)];
                    TGStartTimeLable.font = kFont_Light_16;
                    TGStartTimeLable.tag = 2201;
                    TGStartTimeLable.text = [serveDic objectForKey:@"StartTime"];
                    [NormalEditCell addSubview:TGStartTimeLable];
                    
                    [theOrder setOrder_TGStatus:[[serveDic objectForKey:@"Status"] intValue]];
                    NormalEditCell.titleLabel.frame = CGRectMake(5.0f,5, 30, 20.0f);
                    NormalEditCell.titleLabel.font = [UIFont systemFontOfSize:11.];
                    NormalEditCell.valueText.frame = CGRectMake(200.0f, kTableView_HeightOfRow/2 - 30.0f/2, 105, 30.0f);
                    
                    NSInteger num = theOrder.productAndPriceDoc.productDoc.pro_PastCount + [[serveDic objectForKey:@"number"] integerValue];
                    
                    [NormalEditCell.titleLabel setText:[NSString stringWithFormat:@"%ld.",(long)num]];
                    [NormalEditCell.valueText setText:theOrder.order_TGStatusStr];
                }else if ([type isEqualToString:@"TG"]) {//顾问
                    
                    NormalEditCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                    NormalEditCell.titleLabel.textColor = kColor_DarkBlue;
                    [NormalEditCell.titleLabel setText:@"服务顾问"];
                    [NormalEditCell.valueText setText:[serveDic objectForKey:@"ServicePicName"]];
                    
                    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                    [NormalEditCell.contentView addSubview:arrowsImage];
                    
                }else
                {
                    //指定
                    UIImageView * desineImageView = (UIImageView *)[cell.contentView viewWithTag:2100+indexPath.row];
                    if (!desineImageView) {
                        
                        desineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 13, 12, 12)];
                        desineImageView.image = [UIImage imageNamed:@"order_designated"];
                        desineImageView.hidden = YES;
                        desineImageView.tag = 2100+indexPath.row;
                        [NormalEditCell.contentView addSubview:desineImageView];
                    }
                    if ([[serveDic objectForKey:@"IsDesignated"] integerValue]) {
                        desineImageView.hidden = NO;
                    }else
                    {
                        desineImageView.hidden = YES;
                    }
                    
                    //圆圈
                    UIImageView * imageQuan = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 6, 6)];
                    imageQuan.image = [UIImage imageNamed:@"yuan"];
                    [NormalEditCell.contentView addSubview:imageQuan];
                    
                    //
                    NormalEditCell.titleLabel.frame = CGRectMake(30.0f, kTableView_HeightOfRow/2 - 20.0f/2, 160, 20.0f);
                    NormalEditCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                    NormalEditCell.titleLabel.textColor = [UIColor blackColor];
                    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                    [NormalEditCell.contentView addSubview:arrowsImage];
                    
                    [NormalEditCell.titleLabel setText:[NSString stringWithFormat:@"%@", [[serveDic objectForKey:@"SubServiceName"]isEqualToString:@""] ? @"服务操作" : [serveDic objectForKey:@"SubServiceName"]]];
                    
                    [NormalEditCell.valueText setText:[serveDic objectForKey:@"ExecutorName"]];
                }
                return NormalEditCell;
            }
        }else{//商品已完成纪录
            if (indexPath.row == 0) {
                UIImageView * selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(288, kTableView_HeightOfRow/2 - 10.0f/2 , 20,13)];
                if (finishServeIsShow) {
                    selectImageView.image = [UIImage imageNamed:@"jiantous"];
                }else
                {
                    selectImageView.image = [UIImage imageNamed:@"jiantoux"];
                }
                selectImageView.tag = 3004;
                [NormalEditCell.contentView addSubview:selectImageView];
                
                [NormalEditCell.titleLabel setText:@"已交付商品记录"];
                
            }else if((indexPath.row-1)%2 == 0){
                NormalEditCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                NormalEditCell.titleLabel.frame = CGRectMake(10.0f,5, 30, 20.0f);
                NormalEditCell.titleLabel.font = kFont_Light_12;
                NormalEditCell.tableViewTopLine.hidden = NO;
                NSDictionary * finishiDic = [finishiServeArr objectAtIndex:indexPath.row-1];
                
                [NormalEditCell.titleLabel setText:[NSString stringWithFormat:@"%@.",[finishiDic objectForKey:@"number"]]];
                
                UILabel * TGStartTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 150, kTableView_HeightOfRow)];
                TGStartTimeLable.font = kFont_Light_16;
                TGStartTimeLable.tag = 2201;
                TGStartTimeLable.text = [finishiDic objectForKey:@"StartTime"];
                [NormalEditCell addSubview:TGStartTimeLable];
                
                [theOrder setOrder_TGStatus:[[finishiDic objectForKey:@"Status"] intValue]];
                NormalEditCell.valueText.text = [NSString stringWithFormat:@"%@|%@件",theOrder.order_TGStatusStr,[finishiDic objectForKey:@"Quantity"]];
            }else
            {
                NormalEditCell.backgroundColor = [UIColor colorWithRed:246/255.0f green:255/255.0f blue:246/255.0f alpha:1.0f];
                NormalEditCell.titleLabel.frame = CGRectMake(40.0f, kTableView_HeightOfRow/2 - 20.0f/2, 160, 20.0f);
                NormalEditCell.titleLabel.textColor = [UIColor blackColor];
                [NormalEditCell.titleLabel setText:@"服务顾问"];
                
                [NormalEditCell.valueText setText:[[finishiServeArr objectAtIndex:indexPath.row-1] objectForKey:@"ServicePicName"]];
                
            }
            return NormalEditCell;
        }
        //如果已经交付完成 显示备注
    }
    //-------------------section last---------------------
    else if(indexPath.section == 6) {
        if (ORDER_STATUS_HIDDEN) {
            switch (indexPath.row) {
                case 0:
                {
                    NormalEditCell  *normalRemark = [self configNormalEditCell3:tableView indexPath:indexPath];
                    normalRemark.tableViewLine.hidden = NO;
                    [normalRemark.titleLabel setText:@"备注"];
                    normalRemark.valueText.frame = CGRectMake(175.0f, (kTableView_HeightOfRow - 30.0f)/2, 100.0f, 30.0f);
                    normalRemark.valueText.text = nil;
                    UIButton *saveButton = (UIButton *)[normalRemark viewWithTag:1004];
                    saveButton.hidden = bool_save;
                    UIButton *editButton = (UIButton *)[normalRemark viewWithTag:1003];
                    editButton.hidden = bool_edit;
                    return normalRemark;
                }
                case 1:
                {
                    static NSString *editCellIdentifier = @"editCell";
                    ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                    
                    if ( [theOrder.order_Remark isEqualToString:@"(null)"] || theOrder.order_Remark.length == 0) {
                        editCell.contentEditText.placeholder = @"请输入备注...";
                    } else {
                        editCell.contentEditText.text = theOrder.order_Remark;
                        editCell.contentEditText.textColor = bool_edit ? kColor_Editable : [UIColor blackColor];
                    }
                    editCell.contentEditText.editable = !bool_save;
                    editCell.contentEditText.tag = 1000;
                    editCell.delegate = self;
                    return editCell;
                }
                default:
                    break;
            }
        }else{
            switch (indexPath.row) {
                case 0:
                {
                    NormalEditCell  *normalRemark = [self configNormalEditCell3:tableView indexPath:indexPath];
                    normalRemark.tableViewLine.hidden = NO;
                    [normalRemark.titleLabel setText:@"备注"];
                    normalRemark.valueText.frame = CGRectMake(175.0f, (kTableView_HeightOfRow - 30.0f)/2, 100.0f, 30.0f);
                    normalRemark.valueText.text = nil;
                    UIButton *saveButton = (UIButton *)[normalRemark viewWithTag:1004];
                    saveButton.hidden = bool_save;
                    UIButton *editButton = (UIButton *)[normalRemark viewWithTag:1003];
                    editButton.hidden = bool_edit;
                    
                    return normalRemark;
                }
                case 1:
                {
                    static NSString *editCellIdentifier = @"editCell";
                    
                    ContentEditCell  *editCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:editCellIdentifier];
                    
                    if ( [theOrder.order_Remark isEqualToString:@""] || theOrder.order_Remark.length == 0) {
                        editCell.contentEditText.placeholder = @"请输入备注...";
                    } else {
                        editCell.contentEditText.text = theOrder.order_Remark;
                        editCell.contentEditText.textColor = bool_edit ? kColor_Editable : [UIColor blackColor];
                    }
                    editCell.contentEditText.editable = !bool_save;
                    editCell.contentEditText.tag = 1000;
                    editCell.delegate = self;
                    return editCell;
                }
                default:
                    break;
            }
        }
    }
    return cell;
}

- (BOOL)groupByPermission:(NSDictionary *)serviceDic
{
    if ([[PermissionDoc sharePermission] rule_AllOrder_Write]) {
        return YES;
    } else {
        if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
            if (theOrder.isMyOrder) {
                return YES;
            } else {
                if ([[serviceDic valueForKey:@"ServicePicID"] integerValue] == ACC_ACCOUNTID) {
                    return YES;
                } else {
                    return NO;
                }
            }
        } else {
            return NO;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.productType == 0 && indexPath.section == 6 && indexPath.row == 1) {
        return kTableView_HeightOfRow > theOrder.remark_height ? kTableView_HeightOfRow : theOrder.remark_height;
    }
    if (self.productType == 1 ) {
        if (indexPath.section == 6  && indexPath.row == 1 ) {
            return kTableView_HeightOfRow > theOrder.remark_height ? kTableView_HeightOfRow : theOrder.remark_height;
        }
        return kTableView_HeightOfRow;
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section ==0) {
        if ((theOrder.order_Status == 1||theOrder.order_Status == 2) && ([[PermissionDoc sharePermission] rule_Payment_Use]||theOrder.editStatus != OrderEditStatusNone)){
            
            if (theOrder.order_Status == 2 && (theOrder.order_Ispaid ==3 || theOrder.order_Ispaid ==5)) {
                return kTableView_Margin_TOP;
            }
            return 30;
        }
        if (theOrder.order_Status == 4 && [[PermissionDoc sharePermission] rule_Payment_Use]) {
            //终止状态下已退款和未支付返回间隙减小以防空行
            if(theOrder.order_Ispaid == 4 || theOrder.order_Ispaid == 1){
                return kTableView_Margin_TOP;
            }else{
                return 30;
            }
        }
    }
    
    if (section == 4) {
        if (theOrder.order_Status == 1 && [[PermissionDoc sharePermission] rule_MyOrder_Write]) {
            //            开单 预约
            //            NSInteger  count  = 100 ;
            //            if (theOrder.productAndPriceDoc.productDoc.pro_TotalCount > 0) {
            //              count = theOrder.productAndPriceDoc.productDoc.pro_SurplusCount - scdlListArr.count;
            //            }
            //
            if ((theOrder.productAndPriceDoc.productDoc.pro_SurplusCount >0 ||theOrder.productAndPriceDoc.productDoc.pro_TotalCount ==0) ) { //&& count > 0
                return 30;
            }
        }
    }
    
    if (section ==5 && scdlListArr.count ==0) {
        
        return 0.5;
    }
    if(section == 6 && (finishiServeArr.count == 0 &&theOrder.productAndPriceDoc.productDoc.pro_PastCount == 0))
    {
        return 0.5;
    }
    
    return kTableView_Margin_TOP;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 40)];
    view.backgroundColor = [UIColor clearColor];
    if (section == 0) {
#pragma mark 权限
        if ((theOrder.order_Status == 1||theOrder.order_Status == 2||theOrder.order_Status == 4)){ // && theOrder.editStatus != OrderEditStatusNone
            [self initNavButton:view];
        }
    }
    
    if (section == 4) {
        if (theOrder.order_Status == 1 && [[PermissionDoc sharePermission] rule_MyOrder_Write]) { //theOrder.editStatus != OrderEditStatusNone
            //开单
            NSInteger  count  = 100 ;
            if (theOrder.productAndPriceDoc.productDoc.pro_TotalCount > 0) {
                count =  theOrder.productAndPriceDoc.productDoc.pro_SurplusCount - scdlListArr.count;
            }
            //订单详情页，预约次数+进行中小单次数+已完成小单次数>=总次数时，预约按钮不应出现
            if ((theOrder.productAndPriceDoc.productDoc.pro_SurplusCount >0 ||theOrder.productAndPriceDoc.productDoc.pro_TotalCount ==0)) {
                UIButton *addOrderButton = [UIButton buttonTypeRoundedRectWithTitle:@"开单" target:self selector:@selector(checkOrderAndSubscribe:) frame:CGRectMake(0, 4, 50, 22)  titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
                addOrderButton.tag = 997;
                [view addSubview:addOrderButton];
                
                if (self.productType == 0 && count >0) {
                    if (!theOrder.order_AppointMustPaid || (theOrder.order_AppointMustPaid &&  theOrder.order_Ispaid != 1)) {
                        //预约
                        UIButton *subscribeButton = [UIButton buttonTypeRoundedRectWithTitle:@"预约" target:self selector:@selector(checkOrderAndSubscribe:) frame:CGRectMake(55, 4, 50, 22)  titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
                        subscribeButton.tag = 998;
                        [view addSubview:subscribeButton];
                    }
                }
                
            }
        }
    }
    
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section ==0 && indexPath.row ==0) {
        orderIsShow = !orderIsShow;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }else if(indexPath.section == 1 && indexPath.row ==0)
    {
        serveSection1IsShow = !serveSection1IsShow;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }else if (indexPath.section == 1 && indexPath.row ==4)
    {
        //        [self changeOrderPrice];
    }
    
    else if (indexPath.section == 3){
        if (indexPath.row > 0 && indexPath.row < (uncount+1)) {
            NSString * type = [[unFinishiServeArr objectAtIndex:(indexPath.row-1)] objectForKey:@"type"];
            NSInteger  status = [[[unFinishiServeArr objectAtIndex:(indexPath.row-1)] objectForKey:@"Status"] integerValue];
            if ([type isEqualToString:@"treatment"]) {
                if(status == 1 && theOrder.order_Status ==1 && [self groupByPermission:[unFinishiServeArr objectAtIndex:(indexPath.row -1)]])//未完成
                {
                    [self nonoTreatment:[unFinishiServeArr objectAtIndex:(indexPath.row-1)]];
                }else
                {//跳转到详情页
                    [self goToTabBarFromOrderDetailView:[unFinishiServeArr objectAtIndex:(indexPath.row-1)]];
                }
                
            }else if ([type isEqualToString:@"TG"])
            {
                if(status == 1 && theOrder.order_Status ==1 && [self groupByPermission:[unFinishiServeArr objectAtIndex:(indexPath.row -1)]])
                {
                    [self groupServe:[unFinishiServeArr objectAtIndex:(indexPath.row-1)]];
                    
                }else
                {   //跳转到TG详情页
                    [self gotoTreatmentGroupDetail:[unFinishiServeArr objectAtIndex:(indexPath.row-1)]];
                    
                }
            }
        }
    }else if(indexPath.section == 4 )
    {
        if (indexPath.row ==0) {
            scdlShowBool = !scdlShowBool;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        }else{//跳转到预约详情
            AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
            detail.LongID = [[[scdlListArr objectAtIndex:indexPath.row-1] objectForKey:@"TaskID"] longLongValue];
            detail.viewFor = 3;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
    else if((indexPath.section == 5  ) &&( finishiServeArr.count >0 ||((long)theOrder.productAndPriceDoc.productDoc.pro_PastCount >0)))//隐藏／显示已完成订单
    {
        if (indexPath.row ==0) {
            finishServeIsShow = !finishServeIsShow ;
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:indexPath.section];
            [tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            
        }else if(self.productType == 0) { //进入已完成服务的详情页
            if (indexPath.row >1) {
                NSInteger pastCount = theOrder.productAndPriceDoc.productDoc.pro_PastCount >0? 1:0;
                NSDictionary * dic =[finishiServeArr objectAtIndex:indexPath.row-1-pastCount];
                if ([[dic objectForKey:@"type"] isEqualToString:@"TG"]) {
                    
                    [self gotoTreatmentGroupDetail:dic];
                    
                }else if([[dic objectForKey:@"type"] isEqualToString:@"treatment"]){
                    
                    [self goToTabBarFromOrderDetailView:dic];
                }
            }
        } else { //已完成商品
            int row = indexPath.row - 1;
            int section = row/2;
            int indexArray = section * 2;
            NSDictionary *dic =[finishiServeArr objectAtIndex:indexArray];
            NSString *thumbnailURL = [NSString stringWithFormat:@"%@", [dic objectForKey:@"ThumbnailURL"]];
            NSString *message = [NSString stringWithFormat:@"%@", [dic objectForKey:@"GroupNo"]];
            deliveryView = [[DeliveryView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
            deliveryView.backgroundColor = RGBA(66, 66, 66, 0.5);
            if (thumbnailURL && thumbnailURL.length > 0) { // 签名
                [deliveryView initSignImageView];
                deliveryView.groupNo = message;
                deliveryView.thumbnailURL = thumbnailURL;
            }else{ //不签名
                [deliveryView initView];
                deliveryView.groupNo = message;
            }
            __weak typeof(self) weakSelf = self;
            deliveryView.deliveryViewConfrimBlock = ^(){
                [weakSelf removeDeliveryView];
            };
            [self.view addSubview:deliveryView];
        }
        return;
    }
    
    // 支付 详情
    if (indexPath.section ==2) {
        if (indexPath.row == 1) {
            if ((theOrder.order_Ispaid == 2 || theOrder.order_Ispaid == 3|| theOrder.order_Ispaid == 4)&& _isBranch !=2)
            {
                [self goToThePayHistory];
            }else if(self.HasNetTrade)
            {
                ThirdPatmentRecords_ViewController * records = [[ThirdPatmentRecords_ViewController alloc] init];
                records.orderId = orderID;
                records.viewFor = 1 ;
                [self.navigationController pushViewController:records animated:YES];
            }
        }
        if (indexPath.row ==2) {
            ThirdPatmentRecords_ViewController * records = [[ThirdPatmentRecords_ViewController alloc] init];
            records.orderId = orderID;
            records.viewFor = 1 ;
            [self.navigationController pushViewController:records animated:YES];
        }
    }
    
    if ( ORDER_RPN_FLAG && indexPath.section == 0 && indexPath.row == 3) {
        if(theOrder.order_Status == 0 && theOrder.order_ProductType == 0)
            [self chooseDate:[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1005]];
    }
    
    //是否允许修改统计~~
    //    if (indexPath.section == 0 &&((indexPath.row == 4 && theOrder.order_ProductType == 0) || (indexPath.row == 3 && theOrder.order_ProductType == 1)) && ORDER_STATUS_FLAG) {
    //        [self upDataAdd:(NSIndexPath *)indexPath];
    //    }
    //是不是我的顾客？？？
    if (indexPath.section == 0 && indexPath.row == (4 - theOrder.order_ProductType) && _isBranch == 1)
    {
        //        UIButton *button = (UIButton *)[[_tableView cellForRowAtIndexPath:indexPath] viewWithTag:100];
        //        [self selectCustomer:button];
        //跳转到顾客服务页
        CustomerDoc *doc = [[CustomerDoc alloc] init];
        [doc setCus_ID:theOrder.order_CustomerID];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        app.customer_Selected = doc ;//保存选中顾客
        
        [self moveToCusMainViewController];
    }
    
    if (ORDER_CONFIRM_FLAG && indexPath.section == ([_tableView numberOfSections] - 2) && indexPath.row == 0) {
        [self changeCommodityStatus:nil];
    }
    
    //备注编辑
    if (theOrder.order_Flag == 1 && indexPath.section == ([_tableView numberOfSections] - 1) && indexPath.row == 0 ) {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        if ( !bool_edit) {
            UIButton *button = (UIButton *)[cell viewWithTag:1003];
            [self changeRemark:button];
        } else if ( !bool_save) {
            UIButton *button = (UIButton *)[cell viewWithTag:1004];
            [self saveRemark:button];
        }
    }
    
}
- (void)removeDeliveryView
{
    [deliveryView removeFromSuperview];
    deliveryView = nil;
}
- (void)moveToCusMainViewController
{
    CusMainViewController  * navCon = [[CusMainViewController alloc] init];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID = theOrder.order_CustomerID;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name = theOrder.order_CustomerName;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 1;
    [self.navigationController pushViewController:navCon animated:YES];
}

#pragma mark init Button
-(void)initNavButton:(UIView *)view
{
    int with = 0;
#pragma mark 权限
    if ((theOrder.order_Status == 1 || theOrder.order_Status == 2) && [[PermissionDoc sharePermission] rule_Payment_Use]) {//已完成和进行中都可以结账theOrder.editStatus != OrderEditStatusNone
        if (theOrder.order_Ispaid == 1 || theOrder.order_Ispaid == 2) {
            UIButton *checkOutButton = [UIButton buttonTypeRoundedRectWithTitle:@"结账" target:self selector:@selector(changeOrderPayStatus:) frame:CGRectMake(0, 4, 50, 22)  titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
            int w = with;
            with = w + 55;
            [view addSubview:checkOutButton];
        }
    }
    
    if (theOrder.order_Status == 1 && theOrder.editStatus != OrderEditStatusNone) { //theOrder.productAndPriceDoc.productDoc.pro_PastCount
        
        if (theOrder.order_ServiceOn == 0 && ( theOrder.order_Ispaid == 1 ||theOrder.order_Ispaid == 5 ||theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney  == 0) && theOrder.productAndPriceDoc.productDoc.pro_PastCount == 0) {
            //【取消】和【终止】不同时出现；没有进行服务或支付的订单可以取消；一旦有过服务或支付过的订单只能终止；完结的订单无法取消、终止
            UIButton *cancelButton = [UIButton buttonTypeRoundedRectWithTitle:@"取消" target:self selector:@selector(changeOrderStatus:) frame:CGRectMake(with,4, 50, 22)  titleColor:[UIColor whiteColor] backgroudColor:KColor_Red cornerRadius:6.0f];
            [view addSubview:cancelButton];
            cancelButton.tag = 2002;
            int w = with;
            with = w + 55;
        }else if([[PermissionDoc sharePermission] rule_TerminateOrder] && (theOrder.order_ServiceOn == 1 || theOrder.productAndPriceDoc.productDoc.pro_PastCount != 0 || (theOrder.order_Ispaid !=1)))
        {
            UIButton *cancelButton = [UIButton buttonTypeRoundedRectWithTitle:@"终止" target:self selector:@selector(changeOrderStatus:) frame:CGRectMake(with, 4, 50, 22) titleColor:[UIColor whiteColor] backgroudColor:KColor_Red cornerRadius:6.0f];
            [view addSubview:cancelButton];
            cancelButton.tag = 2004;
            int w = with;
            with = w + 55;
        }
    }
    //【完成】按钮只适用于无限次数的服务；没有进行中的服务可以点击【完成】；未支付或有进行中的服务，【完成】按钮不显示
    if (theOrder.order_Status ==1 && unFinishiServeArr.count == 0 &&(long)theOrder.productAndPriceDoc.productDoc.pro_TotalCount== 0 && theOrder.editStatus != OrderEditStatusNone) {
        
        UIButton *endButton = [UIButton buttonTypeRoundedRectWithTitle:@"完成" target:self selector:@selector(finishOrder:) frame:CGRectMake(with, 4, 50, 22) titleColor:[UIColor whiteColor] backgroudColor:KColor_Blue cornerRadius:6.0f];
        [view addSubview:endButton];
        endButton.tag = 1003;
        int w = with;
        with = w + 55;
    }
    NSLog(@"[[PermissionDoc sharePermission] rule_Payment_Use] =%d",[[PermissionDoc sharePermission] rule_Payment_Use]);
    
    //有退款权限的可以退款//不是合并支付的可以退款//部分支付或已支付的可以退款
    if (theOrder.order_Status == 4 && (theOrder.order_Ispaid == 2 || theOrder.order_Ispaid == 3) && [[PermissionDoc sharePermission] rule_Payment_Use]) {
        UIButton *endButton = [UIButton buttonTypeRoundedRectWithTitle:@"退款" target:self selector:@selector(refundMoney) frame:CGRectMake(with, 4, 50, 22) titleColor:[UIColor whiteColor] backgroudColor:KColor_Red cornerRadius:6.0f];
        [view addSubview:endButton];
        endButton.tag = 1004;
        int w = with;
        with = w + 55;
    }
}

#pragma mark - addButtonAction
#pragma mark 增加课程按钮
- (void)addButtonAction:(UIButton *)sender
{
    if (sender.tag ==999) {
        surplusNUmber --;
        if (surplusNUmber < 0) {
            surplusNUmber = 0;
            if (surplusNUmber ==0) {
                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }else
        {
            [self UpdateServiceTGTotalCount:1];
        }
    }else if(sender.tag ==1000){
        surplusNUmber ++;
        [self  UpdateServiceTGTotalCount:0];
    }
}

-(void)checkOrderAndSubscribe:(UIButton *)sender
{
    if (sender.tag ==997) {//开单//跳转到开单页
        SubOrderViewController * sub = [[SubOrderViewController alloc] init];
        sub.orderList = [NSString stringWithFormat:@"%ld",(long)theOrder.order_ID];
        sub.customerName = theOrder.order_CustomerName;
        sub.customerID = theOrder.order_CustomerID;
        sub.backMode = SubOrderViewBackDetail ;
        [self.navigationController pushViewController:sub animated:YES];
        
    }else if(sender.tag == 998)//预约
    {
        [self appointmentTreatment:nil];
    }
}

-(void)completeGroup:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成该组服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (theOrder.IsConfirmed == 2) { //电子签
                __weak typeof(self) weakSelf = self;
                ComputerSginViewController *signVC  = [[ComputerSginViewController alloc]init];
                signVC.computerConfirmSignBlock = ^(NSString *imgString){
                    _signImgStr = imgString;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                    [weakSelf completeTreatmentGroup:[[[unFinishiServeArr objectAtIndex:sender.tag-201] objectForKey:@"GroupNo"] longLongValue] completion:NO];
                    
                };
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:signVC animated:YES completion:^{
                    
                }];
            }else{
                [self completeTreatmentGroup:[[[unFinishiServeArr objectAtIndex:sender.tag-201] objectForKey:@"GroupNo"] longLongValue] completion:NO];
            }
        }
    }];
}

-(void)deleteGroup:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除该组服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self deleteTreatmentGroup:[[[unFinishiServeArr objectAtIndex:sender.tag-301] objectForKey:@"GroupNo"] longLongValue] completion:NO];
        }
    }];
}

-(void)refundMoney
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否立即退款？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"立即退款", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            OrderRefund_ViewController * refund = [[OrderRefund_ViewController alloc] init];
            refund.orderID = orderID;
            refund.customerId = theOrder.order_CustomerID;
            refund.productType  =  theOrder.order_ProductType;
            [self.navigationController pushViewController:refund animated:YES];
        }
    }];
}

#pragma mark 完成按钮
- (void)completeButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)button.superview.superview;
    } else {
        cell = (UITableViewCell *)button.superview;
    }
    
    NSIndexPath *indexPath =[_tableView indexPathForCell:cell];
    if (indexPath == nil) {
        indexPath =INDEX(cell.tag);
    }
    CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:indexPath.section -3];
    if(operation_course.treatmentArray.count > 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成全部服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestCompleteTreatmentWithTreatment:[operation_course.treatmentArray objectAtIndex:0] andByCourse:operation_course.course_ID andByOrderID:theOrder.order_ID];
            }
        }];
    }else
        [SVProgressHUD showErrorWithStatus2:@"没有可以完成的疗程！" touchEventHandle:^{}];
    
}
#pragma mark 修改美丽顾问
- (void)changeResponsiblePerson:(id)sender
{
    // 美丽顾问
    if (ORDER_RPN_FLAG) {
        UserDoc *userDoc = [[UserDoc alloc] init];
        userDoc.user_Id   = theOrder.order_ResponsiblePersonID;
        userDoc.user_Name = theOrder.order_ResponsiblePersonName;
        
        SelectCustomersViewController *selectCustomersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        [selectCustomersVC setSelectModel:0 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
        [selectCustomersVC setDelegate:self];
        [selectCustomersVC setNavigationTitle:@"选择美丽顾问"];
        [selectCustomersVC setPersonType:CustomePersonGroup];
        [selectCustomersVC setPushOrpop:1];  // push
        [selectCustomersVC setOrderId:theOrder.order_ID];
        [selectCustomersVC setPrevView:9];
        [selectCustomersVC setCustomerId:theOrder.order_CustomerID];
        [selectCustomersVC setSalesId:theOrder.order_SalesID];
        [selectCustomersVC setOrderObjectID:theOrder.order_ObjectID];
        [selectCustomersVC setProductType:theOrder.order_ProductType];
        [self.navigationController pushViewController:selectCustomersVC animated:YES];
    }
}
#pragma mark 选择修改服务顾问
-(void)changeServePerson:(NSDictionary *)groupDic
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    UserDoc *userDoc = [[UserDoc alloc] init];
    NSString * type = [groupDic objectForKey:@"type"];
    if ([type isEqualToString:@"treatment"]) {
        selectCustomer.navigationTitle = @"选择服务人员";
        [userDoc setUser_Id:[[groupDic objectForKey:@"ExecutorID"] integerValue]];
        [userDoc setUser_Name:[groupDic objectForKey:@"ExecutorName"]];
    }else if([type isEqualToString:@"TG"])
    {
        selectCustomer.navigationTitle = @"选择服务顾问";
        [userDoc setUser_Id:[[groupDic objectForKey:@"ServicePicID"] integerValue]];
        [userDoc setUser_Name:[groupDic objectForKey:@"ServicePicName"]];
    }
    selectCustomer.groupDic = groupDic;
    selectCustomer.serveType = @"serve";
    selectCustomer.personType = 0;
    selectCustomer.delegate = self;
    selectCustomer.customerId = theOrder.order_CustomerID;
    [selectCustomer setSelectModel:0 userType: 3 customerRange:1 defaultSelectedUsers:@[userDoc]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark 跳转到课程详情页
-(void)gotoServiceViewDetail:(NSDictionary *)dic
{
    serveDetailDic = dic;
    TreatmentDetailViewController *treatmentDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TreatmentDetailViewController"];
    treatmentDetailViewController.treatMentOrGroup = 0;
    treatmentDetailViewController.OrderID = [[serveDetailDic objectForKey:@"OrderID"] integerValue];
    treatmentDetailViewController.GroupNo =[[serveDetailDic objectForKey:@"GroupNo"] doubleValue];
    
#pragma mark 权限
    treatmentDetailViewController.permission_Write = [self groupByPermission:dic];
    [self.navigationController pushViewController:treatmentDetailViewController animated:YES];
}

//跳转TG详情页

-(void)gotoTreatmentGroupDetail:(NSDictionary *)dic
{
    serveDetailDic = dic;
    
    UITabBarController *tabBarController = [[TreatmentGroupTabbarController alloc] init];
    
    TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
#pragma mark 权限
    BOOL permission_Write = [self groupByPermission:serveDetailDic];
    treatmentDetailViewController.permission_Write = permission_Write;
    
    treatmentDetailViewController.treatMentOrGroup = 0;
    treatmentDetailViewController.OrderID = [[serveDetailDic objectForKey:@"OrderID"] integerValue];
    treatmentDetailViewController.GroupNo =[[serveDetailDic objectForKey:@"GroupNo"] doubleValue];
    treatmentDetailViewController.customerId = theOrder.order_CustomerID;
    treatmentDetailViewController.isConfirmed = theOrder.IsConfirmed;
    
    //serviceEffectVC
    ZXServiceEffectViewController *serviceEffectVC = [tabBarController.viewControllers objectAtIndex:1];
    serviceEffectVC.OrderID = [[serveDetailDic objectForKey:@"OrderID"] integerValue];
    serviceEffectVC.GroupNo =[[serveDetailDic objectForKey:@"GroupNo"] doubleValue];
    serviceEffectVC.permission_Write = permission_Write;
    serviceEffectVC.customerID = theOrder.order_CustomerID;
    
    
    //review
    TreatmentGroupReview_ViewController *reviewVC = [tabBarController.viewControllers objectAtIndex:2];
    reviewVC.OrderID = [[serveDetailDic objectForKey:@"OrderID"] integerValue];
    reviewVC.GroupNo =[[serveDetailDic objectForKey:@"GroupNo"] doubleValue];
    reviewVC.permission_Write = permission_Write;
    tabBarController.selectedIndex = 0 ;
    [self.navigationController pushViewController:tabBarController animated:YES];
    
}

-(void)goToTabBarFromOrderDetailView:(NSDictionary *)dic
{
    serveDetailDic = dic;
    [self performSegueWithIdentifier:@"goOrderTabBarFromOrderDetailView" sender:self];
}
//服务详情 tabbar
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.view endEditing:YES];
    if ([segue.identifier isEqualToString:@"goOrderEditViewFromOrderDetailView"]) {
        
    } else if ([segue.identifier isEqualToString:@"goContactDetailViewFromOrderDetailView"]) {
        
    } else if ([segue.identifier isEqualToString:@"goOrderTabBarFromOrderDetailView"]) {
        
        BOOL permission_Write = [self groupByPermission:serveDetailDic];
        UITabBarController *tabBarController = segue.destinationViewController;
        
        
        TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
#pragma mark 权限
        treatmentDetailViewController.permission_Write = permission_Write;
        
        // effec
        EffectDisplayViewController *effectDosplayeController = [tabBarController.viewControllers objectAtIndex:1];
#pragma mark 权限
        effectDosplayeController.permission_Write = permission_Write;
        // reviewVC
        ReviewViewController *reviewVC = [tabBarController.viewControllers objectAtIndex:2];
#pragma mark 权限
        reviewVC.permission_Write = permission_Write;
        if([[serveDetailDic objectForKey:@"type"] isEqualToString:@"treatment"])
        {
            //treatment
            treatmentDetailViewController.TreatmentID =[[serveDetailDic objectForKey:@"TreatmentID"] integerValue];
            treatmentDetailViewController.treatMentOrGroup = 1;
            treatmentDetailViewController.treatMentOrGroup =  1;
            treatmentDetailViewController.customerId =  theOrder.order_CustomerID;
            
            // effec
            effectDosplayeController.treat_ID = [[serveDetailDic objectForKey:@"TreatmentID"] integerValue];
            effectDosplayeController.customerID = theOrder.order_CustomerID;
            effectDosplayeController.treatMentOrGroup = 1;
            effectDosplayeController.GroupNo = [[serveDetailDic objectForKey:@"GroupNo"] doubleValue];
            
            //review
            reviewVC.treatmentID = [[serveDetailDic objectForKey:@"TreatmentID"] integerValue];
            reviewVC.treatMentOrGroup = 1;
            
            
        }
    }
    
}

//选择服务顾问或者 小工的回调
- (void)dismissViewControllerWithServe:(NSInteger)userId groupDic:(NSDictionary *)groupDic
{
    NSString * type = [groupDic objectForKey:@"type"];
    if ([type isEqualToString:@"treatment"]) {//treatment
        NSInteger  TreatmentID = [[groupDic objectForKey:@"TreatmentID"] integerValue];
        [self UpdateTreatmentExecutorID:TreatmentID ExecutorID:userId];
    }else if([type isEqualToString:@"TG"])//group
    {
        double groupNO = [[groupDic objectForKey:@"GroupNo"] doubleValue];
        [self UpdateTGServicePIC:groupNO ServicePIC:userId];
    }
}
#pragma mark - SelectCustomersViewControllerDelegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = (UserDoc *)[userArray firstObject];
    if (userDoc == nil) {
        userDoc = [[UserDoc alloc] init];
        userDoc.user_Name = @"";
    }
    theOrder.order_ResponsiblePersonID   = userDoc.user_Id;
    theOrder.order_ResponsiblePersonName = userDoc.user_Name;
    
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)dismissViewController:(WorkSheetViewController *)workSheetVC userArray:(NSArray *)userArray dateStr:(NSString *)dateStr
{
    
}

//修改treatment操作人
-(void)UpdateTreatmentExecutorID:(NSInteger)TreatmentID ExecutorID:(NSInteger)ExecutorID
{
    
    NSDictionary * par =@{
                          @"OrderID":@((long)theOrder.order_ID),
                          @"TreatmentID":@((long)TreatmentID),
                          @"ExecutorID":@((long)ExecutorID)
                          };
    
    _requestUpdateOrderRemark = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTreatmentExecutorID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [SVProgressHUD dismiss];
                [self requestGetOrderDetailByJson];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

//修改TG服务顾问
-(void)UpdateTGServicePIC:(double)groupNo ServicePIC:(NSInteger)ServicePIC
{
    NSDictionary * par =@{
                          @"OrderID":@((long)theOrder.order_ID),
                          @"ServicePIC":@((long)ServicePIC),
                          @"GroupNo":@(groupNo)
                          };
    
    _requestUpdateOrderRemark = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTGServicePIC" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [SVProgressHUD dismiss];
                [self requestGetOrderDetailByJson];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 完成订单
- (void)finishOrder:(id)sender
{
    if (IOS8) {
        UIAlertController *alterContro = [UIAlertController alertControllerWithTitle:@"提醒" message:@"是否完成此订单？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self requestCompleteOrder:YES];
        }];
        
        [alterContro addAction:cancleAction];
        [alterContro addAction:otherAction];
        
        [self presentViewController:alterContro animated:YES completion:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成此订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestCompleteOrder:YES ];
            }
        }];
    }
    
}

//#pragma mark 修改订单状态
//- (void)changeOrderStatus:(UIButton *)sender
//{
////    // 取消订单
////    if ((theOrder.order_Flag == 1 && theOrder.order_Status == 0 && theOrder.order_Ispaid == 0) || (theOrder.order_Flag == 1 && theOrder.order_Status == 0 && theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney == 0)) {
//    if (sender.tag == 1002) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否取消此订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self requestDeleteOrder:theOrder.order_ID DeleteType:1];
//            }
//        }];
//    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否终止此订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self requestDeleteOrder:theOrder.order_ID DeleteType:2];
//            }
//        }];
//    }
//}
//

//交付商品
-(void)paycommodity:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"商品确认交付？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            double groupNo = [[[unFinishiServeArr objectAtIndex:(sender.tag-400)] objectForKey:@"GroupNo"] doubleValue];
            if (theOrder.IsConfirmed == 2) { //电子签
                __weak typeof(self) weakSelf = self;
                ComputerSginViewController *signVC  = [[ComputerSginViewController alloc]init];
                signVC.computerConfirmSignBlock = ^(NSString *imgString){
                    _signImgStr = imgString;
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                    [weakSelf  completeTreatmentGroup:groupNo completion:(BOOL)NO ];
                };
                signVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:signVC animated:YES completion:^{
                    
                }];
            }else{
                [self  completeTreatmentGroup:groupNo completion:(BOOL)NO ];
            }
            
        }
    }];
}

//撤销商品
-(void)productCancel:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"商品确认撤销？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            double  groupNo = [[[unFinishiServeArr objectAtIndex:(sender.tag - 200)] objectForKey:@"GroupNo"] doubleValue];
            
            [self deleteTreatmentGroup:groupNo completion:NO];
            
        }
    }];
}

-(void)changeOrderStatus:(UIButton *)sender
{
    //    if (unFinishiServeArr.count >0) {
    //        [SVProgressHUD showSuccessWithStatus2:@"还有未结的小单请先撤销!" touchEventHandle:^{}];
    //        return;
    //    }else{
    if (sender.tag == 2002) {//取消订单
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否取消此订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestDeleteOrderDeleteType:1];
            }
        }];
    }else if(sender.tag == 2004)//终止订单
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否终止此订单？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestDeleteOrderDeleteType:2];
            }
        }];
    }
    //    }
}
#pragma mark 修改订单支付状态
- (void)changeOrderPayStatus:(id)sender
{
    [self.view endEditing:YES];
    if (theOrder.order_Ispaid ==2) {//部分付
        PayInfoViewController *payInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
        payInfoController.orderNumbers = 1;
        payInfoController.makeStateComplete = 0;
        payInfoController.paymentOrderArray = [NSMutableArray arrayWithObjects:theOrder, nil];
        payInfoController.productType = theOrder.order_ProductType;
        payInfoController.customerId = theOrder.order_CustomerID;
        payInfoController.comeFrom = 1;
        [self.navigationController pushViewController:payInfoController animated:YES];
    }else
    {
        PayConfirmViewController *confirm = [[PayConfirmViewController alloc] init];
        confirm.orderNumbers = 1;
        confirm.makeStateComplete = 0;
        confirm.paymentOrderArray = [NSMutableArray arrayWithObjects:theOrder, nil];
        confirm.productType = theOrder.order_ProductType;
        confirm.customerId = theOrder.order_CustomerID;
        confirm.payStatus = theOrder.order_Ispaid;
        confirm.comeFrom = 1;
        [self.navigationController pushViewController:confirm animated:YES];
        if (ORDER_PAY_FLAG) {
            
        }
    }
}

#pragma mark 订单支付记录
- (void)goToThePayHistory
{
    [self.view endEditing:YES];
    OrderPaymentDetailViewController    *detailCon = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderPaymentDetailViewController"];
    detailCon.orderID = theOrder.order_ID;
    [self.navigationController pushViewController:detailCon animated:YES];
}

#pragma mark 修改商品状态
- (void)changeCommodityStatus:(id)sender
{
    if (ORDER_CONFIRM_FLAG) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"商品确认交付？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestCompleteOrder:YES];
            }
        }];
    }
}

#pragma mark - OrderDateCellDelete
#pragma mark 处理课程服务
- (void)chickOperateRowButton:(UITableViewCell *)cell
{
    //    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    //    if (indexPath == nil) {
    //        indexPath =INDEX(cell.tag);
    //    }
    //    CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:indexPath.section - 3];
    //    TreatmentDoc *treatmentDoc = [operation_course.treatmentArray objectAtIndex:indexPath.row - 1];
    //
    
    //    if (treatmentDoc.treat_Schedule.sch_ScheduleTime == nil || [treatmentDoc.treat_Schedule.sch_ScheduleTime isEqualToString:@""]) {//未预约的课程
    //        [self nonoTreatment:indexPath Treat:treatmentDoc];
    //    } else {// 预约但未完成的课程
    //        [self appointmentTreatment:indexPath Treat:treatmentDoc];
    //    }
}

#pragma mark 未预约的treatment点击事件处理
-(void)groupServe:(NSDictionary * )groupDic
{
    int state = [[groupDic objectForKey:@"Status"] intValue];
    
    if (!state) {
        [self gotoTreatmentGroupDetail:groupDic];
        
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择顾问", @"详情", nil];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0){
                [self changeServePerson:groupDic];
            } else if (buttonIndex == 1) {
                [self gotoTreatmentGroupDetail:groupDic];
            }
        }];
    }
}

- (void)nonoTreatment:(NSDictionary *)treatMentDic
{
    int state = [[treatMentDic objectForKey:@"Status"] intValue];
    if (!state) {
        [self goToTabBarFromOrderDetailView:treatMentDic];
    }else{
        NSInteger isDesigna = [[treatMentDic objectForKey:@"IsDesignated"] integerValue];
        
        if ([[treatMentDic objectForKey:@"TreatmentCount"] integerValue] >1) {
            UIActionSheet *  actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成",isDesigna ==1?@"取消指定": @"指定",@"选择服务人员", @"详情", @"删除", nil];
            [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self finishServe:[[treatMentDic objectForKey:@"TreatmentID"] integerValue]];
                }else if (buttonIndex == 1)
                {
                    [self DesignatedForgroupNo:[[treatMentDic objectForKey:@"GroupNo"] doubleValue] treatmentID:[[treatMentDic objectForKey:@"TreatmentID"] integerValue] IsDesignated:!isDesigna];
                }
                else if (buttonIndex == 2){
                    [self changeServePerson:treatMentDic];
                } else if (buttonIndex == 3) {
                    [self goToTabBarFromOrderDetailView:treatMentDic];
                }else if(buttonIndex == 4)
                {
                    [self deleteServe:[[treatMentDic objectForKey:@"TreatmentID"] integerValue] groupNo:[[treatMentDic objectForKey:@"GroupNo"] doubleValue]];
                }
            }];
            
        }else
        {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成",isDesigna ==1?@"取消指定": @"指定",@"选择服务人员", @"详情", nil];
            [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self finishServe:[[treatMentDic objectForKey:@"TreatmentID"] integerValue]];
                }else if(buttonIndex ==1)
                {
                    [self DesignatedForgroupNo:[[treatMentDic objectForKey:@"GroupNo"] doubleValue] treatmentID:[[treatMentDic objectForKey:@"TreatmentID"] integerValue] IsDesignated:!isDesigna];
                }
                else if (buttonIndex == 2){
                    [self changeServePerson:treatMentDic];
                } else if (buttonIndex == 3) {
                    [self goToTabBarFromOrderDetailView:treatMentDic];
                }
            }];
            
        }
        
    }
}

#pragma mark treatment预约处理
#pragma mark 单个Treatment预约
- (void)appointmentTreatment:(TreatmentDoc *)treatmentDoc
{
    AppointmenCreat_ViewController * creat = [[AppointmenCreat_ViewController alloc] init];
    creat.viewTag = 2;
    creat.orderObjectID = theOrder.order_ObjectID;
    creat.orderID = theOrder.order_ID;
    creat.serveName = theOrder.productAndPriceDoc.productDoc.pro_Name;
    creat.cusName = theOrder.order_CustomerName;
    creat.cusID = theOrder.order_CustomerID;
    [self.navigationController pushViewController:creat animated:YES];
    
}

#pragma mark treatment点击事件处理
#pragma mark 完成处理
//删除单次服务
-(void)deleteServe:(NSInteger)treatmentID  groupNo:(double)groupNO
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self deleteCompleteTreatment:treatmentID groupNo:groupNO completion:NO];
        }
    }];
}
//完成单次服务
-(void)finishServe:(NSInteger)treatmentID
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self completeTreatment:treatmentID completion:NO];
        }
    }];
}
//- (void)completionTreatment:(TreatmentDoc *)treatment
//{
//    if (self.unCompleteTreats == 1) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self completeTreatmentGroup:treatment.treatGroup completion:YES];
//            } else {
//                [self completeTreatmentGroup:treatment.treatGroup completion:NO];
//            }
//        }];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self completeTreatmentGroup:treatment.treatGroup completion:NO];
//            }
//        }];
//    }
//}

//
//- (void)completionBeforeTreatment:(TreatmentDoc *)treatmentDoc
//{
//    if (self.unCompleteTreats == 1) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self haveCompletionGroup:treatmentDoc.treatGroup completion:YES];
//            }
//            if (buttonIndex == 0) {
//                [self haveCompletionGroup:treatmentDoc.treatGroup completion:NO];
//            }
//        }];
//
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self haveCompletionGroup:treatmentDoc.treatGroup completion:NO];
//            }
//        }];
//
//    }
//}
#pragma mark treatment删除预约后
#pragma mark Treatment删除
//- (void)deleteTreatment:(TreatmentDoc *)treatmentDoc
//{
//    if ( self.unCompleteTreats == 1 && self.treatsCount > 1)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self deleteTreatmentGroup:treatmentDoc.treatGroup completion:YES];
//            }
//            if (buttonIndex == 0) {
//                [self deleteTreatmentGroup:treatmentDoc.treatGroup completion:NO];
//            }
//        }];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self deleteTreatmentGroup:treatmentDoc.treatGroup completion:NO];
//            }
//        }];
//    }
//}

#pragma mark group点击事件处理
- (void)dosomethingwithGroup:(TreatmentGroup *)group IndexPath:(NSIndexPath *)groupIndex
{
    //    if (group.STATUS == GROUPSTATUSCOMLETE) {
    //
    //        UIActionSheet *groupAction = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成本次", nil];
    //        [groupAction showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
    //            if (buttonIndex == 0) {
    //                [self completionGroup:group];
    //            }
    //        }];
    //    }
    //    if (group.STATUS == GROUPSTATUSDELETE){
    //            UIActionSheet *groupAction = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除本次", theOrder.productAndPriceDoc.productDoc.isCount ? @"过去完成": nil, nil];
    //            [groupAction showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
    //                if (buttonIndex == 0) {
    //                    [self deleteGroup:group];
    //                }
    //                if (buttonIndex == 1 && theOrder.productAndPriceDoc.productDoc.isCount) {
    //                    [self completeBefore:group];
    //                    NSLog(@"the click title is %@,is %s:%d",[groupAction buttonTitleAtIndex:buttonIndex], __PRETTY_FUNCTION__, __LINE__);
    //                }
    //
    //            }];
    //        }
    //    if (group.STATUS == GROUPSTATUSALL) {
    //        UIActionSheet *groupAction = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成本次",@"删除本次", theOrder.productAndPriceDoc.productDoc.isCount ? @"过去完成": nil,nil];
    //        [groupAction showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
    //            if (buttonIndex == 0) {
    //                [self completionGroup:group];
    //            }
    //            if (buttonIndex == 1) {
    //                [self deleteGroup:group];
    //            }
    //            if (buttonIndex == 2 && theOrder.productAndPriceDoc.productDoc.isCount) {
    //                [self completeBefore:group];
    //                NSLog(@"the click title is %@,is %s:%d",[groupAction buttonTitleAtIndex:buttonIndex], __PRETTY_FUNCTION__, __LINE__);
    //            }
    //        }];
    //    }
}

//- (void)completionGroup:(TreatmentGroup *)treGroup
//{
//    if ([self groupCompletionTreatmentGroup:treGroup] == 0)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self completeTreatmentGroup:treGroup.groupList completion:YES];
//            }
//            if (buttonIndex == 0) {
//                [self completeTreatmentGroup:treGroup.groupList completion:NO];
//            }
//        }];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否完成该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self completeTreatmentGroup:treGroup.groupList completion:NO];
//            }
//        }];
//    }
//}
//
//- (void)completeBefore:(TreatmentGroup *)treatGroup
//{
//    if ([self groupCompletionTreatmentGroup:treatGroup] == 0 )
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self haveCompletionGroup:treatGroup.groupList completion:YES];
//            }
//            if (buttonIndex == 0) {
//                [self haveCompletionGroup:treatGroup.groupList completion:NO];
//            }
//        }];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self haveCompletionGroup:treatGroup.groupList completion:NO];
//            }
//        }];
//    }
//
//}

//- (void)deleteGroup:(TreatmentGroup *)treatGroup
//{
//    if ([self groupCompletionTreatmentGroup:treatGroup] == 0 && self.groupArray.count > 1)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否更新订单完成状态？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self deleteTreatmentGroup:treatGroup.groupList completion:YES];
//            }
//            if (buttonIndex == 0) {
//                [self deleteTreatmentGroup:treatGroup.groupList completion:NO];
//            }
//        }];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除该次服务？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self deleteTreatmentGroup:treatGroup.groupList completion:NO];
//            }
//        }];
//    }
//}

- (int)groupCompletionTreatmentGroup:(TreatmentGroup *)treatGroup
{
    int ungroup = 0;
    for (TreatmentGroup *group in groupArray) {
        if (treatGroup.groupID != group.groupID && group.COMPLETE != GROUPTREATCOMPLETEALL) {
            ungroup ++;
        }
    }
    return ungroup;
}

#pragma mark - ConfigCell

// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell1%ld%ld",(long)indexPath.row,(long)indexPath.section];
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    
    UILabel *lable = (UILabel *)[cell viewWithTag:2201];
    [lable removeFromSuperview];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2001];
    [imageView removeFromSuperview];
    
    UIImageView *imageView6= (UIImageView *)[cell viewWithTag:2002];
    [imageView6 removeFromSuperview];
    
    UIImageView *imageView1= (UIImageView *)[cell viewWithTag:3001];
    [imageView1 removeFromSuperview];
    
    UIImageView *imageView3= (UIImageView *)[cell viewWithTag:3003];
    [imageView3 removeFromSuperview];
    
    UIImageView *imageView4= (UIImageView *)[cell viewWithTag:3004];
    [imageView4 removeFromSuperview];
    UIImageView *imageView5= (UIImageView *)[cell viewWithTag:1181];
    [imageView5 removeFromSuperview];
    
    
    
    //
    //    UIButton *button1= (UIButton *)[cell viewWithTag:999];
    //    [button1 removeFromSuperview];
    //    UIButton *button2= (UIButton *)[cell viewWithTag:1000];
    //    [button2 removeFromSuperview];
    
    UIButton *button = (UIButton *)[cell viewWithTag:1005];
    [button removeFromSuperview];
    
    UIImageView * moreImageView = (UIImageView *)[cell viewWithTag:indexPath.section + indexPath.row];
    [moreImageView removeFromSuperview];
    
    UIButton * bu = (UIButton *)[cell viewWithTag:1001];
    [bu removeFromSuperview];
    
    UIButton *button1= (UIButton *)[cell viewWithTag:(400+indexPath.row-1)];
    [button1 removeFromSuperview];
    
    UIButton *button2= (UIButton *)[cell viewWithTag:(200+indexPath.row-1)];
    [button2 removeFromSuperview];
    
    UIButton *button4= (UIButton *)[cell viewWithTag:(200+indexPath.row)];
    [button4 removeFromSuperview];
    
    UIButton *button3= (UIButton *)[cell viewWithTag:(300+indexPath.row)];
    [button3 removeFromSuperview];
    
    return cell;
}

// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell2:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell2%ld%ld",(long)indexPath.section,(long)indexPath.row];
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    
    UIImageView *imageView1= (UIImageView *)[cell viewWithTag:3002];
    [imageView1 removeFromSuperview];
    
    UIImageView *imageView2= (UIImageView *)[cell viewWithTag:2118];
    [imageView2 removeFromSuperview];
    
    UILabel *lable = (UILabel *)[cell viewWithTag:2119];
    [lable removeFromSuperview];
    
    return cell;
}
// 配置NormalEditCell3
- (NormalEditCell *)configNormalEditCell3:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell_three%ld",(long)indexPath.row+indexPath.section];
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    
    UIButton *edButton = (UIButton *)[cell viewWithTag:1003];
    if (!edButton ) {
        UIButton *editButton = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(changeRemark:)
                                                   frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                           backgroundImg:[UIImage imageNamed:@"bianji"]
                                        highlightedImage:nil];
        editButton.tag = 1003;
        [cell.contentView addSubview:editButton];
    }
    UIButton *saButton = (UIButton *)[cell viewWithTag:1004];
    if (!saButton) {
        UIButton *saveButton = [UIButton buttonWithTitle:@""
                                                  target:self
                                                selector:@selector(saveRemark:)
                                                   frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                           backgroundImg:[UIImage imageNamed:@"baocun"]
                                        highlightedImage:nil];
        saveButton.tag = 1004;
        [cell.contentView addSubview:saveButton];
    }
    
    
    
    return cell;
}

- (NormalEditCell *)configNormalEditCell4:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell_for%ld",(long)indexPath.row+indexPath.section];
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    //
    return cell;
}
// 配置OrderTreatmentCell
- (OrderTreatmentCell *)configOrderTreatmentCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderTreatmentCell_one";
    OrderTreatmentCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderTreatmentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    //    cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    cell.delegate = self;
    if (![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

// 配置OrderContactCell
- (OrderContactCell *)configOrderContactCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderContactCell_two";
    OrderContactCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row ];
    
    if (![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - 网络请求接口
#pragma mark 交付商品结商品单

#pragma mark 更新有效期
-(void)updateExpirationTime
{
    [SVProgressHUD showWithStatus:@"Updating"];
    NSDictionary * par = @{
                           @"OrderObjectID":@((long)theOrder.order_ObjectID),
                           @"ExpirationTime":theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime
                           };
    _requestUpdateExpirationTime = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateExpirationTime" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                
                [SVProgressHUD dismiss];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 更新订单备注
- (void)updateOrderRemark
{
    [SVProgressHUD showWithStatus:@"Updating"];
    NSDictionary * par =@{
                          @"OrderObjectID":@((long)theOrder.order_ObjectID),
                          @"ProductType":@(self.productType),
                          @"Remark":theOrder.order_Remark,
                          @"OrderID":@((long)theOrder.order_ID)
                          };
    
    _requestUpdateOrderRemark = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateOrderRemark" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer  touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error duration:kSvhudtimer touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
}

//修改指定
-(void)DesignatedForgroupNo:(double)groupNo treatmentID:(NSInteger)treatID IsDesignated:(NSInteger)IsDesignated
{
    [SVProgressHUD showWithStatus:@"Updating"];
    NSDictionary * par =@{
                          @"TreatmentID":@((long)treatID),
                          @"OrderObjectID":@((long)theOrder.order_ObjectID),
                          @"GroupNo":@(groupNo),
                          @"IsDesignated":@((long)IsDesignated)
                          };
    
    _requestUpdateOrderRemark = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTMDesignated" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            //            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
            //                [SVProgressHUD dismiss];
            [self requestGetOrderDetailByJson];
            //            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}


#pragma mark 请求订单信息
- (void)finishiOrderList
{
    NSString *par = [NSString stringWithFormat:@"{\"OrderObjectID\":%ld,\"ProductType\":%ld,\"Status\":%d}", (long)self.objectID, (long)productType,-1];
    
    _requestGetOrderDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetTreatGroupByOrderObjectID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(data == nil)
                return ;
            
            [finishiServeArr removeAllObjects];
            NSArray * dataArr = data;
            int number = 1;
            
            for (int i=0;i<dataArr.count;i++) {
                if(self.productType ==0){
                    NSDictionary *groupListDic = [dataArr objectAtIndex:i];
                    [finishiServeArr addObject:@{@"type":@"number",@"number":[NSString stringWithFormat:@"%d",number],@"GroupNo":[groupListDic objectForKey:@"GroupNo"],@"StartTime":[groupListDic objectForKey:@"StartTime"] ,@"Status":[groupListDic objectForKey:@"Status"]}];
                    //服务顾问
                    [finishiServeArr addObject:@{@"type":@"TG",
                                                 @"OrderID":@((long)theOrder.order_ID),
                                                 @"ServicePicName":[groupListDic objectForKey:@"ServicePicName"],
                                                 @"Status":[groupListDic objectForKey:@"Status"],
                                                 @"GroupNo":[groupListDic objectForKey:@"GroupNo"],
                                                 @"IsDesignated":[groupListDic objectForKey:@"IsDesignated"]
                                                 }];//服务顾问
                    if ([groupListDic objectForKey:@"TreatmentList"] !=[NSNull null]) {
                        for (NSDictionary * subServeDic in [groupListDic objectForKey:@"TreatmentList"]) {
                            
                            [finishiServeArr addObject:@{@"type":@"treatment",
                                                         @"SubServiceName":[subServeDic objectForKey:@"SubServiceName"],
                                                         @"ExecutorName":[subServeDic objectForKey:@"ExecutorName"],
                                                         @"Status":[subServeDic objectForKey:@"Status"],
                                                         @"TreatmentID":[subServeDic objectForKey:@"TreatmentID"],
                                                         @"GroupNo":[groupListDic objectForKey:@"GroupNo"],
                                                         @"ExecutorID":[subServeDic objectForKey:@"ExecutorID"],
                                                         @"IsDesignated":[subServeDic objectForKey:@"IsDesignated"]
                                                         }];//小工
                        }
                    }
                    
                }else
                {
                    [finishiServeArr addObject:@{@"number":[NSString stringWithFormat:@"%d",number],@"Quantity":[[dataArr objectAtIndex:i] objectForKey:@"Quantity"],@"Status":[[dataArr objectAtIndex:i] objectForKey:@"Status"],@"StartTime":[[dataArr objectAtIndex:i] objectForKey:@"StartTime"],@"GroupNo":[[dataArr objectAtIndex:i] objectForKey:@"GroupNo"],@"ThumbnailURL":[[dataArr objectAtIndex:i] objectForKey:@"ThumbnailURL"]}];
                    [finishiServeArr addObject:@{@"ServicePicName":[[dataArr objectAtIndex:i] objectForKey:@"ServicePicName"]}];
                    //                        [finishiServeArr addObject:@{@"ThumbnailURL":[[dataArr objectAtIndex:i] objectForKey:@"ThumbnailURL"]}];
                    
                }
                number ++ ;
            }
            
            if (finishiServeArr.count > 0) {
                theOrder.order_ServiceOn = 1 ;
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD dismiss];
        }];
        
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];
}

#pragma mark 请求订单信息
- (void)requestGetOrderDetailByJson
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"OrderObjectID\":%ld,\"ProductType\":%ld}", (long)self.objectID, (long)productType];
    
    _requestGetOrderDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(data == nil)
                return ;
            
            theOrder = [[OrderDoc alloc] init];
            balance = [[data objectForKey:@"Balance"] doubleValue];
            [theOrder setOrder_ID:orderID ];
            [theOrder setOrder_ObjectID:[[data objectForKey:@"OrderObjectID"] integerValue]];
            [theOrder setOrder_Status:[[data objectForKey:@"Status"] intValue]];
            [theOrder setOrder_Ispaid:[[data objectForKey:@"PaymentStatus"] intValue]];
            [theOrder setOrder_UnPaidPrice:[[data objectForKey:@"UnPaidPrice"] doubleValue]];
            
            [theOrder setOrder_Number:[data objectForKey:@"OrderNumber"]];
            [theOrder setOrder_Branch:[data objectForKey:@"BranchName"]];
            [theOrder setOrder_Remark:[data objectForKey:@"Remark"]];
            [theOrder setOrder_OrderTime:[data objectForKey:@"OrderTime"]];
            [theOrder setOrder_AccountName:[data objectForKey:@"ResponsiblePersonName"]];
            [theOrder setOrder_AppointMustPaid: [[data objectForKey:@"AppointmentMustPaid"] boolValue]];
            
            [theOrder setIsConfirmed:[[data objectForKey:@"IsConfirmed"] integerValue]];
            
            self.isMergePay = [[data objectForKey:@"IsMergePay"] boolValue];
            
            
            [theOrder.order_SalesList removeAllObjects];
            NSArray *tempArr = [data objectForKey:@"SalesList"];
            if (![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                for (NSDictionary * dic  in  [data objectForKey:@"SalesList"]) {
                    UserDoc * user  = [[UserDoc alloc] init];
                    user.user_Id = [[dic objectForKey:@"SalesPersonID"] integerValue];
                    user.user_Name = [dic objectForKey:@"SalesName"];
                    [theOrder.order_SalesList addObject:user];
                }
            }
            
            [theOrder setOrder_SalesID:[[data objectForKey:@"SalesPersonID"] integerValue]]; //修改
            [theOrder setOrder_ProductType:[[data objectForKey:@"ProductType"] integerValue]];
            [theOrder setOrder_CourseFrequency:[[data objectForKey:@"CourseFrequency"] integerValue]];
            [theOrder setOrder_BranchId:[[data objectForKey:@"BranchID"] integerValue]];
            
            /** 是否有优惠券*/
            
            if([data objectForKey:@"BenefitList"] != [NSNull null]){
                for (NSDictionary  *benefit in [data objectForKey:@"BenefitList"] ) {
                    WelfareRes *welfare = [[WelfareRes alloc] init];
                    welfare.PolicyName = [benefit objectForKey:@"PolicyName"];
                    welfare.PRValue2 = [benefit objectForKey:@"PRValue2"];
                    [theOrder.BenefitListArr addObject:welfare];
                }
            }
            
            /** 是否有第三方支付*/
            self.HasNetTrade  = [[data objectForKey:@"HasNetTrade"] boolValue];
            
            if (!payment_Info)
                payment_Info = [[NSMutableArray alloc] init];
            else if([payment_Info count] > 0)
                [payment_Info removeAllObjects];
            if([data objectForKey:@"PaymentList"] != [NSNull null]){
                for (NSDictionary  *pay in [data objectForKey:@"PaymentList"] ) {
                    PayInfoDoc *payInfo = [[PayInfoDoc alloc] init];
                    
                    payInfo.pay_Mode = [[pay objectForKey:@"PaymentMode"] integerValue];
                    payInfo.pay_Amount = [[pay objectForKey:@"PaymentAmount"] doubleValue];
                    [payment_Info addObject:payInfo];
                }
            }
            
            if(!theOrder.productAndPriceDoc || theOrder.productAndPriceDoc.productArray.count <= 0)
                theOrder.productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
            [theOrder.productAndPriceDoc setTotalMoney:[[data objectForKey:@"TotalOrigPrice"] doubleValue]];
            [theOrder.productAndPriceDoc setDiscountMoney:[[data objectForKey:@"TotalSalePrice"] doubleValue]];
            
            
            [theOrder setOrder_CustomerID:[[data objectForKey:@"CustomerID"] integerValue]];
            [theOrder setOrder_CustomerName:[data objectForKey:@"CustomerName"]];
            [theOrder setOrder_Flag:[[data objectForKey:@"Flag"] boolValue]];
            [theOrder setOrder_ResponsiblePersonID:[[data objectForKey:@"ResponsiblePersonID"] integerValue]];
            [theOrder setOrder_ResponsiblePersonName:[data objectForKey:@"ResponsiblePersonName"]];
            [theOrder setOrder_CreatorID:[[data objectForKey:@"CreatorID"] integerValue]];
            [theOrder setOrder_CreatorName:[data objectForKey:@"CreatorName"]];
            [theOrder setOrder_PayRemark:[data objectForKey:@"PaymentRemark"]];
            
            theOrder.productAndPriceDoc.productDoc.pro_Name     = [data objectForKey:@"ProductName"];
            theOrder.productAndPriceDoc.productDoc.pro_Type     = [[data objectForKey:@"ProductType"] integerValue];
            theOrder.productAndPriceDoc.productDoc.pro_quantity = [[data objectForKey:@"Quantity"] integerValue];
            theOrder.productAndPriceDoc.productDoc.pro_TotalMoney     = [[data objectForKey:@"TotalOrigPrice"] doubleValue];
            theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[data objectForKey:@"TotalSalePrice"] doubleValue];
            theOrder.productAndPriceDoc.productDoc.pro_TotalCalcPrice = [[data objectForKey:@"TotalCalcPrice"] doubleValue];
            theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime = [data objectForKey:@"ExpirationTime"];
            theOrder.productAndPriceDoc.productDoc.pro_SubServicesCode = [data objectForKey:@"SubServiceIDs"];
            //退款总额
            
            theOrder.productAndPriceDoc.productDoc.pro_refundPrice = [[data objectForKey:@"RefundSumAmount"] doubleValue];
            
            theOrder.productAndPriceDoc.productDoc.pro_TotalCount = [[data objectForKey:@"TotalCount"]integerValue];
            theOrder.productAndPriceDoc.productDoc.pro_SurplusCount = [[data objectForKey:@"SurplusCount"] integerValue];
            surplusNUmber = theOrder.productAndPriceDoc.productDoc.pro_SurplusCount;
            theOrder.productAndPriceDoc.productDoc.pro_Unitprice = [[data objectForKey:@"UnPaidPrice"] integerValue];
            theOrder.productAndPriceDoc.productDoc.pro_PastCount = [[data objectForKey:@"PastCount"] integerValue];
            theOrder.productAndPriceDoc.productDoc.pro_FinishedCount = [[data objectForKey:@"FinishedCount"] integerValue];//已经完成数量
            theOrder.productAndPriceDoc.productDoc.pro_quantity = [[data objectForKey:@"Quantity"] integerValue];
            //追加未支付价格
            theOrder.productAndPriceDoc.productDoc.pro_UnPaidPrice = theOrder.order_UnPaidPrice;
            theOrder.productAndPriceDoc.productDoc.pro_Status = theOrder.order_Ispaid;
            
            //统计默认为yes
            if ([data objectForKey:@"IsPast"] == nil ) {
                theOrder.productAndPriceDoc.productDoc.isCount = NO;
            } else {
                theOrder.productAndPriceDoc.productDoc.isCount = [[data objectForKey:@"IsPast"] boolValue];
            }
            
            //是否显示优惠价。
            if (ORDER_ISCHANGEPRICE) {
                theOrder.productAndPriceDoc.productDoc.pro_IsShowDiscountMoney = YES;
            } else {
                [theOrder.productAndPriceDoc initIsShowDiscountMoney];
            }
            
            theOrder.productAndPriceDoc.productArray = [NSMutableArray arrayWithObject: theOrder.productAndPriceDoc.productDoc];
            _courseStatus = 1;
            
            // --Course
            //已完成未完成订单分离
            [unFinishiServeArr removeAllObjects];
            int number = 1;
            if (self.productType ==0) {
                for (NSDictionary *groupListDic in [data objectForKey:@"GroupList"]) {
                    [unFinishiServeArr addObject:@{@"type":@"number",@"number":[NSString stringWithFormat:@"%d",number],@"GroupNo":[groupListDic objectForKey:@"GroupNo"] ,@"StartTime":[groupListDic objectForKey:@"StartTime"],                                                       @"ServicePicID":[groupListDic objectForKey:@"ServicePicID"]}];//number
                    [unFinishiServeArr addObject:@{@"type":@"TG",
                                                   @"OrderID":@((long)theOrder.order_ID),
                                                   @"ServicePicName":[groupListDic objectForKey:@"ServicePicName"],
                                                   @"ServicePicID":[groupListDic objectForKey:@"ServicePicID"],
                                                   @"Status":[groupListDic objectForKey:@"Status"],
                                                   @"GroupNo":[groupListDic objectForKey:@"GroupNo"],
                                                   @"IsDesignated":[groupListDic objectForKey:@"IsDesignated"]
                                                   }];//服务顾问
                    
                    if ([groupListDic objectForKey:@"TreatmentList"] !=[NSNull null]) {
                        int count = 0;
                        for (NSDictionary * subServeDic in [groupListDic objectForKey:@"TreatmentList"]) {
                            if ([[subServeDic objectForKey:@"Status"] integerValue] ==1) {
                                count ++ ;
                            }
                        }
                        
                        for (NSDictionary * subServeDic in [groupListDic objectForKey:@"TreatmentList"]) {
                            
                            [unFinishiServeArr addObject:@{@"type":@"treatment",
                                                           @"SubServiceName":[subServeDic objectForKey:@"SubServiceName"],
                                                           @"ExecutorName":[subServeDic objectForKey:@"ExecutorName"],
                                                           @"Status":[subServeDic objectForKey:@"Status"],
                                                           @"TreatmentID":[subServeDic objectForKey:@"TreatmentID"],
                                                           @"GroupNo":[groupListDic objectForKey:@"GroupNo"],
                                                           @"ServicePicID":[groupListDic objectForKey:@"ServicePicID"],
                                                           @"ExecutorID":[subServeDic objectForKey:@"ExecutorID"],
                                                           @"TreatmentCount":@(count),
                                                           @"IsDesignated":[subServeDic objectForKey:@"IsDesignated"]
                                                           }];//小工
                            
                        }
                        
                    }
                    number ++ ;
                }
            }else
            {
                for (NSDictionary *groupListDic in [data objectForKey:@"GroupList"]) {
                    
                    [unFinishiServeArr addObject:@{@"StartTime":[groupListDic objectForKey:@"StartTime"],@"Quantity":[groupListDic objectForKey:@"Quantity"],@"type":@"one",@"GroupNo":[groupListDic objectForKey:@"GroupNo"]}];
                    
                    [unFinishiServeArr addObject:@{@"StartTime":[groupListDic objectForKey:@"StartTime"],@"Quantity":[groupListDic objectForKey:@"Quantity"],@"type":@"two",@"GroupNo":[groupListDic objectForKey:@"GroupNo"]}];
                }
            }
            // --Contact
            NSMutableArray *tmpContactArray = [NSMutableArray array];
            for (NSDictionary *contact in [data objectForKey:@"Contact"]) {
                ContactDoc *tmpContact = [[ContactDoc alloc] init];
                [tmpContact setCont_ID:[[contact objectForKey:@"ContactID"] integerValue]];
                [tmpContact setCont_Remark:[contact objectForKey:@"ContactID"]];
                
                ScheduleDoc *sch = [[ScheduleDoc alloc] init];
                [sch setSch_ID:[[contact objectForKey:@"ScheduleID"] integerValue]];
                [sch setSch_ScheduleTime:[contact objectForKey:@"Time"]];
                [sch setSch_Completed:[[contact objectForKey:@"IsCompleted"] integerValue]];
                [tmpContact setCont_Schedule:sch];
                [tmpContactArray addObject:tmpContact];
            }
            
            bool_edit = !theOrder.order_Flag;
            bool_save = YES;
            [theOrder setContractArray:tmpContactArray];
            
            scdlListArr = [data objectForKey:@"ScdlList"]; //预约list
            
            [self finishiOrderList];
            
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];
    
}
////增加group 开小单
//- (void)addTreatmentGroup:(CourseDoc *)course
//{
//    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"OrderID\":%ld,\"CourseID\":%ld,\"CustomerID\":%ld,\"CreatorID\":%ld,\"IsDesignated\":%d,\"SubServiceIDs\":\"%@\"}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)theOrder.order_ID, (long)course.course_ID, (long)theOrder.order_CustomerID, (long)theOrder.order_CreatorID, 0, theOrder.productAndPriceDoc.productDoc.pro_SubServicesCode];
//
//
//    _requestAddTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/AddTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
//        [self parserJsonData:json andComplete:NO];
//    } failure:^(NSError *error) {
//
//    }];
//}

-(void)UpdateServiceTGTotalCount:(int)type
{
    NSDictionary * par =@{
                          @"OrderID":@((long)theOrder.order_ID),
                          @"OrderObjectID":@((long)theOrder.order_ObjectID),
                          @"Type":@(type)
                          };
    _requestAddTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateServiceTGTotalCount" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [self parserJsonData:json andComplete:NO];
    } failure:^(NSError *error) {
        
    }];
}

// order删除
#pragma mark 删除订单
- (void)requestDeleteOrderDeleteType:(int)type
{
    NSString * string = @"取消";
    if (type ==2) {
        string = @"终止";
    }
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary * par = @{
                           @"OrderID":@((long)theOrder.order_ID),
                           @"OrderObjectID":@((long)theOrder.order_ObjectID),
                           @"ProductType":@(theOrder.order_ProductType),
                           @"DeleteType":@(type)
                           };
    
    _requestDeleteOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/DeleteOrder" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
                [self requestGetOrderDetailByJson];
                
                //有退款权限的可以退款//不是合并支付的可以退款//部分支付或已支付的可以退款
                if (type ==2 && (theOrder.order_Ispaid==2 || theOrder.order_Ispaid ==3) && [[PermissionDoc sharePermission] rule_Payment_Use]) {
                    
                    [self refundMoney];
                }
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            if (code == -1) {
                [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                    [SVProgressHUD dismiss];
                    [self requestGetOrderDetailByJson];
                }];
            } else if (code == 0) { //sdf
                [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                    
                    [SVProgressHUD dismiss];
                    [self requestGetOrderDetailByJson];
                }];
            } else {
                [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                    
                    [SVProgressHUD dismiss];
                    [self requestGetOrderDetailByJson];
                }];
            }
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

// completeTreatment
- (void)requestCompleteTreatmentWithTreatment:(TreatmentDoc *)treatmentDoc andIndexPath:(NSIndexPath *)index andButtonIndex:(NSInteger)buttonIndex
{
    _requestCompleteTreaatmentOperation = [[GPHTTPClient shareClient] requestCompleteTreatmentWithScheduleID:treatmentDoc.treat_Schedule.sch_ID andCustomerID:theOrder.order_CustomerID addOrderID:theOrder.order_ID success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if(buttonIndex == 1)
                [self requestCompleteOrder:YES];
            else
                [self requestGetOrderDetailByJson];
            
        } failure:^{}];
    } failure:^(NSError *error) {
    }];
}

// completeTreatment
- (void)requestCompleteTreatmentWithTreatment:(TreatmentDoc *)treatmentDoc andByCourse:(NSInteger)courseID andByOrderID:(NSInteger)orderId
{
    
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"CustomerID\":%ld,\"CourseID\":%ld,\"OrderID\":%ld}", (long)ACC_BRANCHID, (long)theOrder.order_CustomerID, (long)courseID, (long)orderId];
    
    _requestCompleteTreaatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/completeTrearmentsByCourseID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

// completeOrder
- (void)requestCompleteOrder:(BOOL)finishFlag
{
    //    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"CustomerID\":%ld,\"OrderType\":%ld,\"IsComplete\":%d}", (long)ACC_BRANCHID, (long)theOrder.order_ID, (long)theOrder.order_CustomerID, (long)theOrder.order_ProductType, finishFlag];
    NSDictionary * par = @{
                           @"OrderID":@((long)theOrder.order_ID),
                           @"OrderObjectID":@((long)theOrder.order_ObjectID),
                           @"ProductType":@(self.productType)
                           };
    _requestCompleteOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CompleteOrder" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        NSString *Message = [json objectForKey:@"Message"];
        NSInteger code = [[json objectForKey:@"Code"] integerValue];
        if(code == 1) {
            [self requestGetOrderDetailByJson];
            [SVProgressHUD showSuccessWithStatus:Message];
        } else
            [SVProgressHUD showErrorWithStatus2:Message touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
    } failure:^(NSError *error) {
        
    }];
}

// cancelTreatment
- (void)requestCancelTreatmentWithTreatment:(TreatmentDoc *)treatmentDoc andIndex:(NSIndexPath *)index
{
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"TreatmentID\":%ld,\"ScheduleID\":%ld,\"CustomerID\":%ld}", (long)ACC_BRANCHID, (long)theOrder.order_ID, (long)treatmentDoc.treat_ID, (long)treatmentDoc.treat_Schedule.sch_ID, (long)theOrder.order_CustomerID];
    
    _requestCompleteOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/cancelTreatment" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:index.section - 3];
            TreatmentDoc *treatment = [operation_course.treatmentArray objectAtIndex:index.row - 1];
            treatment.treat_Schedule.sch_ScheduleTime = nil;
            [operation_course.treatmentArray replaceObjectAtIndex:(index.row - 1) withObject:treatment];
            
            [[theOrder.courseArray objectAtIndex:index.section - 3] setTreatmentArray:operation_course.treatmentArray];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.row inSection:index.section]] withRowAnimation:UITableViewRowAnimationNone];
            
            [self requestGetOrderDetailByJson];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateTreatmentDesignated:(TreatmentDoc *)treatmentDoc andIndex:(NSIndexPath *)index
{
    [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeClear];
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"TreatmentID\":%ld,\"IsDesignated\":%d}", (long)ACC_BRANCHID, (long)theOrder.order_ID, (long)treatmentDoc.treat_ID, treatmentDoc.status_Designated];
    
    
    _requestUpdateTreatmentDesignated = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTreatmentDesignated" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
            }];
        }];
        [self requestGetOrderDetailByJson];
    } failure:^(NSError *error) {
        
    }];
}


- (void)upDataAdd:(NSIndexPath *)indexPath

{
    [SVProgressHUD showWithStatus:@"Updating" maskType:SVProgressHUDMaskTypeClear];
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"IsAddUp\":%d}", (long)ACC_BRANCHID, (long)theOrder.order_ID, !theOrder.productAndPriceDoc.productDoc.isCount];
    
    _requestIsAddUp = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateOrderIsAddUp" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [self requestGetOrderDetailByJson];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)updateTotalSalePrice:(double)price
{
    
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"TotalSalePrice\":%.2f}", (long)ACC_BRANCHID, (long)theOrder.order_ID, price];
    
    _requestUpdatePrice = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTotalSalePrice" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)haveCompletionGroup:(NSString *)haveGroup completion:(BOOL)isCompletion
{
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"OrderID\":%ld,\"CustomerID\":%ld,\"Group\":%@}", (long)ACC_BRANCHID, (long)theOrder.order_ID, (long)theOrder.order_CustomerID, haveGroup];
    _requestDeleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/completeBeforeTreatmentsByGroupNO" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [self parserJsonData:json andComplete:isCompletion];
    } failure:^(NSError *error) {
        
    }];
}

//撤掉group
- (void)deleteTreatmentGroup:(double)GroupNo completion:(BOOL)isCompletion
{
    NSArray * arr = @[
                      @{@"OrderType":@(self.productType),
                        @"OrderID":@((long)theOrder.order_ID),
                        @"OrderObjectID":@((long)theOrder.order_ObjectID),
                        @"GroupNo":@(GroupNo)}
                      ];
    NSDictionary *par = @{
                          @"TGDetailList":arr,
                          };
    
    _requestDeleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CancelTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [self parserJsonData:json andComplete:isCompletion];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 结单完成(服务/商品)group
- (void)completeTreatmentGroup:(double)GroupNo completion:(BOOL)isCompletion
{
    
    NSArray * arr = @[@{
                          @"OrderType":@(self.productType),
                          @"OrderID":@((long)theOrder.order_ID),
                          @"OrderObjectID":@((long)theOrder.order_ObjectID),
                          @"GroupNo":@(GroupNo)
                          }
                      ];
    //    NSDictionary *par = @{
    //                              @"CustomerID":@((long)theOrder.order_CustomerID),
    //                              @"TGDetailList":arr,
    //                          };
    NSDictionary *par;
    if (theOrder.IsConfirmed == 2) { // 电子签名
        par = @{
                @"CustomerID":@((long)theOrder.order_CustomerID),
                @"SignImg":_signImgStr,
                @"ImageFormat":@".jpg",
                @"TGDetailList":arr,
                };
        
    }else{
        par = @{
                @"CustomerID":@((long)theOrder.order_CustomerID),
                @"TGDetailList":arr,
                };
    }
    
    _requestCompleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CompleteTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [self parserJsonData:json andComplete:isCompletion];
        
    } failure:^(NSError *error) {
        
    }];
}

//删除单个服务
- (void)deleteCompleteTreatment:(NSInteger)treatmentID groupNo:(double)groupNO completion:(BOOL)isCompletion
{
    NSDictionary *par = @{
                          @"OrderObjectID":@((long)theOrder.order_ObjectID),
                          @"TreatmentID":@((long)treatmentID),
                          @"GroupNo":@(groupNO)
                          };
    NSLog(@"删除单个服务 = %@",par);
    
    _requestDeleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CancelTreatment" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [self parserJsonData:json andComplete:isCompletion];
        
    } failure:^(NSError *error) {
        
    }];
}

//完成单个服务
- (void)completeTreatment:(NSInteger)treatmentID completion:(BOOL)isCompletion
{
    NSDictionary *par = @{
                          @"CustomerID":@((long)theOrder.order_CustomerID),
                          @"TreatmentID":@((long)treatmentID),
                          };
    NSLog(@"完成单个服务 = %@",par);
    
    _requestCompleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/CompleteTreatment" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [self parserJsonData:json andComplete:isCompletion];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)parserJsonData:(id)data andComplete:(BOOL)isCompletion
{
    NSString *Message = [data objectForKey:@"Message"];
    NSInteger code = [[data objectForKey:@"Code"] integerValue];
    
    if(code == 1){
        if (isCompletion) {
            [self requestCompleteOrder:YES];
        } else {
            [self requestGetOrderDetailByJson];
        }
    }
    else{
        if (code == -2 ) {
            [SVProgressHUD showErrorWithStatus2:Message duration:kSvhudtimer touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus2:(Message.length == 0 ? @"操作失败" : Message) duration:kSvhudtimer touchEventHandle:^{
                [self requestGetOrderDetailByJson];
            }];
        }
        
    }
}

// addNewTreatment
#pragma mark 添加新的课程
- (void)requestAddNewTreatmentWithOrderID:(NSInteger)orderId andCourseID:(NSInteger)courseId andIndex:(NSIndexPath *)index
{
    [SVProgressHUD showWithStatus:@"Loading"maskType:SVProgressHUDMaskTypeClear];
    _requestAddTreatmentOperation = [[GPHTTPClient shareClient] requestAddNewTreatmentWithOrderID:orderId andCourseID:courseId andCustomerID:theOrder.order_CustomerID success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            
            TreatmentDoc *newTreatmentDoc = [[TreatmentDoc alloc] init];
            newTreatmentDoc.ctlFlag = 1;
            newTreatmentDoc.treat_Schedule.ctlFlag = 1;
            [newTreatmentDoc setTreat_ID:[[[[contentData elementsForName:@"TreatmentID"] objectAtIndex:0] stringValue] intValue]];
            [newTreatmentDoc.treat_Schedule setSch_ID:[[[[contentData elementsForName:@"ScheduleID"] objectAtIndex:0] stringValue] intValue]];
            
            CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:index.section -3];
            [operation_course.treatmentArray addObject:newTreatmentDoc];
            [[theOrder.courseArray objectAtIndex:index.section -3] setTreatmentArray:operation_course.treatmentArray];
            
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:operation_course.treatmentArray.count-1 inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:operation_course.treatmentArray.count inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index.section]] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


// deleteTreatment
- (void)requestDeleteTreatmentWithTreatment:(TreatmentDoc *)treatmentDoc andIndex:(NSIndexPath *)index
{
    [SVProgressHUD showWithStatus:@"Loading"maskType:SVProgressHUDMaskTypeClear];
    
    _requestDeleteTreaatmentOperation = [[GPHTTPClient shareClient] requestdeleteTreatmentWithTreatmentID:treatmentDoc.treat_ID andScheduleID:treatmentDoc.treat_Schedule.sch_ID andCustomerID:theOrder.order_CustomerID success:^(id xml) {
        [SVProgressHUD dismiss];
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:index.section - 3];
            [operation_course.treatmentArray removeObjectAtIndex:index.row - 1];
            [[theOrder.courseArray objectAtIndex:index.section -3] setTreatmentArray:operation_course.treatmentArray];
            
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.row inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index.section]] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            for (NSInteger i = index.row; i < operation_course.treatmentArray.count + 1; i++) {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            }
        } failure:^{
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)requestDeleteTreatmentWithTreatmentTwo:(TreatmentDoc *)treatmentDoc andIndex:(NSIndexPath *)index
{
    [SVProgressHUD showWithStatus:@"Loading"maskType:SVProgressHUDMaskTypeClear];
    
    _requestDeleteTreaatmentOperation = [[GPHTTPClient shareClient] requestdeleteTreatmentWithTreatmentID:treatmentDoc.treat_ID andScheduleID:treatmentDoc.treat_Schedule.sch_ID andCustomerID:theOrder.order_CustomerID success:^(id xml) {
        [SVProgressHUD dismiss];
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            CourseDoc *operation_course = [theOrder.courseArray objectAtIndex:index.section - 3];
            [operation_course.treatmentArray removeObjectAtIndex:index.row - 1];
            [[theOrder.courseArray objectAtIndex:index.section -3] setTreatmentArray:operation_course.treatmentArray];
            
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.row inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            for (NSInteger i = index.row; i < operation_course.treatmentArray.count + 1; i++) {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:index.section]] withRowAnimation:UITableViewRowAnimationBottom];
            }
            
        } failure:^{
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)requestCustomerWithQRCode:(NSString *)QRCodeString
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"QRCode\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld}", QRCodeString, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/WebUtility/getInfoByQRcode" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            CustomerDoc *customerDoc = [[CustomerDoc alloc]init];
            [customerDoc setCus_ID:[(NSString*)[data objectForKey:@"CustomerID"] integerValue]];
            [customerDoc setCus_Name:(NSString *)[data objectForKey:@"CustomerName"]];
            [customerDoc setCus_Discount:[(NSString*)[data objectForKey:@"Discount"] doubleValue]];
            [customerDoc setCus_HeadImgURL:(NSString*)[data objectForKey:@"HeadImageURL"]];
            [customerDoc setCus_IsMyCustomer:[(NSString*)[data objectForKey:@"IsMyCustomer"] boolValue]];
            if (customerDoc.cus_ID > 0) {
                if ([[PermissionDoc sharePermission] rule_MyCustomer_Read]) {
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.customer_Selected = customerDoc;
                    [SVProgressHUD showSuccessWithStatus:@"选择顾客成功！"];
                }else
                    [SVProgressHUD showErrorWithStatus2:@"没有权限，不能选中该顾客！" touchEventHandle:^{}];
            }else
                [SVProgressHUD showErrorWithStatus2:@"获取顾客信息失败！" touchEventHandle:^{}];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:@"获取顾客信息失败！" touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark footerView 订单数量 价格 及优惠价
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark  订单优惠价修改
- (void)changeOrderPrice
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"" message:@"修改订单价格" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alterView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alterView show];
}
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    UITextField *text = [alertView textFieldAtIndex:0];
    text.delegate = self;
    text.keyboardType = UIKeyboardTypeDecimalPad;
    text.clearButtonMode = UITextFieldViewModeWhileEditing;
    text.placeholder = [NSString stringWithFormat:@"%.2Lf", theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
    }
    if (buttonIndex == 0) {
        UITextField *text = [alertView textFieldAtIndex:buttonIndex];
        NSLog(@"the text is %@", text.text);
        if ([text.text doubleValue] == 0) {
            [SVProgressHUD showErrorWithStatus2:@"订单价格不可修改为0" touchEventHandle:^{}];
        } else if (![text.text isEqualToString:@""] &&[text.text doubleValue] != theOrder.productAndPriceDoc.productDoc.pro_TotalSaleMoney) {
            [self updateTotalSalePrice:[text.text doubleValue]];
        }
    }
}

#pragma mark 优惠价修改输入框delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"0"]) {
        textField.text = @"" ;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToTextField:textField];
    });
}

- (void)scrollToTextField:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    NSIndexPath* path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text integerValue] > (long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount) {
        [SVProgressHUD showErrorWithStatus2:@"支付数量超出剩余数量!" touchEventHandle:^{}];
        textField.text = [NSString stringWithFormat:@"%ld",(long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount];
        payCountStr = [NSString stringWithFormat:@"%ld",(long)theOrder.productAndPriceDoc.productDoc.pro_SurplusCount];
    }else
    {
        payCountStr = textField.text;
    }
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
    
    if (self.textView_Selected) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:[_tableView numberOfSections] - 1];
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];//
    }
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
}


- (void)scrollToTextView:(UITextView *)textView
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textView.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textView.superview.superview;
    }
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 备注编辑
- (void)changeRemark:(id)sender
{
    bool_save = NO;
    bool_edit = YES;
    UIButton *editButton = (UIButton *)sender;
    
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)editButton.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)editButton.superview.superview;
    }
    UIButton *saveButton = (UIButton *)[cell viewWithTag:1004];
    
    saveButton.hidden = bool_save;
    editButton.hidden = bool_edit;
    
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    NSIndexPath *pathedit = [NSIndexPath indexPathForRow:path.row + 1 inSection:path.section];
    
    UITableViewCell *editCell = [_tableView cellForRowAtIndexPath:pathedit];
    
    UITextView *textEdit = (UITextView *)[editCell viewWithTag:1000];
    textEdit.editable = YES;
    textEdit.userInteractionEnabled = YES;
    textEdit.textColor = kColor_Editable;
    [textEdit becomeFirstResponder];
}

- (void)saveRemark:(id)sender
{
    bool_save = YES;
    bool_edit = NO;
    UIButton *saveButton = (UIButton *)sender;
    
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)saveButton.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)saveButton.superview.superview;
    }
    UIButton *editButton = (UIButton *)[cell viewWithTag:1003];
    saveButton.hidden = bool_save;
    editButton.hidden = bool_edit;
    
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    NSIndexPath *pathedit = [NSIndexPath indexPathForRow:path.row + 1 inSection:path.section];
    
    UITableViewCell *editCell = [_tableView cellForRowAtIndexPath:pathedit];
    
    UITextView *textEdit = (UITextView *)[editCell viewWithTag:1000];
    [textEdit resignFirstResponder];
    textEdit.editable = NO;
    textEdit.userInteractionEnabled = NO;
    [textEdit resignFirstResponder];
    textEdit.textColor = [UIColor blackColor];
    theOrder.order_Remark = textEdit.text;
    [self updateOrderRemark];
}



- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    contentText.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 300;
    textView.frame = rect;
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 300) {
                textView.text = [toBeString substringToIndex:300];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
}
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //if ([contentText.text length] > 299) return NO;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];
    self.textView_Selected = nil;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    NSIndexPath *indexRemark = [_tableView indexPathForCell:cell];
    
    theOrder.order_Remark = contentText.text;
    
    if (indexRemark.row == 1 ) {
        //  [_tableView scrollToRowAtIndexPath:indexRemark atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [_tableView beginUpdates];
        [_tableView endUpdates];
        
    }
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [_tableView convertRect:cursorRect fromView:textView];
    
    if (_prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        _prevCaretRect = newCursorRect;
        [self.tableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(300.0f, 500.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    if (textViewSize.width < 300) {
        textViewSize.width = 300;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    //    [_tableView beginUpdates];
    //    [_tableView endUpdates];
}

- (NSIndexPath *)indexPathForCellWithTextFiled:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[[textField superview] superview] superview];
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[[textField superview] superview];
    }
    return [_tableView indexPathForCell:cell];
}



#pragma mark 有效期更换
-(void)chooseDate:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)[[button superview] superview];
        
    } else if (IOS6 || IOS8) {
        cell = (UITableViewCell *)[button superview];
    }
    _index = [_tableView indexPathForCell:cell];
    _textField_Editing = ((NormalEditCell*)cell).valueText;
    [self initialKeyboard];
}

-(void)selectCustomer:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.customer_Selected.cus_ID == theOrder.order_CustomerID)
        [SVProgressHUD showSuccessWithStatus:@"已选中该顾客！"];
    else{
        NSMutableString *QRCodeString = [NSMutableString stringWithFormat:@""];
        NSString *tailString = [NSString stringWithFormat:@"%@",ACC_COMPANTCODE];
        for (int i = 0; i < 10 - tailString.length ;i++ ){
            [QRCodeString appendString:@"0"];
        }
        [QRCodeString appendFormat:@"%@^000^",tailString];
        tailString = [NSString stringWithFormat:@"%ld",(long)theOrder.order_CustomerID];
        for (int i = 0; i < 10 - tailString.length ;i++ ){
            [QRCodeString appendString:@"0"];
        }
        [QRCodeString appendString:tailString];
        [self requestCustomerWithQRCode:QRCodeString];
    }
}
#pragma mark - Initial Keyboard

- (void)initialKeyboard
{
    if(IOS7 || IOS6){
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    }
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] init];
        if (IOS8)
            datePicker.frame = CGRectMake(-8, 30, kSCREN_BOUNDS.size.width, 390);
        else
            datePicker.frame = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, 390);
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    NSDate *theDate = [NSDate stringToDate:[[NSDate date].description substringToIndex:10] dateFormat:@"yyyy-MM-dd"];
    // theDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([theDate timeIntervalSinceReferenceDate] - 8*3600)];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
        _oldDate = [NSDate stringToDate:[theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime substringToIndex:10] dateFormat:@"yyyy-MM-dd"] ;
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        if(IOS8)
            [inputAccessoryView setFrame:CGRectMake(-8, 0, kSCREN_BOUNDS.size.width, 35)];
        else
            inputAccessoryView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 35);
        
        CGFloat width = kSCREN_BOUNDS.size.width / 3;
        
        UIButton *doneBtn = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(done:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *clearBtn = [UIButton buttonWithTitle:@"无有效期" target:self selector:@selector(clear:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIButton *canceBtn = [UIButton buttonWithTitle:@"取消" target:self selector:@selector(cancel:) frame:CGRectMake(0, 0, width, 35) titleColor:kColor_White backgroudColor:nil];
        UIBarButtonItem *itemDoneBtn= [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
        UIBarButtonItem *itemClearBtn = [[UIBarButtonItem alloc]initWithCustomView:clearBtn];
        UIBarButtonItem *itemCanceBtn = [[UIBarButtonItem alloc]initWithCustomView:canceBtn];
        
        
        //        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        //        [doneBtn setTintColor:kColor_White];
        //
        //        UIBarButtonItem *clearBtn =[[UIBarButtonItem alloc] initWithTitle:@"无有效期" style:UIBarButtonItemStyleDone target:self action:@selector(clear:)];
        //        [clearBtn setTintColor:kColor_White];
        //
        //        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        //        [cancelBtn setTintColor:kColor_White];
        
        //        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //        flexibleSpaceLeft.width = 120;
        //        UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //        flexibleSpaceRight.width = 5;
        //        UIBarButtonItem *flexibleSpaceCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //        flexibleSpaceCenter.width = (kSCREN_BOUNDS.size.width - 40) / 3;
        //        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, clearBtn, cancelBtn, doneBtn,flexibleSpaceRight,nil];
        NSArray *array = @[itemClearBtn,itemCanceBtn,itemDoneBtn];
        [inputAccessoryView setItems:array];
    }
    if(IOS8){
        UIAlertController *alertCtrlr =[UIAlertController  alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(-8, 30, kSCREN_BOUNDS.size.width , 400)];
        view.backgroundColor = [UIColor whiteColor];
        [alertCtrlr.view addSubview:view];
        [alertCtrlr.view addSubview:inputAccessoryView];
        [alertCtrlr.view addSubview:datePicker];
        [self presentViewController:alertCtrlr animated:YES completion:nil];
    }else{
        [_actionSheet addSubview:datePicker];
        [_actionSheet addSubview:inputAccessoryView];
        
        [_actionSheet showInView:self.view];
        [_actionSheet setBounds:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 430)];
        [_actionSheet setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)dateChanged:(id)sender
{
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate]  + 8*3600)];
    NSMutableString *dateString =[NSMutableString stringWithString: [newDate.description substringToIndex:10]];
    NSLog(@"%@", dateString);
    [dateString replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
    [dateString replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    //UIImageView *imageView = (UIImageView *)[cell viewWithTag:1006];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    newDate = [dateFormatter dateFromString:dateString];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]]; //取出日期比较
    if([newDate compare:currentDate] == NSOrderedDescending || [newDate compare:currentDate] == NSOrderedSame){
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dateString]];
        theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime = _textField_Editing.text;
        //imageView.hidden = YES;
    }
    else{
        return;
    }
}

-(void)clear:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *furtureDate = [dateFormatter dateFromString:@"2099-12-31"];
    [datePicker setDate:furtureDate animated:YES];
    _textField_Editing.text = @"2099-12-31"; //[dateFormatter stringFromDate:furtureDate];
    theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime = @"2099-12-31";//[NSString stringWithString: _textField_Editing.text];
}

- (void)done:(id)sender
{
    NSDate *newDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([datePicker.date timeIntervalSinceReferenceDate])+8*3600];
    NSMutableString *dateString =[NSMutableString stringWithString: [newDate.description substringToIndex:10]];
    NSLog(@"%@", dateString);
    [dateString replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
    [dateString replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
    newDate = [dateFormatter dateFromString:[newDate.description substringToIndex:10]];
    if ([newDate compare:currentDate] == NSOrderedAscending) {
        inputAccessoryView = nil;
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"所选日期不能在今天之前" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }else{
        inputAccessoryView = nil;
        [_textField_Editing setText:[NSString stringWithFormat:@"%@", dateString]];
        theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime = _textField_Editing.text;
        [self updateExpirationTime];
        
        if(IOS8){
            datePicker = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
            [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)cancel:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    UITableViewCell *cell = nil;
    if (IOS7)
        cell = (UITableViewCell *)_textField_Editing.superview.superview.superview;
    else
        cell = (UITableViewCell *)_textField_Editing.superview.superview;
    
    NSDate *currentDate = [NSDate date];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1006];
    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]]; //取出日期比较
    if([_oldDate compare:currentDate] == NSOrderedDescending || [_oldDate compare:currentDate] == NSOrderedSame){
        imageView.hidden = YES;
    }else
        imageView.hidden = NO;
    _textField_Editing.text = [dateFormatter stringFromDate:_oldDate];
    theOrder.productAndPriceDoc.productDoc.pro_ExpirationTime =[NSString stringWithString: _textField_Editing.text];
    _oldDate = nil;
    inputAccessoryView = nil;
    if(IOS8){
        datePicker = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

@end

