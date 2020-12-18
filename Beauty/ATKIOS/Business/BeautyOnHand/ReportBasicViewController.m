//
//  ReportBasicViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//


#import "ReportBasicViewController.h"
#import "ReportDetailViewController.h"
#import "ReportCustomerDetailViewController.h"
#import "NavigationView.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "ReportBasicDoc.h"
#import "UILabel+InitLabel.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "GPBHTTPClient.h"
#import "EcardReportViewController.h"
#import "UIButton+InitButton.h"
#import "UIButton+WebCache.h"
#import "StatementCategoryDoc.h"
#import "ReportBasicTopView.h"

typedef NS_ENUM(NSInteger, ReportCellStyle) {
    ReportCellTitleWhite,
    ReportCellTitleBlue,
    ReportCellTitleDefault,
    ReportCellTitleRed,
    ReportCellTitlWidth
};

typedef NS_ENUM(NSInteger, ProductType) {
    ProductService = 0,
    ProductCommodity = 1
};
@interface ReportBasicViewController () <ReportBasicTopViewDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReportBasicOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetStatementCategory;

@property (assign, nonatomic) NSInteger objectType;
@property (assign, nonatomic) NSInteger accountID;
@property (assign, nonatomic) NSInteger branchID;
@property (assign, nonatomic) NSInteger statementCategoryID;
@property (assign, nonatomic) NSInteger extractItemType;

@property (strong, nonatomic) ReportBasicDoc *reportBasicDoc;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) noCopyTextField *beginTime;
@property (strong, nonatomic) noCopyTextField *endTime;
@property (strong, nonatomic) UILabel *timeGap;
@property (strong, nonatomic) UIButton *queryButton;
@property (strong, nonatomic) UIImageView *queryPad;
@property (strong, nonatomic) UITextField *textField_Selected;
@property (strong, nonatomic)   NavigationView *navigationView;

@property (strong, nonatomic) ReportBasicTopView *basicTopView;


@property (nonatomic,getter=isExpand) BOOL expand;

@property (nonatomic,strong) NSMutableArray *statementCategoryList;

@end

@implementation ReportBasicViewController
@synthesize reportTitle, reportAccountID, reportBranchID;
@synthesize objectType, cycleType, accountID, branchID,statementCategoryID,extractItemType;
@synthesize reportBasicDoc;
@synthesize datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDateBasic, endDateBasic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(cycleType == 4)
//    {
//        [self initialCustomizeQueryPad];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetReportBasicOperation && [_requestGetReportBasicOperation isExecuting]) {
        [_requestGetReportBasicOperation cancel];
    }
    _requestGetReportBasicOperation = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
}

