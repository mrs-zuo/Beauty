//
//  SubOrderViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/10.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SubOrderViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"
#import "OrderInfoCell.h"
#import "FooterView.h"

#import "OrderInfo.h"
#import "ContentEditCell.h"
#import "NormalEditCell.h"
#import "UserDoc.h"
#import "SelectCustomersViewController.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "OrderDetailViewController.h"   
#import "CompletionOrderController.h"   
#import "GPNavigationController.h"
#import "ECSlidingViewController.h"
#import "TitleTableViewCell.h"
#import "ServiceViewCell.h"
#import "ColorImage.h"
#import "OrderConfirmViewController.h"
#import "AppDelegate.h"
#import "CusMainViewController.h"
#import "ComputerSginViewController.h"

#define Group_Designated  (group.isDesignated ? @"全部取消指定" : @"全部指定")
#define Treatment_Designated  (treatment.isDesignated ? @"取消指定" : @"指定")
#define TGListAccount   @"选择员工"

typedef NS_ENUM(NSInteger, NotificationManage) {
    NotificationAdd,
    NotificationRemove
};

@interface SubOrderViewController ()<UITableViewDelegate, UITableViewDataSource, ContentEditCellDelegate, UITextFieldDelegate, SelectCustomersViewControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@property (nonatomic, weak) AFHTTPRequestOperation *requestCommitOrder;
@property (nonatomic, weak) DFUITableView  *tableView;
@property (nonatomic, weak) NavigationView *navigaView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSIndexPath *serviceIndex;
@property (nonatomic, assign) NSUInteger productIndex;
@property (nonatomic,assign) BOOL isAllowSign;
@property (nonatomic,copy) NSString *signImgStr;

@end

@implementation SubOrderViewController

- (NSUInteger)productIndex
{
    [self.dataArray enumerateObjectsUsingBlock:^(OrderInfo *obj, NSUInteger idx, BOOL *stop) {
        if (obj.ProductType == 1) {
            _productIndex = idx;
            *stop = YES;
        }
    }];
    return _productIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.backMode == SubOrderViewBackOrderMain) {
        GPNavigationController *nav = (GPNavigationController *)self.navigationController;
        [nav cleanScreenShotsFromeVC:[self class] ViewController:[CusMainViewController class]];
    }

    [self notificationManageWithNotificationManage:NotificationAdd];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self notificationManageWithNotificationManage:NotificationRemove];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
- (void)notificationManageWithNotificationManage:(NotificationManage)manageType
{
    switch (manageType) {
        case NotificationAdd:
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:)   name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
            break;
        case NotificationRemove:
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
            break;
    }
}

-(void)keyboardWillShown:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 240, 0);
    }];
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
    }];
}

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"开单"];
        [self.view addSubview:_navigaView = nav];
    }
    return _navigaView;
}
static NSString *remark = @"Remark";

