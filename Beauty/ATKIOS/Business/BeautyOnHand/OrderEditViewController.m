//
//  OrderConfirmViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-11.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderEditViewController.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"
#import "NumberEditCell.h"
#import "OrderDoc.h"
#import "ServiceDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDoc.h"
#import "ProductAndPriceView.h"
#import "CourseDoc.h"
#import "ContactDoc.h"
#import "DEFINE.h"
#import "OrderListViewController.h"
#import "NavigationView.h"
#import "CusTabBarController.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "OpportunityDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"

#import "OrderTreatmentCell.h"
#import "OrderContactCell.h"
#import "GPBHTTPClient.h"

@interface OrderEditViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddOrderOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateOrderOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDeleteOrderOperation;

@property (strong, nonatomic) ProductAndPriceView *productAndPriceView;

@property (assign, nonatomic) CGFloat tableView_Height;
@property (strong, nonatomic) NSIndexPath *indexPath_Selected;

@property (nonatomic) NSDate *currentDate;        // 记录进入该页面时的时间
@property (nonatomic) NSDictionary *accountsDic;  // 服务人员信息(accountId && accountName)

// theCourseArray保存NSMutableArray集合,而NSMutableArray保存着TreatmentDoc集合(而非Course集合) --保存显示treatDoc对象的数据
// theDataArray中的treatDoc对象与theOrderDoc中的course中的treatDoc地址相同
@property (nonatomic) NSMutableArray *theDataArray;

// --保存显示页面course对象除treatArray外的数据
//  theCourseArray中的course对象 与theOrderDoc对象中course对象地址相同 两者的treatArray地址也相同(两数组的count相同) so不能显示treatDoc数据
@property (nonatomic) NSMutableArray *theCourseArray;
@property (nonatomic) NSMutableArray *theContactArray;  // theContactArray保存ContactDoc集合 保存着页面显示的contact数据


@end

@implementation OrderEditViewController
@synthesize theOrderDoc;
@synthesize tableView_Height;
@synthesize indexPath_Selected;
@synthesize theDataArray, theCourseArray, theContactArray;
@synthesize currentDate;
@synthesize accountsDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestAddOrderOperation && [_requestAddOrderOperation isExecuting]) {
        [_requestAddOrderOperation cancel];
    }
    
    if (_requestUpdateOrderOperation && [_requestUpdateOrderOperation isExecuting]) {
        [_requestUpdateOrderOperation cancel];
    }
    
    if (_requestDeleteOrderOperation && [_requestDeleteOrderOperation isExecuting]) {
        [_requestDeleteOrderOperation cancel];
    }
    _requestAddOrderOperation = nil;
    _requestUpdateOrderOperation = nil;
    _requestDeleteOrderOperation = nil;

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    
    currentDate = [NSDate date];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)    name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowAndHide:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowAndHide:) name:UIKeyboardDidHideNotification object:nil];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initTableView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑订单详情"];
    [self.view addSubview:navigationView];

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    tableView_Height = kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f;
    
  //  ProductDoc *productDoc = (ProductDoc *)[theOrderDoc.productAndPriceDoc.productArray firstObject];
    
    if (theOrderDoc.order_Ispaid == 0) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self
                                                          submitImg:nil
                                                       submitAction:@selector(submitOrderAction)
                                                          deleteImg:nil
                                                       deleteAction:@selector(deleteAction)];
        [footerView showInTableView:_tableView];
    } else if(theOrderDoc.order_Ispaid == 1) {
        FooterView *footerView = [[FooterView alloc] initWithTarget:self
                                                          submitImg:[UIImage imageNamed:@"buttonLong_Confirm"]
                                                        submitTitle:@""
                                                       submitAction:@selector(submitOrderAction)];
        [footerView showInTableView:_tableView];
    }
}

#pragma mark - Setting Method

- (void)setTheOrderDoc:(OrderDoc *)orderDoc
{
    theOrderDoc = orderDoc;
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (CourseDoc *course in theOrderDoc.courseArray) {
        [tmpArray addObject:[course.treatmentArray mutableCopy]];
    }
    theContactArray = [theOrderDoc.contractArray mutableCopy];
    theCourseArray  = [theOrderDoc.courseArray mutableCopy];
    theDataArray  = tmpArray;

}

#pragma mark - Public Method