- (void)initData
{
    if ([reportTitle isEqualToString:@"我的报表"]) {
        objectType = 0;
        accountID = ACC_ACCOUNTID;
        branchID  = ACC_BRANCHID;
    } else if ([reportTitle isEqualToString:@"门店报表"]) {
        objectType = 1;
        accountID = ACC_ACCOUNTID;
        branchID  = ACC_BRANCHID;
    } else if ([reportTitle isEqualToString:@"全公司报表"]) {
        objectType = 2;
        accountID = ACC_ACCOUNTID;
        branchID  = ACC_BRANCHID;
    } else if ([reportTitle isEqualToString:@"员工报表"]) {
        objectType = 0;
        accountID = reportAccountID;
        branchID  = ACC_BRANCHID;
    } else if ([reportTitle isEqualToString:@"各门店报表"]) {
        objectType = 1;
        accountID = ACC_ACCOUNTID;
        branchID  = reportBranchID;
    } else if ([reportTitle isEqualToString:@"分组报表"]) {
        objectType = 3;
        branchID = ACC_BRANCHID;
        accountID = reportAccountID;
    }
    
    if (cycleType != 4) {
        self.startDateBasic = [NSDate date];
        self.endDateBasic = [NSDate date];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    self.statementCategoryList = [NSMutableArray array];
  self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:reportTitle];
    self.navigationView.tag = 10;
    [self.view addSubview:self.navigationView];

    UIButton *rightButt = [UIButton buttonTypeRoundedRectWithTitle:@"..." target:self selector:@selector(rightButtEvent:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 64, 0, 44, self.navigationView.frame.size.height) titleColor:BACKGROUND_COLOR_TITLE backgroudColor:nil cornerRadius:1];
    rightButt.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    rightButt.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [self.navigationView addSubview:rightButt];
    
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, self.navigationView.frame.size.height + self.navigationView.frame.origin.y, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, self.navigationView.frame.size.height + self.navigationView.frame.origin.y, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    _tableView.tag = 101;
    
    if (cycleType == 4) {
//        [self performSelector:@selector(changeCycleTypeAction:) withObject:segmentC];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //默认值
    extractItemType = 1; // 服务和商品
    statementCategoryID = 0; // (0表示全部)
    cycleType = 0; //(日)
    self.expand = YES;

    [self requestGetReportStatementCategory];
    [self requestGetReportBasic:nil withStartTime:[dateFormatter stringFromDate:self.startDateBasic] withEndTime:[dateFormatter stringFromDate:self.endDateBasic]];
    
}
#pragma mark -  tableView 位置
- (void)tableViewFrameWithView:(UIView *)view
{
    _tableView.frame = CGRectMake(5.0f, view.frame.size.height + view.frame.origin.y + 5, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (view.frame.size.height + view.frame.origin.y + 5) - 64.0f -  5.0f);
}

#pragma mark - ReportBasicTopViewDelegate
-(void)ReportBasicTopView:(ReportBasicTopView *)reportBasicTopView repBeginTime:(noCopyTextField *)repBeginTime repEndTime:(noCopyTextField *)repEndTime
{
    self.beginTime = repBeginTime;
    self.endTime = repEndTime;
}
-(void)ReportBasicTopView:(ReportBasicTopView *)reportBasicTopView textField:(UITextField *)textField
{
    if(textField.tag == 102 )
    {
        self.beginTime = (noCopyTextField *)textField;
    }
    else if (textField.tag == 103) {
        self.endTime =  (noCopyTextField *)textField;
    }

        [self initialKeyboard];
        textField_Selected = textField;
        textField.inputAccessoryView = inputAccessoryView;
        textField.inputView = datePicker;
        NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy年MM月dd日"];
        if (theDate != nil && ![theDate  isEqual: @""]) {
            [datePicker setDate:theDate];
        }
}
-(void)ReportBasicTopView:(ReportBasicTopView *)reportBasicTopView selCycleType:(NSInteger)selCycleType selExtractItemType:(NSInteger)selExtractItemType selStatementCategoryID:(NSInteger)selStatementCategoryID
{
    self.expand = !self.expand;
    if (self.basicTopView) {
        [self.basicTopView removeFromSuperview];
        self.basicTopView = nil;
    }
    extractItemType = selExtractItemType;
    cycleType = selCycleType;
    statementCategoryID = selStatementCategoryID;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (cycleType == 4) {
        [self requestGetReportBasic:nil withStartTime:[dateFormatter stringFromDate:self.startDateBasic] withEndTime:[dateFormatter stringFromDate:self.endDateBasic]];

    }else{
        [self requestGetReportBasic:nil withStartTime:nil withEndTime:nil];
    }
}

#pragma mark - 按钮事件

//rightButt 事件
- (void)rightButtEvent:(UIButton *)sender
{
    if (self.expand) {
        self.expand = !self.expand;
        if (!self.basicTopView) {
            self.basicTopView = [[ReportBasicTopView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 88 * 2 + 44 + 20 + 1)];
            self.basicTopView.delegate = self;
            self.basicTopView.extractItemType = extractItemType;
             self.basicTopView.cycleType = cycleType;
             self.basicTopView.statementCategoryID = statementCategoryID;
            self.basicTopView.startDateBasic = self.startDateBasic;
            self.basicTopView.endDateBasic = self.endDateBasic;
             self.basicTopView.reportTitle = reportTitle;
             self.basicTopView.statementCategoryList = self.statementCategoryList;
            [self.basicTopView initView];
            [self.view addSubview:self.basicTopView];
        }
    }else{
        self.expand = !self.expand;
        [self.basicTopView removeFromSuperview];
        self.basicTopView = nil;
    }
}
- (void)changeCycleTypeAction:(UISegmentedControl *)sender
{
            /*
     *
    cycleType = sender.selectedSegmentIndex;
    int addHeight = 0;
    if(cycleType == 4)
        addHeight = 1;

    NavigationView *navigationView = (NavigationView *)[self.view viewWithTag:10];
 //   NSLog(@"______%ld   , %@",cycleType,navigationView);
    navigationView.frame = CGRectMake(0, 5.f, 312.f, 36.f * (1 + addHeight ));
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height , 310.0f , kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 36.f * addHeight );
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height , 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 36.f * addHeight);
    }
    
    if(cycleType == 4)
    {
        [self initialCustomizeQueryPad];
    }
    else {
        [beginTime setHidden:YES];
        [endTime setHidden:YES];
        [timeGap setHidden:YES];
        [queryButton setHidden:YES];
        [queryPad setHidden:YES];
        [self requestGetReportBasic:nil withStartTime:nil withEndTime:nil];
    }
    */
}
#pragma mark - UITextFieldDelegate

//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    [self initialKeyboard];
//    textField_Selected = textField;
//    textField.inputAccessoryView = inputAccessoryView;
//    textField.inputView = datePicker;
//    NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy年MM月dd日"];
//    if (theDate != nil && ![theDate  isEqual: @""]) {
//        [datePicker setDate:theDate];
//    }
//    return YES;
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    return  YES;
//}
//
#pragma mark - Initial Keyboard
- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        CGRect frame = self.inputView.frame;
        frame.size = [self.datePicker sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!pickerView) {
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [pickerView setShowsSelectionIndicator:YES];
        [pickerView setDelegate:self];
        [pickerView setDataSource:self];
        CGRect frame = self.inputView.frame;
        frame.size = [self.pickerView sizeThatFits:CGSizeZero];
        self.inputView.frame = frame;
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    
    if (!inputAccessoryView) {
        inputAccessoryView = [[UIToolbar alloc] init];
        inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
        inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [inputAccessoryView sizeToFit];
        CGRect frame1 = inputAccessoryView.frame;
        frame1.size.height = 44.0f;
        inputAccessoryView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
        [doneBtn setTintColor:kColor_White];
        
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [inputAccessoryView setItems:array];
    }
}

- (void)dateChanged:(id)sender
{
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = @"yyyy年MM月dd日";

    if(textField_Selected.tag == 102 )
    {
        self.startDateBasic = self.datePicker.date;
        [self.beginTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.startDateBasic]]];
    }
    else if (textField_Selected.tag == 103) {
        self.endDateBasic = self.datePicker.date;
        [self.endTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.endDateBasic]]];

    }
}

