//
//  ReportPersonAnalyzeViewController.m
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


#import "ReportPersonAnalyzeViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "PCPieChart.h"
#import "ServeKindView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "UIButton+InitButton.h"
//->Ver.010
#import "ReportCountTopView.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "UILabel+InitLabel.h"

//@interface ReportPersonAnalyzeViewController ()
@interface ReportPersonAnalyzeViewController () <ReportCountTopViewDelegate>
//<-Ver.010
{
    PCPieChart *pieChart ;
    UIView *chartView;
    
    AFHTTPRequestOperation *_requestBranchDataStatisticsListOperation;
    
    NSMutableArray *chartData;
    NSMutableArray *colorData;
    
    NSMutableArray *btnTitleData;
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

@implementation ReportPersonAnalyzeViewController
//->Ver.010
@synthesize reportTitle, reportAccountID, reportBranchID;
@synthesize datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDateBasic, endDateBasic;
@synthesize objectType, cycleType, accountID, branchID,statementCategoryID,extractItemType;
//<-Ver.010

- (void)initPieChartView
{
    //NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"员工业务数据统计"];
    self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"员工业务数据统计"];
    [self.view addSubview:self.navigationView];
    
    //->Ver.010
    UIButton *rightButt = [UIButton buttonTypeRoundedRectWithTitle:@"..." target:self selector:@selector(rightButtEvent:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 50, 0, 44, 44) titleColor:BACKGROUND_COLOR_TITLE backgroudColor:nil cornerRadius:1];
    rightButt.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    rightButt.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [self.navigationView addSubview:rightButt];
    
    //<-Ver.010
    
    self.view.backgroundColor = kBackgroundColor;
    
    chartView = [[UIView alloc]initWithFrame:CGRectMake(5, self.navigationView.frame.origin.y + self.navigationView.frame.size.height + 5 , kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height -(self.navigationView.frame.origin.y + self.navigationView.frame.size.height + 5) - 40 - 5 - 64 - 5)];
    chartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:chartView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, chartView.frame.size.width, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"员工业绩占比图表"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [chartView addSubview:viewLine];
    [chartView addSubview:lab];
    
    
      UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width  , 40)];
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
        }

    
    int height = [self.view bounds].size.width/3*2; // 220;
    int width = [self.view bounds].size.width; //320;
    pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(5,41,width - 5,height)];
    [pieChart setShowArrow:NO];
    [pieChart setSameColorLabel:NO];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:width / 2];
    [chartView addSubview:pieChart];
    
}


