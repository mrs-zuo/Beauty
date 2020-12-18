//
//  ReportDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportCustomerDetailViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"

#import "NavigationView.h"
#import "ReportCustomerDetailCell.h"
#import "UILabel+InitLabel.h"
#import "GPBHTTPClient.h"
#import "ReportDetailDoc.h"
#import "DEFINE.h"

@interface ReportCustomerDetailViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReportDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetAccountServiceCountDetailOperation;

@property (strong, nonatomic) NSMutableArray *reportArray;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ReportCustomerDetailViewController
@synthesize branchID, accountID, productType, objectType, cycleType, itemType, orderType,statementCategoryID;
@synthesize reportTitle;
@synthesize totalMoney, totalCases;
@synthesize reportArray,beginTime, endTime, timeGap ,queryPad;
@synthesize contentLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *message = nil;
    switch (cycleType) {
        case 0:
            message = [NSString stringWithFormat:@"%@(日)", reportTitle];
            break;
        case 1:
            message = [NSString stringWithFormat:@"%@(月)", reportTitle];
            break;
        case 2:
            message = [NSString stringWithFormat:@"%@(季)", reportTitle];
            break;
        case 3:
            message = [NSString stringWithFormat:@"%@(年)", reportTitle];
            break;
        case 4:
            message = [NSString stringWithFormat:@"%@",reportTitle];
            break;
            
        default:
            break;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:message];
    [self.view addSubview:navigationView];
    navigationView.tag = 10;
    
    contentLabel = [UILabel initNormalLabelWithFrame:CGRectMake(155.0f, 0.0f, 150.0f, HEIGHT_NAVIGATION_VIEW) title:@"--"];
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.textColor = kColor_LightBlue;
    if (itemType == 0 || itemType == 5) {
        contentLabel.text = MoneyFormat(totalMoney);
    } else if (itemType == 1 && productType == 0){
        contentLabel.text = [NSString stringWithFormat:@"%ld项", (long)totalCases];
    } else if (itemType == 1 && productType == 1) {
        contentLabel.text = [NSString stringWithFormat:@"%ld件", (long)totalCases];
    } else if (itemType == 2 && productType == 0) {
        contentLabel.text = [NSString stringWithFormat:@"%ld次", (long)totalCases];
    }
    
    [navigationView addSubview:contentLabel];
    
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
    }
    else
        [queryPad setHidden:NO];
    
    if(beginTime == nil) {
        beginTime = [[UITextField alloc]init];
    }
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
    }
    else
        [timeGap setHidden:NO];
    
    if(endTime == nil) {
        endTime = [[UITextField alloc]init];
    }
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
    return  38.0f;
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
    ReportCustomerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[ReportCustomerDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ReportDetailDoc *listDoc = [reportArray objectAtIndex:indexPath.row];
    [cell updateData:listDoc andProductType:productType];
    return cell;
}

