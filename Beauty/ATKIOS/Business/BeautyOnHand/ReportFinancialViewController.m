//
//  ReportFinancialViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/6/19.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ReportFinancialViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "UILabel+InitLabel.h"
#import "SVProgressHUD.h"
#import "UIButton+InitButton.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#define kText_borderColor [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0  blue:233.0 / 255.0  alpha:1].CGColor;
#define kbtn_borderColor [UIColor colorWithRed:49.0 / 255.0 green:184.0 / 255.0  blue:235.0 / 255.0  alpha:1].CGColor;

#define kTextTitleColor [UIColor colorWithRed:135.0 / 255.0 green:135.0 / 255.0  blue:135.0 / 255.0  alpha:1];
#define kLineViewColor [UIColor colorWithRed:230.0 / 255.0 green:230.0 / 255.0  blue:230.0 / 255.0  alpha:1];
typedef NS_ENUM(NSInteger, ReportCellStyle) {
    ReportCellTitleWhite,
    ReportCellTitleBlue,
    ReportCellTitleDefault,
    ReportCellTitleRed,
    ReportCellTitlWidth
};

@interface ReportFinancialViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic)   NavigationView *navigaView;
@property (strong, nonatomic)  UITableView *tableView;
@property (nonatomic, weak) UISegmentedControl *segmentCon;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReportFinacialOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetStatementCategory;
@property (strong, nonatomic) NSArray * payMuArr;
@property (nonatomic, assign) NSInteger dateType;

// time piker

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) UITextField *beginTime;
@property (strong, nonatomic) UITextField *endTime;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (strong, nonatomic) UILabel *timeGap;
@property (strong, nonatomic) UIButton *queryButton;
@property (strong , nonatomic) UIImageView *queryPad;
@property (strong , nonatomic) UITextField *textField_Selected;
@property (nonatomic,assign) BOOL isShowtimeCell;

//cell value
@property (nonatomic ,assign) double IncomeAmount;
@property (nonatomic ,assign) double SalesAll;
@property (nonatomic ,strong) NSString *SalesAllRatio;
@property (nonatomic ,assign) double SalesService;
@property (nonatomic ,strong) NSString *SalesServiceRatio;
@property (nonatomic ,assign) double SalesCommodity;
@property (nonatomic ,strong) NSString *SalesCommodityRatio;
@property (nonatomic ,assign) double SalesEcard;
@property (nonatomic ,strong) NSString *SalesEcardRatio;
@property (nonatomic ,assign) double IncomeOthers;
@property (nonatomic ,strong) NSString *IncomeOthersRatio;
@property (nonatomic ,assign) double OutAmout;
@property (nonatomic ,assign) double BalanceAmount;
@end

@implementation ReportFinancialViewController
@synthesize beginTime,endTime,startDate,endDate;
@synthesize datePicker,pickerView,timeGap,inputAccessoryView,pickerData,queryButton,queryPad,textField_Selected;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"财务总览"];
    self.navigationView.tag = 10;
    [self.view addSubview:self.navigationView];
    
    UIButton *rightButt = [UIButton buttonTypeRoundedRectWithTitle:@"..." target:self selector:@selector(rightButtEvent:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 50, 0, 44, self.navigationView.frame.size.height) titleColor:BACKGROUND_COLOR_TITLE backgroudColor:nil cornerRadius:1];
    rightButt.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    rightButt.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    [self.navigationView addSubview:rightButt];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(-5.0f, self.navigationView.frame.size.height + self.navigationView.frame.origin.y, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.delegate =self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:_tableView];
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, self.navigationView.frame.size.height + self.navigationView.frame.origin.y, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, self.navigationView.frame.size.height + self.navigationView.frame.origin.y, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    _tableView.tag = 101;
    
    self.isShowtimeCell = NO;*/
    
    [self initView];
    [self initData];
}
- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    self.tableView.frame = CGRectMake(5.0f, self.navigaView.frame.origin.y + self.navigaView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //self.tableView.delegate = self;
}

