//
//  ReportProductAnalyzeCompositorViewController.m
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

#import "ReportProductAnalyzeCompositorViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "ReportProductTableViewCell.h"

//->Ver.010
#import "UIButton+InitButton.h"
#import "ReportCountTopView.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "UILabel+InitLabel.h"

//@interface ReportProductAnalyzeCompositorViewController ()<UITableViewDataSource,UITableViewDelegate>
@interface ReportProductAnalyzeCompositorViewController ()<UITableViewDataSource,UITableViewDelegate,ReportCountTopViewDelegate>
//<-Ver.010
{
    UITableView *productTableView;
    NSMutableArray *productData;
    AFHTTPRequestOperation *_requestBranchDataStatisticsListOperation;
    
    UIButton *serverBtn;
    UIButton *productBtn;
    
    BOOL isSelectServer;
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


@implementation ReportProductAnalyzeCompositorViewController
//->Ver.010
@synthesize reportTitle, reportAccountID, reportBranchID;
@synthesize datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDateBasic, endDateBasic;
@synthesize objectType, cycleType, accountID, branchID,statementCategoryID,extractItemType;
//<-Ver.010

- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"产品消费数据统计"];
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
    [lab setText:@"产品消费排行榜"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [self.view addSubview:viewLine];
    [self.view addSubview:lab];
    
    productTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if ((IOS7 || IOS8)) {
        productTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 41, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f - 40.0f - 41  - 5);
    } else {
        productTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f  - 40.0f - 41  - 5);
    }
    
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
    
    
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width  , 40)];
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
    
    productData = [NSMutableArray array];
    isSelectServer = YES;
    
    //Ver.010
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:[NSDate date]];
    self.startDateBasic = firstDay;
    self.endDateBasic = [NSDate date];
    self.expand = YES;
    self.cycleType = 2; //(月)
    //Ver.010
    
    [self requestWithObjectType:0];
    
}

#pragma mark - 按钮事件
- (void)serverBtnClick:(UIButton *)sender
{
    isSelectServer = YES;
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_BuleColor;
    [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:0];
}
- (void)productBtnClick:(UIButton *)sender
{
    isSelectServer = NO;
    [productBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_BuleColor;
    [serverBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:1];
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
    static  NSString *identifier = @"ReportProductCell";
    ReportProductTableViewCell *cell = (ReportProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"ReportProductTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    cell.isSelectServer = isSelectServer;
    cell.data = productData[indexPath.row];
    return cell;
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
    if (isSelectServer == YES){
        [self requestWithObjectType:0];
    }else{
        [self requestWithObjectType:1];
    }
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

#pragma makr - 接口
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (productData) {
        [productData removeAllObjects];
    } else {
        productData = [NSMutableArray array];
    }
    NSInteger ExtractItemType = 3;
    NSInteger MonthCount = 6;
    //->Ver.010
    NSInteger TimeChooseFlag = 0;

    
    //NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType];
    NSString *par = [NSString stringWithFormat:@"{\"ObjectType\":%ld,\"MonthCount\":%ld,\"ExtractItemType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TimeChooseFlag\":%ld}",(long)ObjectType,(long)MonthCount,(long)ExtractItemType,[NSDate dateToString:self.startDateBasic dateFormat:@"yyyy-MM-dd"],[NSDate dateToString:self.endDateBasic dateFormat:@"yyyy-MM-dd"],(long)TimeChooseFlag];
    //<-Ver.010
    
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
