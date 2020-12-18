//
//  AccountListViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-3.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AccountListViewController.h"
#import "GPHTTPClient.h"
#import "UIImageView+WebCache.h"
#import "CacheInDisk.h"
#import "GDataXMLNode.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "AccountDetailViewController.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "MenuViewController.h"
#import "AccountDoc.h"
#import "AppDelegate.h"

#define UPLATE_ACCOUNT_LIST_DATE  @"UPLATE_ACCOUNT_LIST_DATE"

@interface AccountListViewController()
@property (weak,nonatomic) AFHTTPRequestOperation *accountListOperation;
@property (weak,nonatomic) AccountDoc *account_selected;
@property (strong, nonatomic) TitleView *titleView;
@end

@implementation AccountListViewController
@synthesize accounts;
@synthesize myListView;
@synthesize account_selected;
@synthesize companyLabel;
@synthesize branchId;
@synthesize requestType;
@synthesize businessName;
@synthesize titleView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [myListView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -27.0f)];

	myListView.dataSource = self;
    myListView.delegate = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = NO;
    
    requestType = 3;
    branchId = 0;
    
    __weak AccountListViewController *accountViewController = self;
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime,dispatch_get_main_queue(),^(void){
            [accountViewController pullToRefreshData];
        });
    }];
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults]objectForKey:UPLATE_ACCOUNT_LIST_DATE];
    if(uploadDate){
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    }else{
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self.myListView reloadData];
    
    if (businessName == nil) {
        self.title = [NSString stringWithFormat:@"%@的服务团队",[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_COMPANYABBREVIATION"]];
    } else {
        self.title = [NSString stringWithFormat:@"%@的服务团队",businessName];
    }
    
    [companyLabel setText:@"美容师"];
    [myListView triggerPullToRefresh];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_accountListOperation || [_accountListOperation isExecuting]){
        [_accountListOperation cancel];
        _accountListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}


- (void)pullToRefreshData
{
    if (_accountListOperation && [_accountListOperation isExecuting]) {
        [_accountListOperation cancel];
        _accountListOperation = nil;
    }
    [self requestAccountList];
}

- (void)pullToRefreshDone
{
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:[@"上次更新时间" stringByAppendingString:@": MM/dd hh:mm:ss"]];
  //  NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    NSString *data2Str = [@"上次更新时间：" stringByAppendingString:[NSDate stringDateTimeLongFromDate:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_ACCOUNT_LIST_DATE];
    [myListView.pullToRefreshView setSubtitle:data2Str forState:SVPullToRefreshStateAll];
    [myListView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.3f];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    AccountDoc *account = [self.accounts objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *departLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *exportLabel = (UILabel *)[cell.contentView viewWithTag:103];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:105];
    
    [nameLabel setFont:kFont_Light_16];
    [departLabel setFont:kFont_Light_14];
    [titleLabel setFont:kFont_Light_14];
    [exportLabel setFont:kFont_Light_14];
    
    [nameLabel setTextColor:kColor_TitlePink];
    
    [nameLabel setText:account.acc_Name];
    [departLabel setText:account.acc_Department];
    [titleLabel setText:account.acc_Title];
    [exportLabel setText:account.acc_Expert];
    [imageView setImageWithURL:[NSURL URLWithString:account.acc_HeadImgURL]placeholderImage:[UIImage imageNamed:@"People-default"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow_Single;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    account_selected = (AccountDoc *)[accounts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"gotoDetail" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoDetail"]) {
        AccountDetailViewController *accoutDetailController = (AccountDetailViewController *)segue.destinationViewController;
        accoutDetailController.accountId =  account_selected.acc_ID;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 接口
-(void)requestAccountList
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"Flag":@(requestType),
                           @"BranchID":@(branchId)};
    _accountListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/account/getAccountListForCustomer"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        
        myListView.userInteractionEnabled = NO;
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *accountArray = [NSMutableArray array];
            NSDictionary *dict = @{@"acc_ID":@"AccountID",
                                   @"acc_Name":@"AccountName",
                                   @"acc_Department":@"Department",
                                   @"acc_Title":@"Title",
                                   @"acc_Expert":@"Expert",
                                   @"acc_HeadImgURL":@"HeadImageURL",
                                   @"acc_PinYin":@"PinYin",
                                   @"acc_PinYinFirst":@"PinYinFirst"};
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AccountDoc *account =[[AccountDoc alloc] init];
                [account assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [accountArray addObject:account];
            }];
            accounts = accountArray;
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self pullToRefreshDone];
        [myListView reloadData];
        myListView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
    }];
}

@end