- (void)done:(id)sender
{
    [self dateChanged:nil];
    [self.beginTime resignFirstResponder];
    [self.endTime resignFirstResponder];
    [self dismissKeyBoard];
}

#pragma mark - UIPickerViewDataSource && UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kTableView_HeightOfRow;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *valueLabel = [UILabel initNormalLabelWithFrame:view.bounds title:@""];
    [valueLabel setTextAlignment:NSTextAlignmentCenter];
    [valueLabel setFont:kFont_Medium_18];
    [valueLabel setText:[pickerData objectAtIndex:row]];
    return valueLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.textField_Selected setText:[pickerData objectAtIndex:row]];
}

#pragma mark - UITableView 块行 数
- (NSInteger)sectionsCount
{
    NSInteger count = 0;
    switch (extractItemType) {
        case 1:
        {
            count = 6;
        }
            break;
        case 2:
        {
            count = 2;
        }
            break;
        case 3:
        {
            count = 2;
        }
            break;
            
        default:
            break;
    }
    return count;
}
- (NSInteger)rowsCountWithSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (extractItemType) {
        case 1:
        {
            switch (section) {
//                case 0: return 10;
//                case 1: return 10;
//                case 2: return 4;
                case 0: return 13;
                case 1: return 13;
                case 2: return 8;
                case 3: return 4;
                //wugang
                case 4: return 5;
                //wugang
                case 5: return 4;
            }
        }
            break;
        case 2:
        {
            if ([reportTitle isEqualToString:@"我的报表"] || [reportTitle isEqualToString:@"员工报表"] || [reportTitle isEqualToString:@"分组报表"]) {
                switch (section) {
                    case 0: return 3;
                    case 1: return 5;
                }
            }else{
                switch (section) {
                    case 0: return 5;
                    case 1: return 5;
                }

            }
        }
            break;
        case 3:
        {
            switch (section) {
                case 0: return 3;
                case 1: return 5;
            }
        }
            break;
            
        default:
            break;
    }

    return count;
}
- (UITableViewCell *)configurationCellWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UITableViewCell *cell;
    switch (extractItemType) {
        case 1:
        {
            if (indexPath.section == 0) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务销售额" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueAll) andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueCash) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueBank) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueWeChat) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 4:
                        cell = [self tableView:tableView CellWithTitleText:@"支付宝收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueAlipay) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 5:
                        cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueECard) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 6:
                        cell = [self tableView:tableView CellWithTitleText:@"积分抵用" contentText:MoneyFormat(reportBasicDoc.ServiceRevenuePoint) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 7:
                        cell = [self tableView:tableView CellWithTitleText:@"券抵用" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueCoupon) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 8:
                        cell = [self tableView:tableView CellWithTitleText:@"消费贷款" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueLoan) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 9:
                        cell = [self tableView:tableView CellWithTitleText:@"第三方付款" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueThird) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 10:
                        cell = [self tableView:tableView CellWithTitleText:@"其他" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueOther) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 11:
                        cell = [self tableView:tableView CellWithTitleText:@"服务销售分析"];
                        break;
                    case 12:
                        cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                        break;
                        
                }
            }
            
            if (indexPath.section == 1) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"商品销售额" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueAll) andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueCash) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueBank) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueWeChat) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 4:
                        cell = [self tableView:tableView CellWithTitleText:@"支付宝收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueAlipay) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 5:
                        cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueECard) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 6:
                        cell = [self tableView:tableView CellWithTitleText:@"积分抵用" contentText:MoneyFormat(reportBasicDoc.CommodityRevenuePoint) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 7:
                        cell = [self tableView:tableView CellWithTitleText:@"券抵用" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueCoupon) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 8:
                        cell = [self tableView:tableView CellWithTitleText:@"消费贷款" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueLoan) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 9:
                        cell = [self tableView:tableView CellWithTitleText:@"第三方付款" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueThird) andCellStytle:ReportCellTitleDefault];
                        break;

                    case 10:
                        cell = [self tableView:tableView CellWithTitleText:@"其他" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueOther) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 11:
                        cell = [self tableView:tableView CellWithTitleText:@"商品销售分析"];
                        break;
                    case 12:
                        cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                        break;
                }
            }
            if (indexPath.section == 2) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务商品销售" contentText:MoneyFormat(reportBasicDoc.SalesAllIncome) andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.SalesCashIncome) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.SalesBankIncome) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.SalesWeChatIncome) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 4:
                        cell = [self tableView:tableView CellWithTitleText:@"支付宝收入" contentText:MoneyFormat(reportBasicDoc.SalesAlipayIncome) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 5:
                        cell = [self tableView:tableView CellWithTitleText:@"消费贷款" contentText:MoneyFormat(reportBasicDoc.SalesRevenueLoan) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 6:
                        cell = [self tableView:tableView CellWithTitleText:@"第三方付款" contentText:MoneyFormat(reportBasicDoc.SalesRevenueThird) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 7:
                        cell = [self tableView:tableView CellWithTitleText:@"*不含储值卡充值" contentText:@"" andCellStytle:ReportCellTitleRed];
                        break;
                }
            }
            if (indexPath.section == 3) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务操作业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementAll) andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"指定业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementDesigned) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"非指定业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementNotDesigned) andCellStytle:ReportCellTitleDefault];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"*不限次数及0元订单不计入业绩" contentText:@"" andCellStytle:ReportCellTitleRed];
                        break;
                }
            }
            if (indexPath.section == 4) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务操作次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesAll] andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"指定次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesDesigned] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"非指定次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesNotDesigned] andCellStytle:ReportCellTitleDefault];
                        break;
                    //wugang
                    case 3:
                        if (reportBasicDoc.TreatmentTimesAll == 0){
                            _TreatmentRateDesigned = 0;
                        }else{
                            _TreatmentRateDesigned = (long) (reportBasicDoc.TreatmentTimesDesigned * 100 /  reportBasicDoc.TreatmentTimesAll);
                        }
                        cell = [self tableView:tableView CellWithTitleText:@"指定率" contentText:[NSString stringWithFormat:@"%ld%%", (long)_TreatmentRateDesigned] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 4:
                    //wugang
                        cell = [self tableView:tableView CellWithTitleText:@"服务次数分析"];
                        break;
                }
            }
            
            if (indexPath.section == 5) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务操作金额/次数分析" contentText:@"" andCellStytle:ReportCellTitlWidth];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"服务操作分析"];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"*不限次数及0元订单不计入业绩" contentText:@"" andCellStytle:ReportCellTitleRed];
                        break;
                }
            }
            
            
        }
            break;
        case 2:
        {
            if ([reportTitle isEqualToString:@"我的报表"] || [reportTitle isEqualToString:@"员工报表"] || [reportTitle isEqualToString:@"分组报表"]) {
                
                if (indexPath.section == 0) {
                    switch (indexPath.row) {
                        case 0:
                            cell = [self tableView:tableView CellWithTitleText:@"服务客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountAll] andCellStytle:ReportCellTitleWhite];
                            break;
                        case 1:
                            cell = [self tableView:tableView CellWithTitleText:@"女性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountFemale] andCellStytle:ReportCellTitleDefault];
                            break;
                        case 2:
                            cell = [self tableView:tableView CellWithTitleText:@"男性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountMale] andCellStytle:ReportCellTitleDefault];
                            break;
                    }
                }
                
                if (indexPath.section == 1) {
                    switch (indexPath.row) {
                        case 0:
                            cell = [self tableView:tableView CellWithTitleText:@"顾客数" contentText:@"" andCellStytle:ReportCellTitleWhite];
                            break;
                        case 1:
                            cell = [self tableView:tableView CellWithTitleText:@"新增顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddCustomer] andCellStytle:ReportCellTitleDefault];
                            break;
                        case 2:
                            cell = [self tableView:tableView CellWithTitleText:@"新增有消费顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddEffectCustomer] andCellStytle:ReportCellTitleDefault];
                            break;
                        case 3:
                            cell = [self tableView:tableView CellWithTitleText:@"再次消费老顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.OldEffectCustomer] andCellStytle:ReportCellTitleDefault];
                            break;
                        case 4:
                            cell = [self tableView:tableView CellWithTitleText:@"*含课程不含充值" contentText:@"" andCellStytle:ReportCellTitleRed];
                            break;
                    }
                }
            }else{
                if (indexPath.section == 0) { // 新增储值卡销售
                    switch (indexPath.row) {
                        case 0:
                            cell = [self tableView:tableView CellWithTitleText:@"储值卡销售" contentText:MoneyFormat(reportBasicDoc.EcardSalesAllIncome) andCellStytle:ReportCellTitleWhite];
                            break;
                        case 1:
                            cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.EcardSalesCashIncome) andCellStytle:ReportCellTitleDefault];
                            break;
                        case 2:
                            cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.EcardSalesBankIncome) andCellStytle:ReportCellTitleDefault];
                            break;
                        case 3:
                            cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.EcardWeChatIncome) andCellStytle:ReportCellTitleDefault];
                            break;
                        case 4:
                            cell = [self tableView:tableView CellWithTitleText:@"支付宝收入" contentText:MoneyFormat(reportBasicDoc.EcardAlipayIncome) andCellStytle:ReportCellTitleDefault];
                            break;
                    }
                }
                if (indexPath.section == 1) {
                    switch (indexPath.row) {
                        case 0:
                            cell = [self tableView:tableView CellWithTitleText:@"储值卡净变动" contentText:MoneyFormat(reportBasicDoc.ECardBalance) andCellStytle:ReportCellTitleWhite];
                            break;
                        case 1:
                            cell = [self tableView:tableView CellWithTitleText:@"储值卡销售" contentText:MoneyFormat(reportBasicDoc.ECardSales) andCellStytle:ReportCellTitleDefault];
                            break;
                        case 2:
                            cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.ECardConsume) andCellStytle:ReportCellTitleDefault];
                            break;
                        case 3:
                            cell = [self tableView:tableView CellWithTitleText:@"顾客余额变动分析"];
                            break;
                        case 4:
                            cell = [self tableView:tableView CellWithTitleText:@"*不含转入、赠送及直扣" contentText:@"" andCellStytle:ReportCellTitleRed];
                            break;
                            
                    }
                }
            }
            
            
            
            
        }
            break;
        case 3:
        {
            if (indexPath.section == 0) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"服务客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountAll] andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"女性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountFemale] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"男性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountMale] andCellStytle:ReportCellTitleDefault];
                        break;
                }
            }
            
            if (indexPath.section == 1) {
                switch (indexPath.row) {
                    case 0:
                        cell = [self tableView:tableView CellWithTitleText:@"顾客数" contentText:@"" andCellStytle:ReportCellTitleWhite];
                        break;
                    case 1:
                        cell = [self tableView:tableView CellWithTitleText:@"新增顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddCustomer] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 2:
                        cell = [self tableView:tableView CellWithTitleText:@"新增有消费顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddEffectCustomer] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 3:
                        cell = [self tableView:tableView CellWithTitleText:@"再次消费老顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.OldEffectCustomer] andCellStytle:ReportCellTitleDefault];
                        break;
                    case 4:
                        cell = [self tableView:tableView CellWithTitleText:@"*含课程不含充值" contentText:@"" andCellStytle:ReportCellTitleRed];
                        break;
                }
            }
            
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)enterPageViewControllerWithIndexPath:(NSIndexPath *)indexPath
{
    switch (extractItemType) {
        case 1:
        {
            if (indexPath.section == 0 && indexPath.row == 11) { // 服务销售分析
                [self serviceSaleReport:ProductService];
            }
            if (indexPath.section == 1 && indexPath.row == 11) { // 商品销售分析
                [self serviceSaleReport:ProductCommodity];
            }
            
            if (indexPath.section == 0 && indexPath.row == 12) { // 顾客消费分析
                ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
                [self customerExpendReport:type];
            }
            if (indexPath.section == 1 && indexPath.row == 12) { // 顾客消费分析
                ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
                [self customerExpendReport:type];
            }
            //wugang
            if (indexPath.section == 4 && indexPath.row == 4) { //服务次数
            //wugang
                [self serviceCountReport];
            }
            if (indexPath.section == 5) {
                if (indexPath.row == 1) {  //服务操作分析
                    [self serviceAnalyze];
                }
                if (indexPath.row == 2) {  //顾客消费分析
                    [self customerOpp];
                }
            }

            
//            if (((indexPath.section == 0 || indexPath.section == 1) && indexPath.row != 0) ||(indexPath.section == 3 && indexPath.row == 3) || (indexPath.section == 5 && indexPath.row == 3) || (indexPath.section == 6 && indexPath.row != 0)) {
//                if ((indexPath.section == 0 || indexPath.section == 1 )&& indexPath.row == 8) {
//                    ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
//                    [self serviceSaleReport:type];
//                    return;
//                }
//                
//                if ((indexPath.section == 0 || indexPath.section == 1 )&& indexPath.row == 9) {
//                    ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
//                    [self customerExpendReport:type];
//                    return;
//                }
//                
////                if (indexPath.section == 4 && indexPath.row == 3) {
////                    [self serviceCountReport];
////                    return;
////                }
////                if (indexPath.section == 5) {
////                    if (indexPath.row == 1) {
////                        [self serviceAnalyze];
////                    }
////                    if (indexPath.row == 2) {
////                        [self customerOpp];
////                    }
////                    return;
////                }
//            }
        }
            break;
        case 2:
        {
            if (indexPath.section == 1 && indexPath.row == 3) {
                [self gotoEcardReport];
                return;
            }
            
        }
            break;
        case 3:
        {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self sectionsCount];
//    if (reportBasicDoc){
//        if([reportTitle isEqualToString:@"门店报表"]){
//            return 10;
//        }else{
//            return 9;
//        }
//    } else {
//        return 0;
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (reportBasicDoc){
//        if([reportTitle isEqualToString:@"我的报表"]){
//                if (section == 3 || section == 4 ) {
//                    return 0.1f;
//                }
//        }
//    }
    return kTableView_Margin_TOP;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self rowsCountWithSection:section];
//    switch (section) {
//        case 0: return 10;
//        case 1: return 10;
//        case 2: return 5;
//    }
//    if([reportTitle isEqualToString:@"门店报表"]){
//            switch (section) {
//                case 3:return 4; //  新增  储值卡
//            }
//        }else{
//            switch (section) {
//                case 3:return 0;
//            }
//        }
//    switch (section) {
//        case 3 + 1: return objectType == 1 ? 5: 0;
//        case 4 + 1: return 4;
//        case 5 + 1: return 4;
//        case 6 + 1: return 4;
//        case 7 + 1: return 3;
//        case 8 + 1: return 5;
//    }
//        return 0;
}
        

//        case 2: return 5;
//        case 3: return objectType == 1 ? 5: 0;
//        case 4: return 4;
//        case 5: return 4;
//        case 6: return 4;
//        case 7: return 3;
//        case 8: return 5;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     *
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务销售额" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueAll) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueCash) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueBank) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueWeChat) andCellStytle:ReportCellTitleDefault];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueECard) andCellStytle:ReportCellTitleDefault];
                break;
            case 5:
                cell = [self tableView:tableView CellWithTitleText:@"积分抵用" contentText:MoneyFormat(reportBasicDoc.ServiceRevenuePoint) andCellStytle:ReportCellTitleDefault];
                break;
            case 6:
                cell = [self tableView:tableView CellWithTitleText:@"券抵用" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueCoupon) andCellStytle:ReportCellTitleDefault];
                break;
            case 7:
                cell = [self tableView:tableView CellWithTitleText:@"其他" contentText:MoneyFormat(reportBasicDoc.ServiceRevenueOther) andCellStytle:ReportCellTitleDefault];
                break;
            case 8:
                cell = [self tableView:tableView CellWithTitleText:@"服务销售分析"];
                break;
            case 9:
                cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                break;

        }
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"商品销售额" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueAll) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueCash) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueBank) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueWeChat) andCellStytle:ReportCellTitleDefault];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueECard) andCellStytle:ReportCellTitleDefault];
                break;
            case 5:
                cell = [self tableView:tableView CellWithTitleText:@"积分抵用" contentText:MoneyFormat(reportBasicDoc.CommodityRevenuePoint) andCellStytle:ReportCellTitleDefault];
                break;
            case 6:
                cell = [self tableView:tableView CellWithTitleText:@"券抵用" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueCoupon) andCellStytle:ReportCellTitleDefault];
                break;
            case 7:
                cell = [self tableView:tableView CellWithTitleText:@"其他" contentText:MoneyFormat(reportBasicDoc.CommodityRevenueOther) andCellStytle:ReportCellTitleDefault];
                break;
            case 8:
                cell = [self tableView:tableView CellWithTitleText:@"商品销售分析"];
                break;
            case 9:
                cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                break;
        }
    }
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务商品销售" contentText:MoneyFormat(reportBasicDoc.SalesAllIncome) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.SalesCashIncome) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.SalesBankIncome) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.SalesWeChatIncome) andCellStytle:ReportCellTitleDefault];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"*不含储值卡充值" contentText:@"" andCellStytle:ReportCellTitleRed];
                break;
        }
    }
    if (indexPath.section == 3) { // 新增储值卡销售
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡销售" contentText:MoneyFormat(reportBasicDoc.EcardSalesAllIncome) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"现金收入" contentText:MoneyFormat(reportBasicDoc.EcardSalesCashIncome) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"银行卡收入" contentText:MoneyFormat(reportBasicDoc.EcardSalesBankIncome) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"微信收入" contentText:MoneyFormat(reportBasicDoc.EcardWeChatIncome) andCellStytle:ReportCellTitleDefault];
                break;
        }
    }
    if (indexPath.section == 3 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡净变动" contentText:MoneyFormat(reportBasicDoc.ECardBalance) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡销售" contentText:MoneyFormat(reportBasicDoc.ECardSales) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"储值卡消耗" contentText:MoneyFormat(reportBasicDoc.ECardConsume) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"顾客余额变动分析"];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"*不含转入、赠送及直扣" contentText:@"" andCellStytle:ReportCellTitleRed];
                break;

        }
    }
    
    if (indexPath.section == 4 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务操作业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementAll) andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"指定业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementDesigned) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"非指定业绩" contentText:MoneyFormat(reportBasicDoc.ServiceAchievementNotDesigned) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"*不限次数及0元订单不计入业绩" contentText:@"" andCellStytle:ReportCellTitleRed];
                break;
        }
    }
    if (indexPath.section == 5 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务操作次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesAll] andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"指定次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesDesigned] andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"非指定次数" contentText:[NSString stringWithFormat:@"%ld次", (long)reportBasicDoc.TreatmentTimesNotDesigned] andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"服务次数分析"];
                break;
        }
    }
    
    if (indexPath.section == 6 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务操作金额/次数分析" contentText:@"" andCellStytle:ReportCellTitlWidth];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"服务操作分析"];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"顾客消费分析"];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"*不限次数及0元订单不计入业绩" contentText:@"" andCellStytle:ReportCellTitleRed];
                break;
        }
    }
    
    if (indexPath.section == 7 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"服务客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountAll] andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"女性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountFemale] andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"男性客数" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.ServiceCustomerCountMale] andCellStytle:ReportCellTitleDefault];
                break;
        }
    }
    
    if (indexPath.section == 8 + 1) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"顾客数" contentText:@"" andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"新增顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddCustomer] andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"新增有消费顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.NewAddEffectCustomer] andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"再次消费老顾客" contentText:[NSString stringWithFormat:@"%ld人", (long)reportBasicDoc.OldEffectCustomer] andCellStytle:ReportCellTitleDefault];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"*含课程不含充值" contentText:@"" andCellStytle:ReportCellTitleRed];
                break;
        }
    }
    
    return cell;
     */
    
   UITableViewCell *cell = [self configurationCellWithIndexPath:indexPath tableView:tableView];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView CellWithTitleText:(NSString *)title {
    static NSString *cellIndentify = @"ReportCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:101];
    titleLable.font = kFont_Light_16;
    valueLabel.font = kFont_Light_16;
    titleLable.text = title;
    valueLabel.text = @"";
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView CellWithTitleText:(NSString *)title contentText:(NSString *)content andCellStytle:(ReportCellStyle)stytle {
    static NSString *cellIndentify = @"ReportCell0";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:101];
    titleLable.font = kFont_Light_16;
    valueLabel.font = kFont_Light_16;
    CGRect frameTitle = titleLable.frame;
    frameTitle.size.width = 145;
    titleLable.frame = frameTitle;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;
    switch (stytle) {
        case ReportCellTitleWhite:
            cell.backgroundColor = BACKGROUND_COLOR_TITLE;
            titleLable.textColor = [UIColor whiteColor];
            valueLabel.textColor = [UIColor whiteColor];
            break;
        case ReportCellTitleBlue:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = kColor_LightBlue;
            valueLabel.textColor = [UIColor blackColor];
            break;
        case ReportCellTitleDefault:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = [UIColor blackColor];
            valueLabel.textColor = [UIColor blackColor];
            break;
        case ReportCellTitleRed:
            cell.backgroundColor = [UIColor whiteColor];
            frameTitle.size.width = 300;
            titleLable.frame = frameTitle;
            titleLable.textColor = [UIColor redColor];
            valueLabel.textColor = [UIColor blackColor];
            break;
        case ReportCellTitlWidth:
            cell.backgroundColor = BACKGROUND_COLOR_TITLE;
            frameTitle.size.width = 300;
            titleLable.frame = frameTitle;
            titleLable.textColor = [UIColor whiteColor];
            valueLabel.textColor = [UIColor whiteColor];
            break;
        default:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = [UIColor blackColor];
            valueLabel.textColor = [UIColor blackColor];
            break;
    }
    
    titleLable.text = title;
    valueLabel.text = content;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self enterPageViewControllerWithIndexPath:indexPath];
    /*
     *
    if (((indexPath.section == 0 || indexPath.section == 1) && indexPath.row != 0) ||(indexPath.section == 3 && indexPath.row == 3) || (indexPath.section == 5 && indexPath.row == 3) || (indexPath.section == 6 && indexPath.row != 0)) {
        
        if (indexPath.section == 3 && indexPath.row == 3) {
            [self gotoEcardReport];
            return;
        }
        
        if ((indexPath.section == 0 || indexPath.section == 1 )&& indexPath.row == 8) {
            ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
            [self serviceSaleReport:type];
            return;
        }
        
        if ((indexPath.section == 0 || indexPath.section == 1 )&& indexPath.row == 9) {
            ProductType type = indexPath.section == 0 ? ProductService : ProductCommodity;
            [self customerExpendReport:type];
            return;
        }
        
        if (indexPath.section == 5 && indexPath.row == 3) {
            [self serviceCountReport];
            return;
        }
        
        if (indexPath.section == 6) {
            if (indexPath.row == 1) {
                [self serviceAnalyze];
            }
            if (indexPath.row == 2) {
                [self customerOpp];
            }
            return;
        }
    }
     */
    
}


