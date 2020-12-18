//
//  CustomerSelectViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-10.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerSelectViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CustomerDoc.h"
#import "MessageDoc.h"
#import "DEFINE.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "SVPullToRefresh.h"
#import "CustomerSelectListCell.h"
#import "NavigationView.h"
#import "UserDoc.h"

#import "UIButton+InitButton.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "GPBHTTPClient.h"

#define UPLATE_NEWS_LIST_DATA @"UPLATE_NEWS_LIST_DATA"

@interface CustomerSelectViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetCustomerListOperation;
@property (strong, nonatomic) NSMutableArray *customerListArray;
@property (strong, nonatomic) NSMutableArray *users_Selected;
@property (nonatomic) NSInteger type;   // type=0 我的顾客  type=1 分支机构顾客  type=2 公司顾客
@end

@implementation CustomerSelectViewController
@synthesize customerListArray;
@synthesize delegate;
@synthesize users_Selected;
@synthesize type;

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
    
    [_tableView triggerPullToRefresh];
    //[self requestTheTotalCountOfNewMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    // filterButton
    UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(filterAction)
                                                 frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"icon_Screen"]
                                      highlightedImage:nil];*/
    
    // addCustomer Button
    UIButton *groupChatButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(multipleChoiceAction)
                                                 frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"icon_GroupChats"]
                                      highlightedImage:nil];
    
    NavigationView  *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y +5.0f) title:@"飞语"];
    //[navigationView addSubview:filterButton];
    [navigationView addSubview:groupChatButton];
    [self.view addSubview:navigationView];
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    
    //###刷新顾客列表
    __weak CustomerSelectViewController *customerSelectViewController = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [customerSelectViewController pullToRefreshData];
        });
    }];
    NSString *updateDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_NEWS_LIST_DATA];
    if (updateDate) {
        [_tableView.pullToRefreshView setSubtitle:updateDate forState:SVPullToRefreshStateAll];
    } else {
        [_tableView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

/*
- (void)filterAction
{
    if (ACC_BRANCHID == 0) {  // 没有分支机构
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"筛选" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"我的顾客", @"所有顾客", nil];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0: type = 0; [self pullToRefreshData];  break; // 我的顾客
                case 1: type = 2; [self pullToRefreshData];  break; // 公司顾客
                default: break;
            }
        }];
    } else {
          UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"筛选" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"我的顾客", @"门店顾客", @"所有顾客", nil];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex != 3) {
                type = buttonIndex;
                [self pullToRefreshData];
            }
        }];
    }
}*/

- (void)multipleChoiceAction
{
    SelectCustomersViewController *selectCustomer = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    [selectCustomer setSelectModel:1 userType:0 customerRange:CUSTOMEROFMINE defaultSelectedUsers:nil];
    [selectCustomer setNavigationTitle:@"选择顾客"];
    [selectCustomer setDelegate:self];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}


- (void)pullToRefreshData
{
    if (_requestGetCustomerListOperation && [_requestGetCustomerListOperation isExecuting]) {
        [_requestGetCustomerListOperation cancel];
        _requestGetCustomerListOperation = nil;
    }
    [self requsetGetCustomerSelectList];
}

- (void)pullToRefreshDone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"上次更新时间: MM/dd hh:mm:ss"];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_NEWS_LIST_DATA];
    [_tableView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [_tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SelectCustomersViewControllerDelegate 

- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    users_Selected = [NSMutableArray arrayWithArray:userArray];
    [self performSegueWithIdentifier:@"goChatViewFromCustomerSelectView" sender:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [customerListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"CustomerSelectListCell";
    CustomerSelectListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[CustomerSelectListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (60-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MessageDoc *messageDoc = [customerListArray objectAtIndex:indexPath.row];
    [cell updateData:messageDoc];
  
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageDoc *messageDoc = [customerListArray objectAtIndex:indexPath.row];
    
    UserDoc *userDoc = [[UserDoc alloc] init];
    userDoc.user_Id = messageDoc.mesg_ToUserID;
    userDoc.user_Name = messageDoc.mesg_ToUserName;
    userDoc.user_HeadImage = messageDoc.customerHeadImgURL;
    userDoc.user_Available = messageDoc.customerAvailable;
    users_Selected = [NSMutableArray arrayWithObject:userDoc];
    [self performSegueWithIdentifier:@"goChatViewFromCustomerSelectView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goChatViewFromCustomerSelectView"]) {
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.users_Selected = users_Selected;
    }
}

#pragma mark -- 接口

- (void)requsetGetCustomerSelectList
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *par = [NSString stringWithFormat:@"{\"Flag\":%d}", 1];
    _requestGetCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getContactListForAccount" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
            
            if (customerListArray) {
                [customerListArray removeAllObjects];
            } else {
                customerListArray = [NSMutableArray array];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [customerListArray addObject:[[MessageDoc alloc] initWithDictionary:obj]];
            }];
//            for (GDataXMLElement *item in [data elementsForName:@"Message"]) {
//                MessageDoc *message = [[MessageDoc alloc] init];
//                [message setMesg_NewsCount:[[[[item elementsForName:@"NewMessageCount"] objectAtIndex:0] stringValue] integerValue]];
//                [message setCustomerAvailable:[[[[item elementsForName:@"Available"] objectAtIndex:0] stringValue] integerValue]];
//                [message setMesg_ToUserID:[[[[item elementsForName:@"CustomerID"] objectAtIndex:0] stringValue] integerValue]];
//                [message setMesg_ToUserName:[[[item elementsForName:@"CustomerName"] objectAtIndex:0] stringValue]];
//                [message setMesg_MessageContent:[[[item elementsForName:@"LastMessageContent"] objectAtIndex:0] stringValue]];
//                [message setMesg_SendTime:[[[item elementsForName:@"LastSendTime"] objectAtIndex:0] stringValue]];
//                [message setCustomerHeadImgURL:[[[item elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue]];
//                [customerListArray addObject:message];
//            }
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];

        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self pullToRefreshDone];

    }];
    
    
    
    /*
    _requestGetCustomerListOperation = [[GPHTTPClient shareClient] requestGetCustomerSelectListWithType:0 success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
            
            if (customerListArray) {
                [customerListArray removeAllObjects];
            } else {
                customerListArray = [NSMutableArray array];
            }
            
            for (GDataXMLElement *item in [contentData elementsForName:@"Message"]) {
                MessageDoc *message = [[MessageDoc alloc] init];
                [message setMesg_NewsCount:[[[[item elementsForName:@"NewMessageCount"] objectAtIndex:0] stringValue] integerValue]];
                [message setCustomerAvailable:[[[[item elementsForName:@"Available"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_ToUserID:[[[[item elementsForName:@"CustomerID"] objectAtIndex:0] stringValue] integerValue]];
                [message setMesg_ToUserName:[[[item elementsForName:@"CustomerName"] objectAtIndex:0] stringValue]];
                [message setMesg_MessageContent:[[[item elementsForName:@"LastMessageContent"] objectAtIndex:0] stringValue]];
                [message setMesg_SendTime:[[[item elementsForName:@"LastSendTime"] objectAtIndex:0] stringValue]];
                [message setCustomerHeadImgURL:[[[item elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue]];
                [customerListArray addObject:message];
            }
            [_tableView reloadData];
        } failure:^{
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self pullToRefreshDone];
    }];
     */
}

// 获取新消息的条目
- (void)requestTheTotalCountOfNewMessage
{
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getNewMessageCount" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[json objectForKey:@"Count" ] integerValue]];
    } failure:^(NSError *error) {
    }];
    /*
    [[GPHTTPClient shareClient] requestTheTotalCountOfNewMessageWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[[contentData elementsForName:@"Count"] objectAtIndex:0] stringValue] integerValue]];
        } failure:^{}];
    } failure:^(NSError *error) {}];
     */
}

@end
