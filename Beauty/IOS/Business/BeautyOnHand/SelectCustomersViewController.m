//
//  CustomerListViewController.m
//  customerArray
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "SelectCustomersViewController.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIButton+InitButton.h"
#import "NSString+Additional.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"

#import "UIActionSheet+AddBlockCallBacks.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "UserDoc.h"
#import "AppDelegate.h"
#import "FooterView.h"
#import "GPBHTTPClient.h"

#import "SVProgressHUD.h"
#import "DFChooseAlertView.h"
#import "DFTableCell.h"
#import "Tags.h"

#define UPLATE_CUSTOMER_LIST_DATE  @"UPLATE_CUSTOMER_LIST_DATE"

@interface SelectCustomersViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestCustomerListOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateResponsiblePersonOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestAddResponsiblePerson;
@property (nonatomic, weak) AFHTTPRequestOperation *requestGroupList;
@property (nonatomic, weak) AFHTTPRequestOperation *requestAddSalesPerson;
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic) NavigationView *navigationView;
@property (nonatomic) UIButton *checkAllButton;

@property (nonatomic) NSMutableArray *user_Selected;
@property (assign, nonatomic) NSInteger selectModel;
@property (assign, nonatomic) NSInteger userType;

@property (nonatomic) NSMutableArray *userArray;          // 数据库查询的user
@property (nonatomic) NSMutableArray *searchResultArray;  // searchBar 搜索的user
@property (nonatomic) NSMutableArray *users;              // 页面显示的user
@property (nonatomic) NSInteger type;                     // type=0 我的顾客/公司人员    type=1 公司顾客/机构人员
@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) UIToolbar *accessoryInputView;
@property (nonatomic, copy) NSString *tagIDs;
@property (nonatomic, strong) NSMutableString *slaveID;
@property (nonatomic,assign) NSInteger flag ;
@end