- (DFUITableView *)tableView
{
    if (_tableView == nil) {
        DFUITableView *tab = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        tab.separatorColor = kTableView_LineColor;
        [tab registerClass:[OrderInfoCell class] forCellReuseIdentifier:@"OrderInfo"];
        [tab registerClass:[TitleTableViewCell class] forCellReuseIdentifier:@"TitleViewCell"];
        [tab registerClass:[ServiceViewCell class] forCellReuseIdentifier:@"ServiceCell"];
        [tab registerClass:[ContentEditCell class] forCellReuseIdentifier:remark];
        FooterView *footerView = [[FooterView alloc] initWithTarget:self submitTitle:@"确定" submitAction:@selector(chechoutAction)];
        [footerView showInTableView:tab];
        
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
}

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    self.tableView.frame = CGRectMake(5.0f, self.navigaView.frame.origin.y + self.navigaView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initData
{
    self.dataArray = [[NSMutableArray alloc] init];
    _signImgStr = @"";
    [self tmpRequestTreatGroup:self.orderList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        OrderInfo *order = self.dataArray[section -1];
        if (order.ProductType == 0) {
            return 6 + order.subServiceCount;
        } else {
            return 7;
        }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderInfoCell *dfCell = [tableView dequeueReusableCellWithIdentifier:@"OrderInfo"];
    dfCell.textLabel.textColor = kColor_Black;
    dfCell.detailTextLabel.textColor = kColor_Black;

    if ([dfCell respondsToSelector:@selector(setSeparatorInset:)]) {
        [dfCell setSeparatorInset:UIEdgeInsetsZero];
    }
    if (indexPath.section == 0) {
        dfCell.textLabel.textColor = kColor_DarkBlue;
        dfCell.textLabel.text = @"顾客";
        dfCell.detailTextLabel.text = self.customerName;
        return dfCell;
    } else {
        
        OrderInfo *order = self.dataArray[indexPath.section -1];

        if (order.ProductType == 1) {
            if (indexPath.row == 0) {
                dfCell.textLabel.text = order.ProductName;
                dfCell.textLabel.textColor = kColor_Black;
            } else if (indexPath.row == 1) {
                dfCell.textLabel.text = @"美丽顾问";
                dfCell.textLabel.textColor = kColor_DarkBlue;
                dfCell.detailTextLabel.text = order.AccountName;
            } else if (indexPath.row == 2) {
                static NSString *CellTag = @"cellTag";
                NormalEditCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTag];
                
                if (!cell) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellTag];
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(284.0f, 9.0f, 21.0f, 21.0f)];
                    button.userInteractionEnabled = NO;
                    [button setBackgroundImage:[UIImage imageNamed:@"zixun_NoPermit"] forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"zixun_Permit"] forState:UIControlStateSelected];
                    button.tag = 100;
                    [cell.contentView addSubview:button];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.titleLabel.textColor = kColor_Black;
                cell.titleLabel.text = @"立即交付";
                cell.valueText.text = @"";
                cell.valueText.userInteractionEnabled = NO;
                UIButton *button = (UIButton *)[cell.contentView viewWithTag:100];
                button.selected = order.isFinish;
                return cell;
            } else if (indexPath.row == 3) {
                NormalEditCell *cell = [self normalNumberCell:tableView indexPath:indexPath];
                cell.titleLabel.textColor = kColor_Black;
                cell.titleLabel.text = @"本次交付数量";
                cell.nocopyText.text = [NSString stringWithFormat:@"%ld", (long)order.count];
                return cell;
            } else if (indexPath.row == 4) {
                dfCell.textLabel.text = order.StatusTitleCom;
                dfCell.detailTextLabel.text = order.SurplusTitleCom;
            } else if (indexPath.row == 5) {
                dfCell.textLabel.text = @"备注";
                dfCell.textLabel.textColor = kColor_DarkBlue;
                dfCell.detailTextLabel.text = @"";
            } else {
                ContentEditCell *cell = [self remarkCell:tableView indexPath:indexPath];
                cell.contentEditText.text = order.Remark;
                return cell;
            }
                return dfCell;
            
        } else {
            if (indexPath.row == 0) {
                dfCell.textLabel.text = order.ProductName;
            } else if (indexPath.row == 1) {
                dfCell.textLabel.textColor = kColor_DarkBlue;
                dfCell.textLabel.text = @"美丽顾问";
                dfCell.detailTextLabel.text = order.AccountName;
            } else if (indexPath.row == 2) {
                dfCell.textLabel.text = order.StatusTitleSer;
                //wugang->
                //追加进行中件数显示后textLabel宽度不足，针对此格单独调整宽度为200
                CGRect temp = dfCell.textLabel.frame;
                temp.size.width = 200;
                dfCell.textLabel.frame = temp;
                //<-wugang
                dfCell.detailTextLabel.text = order.SurplusTitleSer;
            } else if (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)) {
                ContentEditCell *cell = [self remarkCell:tableView indexPath:indexPath];
                cell.contentEditText.text = order.Remark;
                return cell;
            } else if (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 2)) {
                dfCell.textLabel.textColor = kColor_DarkBlue;
                dfCell.textLabel.text = @"备注";
                dfCell.detailTextLabel.text = @"";
            } else if (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 3)) {
                TitleTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:@"TitleViewCell"];
                titleCell.textLabel.text = @"";
                titleCell.backgroundColor = [UIColor whiteColor];
                titleCell.mdetailTextLabel.text = @"添加";
                titleCell.mdetailTextLabel.backgroundColor = KColor_Blue;
                if ([titleCell respondsToSelector:@selector(setSeparatorInset:)]) {
                    [titleCell setSeparatorInset:UIEdgeInsetsZero];
                }

                return titleCell;
            } else {

                NSIndexPath *index = [self rowNumberOfTheCellOfOrderInfo:order tableView:tableView indexPath:indexPath];
                SubServiceGroup *subGroup = order.groupList[index.section];
                TitleTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:@"TitleViewCell"];
                ServiceViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
                serviceCell.desigImage.hidden = YES;
                serviceCell.quanImage.hidden = YES;
                titleCell.backgroundColor = kColor_CellView_Backgroud;
                serviceCell.backgroundColor = kColor_CellView_Backgroud;
                serviceCell.textLabel.textColor = kColor_Black;
                serviceCell.detailTextLabel.textColor = kColor_Editable;
                if (index.row == 0) {
                    titleCell.textLabel.text = [NSString stringWithFormat:@"新开单%ld", index.section + 1];
                    titleCell.mdetailTextLabel.text = @"删除";
                    titleCell.mdetailTextLabel.backgroundColor = KColor_Red;
                    if ([titleCell respondsToSelector:@selector(setSeparatorInset:)]) {
                        [titleCell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                    }
                    return titleCell;
                } else if (index.row == 1) {
                    serviceCell.imageLayout = ServiceCellLayoutNormol;
                    serviceCell.textLabel.text = @"服务顾问";
                    serviceCell.textLabel.textColor = kColor_DarkBlue;
                    serviceCell.detailTextLabel.text = subGroup.serviceName;
                } else {
                    SubService *sub = subGroup.serviceList[index.row - 2];
                    
                    serviceCell.desigImage.image = [UIImage imageNamed:@"order_designated"];
                    serviceCell.desigImage.hidden = !sub.isDesignated;
                    serviceCell.imageLayout = ServiceCellLayoutSecond;

                    serviceCell.quanImage.hidden = NO;
                    serviceCell.textLabel.text = sub.SubServiceName.length ==0 ?@"服务操作":sub.SubServiceName;
                    serviceCell.detailTextLabel.text = sub.ExecutorID >0 ? sub.ExecutorName:@"";
                }
                if (index.row == subGroup.serviceList.count + 1) {
                    if ([serviceCell respondsToSelector:@selector(setSeparatorInset:)]) {
                        [serviceCell setSeparatorInset:UIEdgeInsetsZero];
                    }
                } else {
                    if ([serviceCell respondsToSelector:@selector(setSeparatorInset:)]) {
                        [serviceCell setSeparatorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                    }
                }
                return serviceCell;
            }
            return dfCell;
        }
    }
    return dfCell;
}

