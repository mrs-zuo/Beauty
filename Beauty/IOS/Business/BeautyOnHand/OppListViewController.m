//
//  CustomerListViewController.m
//  Customers
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OppListViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SVProgressHUD.h"
#import "OpportunityDoc.h"
#import "SalesProgressViewController.h"
#import "ProgressHistoryViewController.h"
#import "ProductAndPriceDoc.h"
#import "CommodityDoc.h"
#import "ServiceDoc.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"
#import "MJRefresh.h"
#import "OppFilterViewController.h"
#import "DFFilterSet.h"
#import "UserDoc.h"

#define UPLATE_CUSTOMER_LIST_DATE  @"UPLATE_OPP_LIST_DATE"
typedef enum{
    REQUESTOLD = 0,
    REQUESTNEW = 1
}REQUESTTYPE;

@interface OppListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOppListOperation;
@property (strong, nonatomic) NSMutableArray *oppArray;
@property (assign, nonatomic) OpportunityDoc *oppDoc_Selected;
@property (nonatomic, strong) DFFilterSet *oppFilter;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger oppCount;
@property (nonatomic, strong) NavigationView *navigationView;
@end

@implementation OppListViewController
@synthesize pageIndex;
@synthesize oppArray;
@synthesize oppDoc_Selected;
@synthesize oppCount;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView headerBeginRefreshing];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"与我相关的商机"];
    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterOpp)];
    [self.view addSubview:_navigationView];
    
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake( 5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRefresh)];

    self.oppFilter = [[DFFilterSet alloc] init];
        
    self.oppArray = [NSMutableArray array];
    
}

- (void)headerRefresh {
    self.pageIndex = 0;
    if (self.tableView.footerHidden == YES) {
        self.tableView.footerHidden = NO;
    }
    [self requesOppListcreatTime:@"" Type:REQUESTNEW];
}