- (void)initData
{
    self.SalesAllRatio = @"0%";
    self.SalesServiceRatio = @"0%";
    self.SalesCommodityRatio = @"0%";
    self.SalesEcardRatio = @"0%";
    self.IncomeOthersRatio = @"0%";
    self.dateType = 0;
    self.startDate = [NSDate date];
    self.endDate = [NSDate date];
    [self requestGetReportFinancial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)changeCycleTypeAction:(UISegmentedControl *)sender
{
    self.dateType = sender.selectedSegmentIndex;
    int addHeight = 0;
    
    if (self.dateType == 4) {
        
        addHeight = 1;
        
        self.navigaView.frame = CGRectMake(0, 5.f, 312.f, 36.f * (1 + addHeight ));
        
        self.tableView.contentInset = UIEdgeInsetsMake(36.0, 0, 0, 0);
        [self initialCustomizeQueryPad];
    } else {
        self.navigaView.frame = CGRectMake(0, 5.f, 312.f, 36.f * (1 + addHeight ));
        self.tableView.contentInset = UIEdgeInsetsZero;
        [self hideTheDateView];
        [self requestGetReportFinancial];
    }
}

- (void)hideTheDateView
{
    [beginTime setHidden:YES];
    [endTime setHidden:YES];
    [timeGap setHidden:YES];
    [queryButton setHidden:YES];
    [queryPad setHidden:YES];
}

//rightButt 事件
/*- (void)rightButtEvent:(UIButton *)sender
{
    self.isShowtimeCell = !self.isShowtimeCell;
    [_tableView reloadData];
}*/

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"财务数据总览"];
        
        UISegmentedControl *segC = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"日", @"月", @"季", @"年", @"...", nil]];
        segC.frame = CGRectMake(170.0f, 2.0f, 150.0f, 32.0f);
        segC.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        segC.segmentedControlStyle = UISegmentedControlStyleBordered;
        segC.selectedSegmentIndex = 0;
        segC.tintColor = BACKGROUND_COLOR_TITLE;
        [segC addTarget:self action:@selector(changeCycleTypeAction:) forControlEvents:UIControlEventValueChanged];
        [segC setImage:[UIImage imageNamed:@"icon_Date"] forSegmentAtIndex:4];
        [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kColor_DarkBlue, UITextAttributeTextColor, kFont_Light_16, UITextAttributeFont, nil] forState:UIControlStateNormal];
        [nav addSubview:self.segmentCon = segC];
        
        [self.view addSubview:_navigaView = nav];
        
    }
    return _navigaView;
}

- (DFUITableView *)tableView
{
    if (_tableView == nil) {
        DFUITableView *tab = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        tab.separatorColor = kTableView_LineColor;
        //[tab registerClass:[OrderInfoCell class] forCellReuseIdentifier:@"ReportMarking"];
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
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
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:textField];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return  YES;
}

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