- (ContentEditCell *)remarkCell:(UITableView *)tableView indexPath:(NSIndexPath *)index
{
    ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:remark];
    cell.userInteractionEnabled = YES;
    cell.delegate = self;
    cell.contentEditText.placeholder = @"请输入备注...";

    return cell;
}

- (NormalEditCell *)normalNumberCell:(UITableView *)tableView indexPath:(NSIndexPath *)index
{
    static NSString *numberCell = @"number";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:numberCell];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyleNocopy:UITableViewCellStyleDefault reuseIdentifier:numberCell];
        cell.nocopyText.delegate = self;
        cell.nocopyText.frame = CGRectMake(255.0f, kTableView_HeightOfRow/2 - 30.0f/2, 50, 30.0f);
        cell.nocopyText.layer.masksToBounds = YES;
        cell.nocopyText.layer.cornerRadius = 5.0f;
        cell.nocopyText.layer.borderColor = [kTableView_LineColor CGColor];
        cell.nocopyText.layer.borderWidth = .5f;
    }
    return cell;
}

- (NSIndexPath *)rowNumberOfTheCellOfOrderInfo:(OrderInfo *)orderInfo tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 3 ||
        indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 3) ||
        indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 2) ||
        indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1) ||
        orderInfo.ProductType == 1) {
        return nil;
    }

    __block NSInteger indexRow = indexPath.row - 3; //
    __block NSIndexPath *groupIndex = nil;
    [orderInfo.groupList enumerateObjectsUsingBlock:^(SubServiceGroup *obj, NSUInteger idx, BOOL *stop) {
        if (indexRow - obj.serviceCount < 0) {
            groupIndex = [NSIndexPath indexPathForRow:indexRow inSection:idx];
            *stop = YES;
        } else {
            indexRow -= obj.serviceCount;
        }
    }];
    return groupIndex;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        OrderInfo *order = self.dataArray[indexPath.section -1];
        if (order.ProductType == 0 && indexPath.row == (5 + order.subServiceCount)) {
            return kTableView_HeightOfRow > order.Remark_Height ? kTableView_HeightOfRow : order.Remark_Height;
        }
        if (order.ProductType == 1 && indexPath.row == 6) {
            return kTableView_HeightOfRow > order.Remark_Height ? kTableView_HeightOfRow : order.Remark_Height;
        }
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 1 || self.productIndex) {
//        return 36.0;
//    }
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 1 || self.productIndex) {
//        UITableViewHeaderFooterView *tableHeader = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"add"];
//        if (tableHeader == nil) {
//            tableHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"add"];
//            tableHeader.backgroundColor = [UIColor grayColor];
//        }
//        tableHeader.tintColor = kColor_Black;
//        tableHeader.textLabel.font = kFont_Light_16;
//        tableHeader.textLabel.text = (section == 1 ? @"服务类" : @"商品类");
//        return tableHeader;
//    } else {
//        return nil;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    OrderInfo *order = self.dataArray[indexPath.section -1];
    
    if (order.ProductType == 0) {
        NSIndexPath *tmpIndex = [self rowNumberOfTheCellOfOrderInfo:order tableView:tableView indexPath:indexPath];
        
        if (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 3)) {
            if (order.SurplusCount <= order.groupList.count && order.TotalCount != 0) {
                [SVProgressHUD showErrorWithStatus2:@"服务次数已到达最大值!" duration:kSvhudtimer touchEventHandle:^{
                    
                }];
                return;
            }
            if (self.taskID  > 0 && order.groupList.count > 0 ) {//预约开单不能增加
                [SVProgressHUD showSuccessWithStatus2:@"一次预约只能做一次服务!" touchEventHandle:^{}];
                return;
            }
            
            SubServiceGroup *sub = [[SubServiceGroup alloc] initWithServiceArray:order.SubServiceList accountName:order.AccountName accountID:order.AccountID];
            [order.groupList addObject:sub];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        }
        if (tmpIndex.row == 0 && tmpIndex != nil) {
            if (self.taskID  > 0 ) {//预约开单不能删除
                [SVProgressHUD showSuccessWithStatus2:@"此次服务不能删除!" touchEventHandle:^{}];
                return;
            }

            [order.groupList removeObjectAtIndex:tmpIndex.section];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
        } else if (tmpIndex != nil) {
            self.serviceIndex = indexPath;
            SubServiceGroup *group = order.groupList[tmpIndex.section];

            if (tmpIndex.row == 1) {
                [self showDesignatedAndServiceID:group mapIndex:tmpIndex];
            } else {
                [self showDeleteAndServiceID:group mapIndex:tmpIndex];
            }
        }
    } else {
        if (indexPath.row == 2) {
            UIButton *button = (UIButton *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:100];;
            order.isFinish = !order.isFinish;
            button.selected = order.isFinish;
        }
    }
}