#pragma mark gotoEcardReport
#pragma mark --顾客余额变动分析
- (void)gotoEcardReport {
    EcardReportViewController *ecardReport = [[EcardReportViewController alloc] init];
    ecardReport.date = cycleType;

    if (cycleType == 4) {
        NSMutableString *start = [NSMutableString stringWithString:beginTime.text];
        [start replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
        [start replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
        [start deleteCharactersInRange: [start rangeOfString: @"日"]];
        
        NSMutableString *end = [NSMutableString stringWithString:endTime.text];
        [end replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
        [end replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
        [end deleteCharactersInRange: [end rangeOfString: @"日"]];
        
        ecardReport.startTime = start;
        ecardReport.endTime = end;
        ecardReport.titleString = @"顾客余额变动分析";
        
    } else {
        ecardReport.titleString = [NSString stringWithFormat:@"顾客余额变动分析(%@)", @[@"日", @"月", @"季", @"年"][cycleType]];
        ecardReport.startTime = @"";
        ecardReport.endTime = @"";
    }
    
    [self.navigationController pushViewController:ecardReport animated:YES];

}

#pragma mark --服务、商品销售分析
- (void)serviceSaleReport:(ProductType)type {

    ReportDetailViewController *reportDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    if(cycleType == 4){
        reportDetail.beginTime = [[noCopyTextField alloc] init];
        reportDetail.beginTime.text = beginTime.text;
        
        if (IOS7 || IOS8) {
            reportDetail.beginTime.tintColor = [UIColor whiteColor];
            reportDetail.endTime.tintColor = [UIColor whiteColor];
        }
        reportDetail.endTime = [[noCopyTextField alloc] init];
        reportDetail.endTime.text = endTime.text;
    } else {
        reportDetail.beginTime = nil;
        reportDetail.endTime = nil;
    }
    
    reportDetail.branchID = branchID;
    reportDetail.accountID = accountID;
    reportDetail.objectType = objectType;
    reportDetail.cycleType = cycleType;
    reportDetail.statementCategoryID = statementCategoryID;


    reportDetail.productType = type;
    reportDetail.orderType = 1;
    reportDetail.itemType = 0;
    
    switch (type) {
        case ProductService:
            reportDetail.reportTitle = @"服务销售量/金额";
            reportDetail.totalMoney = reportBasicDoc.ServiceRevenue;
            break;
        case ProductCommodity:
            reportDetail.reportTitle = @"商品销售量/金额";
            reportDetail.totalMoney = reportBasicDoc.CommodityRevenue;
            break;
    }
    
    [self.navigationController pushViewController:reportDetail animated:YES];
}

//服务次数分析  顾客消费分析 调用 ReportCustomerDetailViewController
#pragma mark --顾客消费分析
- (void)customerExpendReport:(ProductType)type {
    ReportCustomerDetailViewController *reportCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportCustomerDetailViewController"];
    if(cycleType == 4){
        reportCustomer.beginTime = [[noCopyTextField alloc] init];
        reportCustomer.beginTime.text = beginTime.text;
        
        if (IOS7 || IOS8) {
            reportCustomer.beginTime.tintColor = [UIColor whiteColor];
            reportCustomer.endTime.tintColor = [UIColor whiteColor];
        }
        reportCustomer.endTime = [[noCopyTextField alloc] init];
        reportCustomer.endTime.text = endTime.text;
    } else {
        reportCustomer.beginTime = nil;
        reportCustomer.endTime = nil;
    }
    
    reportCustomer.branchID = branchID;
    reportCustomer.accountID = accountID;
    reportCustomer.objectType = objectType;
    reportCustomer.cycleType = cycleType;
    reportCustomer.statementCategoryID = statementCategoryID;


    reportCustomer.productType = type;
    reportCustomer.orderType = 0;
    reportCustomer.itemType = 0;

    switch (type) {
        case ProductService:
            reportCustomer.reportTitle = @"服务消费额";
            reportCustomer.totalMoney = reportBasicDoc.ServiceRevenue;
            break;
        case ProductCommodity:
            reportCustomer.reportTitle = @"商品消费额";
            reportCustomer.totalMoney = reportBasicDoc.CommodityRevenue;
            break;
    }
    
    [self.navigationController pushViewController:reportCustomer animated:YES];
}

#pragma mark --服务操作次数分析
- (void)serviceCountReport {
    ReportCustomerDetailViewController *reportCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportCustomerDetailViewController"];
    if(cycleType == 4){
        reportCustomer.beginTime = [[noCopyTextField alloc] init];
        reportCustomer.beginTime.text = beginTime.text;
        
        if (IOS7 || IOS8) {
            reportCustomer.beginTime.tintColor = [UIColor whiteColor];
            reportCustomer.endTime.tintColor = [UIColor whiteColor];
        }
        reportCustomer.endTime = [[noCopyTextField alloc] init];
        reportCustomer.endTime.text = endTime.text;
    } else {
        reportCustomer.beginTime = nil;
        reportCustomer.endTime = nil;
    }

    reportCustomer.branchID = branchID;
    reportCustomer.accountID = accountID;
    reportCustomer.objectType = objectType;
    reportCustomer.cycleType = cycleType;
    reportCustomer.statementCategoryID = statementCategoryID;

    reportCustomer.orderType= 1;
    reportCustomer.itemType = 2;
    reportCustomer.reportTitle = @"服务次数";
    reportCustomer.totalCases = reportBasicDoc.TreatmentTimesAll;
    
    [self.navigationController pushViewController:reportCustomer animated:YES];

}

// itemType 4服务操作分析 5顾客消费分析
#pragma mark --服务操作金额/次数
#pragma mark --服务操作分析
- (void)serviceAnalyze {
    ReportDetailViewController *reportDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    if(cycleType == 4){
        reportDetail.beginTime = [[noCopyTextField alloc] init];
        reportDetail.beginTime.text = beginTime.text;
        
        if (IOS7 || IOS8) {
            reportDetail.beginTime.tintColor = [UIColor whiteColor];
            reportDetail.endTime.tintColor = [UIColor whiteColor];
        }
        reportDetail.endTime = [[noCopyTextField alloc] init];
        reportDetail.endTime.text = endTime.text;
    } else {
        reportDetail.beginTime = nil;
        reportDetail.endTime = nil;
    }
    
    reportDetail.branchID = branchID;
    reportDetail.accountID = accountID;
    reportDetail.objectType = objectType;
    reportDetail.cycleType = cycleType;
    reportDetail.statementCategoryID = statementCategoryID;

    reportDetail.orderType= 1;
    reportDetail.itemType = 4;
    reportDetail.reportTitle = @"服务操作";
    [self.navigationController pushViewController:reportDetail animated:YES];
}

- (void)customerOpp {
    ReportCustomerDetailViewController *reportCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportCustomerDetailViewController"];
    if(cycleType == 4){
        reportCustomer.beginTime = [[noCopyTextField alloc] init];
        reportCustomer.beginTime.text = beginTime.text;
        
        if (IOS7 || IOS8) {
            reportCustomer.beginTime.tintColor = [UIColor whiteColor];
            reportCustomer.endTime.tintColor = [UIColor whiteColor];
        }
        reportCustomer.endTime = [[noCopyTextField alloc] init];
        reportCustomer.endTime.text = endTime.text;
    } else {
        reportCustomer.beginTime = nil;
        reportCustomer.endTime = nil;
    }
    
    reportCustomer.branchID = branchID;
    reportCustomer.accountID = accountID;
    reportCustomer.objectType = objectType;
    reportCustomer.cycleType = cycleType;
    reportCustomer.statementCategoryID = statementCategoryID;

    reportCustomer.productType = 0;
    reportCustomer.itemType = 5;
    reportCustomer.reportTitle = @"顾客消费";

    [self.navigationController pushViewController:reportCustomer animated:YES];

}

#pragma mark - other
-(void)reportQueryCustomize
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self requestGetReportBasic:nil withStartTime:[dateFormatter stringFromDate:self.startDateBasic] withEndTime:[dateFormatter stringFromDate:self.endDateBasic]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 接口

- (void)requestGetReportBasic:(id)nothing withStartTime:(NSString *)start withEndTime:(NSString *)end
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"ExtractItemType\":%ld,\"StatementCategoryID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"ObjectType\":%ld}",(long)extractItemType,(long)statementCategoryID, (long)branchID, (long)accountID, (long)cycleType, start ? start: @"", end ? end: @"",(long)objectType];
    _requestGetReportBasicOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getReportBasic_2_1" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            reportBasicDoc = [[ReportBasicDoc alloc] initWithDictionary:data];
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)requestGetReportStatementCategory
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetStatementCategory = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Report/GetStatementCategory"  andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
            [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *temps = (NSArray *)data;
                if (temps.count > 0) {
                    for (int i  = 0 ; i < temps.count ; i++) {
                        StatementCategoryDoc *statementDoc = [[StatementCategoryDoc alloc]initWithDictionary:[data objectAtIndex:i]];
                        [self.statementCategoryList addObject:statementDoc];
                    }
                }
            }
            // 插入一个全部的数据
            StatementCategoryDoc *statementDoc = [[StatementCategoryDoc alloc]init];
            statementDoc.ID = 0;
            statementDoc.CategoryName = @"全部";
            [self.statementCategoryList insertObject:statementDoc atIndex:0];
            
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
}

@end