#pragma mark - 接口
- (void)requestGetReportDetail:(id)nothing withStartTime:(NSString *)start withEndTime:(NSString *)end
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"StatementCategoryID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"ObjectType\":%ld,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"OrderType\":%ld,\"ProductType\":%ld,\"ExtractItemType\":%ld,\"SortType\":%d}",(long)statementCategoryID,(long)ACC_COMPANTID, (long)branchID, (long)accountID, (long)objectType, (long)cycleType, start ? start: @"", end ? end: @"",(long)orderType, (long)productType, (long)itemType, 1];
    _requestGetReportDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getReportDetail_1_7_2" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *ProductDetailDic = [data objectForKey:@"ProductDetail"] == [NSNull null] ? nil : [data objectForKey:@"ProductDetail"];
            NSArray *ProductDetailArray;
            if (itemType != 2){
                ProductDetailArray = [ProductDetailDic objectForKey:@"ProductDetail"] == [NSNull null] ? nil : [ProductDetailDic objectForKey:@"ProductDetail"];
                totalCases = [[ProductDetailDic objectForKey:@"AllQuantity"] integerValue];
            } else
                ProductDetailArray = [data objectForKey:@"TreatmentTimesDetail"] == [NSNull null] ? nil : [data objectForKey:@"TreatmentTimesDetail"];
            
            totalMoney = [[ProductDetailDic objectForKey:@"AllTotalPrice"] doubleValue];
            if (itemType == 0 || itemType == 5) {
                contentLabel.text = MoneyFormat(totalMoney);
            }
            reportArray = [NSMutableArray array];
            for (int i = 0 ; i <  [ProductDetailArray count]; i++) {
                
                NSDictionary *dic = [ProductDetailArray objectAtIndex:i];
                ReportDetailDoc *detailDoc = [[ReportDetailDoc alloc] init];
                detailDoc.objectName = [dic objectForKey:@"ObjectName"];
                detailDoc.amount = [[dic objectForKey:@"TotalPrice"] doubleValue];
                detailDoc.amountRatio = [[dic objectForKey:@"TotalPriceScale"] doubleValue];
                detailDoc.cases = itemType == 2 ? [[dic objectForKey:@"Total"] integerValue] : [[dic objectForKey:@"Quantity"] integerValue];
                detailDoc.casesRatio = totalCases == 0 ? 0 : detailDoc.cases / (float)totalCases * 100; //[[dic objectForKey:@"QuantityScale"] floatValue];
                if (itemType == 2)
                    detailDoc.amountRatio = detailDoc.casesRatio;
                detailDoc.flag = itemType;
                
                [reportArray addObject:detailDoc];
            }

            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    
    /*
     _requestGetReportDetailOperation = [[GPHTTPClient shareClient] requestGetReportDetailWithBranchID:branchID accountID:accountID objectType:objectType productType:productType cycleType:cycleType orderType:orderType itemType:itemType startTime: start endTime:end success:^(id xml) {
     [SVProgressHUD dismiss];
     if (reportArray) {
     [reportArray removeAllObjects];
     } else {
     reportArray = [NSMutableArray array];
     }
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     
     float maxSale = 0.0f;
     NSArray *array = [contentData elementsForName:@"Report"];
     for (int i = 0 ; i <  [array count]; i++) {
     GDataXMLElement *dataElement = [array objectAtIndex:i];
     ReportDetailDoc *detailDoc = [[ReportDetailDoc alloc] init];
     detailDoc.objectName = [[[dataElement elementsForName:@"ObjectName"] objectAtIndex:0] stringValue];
     detailDoc.flag = itemType;
     if (itemType == 0) {
     detailDoc.amount = [[[[dataElement elementsForName:@"Total"] objectAtIndex:0] stringValue] doubleValue];
     
     if (totalMoney == 0)
     detailDoc.salesRatio = 0;
     else
     detailDoc.salesRatio = (float)detailDoc.amount / (float)totalMoney;
     
     if (i == 0) {
     maxSale = detailDoc.amount;
     }
     
     if (maxSale == 0)
     detailDoc.viewRatio = 0;
     else
     detailDoc.viewRatio = (float)detailDoc.amount / (float)maxSale;
     
     } else if (itemType == 1 || itemType == 2){
     detailDoc.cases = [[[[dataElement elementsForName:@"Total"] objectAtIndex:0] stringValue] intValue];
     
     if (totalCases == 0)
     detailDoc.salesRatio = 0;
     else
     detailDoc.salesRatio = (float)detailDoc.cases / (float)totalCases;
     
     if (i == 0) {
     maxSale = detailDoc.cases;
     }
     
     if (maxSale == 0)
     detailDoc.viewRatio = 0;
     else
     detailDoc.viewRatio = (float)detailDoc.cases / (float)maxSale;
     }
     
     [reportArray addObject:detailDoc];
     }
     [_tableView reloadData];
     } failure:^{}];
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     }];
     */
}

@end