
//
//  ReportCustomerDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ReportDetailViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NavigationView.h"
#import "ReportDetailCell.h"
#import "UILabel+InitLabel.h"
#import "GPBHTTPClient.h"
#import "ReportDetailDoc.h"
#import "DEFINE.h"


@interface ReportDetailViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReportDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetAccountServiceCountDetailOperation;
@property (assign, nonatomic) NSInteger sortCase;
@property (strong, nonatomic) NSMutableArray *reportArray;
@end

@implementation ReportDetailViewController
@synthesize branchID, accountID, productType, objectType, cycleType, itemType, orderType,statementCategoryID;
@synthesize reportTitle;
@synthesize totalMoney, totalCases;
@synthesize reportArray,beginTime, endTime ,timeGap ,queryPad;

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
    
    if (_requestGetReportDetailOperation && [_requestGetReportDetailOperation isExecuting]) {
        [_requestGetReportDetailOperation cancel];
    }
    
    if (_requestGetAccountServiceCountDetailOperation && [_requestGetAccountServiceCountDetailOperation isExecuting]) {
        [_requestGetAccountServiceCountDetailOperation cancel];
    }
    
    _requestGetReportDetailOperation = nil;
    _requestGetAccountServiceCountDetailOperation = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
}


-(void)sortCase:(id)sender
{
    NSString *itemsCase;
    NSString *amountCase;
    //✅☑️◎◉
    if(_sortCase == 1){
        itemsCase = (self.itemType == 4 ? @"◉ 按总次数从高到低" : @"◉ 按总销量从高到低");
        amountCase = @"◎ 按总金额从高到低";
    } else if (_sortCase == 2) {
        itemsCase = (self.itemType == 4 ?  @"◎ 按总次数从高到低":@"◎ 按总销量从高到低");
        amountCase = @"◉ 按总金额从高到低";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"排序选择" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:itemsCase,amountCase, nil] ;
    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(buttonIndex != 0)
            _sortCase = buttonIndex;
        if(cycleType == 4)
        {
            NSMutableString *start = [NSMutableString stringWithString:beginTime.text];
            [start replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
            [start replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
            [start deleteCharactersInRange: [start rangeOfString: @"日"]];
            
            NSMutableString *end = [NSMutableString stringWithString:endTime.text];
            [end replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
            [end replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
            [end deleteCharactersInRange: [end rangeOfString: @"日"]];
            
            [self requestGetReportDetail:nil withStartTime:start withEndTime:end];
        }
        else
            [self requestGetReportDetail:nil withStartTime:nil withEndTime:nil];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _sortCase = 1;
    NSArray *array = [NSArray arrayWithObjects:@"(日)",@"(月)",@"(季)",@"(年)",@"", nil];
    NSString *message = [NSString stringWithFormat:@"%@%@", reportTitle,[array objectAtIndex:cycleType]];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:message];
    [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"order_operateButton"] selector:@selector(sortCase:)];
    [self.view addSubview:navigationView];
    navigationView.tag = 10;
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    if(cycleType == 4)
    {
        [self displayTimePad];
        
        NSMutableString *start = [NSMutableString stringWithString:beginTime.text];
        [start replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
        [start replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
        [start deleteCharactersInRange: [start rangeOfString: @"日"]];
        
        NSMutableString *end = [NSMutableString stringWithString:endTime.text];
        [end replaceCharactersInRange:NSMakeRange(4, 1) withString:@"-"];
        [end replaceCharactersInRange:NSMakeRange(7, 1) withString:@"-"];
        [end deleteCharactersInRange: [end rangeOfString: @"日"]];
        
        [self requestGetReportDetail:nil withStartTime:start withEndTime:end];
    }
    else
        [self requestGetReportDetail:nil withStartTime:nil withEndTime:nil];
    
}
- (void)displayTimePad
{
    int addHeight = 0;
    if(cycleType == 4)
        addHeight = 1;
    
    NavigationView *navigationView = (NavigationView *)[self.view viewWithTag:10];
    
    navigationView.frame = CGRectMake(0, 5.f, 312.f, 36.f * (1 + addHeight ));
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f , kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 36.f * addHeight );
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 3, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 36.f * addHeight);
    }
    
    if(cycleType == 4)
    {
        [self initialCustomizeQueryPad];
    }
    else {
        [beginTime setHidden:YES];
        [endTime setHidden:YES];
        [timeGap setHidden:YES];
        
    }
    
}
-(void )initialCustomizeQueryPad
{
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
    } else
        [queryPad setHidden:NO];
    
    if(beginTime == nil)
        beginTime = [[UITextField alloc]init];
    else
        [beginTime setHidden:NO];
    
    if ((IOS7 || IOS8))
        beginTime.frame = CGRectMake(33.f, 38.f, 130.f, 32.f);
    else if (IOS6)
        beginTime.frame = CGRectMake(33.f, 47.f, 130.f, 32.f);
    beginTime.tag = 102;
    [beginTime setEnabled:NO];
    beginTime.font = kFont_Light_15;
    beginTime.textColor = [UIColor grayColor];
    [navigationView addSubview:beginTime];
    
    if(timeGap == nil)
    {
        timeGap = [[UILabel alloc] init];
        timeGap.text = @"-";
        if ((IOS7 || IOS8))
            timeGap.frame = CGRectMake(150.f, 38.f, 6.f, 26.f);
        else if(IOS6)
            timeGap.frame = CGRectMake(150.f, 40.f, 6.f, 26.f);
        timeGap.textColor = [UIColor grayColor];
        timeGap.backgroundColor = [UIColor clearColor];
        [navigationView addSubview:timeGap];
    } else
        [timeGap setHidden:NO];
    
    if(endTime == nil)
        endTime = [[UITextField alloc]init];
    else
        [endTime setHidden:NO];
    if ((IOS7 || IOS8))
        endTime.frame = CGRectMake(165.f, 38.f, 130.f, 32.f);
    else if (IOS6)
        endTime.frame = CGRectMake(165.f, 47.f, 130.f, 32.f);
    endTime.tag = 103;
    [endTime setEnabled:NO];
    endTime.font = kFont_Light_15;
    endTime.textColor = [UIColor grayColor];
    [navigationView addSubview:endTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  56.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [reportArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cellIndentify = @"ReportDetail";
    ReportDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[ReportDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ReportDetailDoc *listDoc = [reportArray objectAtIndex:indexPath.row];
    [cell updateData:listDoc andProductType:productType andItemType:itemType];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 300, 56)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55.5, 310, .5)];
    lineView.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1.f];
    [view addSubview:lineView];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 20)];
    headerTitle.text = @"总销量";
    if (self.itemType == 4) {
        headerTitle.text = @"总次数";
    }
    headerTitle.font = kFont_Light_16;
    headerTitle.textColor = kColor_DarkBlue;
    [view.contentView addSubview:headerTitle];
    
    UILabel *tailTitle = [[UILabel alloc] initWithFrame:CGRectMake(155, 5, 150, 20)];
    tailTitle.text = @"总金额";
    tailTitle.font = kFont_Light_16;
    tailTitle.textColor = kColor_DarkBlue;
    tailTitle.textAlignment = NSTextAlignmentRight;
    [view.contentView addSubview:tailTitle];
    
    UILabel *headerValue = [[UILabel alloc] initWithFrame:CGRectMake(5, 28, 150, 20)];
    headerValue.text = [NSString stringWithFormat:@"%ld%@",(long)totalCases,productType == 0 ? @"项" : @"件"];
    if (self.itemType == 4) {
        headerValue.text = [NSString stringWithFormat:@"%ld次",(long)totalCases];
    }
    headerValue.font = kFont_Light_16;
    [view.contentView addSubview:headerValue];
    
    UILabel *tailValue = [[UILabel alloc] initWithFrame:CGRectMake(155, 28, 150, 20)];
    tailValue.text = MoneyFormat(totalMoney);
    tailValue.font = kFont_Light_16;
    tailValue.textAlignment = NSTextAlignmentRight;
    [view.contentView addSubview:tailValue];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56;
}