#pragma mark tableViewCell点击事件处理
#pragma mark group 指定 美丽顾问选择 处理
- (void)showDesignatedAndServiceID:(SubServiceGroup *)group mapIndex:(NSIndexPath *)mapIndex
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择顾问", Group_Designated, nil];
    [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
        if (buttonIndex == 0) {
            [self selectServiceID:group indexPath:mapIndex];
        }
        if (buttonIndex == 1) {
            group.isDesignated = !group.isDesignated;
            for (NSInteger i = (mapIndex.row - 1) ; i< group.serviceList.count; i++) {
                 SubService *treatment = group.serviceList[i];
                 treatment.isDesignated = group.isDesignated;
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark group  美丽顾问选择 删除 处理
- (void)showDeleteAndServiceID:(SubServiceGroup *)group mapIndex:(NSIndexPath *)mapIndex
{
    SubService *treatment = group.serviceList[mapIndex.row - 2];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:TGListAccount, Treatment_Designated,  nil];
    if (group.serviceList.count > 1) {
        [actionSheet addButtonWithTitle:@"删除"];
    }
    [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:TGListAccount]) {
            [self selectServiceID:group indexPath:mapIndex];
        }
        if ([title isEqualToString:Treatment_Designated]) {
            treatment.isDesignated = !treatment.isDesignated;
            
            int count = 0;
            for (SubService *subTreat in group.serviceList) {
                if (subTreat.isDesignated) {
                    count++;
                }
            }
            
            if (count == group.serviceList.count) {
                group.isDesignated = YES;

            }else
            {
                group.isDesignated = NO;

            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.serviceIndex.section] withRowAnimation:UITableViewRowAnimationNone];
        }
        if ([title isEqualToString:@"删除"]) {
            [group.serviceList removeObjectAtIndex:(mapIndex.row - 2)];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.serviceIndex.section] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

#pragma mark 设置美丽顾问
- (void)selectServiceID:(SubServiceGroup *)group indexPath:(NSIndexPath *)mapIndex
{
    SelectCustomersViewController *selectCustomer =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];

    UserDoc *userDoc = [[UserDoc alloc] init];

    if (mapIndex.row == 1) {
        userDoc.user_Id = group.serviceID;
        userDoc.user_Name = group.serviceName;
    } else {
        SubService *sub = group.serviceList[mapIndex.row - 2];
        userDoc.user_Id = sub.ExecutorID;
        userDoc.user_Name = sub.ExecutorName;
    }
    [selectCustomer setSelectModel:0 userType:3 customerRange:CUSTOMEROFMINE defaultSelectedUsers:@[userDoc]];
    
    [selectCustomer setDelegate:self];
    [selectCustomer setNavigationTitle:@"选择顾问"];
    [selectCustomer setPersonType:CustomePersonGroup];
    [selectCustomer setCustomerId:self.customerID];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
    
}

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = [userArray firstObject];
    OrderInfo *order = self.dataArray[self.serviceIndex.section -1];
    NSIndexPath *tmpIndex = [self rowNumberOfTheCellOfOrderInfo:order tableView:self.tableView indexPath:self.serviceIndex];
    NSAssert1(tmpIndex.section <= order.groupList.count, @"the index is invial %@", tmpIndex);
    SubServiceGroup *subGroup = order.groupList[tmpIndex.section];
    if (tmpIndex.row == 1) {
        subGroup.serviceID = userDoc.user_Id;
        subGroup.serviceName = userDoc.user_Name;
        [subGroup.serviceList enumerateObjectsUsingBlock:^(SubService *obj, NSUInteger idx, BOOL *stop) {
            obj.ExecutorID = userDoc.user_Id;
            obj.ExecutorName = userDoc.user_Name;
        }];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.serviceIndex.section] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        SubService *sub = subGroup.serviceList[tmpIndex.row - 2];
        sub.ExecutorID = userDoc.user_Id;
        sub.ExecutorName = userDoc.user_Name;
        [self.tableView reloadRowsAtIndexPaths:@[self.serviceIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.keyboardType = UIKeyboardTypeNumberPad;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollToTextField:textField withOption:UITableViewScrollPositionMiddle];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *ch = [string cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    if (textField.text.length > 2) {
        return NO;
    }
    
    NSCharacterSet *charSet = [NSCharacterSet decimalDigitCharacterSet];
    NSRange chatRange = [string rangeOfCharacterFromSet:charSet];
    
    if (chatRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self textFieldCellIndexPath:textField];
    OrderInfo *order = self.dataArray[indexPath.section - 1];
    NSInteger newCount = [textField.text integerValue];
    if (newCount <= order.SurplusCount && newCount >= 0) {
        order.count = newCount;
    } else {
        [SVProgressHUD showErrorWithStatus2:@"不能超过剩余次数!" touchEventHandle:^{}];
        textField.text = [NSString stringWithFormat:@"%ld", (long)order.count];
    }
}

- (void)scrollToTextField:(UITextField *)textField withOption:(UITableViewScrollPosition)position
{
    NSIndexPath* path = [self textFieldCellIndexPath:textField];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:position animated:YES];
}

