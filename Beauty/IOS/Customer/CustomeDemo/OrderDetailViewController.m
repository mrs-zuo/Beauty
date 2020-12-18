//
//  OrderConfirmViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "ContactDetailViewController.h"
#import "TreatmentDetailViewController.h"
#import "EffectDisplayViewController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "OrderDateCell.h"
#import "OrderDoc.h"
#import "ServiceDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDoc.h"
#import "CourseDoc.h"
#import "ContactDoc.h"
#import "ProductAndPriceView.h"
#import "PayInfoViewController.h"

@interface OrderDetailViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderDetailOperation;
@property (nonatomic) ProductAndPriceView *productAndPriceView;
@property (nonatomic) ContactDoc *contactDoc_Selected;
@property (nonatomic) TreatmentDoc *treatmentDoc_Selected;
@end

@implementation OrderDetailViewController
@synthesize orderDoc;
@synthesize contactDoc_Selected, treatmentDoc_Selected;
@synthesize productAndPriceView;
@synthesize type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_BackgroundView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestGetScheduleList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(-5.0f, 41.0f, 330.0f, kSCREN_BOUNDS.size.height - 88.0f);
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [_tableView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 88.0f)];
    }
    
    TitleView *titleView = [[TitleView alloc] init];
    [self.view addSubview:[titleView getTitleView:@"订单详情（）"]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderDetailOperation || [_requestGetOrderDetailOperation isExecuting]) {
        [_requestGetOrderDetailOperation cancel];
        _requestGetOrderDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 + [orderDoc.courseArray count] + ([orderDoc.contractArray count]> 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) { // 时间section
        return 1;
    } else if (section ==  1+ [orderDoc.courseArray count] + ([orderDoc.contractArray count]> 0 ? 1 : 0)) { // 订单状态setion
        return 1;
    } else if (section == [orderDoc.courseArray count] + 1) { // 联系section
        return [orderDoc.contractArray count] + 1;
    } else { // 课程section
        CourseDoc *tmpCourse = [orderDoc.courseArray objectAtIndex:section - 1];
        return [tmpCourse.groupOrTreatmentArray count] + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // 时间section
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        [cell.titleLabel setText:@"时间"];
        [cell.valueText setText:orderDoc.order_OrderTime];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setAccessoryText:@""];
        return cell;
    } else if (indexPath.section ==  1+ [orderDoc.courseArray count] + ([orderDoc.contractArray count] > 0 ? 1 : 0)) { // 订单状态section
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        [cell.titleLabel setText:@"订单状态"];
        [cell.valueText setText:orderDoc.order_StatusStr];
        if ([orderDoc.order_StatusStr isEqualToString:@"未支付"]) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.valueText setFrame:CGRectMake(105.0f, kTableView_HeightOfRow/2 - 30.0f/2, 180, 30.0f)];
        }
        return cell;
    } else if (indexPath.section == [orderDoc.courseArray count] + 1 ) { // 联系section
        if (indexPath.row == 0) {
            NormalEditCell *normalCell = [self configNormalEditCell:tableView indexPath:indexPath];
            [normalCell.titleLabel setText:@"联系"];
            [normalCell.valueText setText:@""];
            return normalCell;
        } else {
            OrderDateCell *dateCell = [self configOrderDateCell:tableView indexPath:indexPath];
            ContactDoc *contactDoc = [orderDoc.contractArray objectAtIndex:indexPath.row - 1];
            [dateCell updateData:contactDoc.cont_Schedule mode:OrderDateCellModeDisplayContact];
            return dateCell;
        }
    } else {
        CourseDoc *courseDoc = [orderDoc.courseArray objectAtIndex:indexPath.section - 1];
        if (indexPath.row < 2) {
            NormalEditCell *normalCell = [self configNormalEditCell:tableView indexPath:indexPath];
            if (indexPath.row == 0) {
                [normalCell.titleLabel setText:[NSString stringWithFormat:@"课程%ld", (long)indexPath.section]];
                [normalCell.valueText setText:[NSString stringWithFormat:@"%lu", (unsigned long)[courseDoc.groupOrTreatmentArray count]]];
                [normalCell setAccessoryText:@"次"];
                [normalCell setAccessoryType:UITableViewCellAccessoryNone];
                [normalCell.valueText setFrame:CGRectMake(100.0f, kTableView_HeightOfRow/2 - 30.0f/2, 180, 30.0f)];
            } else if (indexPath.row == 1){
                [normalCell.titleLabel setText:@"服务人员"];
                [normalCell.valueText setText:courseDoc.course_AccountName];
                [normalCell setAccessoryText:@""];
            }
            return normalCell;
        } else {
            OrderDateCell *dateCell = [self configOrderDateCell:tableView indexPath:indexPath];
            TreatmentDoc *treatmentDoc = [courseDoc.groupOrTreatmentArray objectAtIndex:indexPath.row - 2];
            [dateCell updateData:treatmentDoc.schedule mode:OrderDateCellModeDisplayCourse];
            return dateCell;
        }
    }
}

// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditCell";
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
    return cell;
}

// 配置OrderDateCell
- (OrderDateCell *)configOrderDateCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderDateCell";
    OrderDateCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderDateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.section == [orderDoc.courseArray count] + 1) {
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    } else {
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)(indexPath.row -1)];
    }
    cell.timeText.userInteractionEnabled = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    }
    if (section == 1 && orderDoc.productAndPriceDoc) {
        return orderDoc.productAndPriceDoc.table_Height;
    }
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1 && orderDoc.productAndPriceDoc ) {
        productAndPriceView = [[ProductAndPriceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, orderDoc.productAndPriceDoc.table_Height)];
        [productAndPriceView setTheProductAndPriceDoc:orderDoc.productAndPriceDoc];
        return productAndPriceView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((indexPath.section ==  1+ [orderDoc.courseArray count] + ([orderDoc.contractArray count]> 0 ? 1 : 0)) && orderDoc.order_Status == 0){
        CGFloat totalPrice = 0.0f;
        CGFloat totalSalePrice = 0.0f;
        
        ProductAndPriceDoc *productAndPriceDoc = orderDoc.productAndPriceDoc;
        totalPrice += productAndPriceDoc.totalMoney;
        totalSalePrice += productAndPriceDoc.discountMoney;
        
        NSMutableArray *orderArray_Selected = [[NSMutableArray alloc] initWithObjects:orderDoc, nil];
        
        PayInfoViewController *payInfoController = (PayInfoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PayInfoViewController"];
        payInfoController.totalMoney = totalPrice;
        payInfoController.favorable = totalSalePrice;
        payInfoController.orderNumbers = 1;
        payInfoController.paymentOrderArray = orderArray_Selected;
        [self.navigationController pushViewController:payInfoController animated:YES];
    } else if (indexPath.section ==  1 + [orderDoc.courseArray count]){
        if (indexPath.row > 0) {
            contactDoc_Selected = [orderDoc.contractArray objectAtIndex:indexPath.row - 1];
            [self performSegueWithIdentifier:@"goContactDetailViewFromOrderDetailView" sender:self];
        }
    } else {
        if (indexPath.row > 1) {
            CourseDoc *couse = [orderDoc.courseArray objectAtIndex:indexPath.section - 1];
            treatmentDoc_Selected = [couse.groupOrTreatmentArray objectAtIndex:indexPath.row - 2];
            [self performSegueWithIdentifier:@"goOrderTabBarFromOrderDetailView" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goContactDetailViewFromOrderDetailView"]) {
        ContactDetailViewController *contactController = segue.destinationViewController;
        contactController.contactDoc = contactDoc_Selected;
    } else if ([segue.identifier isEqualToString:@"goOrderTabBarFromOrderDetailView"]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
        treatmentDetailViewController.treatmentDoc = treatmentDoc_Selected;
        
        EffectDisplayViewController *effectDosplayeController = [tabBarController.viewControllers objectAtIndex:1];
        effectDosplayeController.treat_ID = treatmentDoc_Selected.treat_ID;
    }
}
#pragma mark - 接口

// 获取Schudle列表
- (void)requestGetScheduleList
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    _requestGetOrderDetailOperation = [[GPHTTPClient shareClient] requestOrderDetailByOrderId:orderDoc.order_ID andProductType:type success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
            // --Course
            NSMutableArray *tmpCourseArray = [NSMutableArray array];
            for (GDataXMLElement *course in [contentData elementsForName:@"Course"]) {
                CourseDoc *tempCourse = [[CourseDoc alloc] init];
                tempCourse.ctlFlag = 2;
                tempCourse.course_ID = [[[[course elementsForName:@"CourseID"] objectAtIndex:0] stringValue] integerValue];
                tempCourse.course_AccountID = [[[[course elementsForName:@"ExecutorID"] objectAtIndex:0] stringValue] integerValue];
                tempCourse.course_AccountName = [[[course elementsForName:@"ExecutorName"] objectAtIndex:0] stringValue];
                NSMutableArray *tmpTreatmentArray = [NSMutableArray array];
                for (GDataXMLElement *treatment in [course elementsForName:@"Treatment"]) {
                    TreatmentDoc *treat = [[TreatmentDoc alloc] init];
                    [treat setTreat_ID:[[[[treatment elementsForName:@"TreatmentID"] objectAtIndex:0] stringValue] integerValue]];
                    [treat setTreat_Remark:[[[treatment elementsForName:@"Remark"] objectAtIndex:0] stringValue]];
                    
                    ScheduleDoc *sch = [[ScheduleDoc alloc] init];
                    [sch setSch_ID:[[[[treatment elementsForName:@"ScheduleID"] objectAtIndex:0] stringValue] integerValue]];
                    [sch setSch_Completed:[[[[treatment elementsForName:@"IsCompleted"] objectAtIndex:0] stringValue] intValue]];
                    [sch setSch_ScheduleTime:[[[treatment elementsForName:@"Time"] objectAtIndex:0] stringValue]];
                    [sch setSch_ImageCnt:[[[[treatment elementsForName:@"ImageCount"] objectAtIndex:0] stringValue] intValue]];
                    [sch setSch_RemarkCnt:[treat.treat_Remark length] > 0 ? 1 : 0];
                    [treat setSchedule:sch];
                    [tmpTreatmentArray addObject:treat];
                }
                [tempCourse setGroupOrTreatmentArray:tmpTreatmentArray];
                [tmpCourseArray addObject:tempCourse];
            }
            [orderDoc setCourseArray:tmpCourseArray];
            
            // --Contact
            NSMutableArray *tmpContactArray = [NSMutableArray array];
            for (GDataXMLElement *contact in [contentData elementsForName:@"Contact"]) {
                ContactDoc *tmpContact = [[ContactDoc alloc] init];
                [tmpContact setCont_ID:[[[[contact elementsForName:@"ContactID"] objectAtIndex:0] stringValue] integerValue]];
                [tmpContact setCont_Remark:[[[contact elementsForName:@"Remark"] objectAtIndex:0] stringValue]];
                
                ScheduleDoc *sch = [[ScheduleDoc alloc] init];
                [sch setSch_ID:[[[[contact elementsForName:@"ScheduleID"] objectAtIndex:0] stringValue] integerValue]];
                [sch setSch_ScheduleTime:[[[contact elementsForName:@"Time"] objectAtIndex:0] stringValue]];
                [sch setSch_Completed:[[[[contact elementsForName:@"IsCompleted"] objectAtIndex:0] stringValue] integerValue]];
                [tmpContact setCont_Schedule:sch];
                [tmpContactArray addObject:tmpContact];
            }
            [orderDoc setContractArray:tmpContactArray];
            [_tableView reloadData];
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

@end
