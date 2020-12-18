//
//  ReportListViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportListViewController.h"
#import "ReportBasicViewController.h"
#import "NavigationView.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "ReportListDoc.h"
#import "UILabel+InitLabel.h"
#import "NSDate+Convert.h"
#import "noCopyTextField.h"
#import "ReportCountViewController.h"
#import "GPBHTTPClient.h"
#import "Tags.h"

@interface ReportListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReportBasicOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestGetBranchTotalList;
@property (nonatomic, weak) AFHTTPRequestOperation *getTagList;
@property (assign, nonatomic) NSInteger objectType;
@property (assign, nonatomic) NSInteger cycleType;


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
@property (strong, nonatomic) NSMutableArray *reportListArray;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
//@property (nonatomic, copy) NSString *endDate;

@end

@implementation ReportListViewController
@synthesize reportTitle;
@synthesize objectType, cycleType;
@synthesize reportListArray, datePicker, pickerView, inputAccessoryView, pickerData;
@synthesize beginTime, endTime ,timeGap ,queryButton,queryPad,textField_Selected;
@synthesize startDate, endDate;

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetReportBasicOperation && [_requestGetReportBasicOperation isExecuting]) {
        [_requestGetReportBasicOperation cancel];
    }
    
    if (_requestGetBranchTotalList && [_requestGetBranchTotalList isExecuting]) {
        [_requestGetBranchTotalList cancel];
    }
    
    if (_getTagList && [_getTagList isExecuting]) {
        [_getTagList cancel];
    }

    _requestGetReportBasicOperation = nil;
    _requestGetBranchTotalList = nil;
    _getTagList = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
}

- (void)initData
{
    if ([reportTitle isEqualToString:@"员工报表"]) {
        objectType = 0;
    } else if ([reportTitle isEqualToString:@"各门店报表"]) {
        objectType = 1;
    } else if ([reportTitle isEqualToString:@"分组报表"]) {
        objectType = 3;
    }
    self.startDate = [NSDate date];
    self.endDate = [NSDate date];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:reportTitle];
    navigationView.tag = 10;
    [self.view addSubview:navigationView];
    
    cycleType = 0;
//    UISegmentedControl *segmentC = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"日", @"月", @"季", @"年", @"...", nil]];
//    segmentC.frame = CGRectMake(155.0f, 2.0f, 150.0f, 32.0f);
//    segmentC.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
//    segmentC.segmentedControlStyle = UISegmentedControlStyleBordered;
//    segmentC.selectedSegmentIndex = 0;
//    segmentC.tintColor = BACKGROUND_COLOR_TITLE;
//    [segmentC addTarget:self action:@selector(changeCycleTypeAction:) forControlEvents:UIControlEventValueChanged];
//    [segmentC setImage:[UIImage imageNamed:@"icon_Date"] forSegmentAtIndex:4];
//    [navigationView addSubview:segmentC];
//    
//    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kColor_DarkBlue, UITextAttributeTextColor, kFont_Light_16, UITextAttributeFont, nil]
//                                                   forState:UIControlStateNormal];
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    if ((IOS7 || IOS8))  _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.tag = 101;
    
    [self requestGetRepoartList:nil withStartTime:nil withEndTime:nil];
    
}

//- (void)changeCycleTypeAction:(UISegmentedControl *)sender
//{
//    cycleType = sender.selectedSegmentIndex;
//    
//    int addHeight = 0;
//    if(cycleType == 4)
//        addHeight = 1;
//
//    NavigationView *navigationView = (NavigationView *)[self.view viewWithTag:10];
//  //  NSLog(@"______%ld   , %@",cycleType,navigationView);
//    navigationView.frame = CGRectMake(0, 5.f, 312.f, 36.f * (1 + addHeight ));
//    
//    if ((IOS7 || IOS8)) {
//        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3  , 310.0f , kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 36.f * addHeight );
//        _tableView.separatorInset = UIEdgeInsetsZero;
//    } else if (IOS6) {
//        _tableView.frame = CGRectMake(5.0, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 36.f * addHeight);
//    }
//    
//    if(cycleType == 4)
//    {
//        [self initialCustomizeQueryPad];
//    }
//    else {
//        [beginTime setHidden:YES];
//        [endTime setHidden:YES];
//        [timeGap setHidden:YES];
//        [queryButton setHidden:YES];
//        [queryPad setHidden:YES];
//        [self requestGetRepoartList:nil withStartTime:nil withEndTime:nil];
//    }
//
//   // [self requestGetRepoartList];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [reportListArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  38.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSString *cellIndentify = @"ReportListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    
    UILabel *titleLable  = (UILabel *)[cell viewWithTag:100];
    UILabel *valueLabel0 = (UILabel *)[cell viewWithTag:101];
    UILabel *valueLabel1 = (UILabel *)[cell viewWithTag:102];
    UILabel *moneyLabel0 = (UILabel *)[cell viewWithTag:103];
    UILabel *moneyLabel1 = (UILabel *)[cell viewWithTag:104];
    
     titleLable.font = kFont_Light_16;
    valueLabel0.font = kFont_Light_16;
    valueLabel1.font = kFont_Light_16;
    moneyLabel0.font = kFont_Light_16;
    moneyLabel1.font = kFont_Light_16;
    
    titleLable.textColor = kColor_DarkBlue;
    
    valueLabel0.text = @"服务和商品销售";
    valueLabel1.text = @"e卡充值";
    
    ReportListDoc *listDoc = [reportListArray objectAtIndex:indexPath.row];
    titleLable.text = listDoc.ObjectName;
    DLOG(@"%@", MoneyFormat(listDoc.SalesAmount));
    moneyLabel0.text = MoneyFormat(listDoc.SalesAmount);
    moneyLabel1.text = MoneyFormat(listDoc.RechargeAmount);
     */
    static NSString *cellInden = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInden];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInden];
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.textLabel.font = kFont_Light_16;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ReportListDoc *listDoc = [reportListArray objectAtIndex:indexPath.row];

    cell.textLabel.text = listDoc.ObjectName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ReportListDoc *listDoc = [reportListArray objectAtIndex:indexPath.row];

    ReportBasicViewController *reportBasicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
    reportBasicVC.reportTitle = reportTitle;
    reportBasicVC.cycleType = cycleType;
    if (cycleType == 4) {
        reportBasicVC.startDateBasic = self.startDate;
        reportBasicVC.endDateBasic = self.endDate;
    }
    if (objectType == 0) {
        reportBasicVC.reportAccountID = listDoc.ObjectID;
    } else if (objectType == 1) {
        reportBasicVC.reportBranchID = listDoc.ObjectID;
    } else if (objectType == 3) {
        reportBasicVC.reportAccountID = listDoc.ObjectID;
    }
    [self.navigationController pushViewController:reportBasicVC animated:YES];
    
}
#pragma mark - other