- (NSIndexPath *)textFieldCellIndexPath:(UITextField *)textField
{
    UITableViewCell *cell = nil;
    if (IOS7) {
        cell = (UITableViewCell *)textField.superview.superview.superview;
    } else {
        cell = (UITableViewCell *)textField.superview.superview;
    }
    return [self.tableView indexPathForCell:cell];
}

#pragma mark ContentEditCellDelegate
- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    contentText.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToContentCell:cell withOption:UITableViewScrollPositionMiddle];
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    NSIndexPath *indexRemark = [_tableView indexPathForCell:cell];

    if (indexRemark.section >= 1 && indexRemark.section <= self.dataArray.count) {
        
        if (contentText.text.length > 300) {
            contentText.text = [contentText.text substringToIndex:300];
        }
        
        OrderInfo *order = self.dataArray[indexRemark.section -1];
        order.Remark = contentText.text;
        if (height > order.Remark_Height) {
            order.Remark_Height = height;
            [_tableView scrollToRowAtIndexPath:indexRemark atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [_tableView beginUpdates];
            [_tableView endUpdates];
        }
    }

}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    
}

- (void)scrollToContentCell:(ContentEditCell *)cell withOption:(UITableViewScrollPosition)position
{
    NSIndexPath* path = [self.tableView indexPathForCell:cell];
    
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:position animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 网络请求处理 获取小单信息
- (void)tmpRequestTreatGroup:(NSString *)orderID
{
    self.requestOrderList = [OrderInfo requestOrderInfoArray:orderID TaskID:(long long)self.taskID AccountDic:self.userDic completionBlock:^(NSArray *array, NSString *mesg, NSInteger code) {
        if (array) {
            self.dataArray = [[NSMutableArray alloc] initWithArray:array];
            
            if (self.dataArray.count == 0) {
                if (self.taskID > 0) {
                    [SVProgressHUD showSuccessWithStatus2:@"服务次数已到达最大值!" duration:kSvhudtimer touchEventHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    
                }else{
                    [SVProgressHUD showSuccessWithStatus2:@"交付数量不能为0!" touchEventHandle:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }
            
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{
                [self tmpRequestTreatGroup:orderID];
            }];
        }
    }];
    
}
#pragma mark - 提交订单
//是否进入签字页面
- (BOOL)isEnterSignPage
{
    BOOL isConfirmed = NO;
    for (int i = 0; i < self.dataArray.count; i ++) {
        OrderInfo *orderInfo = self.dataArray[i];
        if (orderInfo.ProductType == 1 && orderInfo.isFinish && orderInfo.IsConfirmed == 2) {
            isConfirmed = YES;
            break;
        }
    }
    return isConfirmed;
}

- (void)chechoutAction
{
    _isAllowSign = [self isEnterSignPage];
    if (_isAllowSign) {
        ComputerSginViewController *signVC = [[ComputerSginViewController alloc]init];
        
        __weak typeof(self) weakSelf = self;
        signVC.computerConfirmSignBlock = ^(NSString *imgString){
            _signImgStr = imgString;
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                
            }];
            [self requestAddTreatGroup];
        };
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:signVC animated:YES completion:^{
            
        }];

    }else{
        [self requestAddTreatGroup];
    }
}
- (void)requestAddTreatGroup
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (OrderInfo *order in self.dataArray) {
        if ((order.ProductType == 1 && order.count == 0) || (order.ProductType == 0 && order.groupList.count == 0)) {
            continue ;
        }
        [tmpArray addObject:order.parameter];
    }
    if (tmpArray.count == 0) {
        
        [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:3];
        return;
    }
    NSString *par;
    if (_isAllowSign) {
        par  = [NSString stringWithFormat:@"{\"SignImg\":\"%@\",\"ImageFormat\":\".jpg\",\"TGDetailList\":[%@]}",_signImgStr,[tmpArray componentsJoinedByString:@","]];
    }else{
        par  = [NSString stringWithFormat:@"{\"TGDetailList\":[%@]}",[tmpArray componentsJoinedByString:@","]];
    }
    _requestCommitOrder = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Order/AddTreatGroup" andParameters:par failureHandle: AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray removeAllObjects];
                    if (self.dataArray.count == 1) {
                        if (self.backMode == SubOrderViewBackDetail) {
                            for (UIViewController *temp in self.navigationController.viewControllers) {
                                if ([temp isKindOfClass:[OrderDetailViewController class]]) {
                                    
                                    [self.navigationController popToViewController:temp animated:YES];
                                }
                            }
                        }else if(self.backMode ==SubOrderViewBackOrderList)
                        {
                            [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:2];
                        }
                        else {
                            [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:3];
                        }
                    } else {
                        
                        [self OrderCompletionViewControllerLastView:5 andClearStack:YES];
                        
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus2:message touchEventHandle:^{}];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

