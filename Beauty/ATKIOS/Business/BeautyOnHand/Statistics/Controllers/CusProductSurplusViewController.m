//
//  CusProductSurplusViewController.m
//
//
//  Created by scs_zhouyt on 2021/02/06.
//  Copyright © 2021 ace-009. All rights reserved.
//

#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20

#import "CusProductSurplusViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
//#import "ChartModel.h"
//#import "CusProductTableViewCell.h"
#import "../Views/JHGridView.h"
#import "../Models/StatustucsProductSurplus.h"
#import "OrderDoc.h"
#import "OrderDetailViewController.h"
#import <UIKit/UIKit.h>

@interface CusProductSurplusViewController () <JHGridViewDelegate>
{
    // UITableView *productTableView;
    JHGridView *productGridView;
    CGFloat productGridViewWidth;
    NSMutableArray *productData;
    AFHTTPRequestOperation *_requestProductOperation;
    
    UIButton *serverBtn;
    UIButton *productBtn;
    UILabel *titleLab;
    UILabel *statustucsSurplusPriceTotal;
    NSNumber *productSurplusPriceTotal;
    
    OrderDoc *selectOrderDoc;
    
    BOOL isSelectServer;
}
@end

@implementation CusProductSurplusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isSelectServer = YES;
    productGridViewWidth = kSCREN_BOUNDS.size.width - 10;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"消费剩余价值统计(%@)", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name]];
    navigationView.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:navigationView];
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, self.view.frame.size.width - 10, 40)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = KColor_Blue;
    [titleLab setText:@"未服务项目"];
    [self.view addSubview:titleLab];
    titleLab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   titleLab.frame.origin.y + titleLab.frame.size.height, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [self.view addSubview:viewLine];
    
    productGridView = [[JHGridView alloc] initWithFrame:CGRectMake(5.0f, viewLine.frame.origin.y + viewLine.frame.size.height, productGridViewWidth, kSCREN_BOUNDS.size.height - 64.0f - viewLine.frame.origin.y - 40 -40 - 5)];
    productGridView.delegate = self;
    [self.view addSubview:productGridView];
    productData = [NSMutableArray array];
    [self initProductGridView:productData];
    statustucsSurplusPriceTotal = [[UILabel alloc]initWithFrame:CGRectMake(5, productGridView.frame.origin.y + productGridView.frame.size.height, self.view.frame.size.width - 10, 40)];
    statustucsSurplusPriceTotal.textAlignment = NSTextAlignmentRight;
    statustucsSurplusPriceTotal.textColor = KColor_Blue;
    [self.view addSubview:statustucsSurplusPriceTotal];
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, statustucsSurplusPriceTotal.frame.origin.y + statustucsSurplusPriceTotal.frame.size.height, kSCREN_BOUNDS.size.width  , 40)];
    [self.view addSubview:btnView];
    serverBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    serverBtn.frame =  CGRectMake(5, 0 , btnView.frame.size.width  / 2 - 5, 40);
    [serverBtn setTitle:@"服务" forState:UIControlStateNormal];
    [serverBtn addTarget:self action:@selector(serverBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:serverBtn];
    productBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    productBtn.frame =  CGRectMake(serverBtn.frame.origin.x +serverBtn.frame.size.width, 0 , btnView.frame.size.width  / 2 - 5, 40);
    [productBtn setTitle:@"商品" forState:UIControlStateNormal];
    [productBtn addTarget:self action:@selector(productBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:productBtn];
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_BuleColor;
    [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_WitheColor;
    [self requestWithObjectType:0];
    
}
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (productData) {
        [productData removeAllObjects];
    } else {
        productData = [NSMutableArray array];
    }
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ObjectType\":%ld}", (long)customer.cus_ID, (long)ObjectType];
    _requestProductOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"Statistics/GetDataStatisticsSurplusList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            NSNumberFormatter *productSurplusPriceFormatter =[[NSNumberFormatter alloc]init];
            productSurplusPriceFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
            [productSurplusPriceFormatter setPositiveFormat:@"#0.00"];
            
            NSNumberFormatter *productSurPlusNumFormatter =[[NSNumberFormatter alloc]init];
            productSurPlusNumFormatter.numberStyle = kCFNumberFormatterNoStyle;
            productSurPlusNumFormatter.positiveSuffix = @"天";
            
            NSNumberFormatter *productSurPlusNumFormatter2 =[[NSNumberFormatter alloc]init];
            productSurPlusNumFormatter2.numberStyle = kCFNumberFormatterNoStyle;
            productSurPlusNumFormatter2.positiveSuffix = @"次";
            
            NSNumberFormatter *productSurPlusNumFormatter3 =[[NSNumberFormatter alloc]init];
            productSurPlusNumFormatter3.numberStyle = kCFNumberFormatterNoStyle;
            productSurPlusNumFormatter3.positiveSuffix = @"件";

            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                StatustucsProductSurplus *statustucsProductSurplus = [[StatustucsProductSurplus alloc] init];
                statustucsProductSurplus.productNo = [NSString stringWithFormat:@"%d", i + 1];
                if ([dic objectForKey:@"OrderNumber"]) {
                    statustucsProductSurplus.orderNumber = [dic objectForKey:@"OrderNumber"];
                }
                if ([dic objectForKey:@"ProductName"]) {
                    statustucsProductSurplus.productName = [dic objectForKey:@"ProductName"];
                }
                if ([dic objectForKey:@"ProductServiceType"]) {
                    statustucsProductSurplus.productServiceType = [dic objectForKey:@"ProductServiceType"];
                }
                if ([dic objectForKey:@"ProductSurPlusNum"]) {
                    statustucsProductSurplus.productSurPlusNum = [dic objectForKey:@"ProductSurPlusNum"];
                    if (isSelectServer) {
                        // 服务
                        if ([statustucsProductSurplus.productServiceType longValue] == 1) {
                            // 时间卡
                            statustucsProductSurplus.productSurPlusNumDisplay = [productSurPlusNumFormatter stringFromNumber:statustucsProductSurplus.productSurPlusNum];
                        } else {
                            // 服务次数
                            statustucsProductSurplus.productSurPlusNumDisplay = [productSurPlusNumFormatter2 stringFromNumber:statustucsProductSurplus.productSurPlusNum];
                        }
                    } else {
                        // 商品
                        statustucsProductSurplus.productSurPlusNumDisplay = [productSurPlusNumFormatter3 stringFromNumber:statustucsProductSurplus.productSurPlusNum];
                    }
                    
                }
                if ([dic objectForKey:@"ProductSurplusPrice"]) {
                    statustucsProductSurplus.productSurplusPrice = [dic objectForKey:@"ProductSurplusPrice"];
                    statustucsProductSurplus.productSurplusPriceDisplay = [productSurplusPriceFormatter stringFromNumber:statustucsProductSurplus.productSurplusPrice];
                    productSurplusPriceTotal = [NSNumber numberWithFloat:[productSurplusPriceTotal floatValue] + [statustucsProductSurplus.productSurplusPrice floatValue]];
                }
                [productData addObject:statustucsProductSurplus];
            }
            [self initProductGridView:productData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}

