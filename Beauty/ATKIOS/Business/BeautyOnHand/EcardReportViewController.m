//
//  EcardReportViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "EcardReportViewController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "ReportBalanceCell.h"
#import "EcardReport.h"
//#import "GPBHTTPClient.h"

@interface EcardReportViewController ()<UITableViewDataSource,  UITableViewDelegate>
@property (nonatomic, strong) DFUITableView *ecardReportTable;
@property (nonatomic, strong) NSArray *reports;
@property (nonatomic, weak) AFHTTPRequestOperation *ecarReportRequestOperation;
@end

@implementation EcardReportViewController
@synthesize ecardReportTable;
@synthesize reports;
@synthesize titleString;
@synthesize date;
@synthesize startTime;
@synthesize endTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Background_View;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:self.titleString];
    CGRect frame = navigationView.titleLabel.frame;
    frame.size.width = 300;
    navigationView.titleLabel.frame = frame;
    [self.view addSubview:navigationView];
    
    self.ecardReportTable = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStylePlain];
    if ((IOS7 || IOS8)) {
        [ecardReportTable setFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f,
                                        kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)];
    } else if (IOS6) {
        [ecardReportTable setFrame:CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f,
                                        kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)];
    }
//    self.ecardReportTable.tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 40)];
//    self.ecardReportTable.tableHeaderView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:ecardReportTable];

    self.ecardReportTable.delegate = self;
    self.ecardReportTable.dataSource = self;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self requestEcardReport];
}

- (void)requestEcardReport {
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"ObjectType\":%d,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"OrderType\":%d,\"ProductType\":%d,\"ExtractItemType\":%d,\"SortType\":%d}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, 1, (long)self.date, self.startTime, self.endTime, 1, 1, 3,1];
    
    
    _ecarReportRequestOperation = [EcardReport getReportWithPar:par completionBlock:^(NSArray *array, NSInteger code, NSString *msg) {
        if (array) {
            self.reports = [NSArray arrayWithArray:array];
            [self.ecardReportTable reloadData];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        _ecarReportRequestOperation = nil;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.date == 4) {
        UITableViewHeaderFooterView *dateLabel = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
        dateLabel.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.8];
        UILabel *label =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
        label.text = [NSString stringWithFormat:@"%@至%@", self.startTime, self.endTime];
//        label.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.8];
        label.textColor = [UIColor grayColor];
        label.font = kFont_Light_16;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [dateLabel addSubview:label];
        return dateLabel;
    } else {
        return nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reports.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.date == 4) {
        return 30.0f;
    } else {
        return 0.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifer = @"ecardCell";
    ReportBalanceCell  *cell  = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[ReportBalanceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.report = [self.reports objectAtIndex:(NSUInteger)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