//- (void)requestGetCommitOrder{
//    self.requestCommitOrder = [OrderInfo requestCommitOrder:[self.dataArray copy] completionBlock:^(NSString *mesg, NSInteger code) {
//        if (code == 1) {
//            [SVProgressHUD showSuccessWithStatus2:mesg duration:kSvhudtimer touchEventHandle:^{
//                [((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray removeAllObjects];
//                if (self.dataArray.count == 1) {
//                    if (self.backMode == SubOrderViewBackDetail) {
//                        for (UIViewController *temp in self.navigationController.viewControllers) {
//                            if ([temp isKindOfClass:[OrderDetailViewController class]]) {
//                                
//                                [self.navigationController popToViewController:temp animated:YES];
//                            }
//                        }
//                    }else if(self.backMode ==SubOrderViewBackOrderList)
//                    {
//                        [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:2];
//                    }
//                    else {
//                        [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:3];
//                    }
//                } else {
//                    
//                    [self OrderCompletionViewControllerLastView:5 andClearStack:YES];
//                    
//                }
//            }];
//        } else {
//            if (code == -11) {
//                
//                [self OrderDetailViewControllerwithOrderID:[self.dataArray firstObject]  lastView:3];
//                
//            } else {
//                [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
//            }
//        }
//    }];
//}

- (void)OrderDetailViewControllerwithOrderID:(OrderInfo *)order lastView:(NSInteger)lastView
{
    OrderDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    viewController.orderID = order.OrderID;
    viewController.objectID = order.OrderObjectID;
    viewController.productType = order.ProductType;
    viewController.lastView = lastView; // 返回到 order roo
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)OrderCompletionViewControllerLastView:(NSInteger)lastView andClearStack:(BOOL)isClear
{
    CompletionOrderController *completionVC = [[CompletionOrderController alloc] init];
    GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:completionVC];
    navCon.canDragBack = YES;

    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = navCon;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

@end