//- (void)keyboardShowAndHide:(NSNotification *)notification
//{
//    if (notification.name == UIKeyboardDidShowNotification) {
//        canSelectRowInProductAndPriceView = NO;
//    } else if (notification.name == UIKeyboardDidHideNotification) {
//        canSelectRowInProductAndPriceView = YES;
//    }
//}

- (void)dismissKeyBoard
{
    CGRect rect = _tableView.frame;
    if (rect.size.height != tableView_Height)
    {
        rect.size.height = tableView_Height;
        _tableView.frame = rect;
    }
    [_productAndPriceView dismissKeyboard];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect;
    NSValue *keyboardValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    [keyboardValue getValue:&keyboardRect];
    
    
    NSValue *animationDurationValue = [notification userInfo][UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    float off_Y = tableView_Height - keyboardRect.size.height + 50;
    CGRect rect = _tableView.frame;
    rect.size.height = off_Y;
    
    [UIView beginAnimations:@"showKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    _tableView.frame = rect;
    [UIView commitAnimations];
    
    [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    UIView *view = nil;
    if ((IOS6 || IOS8)) {
        view = touch.view.superview;
    } else {
        view = touch.view.superview.superview;
    }
   
    if ([view isKindOfClass:[UITableViewCell class]] ) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 0) {
        return 3 + [theCourseArray count] + 1;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)  // 时间section
        return 2;
     else if (section == 1)
        return 2;
    else if (section == 2)
        return 2;
    else if (section == [theCourseArray count] + 3 ) // 联系section
    {
        return [theContactArray count] + 2;
    }
    else  // 课程section
    {
        NSArray *treatmentArray = [theDataArray objectAtIndex:section - 3];
        return [treatmentArray count] + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)  // 时间section
    {
        switch (indexPath.row) {
            case 0:
            {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];  // 不可编辑 无单位
                cell.titleLabel.text = @"下单时间";
                cell.valueText.text = theOrderDoc.order_OrderTime;
                [cell setAccessoryText:@""];
                return cell;
            } break;
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];  // 不可编辑 无单位
                cell.titleLabel.text = @"顾客";
                cell.valueText.text  = theOrderDoc.order_CustomerName;
                [cell setAccessoryText:@""];
                 return cell;
            } break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];  // 不可编辑 无单位
                cell.titleLabel.text = @"创建人";
                cell.valueText.text = theOrderDoc.order_CreatorName;
                [cell setAccessoryText:@""];
                return cell;
            } break;
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath]; // 可编辑 无单位
                [cell.titleLabel setText:@"美丽顾问"];
                [cell.valueText setText:theOrderDoc.order_ResponsiblePersonName];
                [cell.valueText setPlaceholder:@"请选择美丽顾问"];
                [cell.valueText setTextColor:kColor_Editable];
                cell.userInteractionEnabled = YES;
                [cell setAccessoryText:@""];
                return cell;
            } break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                UISwitch *swith = nil;
                UILabel *stateLabel = nil;
                if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 0) {
                    if (IOS6) {
                        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0f, 4.0f, 60.0f, 30.0f)];
                    } else if(IOS7) {
                        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0f, 4.0f, 60.0f, 30.0f)];
                    } else {
                        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0f, 4.0f, 60.0f, 30.0f)];
                    }
                    stateLabel.font = kFont_Light_16;
                    stateLabel.textColor = [UIColor blackColor];
                    stateLabel.textAlignment = NSTextAlignmentRight;
                    stateLabel.text = theOrderDoc.order_StatusStr;
                } else {
                    if (IOS7) {
                        swith = [[UISwitch alloc] initWithFrame:CGRectMake(255.0f, 4.0f, 40.0f, 30.0f)];
                    } else if (IOS6) {
                        swith = [[UISwitch alloc] initWithFrame:CGRectMake(235.0f, 4.0f, 40.0f, 30.0f)];
                    } else {
                        swith = [[UISwitch alloc] initWithFrame:CGRectMake(255.0f, 4.0f, 40.0f, 30.0f)];
                    }
                    swith.transform = CGAffineTransformMakeScale(0.8, 0.8);
                    swith.on = theOrderDoc.order_Status;
                    swith.userInteractionEnabled = YES;
                    
                    [swith addTarget:self action:@selector(changeOrderStatusAction:) forControlEvents:UIControlEventValueChanged];
                }
                
                static NSString *cellIndentify = @"cell_orderStatus";
                NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.backgroundColor = [UIColor whiteColor];
                    if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 0) {
                        [cell.contentView addSubview:stateLabel];
                    } else {
                        [cell.contentView addSubview:swith];
                    }
                    
                }
                [cell.valueText setHidden:YES];
                [cell.accessoryLabel setHidden:YES];
                
                cell.titleLabel.text = @"完成状态";
           
                return cell;
            } break;
            case 1:
            {
                NormalEditCell *cell = [self configNormalEditCell2:tableView indexPath:indexPath];  // 不可编辑 无单位
                cell.titleLabel.text = @"支付状态";
                cell.valueText.text  = theOrderDoc.order_IspaidStr;
                [cell setAccessoryText:@""];
                return cell;
            } break;
        }
    } else if (indexPath.section == [theCourseArray count] + 3 )  // 联系section
    {
        if (indexPath.row == 0) {
            NormalEditCell *normalCell2 = [self configNormalEditCell2:tableView indexPath:indexPath];  // 不可编辑  无单位
            [normalCell2.titleLabel setText:@"联系"];
            [normalCell2.valueText setText:nil];
            [normalCell2 setAccessoryText:nil];
            [normalCell2.valueText setPlaceholder:nil];
            return normalCell2;
        } else if (indexPath.row == [theContactArray count] + 1) {
            OrderAddCell *orderAddCell = [self configOrderAddCell:tableView indexPath:indexPath];
            orderAddCell.promptLabel.text = @"添加新的联系时间";
            return orderAddCell;
        } else {
            ContactDoc *contactDoc = [theContactArray objectAtIndex:indexPath.row - 1];
            
            OrderContactCell *cell = [self configOrderContactCell:tableView indexPath:indexPath];
            cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
            [cell updateData:contactDoc canEdited:YES];
            return cell;
        }
    }
    else  // 课程section
    {
        NSArray *treatmentArray = [theDataArray objectAtIndex:indexPath.section - 3];
        if (indexPath.row == 0)
        {
            NormalEditCell *normalCell2 = [self configNormalEditCell2:tableView indexPath:indexPath]; // 有单位  不可编辑
            [normalCell2.titleLabel setText:[NSString stringWithFormat:@"课程%ld", (long)(indexPath.section - 2)]];
            [normalCell2.valueText setText:[NSString stringWithFormat:@"%lu次",  (unsigned long)[treatmentArray count]]];
            [normalCell2 setAccessoryText:@""];
            return normalCell2;
        }
        else if (indexPath.row == [treatmentArray count] + 1)
        {
            OrderAddCell *orderAddCell = [self configOrderAddCell:tableView indexPath:indexPath];
            orderAddCell.promptLabel.text = @"添加新的服务时间";
            return orderAddCell;
        }
        else
        {
            OrderTreatmentCell *cell = [self configOrderTreatmentCell:tableView indexPath:indexPath];
            TreatmentDoc *treatmentDoc = [treatmentArray objectAtIndex:indexPath.row - 1];
            if(treatmentDoc.treat_Schedule.sch_Completed == 0){
                [cell updateData:treatmentDoc canEdited:YES];
            } else {
                [cell updateData:treatmentDoc canEdited:NO];
            }
            

            return cell;
        }
    }
    return nil;
}

