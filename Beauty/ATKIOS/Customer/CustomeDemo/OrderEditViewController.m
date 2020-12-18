//
//  OrderConfirmViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-11.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderEditViewController.h"
#import "NSDate+Convert.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "OrderDoc.h"
#import "InitialSlidingViewController.h"
#import "AppDelegate.h"
#import "UIButton+InitButton.h"
#import "ProductAndPriceView.h"
#import "OrderListViewController.h"
#import "UIAlertView+AddBlockCallBacks.h"

@interface OrderEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddOrderOperation;
@property (nonatomic) OrderDoc *theOrderDoc;
@property (nonatomic) NSDate *currentDate;        // 记录进入该页面时的时间
@property (strong, nonatomic) TitleView *titleView;
@end

@implementation OrderEditViewController
@synthesize productAndPriceDoc;
@synthesize theOrderDoc;
@synthesize currentDate;
@synthesize titleName;
@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         self.view.backgroundColor = kDefaultBackgroundColor;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestAddOrderOperation && [_requestAddOrderOperation isExecuting]) {
        [_requestAddOrderOperation cancel];
        _requestAddOrderOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
//    if (titleView == nil) {
//        titleView = [[TitleView alloc] init];
//        [self.view addSubview:titleView];
//    }
    
    currentDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
//    [titleView getTitleView:titleName];
    self.title = titleName;
}

- (void)initTableView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 312.0f, 60.0f)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:footerView];
    UIButton *footerButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(submitOrderAction)
                                                 frame:CGRectMake(10.0f, 10.0f, 310.0f, 36.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_Confirm"]
                                      highlightedImage:nil];
    [_tableView setFrame:CGRectMake(-5.0f, 0, 330.0f, kSCREN_BOUNDS.size.height - 88.0f)];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 88.0f)];
        [footerButton setFrame:CGRectMake(1.0f, 10.0f, 310.0f, 36.0f)];
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    [footerView addSubview:footerButton];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditCell_OrderEditCell";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    
    cell.titleLabel.text = @"时间";
    cell.valueText.text = [NSDate stringFromDateTime:currentDate];
    [cell setAccessoryText:@""];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? kTableView_HeightOfRow : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (productAndPriceDoc.table_Height != 0 && section == 0) ? productAndPriceDoc.table_Height : kTableView_Margin_Bottom;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        static NSString *footerIdentity = @"ProductAndPriceFooter";
        ProductAndPriceView  *proView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerIdentity];
        if (proView == nil) {
          proView = [[ProductAndPriceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, productAndPriceDoc.table_Height)];
        }
        [proView setTheProductAndPriceDoc:productAndPriceDoc];
        [proView setCanEditeQuantityAndPrice:YES];
        return proView;
    } else {
        return nil;
    }
}

#pragma mark - Submit

- (void)submitOrderAction
{
    theOrderDoc = [[OrderDoc alloc] init];
    theOrderDoc.order_CustomerID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue];;
    theOrderDoc.order_OrderTime = [NSDate stringFromDateTime:currentDate];
    theOrderDoc.productAndPriceDoc = productAndPriceDoc;
    [self appendJSONString];
  //  [self convertSpecialString];
    [self requestAddOrder:theOrderDoc];
}


