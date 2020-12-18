//
//  OrderDetailAboutCommodityViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderDetailAboutCommodityViewController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "OrderDoc.h"
#import "ProductAndPriceDoc.h"
#import "CommodityDoc.h"
#import "OneLabelCell.h"
#import "TwoLabelCell.h"
#import "UILabelStrikeThrough.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "PayInfoDoc.h"
#import "ZWJson.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "OrderPaymentDetailViewController.h"
#define kColorNewLightBrown [UIColor colorWithRed:213.0/255.0f green:197.0f/255.0f blue:181.0f/255.0f alpha:1.0f]

#define OrderPaymentStatus (self.orderDetail.PaymentStatus == 2 || self.orderDetail.PaymentStatus == 3)

#import "OrderDetailModel.h"
#import "OrderDetailCell.h"
#import "Treatments.h"
#import "OrderProgressCell.h"

@interface OrderDetailAboutCommodityViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderDetailAboutCommodityOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCancelOrderOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetTreatGroupByOrderObjectID;
@property (nonatomic ,retain) UIButton *footerButton;
@property (nonatomic ,retain) UIView *footerView;
@property (nonatomic, copy) NSMutableArray *payment_Info;
@property (strong, nonatomic)NSMutableArray *getTreatGroupArray;
@property (nonatomic, strong) OrderDetailModel *orderDetail;
@property (nonatomic, assign) BOOL isRefresh;
@end

@implementation OrderDetailAboutCommodityViewController
@synthesize orderDoc;
@synthesize footerButton;
@synthesize footerView;
@synthesize payment_Info;

- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
     payment_Info = [[NSMutableArray alloc] init];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 44);
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 312.0f, 60.0f)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:footerView];
    footerButton = [UIButton buttonWithTitle:@""
                                      target:self
                                    selector:@selector(cancelOrderAction)
                                       frame:CGRectMake(10.0f, 10.0f, kSCREN_BOUNDS.size.width - 10, 36.0f)
                               backgroundImg:[UIImage imageNamed:@"order_cancel"]
                            highlightedImage:nil];
    footerButton.tag = 100;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [footerButton setFrame:CGRectMake(1.0f, 10.0f, kSCREN_BOUNDS.size.width - 10, 36.0f)];
    }
    [self.tableView registerClass:[OrderDetailCell class] forCellReuseIdentifier:@"CommDetailCell"];
    [self.tableView registerClass:[OrderProgressCell class] forCellReuseIdentifier:@"CommProgressCell"];
    
    self.title = @"订单详情（商品)";
    self.isRefresh = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    orderDoc.productAndPriceDoc.commodityArray = nil;
    if (self.isRefresh) {
        [self requestGetOrderDetailAboutCommodityListByJson];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
   
    if (_requestGetOrderDetailAboutCommodityOperation || [_requestGetOrderDetailAboutCommodityOperation isExecuting]) {
        [_requestGetOrderDetailAboutCommodityOperation cancel];
        _requestGetOrderDetailAboutCommodityOperation = nil;
    }
    
    if (_requestCancelOrderOperation || [_requestCancelOrderOperation isExecuting]) {
        [_requestCancelOrderOperation cancel];
        _requestCancelOrderOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isRefresh = NO;
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.orderDetail.isShowFirst)
            return 4;
        else
            return 1;
    } else if (section == 1) {
        if (self.orderDetail.isShowSecond) {
            if (self.orderDetail.TotalSalePrice == self.orderDetail.TotalCalcPrice) {
                return 4;
            } else {
                return 5;
            }
        }
        else
            return 1;
    } else if (section == 2) {//订单状态
        if (OrderPaymentStatus) {
            return 2;
        }
        return 1;
    } else if (section == 3) {//订单进度
        if (self.orderDetail.GroupList.count == 0 ) {
            return 1;
        } else {
            return self.orderDetail.groupCount + 1;
        }
    } else if (section == 4) { //完成
        if (self.orderDetail.FinishedCount == 0 ) {
            return 0;
        } else {
            if (self.orderDetail.isShowCompletion) {
                return self.orderDetail.completionCount + 1 ;
            } else {
                return 1;
            }
        }
    } else { //备注
//        if (self.orderDetail.Remark.length > 0) {
//            return 2;
//        } else {
            return 0;
//        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSIndexPath *)computeOrderProgressIndexPath:(NSIndexPath *)indexPath type:(NSInteger)type
{
    __block NSInteger indexRow = indexPath.row - 1;
    __block NSIndexPath *progressIndexPath = nil;
    // type == 0 计算订单进度  type == 1 计算已完成的小单
    if (type == 0) {
        [self.orderDetail.GroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            if (indexRow - obj.treatCount < 0) {
                progressIndexPath = [NSIndexPath indexPathForRow:indexRow inSection:idx];
            } else {
                indexRow -= obj.treatCount;
            }
        }];
    } else {
        [self.orderDetail.CompletionGroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            if (indexRow - obj.treatCount < 0) {
                progressIndexPath = [NSIndexPath indexPathForRow:indexRow inSection:idx];
            } else {
                indexRow -= obj.treatCount;
            }
        }];
    }
    return progressIndexPath;
}