- (void)changeOrderStatusAction:(UISwitch *)swith
{
    NSLog(@"%d", swith.on);
    
    if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 0) {
        theOrderDoc.order_Status = swith.on;
    } else {
        if (swith.on == 0) {
            theOrderDoc.order_Status = swith.on;
        }
        if (swith.on == 1) {
            theOrderDoc.order_Status = 3;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        if (theOrderDoc.productAndPriceDoc) {
            return theOrderDoc.productAndPriceDoc.table_Height;
        }
    }
    return kTableView_Margin_Bottom;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        if (theOrderDoc.productAndPriceDoc) {
            _productAndPriceView = [[ProductAndPriceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, theOrderDoc.productAndPriceDoc.table_Height)];
            _productAndPriceView.theProductAndPriceDoc = theOrderDoc.productAndPriceDoc;
            _productAndPriceView.canEditeQuantityAndPrice = NO;
            return _productAndPriceView;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 课程section时间
    if (indexPath.section > 2 && indexPath.section < [theOrderDoc.courseArray count] + 3) {
        if (indexPath.row == 0) return;
        
        NSArray *treatArray = [theDataArray objectAtIndex:indexPath.section - 3];
        if (indexPath.row == [treatArray count] + 1) return; // 最后一行
        
        TreatmentDoc *treatmentDoc = [treatArray objectAtIndex:indexPath.row - 1];
        
        WorkSheetViewController *workSheetVC = nil;
        if (treatmentDoc.treat_AccID == 0) {
            workSheetVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkSheetViewController"];
            workSheetVC.selected_UserArray = nil;
        } else {
            UserDoc *userDoc = [[UserDoc alloc] init];
            userDoc.user_Id = treatmentDoc.treat_AccID;
            userDoc.user_Name = treatmentDoc.treat_AccName;
            
            workSheetVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkSheetViewController"];
            workSheetVC.selected_UserArray = @[userDoc];
        }
        
        NSDate *schDate = [NSDate stringToDate:treatmentDoc.treat_Schedule.sch_ScheduleTime];
        workSheetVC.wsDate = schDate ? schDate : [NSDate date];
        workSheetVC.delegate = self;
        workSheetVC.multipleSelection = NO;
        workSheetVC.orderId = theOrderDoc.order_ID;
        [self.navigationController pushViewController:workSheetVC animated:YES];

        indexPath_Selected = indexPath;
    }
    
    // 美丽顾问
    if (indexPath.section == 1 && indexPath.row == 1) {
        
        UserDoc *userDoc = [[UserDoc alloc] init];
        userDoc.user_Id   = theOrderDoc.order_ResponsiblePersonID;
        userDoc.user_Name = theOrderDoc.order_ResponsiblePersonName;
        
        SelectCustomersViewController *selectCustomersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
        [selectCustomersVC setSelectModel:0 userType:1 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
        [selectCustomersVC setDelegate:self];
        [selectCustomersVC setNavigationTitle:@"选择美丽顾问"];
        [selectCustomersVC setPersonType:CustomePersonGroup];
        [selectCustomersVC setPushOrpop:1];  // push
        [self.navigationController pushViewController:selectCustomersVC animated:YES];
        
        indexPath_Selected = indexPath;
    }
}

#pragma mark - WorkSheetViewControllerDelegate

- (void)dismissViewController:(WorkSheetViewController *)workSheetVC userArray:(NSArray *)userArray dateStr:(NSString *)dateStr
{
    NSArray *treatArray = [theDataArray objectAtIndex:indexPath_Selected.section -3];
    TreatmentDoc *treatmentDoc = [treatArray objectAtIndex:indexPath_Selected.row - 1];

    if ([userArray count] == 0) {
        UserDoc *userDoc = [[UserDoc alloc] init];
        userDoc.user_Id = 0;
        userDoc.user_Name = @"";
        userArray = [NSArray arrayWithObjects:userDoc, nil];
    }
    
    UserDoc *userDoc = (UserDoc *)[userArray firstObject];
    if (treatmentDoc.ctlFlag == 1) {
        treatmentDoc.treat_AccID   = userDoc.user_Id;
        treatmentDoc.treat_AccName = userDoc.user_Name;
    } else {
        if (treatmentDoc.treat_AccID != userDoc.user_Id) {
            treatmentDoc.treat_AccID   = userDoc.user_Id;
            treatmentDoc.treat_AccName = userDoc.user_Name;
            treatmentDoc.ctlFlag = 2;
        }
    }
    
    if (treatmentDoc.treat_Schedule.ctlFlag == 1) {
        treatmentDoc.treat_Schedule.sch_ScheduleTime = dateStr;
    } else {
        if (![treatmentDoc.treat_Schedule.sch_ScheduleTime isEqualToString:dateStr]) {
            treatmentDoc.treat_Schedule.sch_ScheduleTime = dateStr;
            treatmentDoc.treat_Schedule.ctlFlag = 2;
        }
    }

    [_tableView reloadRowsAtIndexPaths:@[indexPath_Selected] withRowAnimation:UITableViewRowAnimationNone];
    
    indexPath_Selected = nil;
}

#pragma mark - SelectCustomersViewControllerDelegate

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = (UserDoc *)[userArray firstObject];
    if (userDoc == nil) {
        userDoc = [[UserDoc alloc] init];
        userDoc.user_Name = @"";
    }
    theOrderDoc.order_ResponsiblePersonID   = userDoc.user_Id;
    theOrderDoc.order_ResponsiblePersonName = userDoc.user_Name;
    
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    indexPath_Selected = nil;
}

#pragma mark - ConfigCell

// 配置OrderAddCell
- (OrderAddCell *)configOrderAddCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderAddCell";
    OrderAddCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderAddCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.delegate = self;
    return cell;
}