-(void)appendJSONString
{
    NSMutableString *productString = [[NSMutableString alloc]init];
    [productString appendString:@"["];
    for (CommodityDoc *productDoc in theOrderDoc.productAndPriceDoc.commodityArray) {
        [productString appendFormat:@"{\"ProductCode\":%lld,",(long long)productDoc.comm_Code];
        [productString appendFormat:@"\"Quantity\":%ld,",(long)productDoc.comm_Quantity];
        [productString appendFormat:@"\"TotalOrigPrice\":%.2Lf,",
         productDoc.comm_UnitPrice * productDoc.comm_Quantity];
        [productString appendFormat:@"\"BranchID\":%ld,",(long)productDoc.comm_BranchID];
        if(productDoc.comm_MarketingPolicy == 1)
            [productString appendFormat:@"\"TotalCalcPrice\":%.2Lf,",productDoc.comm_DiscountMoney];
        else if(productDoc.comm_MarketingPolicy == 2)
            [productString appendFormat:@"\"TotalCalcPrice\":%.2Lf,",productDoc.comm_PromotionPrice * productDoc.comm_Quantity];
        else
            [productString appendFormat:@"\"TotalCalcPrice\":%.2Lf,",productDoc.comm_UnitPrice * productDoc.comm_Quantity];
        
        [productString appendFormat:@"\"TotalSalePrice\":%d,",-1];
        
        [productString appendFormat:@"\"ProductType\":%d,",1];
        if (productDoc == [theOrderDoc.productAndPriceDoc.commodityArray lastObject])
            [productString appendFormat:@"\"CartID\":%ld}",(long)productDoc.cart_ID];
        else
            [productString appendFormat:@"\"CartID\":%ld},",(long)productDoc.cart_ID];
    }
    [productString appendString:@"]"];
    NSMutableArray *array = [NSMutableArray array];
    for (CommodityDoc *productDoc in theOrderDoc.productAndPriceDoc.commodityArray) {
        CGFloat totalCalcPrice = 0;
        if(productDoc.comm_MarketingPolicy == 1)
            totalCalcPrice = productDoc.comm_DiscountMoney;
        else if(productDoc.comm_MarketingPolicy == 2)
            totalCalcPrice = productDoc.comm_PromotionPrice * productDoc.comm_Quantity;
        else
            totalCalcPrice = productDoc.comm_UnitPrice * productDoc.comm_Quantity;
        NSDictionary *dict = @{@"ProductCode":[NSNumber numberWithLongLong:productDoc.comm_Code],
                               @"Quantity":@(productDoc.comm_Quantity),
                               @"TotalOrigPrice":[NSNumber numberWithFloat:productDoc.comm_UnitPrice * productDoc.comm_Quantity],
                               @"BranchID":@(productDoc.comm_BranchID),
                               @"TotalCalcPrice":[NSNumber numberWithFloat:totalCalcPrice],
                               @"TotalSalePrice":@(-1),
                               @"Quantity":@(productDoc.comm_Quantity),
                               @"ProductType":@1,
                               @"CartID":productDoc.cart_ID,
                               };
        [array addObject:dict];
//        [productString appendFormat:@"{\"ProductCode\":%lld,",(long long)productDoc.comm_Code];
//        [productString appendFormat:@"\"Quantity\":%ld,",(long)productDoc.comm_Quantity];
//        [productString appendFormat:@"\"TotalOrigPrice\":%.2f,",productDoc.comm_UnitPrice * productDoc.comm_Quantity];
//        [productString appendFormat:@"\"BranchID\":%ld,",(long)productDoc.comm_BranchID];
//        if(productDoc.comm_MarketingPolicy == 1)
//            [productString appendFormat:@"\"TotalCalcPrice\":%.2f,",productDoc.comm_DiscountMoney];
//        else if(productDoc.comm_MarketingPolicy == 2)
//            [productString appendFormat:@"\"TotalCalcPrice\":%.2f,",productDoc.comm_PromotionPrice * productDoc.comm_Quantity];
//        else
//            [productString appendFormat:@"\"TotalCalcPrice\":%.2f,",productDoc.comm_UnitPrice * productDoc.comm_Quantity];
//        
//        [productString appendFormat:@"\"TotalSalePrice\":%d,",-1];
//        
//        [productString appendFormat:@"\"ProductType\":%d,",1];
//        if (productDoc == [theOrderDoc.productAndPriceDoc.commodityArray lastObject])
//            [productString appendFormat:@"\"CartID\":%ld}",(long)productDoc.cart_ID];
//        else
//            [productString appendFormat:@"\"CartID\":%ld},",(long)productDoc.cart_ID];
    }
    
    theOrderDoc.OrderDetail = array;
    theOrderDoc.strCourse = @"";
    theOrderDoc.strContact = @"";
}

//- (void)convertSpecialString
//{
//    NSString *tempStrOrderDetail_0 = theOrderDoc.strOrderDetail;
//    NSString *tempStrOrderDetail_1 = [tempStrOrderDetail_0  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    NSString *tempStrOrderDetail_2 = [tempStrOrderDetail_1  stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    theOrderDoc.strOrderDetail = tempStrOrderDetail_2;
//    
//    NSString *temp_StrCourse_0 = theOrderDoc.strCourse;
//    NSString *temp_StrCourse_1 = [temp_StrCourse_0  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    NSString *temp_StrCourse_2 = [temp_StrCourse_1  stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    theOrderDoc.strCourse = temp_StrCourse_2;
//    
//    NSString *temp_StrContact_0 = theOrderDoc.strContact;
//    NSString *temp_StrContact_1 = [temp_StrContact_0  stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    NSString *temp_StrContact_2 = [temp_StrContact_1  stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    theOrderDoc.strContact = temp_StrContact_2;
//}

#pragma mark - 接口

// 添加order
- (void)requestAddOrder:(OrderDoc *)newOrder
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"CreatorID":@(CUS_CUSTOMERID),
                           @"UpdaterID":@(CUS_CUSTOMERID),
                           @"OrderList":newOrder.OrderDetail};
    
    _requestAddOrderOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/order/addOrder"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"新增订单成功" ];
            [self performSelector:@selector(goOrderListViewController) withObject:nil afterDelay:1.0f];
        } failure:^(NSInteger code, NSString *error) {
            if(code == -2) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                return;
            }else {
                [SVProgressHUD showErrorWithStatus2:error];
                return;
            }
        }];
    } failure:^(NSError *error) {
        
    }];
    
//    _requestAddOrderOperation = [[GPHTTPClient shareClient] requestAddOrder:newOrder oppId:0 cartIdStr:nil success:^(id xml) {
//        [SVProgressHUD dismiss];
//        
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, NSInteger code, id message) {
//            [SVProgressHUD showSuccessWithStatus2:@"新增订单成功" ];
//            [self performSelector:@selector(goOrderListViewController) withObject:nil afterDelay:1.0f];
//        } failure:^(NSInteger code, NSString *error) {
//            if(code == -2) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }];
//                return;
//            }else {
//                [SVProgressHUD showErrorWithStatus2:error];
//                return;
//            }
//        }];
//
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

- (void)goOrderListViewController
{
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderListNavigation"];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}
@end