@implementation SelectCustomersViewController
@synthesize myListView;
@synthesize mySearchBar;
@synthesize navigationView;
@synthesize users;
@synthesize userArray;
@synthesize searchResultArray;
@synthesize isSearching;
@synthesize type;
@synthesize user_Selected;
@synthesize selectModel;
@synthesize checkAllButton;
@synthesize userType;
@synthesize delegate;
@synthesize pushOrpop;
@synthesize navigationTitle;
@synthesize prevView;
@synthesize orderId;
@synthesize customerId;
@synthesize accessoryInputView;
@synthesize groupArray;
@synthesize tagIDs;
@synthesize personType;


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
    [super viewWillAppear:animated];
    
    [myListView triggerPullToRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestCustomerListOperation && [_requestCustomerListOperation isExecuting]) {
        [_requestCustomerListOperation cancel];
        _requestCustomerListOperation = nil;
    }
    
    if (_requestUpdateResponsiblePersonOperation && [_requestUpdateResponsiblePersonOperation isExecuting]) {
        [_requestUpdateResponsiblePersonOperation cancel];
        _requestUpdateResponsiblePersonOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(goBack)
                                           frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                   backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    
    // ---searchBar
    isSearching = NO;
    mySearchBar.backgroundImage = nil;
    mySearchBar.placeholder = @"来搜索你想要找的人吧!";
    mySearchBar.frame = CGRectMake(0.0f, -44.0f, kSCREN_BOUNDS.size.width, 44.0f);
    mySearchBar.delegate = self;
    [mySearchBar setBackgroundImage:[self backgroundImage]];
    [mySearchBar setBackgroundImage:[self backgroundImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    
    // ---NavigationView
    // check all button
    checkAllButton = [UIButton buttonWithTitle:@""
                                        target:self
                                      selector:@selector(checkAllAction)
                                         frame:CGRectMake(314.0f - HEIGHT_NAVIGATION_VIEW, 0.0f, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                 backgroundImg:[UIImage imageNamed:@"icon_unCheckedTitle"]
                              highlightedImage:nil];
    [checkAllButton setBackgroundImage:[UIImage imageNamed:@"icon_CheckedTitle"] forState:UIControlStateSelected];
    
    // filterButton
    UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(filterAction)
                                                 frame:CGRectMake(CGRectGetMinX(checkAllButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"icon_Screen"]
                                      highlightedImage:nil];
    
    // 美丽顾问分组筛选
    UIButton *personFilter = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(personFilterAction)
                                                 frame:CGRectMake(CGRectGetMinX(checkAllButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"group_respon"]
                                      highlightedImage:nil];

    
    // search Button
    UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(searchAction)
                                                 frame:CGRectMake(CGRectGetMinX(filterButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"icon_Search"]
                                      highlightedImage:nil];
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,kORIGIN_Y + 5.0f) title:[navigationTitle isEqualToString:@""] ? @"选择人员" : navigationTitle];
    [navigationView addSubview:checkAllButton];
    if(userType == 0 || userType == 4)
    {
        [navigationView addSubview:filterButton];
    }
    // 如果是选择美丽顾问 则添加筛选按钮
    if ( userType == 1 || userType == 2 || userType == 3) {
        [navigationView addSubview:personFilter];
    }
    [navigationView addSubview:searchButton];
    [self.view addSubview:navigationView];
    
    if (selectModel == 0 ) { //|| (selectModel == 1 &&  userType == 1)
        checkAllButton.hidden = YES;
        
        CGRect filterRec = filterButton.frame;
        filterRec.origin.x = 314 - HEIGHT_NAVIGATION_VIEW;
        filterButton.frame = filterRec;
        
        CGRect searchRect = searchButton.frame;
        searchRect.origin.x = filterButton.frame.origin.x - HEIGHT_NAVIGATION_VIEW;
        searchButton.frame = searchRect;
    }
    if((userType == 2 && selectModel == 0) || userType == 3 || (userType == 1 && selectModel == 0))
        searchButton.frame = CGRectMake(278, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW);
    // ---TableView
    myListView.delegate = self;
    myListView.dataSource = self;
    myListView.showsHorizontalScrollIndicator = NO;
    myListView.showsVerticalScrollIndicator = YES;
    myListView.allowsSelection = NO;
    myListView.autoresizingMask = UIViewAutoresizingNone;
    myListView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 44.0f - 5.0f);
    
    __weak SelectCustomersViewController *selectCustomersViewController = self;
    [myListView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [selectCustomersViewController pullToRefreshData];
        });
    }];
    NSString *uploadDate = [[NSUserDefaults standardUserDefaults] objectForKey:UPLATE_CUSTOMER_LIST_DATE];
    if (uploadDate) {
        [myListView.pullToRefreshView setSubtitle:uploadDate forState:SVPullToRefreshStateAll];
    } else {
        [myListView.pullToRefreshView setSubtitle:@"没有记录" forState:SVPullToRefreshStateAll];
    }
    
    //---footView
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, myListView.frame.origin.y + myListView.frame.size.height + 5, 320.0f, 44.0f)];
    [footView setBackgroundColor:[UIColor clearColor]];
    
//    UIButton *submitButton = [UIButton buttonWithTitle:@""
//                                      target:self
//                                    selector:@selector(confirmAction)
//                                       frame:CGRectMake(5.0f, 0.0f, 310.0f , 36.0f)
//                               backgroundImg:[UIImage imageNamed:@"buttonLong_Confirm"]
//                            highlightedImage:nil];
    UIButton *submitButton = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirmAction) frame:CGRectMake(5.0f, 0.0f, 310.0f, 36.0f) backgroundImg:ButtonStyleBlue];
    [footView addSubview:submitButton];
    [self.view addSubview:footView];
    
    if (userType == 1 || userType == 2 || userType == 3) {
        [self requestGroup];
    }

}


- (UIImage *)backgroundImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, kColor_Background_View.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)goBack
{
    if (pushOrpop == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)checkAllAction
{
    if (checkAllButton.isSelected) {
        checkAllButton.selected = NO;
        
        [self initAllUsersWithSelectedState:NO];
        [myListView reloadData];
        
        [user_Selected removeAllObjects];
    } else {
        checkAllButton.selected = YES;
        
        [self initAllUsersWithSelectedState:YES];
        [myListView reloadData];
        
        user_Selected = [users mutableCopy];
    }
}

- (void)filterAction
{
    if (userType == 0 || userType == 4) {
        if (ACC_BRANCHID == 0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"筛选" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的顾客", @"公司顾客", nil];
            [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex != 2) {
                    type = buttonIndex;
                    checkAllButton.selected = NO;
                    [user_Selected removeAllObjects];
                    [myListView triggerPullToRefresh];
                }
            }];
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"筛选" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的顾客", @"门店顾客", @"所有顾客", nil];
            [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex != 3) {
                    if (buttonIndex == 1) {
                        type = 2;
                        checkAllButton.selected = NO;
                        [user_Selected removeAllObjects];
                    } else if(buttonIndex == 2) {
                        type = 1;
                        checkAllButton.selected = NO;
                        [user_Selected removeAllObjects];
                    } else if(buttonIndex == 0) {
                        type = 0;
                        checkAllButton.selected = NO;
                        [user_Selected removeAllObjects];
                    }
                    
                    [myListView triggerPullToRefresh];
                }
            }];
        }
       
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"筛选" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"所有人员", @"本店人员", nil];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex != 2) {
                type = buttonIndex;
                checkAllButton.selected = NO;
                [user_Selected removeAllObjects];
                [myListView triggerPullToRefresh];
            }
        }];
    }
    
}

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
                [self requesAccountListByBranchID];
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

