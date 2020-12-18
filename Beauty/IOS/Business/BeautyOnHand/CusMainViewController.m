//
//  CusMainViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CusMainViewController.h"
#import "AwaitOrderTableViewController.h"
#import "ProcessTableViewController.h"
#import "PaymentTableViewController.h"
#import "AwaitFinishTableViewController.h"
#import "FavoritesTableViewController.h"
#import "AwaitView.h"
#import "AppDelegate.h"
#import "CustomerDoc.h"
#import "UIImageView+WebCache.h"
#import "GPUniqueArray.h"

#import "UserDoc.h"
#import "GPBHTTPClient.h"   
#import "CustomerBasicViewController.h"
#import "OrderPayListViewController.h"
#import "CustomerAddViewController.h"
#import "CustomerListViewController.h"
#import "OrderRootViewController.h"
#import "AccountECard_ViewController.h"
#import "PermissionDoc.h"   
#import "AppointmentList_ViewController.h"
#import "StatisticsViewController.h"
#import "ZXPhotoViewController.h"
#import "NoteListController.h"
#define CustomerInfoViewHeight  100

#define ButtonFieldHeight   32.0

//#define SelectLineHeight    5.0
#define SelectLineWidth

#define TableViewBorder     3.0

#define ButtonWidth         64.0f

#define LabelBorder         85.0f
NSString * const CustomerChildViewRefreshNotification = @"CustomerChildViewRefreshNotification";

const NSInteger HeadImageTag = 1000;
const NSInteger DetailViewTag = 1030;
const NSInteger NameLabelTag = 1010;
const NSInteger CardLabelTag = 1020;
const NSInteger AccountButtonTag = 1040;
const NSInteger ChatButtonTag = 1050;
const NSInteger PhotoButtonTag = 1051;
const NSInteger SearchButtonTag = 1060;
const NSInteger CheckOutButtonTag = 1070;
const NSInteger SearchBarTag = 1080;
const NSInteger AddNewCustomerButtonTag = 1090;

const NSInteger CustomerInfoTag = 1100;
const NSInteger CustomerAccountTag = 1110;
const NSInteger CustomerOrderTag = 1120;
const NSInteger TextFieldSearchTag = 1130;
const NSInteger StatisticsTag = 1140;



@interface CusMainViewController ()<UIScrollViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) UIView *customerInfoView;
@property (nonatomic, strong) UIView *buttonField;
@property (nonatomic, weak) UIView *selectLine;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentButton;
@property (nonatomic, assign) NSInteger oldButton;
@property (nonatomic, strong) NSArray *vcArray;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *originArray;
@property (nonatomic, weak) AFHTTPRequestOperation *requestCustomerListOperation;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSString *  defaultCardNo;
@end

@implementation CusMainViewController
static NSString *kCellID = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
    if (_viewOrigin != CusMainViewOriginMenu) {
        [self requestCustomerInfo:YES];
    }
    
    if (self.viewOrigin == CusMainViewOriginMenu) {
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected = nil;
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected removeAllObjects];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray removeAllObjects];
    }

    [self selectTableView:(UIButton *)[self.buttonField viewWithTag:(_viewOrigin == CusMainViewOriginProductList ? 100 : 103)]];
    self.searchString = [[NSString alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType == CustomerRefreshTypeAll) {
        [self requestCustomerInfo:YES];
    } else if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType == CustomerRefreshTypeInfo) {
        [self requestCustomerInfo:NO];
    } else {
        [self updateCustomerInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)dealloc
//{
//    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID) {
//        [[NSUserDefaults standardUserDefaults] setObject:@(((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID) forKey:@"LastCustomer"];
//    } else {
//        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"LastCustomer"];
//    }
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.searchString = textField.text;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.searchString = textField.text;
}

