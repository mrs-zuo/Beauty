//
//  RemindViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-9.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RemindViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "DEFINE.h"
#import "RemindDoc.h"
#import "SVProgressHUD.h"

#import "NavigationView.h"
#import "OrderDetailViewController.h"

#define UPLATE_REMIND_LIST_DATE  @"UPLATE_REMIND_LIST_DATE"

@interface RemindViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *remindListOperation;
@end

@implementation RemindViewController
@synthesize remindList;
@synthesize myTableView;

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
    [myTableView triggerPullToRefresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"提醒"];
    [self.view addSubview:navigationView];
    
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = YES;
    
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 20.0f - (navigationView.frame.size.height + 5.0f) - 49.0f);
    
    myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    myTableView.tableFooterView = [[UIView alloc] init];
    
    __weak RemindViewController *remindListViewController = self;
    [myTableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [remindListViewController pullToRefreshData];
        });
    }];
    
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_REMIND_LIST_DATE];
    if (uploadDate) {
        [myTableView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myTableView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

- (void)pullToRefreshData
{
    if (_remindListOperation && [_remindListOperation isExecuting]) {
        [_remindListOperation cancel];
        _remindListOperation = nil;
    }
    [self requesRemindList];
}

- (void)pullToRefreshDone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"上次更新时间: MM/dd hh:mm:ss"];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_REMIND_LIST_DATE];
    [myTableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [myTableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [remindList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RemindDoc *reminData = (RemindDoc *)[self.remindList objectAtIndex:indexPath.row];
    return reminData.remind_Height + 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"MyCell";
    RemindDoc *remindData = [self.remindList objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, remindData.remind_Height + 35.0f);
    
    UILabel *typeLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView *imageType = (UIImageView *)[cell.contentView viewWithTag:102];
    imageType.contentMode = UIViewContentModeScaleAspectFit;
    
    typeLabel.textColor = [UIColor blackColor];
    typeLabel.font = kFont_Light_20;
    
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.font = kFont_Light_16;
    
    UITextView *tmpLab = (UITextView *)[cell.contentView viewWithTag:1013];
    
    if ( !tmpLab) {
        tmpLab = [[UITextView alloc] init];
        tmpLab.tag = 1013;
        tmpLab.userInteractionEnabled = NO;
    }
    tmpLab.frame = CGRectMake(48.0f, 30.0f, 250.0f, remindData.remind_Height);
    tmpLab.allowsEditingTextAttributes = YES;
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:remindData.remind_Content];
    NSMutableParagraphStyle *stringStyle = [[NSMutableParagraphStyle alloc] init];
    [stringStyle setLineSpacing:4];
    
    [attriString addAttribute:NSParagraphStyleAttributeName value:stringStyle range:NSMakeRange(0, [remindData.remind_Content length])];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [remindData.remind_Content length])];
    [attriString addAttribute:NSFontAttributeName value:kFont_Light_14 range:NSMakeRange(0, [remindData.remind_Content length])];
    tmpLab.font = kFont_Light_14;

    [cell.contentView addSubview:tmpLab];
    
    switch (remindData.remind_Type) {
        case RemindTypeService:
            [typeLabel setText:@"服务"];
            timeLabel.text = remindData.remind_Time;
            tmpLab.attributedText = attriString;
            imageType.image = [UIImage imageNamed:@"service.png"];
            break;
        case RemindTypeBrithday:
            typeLabel.text = @"生日";
            timeLabel.text = remindData.remind_Brith;
            tmpLab.attributedText = attriString;
            imageType.image = [UIImage imageNamed:@"liwu.png"];
            break;
        case RemindTypeVisit:
            typeLabel.text = @"回访";
            timeLabel.text = remindData.remind_Time;
            tmpLab.attributedText = attriString;
            imageType.image = [UIImage imageNamed:@"huifang.png"];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RemindDoc *remindData = [self.remindList objectAtIndex:indexPath.row];
    if (remindData.remind_Type == RemindTypeService || remindData.remind_Type == RemindTypeVisit) {
        OrderDetailViewController *orderDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
        orderDetail.orderID = remindData.orderID;
        orderDetail.productType = 0;
        [self.navigationController pushViewController:orderDetail animated:YES];
    }
}

#pragma mark - 接口
- (void)requesRemindList
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    _remindListOperation = [RemindDoc requestRemindList:^(NSArray *reminds, NSError *error) {
        if (!error) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
            self.remindList = [reminds mutableCopy];
            [myTableView reloadData];
        } else {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
        }
    }];
    
    /*
    _remindListOperation = [[GPHTTPClient shareClient] requestGetRemindListWithSuccess:^(id xml) {
        [self pullToRefreshDone];
        [SVProgressHUD dismiss];

        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if (remindList == nil){
                remindList = [NSMutableArray array];
            } else {
                [remindList removeAllObjects];
            }
            for (GDataXMLElement *data in [contentData elementsForName:@"Visit"]) {
                RemindDoc *visit = [[RemindDoc alloc] init];
                [visit setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                [visit setRemind_Time:[[[data elementsForName:@"UpdateTime"] objectAtIndex:0] stringValue]];
                [visit setRemind_Type:RemindTypeVisit];
                
                [remindList addObject:visit];
            }
            for (GDataXMLElement *data in [contentData elementsForName:@"Remind"]) {
                RemindDoc *remind = [[RemindDoc alloc] init];
                [remind setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                [remind setRemind_Time:[[[data elementsForName:@"ScheduleTime"] objectAtIndex:0] stringValue]];
                [remind setOrderID:[[[[data elementsForName:@"OrderID"] objectAtIndex:0] stringValue] integerValue]];
                [remind setRemind_Type:RemindTypeService];

                [remindList addObject:remind];
            }
            for (GDataXMLElement *data in [contentData elementsForName:@"Birthday"]) {
                RemindDoc *brith = [[RemindDoc alloc] init];
                [brith setRemind_Content:[[[data elementsForName:@"RemindContent"] objectAtIndex:0] stringValue]];
                [brith setRemind_Brith:[[[data elementsForName:@"BirthDay"] objectAtIndex:0] stringValue]];
                [brith setRemind_Type:RemindTypeBrithday];
                
                [remindList addObject:brith];
            }
            [myTableView reloadData];
            NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:time_one];
            NSLog(@"the time is %f", time);

        } failure:^{}];
        
    } failure:^(NSError *error) {
         [SVProgressHUD dismiss];
        [self pullToRefreshDone];
    }];
    
     // 13:59:56.965  0.000002 0.000001 0.000003  13:59:58.832
     // 14:01:51.571  0.000003 0.000003  0.000001 14:01:53.428    the time is 2.089550
     // 14:38:56.115                              14:38:57.825                2.182990
     // 14:40:20.195                              14:40:21.442                1.719064
     // 14:57:07.889                              14:57:09.234                1.829938
     // 14:59:17.444                              14:59:16.131                1.801316
     // 15:07:13.359                              15:07:14.873                1.829136
     // 15:10:19.656                              15:10:21.023                1.831457

     
     */

}

@end