-(void)initData
{
    chartData = [NSMutableArray array];
    colorData = [NSMutableArray  arrayWithObjects:ChartColor_1,ChartColor_2,ChartColor_3,ChartColor_4,ChartColor_5,ChartColor_6,ChartColor_7,ChartColor_8,ChartColor_9,ChartColor_10,ChartColor_11, nil];
    btnTitleData = [NSMutableArray arrayWithObjects:@"操作",@"销售",@"充值", nil];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self requestWithObjectType:1];
}
#pragma mark - 刷新视图
- (void)readDataWithType:(NSInteger)theType
{
    for (UIView *vi in self.view.subviews) {
        [vi removeFromSuperview];
    }
    [self initPieChartView];
    
    double  total = [self totalValueWithType:theType];
    double percentageValue = [self percentageValueWithType:theType];
    NSMutableArray *components = [NSMutableArray array];
    // 没有其他
    if (chartData.count <= 10) {
        for (int i =0 ; i < chartData.count; i++) {
            ChartModel *chart = chartData[i];
            double value = 0.0;
            switch (theType) {
                case 1:
                {
                    value = (chart.ObjectCount.doubleValue  / total) *100;
                }
                    break;
                case 2:
                {
                    value = (chart.ConsumeAmout.doubleValue  / total) *100;
                }
                    break;
                case 3:
                {
                    value  = (chart.RechargeAmout.doubleValue  / total) *100;
                }
                    break;
                    
                default:
                    break;
            }
//            double value  = (chart.ObjectCount.doubleValue  / total) *100;
            if (value > 0) {
                PCPieComponent *component = [PCPieComponent pieComponentWithTitle:nil value:value];
                [component  setColour:colorData[i]];
                [components addObject:component];
                ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake((i % 2) * kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2), kKindView_Width, kKindView_Height)];
                NSString  *temp = [NSString stringWithFormat:@"%.2lf",value];
                [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%@%%",temp] nameTitle:chart.ObjectName viewColor: colorData[i] value:1];
                [chartView addSubview:kindView];
            }
        }
        [pieChart setComponents:components];
    }
    
    if (chartData.count > 10) {
        for (int i =0 ; i < chartData.count; i++) {
            ChartModel *chart = chartData[i];
            double value = 0.0;
            switch (theType) {
                case 1:
                {
                    value = (chart.ObjectCount.doubleValue  / total) *100;
                }
                    break;
                case 2:
                {
                    value = (chart.ConsumeAmout.doubleValue  / total) *100;
                }
                    break;
                case 3:
                {
                    value  = (chart.RechargeAmout.doubleValue  / total) *100;
                }
                    break;
                    
                default:
                    break;
            }

//            double value  = (chart.ObjectCount.doubleValue  / total) * 100;
            if (i < 11) {
                if (i == 10) { // 其他
                    double  otherValue = 0;
                    if (percentageValue > 0) {
                        otherValue = (1 - percentageValue) * 100;
                    }
                    if (otherValue > 0) {
                        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:nil value:otherValue];
                        [component setColour:colorData[i]];
                        [components addObject:component];
                        ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake( kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2) , kKindView_Width, kKindView_Height)];
                        
                        [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%.2lf%%",otherValue] nameTitle:@"其他" viewColor: colorData[i]value:1];
                        [chartView addSubview:kindView];
                    }
                }else{ // 前十种
                    if (value > 0) {
                        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"%.2f%%",value] value:value];
                        [component setColour:colorData[i]];
                        [components addObject:component];
                        ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake((i % 2) * kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2), kKindView_Width, kKindView_Height)];
                        
                        [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%.2lf%%",value] nameTitle:chart.ObjectName viewColor:colorData[i] value:1];
                        [chartView addSubview:kindView];
                    }
                }
            }
        }
        [pieChart setComponents:components];
    }
}
#pragma mark - 计算
- (double)totalValueWithType:(NSInteger)theType
{
    double total = 0;
    for (int i =0 ; i < chartData.count; i++) {
        ChartModel *chart = chartData[i];
        switch (theType) {
            case 1:
            {
                total += chart.ObjectCount.doubleValue;

            }
                break;
            case 2:
            {
                total += chart.ConsumeAmout.doubleValue;

            }
                break;
            case 3:
            {
                total += chart.RechargeAmout.doubleValue;

            }
                break;
                
            default:
                break;
        }    }
    return total;
}

- (double)percentageValueWithType:(NSInteger)theType
{
    double percentage = 0;
    double total = [self totalValueWithType:theType];
    for (int i =0 ; i < chartData.count; i++) {
        ChartModel *chart = chartData[i];
        if (i < 10 ) {
            switch (theType) {
                case 1:
                {
                    percentage += chart.ObjectCount.doubleValue / total;
 
                }
                    break;
                case 2:
                {
                    percentage += chart.ConsumeAmout.doubleValue / total;

                }
                    break;
                case 3:
                {
                    percentage += chart.RechargeAmout.doubleValue / total;

                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    return percentage;
}

#pragma mark - 按钮事件
- (void)performanceBtnClick:(UIButton *)sender
{
    currentSelectButtonTag = sender.tag;
    [self requestWithObjectType:sender.tag];
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

#pragma mark - 接口
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (chartData) {
        [chartData removeAllObjects];
    } else {
        chartData = [NSMutableArray array];
    }
    
    NSInteger MonthCount = 6;
    NSInteger ExtractItemType = 2;
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
                [chartData addObject:chart];
            }
            [self readDataWithType:ObjectType];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