- (void)initData
{
    AwaitOrderTableViewController *firstVC = [[AwaitOrderTableViewController alloc] init];
    firstVC.title = @"待开(0)";

    AwaitFinishTableViewController *secondVC = [[AwaitFinishTableViewController alloc] init];
    secondVC.title = @"待结(0)";

    PaymentTableViewController *thirdVC = [[PaymentTableViewController alloc] init];
    thirdVC.title = @"存单(0)";

    FavoritesTableViewController *fourthVC = [[FavoritesTableViewController alloc] init];
    fourthVC.title = @"收藏(0)";
    
    self.vcArray = @[firstVC, secondVC, thirdVC, fourthVC];
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray == nil)
     {
         ((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray = [[NSMutableArray alloc] init];
     }
    self.oldOrderList = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).awaitOrderArray;
}

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    //self.navigationController.navigationBar.translucent = YES;
    /*
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
    searchBar.barStyle = UIBarStyleDefault;
    
    searchBar.placeholder = @"请选择顾客!";
    [self.view addSubview:searchBar];
    self.searchDisplayVC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayVC.delegate = self;
    self.searchDisplayVC.searchResultsDataSource = self;
    self.searchDisplayVC.searchResultsDelegate = self;
    
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];
     */
    self.originArray = [[NSMutableArray alloc] init];
    [self initCustomerInfoView];
    
    [self initWithButtonField];
    
    [self initWithMainView];
}

- (void)gotoAwaitOrderView
{
    [self selectTableView:(UIButton *)[self.buttonField viewWithTag:100]];
}

-(UIImage *)imageFromColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)initWithButtonField
{
    NSArray *titleArray = [self.vcArray valueForKeyPath:@"title"];
    float buttonX = (kSCREN_BOUNDS.size.width - TableViewBorder * 2) / titleArray.count;
    UIImage *image =[self imageFromColor:KColor_Blue];
    
    for (int i = 0; i < titleArray.count; i++) {
        NSString *title = titleArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        button.titleLabel.font = kFont_Light_16;
        
        [button setTitleColor:KColor_Blue forState:UIControlStateNormal];
        [button setTitleColor:kColor_White forState:UIControlStateSelected];
        
//        button.layer.masksToBounds = YES;
//        button.layer.cornerRadius = 2.0f;
//        button.layer.borderWidth = 0.5f;
//        button.layer.borderColor = [KColor_Blue CGColor];

        [button setBackgroundImage:image forState:UIControlStateSelected];
        
        button.tag = 100 + i;
        
        if (i == 0) {
            self.currentButton = button.tag;
            button.selected = YES;
        }
        button.frame = CGRectMake( buttonX * i, 0, buttonX, ButtonFieldHeight);
        [button addTarget:self action:@selector(selectTableView:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonField addSubview:button];
    }
//    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, ButtonFieldHeight - SelectLineHeight, buttonX, SelectLineHeight)];
//    selectView.backgroundColor = [UIColor redColor];
//    [self.buttonField addSubview:self.selectLine = selectView];
}

- (void)updateButtonFieldTitle
{
    AwaitOrderTableViewController *awaitOrder = [self.vcArray firstObject];
    NSUInteger count = (self.oldOrderList.count + ((AppDelegate *)[[UIApplication sharedApplication] delegate]).serviceArray_Selected.count + ((AppDelegate *)[[UIApplication sharedApplication] delegate]).commodityArray_Selected.count);
    awaitOrder.title = [NSString stringWithFormat:@"待开(%lu)", (unsigned long)count];
    NSArray *updateTitleArray = [self.vcArray valueForKeyPath:@"title"];
    for (int i = 0; i < updateTitleArray.count; i++) {
        UIButton *button = (UIButton *)[self.buttonField viewWithTag:(100 + i)];
        NSString *newTitle = updateTitleArray[i];
        [button setTitle:newTitle forState:UIControlStateNormal];
        [button setTitle:newTitle forState:UIControlStateSelected];
    }
}

- (void)initWithMainView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.buttonField.frame), kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - CGRectGetMaxY(self.buttonField.frame) - 64)];
    self.scrollView.backgroundColor = kColor_Background_View;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    
    CGSize size = [self adjustViewLayout];
    
    [self.vcArray enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
        if (idx == 10 ) {
            AwaitView *view = [[AwaitView alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width * idx + TableViewBorder, 0, size.width - TableViewBorder * 2, size.height)];
            [self.scrollView addSubview:view];
        } else {
            [self addChildViewController:obj];
            [obj didMoveToParentViewController:self];
            obj.view.frame = CGRectMake(kSCREN_BOUNDS.size.width * idx + TableViewBorder, 0, size.width - TableViewBorder * 2, size.height);
            [self.scrollView addSubview:obj.view];
        }
    }];
    
    self.scrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width * self.vcArray.count, 0);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}