- (void)searchAction
{
    if (mySearchBar.isHidden) {
        [UIView beginAnimations:@"" context:nil];
        mySearchBar.hidden = NO;
        mySearchBar.frame = CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 44.0f);
        
        CGRect rect_Search = navigationView.frame;
        rect_Search.origin.y = mySearchBar.frame.origin.y + mySearchBar.frame.size.height;
        navigationView.frame = rect_Search;
        
        myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height , 310.0f, kSCREN_BOUNDS.size.height - 20.0f - navigationView.frame.size.height - navigationView.frame.origin.y - 49.0f - 44.0f);
        [UIView commitAnimations];
    } else {
        
        [mySearchBar resignFirstResponder];
        mySearchBar.text = @"";
        isSearching = NO;
        
        [self requestList];
        
        [UIView beginAnimations:@"" context:nil];
        mySearchBar.hidden = YES;
        mySearchBar.frame = CGRectMake(0.0f, -44.0f, kSCREN_BOUNDS.size.width, 44.0f);
        navigationView.frame = CGRectMake(0.0f, 5.0f, 320.0f, HEIGHT_NAVIGATION_VIEW);
        myListView.frame = CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 20.0f - navigationView.frame.size.height - navigationView.frame.origin.y - 49.0f - 44.0f );
        [UIView commitAnimations];
    }
}

- (void)confirmAction
{
    if ([user_Selected count] == 0 && (userType == 3 || userType == 0)) {
        if (userType == 0) {
            [SVProgressHUD showSuccessWithStatus2:@"请选择顾客" touchEventHandle:^{}];
        }else if(userType == 5)
            [SVProgressHUD showSuccessWithStatus2:@"请选择服务人员" touchEventHandle:^{}];
        
        else if (userType == 2) {
            [SVProgressHUD showSuccessWithStatus2:@"请选择销售顾问" touchEventHandle:^{}];
        }
        else
            //        } else if (userType == 1 || userType == 3) {
            [SVProgressHUD showErrorWithStatus2:@"请选择服务顾问" touchEventHandle:^{
                
            }];
            return;
    }
    
//    if ([user_Selected count] > 0) {
        if (prevView == 8 || prevView == 10) {
            if ([user_Selected count] == 0) {
                [self dismissViewControllerAnimated:YES completion:^{}];
            } else {
                if (prevView == 8) {
                    [self addResponsiblePersonWithCustomerID:((UserDoc *)[user_Selected firstObject]).user_Id];
                } else {
                    [self addSalesPersonWithCustomerID:((UserDoc *)[user_Selected firstObject]).user_Id];
                }
            }
        } else if (prevView == 9) {
            UserDoc *userDoc = [[UserDoc alloc] init];
            userDoc = (UserDoc *)[user_Selected firstObject];
            [self requestUpdateResponsiblePersonWithOrderId:orderId andResponsiblePersonID:userDoc.user_Id];
        } else {
            
            if ( ![self.serveType isKindOfClass:[NSNull class]]&&[self.serveType isEqualToString:@"serve"]) {
                if ([delegate respondsToSelector:@selector(dismissViewControllerWithServe:groupDic:)])
                {
                    UserDoc *userDoc = [[UserDoc alloc] init];
                    userDoc = (UserDoc *)[user_Selected firstObject];
                    NSInteger userID = userDoc.user_Id;
                    [delegate dismissViewControllerWithServe:userID groupDic:self.groupDic];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }else
                if ([delegate respondsToSelector:@selector(dismissViewControllerWithSelectedUser:)] || [delegate respondsToSelector:@selector(dismissViewControllerWithSelectedSales:)]) {
                    
                    if (pushOrpop == 1) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self dismissViewControllerAnimated:YES completion:^{}];
                    }
                    if (userType == 2) {
                       
                        [delegate dismissViewControllerWithSelectedSales:user_Selected];
                    }
                    else {
                        [delegate dismissViewControllerWithSelectedUser:user_Selected];
                    }
            }
        }
}

