//
//  ThirdViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ThirdViewController.h"
#import "NoticeDoc.h"
#import "GPHTTPClient.h"
#import "DetailNoticeViewController.h"
#import "NoticeCell.h"

@interface ThirdViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *noticeListOperation;
@property (strong, nonatomic) NoticeDoc *notice_selected;
@property (strong, nonatomic) NSMutableArray *noticeList;

@end

@implementation ThirdViewController
@synthesize noticeList;
@synthesize notice_selected;


static NSString *cellIdent = @"NoticeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.tableView.frame = CGRectMake(0, -35, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 40);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = kTableView_LineColor;
    [self.tableView registerClass:[NoticeCell class] forCellReuseIdentifier:cellIdent];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requesNoticeList];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [noticeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];

    NoticeDoc *noticeData = [self.noticeList objectAtIndex:indexPath.row];
    cell.data = noticeData;
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    NoticeDoc *notice = [noticeList objectAtIndex:indexPath.row];
    DetailNoticeViewController *detailNoticeVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailNoticeViewController"];
    detailNoticeVC.recieveNoticeTitle = notice.notice_Title;
    detailNoticeVC.recieveNoticeTime = [NSString stringWithFormat:@"%@~%@", [notice.notice_StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."], [notice.notice_EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
    detailNoticeVC.recievenoticeContent = notice.notice_Content;
    [self.navigationController pushViewController:detailNoticeVC animated:YES];
}
#pragma mark - 接口
- (void)requesNoticeList
{
    _noticeListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/notice/getNoticeList"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *noticeArray = [NSMutableArray array];
            NSDictionary *dict = @{@"notice_Title":@"NoticeTitle",
                                   @"notice_Content":@"NoticeContent",
                                   @"notice_StartDate":@"StartDate",
                                   @"notice_EndDate":@"EndDate"};
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NoticeDoc *notice = [[NoticeDoc alloc] init];
                [notice assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [noticeArray addObject:notice];
            }];
            
            noticeList = noticeArray;
            [self.tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
    }];
}

@end