//从首页进来，更新顾客信息及刷新存单等页面
- (void)requestCustomerInfo:(BOOL)isRefreshChildVC
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSInteger customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    if (customerID == 0) {
        return;
    }
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerID];
    
     [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/GetCustomerInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
         [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
             CustomerDoc *cusDoc = [[CustomerDoc alloc] init];
             [cusDoc setCus_ID:customerID];
             [cusDoc setCus_Name:[data objectForKey:@"CustomerName"]];
             [cusDoc setCus_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
             [cusDoc setCus_ResponsiblePersonID:[[data objectForKey:@"ResponsiblePersonID"] integerValue]];
             [cusDoc setCus_LoginMobile:[data objectForKey:@"LoginMobile"]];
             [cusDoc setCus_appointCount:[[data objectForKey:@"ScheduleCount"] integerValue]];
             [cusDoc setCus_checkoutCount:[[data objectForKey:@"UnPaidCount"] integerValue]];
             self.defaultCardNo =  [data objectForKey:@"DefaultCardNo"];
             ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected = cusDoc;
             [self updateCustomerInfo];
             if (isRefreshChildVC) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:CustomerChildViewRefreshNotification object:nil];
             }
         } failure:^(NSInteger code, NSString *error) {
             
         }];
    } failure:^(NSError *error) {
        
    }];
}

//未选择顾客进来，则请求顾客列表
- (void)requesCustomertList
{
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%d,\"LevelID\":\"\",\"AccountIDList\":[%@]}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, 1, @""];
    
    _requestCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            self.originArray = [[NSMutableArray alloc] init];
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
                [self.originArray addObject:customerDoc];
            }
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}

- (void)goToAccountView
{
//    if (![[PermissionDoc sharePermission] rule_ECard_Read]) { [SVProgressHUD showErrorWithStatus2:@"您还没有查看账户权限!" touchEventHandle: ^{}]; return;
//    }else{
        AccountECard_ViewController *accountECard = [[AccountECard_ViewController alloc] init];
        accountECard.defaultCardNO = self.defaultCardNo;
        [self.navigationController pushViewController:accountECard animated:YES];
//    }
}

