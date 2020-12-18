//
//  PushMoenyViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/5/3.
//  Copyright © 2016年 ace-009. All rights reserved.
//
#define kText_borderColor [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0  blue:233.0 / 255.0  alpha:1].CGColor;
#define kbtn_borderColor [UIColor colorWithRed:49.0 / 255.0 green:184.0 / 255.0  blue:235.0 / 255.0  alpha:1].CGColor;

#define kTextTitleColor [UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0  blue:135.0 / 255.0  alpha:1];
#define kLineViewColor [UIColor colorWithRed:230.0 / 255.0 green:230.0 / 255.0  blue:230.0 / 255.0  alpha:1];

#import "PushMoenyViewController.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "GPBHTTPClient.h"
#import "NSDate+Convert.h"
#import "MJExtension.h"
#import "AccountCommProfitRes.h"
#import "noCopyTextField.h"
#import "SVProgressHUD.h"

const NSInteger dateView_Height = 256;

@interface PushMoenyViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UIImageView * queryPad;
    UILabel *dateLab;

}
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetAccountCommProfitOperation;
@property (nonatomic,strong) UITableView *pushMoneyTableView;
@property (nonatomic,strong) NavigationView *navigationView;
@property (nonatomic,strong) NSMutableArray *pushMoneyDatas;
@property (nonatomic,strong) NSMutableArray *pushMoneyDetailsDatas;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) UITextField *beginTime;
@property (strong, nonatomic) UITextField *endTime;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (strong , nonatomic) UITextField *textField_Selected;


@property (nonatomic,assign) BOOL isShowYear;


@end

@implementation PushMoenyViewController
@synthesize beginTime,endTime,startDate,endDate;
@synthesize datePicker,inputAccessoryView,textField_Selected;