- (void)footerRefresh {
    OpportunityDoc *oppDoc = [oppArray firstObject];
    if (self.oppCount == oppArray.count) {
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus2:@"没有更多数据了" touchEventHandle:^{}];
        self.tableView.footerHidden = YES;
    } else {
        [self requesOppListcreatTime:oppDoc.opp_UpdateTime Type:REQUESTOLD];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)filterOpp
{
    OppFilterViewController *filterVC = [[OppFilterViewController alloc] init];
    filterVC.supFilter = self.oppFilter;
    
    [self.navigationController pushViewController:filterVC animated:YES];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [oppArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OppListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *customeNameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *updateDateLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *proNameLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *progressRateLabel = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *responsiblePersonNameLabel = (UILabel *) [cell.contentView viewWithTag:104];
    
    [customeNameLabel setFont:kFont_Medium_16];
    [customeNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [responsiblePersonNameLabel setFont:kFont_Medium_16];
    [responsiblePersonNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [updateDateLabel  setFont:kFont_Light_14];
    [progressRateLabel setFont:kFont_Light_14];
    [proNameLabel setFont:kFont_Light_14];
    [customeNameLabel  setTextColor:kColor_DarkBlue];
    [responsiblePersonNameLabel setTextColor:kColor_DarkBlue];
    [progressRateLabel setTextColor:[UIColor redColor]];

    OpportunityDoc *oppDoc = [oppArray objectAtIndex:indexPath.row];
    CGSize customeSize = [oppDoc.customerName sizeWithFont:kFont_Medium_16 constrainedToSize:CGSizeMake(80.0f, 21.0f)];
    CGRect customeFrame = customeNameLabel.frame;
    customeFrame.size.width = ceil(customeSize.width);
    customeNameLabel.frame = customeFrame;
    
    NSString *responsibleString = [NSString stringWithFormat:@"|%@",oppDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonName];
    CGSize responsibleSize = [responsibleString sizeWithFont:kFont_Medium_16 constrainedToSize:CGSizeMake((160.0f - ceil(customeSize.width)), 21.0f)];
    CGRect responsibleFrame = responsiblePersonNameLabel.frame;
    responsibleFrame.origin.x = customeFrame.origin.x + customeFrame.size.width;
    responsibleFrame.size.width = ceil(responsibleSize.width);
    responsiblePersonNameLabel.frame = responsibleFrame;

    UIImageView *invalidImage = (UIImageView *)[cell viewWithTag:10000];
    if(!invalidImage)
        invalidImage= [[UIImageView alloc] init];
    invalidImage.frame = CGRectMake(0, 0, 55, 55);
    invalidImage.tag = 10000;
    invalidImage.image = [UIImage imageNamed:@"invalid.png"];
    [cell addSubview:invalidImage];
    if(oppDoc.opp_Invalid)
        invalidImage.hidden = YES;
    else
        invalidImage.hidden = NO;
    
    [customeNameLabel setText:oppDoc.customerName];
    [responsiblePersonNameLabel setText:responsibleString];
    [updateDateLabel setText:(oppDoc.opp_UpdateTime.length > 16 ? [oppDoc.opp_UpdateTime substringToIndex:16]: oppDoc.opp_UpdateTime)];
    proNameLabel.text = oppDoc.productAndPriceDoc.productDoc.pro_Name;
    [progressRateLabel setText:[NSString stringWithFormat:@"达成率%@", oppDoc.opp_ProgressRate]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    oppDoc_Selected = (OpportunityDoc *)[oppArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goTabBarControllerFromOppListView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTabBarControllerFromOppListView"]) {
        UITabBarController *tabBarController = (UITabBarController *)segue.destinationViewController;
        
        DLOG(@"%@\n\n%@", tabBarController, tabBarController.viewControllers);
        SalesProgressViewController *salesProgressVC = (SalesProgressViewController *)[tabBarController.viewControllers objectAtIndex:0];
        salesProgressVC.opportunityID = oppDoc_Selected.opp_ID;
        salesProgressVC.productType = oppDoc_Selected.productAndPriceDoc.productDoc.pro_Type;
        salesProgressVC.responsibleID = oppDoc_Selected.productAndPriceDoc.productDoc.pro_ResponsiblePersonID;
        salesProgressVC.responsibleName = oppDoc_Selected.productAndPriceDoc.productDoc.pro_ResponsiblePersonName;
        salesProgressVC.opportunityInvalid = oppDoc_Selected.opp_Invalid;
        
        ProgressHistoryViewController *ProgressHistoryVC = (ProgressHistoryViewController *)[tabBarController.viewControllers objectAtIndex:1];
        ProgressHistoryVC.opportunityID = oppDoc_Selected.opp_ID;
        ProgressHistoryVC.productType = oppDoc_Selected.productAndPriceDoc.productDoc.pro_Type;
    }
}

#pragma mark - 接口

- (void)requesOppListcreatTime:(NSString *)creatTime Type:(REQUESTTYPE)type
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"PageIndex\":%ld,\"PageSize\":%d,\"ResponsiblePersonIDs\":[%@],\"CustomerID\":%ld,\"ProductType\":%ld,\"CreateTime\":\"%@\"}", self.oppFilter.timeFlag, self.oppFilter.startTime, self.oppFilter.endTime, (long)++self.pageIndex, 10, self.oppFilter.personIDs, (long)self.oppFilter.customerID, (long)self.oppFilter.oppType, creatTime];

    _requestGetOppListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/GetOpportunityList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            NSInteger totalPage = [[data objectForKey:@"PageCount"] integerValue];
            self.oppCount = [[data objectForKey:@"RecordCount"] integerValue];
            if (self.pageIndex == totalPage) {
                self.tableView.footerHidden = YES;
            }
            
            if (totalPage > 0)
                [_navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)self.pageIndex, (long)totalPage]];
            else
                [_navigationView setSecondLabelText:@""];

            
            NSArray *oppList = [data objectForKey:@"OpportunityList"];
            oppList = (NSNull *)oppList == [NSNull null] ? nil : oppList;
            
            NSMutableArray *tempArray = [NSMutableArray array];

            [oppList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                OpportunityDoc *oppDoc = [[OpportunityDoc alloc] init];
                [oppDoc setOpp_ID:[((NSString *)[obj objectForKey:@"OpportunityID"]) integerValue ]];
                [oppDoc setCustomerId:[((NSString *)[obj objectForKey:@"CustomerID"]) integerValue ]];
                [oppDoc setCustomerName:(NSString *)[obj objectForKey:@"CustomerName"]];
                [oppDoc setOpp_UpdateTime:(NSString *)[obj objectForKey:@"CreateTime"]];
                [oppDoc setOpp_ProgressRate:(NSString *)[obj objectForKey:@"ProgressRate"]];
                [oppDoc setOpp_Invalid:[((NSString *)[obj objectForKey:@"Available"]) integerValue ]];
                oppDoc.productAndPriceDoc.productDoc.pro_ID = [((NSString *)[obj objectForKey:@"ProductID"]) integerValue ];
                oppDoc.productAndPriceDoc.productDoc.pro_Code = [((NSString *)[obj objectForKey:@"ProductCode"]) longLongValue];
                oppDoc.productAndPriceDoc.productDoc.pro_Name = (NSString *)[obj objectForKey:@"ProductName"];
                oppDoc.productAndPriceDoc.productDoc.pro_Type = [((NSString *)[obj objectForKey:@"ProductType"]) integerValue ];
                oppDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonID = [((NSString *)[obj objectForKey:@"ResponsiblePersonID"]) integerValue ];
                //GPB-1402 增加内容 美丽顾问及服务有效期
                oppDoc.productAndPriceDoc.productDoc.pro_ExpirationTime = (NSString *)[obj objectForKey:@"ExpirationTime"];
                oppDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonName = (NSString *)[obj objectForKey:@"ResponsiblePersonName"];
                [tempArray addObject:oppDoc];
            }];
            
            if (type == REQUESTNEW) {
                [oppArray removeAllObjects];
            }
            [oppArray addObjectsFromArray:tempArray];

            [self endRefreshOfNoteList:type];
            [_tableView reloadData];

            
        } failure:^(NSInteger code, NSString *error) {
            [self endRefreshOfNoteList:type];
        }];
        
    } failure:^(NSError *error) {
        [self endRefreshOfNoteList:type];

    }];
    
}

#pragma mark endRefreshing Status
- (void)endRefreshOfNoteList:(REQUESTTYPE)type
{
    switch (type) {
        case REQUESTNEW:
            [self.tableView headerEndRefreshing];
            break;
        case REQUESTOLD:
            [self.tableView footerEndRefreshing];
            break;
    }
}

@end
