//
//  SelectServicePersonnal_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "SelectServicePersonnal_ViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+InitButton.h"
#import "Tags.h"
#import "UserDoc.h"
#import "SelectCustomersCell.h"
#import "AppointmentListTableViewCell.h"
#import "ZXTabBarController.h"

#define UPLATE_CUSTOMER_LIST_DATE  @"UPLATE_CUSTOMER_LIST_DATE"
@interface SelectServicePersonnal_ViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *_requestCustomerListOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestGroupList;
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic) TitleView *titelView;
@property (nonatomic) NSMutableArray *users;
@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (nonatomic, copy) NSString *tagIDs;
@property (strong, nonatomic)  UITableView *myListView;
@property (strong, nonatomic)  UISearchBar *mySearchBar;
@property (nonatomic) NSMutableArray *userArray;          // 数据库查询的user
@property (nonatomic) NSMutableArray *searchResultArray;
@property (nonatomic) NSMutableArray *user_Selected;// searchBar 搜索的user

@end

@implementation SelectServicePersonnal_ViewController
@synthesize groupArray;
@synthesize titelView;
@synthesize users;
@synthesize isSearching;
@synthesize accessoryInputView;
@synthesize tagIDs;
@synthesize myListView;
@synthesize mySearchBar;
@synthesize userArray;
@synthesize searchResultArray;
@synthesize user_Selected;


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

- (void)viewWillAppear:(BOOL)animated
{
    
    [myListView triggerPullToRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}


- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    self.groupArray = [NSMutableArray array];
    
    // ---searchBar
    isSearching = NO;
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    mySearchBar.backgroundImage = nil;
    mySearchBar.placeholder = @"来搜索你想要找的人吧!";
    mySearchBar.frame = CGRectMake(5,5,kSCREN_BOUNDS.size.width-10, 44);
    mySearchBar.delegate = self;
    [mySearchBar setBackgroundImage:[self backgroundImage]];
    [mySearchBar setBackgroundImage:[self backgroundImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [self.view addSubview:mySearchBar];
    self.title = @"服务顾问";
    // ---TableView
    myListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44 + 10, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -kNavigationBar_Height - 44 - 10 + 20)];
    myListView.delegate = self;
    myListView.dataSource = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = YES;
    myListView.separatorColor=kTableView_LineColor;
//    myListView.allowsSelection = NO;
    myListView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:myListView];
    
    
    __weak SelectServicePersonnal_ViewController *SelectServicePersonnal = self;
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [SelectServicePersonnal pullToRefreshData];
        });
    }];
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_CUSTOMER_LIST_DATE];
    if (uploadDate) {
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
    
}


- (UIImage *)backgroundImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, kDefaultBackgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)homeAction
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    if ([self.presentingViewController isKindOfClass:[ZXTabBarController class]]) {
        ZXTabBarController *tab = (ZXTabBarController *)self.presentingViewController;
       UINavigationController *nav = [tab.viewControllers objectAtIndex:1]; //预约nav
        [nav popToRootViewControllerAnimated:YES];
        tab.selectedIndex = 0;
    }
}
- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)pullToRefreshData
{
    if (!isSearching) {
        [self requesAccountListByBranchID];
    } else {
        [self pullToRefreshDone];
    }
}

- (void)pullToRefreshDone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"上次更新时间: MM/dd hh:mm:ss"];
    NSString *data2Str = [formatter stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:data2Str forKey:UPLATE_CUSTOMER_LIST_DATE];
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
    return [users count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = @"SelectCustomersCell";
    SelectCustomersCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[SelectCustomersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    
    UserDoc *userDoc = [users objectAtIndex:indexPath.row];
    
    [cell updateData:userDoc];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserDoc *userDoc = [users objectAtIndex:indexPath.row];
    
    NSArray * arr = [[NSArray alloc] initWithObjects:userDoc, nil];
    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithSelectedSales:)]) {
        [self.delegate dismissViewControllerWithSelectedSales:arr];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[self initInputAccessoryView];
    //searchBar.inputAccessoryView = accessoryInputView;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0) {
        [self setIsSearching:YES];
        [self initSearchArrayByText:searchText];
        users = [searchResultArray mutableCopy];
        [myListView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        
        [self requesAccountListByBranchID];
    }
}

- (void)initSearchArrayByText:(NSString *)text
{
    if (!searchResultArray) {
        searchResultArray = [NSMutableArray array];
    } else {
        [searchResultArray removeAllObjects];
    }
    
    NSString *string = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (UserDoc *userDoc in userArray) {
        if ([userDoc.user_Name containsString:string] ||
            [userDoc.user_ShortPinYin containsString:string] ||
            [userDoc.user_QuanPinYin containsString:string] ||
            [userDoc.user_LoginMobile containsString:string])
        {
            [searchResultArray addObject:userDoc];
        }
    }
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mySearchBar resignFirstResponder];
}

- (void)initInputAccessoryView
{
    if (accessoryInputView == nil) {
        accessoryInputView  = [[UIToolbar alloc] init];
        accessoryInputView.barStyle = UIBarStyleBlackTranslucent;
        accessoryInputView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [accessoryInputView sizeToFit];
        //CGRect frame1 = accessoryInputView.frame;
        //frame1.size.height = 44.0f;
        //accessoryInputView.frame = frame1;
        
        //UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        
        //UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        //NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        //[accessoryInputView setItems:array];
    }
}

- (void)dismissKeyboard
{
    [mySearchBar resignFirstResponder];
}

- (void)requestGroup {
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Type\":2}", (long)CUS_COMPANYID, (long)self.BracnID];
    
    _requestGroupList  = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Tag/getTagList" showErrorMsg:YES  parameters:par WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [self.groupArray removeAllObjects];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [self.groupArray addObject:[[Tags alloc] initWithDictionary:data]];
        }failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [myListView reloadData];
    } failure:^(NSError *error) {
        
    }];
}


- (void)requesAccountListByBranchID
{
    NSString *message = @"";

     message = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"ImageHeight\":160,\"ImageWidth\":160,\"Flag\":\"%d\",\"CustomerID\":%ld}", (long)self.BracnID, 2, (long)CUS_CUSTOMERID];
    
    __requestCustomerListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/account/getAccountListForCustomer" showErrorMsg:YES  parameters:message WithSuccess:^(id json) {
        [self pullToRefreshDone];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (!userArray) {
                userArray = [NSMutableArray array];
            } else {
                [userArray removeAllObjects];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                UserDoc *userDoc = [[UserDoc alloc] init];
                [userDoc setUser_Type:1];
                [userDoc setUser_Id:[[obj objectForKey:@"AccountID"] integerValue]];
                [userDoc setUser_Name:[obj objectForKey:@"AccountName"]];
                [userDoc setUser_QuanPinYin:[obj objectForKey:@"PinYin"] ];
                [userDoc setUser_ShortPinYin:[obj objectForKey:@"PinYinFirst"]];
                [userDoc setUser_HeadImage:[obj objectForKey:@"HeadImageURL"]];
                [userDoc setUser_Code:[obj objectForKey:@"AccountCode"]];
                [userDoc setAccountType:[[obj objectForKey:@"AccountType"] integerValue]];
                [userDoc setUser_Available:1];
                [userArray addObject:userDoc];
                
            }];
            if (!users) {
                users = [NSMutableArray array];
            } else {
                [users removeAllObjects];
            }
            users = [userArray mutableCopy];
            
        }failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [myListView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