- (void)setCellSpearatorInsetOfCell:(UITableViewCell *)cell separtorInset:(UIEdgeInsets)separaInsets
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:separaInsets];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * identifier = [NSString stringWithFormat:@"detailCell_%@",indexPath];
    
    OrderDetailCell *detailCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (detailCell == nil) {
        detailCell = [[OrderDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    detailCell.accessoryView = nil;
    detailCell.accessoryType = UITableViewCellAccessoryNone;
    detailCell.textLabel.textColor = kColor_TitlePink;
    detailCell.textLabel.numberOfLines = 1;
    detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    OrderProgressCell *progressCell = [self.tableView dequeueReusableCellWithIdentifier:@"CommProgressCell"];

    [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsZero];
    progressCell.accessoryView = nil;
    progressCell.accessoryType = UITableViewCellAccessoryNone;
    progressCell.textLabel.textColor = kColor_TitlePink;
    progressCell.textLabel.numberOfLines = 1;
    progressCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView * downImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, (kTableView_DefaultCellHeight-15)/2, 20, 15)];
    downImage.tag = indexPath.section +1000;
    [detailCell.contentView addSubview:downImage];

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                detailCell.textLabel.text = @"订单编号";
                detailCell.detailLabel.frame = CGRectMake(160, 15, 130, kLabel_DefaultHeight);
                detailCell.detailLabel.text = self.orderDetail.OrderNumber;
                UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
                image.image = [UIImage imageNamed:self.orderDetail.isShowFirst ? @"jiantous.png" : @"jiantoux.png"];
                [detailCell.contentView addSubview:image];
            }
                break;
            case 1:
                detailCell.textLabel.text = @"下单门店";
                detailCell.detailTextLabel.text = self.orderDetail.BranchName;
                break;
            case 2:
                detailCell.textLabel.text = @"下单时间";
                detailCell.detailTextLabel.text = self.orderDetail.OrderTime;
                break;
            case 3:
                detailCell.textLabel.text = @"美丽顾问";
                detailCell.detailTextLabel.text = self.orderDetail.ResponsiblePersonName;
                
                break;
        }
        return detailCell;
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                detailCell.textLabel.text = self.orderDetail.ProductName;
                detailCell.detailTextLabel.text = @"";
                UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
                image.image = [UIImage imageNamed:self.orderDetail.isShowSecond ? @"jiantous.png" : @"jiantoux.png"];
                [detailCell.contentView addSubview:image];
            }
                break;
            case 1:
                detailCell.textLabel.text = @"数量";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.orderDetail.Quantity];
                break;
            case 2:
                detailCell.textLabel.text = @"原价小计";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalOrigPrice];
                break;
            case 3:
                detailCell.textLabel.text = @"会员价";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalCalcPrice];
                break;
            case 4:
                detailCell.textLabel.text = @"成交价";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalSalePrice];
                break;
        }
        return detailCell;
    }
    
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                detailCell.textLabel.text = @"订单状态";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@|%@",self.orderDetail.progressStatus, self.orderDetail.payStatus];
                break;
            case 1:
                detailCell.textLabel.text = @"支付详情";
                detailCell.detailTextLabel.text = @"";
                detailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
        }
        return detailCell;
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = self.orderDetail.orderProgressInfo;
            detailCell.detailTextLabel.text = [NSString stringWithFormat:@"剩余%ld件", (long)self.orderDetail.SurplusCount];
            return detailCell;
        } else {
            NSIndexPath *progressIndexPath = [self computeOrderProgressIndexPath:indexPath type:0];
            
            TreatmentGroup *treatGroup = [self.orderDetail.GroupList objectAtIndex:progressIndexPath.section];
            if (progressIndexPath.row == 0) {
                //时间  状态|数量
                progressCell.textLabel.text = treatGroup.StartTime;
                progressCell.detailTextLabel.text = [NSString stringWithFormat:@"%@|%ld件",[OrderDetailModel orderProgressStatus:treatGroup.Status], (long)treatGroup.Quantity];
                
                [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                
            } else if (progressIndexPath.row == 1) {
                //服务顾问 姓名
                progressCell.textLabel.text = @"服务顾问";
                progressCell.detailTextLabel.text = treatGroup.ServicePicName;
            }
            return progressCell;
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = @"已交付商品记录";
            detailCell.detailTextLabel.text = @"";
            UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
            image.image = [UIImage imageNamed:self.orderDetail.isShowCompletion ? @"jiantous.png" : @"jiantoux.png"];
            [detailCell.contentView addSubview:image];
            
            return detailCell;
        } else {
            NSIndexPath *progressIndexPath = [self computeOrderProgressIndexPath:indexPath type:1];
            
            TreatmentGroup *treatGroup = [self.orderDetail.CompletionGroupList objectAtIndex:progressIndexPath.section];
            if (progressIndexPath.row == 0) {
                //时间  状态
                progressCell.textLabel.text = treatGroup.StartTime;
                progressCell.detailTextLabel.text = [NSString stringWithFormat:@"%@|%ld件",[OrderDetailModel orderProgressStatus:treatGroup.Status], (long)treatGroup.Quantity];
                [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
            } else if (progressIndexPath.row == 1) {
                progressCell.textLabel.text = @"服务顾问"; //.length == 0 ? @"服务操作" : treatGroup.ServicePicName
                progressCell.detailTextLabel.text = treatGroup.ServicePicName;
            }
            return progressCell;
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = @"备注";
            detailCell.detailTextLabel.text = @"";
        } else {
            detailCell.textLabel.text = self.orderDetail.Remark;
            detailCell.detailTextLabel.text = @"";
            detailCell.textLabel.numberOfLines = 0;
            detailCell.textLabel.textColor = kColor_Black;

        }
        return detailCell;
    }
    return detailCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 5 && indexPath.row == 1)
    {
        return self.orderDetail.remarkHeight;
    }
    return kTableView_DefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section >= 3){
        return 0.00001;
    }else{
        return kTableView_Margin_Bottom;
    }
}

