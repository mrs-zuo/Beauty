//
//  NoticeViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-6.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "NoticeViewController.h"
#import "GPHTTPClient.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "NoticeDoc.h"
#import "SVProgressHUD.h"
#import "DetailNoticeViewController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "AppDelegate.h"

#define UPLATE_NOTICE_LIST_DATE  @"UPLATE_NOTICE_LIST_DATE"

@interface NoticeViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *noticeListOperation;
@property (strong, nonatomic) NoticeDoc *notice_selected;
@property (strong, nonatomic) NSMutableArray *noticeList;
@end

@implementation NoticeViewController
@synthesize noticeList;
@synthesize myListView;
@synthesize notice_selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [myListView triggerPullToRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_noticeListOperation || [_noticeListOperation isExecuting]) {
        [_noticeListOperation cancel];
        _noticeListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"公告"]];
    self.title = @"公告";
    
	myListView.dataSource = self;
    myListView.delegate = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = NO;
    myListView.separatorColor = kTableView_LineColor;

    
    __weak NoticeViewController *noticeListViewController = self;
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [noticeListViewController pullToRefreshData];
        });
    }];
    
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_NOTICE_LIST_DATE];
    if (uploadDate) {
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setMyListView:nil];
    [super viewDidUnload];
}

#pragma mark - pullTo

- (void)pullToRefreshData
{
    if (_noticeListOperation && [_noticeListOperation isExecuting]) {
        [_noticeListOperation cancel];
        _noticeListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [self requesNoticeList];
}

- (void)pullToRefreshDone
{
    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_NOTICE_LIST_DATE];
    [myListView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [myListView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [noticeList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow_Multiline;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    NoticeDoc *noticeData = [self.noticeList objectAtIndex:indexPath.row];
    [titleLabel setFont:kFont_Light_16];
    [titleLabel setTextColor:kColor_TitlePink];
    [titleLabel setText:noticeData.notice_Title];
    
    [timeLabel setFont:kFont_Light_14];
    [timeLabel setTextColor:kColor_Editable];
    [timeLabel setText:[NSString stringWithFormat:@"%@~%@", [noticeData.notice_StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."], [noticeData.notice_EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    notice_selected = [noticeList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goDetailNoticeView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goDetailNoticeView"]) {
        DetailNoticeViewController *detailController = segue.destinationViewController;
        detailController.recieveNoticeTitle = notice_selected.notice_Title;
        detailController.recieveNoticeTime = [NSString stringWithFormat:@"%@~%@", [notice_selected.notice_StartDate stringByReplacingOccurrencesOfString:@"-" withString:@"."], [notice_selected.notice_EndDate stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
        detailController.recievenoticeContent = notice_selected.notice_Content;
    }
}

#pragma mark - 接口

- (void)requesNoticeList
{
    _noticeListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/notice/getNoticeList"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        myListView.userInteractionEnabled = NO;
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
            [myListView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self pullToRefreshDone];
        myListView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];
//    _noticeListOperation = [[GPHTTPClient shareClient] requestGetNoticeListWithSuccess:^(id xml) {
//        myListView.userInteractionEnabled = NO;
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
//            [self pullToRefreshDone];
//            if (noticeList == nil){
//                noticeList = [NSMutableArray array];
//            } else {
//                [noticeList removeAllObjects];
//            }
//            NSMutableArray *noticeArray = [NSMutableArray array];
//            for (GDataXMLElement *data in [contentData elementsForName:@"Notice"]) {
//                NoticeDoc *notice = [[NoticeDoc alloc] init];
//                [notice setNotice_Title:([[[data elementsForName:@"NoticeTitle"] objectAtIndex:0] stringValue] == nil ? @"" : [[[data elementsForName:@"NoticeTitle"] objectAtIndex:0] stringValue])];
//                [notice setNotice_Content:([[[data elementsForName:@"NoticeContent"] objectAtIndex:0] stringValue] == nil ? @"":[[[data elementsForName:@"NoticeContent"] objectAtIndex:0] stringValue])];
//                [notice setNotice_StartDate:([[[data elementsForName:@"StartDate"] objectAtIndex:0] stringValue] == nil ? @"":[[[data elementsForName:@"StartDate"] objectAtIndex:0] stringValue])];
//                [notice setNotice_EndDate:([[[data elementsForName:@"EndDate"] objectAtIndex:0] stringValue] == nil ? @"":[[[data elementsForName:@"EndDate"] objectAtIndex:0] stringValue])];
//                [noticeArray addObject:notice];
//            }
//            noticeList = noticeArray;
//            [myListView reloadData];
//            myListView.userInteractionEnabled = YES;
//        } failure:^{
//        }];
//    } failure:^(NSError *error) {
//        [self pullToRefreshDone];
//        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
//    }];
}
@end
