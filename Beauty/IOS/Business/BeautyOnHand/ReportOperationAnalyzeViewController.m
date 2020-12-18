//
//  ReportOperationAnalyzeViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/7.
//  Copyright © 2016年 ace-009. All rights reserved.
//
#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20

#import "ReportOperationAnalyzeViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "EColumnDataModel.h"
#import "EColumnChartLabel.h"
#import "EFloatBox.h"
#import "EColor.h"
#import "EColumn.h"
#import "EColumnChart.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "UUChart.h"
#include <stdlib.h>
#import "ReportOperationAnalyzeDetailsViewController.h"

//->Ver.010
#import "ReportCountTopView.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"

//@interface ReportOperationAnalyzeViewController ()  <UUChartDataSource>
@interface ReportOperationAnalyzeViewController ()  <UUChartDataSource,ReportCountTopViewDelegate>
//<-Ver.010
{
    
    UUChart *chartView_1;
    UUChart *chartView_2;
    
    
    AFHTTPRequestOperation *_requestBranchDataStatisticsOperation;
    NSMutableArray *periodData;
    
    UIView *subView_1;
    UIView *subView_2;
    
    NSMutableArray *chartData_1;
    NSMutableArray *chartData_2;
    
    NSMutableArray *xTitles;
    
    NSInteger  max_Count;
    double max_Amout;
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

@implementation ReportOperationAnalyzeViewController
//->Ver.010
@synthesize reportTitle, reportAccountID, reportBranchID;
@synthesize datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDateBasic, endDateBasic;
@synthesize objectType, cycleType, accountID, branchID,statementCategoryID,extractItemType;
//<-Ver.010

- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"营业状况统计"];
    UIImage *img = [UIImage imageNamed:@"pop_chart"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //->Ver.010
    //button.frame =  CGRectMake(navigationView.frame.size.width - navigationView.frame.size.height - 5.0f, 0, navigationView.frame.size.height,navigationView.frame.size.height);
    button.frame =  CGRectMake(navigationView.frame.size.width - navigationView.frame.size.height - 50.0f, 0, navigationView.frame.size.height,navigationView.frame.size.height);
    //<-Ver.010
    [button setImage:img forState:UIControlStateNormal];
    [navigationView addSubview:button];
    [button addTarget:self action:@selector(enterDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navigationView];
    
    
    //->Ver.010
    UIButton *rightButt = [UIButton buttonTypeRoundedRectWithTitle:@"..." target:self selector:@selector(rightButtEvent:) frame:CGRectMake(navigationView.frame.size.width - navigationView.frame.size.height - 5.0f, 0, navigationView.frame.size.height,navigationView.frame.size.height) titleColor:BACKGROUND_COLOR_TITLE backgroudColor:nil cornerRadius:1];
    rightButt.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    rightButt.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [self.view addSubview:rightButt];
    
    //<-Ver.010
    
    
    subView_1 = [[UIView alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height + 5, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.height - 64 -navigationView.frame.origin.y - navigationView.frame.size.height - 5) / 2)];
    subView_1.backgroundColor = [UIColor whiteColor];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView_1.frame.size.width, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"服务顾客数量统计"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [subView_1 addSubview:viewLine];
    [subView_1 addSubview:lab];
    [self.view addSubview:subView_1];
    
    subView_2 = [[UIView alloc]initWithFrame:CGRectMake(5, subView_1.frame.origin.y + subView_1.frame.size.height + 5, kSCREN_BOUNDS.size.width - 10,(kSCREN_BOUNDS.size.height - 64 -navigationView.frame.origin.y - navigationView.frame.size.height - 5) / 2 - 10)];
    UILabel *lab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, subView_1.frame.size.width, 40)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.textColor = KColor_Blue;
    [lab2 setText:@"营业收入统计"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(5, 40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine2.backgroundColor = kLineViewColor;
    [subView_2 addSubview:viewLine2];
    [subView_2 addSubview:lab2];
    subView_2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:subView_2];
    
    //Ver.010
    self.startDateBasic = [NSDate date];
    self.endDateBasic = [NSDate date];
    self.expand = YES;
    self.cycleType = 2; //(月)
    //Ver.010
    
    chartData_1 = [NSMutableArray array];
    chartData_2 = [NSMutableArray array];
    xTitles = [NSMutableArray array];
    [self requestGetBranchDataStatisticsList];
    
    
}

#pragma mark - 按钮事件
- (void)enterDetail:(UIButton *)sender
{
    ReportOperationAnalyzeDetailsViewController *periodDetailVC = [[ReportOperationAnalyzeDetailsViewController alloc]init];
    periodDetailVC.extractItemType = 1;
    periodDetailVC.startDateBasic = self.startDateBasic;
    periodDetailVC.endDateBasic = self.endDateBasic;
    periodDetailVC.cycleType = self.cycleType;
    [self.navigationController pushViewController:periodDetailVC animated:YES];
}