- (void)changeOrderPayStatus:(id)sender
{
    
}

- (void)goToThePayHistory
{
    OrderPaymentDetailViewController    *detailCon = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderPaymentDetailViewController"];
    detailCon.orderID = self.orderDetail.OrderID;
    detailCon.totalMoney = orderDoc.order_TotalSalePrice;
    [self.navigationController pushViewController:detailCon animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.hidesBottomBarWhenPushed = YES;

    if (indexPath.section == 0 && indexPath.row == 0) {
        self.orderDetail.isShowFirst = !self.orderDetail.isShowFirst;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        self.orderDetail.isShowSecond = !self.orderDetail.isShowSecond;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self goToThePayHistory];
    }

    if (indexPath.section == 4 && indexPath.row == 0 ) {
        self.orderDetail.isShowCompletion = !self.orderDetail.isShowCompletion;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Cancel
- (void)cancelOrderAction
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定取消订单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestCancelOrder];
        }
    }];
}

#pragma mark - 接口
- (void)requestGetOrderDetailAboutCommodityListByJson
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    NSDictionary *para = @{@"OrderObjectID":@(orderDoc.order_ObjectID),
                           @"ProductType":@(orderDoc.order_Type)};
    _requestGetOrderDetailAboutCommodityOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderDetail"  showErrorMsg:YES  parameters:para
    WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.orderDetail = [[OrderDetailModel alloc] initWithDic:data];
            [self getTreatGroupByOrderObjectID];
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            [self popViewController];
        }];

    } failure:^(NSError *error) {
    }];
}

- (void)requestCancelOrder
{
    [SVProgressHUD  showWithStatus:@"Loading"];

    NSDictionary *para = @{@"UpdaterID":@(CUS_CUSTOMERID),
                           @"OrderID":@(orderDoc.order_ID),
                           @"CustomerID":@(CUS_CUSTOMERID)};
    _requestCancelOrderOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/order/DeleteOrder"  showErrorMsg:YES  parameters:para
     WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:NO
        success:^(id data, NSInteger code, id message) {
            orderDoc.order_Status = 2;
            UIButton *button = (UIButton *)[footerView viewWithTag:100];
            [button removeFromSuperview];
            [_tableView reloadData];
            [SVProgressHUD showSuccessWithStatus2:[message length] > 0 ? message:@"订单取消成功！"];
        } failure:^(NSInteger code, NSString *error) {
            if (code == -1)
                [SVProgressHUD showErrorWithStatus2:[error length] > 0 ? error:@"订单取消失败！"];
            else if (code == 0)
                [SVProgressHUD showErrorWithStatus2:[error length] > 0 ? error:@"订单已完成或已取消！"];
        }];

    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


-(void)popViewController
{
    double delayInSeconds = 1.f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)getTreatGroupByOrderObjectID
{
    [SVProgressHUD  showWithStatus:@"Loading"];
   
    NSDictionary *para = @{@"OrderObjectID":@(orderDoc.order_ObjectID),
                          @"ProductType":@(orderDoc.order_Type),
                           @"Status":@(-1)};
    
    _requestGetTreatGroupByOrderObjectID = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetTreatGroupByOrderObjectID" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
       
        [ZWJson parseJson:json showErrorMsg:NO
                  success:^(id data, NSInteger code, id message) {
                      NSMutableArray *array = [NSMutableArray array];
                      [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                          [array addObject:[[TreatmentGroup alloc] initWithDic:obj]];
                      }];
                      self.orderDetail.CompletionGroupList = [array copy];
                      [_tableView reloadData];
                      [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
       
    }];
}
@end