- (void)gotoCustomerBasic
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        return;
    }
    CustomerBasicViewController *customerBasic = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CusTabBarController"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder =1;
    [self.navigationController pushViewController:customerBasic animated:YES];

}
- (void)goToPhotoView:(UIButton *)button
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        return;
    }
    ZXPhotoViewController *photoVC  = [[ZXPhotoViewController alloc]init];
    NSInteger customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    photoVC.customerID = customerID;
    [self.navigationController  pushViewController:photoVC animated:YES];
}
- (void)goToChatView:(UIButton *)button
{
    if (![[PermissionDoc sharePermission] rule_Chat_Use]) {
        [SVProgressHUD showErrorWithStatus2:@"您没有发送消息的权限!" touchEventHandle:^{}];
        return;
    }
    
    ChatViewController *chatViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"chatViewController"];
    
    UserDoc *userDoc = [[UserDoc alloc] init];
    [userDoc setUser_Id:((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
    [userDoc setUser_Name:((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name];
    [userDoc setUser_Available:1];
    [userDoc setUser_HeadImage:((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_HeadImgURL];
    [chatViewController setUsers_Selected:[NSMutableArray arrayWithObjects:userDoc, nil]];
    
    [self.navigationController pushViewController:chatViewController animated:YES];

}

- (void)appointment
{
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType = CustomerRefreshTypeInfo;
    
    AppointmentList_ViewController *appVC = [[AppointmentList_ViewController alloc] init];
    appVC.viewTag = 1 ;
    [self.navigationController pushViewController:appVC animated:YES];
}
- (void)goToOrderList
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType = CustomerRefreshTypeInfo;

    OrderRootViewController *payment = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderRootViewController"];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder =1;
    payment.menue = 1;
    [self.navigationController pushViewController:payment animated:YES];
}
- (void)goToStatisticsList
{
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType = CustomerRefreshTypeInfo;
    
    StatisticsViewController *statisticsVC = [[StatisticsViewController alloc]init];
    
    [self.navigationController pushViewController:statisticsVC animated:YES];
}
- (void)checkoutOrder:(UIButton *)button
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        return;
    }
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.refreshType = CustomerRefreshTypeInfo;
    OrderPayListViewController *orderPay = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderPayListViewController"];
    
    orderPay.customerId = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    orderPay.customerName = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name;
    orderPay.branchID = 0;
    [self.navigationController pushViewController:orderPay animated:YES];
}

- (void)goToCustomerListView:(UIButton *)button
{
    [self.view endEditing:YES];
    CustomerListViewController  *cusList = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomerListViewController"];
    cusList.returnViewTag = 2;
    
    cusList.searchString = self.searchString;
    
    [self.navigationController pushViewController:cusList animated:YES];
}

- (void)addNewCustomer
{
    CustomerAddViewController *customerAdd = [[CustomerAddViewController alloc] init];
    CustomerDoc *addCustomerDoc = [[CustomerDoc alloc] init];
    addCustomerDoc.cus_ResponsiblePersonID = ACC_ACCOUNTID;
    addCustomerDoc.cus_ResponsiblePersonName = ACC_ACCOUNTName;
    customerAdd.newcustomer = addCustomerDoc;
    customerAdd.addOrigin = CustomerAddOriginOrderMain;
    [self.navigationController pushViewController:customerAdd animated:YES];
}

- (UIView *)buttonField
{
    if (!_buttonField) {
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(TableViewBorder, CGRectGetMaxY(self.customerInfoView.frame) + TableViewBorder, kSCREN_BOUNDS.size.width - TableViewBorder * 2, ButtonFieldHeight)];
        buttonView.backgroundColor = [UIColor whiteColor];
        buttonView.layer.borderColor = kColor_LightBlue.CGColor;
        buttonView.layer.borderWidth = 0.5;
        buttonView.layer.masksToBounds = YES;
//        buttonView.layer.cornerRadius = 2.0;
        [self.view addSubview:_buttonField = buttonView];
    }
    return _buttonField;
}


- (CGSize)adjustViewLayout
{
    return CGSizeMake(kSCREN_BOUNDS.size.width, CGRectGetHeight(self.scrollView.frame));
    
}

- (void)selectTableView:(UIButton *)button
{
    UIButton *lastButton = (UIButton *)[self.buttonField viewWithTag:self.currentButton];
    if (button.tag == self.currentButton) {
        return;
    }
    lastButton.selected = NO;
    button.selected = !button.selected;
    self.currentButton = button.tag;
//    [self updateSelectLine:button.frame.origin.x];
    [self updateViewController];
    [self updateDataWithController];
}

- (void)updateDataWithController
{
    OriginViewController *originVC = [self.vcArray objectAtIndex:self.currentButton % 100];
    [originVC updateData];
}
//更新滚动条位置
- (void)updateSelectLine:(float)pointX
{
    CGRect selectFrame = self.selectLine.frame;
    selectFrame.origin.x = pointX;
    [UIView animateWithDuration:0.1 animations:^{
        self.selectLine.frame = selectFrame;
    }];
}

- (void)updateViewController
{
    self.scrollView.contentOffset = CGPointMake(kSCREN_BOUNDS.size.width * (int)(self.currentButton % 100), 0);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffX = scrollView.contentOffset.x;
    CGFloat startOffX = scrollView.frame.size.width * (self.currentButton - 100);
    float rate = 0;

    if (contentOffX > startOffX) {
        rate = contentOffX / scrollView.frame.size.width;
    } else {
        rate = contentOffX / scrollView.frame.size.width;
    }
    UIButton *lastButton = (UIButton *)[self.buttonField viewWithTag:self.currentButton];
    float rate1 = roundf(rate);
    self.currentButton = rate1 + 100;
    
    UIButton *currentClickButton = (UIButton *)[self.buttonField viewWithTag:self.currentButton];
    lastButton.selected = NO;
    currentClickButton.selected = !currentClickButton.selected;
    
    // 滚动条
//    float pointX = contentOffX / scrollView.contentSize.width * self.buttonField.frame.size.width;
//    
//    [self updateSelectLine:pointX];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.oldButton = self.currentButton;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    if (self.oldButton != self.currentButton) {
        [self updateDataWithController];
    }
}

- (UIImage *)arrorImage:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 20, 20);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);

    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height/2);
    CGContextAddLineToPoint(context, rect.origin.x, rect.size.height);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (void)initCustomerInfoView
{
 
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(TableViewBorder, 4, kSCREN_BOUNDS.size.width - TableViewBorder * 2, CustomerInfoViewHeight)];
    view.backgroundColor = [UIColor whiteColor];
    
    view.layer.borderColor = kColor_LightBlue.CGColor;
    view.layer.borderWidth = 0.5;
    view.layer.masksToBounds = YES;