- (void)setSelectModel:(int)newselectModel userType:(int)newuserType customerRange:(CUSTOMERRANGE)_type defaultSelectedUsers:(NSArray *)defaultselectedArray
{
    selectModel = newselectModel;
    userType = newuserType;
    type = _type;
    
    if  (defaultselectedArray)
        user_Selected = [NSMutableArray arrayWithArray:defaultselectedArray];
    else
        user_Selected = [NSMutableArray array];
}

- (void)setNavTitle:(NSString *)title
{
    self.navigationView.titleLabel.text = title;
}

- (void)pullToRefreshData
{
    if (!isSearching) {
        if (_requestCustomerListOperation && [_requestCustomerListOperation isExecuting]) {
            [_requestCustomerListOperation cancel];
        }
        
        [self requestList];
        
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
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = @"SelectCustomersCell";
    SelectCustomersCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[SelectCustomersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect nameFrame = cell.nameLabel.frame;
        nameFrame.size.width = 150;
        cell.nameLabel.frame = nameFrame;
        CGRect accountLabelFrame = cell.accessoryLabel.frame;
        accountLabelFrame.origin.x = CGRectGetMaxX(nameFrame);
        accountLabelFrame.size.width = 80.0f;
        cell.accessoryLabel.frame = accountLabelFrame;
    }
    UserDoc *userDoc = [users objectAtIndex:indexPath.row];
    
    [cell updateData:userDoc];
    [cell setDelegate:self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SelectCustomersCellDelegate

- (void)selectCustomersCell:(SelectCustomersCell *)cell touchTheSelectButton:(UIButton *)selectButton;
{
    NSIndexPath *indexPath = [myListView indexPathForCell:cell];
    UserDoc *userDoc = [users objectAtIndex:indexPath.row];
    
    if (user_Selected == nil) {
        user_Selected = [NSMutableArray array];
    }
    
    // 修改该userDoc状态
    // 修改其他userDic状态 【tableView reloadData】
    // 从user_Selected添加或者删除
    
    if (selectModel == 0) { // 单选
        if ([user_Selected count] == 0) {
            [user_Selected addObject:userDoc];
        } else {
           [self initAllUsersWithSelectedState:NO];
            [user_Selected removeAllObjects];
            if (selectButton.isSelected) {
                [userDoc setUser_SelectedState:YES];
                [user_Selected addObject:userDoc];
            }
//            [self initAllUsersWithSelectedState:NO];
//            if (userDoc.user_SelectedState == YES) {
//                userDoc.user_SelectedState = NO;
//                [user_Selected removeAllObjects];
//            } else {
//                [userDoc setUser_SelectedState:YES];
//                [user_Selected removeAllObjects];
//                [user_Selected addObject:userDoc];
//            }
            [myListView reloadData];
        }
    } else {  // 多选
        if (selectButton.isSelected) {
            [user_Selected addObject:userDoc];
        } else {
            for (UserDoc *tmpUser in user_Selected) {
                if (tmpUser.user_Id == userDoc.user_Id) {
                    [user_Selected removeObject:tmpUser];
                    break;
                }
            }
        }
        
        if ([user_Selected count] == [users count]) {
            [checkAllButton setSelected:YES];
        } else {
            [checkAllButton setSelected:NO];
        }
    }
}

- (void)initAllUsersWithSelectedState:(BOOL)isSelected
{
    for (UserDoc *tempUser in users) {
        [tempUser setUser_SelectedState:isSelected];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self initInputAccessoryView];
    searchBar.inputAccessoryView = accessoryInputView;
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
        
        [self requestList];
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
        CGRect frame1 = accessoryInputView.frame;
        frame1.size.height = 44.0f;
        accessoryInputView.frame = frame1;
        
        UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
        [accessoryInputView setItems:array];
    }
}

- (void)dismissKeyboard
{
    [mySearchBar resignFirstResponder];
}

#pragma mark - 接口

- (void)requestList
{
    if (userType == 0 || userType == 4) {
        
        [self requesCustomertList];
        
    } else if (userType == 1 || userType == 2 || userType == 3||userType == 5) {
        
        if (self.flag) {
             [self requesAccountListByBranchID];
        }
    }
}

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
            [self requesAccountListByBranchID];
            
        } failure:^(NSInteger code, NSString *error) {
            self.flag = 1;
            [self requesAccountListByBranchID];
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        self.flag = 1;
        [self requesAccountListByBranchID];
    }];
    
}


