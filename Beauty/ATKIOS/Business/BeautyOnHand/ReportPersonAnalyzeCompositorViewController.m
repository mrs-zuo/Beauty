//
//  ReportPersonAnalyzeCompositorViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20


#import "ReportPersonAnalyzeCompositorViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "ReportPersonAnalyzeDetailsViewController.h"
#import "ReportPersonCompositorTableViewCell.h"
#import "UIButton+InitButton.h"
//->Ver.010
#import "ReportCountTopView.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "UILabel+InitLabel.h"

//@interface ReportPersonAnalyzeCompositorViewController () <UITableViewDataSource,UITableViewDelegate>
@interface ReportPersonAnalyzeCompositorViewController () <UITableViewDataSource,UITableViewDelegate,ReportCountTopViewDelegate>
//<-Ver.010

{
    UITableView *productTableView;
    NSMutableArray *productData;
    AFHTTPRequestOperation *_requestBranchDataStatisticsListOperation;
    
    NSMutableArray *btnTitleData;
    NSMutableArray *btnData;
    NSInteger currentSelectButtonTag;
    
}
//->Ver.010
@property (nonatomic,getter=isExpand) BOOL expand;
@property (strong, nonatomic) ReportCountTopView *basicTopView;
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
@property (nonatomic, strong) NSDate *startDateBasic;
@property (nonatomic, strong) NSDate *endDateBasic;
@property (assign, nonatomic) NSInteger cycleType;
@property (assign, nonatomic) NSInteger objectType;
@property (assign, nonatomic) NSInteger accountID;
@property (assign, nonatomic) NSInteger branchID;
@property (assign, nonatomic) NSInteger statementCategoryID;
@property (assign, nonatomic) NSInteger extractItemType;
@property (strong, nonatomic) NavigationView *navigationView;
@property (strong, nonatomic) NSString *reportTitle;
@property (assign, nonatomic) NSInteger reportBranchID;
@property (assign, nonatomic) NSInteger reportAccountID;

@property (nonatomic,strong) NSMutableArray *statementCategoryList;
//<-Ver.010
@end

@implementation ReportPersonAnalyzeCompositorViewController
//->Ver.010
@synthesize reportTitle, reportAccountID, reportBranchID;
@synthesize datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDateBasic, endDateBasic;
@synthesize objectType, cycleType, accountID, branchID,statementCategoryID,extractItemType;
//<-Ver.010

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self requestWithObjectType:1];
    
}
#pragma mark -  初始化
-(void)initView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"员工业绩数据统计"];
    [self.view addSubview:navigationView];
    
    //->Ver.010
    UIButton *rightButt = [UIButton buttonTypeRoundedRectWithTitle:@"..." target:self selector:@selector(rightButtEvent:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 50, 0, 44, 44) titleColor:BACKGROUND_COLOR_TITLE backgroudColor:nil cornerRadius:1];
    rightButt.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    rightButt.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [self.view addSubview:rightButt];
    
    //<-Ver.010
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, self.view.frame.size.width - 10, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"员工业绩排行榜"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [self.view addSubview:viewLine];
    [self.view addSubview:lab];
    
    productTableView = [[UITableView alloc]initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 41, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f - 40.0f - 41  - 5) style:UITableViewStyleGrouped];
    productTableView.delegate = self;
    productTableView.dataSource = self;
    productTableView.separatorColor = kTableView_LineColor;
    productTableView.backgroundView = nil;
    productTableView.backgroundColor = nil;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        productTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    if ((IOS7 || IOS8)) productTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:productTableView];
    
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width , 40)];
    [self.view addSubview:btnView];
    
    CGFloat btnWidth = (btnView.frame.size.width - 10) / 3;
    for (int i = 0; i < btnTitleData.count; i ++) {
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame =  CGRectMake(5 + (btnWidth * i), 0 , btnWidth, 40);
        [button setTitle:btnTitleData[i] forState:UIControlStateNormal];
        button.tag = i + 1;
        if (button.tag == currentSelectButtonTag) {
            [button setTitleColor:kColor_White forState:UIControlStateNormal];
            button.backgroundColor = kBtn_BuleColor;
        }else{
            [button setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
            button.backgroundColor = kBtn_WitheColor;
        }
        [button addTarget:self action:@selector(performanceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
        [btnData addObject:button];
    }
    
}
- (void)initData
{
    productData = [NSMutableArray array];
    btnTitleData = [NSMutableArray arrayWithObjects:@"操作",@"销售",@"充值", nil];
    btnData = [NSMutableArray array];
    currentSelectButtonTag = 1; // 默认
    //Ver.010
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:[NSDate date]];
    self.startDateBasic = firstDay;
    self.endDateBasic = [NSDate date];
    self.expand = YES;
    self.cycleType = 2; //(月)
    //Ver.010
}
#pragma mark - 改变button样式
- (void)changeButtonStyle
{
    [btnData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)obj;
            if (button.tag == currentSelectButtonTag) {
                [button setTitleColor:kColor_White forState:UIControlStateNormal];
                button.backgroundColor = kBtn_BuleColor;
            }else{
                [button setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
                button.backgroundColor = kBtn_WitheColor;
            }
        }
    }];
}
#pragma mark - 按钮事件
- (void)performanceBtnClick:(UIButton *)sender
{
    currentSelectButtonTag = sender.tag;
    [self changeButtonStyle];
    [self requestWithObjectType:sender.tag];
}
#pragma mark - tableViewDelegate && dataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier = @"ReportPersonCompositorCell";
    ReportPersonCompositorTableViewCell *cell = (ReportPersonCompositorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ReportPersonCompositorTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    [cell ReportPersonCompositorCellWithChart:productData[indexPath.row] type:currentSelectButtonTag];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartModel *chart = productData[indexPath.row];
    ReportPersonAnalyzeDetailsViewController *detailsVC = [[ReportPersonAnalyzeDetailsViewController alloc]init];
    detailsVC.accountID = chart.ObjectId.integerValue;
    detailsVC.personName = chart.ObjectName;
    detailsVC.currentSelectButtonTag = currentSelectButtonTag;
    detailsVC.startDateBasic = self.startDateBasic;
    detailsVC.endDateBasic = self.endDateBasic;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

//->Ver.010

#pragma mark - Initial Keyboard
#pragma mark - ReportCountTopViewDelegate
-(void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView repBeginTime:(noCopyTextField *)repBeginTime repEndTime:(noCopyTextField *)repEndTime
{
    self.beginTime = repBeginTime;
    self.endTime = repEndTime;
    
}
-(void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView textField:(UITextField *)textField
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
-(void)ReportCountTopView:(ReportCountTopView *)ReportCountTopView selCycleType:(NSInteger)selCycleType selExtractItemType:(NSInteger)selExtractItemType selStatementCategoryID:(NSInteger)selStatementCategoryID
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
    [self requestWithObjectType:currentSelectButtonTag];
}


- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [datePicker setMaximumDate:[NSDate date]];
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
        [datePicker setMaximumDate:endDateBasic];
        self.startDateBasic = self.datePicker.date;
        [self.beginTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.startDateBasic]]];
    }
    else if (textField_Selected.tag == 103) {
        [datePicker setMaximumDate:[NSDate date]];
        self.endDateBasic = self.datePicker.date;
        if (self.startDateBasic > self.endDateBasic ){
            self.startDateBasic = self.endDateBasic;
            [self.beginTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.startDateBasic]]];
        }
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