//    view.layer.cornerRadius = 2.0f;
    
    UIImageView *headImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    headImage.tag = HeadImageTag;
    headImage.layer.borderColor = [kTableView_LineColor CGColor];
    headImage.layer.shadowColor = [UIColor blackColor].CGColor;
    headImage.layer.shadowOpacity = 0.8f;
    headImage.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    headImage.layer.shadowRadius = 2.0f;
    headImage.layer.masksToBounds = NO;
    headImage.userInteractionEnabled = YES;
    headImage.frame = CGRectMake(10, 10, 52, 52);
    
    UIButton *addCustomerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addCustomerButton.frame = CGRectMake(20, 10, 70, 70);
    CALayer *addlayer = [CALayer layer];
    addlayer.frame = CGRectMake( 69, 0, 1, 70);
    addlayer.backgroundColor = kColor_Background_View.CGColor;
    [addCustomerButton.layer addSublayer:addlayer];
    [addCustomerButton setImage:[UIImage imageNamed:@"CustomerService_addPersons"] forState:UIControlStateNormal];
    addCustomerButton.imageEdgeInsets = UIEdgeInsetsMake(2.5, 0, 0, 2.5);
    addCustomerButton.tag = AddNewCustomerButtonTag;
    [addCustomerButton addTarget:self action:@selector(addNewCustomer) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:addCustomerButton];
    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelBorder, 10, 110, 20)];
    nameLabel.tag = NameLabelTag;
    
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelBorder, 40, 140, 20)];
    cardLabel.tag = CardLabelTag;
    
    
    [view addSubview:nameLabel];
    [view addSubview:cardLabel];
    
    //搜索按钮
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.tag = SearchButtonTag;
    searchButton.frame = CGRectMake(258, 30, 30, 30);
    [searchButton addTarget:self action:@selector(goToCustomerListView:) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setImage:[UIImage imageNamed:@"CustomerService_searchnew"] forState:UIControlStateNormal];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 32, 140, 26)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.delegate = self;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 6.0f;
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = kColor_ButtonBlue.CGColor;
    textField.tag = TextFieldSearchTag;
    [view addSubview:textField];
    
    //结账
    UIButton *checkoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkoutButton.tag = CheckOutButtonTag;
    [checkoutButton addTarget:self action:@selector(checkoutOrder:) forControlEvents:UIControlEventTouchUpInside];
    checkoutButton.frame = CGRectMake( 245, 10, 65, 25);

    checkoutButton.layer.masksToBounds = YES;
    checkoutButton.layer.cornerRadius = 6.0f;
    [checkoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkoutButton setBackgroundImage:[self imageFromColor:KColor_Blue] forState:UIControlStateNormal];
    [checkoutButton setTitle:@"结账" forState:UIControlStateNormal];
    checkoutButton.titleLabel.font = kFont_Light_15;
    checkoutButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    //账户-》预约
    UIButton *accountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accountButton.tag = AccountButtonTag;
    [accountButton addTarget:self action:@selector(appointment) forControlEvents:UIControlEventTouchUpInside];
    [accountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accountButton setBackgroundImage:[self imageFromColor:KColor_Blue] forState:UIControlStateNormal];

    accountButton.layer.masksToBounds = YES;
    accountButton.layer.cornerRadius = 6.0f;

    accountButton.frame = CGRectMake(CGRectGetMinX(checkoutButton.frame), CGRectGetMaxY(checkoutButton.frame) + 5, 65, 25);
    [accountButton setTitle:@"预约" forState:UIControlStateNormal];
    accountButton.titleLabel.font = kFont_Light_15;
    accountButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    //资料
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.tag = CustomerInfoTag;
    [infoButton addTarget:self action:@selector(gotoCustomerBasic) forControlEvents:UIControlEventTouchUpInside];
    [infoButton setTitle:@"资料" forState:UIControlStateNormal];
    infoButton.frame = CGRectMake(5, CGRectGetMaxY(headImage.frame) + 5, ButtonWidth, 28);

    [infoButton setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.5 alpha:0.3]] forState:UIControlStateHighlighted];
    [infoButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [infoButton setTitleColor:kColor_Black forState:UIControlStateNormal];
    infoButton.titleLabel.font = kFont_Light_14;

    [infoButton setImage:[UIImage imageNamed:@"CustomerService_Infonew"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"CustomerService_noInfonew"] forState:UIControlStateDisabled];

    infoButton.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 34);
    infoButton.titleEdgeInsets = UIEdgeInsetsMake(0, -34, 0, 0);
    //账户
    
    UIButton *customerAccount = [UIButton buttonWithType:UIButtonTypeCustom];
    customerAccount.tag = CustomerAccountTag;
    [customerAccount addTarget:self action:@selector(goToAccountView) forControlEvents:UIControlEventTouchUpInside];
    customerAccount.frame = CGRectMake(LabelBorder - 3, CGRectGetMinY(infoButton.frame), ButtonWidth, 28);
    [customerAccount setTitle:@"账户" forState:UIControlStateNormal];

    [customerAccount setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.5 alpha:0.3]] forState:UIControlStateHighlighted];

    [customerAccount setTitleColor:kColor_Black forState:UIControlStateNormal];
    
    [customerAccount setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    customerAccount.titleLabel.font = kFont_Light_14;

    [customerAccount setImage:[UIImage imageNamed:@"CustomerService_acountnew"] forState:UIControlStateNormal];
    [customerAccount setImage:[UIImage imageNamed:@"CustomerService_noacountnew"] forState:UIControlStateDisabled];

    customerAccount.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 34);
    customerAccount.titleEdgeInsets = UIEdgeInsetsMake(0, -34, 0, 0);
    
    //订单
    UIButton *customerOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    customerOrder.tag = CustomerOrderTag;
    [customerOrder addTarget:self action:@selector(goToOrderList) forControlEvents:UIControlEventTouchUpInside];
    customerOrder.frame = CGRectMake(CGRectGetMaxX(customerAccount.frame) + 10, CGRectGetMinY(infoButton.frame), ButtonWidth, 28);
    [customerOrder setTitle:@"订单" forState:UIControlStateNormal];

    [customerOrder setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [customerOrder setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.5 alpha:0.3]] forState:UIControlStateHighlighted];
    [customerOrder setTitleColor:kColor_Black forState:UIControlStateNormal];
    
    [customerOrder setImage:[UIImage imageNamed:@"CustomerService_ordernew"] forState:UIControlStateNormal];
    [customerOrder setImage:[UIImage imageNamed:@"CustomerService_noordernew"] forState:UIControlStateDisabled];
    
    customerOrder.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 34);
    customerOrder.titleEdgeInsets = UIEdgeInsetsMake(0, -34, 0, 0);
    customerOrder.titleLabel.font = kFont_Light_14;
    
    //统计
    UIButton *statistics = [UIButton buttonWithType:UIButtonTypeCustom];
    statistics.tag = StatisticsTag;
    [statistics addTarget:self action:@selector(goToStatisticsList) forControlEvents:UIControlEventTouchUpInside];
    statistics.frame = CGRectMake(CGRectGetMaxX(customerOrder.frame) + 10, CGRectGetMinY(infoButton.frame), ButtonWidth, 28);
    [statistics setTitle:@"统计" forState:UIControlStateNormal];
    
    [statistics setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [statistics setBackgroundImage:[self imageFromColor:[UIColor colorWithWhite:0.5 alpha:0.3]] forState:UIControlStateHighlighted];
    [statistics setTitleColor:kColor_Black forState:UIControlStateNormal];
    
    [statistics setImage:[UIImage imageNamed:@"statistics"] forState:UIControlStateNormal];
    [statistics setImage:[UIImage imageNamed:@"statistics_nostanew"] forState:UIControlStateDisabled];
    
    statistics.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 34);
    statistics.titleEdgeInsets = UIEdgeInsetsMake(0, -34, 0, 0);
    statistics.titleLabel.font = kFont_Light_14;
    

    //30 20
