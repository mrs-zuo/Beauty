//
//  AccountSelectViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AccountSelectViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AccountDoc.h"
#import "MessageDoc.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "SVPullToRefresh.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIButton+InitButton.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "GDataXMLDocument+ParseXML.h"
#import "MenuViewController.h"

#define UPLATE_NEWS_LIST_DATA @"UPLATE_NEWS_LIST_DATA"

#define CUS_COMPANTID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYID"] integerValue]
#define CUS_BRANCHID  [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_BRANCHID"] integerValue]
#define CUS_CUSTOMERID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue]


@interface AccountSelectViewController ()
@property (weak,nonatomic) AFHTTPRequestOperation * requestGetAccountListOperation;
@property (nonatomic) NSInteger type; // type=1 公司  type=2 我的
@property(strong, nonatomic) MessageDoc *selectAccount;
@end

@implementation AccountSelectViewController
@synthesize accountListArray;
@synthesize selectedArray;
@synthesize type;
@synthesize selectAccount;

-(void) viewWillAppear:(BOOL)animated
{
    self.isShowButton = NO;
    [super viewWillAppear:animated];
    self.title = @"飞语";
    [self requsetGetAccountSelectList];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    type = 1;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    __weak AccountSelectViewController *accountSelectViewController = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        int64_t delayInseconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInseconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [accountSelectViewController pullToRefreshData];
        });
    }];
    NSString *uploadDate =[[NSUserDefaults standardUserDefaults]objectForKey:UPLATE_NEWS_LIST_DATA];
    if(uploadDate){
        [_tableView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    }else{
        [_tableView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
    _tableView.separatorColor = kTableView_LineColor;
}
- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - pullTo

-(void)pullToRefreshData
{
    if(_requestGetAccountListOperation && [_requestGetAccountListOperation isExecuting]){
        [_requestGetAccountListOperation cancel];
        _requestGetAccountListOperation = nil;
    }
    [self requsetGetAccountSelectList];
}

- (void)pullToRefreshDone
{
    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_NEWS_LIST_DATA];
    [_tableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [_tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}


#pragma mark -  UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [accountListArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"AccountSelectListCell";
    AccountSelectListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if(cell == nil){
        cell = [[AccountSelectListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
    }
    MessageDoc *messageDoc = [accountListArray objectAtIndex:indexPath.row];
    [cell updateData:messageDoc];
    [cell setDelegate:self];
    
    return cell;
}

-(void)chickSelectBtnWithCell:(UITableViewCell *)cell
{
    AccountSelectListCell *selectListCell =(AccountSelectListCell *)cell;
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectListCell];
    
    MessageDoc *message = [accountListArray objectAtIndex:indexPath.row];
    
    if([selectedArray containsObject:message]){
        [selectedArray removeObject:message];
    }else{
        [selectedArray addObject:message];
    }
}



#pragma mark  - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    if (selectAccount == nil){
        selectAccount = [[MessageDoc alloc] init];
    }
    selectAccount = [accountListArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goChatViewFromAccountSelectView" sender:self];
    self.hidesBottomBarWhenPushed = NO;

}

#pragma mark - 页面切换

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goChatViewFromAccountSelectView"]){
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.selectAccount = selectAccount;
    }
}
#pragma mark -- 接口

- (void)requsetGetAccountSelectList
{
    NSInteger branchId = 0;
    if (type == 1) {
        branchId = 0;
    } else {
        branchId = CUS_BRANCHID;
    }
    [SVProgressHUD showWithStatus:@"Loading..."];
    _requestGetAccountListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getContactListForCustomer"  showErrorMsg:YES  parameters:@{@"Flag":@3} WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
            if(accountListArray){
                [accountListArray removeAllObjects];
            }else{
                accountListArray = [NSMutableArray array];
            }
            
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                MessageDoc *message = [[MessageDoc alloc] init];
                [message setValuesForKeysWithDictionary:obj];
                [accountListArray addObject:message];
            }];
            [_tableView reloadData];
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
        } failure:^(NSInteger code, NSString *error) {
            [self pullToRefreshDone];
        }];
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];
}

// 获取新消息的条目
- (void)requestTheTotalCountOfNewMessage
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary *para = @{@"ToUserID":@(CUS_CUSTOMERID)};
    [[GPCHTTPClient sharedClient] requestUrlPath:@"/message/getNewMessageCount"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSInteger newMessageCount = [data[@"NewMessageCount"] intValue];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newMessageCount];
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
}

@end