- (void)dismisskeyBoard
{
    [self.view endEditing:YES];
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

- (void)initialCustomizeQueryPad
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    
    if(queryPad == nil) {
        queryPad = [[UIImageView alloc ]init];
        queryPad.frame = CGRectMake(5.f, 36.f, 310.f, 38.f);
        queryPad.tag = 100;
        UIImage *backgroundImage = [UIImage imageNamed:@"line.png"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
        // queryPad.backgroundColor = [UIColor blueColor];//[UIColor colorWithPatternImage:backgroundImage];
        [queryPad setImage:backgroundImage];
        
        [self.navigaView addSubview:queryPad];
    }
    else
        [queryPad setHidden:NO];
    
    if(beginTime == nil) {
        beginTime = [[noCopyTextField alloc]init];
        beginTime.text = [dateFormatter stringFromDate:self.startDate];
        if ((IOS7 || IOS8))
            beginTime.frame = CGRectMake(20.f, 38.f, 130.f, 32.f);
        else if(IOS6)
            beginTime.frame = CGRectMake(20.f, 47.f, 130.f, 32.f);
        beginTime.tag = 102;
        beginTime.delegate = self;
        beginTime.font = kFont_Light_15;
        beginTime.textColor = [UIColor grayColor];
        if((IOS7 || IOS8))
            [beginTime setTintColor:[UIColor clearColor]];
        [self.navigaView addSubview:beginTime];
    }
    else
        [beginTime setHidden:NO];
    
    if(timeGap == nil)
    {
        timeGap = [[UILabel alloc] init];
        timeGap.text = @"-";
        if ((IOS7 || IOS8))
            timeGap.frame = CGRectMake(133.f, 38.f, 6.f, 26.f);
        else if (IOS6)
            timeGap.frame = CGRectMake(133.f, 40.f, 6.f, 26.f);
        timeGap.textColor = [UIColor grayColor];
        timeGap.backgroundColor = [UIColor clearColor];
        [self.navigaView addSubview:timeGap];
    }
    else
        [timeGap setHidden:NO];
    
    if(endTime == nil) {
        endTime = [[noCopyTextField alloc]init];
        endTime.text = [dateFormatter stringFromDate:self.endDate];;
        if ((IOS7 || IOS8))
            endTime.frame = CGRectMake(145.f, 38.f, 130.f, 32.f);
        else if (IOS6)
            endTime.frame = CGRectMake(145.f, 47.f, 130.f, 32.f);
        endTime.tag = 103;
        endTime.delegate = self;
        endTime.font = kFont_Light_15;
        endTime.textColor = [UIColor grayColor];
        if((IOS7 || IOS8))
            [endTime setTintColor:[UIColor clearColor]];
        [self.navigaView addSubview:endTime];
    }
    else
        [endTime setHidden:NO];
    
    if(queryButton == nil) {
        queryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        queryButton.frame = CGRectMake(265.f, 45.f, 40.f, 20.f);
        queryButton.tag = 104;
        queryButton.layer.cornerRadius = 10;
        queryButton.titleLabel.font = kFont_Light_14;
        if (IOS6)
            [queryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [queryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        queryButton.backgroundColor = [UIColor colorWithRed:73/255.f green:75/255.f blue:81/255.f alpha:1.f];
        [queryButton setTitle:@"查询" forState:UIControlStateNormal];
        [queryButton addTarget:self action:@selector(reportQueryCustomize) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigaView addSubview:queryButton];
    }
    else
        [queryButton setHidden:NO];
    [self.view addSubview:self.navigaView];
}

- (void)reportQueryCustomize
{
    [self requestGetReportFinancial];
}

#pragma mark -tableDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return 6;
    }else if (section ==1) {
        return self.payMuArr.count >0? self.payMuArr.count+1:1;
    }else if (section ==2)
    {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section ==0) {
        switch (indexPath.row) {
            case 0:
                cell = [self tableView:tableView CellWithTitleText:@"收入"  contentText:@"" contentTextRate:MoneyFormat(_IncomeAmount)  andCellStytle:ReportCellTitleWhite];
                break;
            case 1:
                cell = [self tableView:tableView CellWithTitleText:@"      销售" contentText:self.SalesAllRatio contentTextRate:MoneyFormat(_SalesAll) andCellStytle:ReportCellTitleDefault];
                break;
            case 2:
                cell = [self tableView:tableView CellWithTitleText:@"            服务" contentText:self.SalesServiceRatio contentTextRate:MoneyFormat(_SalesService) andCellStytle:ReportCellTitleDefault];
                break;
            case 3:
                cell = [self tableView:tableView CellWithTitleText:@"            商品" contentText:self.SalesCommodityRatio contentTextRate:MoneyFormat(_SalesCommodity) andCellStytle:ReportCellTitleDefault];
                break;
            case 4:
                cell = [self tableView:tableView CellWithTitleText:@"            储值卡" contentText:self.SalesEcardRatio contentTextRate:MoneyFormat(_SalesEcard) andCellStytle:ReportCellTitleDefault];
                break;
            case 5:
                cell = [self tableView:tableView CellWithTitleText:@"      其它" contentText:self.IncomeOthersRatio contentTextRate:MoneyFormat(_IncomeOthers) andCellStytle:ReportCellTitleDefault];
                break;
                
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row ==0) {
            cell = [self tableView:tableView CellWithTitleText:@"支出" contentText:@"" contentTextRate:MoneyFormat(_OutAmout) andCellStytle:ReportCellTitleWhite];
        }else{
            NSDictionary * dic = [self.payMuArr objectAtIndex:indexPath.row-1];
            cell = [self tableView:tableView CellWithTitleText:[NSString stringWithFormat:@"      %@",[dic objectForKey:@"OutItemName"]] contentText:[dic objectForKey:@"OutItemAmountRatio"] contentTextRate:MoneyFormat([[dic objectForKey:@"OutItemAmount"] doubleValue]) andCellStytle:ReportCellTitleDefault];
            
        }
    }else if (indexPath.section == 2) {
       
        if (indexPath.row ==0) {
            cell = [self tableView:tableView CellWithTitleText:@"结余" contentText:@"" contentTextRate:MoneyFormat(_BalanceAmount) andCellStytle:ReportCellTitleWhite];
        }
    }

    return cell;
}

- (UITableViewCell *)CellWithTimeTextField:(UITableView *)tableView
{
    NSString *myCell = @"FinacialTextFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
   
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = YES;
    
    CGFloat width = (kSCREN_BOUNDS.size.width - 50 - 10 -15) / 2;
    beginTime = [[noCopyTextField alloc]init];
    beginTime.text = [NSDate dateToString:self.startDate dateFormat:@"yyyy年MM月dd日"];
    beginTime.frame = CGRectMake(0, 7, width, 30);
    beginTime.tag = 102;
    beginTime.delegate = self;
    [beginTime setTintColor:[UIColor clearColor]];
    beginTime.font = kFont_Light_15;
    beginTime.textColor = kTextTitleColor;
    beginTime.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:beginTime];
    
    UILabel *timeGap = [[UILabel alloc] init];
    timeGap.text = @"-";
    timeGap.textAlignment = NSTextAlignmentCenter;
    timeGap.frame = CGRectMake(beginTime.frame.origin.x + beginTime.frame.size.width + 2, 7, 6.f, 30);
    timeGap.textColor = [UIColor grayColor];
    timeGap.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:timeGap];
    
    endTime = [[noCopyTextField alloc]init];
    endTime.text = [NSDate dateToString:self.endDate dateFormat:@"yyyy年MM月dd日"];
    endTime.frame = CGRectMake(timeGap.frame.origin.x + 6 + 2, 7,width, 30);
    endTime.tag = 103;
    endTime.delegate = self;
    [endTime setTintColor:[UIColor clearColor]];
    endTime.font = kFont_Light_15;
    endTime.textColor = kTextTitleColor;
    endTime.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:endTime];

    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView CellWithTitleText:(NSString *)title contentText:(NSString *)titleRate contentTextRate:(NSString *)content andCellStytle:(ReportCellStyle)stytle {
    NSString *myCell = @"FinacialCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCell];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCell];
    }else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    UILabel *titleLable =  [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, kTableView_HeightOfRow)] ;
    [cell.contentView addSubview:titleLable];
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width-265, 0, 200, kTableView_HeightOfRow)] ;
    [cell.contentView addSubview:valueLabel];
    
    UILabel *valueLabelRate = [[UILabel alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width-65, 0, 50, kTableView_HeightOfRow)] ;
    [cell.contentView addSubview:valueLabelRate];
    
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabelRate.textAlignment = NSTextAlignmentRight;
//    (UILabel *)[cell viewWithTag:100];
//    UILabel *valueLabel = (UILabel *)[cell viewWithTag:101];
    titleLable.font = kFont_Light_16;
    valueLabel.font = kFont_Light_16;
    valueLabelRate.font = kFont_Light_16;
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
            valueLabelRate.textColor = [UIColor whiteColor];
            break;
        case ReportCellTitleBlue:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = kColor_LightBlue;
            valueLabel.textColor = [UIColor blackColor];
            valueLabelRate.textColor = [UIColor blackColor];
            break;
        case ReportCellTitleDefault:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = [UIColor blackColor];
            valueLabel.textColor = [UIColor blackColor];
            valueLabelRate.textColor = [UIColor blackColor];
            break;
        case ReportCellTitleRed:
            cell.backgroundColor = [UIColor whiteColor];
            frameTitle.size.width = 300;
            titleLable.frame = frameTitle;
            titleLable.textColor = [UIColor redColor];
            valueLabel.textColor = [UIColor blackColor];
            valueLabelRate.textColor = [UIColor blackColor];
            break;
        case ReportCellTitlWidth:
            cell.backgroundColor = BACKGROUND_COLOR_TITLE;
            frameTitle.size.width = 300;
            titleLable.frame = frameTitle;
            titleLable.textColor = [UIColor whiteColor];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabelRate.textColor = [UIColor whiteColor];
            break;
        default:
            cell.backgroundColor = [UIColor whiteColor];
            titleLable.textColor = [UIColor blackColor];
            valueLabel.textColor = [UIColor blackColor];
            valueLabelRate.textColor = [UIColor blackColor];
            break;
    }
    
    titleLable.text = title;
    valueLabel.text = content;
    valueLabelRate.text = titleRate;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self enterPageViewControllerWithIndexPath:indexPath];
}

