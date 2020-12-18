//
//  ReportMarkingViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/21.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ReportMarkingViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"   
#import "MarkingReport.h"
#import "OrderInfoCell.h"

#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "noCopyTextField.h"

@interface ReportMarkingViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) NavigationView *navigaView;
@property (nonatomic, weak) DFUITableView *tableView;
@property (nonatomic, weak) UISegmentedControl *segmentCon;
@property (nonatomic, strong) MarkingReport *report;
@property (nonatomic, assign) NSInteger dateType;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIToolbar *inputAccessoryView;
@property (strong, nonatomic) NSArray *pickerData;
@property (strong, nonatomic) UITextField *beginTime;
@property (strong, nonatomic) UITextField *endTime;
@property (strong, nonatomic) UILabel *timeGap;
@property (strong, nonatomic) UIButton *queryButton;
@property (strong , nonatomic) UIImageView *queryPad;
@property (strong , nonatomic) UITextField *textField_Selected;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation ReportMarkingViewController
@synthesize datePicker,pickerView, inputAccessoryView, pickerData, beginTime, endTime, timeGap, queryButton, queryPad, textField_Selected ;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    self.dateType = 0;
    self.startDate = [NSDate date];
    self.endDate = [NSDate date];
    [self requestMarkingData];
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
        [self requestMarkingData];
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

- (void)requestMarkingData
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
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/GetBranchBusinessDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            self.report  = [[MarkingReport alloc] initWithDic:data];
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 4;
    } else if (section == 2 || section == 3) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportMarking"];
    cell.textLabel.textColor = kColor_DarkBlue;
    cell.textLabel.font = kFont_Light_16;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"到店顾客";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.CustomerCount];
        } else {
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.text = @"*到店做服务的顾客";
            cell.detailTextLabel.text = @"";
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"服务状态";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = @"";
                cell.backgroundColor = BACKGROUND_COLOR_TITLE;
                break;
            case 1:
                cell.textLabel.text = @"进行中";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.TGExecutingCount];
                break;
            case 2:
                cell.textLabel.text = @"已完成";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.TGFinishedCount];
                break;
            case 3:
                cell.textLabel.font = kFont_Light_15;
                cell.textLabel.text = @"      待确认";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.TGUnConfirmed];
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"新增订单";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = @"";
                cell.backgroundColor = BACKGROUND_COLOR_TITLE;
                break;
            case 1:
                cell.textLabel.text = @"服务";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.ServiceOrder];

                break;
            case 2:
                cell.textLabel.text = @"商品";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.CommodityOrder];
                break;
        }
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"取消订单";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = @"";
                cell.backgroundColor = BACKGROUND_COLOR_TITLE;
                break;
            case 1:
                cell.textLabel.text = @"服务";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.ServiceCancelCount];
                
                break;
            case 2:
                cell.textLabel.text = @"商品";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.report.CommodityCancelCount];
                break;
        }
    } else {
        cell.textLabel.text = @"收入金额";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", MoneyFormat(self.report.SalesAmount)];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"运营状况统计"];
        
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
        [tab registerClass:[OrderInfoCell class] forCellReuseIdentifier:@"ReportMarking"];
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
}


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
    
    
    if(textField_Selected.tag == 102 ){
        self.startDate = datePicker.date;
        
        [self.beginTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.startDate]]];
        
    }
    else if (textField_Selected.tag == 103){
        self.endDate = datePicker.date;
        [self.endTime setText:[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:self.endDate]]];
    }
    NSLog(@"%@", [dayFormatter stringFromDate:datePicker.date]);
}

- (void)done:(id)sender
{
    
    [self dateChanged:nil];
    [self.beginTime resignFirstResponder];
    [self.endTime resignFirstResponder];
//    [self dismissKeyBoard];
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
        //wugang->
        //queryButton.backgroundColor = [UIColor colorWithRed:141/255.f green:201/255.f blue:223/255.f alpha:1.f];
        queryButton.backgroundColor = [UIColor colorWithRed:73/255.f green:75/255.f blue:81/255.f alpha:1.f];
        //<-wugang
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
    [self requestMarkingData];
}
@end