//    CALayer *layer2 = [CALayer layer];
//    layer2.frame = CGRectMake(0, 4, 30, 20);
//    layer2.contents = (id)[UIImage imageNamed:@"CustomerService_ordernew"].CGImage;
//    
//    [customerOrder.layer addSublayer:layer2];
//    customerOrder.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);


    //飞语
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.tag = ChatButtonTag;
    [chatButton addTarget:self action:@selector(goToChatView:) forControlEvents:UIControlEventTouchUpInside];
    chatButton.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + 10, 7, 30, 30);
    [chatButton setBackgroundImage:[UIImage imageNamed:@"Menu0_Chat"] forState:UIControlStateNormal];
    
    //照片
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.tag = PhotoButtonTag;
    [photoButton addTarget:self action:@selector(goToPhotoView:) forControlEvents:UIControlEventTouchUpInside];
    photoButton.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame) + 10, 30 + 7, 30, 30);
    [photoButton setBackgroundImage:[UIImage imageNamed:@"effecticon"] forState:UIControlStateNormal];
    
    [view addSubview:infoButton];
    [view addSubview:customerAccount];
    [view addSubview:customerOrder];
    [view addSubview:statistics];
    [view addSubview:headImage];
    [view addSubview:accountButton];
    [view addSubview:searchButton];
    [view addSubview:checkoutButton];
    [view addSubview:chatButton];
    [view addSubview:photoButton];
    
    [self.view addSubview:_customerInfoView = view];
    
}