// 配置NumberEditCell2(无单位+不可编辑 或 有单位+不可编辑)
- (NormalEditCell *)configNormalEditCell2:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditCell2";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.userInteractionEnabled = NO;
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.accessoryLabel setHidden:YES];
    cell.valueText.delegate = self;
    return cell;
}

// 配置OrderTreatmentCell
- (OrderTreatmentCell *)configOrderTreatmentCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderTreatmentCell";
    OrderTreatmentCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderTreatmentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    //cell.delegate = self;
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

// 配置OrderContactCell
- (OrderContactCell *)configOrderContactCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderContactCell";
    OrderContactCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - OrderAddCellDelegate

- (void)chickAddButton:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    DLOG(@"addCell section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    if (indexPath.section == [theCourseArray count] + 3) {  // 联系section
        ContactDoc *newContactDoc = [[ContactDoc alloc] init];
        newContactDoc.cont_Schedule.ctlFlag = 1;
        
        // 添加到theContactArray && theOrderDoc.contractArray
        [theContactArray addObject:newContactDoc];
        [theOrderDoc.contractArray addObject:newContactDoc];
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else // 课程section
    {
        TreatmentDoc *newTreatmentDoc = [[TreatmentDoc alloc] init];
        newTreatmentDoc.ctlFlag = 1;
        newTreatmentDoc.treat_Schedule.ctlFlag = 1;
        
        // 添加到theCourseArray && theOrderDoc.courserArray
         // theCourseArray的course对象和theOrderDoc.courseArray的cours同地址 so theCourseArray不需要再次add
        CourseDoc *operation_course = [theOrderDoc.courseArray objectAtIndex:indexPath.section -3];
        [operation_course.treatmentArray addObject:newTreatmentDoc];
        
        // 添加到theDataArray
        NSMutableArray *treamentArray = [theDataArray objectAtIndex:indexPath.section - 3];
        [treamentArray addObject:newTreatmentDoc];

        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - OrderDateCellDelete

- (void)chickOperateRowButton:(UITableViewCell *)cell
{
    [self dismissKeyBoard];
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    DLOG(@"deleteRow section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);

    if (indexPath.section == [theCourseArray count] + 3) // 联系section
    {
        ContactDoc *contactDoc = [theContactArray objectAtIndex:indexPath.row - 1];
        if (contactDoc.cont_Schedule.ctlFlag == 1) {
            [theContactArray removeObject:contactDoc];
            [theOrderDoc.contractArray removeObject:contactDoc];
        } else {
            contactDoc.cont_Schedule.ctlFlag = 3;
            [theContactArray removeObject:contactDoc];
        }
        
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    else // 课程section
    {
        NSMutableArray *treatmentArray = [theDataArray objectAtIndex:indexPath.section - 3];
        TreatmentDoc *treatmentDoc = [treatmentArray objectAtIndex:indexPath.row - 1];
        if (treatmentDoc.treat_Schedule.ctlFlag == 1) // 不需要(treatmentDoc.treat_Schedule.ctlFlag == 1 && treatmentDoc.ctlFlag == 1) 《==》 因为treatment和schedule是同时新建的
        {
            [treatmentArray removeObject:treatmentDoc];
            
            CourseDoc *operation_Course = [theOrderDoc.courseArray objectAtIndex:indexPath.section - 3];
            [operation_Course.treatmentArray removeObject:treatmentArray];
        } else {
            treatmentDoc.ctlFlag = 3;
            treatmentDoc.treat_Schedule.ctlFlag = 3;
            [treatmentArray removeObject:treatmentDoc];
        }
        
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

/*** 后续可能会用到
#pragma mark - ProductAndPriceViewDelegate

- (void)changeHeightOfProductAndPriceView
{
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

// Add Section For Course
- (void)addOneProductInProductAndPriceView:(ProductAndPriceView *)theproductAndPriceView
{
    if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 1)
    {
        theOrderDoc.productAndPriceDoc = theproductAndPriceView.theProductAndPriceDoc;
        return;
    }
    
    TreatmentDoc *newTreatment = [[TreatmentDoc alloc] init];
    newTreatment.treat_Schedule.ctlFlag = 1;
    
    // 新建一数组 添加newTreatment 后加到theDataArray
    NSMutableArray *newTreatmentArray = [NSMutableArray array];
    [newTreatmentArray addObject:newTreatment];
    [theDataArray addObject:newTreatmentArray];
    
    CourseDoc *newCourse = [[CourseDoc alloc] init];
    newCourse.ctlFlag = 1;
    [newCourse.treatmentArray addObject:newTreatment];
    
    [theOrderDoc.courseArray addObject:newCourse];
    [theCourseArray addObject:newCourse];

    
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:[theCourseArray count]] withRowAnimation:UITableViewRowAnimationFade];
}

// Reduce Section For Course
- (void)reduceOneProductInProductAndPriceView:(ProductAndPriceView *)theproductAndPriceView
{
    if (theOrderDoc.productAndPriceDoc.productDoc.pro_Type == 1)
    {
        theOrderDoc.productAndPriceDoc = theproductAndPriceView.theProductAndPriceDoc;
        return;
    }
    
    CourseDoc *last_CourseDoc = [theCourseArray lastObject];
    if (last_CourseDoc.ctlFlag == 1) {
        [theCourseArray removeObject:last_CourseDoc];
        [theOrderDoc.courseArray removeObject:last_CourseDoc];
    } else {
        last_CourseDoc.ctlFlag = 3;
        [theCourseArray removeObject:last_CourseDoc];
    }
    
    [_tableView deleteSections:[NSIndexSet indexSetWithIndex:[theCourseArray count] + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
}
***/


#pragma mark - Submit

- (void)submitOrderAction
{
    [self removeNoChangedOrder];
    [self appendXMLString];
    [self requestUpdateOrder:theOrderDoc];
}

- (void)deleteAction
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除该订单?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alterView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self requestDeleteOrder:theOrderDoc.order_ID];
        }
    }];
}

// 删除没有改变的数据
- (void)removeNoChangedOrder
{
    for (int i=0; i<[theOrderDoc.courseArray count]; i++) {
        CourseDoc *tmpCourse = [theOrderDoc.courseArray objectAtIndex:i];
        for (int j=0; j< [tmpCourse.treatmentArray count]; j++) {
            TreatmentDoc *treatment = [tmpCourse.treatmentArray objectAtIndex:j];
            ScheduleDoc *sch = treatment.treat_Schedule;
            if (sch.ctlFlag == 0 && treatment.ctlFlag == 0) {
                [tmpCourse.treatmentArray removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    for (int i=0; i<[theOrderDoc.contractArray count]; i++) {
        ContactDoc *tmpContact = [theOrderDoc.contractArray objectAtIndex:i];
        ScheduleDoc *sch = tmpContact.cont_Schedule;
        if (sch.ctlFlag == 0) {
            [theOrderDoc.contractArray removeObjectAtIndex:i];
            i--;
        }
    }
}

// 拼接xml字符串
- (void)appendXMLString
{
    theOrderDoc.strOrderDetail = @"";
    
    //--Course
    NSMutableString *courseDetailRootString = [NSMutableString string];
    for (CourseDoc *tmpCourse in theOrderDoc.courseArray) {
        GDataXMLElement *courseElement = [GDataXMLElement elementWithName:@"Course"];
        GDataXMLElement *courseId =   [GDataXMLElement elementWithName:@"CourseID" stringValue:[NSString stringWithFormat:@"%ld", (long)tmpCourse.course_ID]];
        GDataXMLElement *couseCnt =   [GDataXMLElement elementWithName:@"CourseCount" stringValue:[NSString stringWithFormat:@"%ld", (long)[tmpCourse.treatmentArray count]]];
        GDataXMLElement *couseFlag =  [GDataXMLElement elementWithName:@"CourseControlFlag" stringValue:[NSString stringWithFormat:@"%d", tmpCourse.ctlFlag]];
        [courseElement addChild:courseId];
        [courseElement addChild:couseCnt];
        [courseElement addChild:couseFlag];
       
        for (TreatmentDoc *tmpTreat in tmpCourse.treatmentArray) {
            GDataXMLElement *treatmentElement = [GDataXMLElement elementWithName:@"Treatment"];
            ScheduleDoc *sch = tmpTreat.treat_Schedule;
            GDataXMLElement *treatId =       [GDataXMLElement elementWithName:@"TreatmentID" stringValue:[NSString stringWithFormat:@"%ld", (long)tmpTreat.treat_ID]];
            GDataXMLElement *scheduleId =    [GDataXMLElement elementWithName:@"ScheduleID" stringValue:[NSString stringWithFormat:@"%ld", (long)sch.sch_ID]];
            GDataXMLElement *scheduleTime =  [GDataXMLElement elementWithName:@"ScheduleTime" stringValue:sch.sch_ScheduleTime];
            GDataXMLElement *treatmentFlag = [GDataXMLElement elementWithName:@"TreatmentControlFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)tmpTreat.ctlFlag]];
            GDataXMLElement *scheduleFlag  = [GDataXMLElement elementWithName:@"ScheduleControlFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)sch.ctlFlag]];
            GDataXMLElement *executId =      [GDataXMLElement elementWithName:@"ExecutorID" stringValue:[NSString stringWithFormat:@"%ld", (long)tmpTreat.treat_AccID]];
            [treatmentElement addChild:treatId];
            [treatmentElement addChild:scheduleId];
            [treatmentElement addChild:scheduleTime];
            [treatmentElement addChild:treatmentFlag];
            [treatmentElement addChild:executId];
            [treatmentElement addChild:scheduleFlag];
            [courseElement addChild:treatmentElement];
        }
        [courseDetailRootString appendString:[courseElement XMLString]];
    }
    theOrderDoc.strCourse = [[courseDetailRootString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    //--Contact
    NSMutableString *contactDetailRootString = [NSMutableString string];
    for (ContactDoc *tmpContact in theOrderDoc.contractArray) {
        ScheduleDoc *sch = tmpContact.cont_Schedule;
        GDataXMLElement *contactElement = [GDataXMLElement elementWithName:@"Contact"];
        GDataXMLElement *contactId =      [GDataXMLElement elementWithName:@"ContactID" stringValue:[NSString stringWithFormat:@"%ld", (long)tmpContact.cont_ID]];
        GDataXMLElement *scheduleId =     [GDataXMLElement elementWithName:@"ScheduleID" stringValue:[NSString stringWithFormat:@"%ld", (long)sch.sch_ID]];
        GDataXMLElement *scheduleTime =   [GDataXMLElement elementWithName:@"ScheduleTime" stringValue:sch.sch_ScheduleTime];
        GDataXMLElement *contactFlag =    [GDataXMLElement elementWithName:@"ContactControlFlag" stringValue:[NSString stringWithFormat:@"%ld", (long)sch.ctlFlag]];
        [contactElement addChild:contactId];
        [contactElement addChild:scheduleId];
        [contactElement addChild:scheduleTime];
        [contactElement addChild:contactFlag];
        [contactDetailRootString appendString:[contactElement XMLString]];
    }
    theOrderDoc.strContact = [[contactDetailRootString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
}

#pragma mark - 接口

- (void)goOrderList
{
    // go OrderList
    [UIView beginAnimations:@"" context:nil];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderNavigation"];
    
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
    [UIView commitAnimations];
}

// order修改
- (void)requestUpdateOrder:(OrderDoc *)newOrder
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestUpdateOrderOperation = [[GPHTTPClient shareClient] requestUpdateOrder:newOrder success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {} failure:^{}];
    } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
    }];
}

// order删除
- (void)requestDeleteOrder:(NSInteger)orderId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":\"%ld\",\"OrderID\":\"%ld\",\"IsBusiness\":%d,\"UpdaterID\":\"%ld\"}", (long)ACC_BRANCHID, (long)orderId, 1 , (long)ACC_ACCOUNTID];
    
    _requestDeleteOrderOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/DeleteOrder" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {}];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];

    /*
    
    _requestDeleteOrderOperation = [[GPHTTPClient shareClient] requestDeleteOrder:orderId success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^{}];
    } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
    }];
     */
}

@end