#pragma mark -timePiker
//rightButt 事件
- (void)rightButtEvent:(UIButton *)sender
{
    if (self.expand) {
        self.expand = !self.expand;
        if (!self.basicTopView) {
            //            self.basicTopView = [[ReportCountTopView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 88 * 2 + 44 + 20 + 1)];
            self.basicTopView = [[ReportCountTopView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 88 + 44 + 20 + 1)];
            self.basicTopView.delegate = self;
            self.basicTopView.extractItemType = extractItemType;
            self.basicTopView.cycleType = cycleType;
            self.basicTopView.statementCategoryID = statementCategoryID;
            self.basicTopView.startDateBasic = self.startDateBasic;
            self.basicTopView.endDateBasic = self.endDateBasic;
            self.basicTopView.reportTitle = reportTitle;
            self.basicTopView.statementCategoryList = self.statementCategoryList;
            self.basicTopView.displayType = 1;
            [self.basicTopView initView];
            [self.view addSubview:self.basicTopView];
        }
    }else{
        self.expand = !self.expand;
        [self.basicTopView removeFromSuperview];
        self.basicTopView = nil;
    }
}
//<-Ver.010

#pragma mark -  接口
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (productData) {
        [productData removeAllObjects];
    } else {
        productData = [NSMutableArray array];
    }
    NSInteger ExtractItemType = 2;
    NSInteger MonthCount = 6;
    NSInteger TimeChooseFlag = 0;
    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType];
    NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.endDateBasic dateFormat:@"yyyy-MM-dd"],(long)TimeChooseFlag];
    _requestBranchDataStatisticsListOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Statistics/GetBranchDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                ChartModel *chart = [[ChartModel alloc]init];
                if ([dic objectForKey:@"ObjectCount"]) {
                    chart.ObjectCount = [dic objectForKey:@"ObjectCount"];
                }
                if ([dic objectForKey:@"ObjectName"]) {
                    chart.ObjectName = [dic objectForKey:@"ObjectName"];
                }
                if ([dic objectForKey:@"ConsumeAmout"]) {
                    chart.ConsumeAmout = [dic objectForKey:@"ConsumeAmout"];
                }
                if ([dic objectForKey:@"RechargeAmout"]) {
                    chart.RechargeAmout = [dic objectForKey:@"RechargeAmout"];
                }
                if ([dic objectForKey:@"TotalAmout"]) {
                    chart.TotalAmout = [dic objectForKey:@"TotalAmout"];
                }
                if ([dic objectForKey:@"ObjectId"]) {
                    chart.ObjectId = [dic objectForKey:@"ObjectId"];
                }
                [productData addObject:chart];
            }
            [productTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}



@end