#pragma mark - 接口

- (void)requestGetReportFinancial
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par;
    if (self.dateType == 4) {
        NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
        dateFor.dateFormat = @"yyyy-MM-dd";
        par = [NSString stringWithFormat:@"{\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}", (long)self.dateType, [dateFor stringFromDate:self.startDate], [dateFor stringFromDate:self.endDate]];
    } else {
        par = [NSString stringWithFormat:@"{\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}", (long)self.dateType, @"", @""];
    }
    NSLog(@"par =%@",par);
    _requestGetReportFinacialOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/GetJournalInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {

            _IncomeAmount = [[data objectForKey:@"IncomeAmount"] doubleValue];
            _IncomeOthers = [[data objectForKey:@"IncomeOthers"] doubleValue];
            self.IncomeOthersRatio = [data objectForKey:@"IncomeOthersRatio"];
            _SalesCommodity = [[data objectForKey:@"SalesCommodity"] doubleValue];
            self.SalesCommodityRatio = [data objectForKey:@"SalesCommodityRatio"] ;
            _SalesAll = [[data objectForKey:@"SalesAll"] doubleValue];
            self.SalesAllRatio = [data objectForKey:@"SalesAllRatio"];
            _SalesEcard = [[data objectForKey:@"SalesEcard"] doubleValue];
            self.SalesEcardRatio = [data objectForKey:@"SalesEcardRatio"];
            _SalesService = [[data objectForKey:@"SalesService"] doubleValue];
            self.SalesServiceRatio = [data objectForKey:@"SalesServiceRatio"];
            _OutAmout=[[data objectForKey:@"OutAmout"] doubleValue];
            _BalanceAmount=[[data objectForKey:@"BalanceAmount"] doubleValue];
            self.payMuArr = [NSArray arrayWithArray:[data objectForKey:@"listOutInfo"]];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