#pragma mark -
- (void)readDataWithExtractItemType:(NSInteger)ExtractItemType
{
    for (int  i = 0 ; i < chartData_1.count; i ++) {
        NSNumber *tempNum = chartData_1[i];
        if (max_Count < tempNum.integerValue) {
            max_Count = tempNum.integerValue;
        }
    }
    chartView_1 = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 41, subView_1.frame.size.width, subView_1.frame.size.height - 41) withSource:self withStyle:UUChartBarStyle];
    [chartView_1 showInView:subView_1];
    
    for (int  i = 0 ; i < chartData_2.count; i ++) {
        NSNumber *tempNum = chartData_2[i];
        if (max_Amout < tempNum.doubleValue) {
            max_Amout = tempNum.doubleValue;
        }
    }
    chartView_2 = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 41, subView_2.frame.size.width, subView_2.frame.size.height - 41) withSource:self withStyle:UUChartBarStyle];
    [chartView_2 showInView:subView_2];
}
- (NSArray *)getXTitles:(int)num chart:(UUChart *)chart
{
    NSMutableArray *tempTitles = [NSMutableArray array];
    for (int i=0; i<xTitles.count; i++) {
        NSString * str = [xTitles objectAtIndex:i];;
        [tempTitles addObject:str];
    }
    return tempTitles;
    
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
    [self requestGetBranchDataStatisticsList];
}


- (void)initialKeyboard
{
    if(!datePicker) {
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        [datePicker setMaximumDate:endDateBasic];
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


#pragma mark -timePiker
//rightButt 事件
- (void)rightButtEvent:(UIButton *)sender
{
    if (self.expand) {
        self.expand = !self.expand;
        if (!self.basicTopView) {
            //            self.basicTopView = [[ReportCountTopView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 88 * 2 + 44 + 20 + 1)];
            self.basicTopView = [[ReportCountTopView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, 88 + 44 + 44 + 20 + 1)];
            self.basicTopView.delegate = self;
            self.basicTopView.extractItemType = extractItemType;
            self.basicTopView.cycleType = cycleType;
            self.basicTopView.statementCategoryID = statementCategoryID;
            self.basicTopView.startDateBasic = self.startDateBasic;
            self.basicTopView.endDateBasic = self.endDateBasic;
            self.basicTopView.reportTitle = reportTitle;
            self.basicTopView.statementCategoryList = self.statementCategoryList;
            //self.basicTopView.displayType = 1;
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

-(void)requestGetBranchDataStatisticsList
{
    //    接口地址：/Statistics/GetBranchDataStatisticsList
    //    参数 {"ObjectType":0,"MonthCount": 6,"ExtractItemType":3,"AccountID" : 11761}
    //    MonthCount 抽取的月份数
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSInteger ObjectType = 1;
    NSInteger ExtractItemType = 1;
    //->Ver.010
    NSInteger MonthCount = 6;
    switch (cycleType) {
        case 1:
            MonthCount = 6;
            break;
        case 2:
            MonthCount = 6;
            break;
        case 3:
            MonthCount = 6;
            break;
        case 4:
            MonthCount = 6;
            break;
        default:
            MonthCount = 7;
            break;
    }
    [chartData_1  removeAllObjects];
    [chartData_2  removeAllObjects];
    [xTitles  removeAllObjects];
    max_Count = 0;
    max_Amout = 0;
    //<-Ver.010
    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType];
    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.endDateBasic dateFormat:@"yyyy-MM-dd"],(long)TimeChooseFlag];
    NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],(long)cycleType];
    //StartTime EndTime TimeChooseFlag
    _requestBranchDataStatisticsOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"/Statistics/GetBranchDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                NSNumber *count = [dic objectForKey:@"ObjectCount"];
                NSNumber *amout = [dic objectForKey:@"TotalAmout"];
                NSString *tempString = [dic objectForKey:@"ObjectName"];
                [chartData_1 addObject:count.stringValue];
                [chartData_2 addObject:amout.stringValue];
                [xTitles addObject:tempString];
            }
            [self readDataWithExtractItemType:ExtractItemType];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [self getXTitles:0 chart:chart];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    if (chart  == chartView_1) {
        NSArray *ary1 = chartData_1;
        return @[ary1];
    }else{
        NSArray *ary2 = chartData_2;
        return @[ary2];
    }
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    if (chart == chartView_1) {
        return CGRangeMake(max_Count, 0);
    }else{
        return CGRangeMake(max_Amout, 0);
    }
}
#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    //        return CGRangeMake(0, 100);
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}


@end
