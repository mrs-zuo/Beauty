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
#import "GDataXMLNode.h"
#import "TitleView.h"
#import "AccountInfo.h"
#import "AppDelegate.h"
#import "GPBHTTPClient.h"
#import "UIButton+InitButton.h"
#import "DFChooseAlertView.h"
#import "DFTableCell.h"
#import "Tags.h"

#define UPLATE_ACCOUNT_LIST_DATE  @"UPLATE_ACCOUNT_LIST_DATE"

@interface AccountListViewController()
@property (weak,nonatomic) AFHTTPRequestOperation *accountListOperation;
@property (weak,nonatomic) AccountInfo *account_selected;
@property (strong, nonatomic) TitleView *titleView;

@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic) NSMutableArray *user_Selected;
@property (nonatomic, weak) AFHTTPRequestOperation *requestGroupList;
@property (nonatomic,assign) NSInteger flag ;
@property (nonatomic, copy) NSString *tagIDs;



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
@synthesize tagIDs;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (titleView == nil) {
        titleView = [[TitleView alloc] init];
        [self.view addSubview:titleView];
    }
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [myListView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 110.0f)];
    }else
        [myListView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 110.0f)];
    
    myListView.autoresizingMask = UIViewAutoresizingNone;
	myListView.dataSource = self;
    myListView.delegate = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = NO;
    myListView.backgroundColor = [UIColor whiteColor];
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
    //获得group数据
    [self requestGroup];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myListView reloadData];
    
    if (businessName == nil) {
        [titleView getTitleView:[NSString stringWithFormat:@"%@的服务团队",[[NSUserDefaults standardUserDefaults]objectForKey:@"ACCOUNT_COMPANYABBREVIATION"]]];
    } else {
        [titleView getTitleView:[NSString stringWithFormat:@"%@的服务团队",businessName]];
    }
    // 美丽顾问分组筛选
    UIButton *personFilter = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(personFilterAction)
                                                 frame:CGRectMake(kSCREN_BOUNDS.size.width - HEIGHT_NAVIGATION_VIEW - 10, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"group_respon"]
                                      highlightedImage:nil];
    
    [titleView addSubview:personFilter];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[@"上次更新时间" stringByAppendingString:@": MM/dd hh:mm:ss"]];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
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
    AccountInfo *account = [self.accounts objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    UILabel *departLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *exportLabel = (UILabel *)[cell.contentView viewWithTag:103];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:105];
    
    [nameLabel setFont:kFont_Light_16];
    [departLabel setFont:kFont_Light_14];
    [titleLabel setFont:kFont_Light_14];
    [nameLabel setTextColor:kColor_DarkBlue];
    [exportLabel setFont:kFont_Light_14];
    
    [nameLabel setText:account.acc_Name];
    [departLabel setText:account.acc_Department];
    [titleLabel setText:account.acc_Title];
    [exportLabel setText:account.acc_Expert];
    [imageView setImageWithURL:[NSURL URLWithString:account.acc_HeadImgURL]placeholderImage:[UIImage imageNamed:@"People-default"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    account_selected = (AccountInfo *)[accounts objectAtIndex:indexPath.row];
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

#pragma mark - 按钮事件
- (void)personFilterAction {
    
    NSArray *array = @[@"取消",@"清除",@"确定"];
    
    NSMutableArray *chooseArray = [NSMutableArray array];
    [self.groupArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [chooseArray addObject:[obj copy]];
    }];
    
    DFChooseAlertView *alertView = [DFChooseAlertView DFchooseAlterTitle:@"  分组选择" numberOfRow:chooseArray.count ChooseCells:^UITableViewCell *(DFChooseAlertView *alert, NSIndexPath *indexPath) {
        static NSString *groupCell = @"groupCell";
        DFTableCell *chooseCell = [alert.table dequeueReusableCellWithIdentifier:groupCell];
        if (!chooseCell) {
            chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCell];
            chooseCell.textLabel.font = kFont_Light_18;
            chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
            chooseCell.textLabel.textColor = kColor_Black;
        }
        Tags *tag = chooseArray[indexPath.row];
        chooseCell.textLabel.text = tag.Name;
        chooseCell.imageView.image = (tag.isChoose ? [UIImage imageNamed:@"icon_Checked"]:[UIImage imageNamed:@"icon_unChecked"]);
        __weak DFTableCell *weakCell = chooseCell;
        chooseCell.layoutBlock = ^{
            weakCell.textLabel.frame = CGRectMake(9.0f, 9.0f, 200.0f, 20.0f);
            weakCell.imageView.frame = CGRectMake(225.0f, 2.0f, 36.0f, 36.0f);
        };
        return chooseCell;
        
    } selectionBlock:^(DFChooseAlertView *alert, NSIndexPath *selectedIndex) {
        Tags *tag = chooseArray[selectedIndex.row];
        tag.isChoose = !tag.isChoose;
        [alert.table reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationNone];
        
    } buttonsArray:array andClickButtonIndex:^(DFChooseAlertView *alert, UIButton *button, NSInteger index) {
        if (index == 0 || index == 2) {
            if (index == 2) {
                self.groupArray = [chooseArray mutableCopy];
                [self.user_Selected removeAllObjects];
                [self requestAccountList];
            }
            [alert animateOut];
        } else {
            [chooseArray enumerateObjectsUsingBlock:^(Tags *obj, NSUInteger idx, BOOL *stop) {
                obj.isChoose = NO;
            }];
            [alert.table reloadData];
        }
        
        [self.groupArray enumerateObjectsUsingBlock:^(Tags *obj, NSUInteger idx, BOOL *stop) {
            
            NSLog(@"self.groupArray.tasg.ischoose =%d",obj.isChoose);
            
        }];
        NSUserDefaults  *userDefaults = [ NSUserDefaults  standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.groupArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"FilterTags_ACCOUNT-%ld-BRANCH-%ld",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
        [userDefaults synchronize ];
    }];
    
    [alertView show];
    
}


#pragma mark - 接口
- (void)requestGroup {
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Type\":2}", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    _requestGroupList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Tag/getTagList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                self.groupArray = [[NSMutableArray alloc] init];
                // 选择各种顾问的默认分组
                NSData *date =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"FilterTags_ACCOUNT-%ld-BRANCH-%ld",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
                NSArray * arr = [NSKeyedUnarchiver unarchiveObjectWithData:date];
                
                if (arr && arr.count > 0) {
                    
                    [arr enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
                        
                        [self.groupArray addObject:[obj copy]];
                        
                        Tags *tagGroup = obj;
                        
                        for (Tags *tag in  arr) {
                            
                            if (tag.tagID == tagGroup.tagID) {
                                
                                tagGroup.isChoose = tag.isChoose;
                                
                            }
                        }
                        
                    }];
                }else
                {
                    [self.groupArray removeAllObjects];
                    
                    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        [self.groupArray addObject:[[Tags alloc] initWithDictionary:obj]];
                    }];
                }
            }];
            
            self.flag = 1;
            [self requestAccountList];
            
        } failure:^(NSInteger code, NSString *error) {
            self.flag = 1;
            [self requestAccountList];
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        self.flag = 1;
        [self requestAccountList];
    }];
    
}
- (NSString *)tagIDs {
    if ([self.groupArray count]) {
        NSMutableString *string = [NSMutableString string];
        [self.groupArray enumerateObjectsUsingBlock:^(Tags *obj, NSUInteger idx, BOOL *stop) {
            if (obj.isChoose) {
                [string appendFormat:@"|%ld", (long)obj.tagID];
            }
        }];
        [string appendString:@"|"];
        return [string copy];
    } else {
        return @"";
    }
}
-(void)requestAccountList
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
//    NSString *par = [NSString stringWithFormat:@"{\"TagIDs\":\"%@\",\"CompanyID\":%ld,\"BranchID\":%ld,\"CusotmerID\":%d,\"Flag\":%ld}"self.tagIDs, (long)ACC_COMPANTID, (long)branchId, 0, (long)requestType];
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CusotmerID\":%d,\"Flag\":%ld,\"TagIDs\":\"%@\"}", (long)ACC_COMPANTID, (long)branchId, 0, (long)requestType,self.tagIDs];

    _accountListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/getAccountListForCustomer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        myListView.userInteractionEnabled = NO;
        [self pullToRefreshDone];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            if(accounts == nil) {
                accounts = [NSMutableArray array];
            }else {
                [accounts removeAllObjects];
            }
            NSMutableArray *accountArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AccountInfo *account =[[AccountInfo alloc] init];
                [account setAcc_ID:[[obj objectForKey:@"AccountID"] integerValue]];
                [account setAcc_Name:[obj objectForKey:@"AccountName"]];
                [account setAcc_Department:[obj objectForKey:@"Department"]];
                [account setAcc_Title:[obj objectForKey:@"Title"]];
                [account setAcc_Expert:[obj objectForKey:@"Expert"]];
                [account setAcc_HeadImgURL:[obj objectForKey:@"HeadImageURL"]];
                [account setAcc_PinYin:[obj objectForKey:@"PinYin"]];
                [account setAcc_PinYinFirst:[obj objectForKey:@"PinYinFirst"]];
                [accountArray addObject:account];
            }];
            
            accounts = accountArray;
            [myListView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        myListView.userInteractionEnabled = YES;

    } failure:^(NSError *error) {
        [self pullToRefreshDone];

    }];
    
    
    /*
    _accountListOperation = [[GPHTTPClient shareClient] requestAccountListWithBranchID:branchId andFlag:requestType success:^(id xml) {
        myListView.userInteractionEnabled = NO;
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData , NSString *resultMsg) {
            [SVProgressHUD dismiss];
            [self pullToRefreshDone];
            if(accounts == nil) {
                accounts = [NSMutableArray array];
            }else {
                [accounts removeAllObjects];
            }
            NSMutableArray *accountArray = [NSMutableArray array];
            for (GDataXMLElement *data in [contentData elementsForName:@"Account"]) {
                AccountInfo *account =[[AccountInfo alloc] init];
                [account setAcc_ID:[[[[data elementsForName:@"AccountID"] objectAtIndex:0]stringValue] integerValue]];
                [account setAcc_Name:[[[data elementsForName:@"AccountName"] objectAtIndex:0] stringValue]];
                [account setAcc_Department:[[[data elementsForName:@"Department"] objectAtIndex:0]stringValue]];
                [account setAcc_Title:[[[data elementsForName:@"Title"] objectAtIndex:0] stringValue]];
                [account setAcc_Expert:[[[data elementsForName:@"Expert"] objectAtIndex:0] stringValue]];
                [account setAcc_HeadImgURL:[[[data elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue]];
                [account setAcc_PinYin:[[[data elementsForName:@"PinYin"] objectAtIndex:0]stringValue]];
                [account setAcc_PinYinFirst:[[[data elementsForName:@"PinYinFirst"] objectAtIndex:0]stringValue]];
                [accountArray addObject:account];
            }
            accounts = accountArray;
            [myListView reloadData];
        } failure:^{
        }];
        myListView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self pullToRefreshDone];
        NSLog(@"Error:%@ address:%s",error.description,__FUNCTION__);
    }];
     */
}

@end
