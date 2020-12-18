//
//  AppraiseViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/9.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "AppraiseViewController.h"
#import "AppraiseCellTableViewCell.h"
#import "AppraiseSubmit_ViewController.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"
#import "OrderDoc.h"
#import "OrderDetailAboutServiceViewController.h"
#import "OrderDetailAboutCommodityViewController.h"

@interface AppraiseViewController ()
@property (strong, nonatomic)NSMutableArray *testArray;
@property (weak, nonatomic)AFHTTPRequestOperation *requestGetUnReviewList;

@end

@implementation AppraiseViewController

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.title = @"待评价";
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20);

    [self.tableView registerClass:[AppraiseCellTableViewCell class] forCellReuseIdentifier:@"appraiseCell"];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getUnReviewList];
}
#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _testArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_ThirdCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString * identifier = [NSString stringWithFormat:@"appraiseCell_%@",indexPath];
    AppraiseCellTableViewCell *appraiseCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (appraiseCell == nil) {
        appraiseCell = [[AppraiseCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(submit:)];
        appraiseCell.ViewForbutton.userInteractionEnabled = YES;
        appraiseCell.imageView.userInteractionEnabled = YES;
        [appraiseCell.ViewForbutton addGestureRecognizer:tap];
    }

    appraiseCell.accessoryView = nil;
    appraiseCell.accessoryType = UITableViewCellAccessoryNone;
    
    appraiseCell.nameLabel.text = [[_testArray objectAtIndex:indexPath.row] valueForKey:@"serviceName"];
    appraiseCell.dateLabel.text = [[_testArray objectAtIndex:indexPath.row] valueForKey:@"tGEndTime"];
    appraiseCell.accounNameLabel.text = [[_testArray objectAtIndex:indexPath.row] valueForKey:@"responsiblePersonName"];
    appraiseCell.numberLabel.text = [[_testArray objectAtIndex:indexPath.row] valueForKey:@"productTypeStatus"];
    
    return appraiseCell;
}

-(void)submit:(UITapGestureRecognizer*)tap
{
    CGPoint tapPoint = [tap locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapPoint];
    self.hidesBottomBarWhenPushed = YES;
    AppraiseSubmit_ViewController * submitController = [[AppraiseSubmit_ViewController alloc] init];
    submitController.orderDoc = _testArray[indexPath.row];
    [self.navigationController pushViewController:submitController animated:YES];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderDoc *orderDoc = [_testArray objectAtIndex:indexPath.row];
    self.hidesBottomBarWhenPushed = YES;
    OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
    serve.orderDoc = orderDoc;
    [self.navigationController pushViewController:serve animated:YES];
}
#pragma mark - 接口
-(void)getUnReviewList{
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestGetUnReviewList = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Review/GetUnReviewList" showErrorMsg:YES parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _testArray = [NSMutableArray new];
            for (NSDictionary *dict in data){
                OrderDoc *orderDoc = [[OrderDoc alloc]init];
                orderDoc.groupNo = [[dict objectForKey:@"GroupNo"] longLongValue];
                orderDoc.tGEndTime = [dict objectForKey:@"TGEndTime"];
                orderDoc.finisHedCount = [[dict objectForKey:@"TGFinishedCount"] integerValue];
                orderDoc.totalCount = [[dict objectForKey:@"TGTotalCount"] integerValue];
                orderDoc.serviceName = [dict objectForKey:@"ServiceName"];
                orderDoc.responsiblePersonName = [dict objectForKey:@"ResponsiblePersonName"];
                orderDoc.order_ObjectID =  [[dict objectForKey:@"OrderObjectID"] integerValue];
                orderDoc.productType = 0;
                orderDoc.orderObjectID = [dict objectForKey:@"OrderObjectID"];
                orderDoc.order_Type = 0;
                [_testArray addObject:orderDoc];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end