#pragma mark - 接口
- (void)requestGetReportDetail:(id)nothing withStartTime:(NSString *)start withEndTime:(NSString *)end
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"StatementCategoryID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"ObjectType\":%ld,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"OrderType\":%ld,\"ProductType\":%ld,\"ExtractItemType\":%ld,\"SortType\":%ld}",(long)statementCategoryID,(long)ACC_COMPANTID, (long)branchID, (long)accountID, (long)objectType, (long)cycleType, start ? start: @"", end ? end: @"",(long)orderType, (long)productType, (long)itemType, (long)_sortCase];
    
    _requestGetReportDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getReportDetail_1_7_2" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *ProductDetailDic = [data objectForKey:@"ProductDetail"] == [NSNull null] ? nil : [data objectForKey:@"ProductDetail"];
            NSArray *ProductDetailArray = [ProductDetailDic objectForKey:@"ProductDetail"] == [NSNull null] ? nil : [ProductDetailDic objectForKey:@"ProductDetail"];
            totalMoney = [[ProductDetailDic objectForKey:@"AllTotalPrice"] doubleValue];
            totalCases = [[ProductDetailDic objectForKey:@"AllQuantity"] integerValue];
            
            reportArray = [NSMutableArray array];
            for (int i = 0 ; i <  [ProductDetailArray count]; i++) {
                NSDictionary *dic = [ProductDetailArray objectAtIndex:i];
                ReportDetailDoc *detailDoc = [[ReportDetailDoc alloc] init];
                detailDoc.objectName = [dic objectForKey:@"ObjectName"];
                detailDoc.amount = [[dic objectForKey:@"TotalPrice"] doubleValue];
                detailDoc.amountRatio = [[dic objectForKey:@"TotalPriceScale"] doubleValue];
                detailDoc.cases = [[dic objectForKey:@"Quantity"] doubleValue];
                detailDoc.casesRatio = [[dic objectForKey:@"QuantityScale"] doubleValue];
                detailDoc.flag = itemType;
                [reportArray addObject:detailDoc];
            }
            [SVProgressHUD dismiss];
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        
    }];
}


@end