- (void)requesCustomertList
{
    self.view.userInteractionEnabled = NO;
    
    NSString *par = [NSString stringWithFormat:@"{\"RegistFrom\":%ld,\"sourcetype\":%ld,\"AccountID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%ld,\"LevelID\":\"\"}", (long)-1, (long)-1, (long)ACC_ACCOUNTID , (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)type];

    _requestCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [self pullToRefreshDone];
            if (!userArray)
                userArray = [NSMutableArray array];
            else
                [userArray removeAllObjects];
            
            for (NSDictionary *dict in data){
                UserDoc *userDoc = [[UserDoc alloc] init];
                [userDoc setUser_Type:0];
                [userDoc setUser_Id:[[dict objectForKey:@"CustomerID"] integerValue]];
                [userDoc setUser_Name:[dict objectForKey:@"CustomerName"]];
                [userDoc setUser_QuanPinYin:[dict objectForKey:@"PinYin"]];
                [userDoc setUser_ShortPinYin:[dict objectForKey:@"PinYinFirst"]];
                [userDoc setUser_HeadImage:[dict objectForKey:@"HeadImageURL"]];
                [userDoc setUser_LoginMobile:[dict objectForKey:@"LoginMobile"]];
                [userDoc setUser_Available:1];
                [userArray addObject:userDoc];
            }
            
            
            if (!users) {
                users = [NSMutableArray array];
            } else {
                [users removeAllObjects];
            }
            
            int count = 0;
            for (UserDoc *user in user_Selected) {
                for (UserDoc *tempUser in userArray) {
                    if (user.user_Id == tempUser.user_Id ) { //!user.user_SelectedState &&
                        [tempUser setUser_SelectedState:YES];
                        count ++;
                    }
                }
            }
            
            if (count == [userArray count]) {
                [checkAllButton setSelected:YES];
            }
            
            users = [userArray mutableCopy];
            [myListView reloadData];
            
            self.view.userInteractionEnabled = YES;
            
        } failure:^(NSInteger code, NSString *error) {
            self.view.userInteractionEnabled = YES;
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        [self pullToRefreshDone];
        self.view.userInteractionEnabled = YES;
    }];
    
}

