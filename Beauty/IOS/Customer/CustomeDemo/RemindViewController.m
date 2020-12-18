//
//  RemindViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-8.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "RemindViewController.h"
#import "GPHTTPClient.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "RemindDoc.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIImageView+WebCache.h"
#import "RemindCell.h"
#import "RemindDoc.h"
#import "AppDelegate.h"

#define UPLATE_REMIND_LIST_DATE  @"UPLATE_REMIND_LIST_DATE"

@interface RemindViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *remindListOperation;
@property (strong, nonatomic) NSMutableArray *remindList;
@property (assign, nonatomic)NSInteger pageIndex;
@end

@implementation RemindViewController
@synthesize pageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    //在(IOS7 || IOS8)的情况下重新计算起始点
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"提醒";
    [_myTableView setAllowsSelection:NO];
    [_myTableView setShowsHorizontalScrollIndicator:NO];
    [_myTableView setShowsVerticalScrollIndicator:NO];
    [_myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_myTableView setBackgroundColor:[UIColor clearColor]];

    
    //下拉刷新    __weak + __strong 的做法是在Block中的比较好的一种做法（因为一旦当前页面被释放，而block的代码还在执行的时候，有可能会崩溃）
    __weak RemindViewController *remindListViewController = self;
    [_myTableView addPullToRefreshWithActionHandler:^{
        __strong RemindViewController *remind = remindListViewController;
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [remind pullToRefreshData];
        });
    }];
    
    //停止下拉刷新
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_REMIND_LIST_DATE];
    if (uploadDate) {
        [_myTableView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [_myTableView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = NO;
    [super viewWillAppear:animated];
    [_myTableView triggerPullToRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_remindListOperation || [_remindListOperation isExecuting]) {
        [_remindListOperation cancel];
        _remindListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [super viewDidUnload];
}

#pragma mark - pullTo

- (void)pullToRefreshData
{
    if (_remindListOperation && [_remindListOperation isExecuting]) {
        [_remindListOperation cancel];
        _remindListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [self requesRemindList];
   
}

- (void)pullToRefreshDone
{
    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_REMIND_LIST_DATE];
    [_myTableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [_myTableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = RGB(234, 234, 234);
    UILabel *titlelab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width - 20, 20)];
    titlelab.font = kNormalFont_14;
    titlelab.text = @"提醒";
    [headView addSubview:titlelab];
    return headView;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_remindList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RemindDoc *remindData = [self.remindList objectAtIndex:indexPath.section];
        NSString *contentStr = @"";
    
    if (remindData.ResponsiblePersonName.length > 0 && remindData.BranchPhone.length >0 ) {
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请拨打门店咨询电话%@或联系服务顾问(%@%@)。",[remindData.TaskScdlStartTime substringToIndex:16],remindData.BranchName,remindData.TaskName,remindData.BranchPhone,remindData.ResponsiblePersonName,remindData.remind_ExecutorNum];
        
    } else if(remindData.ResponsiblePersonName.length == 0 && remindData.BranchPhone.length > 0 ){
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请拨打门店咨询电话%@。",[remindData.TaskScdlStartTime substringToIndex:16],remindData.BranchName,remindData.TaskName,remindData.BranchPhone];
        
    }else if (remindData.ResponsiblePersonName.length > 0 && remindData.BranchPhone.length == 0 ){
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请联系服务顾问(%@%@)。",[remindData.TaskScdlStartTime substringToIndex:16],remindData.BranchName,remindData.TaskName,remindData.ResponsiblePersonName,remindData.remind_ExecutorNum];
    }else
    {
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务。",[remindData.TaskScdlStartTime substringToIndex:16],remindData.BranchName,remindData.TaskName];
    }
    
    CGSize sizeRemindContent = [contentStr sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(280.f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    NSInteger lines = (NSInteger)(sizeRemindContent.height / kNormalFont_14.lineHeight);
    
    return sizeRemindContent.height + (5 * (lines -1))  + 20 + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"RemindListCell";
    RemindCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if(cell == nil){
        cell = [[RemindCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    RemindDoc *remindData = [self.remindList objectAtIndex:indexPath.section];
    [cell updateDate:remindData];
    cell.remindViewController = self;
    return cell;
}

#pragma mark - 接口

- (void)requesRemindList
{
    NSArray * arr = [NSArray arrayWithObject:@"2"];
    NSDictionary *para = @{
                               @"TaskType":@(1),
                               @"Status":arr,
                               @"PageIndex":@(1),
                               @"PageSize":@(999999)
                           };
    _remindListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {

        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (_remindList == nil)
                _remindList = [NSMutableArray array];
            else
                [_remindList removeAllObjects];
            
            NSDictionary *dict = @{
                                   @"ResponsiblePersonID":@"ResponsiblePersonID",
                                   @"TaskStatus":@"TaskStatus",
                                   @"TaskType":@"TaskType",
                                   @"ResponsiblePersonName":@"ResponsiblePersonName",
                                   @"BranchPhone":@"BranchPhone",
                                   @"BranchName":@"BranchName",
                                   @"CustomerName":@"CustomerName",
                                   @"TaskName":@"TaskName",
                                   @"TaskID":@"TaskID",
                                   @"TaskScdlStartTime":@"TaskScdlStartTime",
                                   @"ResponsiblePersonChat_Use":@"ResponsiblePersonChat_Use",
                                   @"HeadImageURL":@"HeadImageURL",
                                   };
            
            [[data objectForKey:@"TaskList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                RemindDoc *remind = [[RemindDoc alloc] init];
                [remind setRemind_Type:@"服务提醒"];
                [remind setRemind_ExecutorNum:@"789123456"];
                [remind assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [_remindList addObject:remind];
            }];
            
            [_myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {}];
        [self pullToRefreshDone];
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];

}

@end