- (void)initData
{
    self.pushMoneyDatas = [NSMutableArray arrayWithObjects:@"产品销售业绩",@"产品销售提成",@"服务操作业绩",@"服务操作提成",@"储值卡销售业绩",@"储值卡销售提成",nil];
    self.pushMoneyDetailsDatas = [NSMutableArray array];
    _isShowYear = NO;
    self.startDate = [NSDate date];
    self.endDate = [NSDate date];
}
- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
   _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"提成"];
    [self.view addSubview:_navigationView];
    
    
    queryPad = [[UIImageView alloc ]init];
    queryPad.frame = CGRectMake(5.f, (_navigationView.frame.origin.y + _navigationView.frame.size.height + 5.0f), kSCREN_BOUNDS.size.width - 10, 44);
    queryPad.tag = 100;
    queryPad.userInteractionEnabled = YES;
    queryPad.backgroundColor = kColor_White;
    [self.view addSubview:queryPad];
    
    CGFloat width = (kSCREN_BOUNDS.size.width - 50 - 10 - 5 - 5 - 5) / 2;
    beginTime = [[noCopyTextField alloc]init];
    beginTime.text = [NSDate dateToString:self.startDate dateFormat:@"yyyy年MM月dd日"];
    beginTime.frame = CGRectMake(0, 7, width, 30);
    beginTime.tag = 102;
    beginTime.delegate = self;
    [beginTime setTintColor:[UIColor clearColor]];
    beginTime.font = kFont_Light_15;
    beginTime.textColor = kTextTitleColor;
    beginTime.textAlignment = NSTextAlignmentCenter;
    [queryPad addSubview:beginTime];
    
    UILabel *timeGap = [[UILabel alloc] init];
    timeGap.text = @"-";
    timeGap.textAlignment = NSTextAlignmentCenter;
    timeGap.frame = CGRectMake(beginTime.frame.origin.x + beginTime.frame.size.width + 2, 7, 6.f, 30);
    timeGap.textColor = [UIColor grayColor];
    timeGap.backgroundColor = [UIColor clearColor];
    [queryPad addSubview:timeGap];

    endTime = [[noCopyTextField alloc]init];
    endTime.text = [NSDate dateToString:self.endDate dateFormat:@"yyyy年MM月dd日"];
    endTime.frame = CGRectMake(timeGap.frame.origin.x + 6 + 2, 7,width, 30);
    endTime.tag = 103;
    endTime.delegate = self;
    [endTime setTintColor:[UIColor clearColor]];
    endTime.font = kFont_Light_15;
    endTime.textColor = kTextTitleColor;
    endTime.textAlignment = NSTextAlignmentCenter;
    [queryPad addSubview:endTime];

    UIButton *queryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    queryButton.frame = CGRectMake(endTime.frame.origin.x + endTime.frame.size.width, 7, 50.f, 30.f);
    queryButton.tag = 104;
    queryButton.layer.cornerRadius = 10;
    queryButton.titleLabel.font = kFont_Light_14;
    [queryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    queryButton.backgroundColor = RGBA(18, 140, 230, 1);
    [queryButton setTitle:@"查询" forState:UIControlStateNormal];
    [queryButton addTarget:self action:@selector(reportQueryCustomize:) forControlEvents:UIControlEventTouchUpInside];
    [queryPad addSubview:queryButton];

    
    _pushMoneyTableView = [[UITableView alloc]initWithFrame:CGRectMake(5.0f, queryPad.frame.origin.y + queryPad.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (queryPad.frame.origin.y + queryPad.frame.size.height) -  5.0f) style:UITableViewStyleGrouped];
    _pushMoneyTableView.dataSource = self;
    _pushMoneyTableView.delegate = self;
    _pushMoneyTableView.showsHorizontalScrollIndicator = NO;
    _pushMoneyTableView.showsVerticalScrollIndicator = NO;
    _pushMoneyTableView.backgroundView = nil;
    _pushMoneyTableView.backgroundColor = [UIColor clearColor];
    _pushMoneyTableView.separatorColor = kTableView_LineColor;
    _pushMoneyTableView.separatorInset = UIEdgeInsetsZero;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _pushMoneyTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    [self.view addSubview:_pushMoneyTableView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self requestRepoartGetAccountCommProfit];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pushMoneyDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ReportMasterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
    }
    cell.textLabel.font = kFont_Light_16;
    cell.textLabel.textColor = kColor_DarkBlue;
    cell.textLabel.text = self.pushMoneyDatas[indexPath.row];
    if (self.pushMoneyDetailsDatas.count > 0) {
        NSNumber *tempNum = self.pushMoneyDetailsDatas[indexPath.row];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,tempNum.doubleValue];
    }
    return cell;
}
#pragma mark - didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self initialKeyboard];
    textField_Selected = textField;
    textField.inputAccessoryView = inputAccessoryView;
    textField.inputView = datePicker;
    NSDate *theDate = [NSDate stringToDate:textField.text dateFormat:@"yyyy年MM月dd日"];
    if (theDate != nil && ![theDate  isEqual: @""]) {
        [datePicker setDate:theDate];
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return  YES;
}
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

#pragma mark -  日期选择
- (void)dateChanged:(id)sender
{
    if(textField_Selected.tag == 102 ){
        self.startDate = datePicker.date;
        [self.beginTime setText:[NSString stringWithFormat:@"%@",[NSDate dateToString:self.startDate dateFormat:@"yyyy年MM月dd日"]]];
    }else if (textField_Selected.tag == 103){
        self.endDate = datePicker.date;
        [self.endTime setText:[NSString stringWithFormat:@"%@",[NSDate dateToString:self.endDate dateFormat:@"yyyy年MM月dd日"]]];
    }
}
- (void)done:(id)sender
{
    [self dateChanged:nil];
    [self.beginTime resignFirstResponder];
    [self.endTime resignFirstResponder];
}

#pragma mark -  完成
- (void)reportQueryCustomize:(UIButton *)sender
{
  [self requestRepoartGetAccountCommProfit];
}

#pragma mark -  接口
- (void)requestRepoartGetAccountCommProfit
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *par = @{@"StartTime":[NSDate dateToString:self.startDate dateFormat:@"yyyy-MM-dd"],
                          @"EndTime":[NSDate dateToString:self.endDate dateFormat:@"yyyy-MM-dd"]
                          };
    _requestGetAccountCommProfitOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/GetAccountCommProfit" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [self.pushMoneyDetailsDatas removeAllObjects];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)data;
                AccountCommProfitRes *comProfitRes = [AccountCommProfitRes mj_objectWithKeyValues:dict];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.SalesProfit];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.SalesComm];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.OptProfit];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.OptComm];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.ECardProfit];
                [self.pushMoneyDetailsDatas addObject:comProfitRes.ECardComm];
            }
            [self.pushMoneyTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

@end