-(void )initialCustomizeQueryPad
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    
    NavigationView *navigationView = (NavigationView *)[self.view viewWithTag:10];
    
    if(queryPad == nil) {
        queryPad = [[UIImageView alloc ]init];
        queryPad.frame = CGRectMake(5.f, 36.f, 310.f, 38.f);
        queryPad.tag = 100;
        UIImage *backgroundImage = [UIImage imageNamed:@"line.png"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
        // queryPad.backgroundColor = [UIColor blueColor];//[UIColor colorWithPatternImage:backgroundImage];
        [queryPad setImage:backgroundImage];
        
        [navigationView addSubview:queryPad];
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
        [navigationView addSubview:beginTime];
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
        [navigationView addSubview:timeGap];
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
        [navigationView addSubview:endTime];
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
        
        [navigationView addSubview:queryButton];
    }
    else
        [queryButton setHidden:NO];
}
-(void)reportQueryCustomize
{
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = @"yyyy-MM-dd";
    NSLog(@"start is %@",[dateFor stringFromDate:self.startDate]);
    NSLog(@"start is %@",[dateFor stringFromDate:self.endDate]);

    [self requestGetRepoartList:nil withStartTime:[dateFor stringFromDate:self.startDate] withEndTime:[dateFor stringFromDate:self.endDate]];
}

#pragma mark - 接口
- (void)requestRepoartGetBranchTotalList
{
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld}", (long)ACC_COMPANTID];
    
    _requestGetBranchTotalList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getBranchTotalList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(reportListArray)
                [reportListArray removeAllObjects];
            else
                reportListArray = [NSMutableArray array];
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [reportListArray addObject:[[ReportListDoc alloc] initWithDictionary:obj]];
            }];
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];

        }];
    } failure:^(NSError *error) {
        
    }];
}


- (void)requestGetRepoartList:(id)nothing withStartTime:start withEndTime:end
{
    [SVProgressHUD showWithStatus:@"Loading"]; 
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"ObjectType\":%ld}",(long)ACC_ACCOUNTID, (long)cycleType, start ? start: @"", end ? end: @"", (long)objectType];
    _requestGetReportBasicOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getReportList_1_7_2" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(NSArray *data, NSInteger code, id message) {
            if (reportListArray) {
                [reportListArray removeAllObjects];
            } else {
                reportListArray = [NSMutableArray array];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [reportListArray addObject:[[ReportListDoc alloc] initWithDictionary:obj]];
            }];
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
    
    
    
    
    /*
    _requestGetReportBasicOperation = [[GPHTTPClient shareClient] requestGetReportListWithCycleType:cycleType objectType:objectType startTime:(NSString *)start endTime:(NSString *)end success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if (reportListArray) {
                [reportListArray removeAllObjects];
            } else {
                reportListArray = [NSMutableArray array];
            }
            for (GDataXMLElement *data in [contentData elementsForName:@"Report"]) {
                ReportListDoc *reportListDoc = [[ReportListDoc alloc] init];
                reportListDoc.objectID    = [[[[data elementsForName:@"ObjectID"] objectAtIndex:0] stringValue] integerValue];
                reportListDoc.objectName  =  [[[data elementsForName:@"ObjectName"] objectAtIndex:0] stringValue];
                reportListDoc.salesAmount = [[[[data elementsForName:@"SalesAmount"] objectAtIndex:0] stringValue] doubleValue];
                reportListDoc.rechargeAmount = [[[[data elementsForName:@"RechargeAmount"] objectAtIndex:0] stringValue] doubleValue];
                [reportListArray addObject:reportListDoc];
            }
            [_tableView reloadData];
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

- (void)requestTagList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Type\":2}", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    _getTagList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Tag/getTagList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            //            [self.groupArray addObject:[[Tags alloc] initWithDictionary:@{@"ID":@0, @"Name":@"无"}]];
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.reportListArray addObject:[[ReportListDoc alloc] initWithDictionary:obj]];
            }];
            [self.tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

@end