- (void)requesAccountListByBranchID
{
    
    NSInteger accountID = ACC_ACCOUNTID;
    
    if ((self.viewFor == 1 &&([[PermissionDoc sharePermission] rule_CustomerInfo_Write]))|| (self.viewFor == 2 &&[[PermissionDoc sharePermission] rule_Record_Write])) {
        
        accountID = 0;
        
    }
    
    NSString *message = @"";
    if (type == 0) {
        message = [NSString stringWithFormat:@"{\"AccountID\":0,\"ImageHeight\":160,\"ImageWidth\":160,\"TagIDs\":\"%@\",\"CustomerID\":%ld}", self.tagIDs, (long)self.customerId];
    } else if (type == 1) {
        message = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"ImageHeight\":160,\"ImageWidth\":160,\"TagIDs\":\"%@\",\"CustomerID\":%ld}", (long)ACC_COMPANTID, self.tagIDs, (long)self.customerId];
    } else if (type == 2) {
        message = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"ImageHeight\":160,\"ImageWidth\":160,\"TagIDs\":\"%@\",\"CustomerID\":%ld}", (long)accountID, self.tagIDs, (long)self.customerId];
    }else if (type ==3)
    {
        //选择专属顾问
        message = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"ImageHeight\":160,\"ImageWidth\":160,\"TagIDs\":\"%@\",\"CustomerID\":%ld}", (long)accountID, self.tagIDs, (long)self.customerId];
    }
    
    _requestCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/getAccountList" andParameters:message failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [self pullToRefreshDone];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
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
            
            int count = 0;
            for (UserDoc *user in user_Selected) {
                for (UserDoc *tempUser in userArray) {
                    if (user.user_Id == tempUser.user_Id) { //!user.user_SelectedState &&
                        [tempUser setUser_SelectedState:YES];
                        count ++;
                    }
                }
            }
            
            if (count == [userArray count]) {
                [checkAllButton setSelected:YES];
            }
            if (self.user_Selected.count) {
                users = [[userArray sortedArrayUsingSelector:@selector(compareUserSelectedState:)] mutableCopy];
            }
            else {
                users = [userArray mutableCopy];
            }

            [myListView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

//废止
- (void)requesAccountListByCompanyId
{
    _requestCustomerListOperation = [[GPHTTPClient shareClient] requestGetAccountListByType:1 success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [self pullToRefreshDone];
            
            if (!userArray) {
                userArray = [NSMutableArray array];
            } else {
                [userArray removeAllObjects];
            }
            for (GDataXMLElement *accountEle in [contentData elementsForName:@"Account"]) {
                UserDoc *userDoc = [[UserDoc alloc] init];
                [userDoc setUser_Type:1];
                [userDoc setUser_Id:[[[[accountEle elementsForName:@"AccountID"] objectAtIndex:0] stringValue] integerValue]];
                [userDoc setUser_Name:[[[accountEle elementsForName:@"AccountName"] objectAtIndex:0] stringValue]];
                [userDoc setUser_QuanPinYin:[[[accountEle elementsForName:@"PinYin"] objectAtIndex:0] stringValue]];
                [userDoc setUser_ShortPinYin:[[[accountEle elementsForName:@"PinYinFirst"] objectAtIndex:0] stringValue]];
                [userDoc setUser_HeadImage:[[[accountEle elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue]];
                [userDoc setUser_Code:[[[accountEle elementsForName:@"AccountCode"] objectAtIndex:0] stringValue]];
                [userDoc setUser_Available:1];
                [userArray addObject:userDoc];
            }
            
            if (!users) {
                users = [NSMutableArray array];
            } else {
                [users removeAllObjects];
            }
            
            int count = 0;
            for (UserDoc *user in user_Selected) {
                for (UserDoc *tempUser in userArray) {
                    if (user.user_Id == tempUser.user_Id) { //!user.user_SelectedState &&
                        [tempUser setUser_SelectedState:YES];
                        count ++;
                    }
                }
            }
            
            if (count == [userArray count]) {
                [checkAllButton setSelected:YES];
            }

            users = [userArray mutableCopy];
            
            [myListView reloadData];
            
        } failure:^{
            
        }];
    } failure:^(NSError *error) {}];
}

// completeTreatment
- (void)requestUpdateResponsiblePersonWithOrderId:(NSInteger)ordId andResponsiblePersonID:(NSInteger)rpId
{
    NSDictionary * par = @{
                           @"OrderObjectID":@((long)self.orderObjectID),
                            @"ProductType":@((long)self.productType),
                            @"ResponsiblePersonID":@((long)rpId),
                            @"OrderID":@((long)ordId)
                           };

    _requestUpdateResponsiblePersonOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateResponsiblePerson" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"美丽顾问修改成功" touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)addResponsiblePersonWithCustomerID:(NSInteger)responsibleID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld}", (long)ACC_COMPANTID,(long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)responsibleID, (long)customerId];

    _requestAddResponsiblePerson = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/addResponsiblePersonID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"专属顾问设置成功" touchEventHandle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)addSalesPersonWithCustomerID:(NSInteger)salesID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"AccountIDList\":%@,\"CustomerID\":%ld}",self.slaveID, (long)customerId];
    _requestAddSalesPerson = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/updateSalesPersonID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"销售顾问设置成功" touchEventHandle:^{
                if (userType == 2) {
                    
                    [delegate dismissViewControllerWithSelectedSales:user_Selected];
                }
                 [self dismissViewControllerAnimated:YES completion:^{}];
               
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {

    }];
}

- (NSString *)slaveID
{
    NSMutableArray *slaveIdArray = [NSMutableArray array];
    NSMutableString *str = [NSMutableString string];
    if (user_Selected.count) {
        for (UserDoc *user in user_Selected) {
            [slaveIdArray addObject:@(user.user_Id)];
        }
        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
        [str appendString:[NSString stringWithFormat:@"[%@]", tmpIds]];
    } else {
        [str appendString:@""];
    }
    NSLog(@"str is %@", str);
    return str;
}
@end