- (void)updateCustomerInfo
{
    CustomerDoc *customerDoc = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    
    UIImageView *imageView = (UIImageView *)[self.customerInfoView viewWithTag:HeadImageTag];
    [imageView setImageWithURL:[NSURL URLWithString:customerDoc.cus_HeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    
    
    UIView *detailView = (UIView *)[self.customerInfoView viewWithTag:DetailViewTag];
    
    UILabel *nameLabel = (UILabel *)[self.customerInfoView viewWithTag:NameLabelTag];
    nameLabel.text = customerDoc.cus_Name;
    
    UILabel *cardLabel = (UILabel *)[self.customerInfoView viewWithTag:CardLabelTag];
    cardLabel.text = customerDoc.cus_LoginStarMob;
    
    UIButton *accountButton = (UIButton *)[self.customerInfoView viewWithTag:AccountButtonTag];
    
    UIButton *searchButton = (UIButton *)[self.customerInfoView viewWithTag:SearchButtonTag];
    
    UIButton *checkoutButton = (UIButton *)[self.customerInfoView viewWithTag:CheckOutButtonTag];
    
    UIButton *addNewButton = (UIButton *)[self.customerInfoView viewWithTag:AddNewCustomerButtonTag];

    UIButton *customerInfoButton = (UIButton *)[self.customerInfoView viewWithTag:CustomerInfoTag];
    UIButton *customerAccountButton = (UIButton *)[self.customerInfoView viewWithTag:CustomerAccountTag];
    UIButton *customerOrderButton = (UIButton *)[self.customerInfoView viewWithTag:CustomerOrderTag];
    UIButton *chatButton = (UIButton *)[self.customerInfoView viewWithTag:ChatButtonTag];
    UIButton *photoButton = (UIButton *)[self.customerInfoView viewWithTag:PhotoButtonTag];

    //统计
     UIButton *statisticsButton = (UIButton *)[self.customerInfoView viewWithTag:StatisticsTag];
    
    UITextField *text = (UITextField *)[self.customerInfoView viewWithTag:TextFieldSearchTag];
    
    
    if (customerDoc) {
        searchButton.hidden = YES;
        addNewButton.hidden = YES;
        text.hidden = YES;

        customerInfoButton.hidden = NO;

        chatButton.hidden = NO;

        imageView.hidden = NO;
        accountButton.hidden = NO;
        detailView.hidden = NO;
        nameLabel.hidden = NO;
        cardLabel.hidden = NO;
        checkoutButton.hidden = NO;
        customerAccountButton.hidden = NO;
        customerOrderButton.hidden = NO;
        statisticsButton.hidden = NO;
        photoButton.hidden = NO;

        [accountButton setTitle:[NSString stringWithFormat:@"预约(%ld)",(long)customerDoc.cus_appointCount] forState:UIControlStateNormal];
        [checkoutButton setTitle:[NSString stringWithFormat:@"结账(%ld)",(long)customerDoc.cus_checkoutCount] forState:UIControlStateNormal];

#pragma mark 权限 No.5顾客信息页 订单按钮
        if (![[PermissionDoc sharePermission] rule_Order_Read]) {
            customerOrderButton.enabled = NO;
            statisticsButton.enabled = NO;
            photoButton.enabled = NO;

            accountButton.enabled = NO;
        } else {
            customerOrderButton.enabled = YES;
            statisticsButton.enabled = YES;
            photoButton.enabled = YES;

            accountButton.enabled = YES;
        }
        if (![[PermissionDoc sharePermission] rule_Payment_Use]) {
            checkoutButton.enabled = NO;
        } else {
            checkoutButton.enabled = YES;
        }
        if (![[PermissionDoc sharePermission] rule_ECard_Read]) {
            customerAccountButton.enabled = NO;
        } else {
            customerAccountButton.enabled = YES;
        }
        if (customerDoc.editStatus & CustomerEditStatusBasic) {
            customerInfoButton.enabled = YES;
        } else {
            customerInfoButton.enabled = NO;
        }
    } else {
        
        addNewButton.hidden = NO;
        searchButton.hidden = NO;
        text.hidden = NO;
        if ([[PermissionDoc sharePermission] rule_CustomerInfo_Write]) {
            addNewButton.enabled = YES;
        } else {
            addNewButton.enabled = NO;
        }
        
        if ([[PermissionDoc sharePermission] rule_MyCustomer_Read]) {
            searchButton.enabled = YES;
            text.enabled = YES;
        } else {
            searchButton.enabled = NO;
            text.enabled = NO;
        }
        
        imageView.hidden = YES;
        detailView.hidden = YES;
        checkoutButton.hidden = YES;
        accountButton.hidden = YES;
        
        customerInfoButton.hidden = YES;
        customerAccountButton.hidden = YES;
        customerOrderButton.hidden = YES;
        photoButton.hidden = YES;

        statisticsButton.hidden = YES;

        chatButton.hidden = YES;

        nameLabel.hidden = YES;
        cardLabel.hidden = YES;
    }
}
@end