#pragma mark - 按钮事件
- (void)serverBtnClick:(UIButton *)sender
{
    isSelectServer = YES;
    [titleLab setText:@"未服务项目"];
    [self initProductGridView:nil];
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_BuleColor;
    [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:0];
}
- (void)productBtnClick:(UIButton *)sender
{
    isSelectServer = NO;
    [titleLab setText:@"未交付商品"];
    [self initProductGridView:nil];
    [productBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_BuleColor;
    [serverBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:1];
}

- (void)didSelectRowAtGridIndex:(GridIndex)gridIndex{
    NSLog(@"selected at\ncol:%ld -- row:%ld", gridIndex.col, gridIndex.row);
    if (gridIndex.col != 3) {
        return;
    }
    NSInteger branchId = 0;
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 0)  branchId = ACC_BRANCHID;
    StatustucsProductSurplus *statustucsProductSurplus = [productData objectAtIndex:gridIndex.row];
    
    NSString *par;
    par = [NSString stringWithFormat:@"{\"SerchField\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld,\"ProductType\":%d,\"CustomerID\":%ld,\"PageIndex\":%d,\"PageSize\":%d,\"IsShowAll\":%d}",statustucsProductSurplus.orderNumber,(long)ACC_ACCOUNTID, (long)branchId, isSelectServer ? 0 : 1, (long)customer.cus_ID, 1, 1, (((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder== 1? YES :[[PermissionDoc sharePermission] rule_BranchOrder_Read])];
    
    _requestProductOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
            [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
                OrderDoc *orderDoc = nil;
                NSArray *orderList = [data objectForKey:@"OrderList"];
                orderList = (NSNull *)orderList == [NSNull null] ? nil : orderList;
                if (orderList != nil && orderList.count > 0) {
                    NSDictionary *obj = [orderList objectAtIndex:0];
                    orderDoc = [[OrderDoc alloc] init];
                    [orderDoc setOrder_ID:[[obj objectForKey:@"OrderID"] integerValue]];
                    [orderDoc setOrder_ObjectID:[[obj objectForKey:@"OrderObjectID"] integerValue]];
                    NSLog(@" id =%ld",(long)orderDoc.order_ObjectID);
                    [orderDoc setOrder_ProductType:[[obj objectForKey:@"ProductType"] integerValue]];
                    [orderDoc setOrder_ResponsiblePersonName:[obj objectForKey:@"ResponsiblePersonName"]];
                    [orderDoc setOrder_OrderTime:[obj objectForKey:@"OrderTime"]];
                    [orderDoc setOrder_CreateTime:[obj objectForKey:@"CreateTime"]];
                    [orderDoc setOrder_Status:[[obj objectForKey:@"Status"] intValue]];
                    [orderDoc setOrder_Ispaid:[[obj objectForKey:@"PaymentStatus"] intValue]];
                    [orderDoc setOrder_CustomerName:[obj objectForKey:@"CustomerName"]];
                    [orderDoc setIsThisBranch:[[obj objectForKey:@"IsThisBranch"] integerValue]];
                    orderDoc.productAndPriceDoc.productDoc.pro_Name     = [obj objectForKey:@"ProductName"];
                    orderDoc.productAndPriceDoc.productDoc.pro_Type     = [[obj objectForKey:@"ProductType"] integerValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_quantity = [[obj objectForKey:@"Quantity"] integerValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_TotalMoney     = [[obj objectForKey:@"TotalOrigPrice"] doubleValue];
                    orderDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [[obj objectForKey:@"TotalSalePrice"] doubleValue];
                    [self getOrderDetail:orderDoc];
                    }
            } failure:^(NSInteger code, NSString *error) {
            }];
        } failure:^(NSError *error) {
        }];
}

- (void)getOrderDetail:(OrderDoc *) orderDoc{
    selectOrderDoc = orderDoc;
    OrderDetailViewController *detailController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
//    OrderDetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
//    OrderDetailViewController *detailController = [[OrderDetailViewController alloc] init];
    detailController.orderID = selectOrderDoc.order_ID;
    detailController.productType = selectOrderDoc.order_ProductType;
    detailController.isBranch = selectOrderDoc.isThisBranch;
    detailController.objectID = selectOrderDoc.order_ObjectID;
    [self.navigationController pushViewController:detailController animated:YES];
    //[self performSegueWithIdentifier:@"goOrderDetailViewFromSurplusView" sender:self];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"goOrderDetailViewFromSurplusView"]) {
//        OrderDetailViewController *detailController = segue.destinationViewController;
//        detailController.orderID = selectOrderDoc.order_ID;
//        detailController.productType = selectOrderDoc.order_ProductType;
//        detailController.isBranch = selectOrderDoc.isThisBranch;
//        detailController.objectID = selectOrderDoc.order_ObjectID;
//    }
//}

- (BOOL)isTitleFixed{
    return YES;
}

- (CGFloat)widthForColAtIndex:(long)index{
    // return [[UIScreen mainScreen] bounds].size.width / 5;
    // CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width - 10;
    CGFloat screenWidth = productGridViewWidth;
    CGFloat resultWidth = 0;
    switch (index) {
        case 0:
            resultWidth = screenWidth * 0.14;
            break;
        case 1:
            resultWidth = screenWidth * 0.37;
            break;
        case 2:
            resultWidth = screenWidth * 0.24;
            break;
        case 3:
            resultWidth = screenWidth * 0.25;
            break;
        default:
            break;
    }
    return resultWidth;
}

- (UIColor *)backgroundColorForGridAtGridIndex:(GridIndex)gridIndex{
    return [UIColor whiteColor];
}

- (UIColor *)textColorForGridAtGridIndex:(GridIndex)gridIndex{
    if (gridIndex.col == 3) {
        return [UIColor blueColor];
    }else{
        return [UIColor blackColor];
    }
}

- (CGFloat)heightForRowAtIndex:(long)index{
    return 40.0f;
}


- (UIFont *)fontForTitleAtIndex:(long)index{
    return [UIFont systemFontOfSize:15];
}

- (UIFont *)fontForGridAtGridIndex:(GridIndex)gridIndex{
    return [UIFont systemFontOfSize:14];
}

-(void)initProductGridView:(NSMutableArray *)dataArray{
    if (isSelectServer) {
        [productGridView setTitles:@[@"序号",@"服务名称",@"未完成数",@"剩余金额"]
                 andObjects:dataArray withTags:@[@"productNo",@"productName",@"productSurPlusNumDisplay",@"productSurplusPriceDisplay"]];
    } else {
        [productGridView setTitles:@[@"序号",@"商品名称",@"剩余数量",@"剩余金额"]
                 andObjects:dataArray withTags:@[@"productNo",@"productName",@"productSurPlusNumDisplay",@"productSurplusPriceDisplay"]];
    }
    
    if (dataArray == nil || dataArray.count == 0) {
        productSurplusPriceTotal = [NSNumber numberWithDouble:0];
    } else {
        if (productSurplusPriceTotal == nil) {
            productSurplusPriceTotal = [NSNumber numberWithDouble:0];
        }
    }
    // 总计
    NSNumberFormatter *productSurplusPriceFormatter =[[NSNumberFormatter alloc]init];
    productSurplusPriceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    [productSurplusPriceFormatter setPositiveFormat:@"#0.00"];
    NSString *productSurplusPriceTotalStr = [productSurplusPriceFormatter stringFromNumber:productSurplusPriceTotal];
    NSString *content = @"总计:";
    content = [content stringByAppendingString:productSurplusPriceTotalStr];
    NSMutableAttributedString *attributedString  = [[NSMutableAttributedString alloc] initWithString: content];
    NSDictionary * attriBute3 = @{NSForegroundColorAttributeName:UIColor.redColor ,NSFontAttributeName:[UIFont systemFontOfSize:17]};
    [attributedString addAttributes:attriBute3 range:NSMakeRange(3, [productSurplusPriceTotalStr length])];
    statustucsSurplusPriceTotal.attributedText = attributedString;
    
    selectOrderDoc = [[OrderDoc alloc] init];
}

@end


