//
//  ProductListViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ServiceListViewController.h"
#import "ServiceDetailViewController.h"
#import "OrderConfirmViewController.h"
#import "CategoryDoc.h"
#import "ServiceDoc.h"
#import "AppDelegate.h"
#import "NSString+Additional.h"
#import "UIButton+InitButton.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "UIImageView+WebCache.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "GPBHTTPClient.h"
#import "FooterView.h"
#import "CusMainViewController.h"
#import "GPNavigationController.h"
#import "AppointmenCreat_ViewController.h"

@interface ServiceListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetListByCompanyIDOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetListByCategoryIDOperation;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NavigationView *navigationView;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) NSArray *serviceOrigArray;
@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (strong, nonatomic) NSMutableArray *service_SelectedArray;
@property (strong, nonatomic) NSMutableArray *serviceSearchArray;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (nonatomic, strong) NSMutableArray *tmp_Service;

@end

@implementation ServiceListViewController
@synthesize serviceArray;
@synthesize isSearching;
@synthesize service_SelectedArray;
@synthesize categoryDoc;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];;
    
    if (_requestGetListByCategoryIDOperation && [_requestGetListByCategoryIDOperation isExecuting]) {
        [_requestGetListByCategoryIDOperation cancel];
    }
    
    if (_requestGetListByCompanyIDOperation && [_requestGetListByCompanyIDOperation isExecuting]) {
        [_requestGetListByCompanyIDOperation cancel];
    }
    
    _requestGetListByCategoryIDOperation = nil;
    _requestGetListByCompanyIDOperation = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar setText:@""];
    [self request];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self initData];
    [self initLayOut];

}

- (void)initData
{
    service_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] serviceArray_Selected];
    self.tmp_Service = [[NSMutableArray alloc] initWithArray:service_SelectedArray];
}


- (void)initLayOut
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [_searchBar setBackgroundImage:[self backgroundImage]];
    [_searchBar setBackgroundImage:[self backgroundImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    _searchBar.placeholder = @"来搜索你想要找的服务项目吧!";
//    _searchBar.hidden = YES;
    _searchBar.frame = CGRectMake(0.0f, kORIGIN_Y+3, kSCREN_BOUNDS.size.width, 44.0f);
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    if ((IOS7 || IOS8)) _searchBar.barTintColor = kColor_Background_View;
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f)
                                                         title:[NSString stringWithFormat:@"服务(%@)",
                                                                categoryDoc ? categoryDoc.CategoryName :@"全部"]];
    CGRect navFrame = _navigationView.frame;
    navFrame.origin.y += 44.0;
    _navigationView.frame = navFrame;
//    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Search"] selector:@selector(searchAction)];
    [self.view addSubview:_navigationView];
    
    if (self.returnViewTag ==1) {
        UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(goBack)
                                                     frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                             backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                          highlightedImage:nil];
        
        UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
        self.navigationItem.leftBarButtonItem = goBackBarButton;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 69.0f - 44.0 - 40.0) style:UITableViewStylePlain];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _initialTVHeight = _tableView.frame.size.height;

    [self.view addSubview:_tableView];
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    if (self.returnViewTag ==1) {
        _tableView.frame = CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 69.0f - 40.0);
    }else{
        FooterView *footView = [[FooterView alloc] initWithTarget:self submitTitle:@"确定" submitAction:@selector(affrimOrder:)];
        
        footView.frame = CGRectMake(5, CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame), 36.0);
        
        [self.view addSubview:footView];
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
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)affrimOrder:(UIButton *)button
{
    [service_SelectedArray removeAllObjects];
    if (self.tmp_Service.count) {
        [service_SelectedArray addObjectsFromArray:self.tmp_Service];
        
        CusMainViewController *completionVC = [[CusMainViewController alloc] init];
        completionVC.viewOrigin = CusMainViewOriginProductList;
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:completionVC];
        navCon.canDragBack = YES;
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = navCon;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
        //跳转至开单页
//        OrderConfirmViewController *orderCon = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
//        [self.navigationController pushViewController:orderCon animated:YES];

    } else {
        [SVProgressHUD showErrorWithStatus2:@"清除已选服务!" touchEventHandle:^{}];
    }
}

- (void)searchAction
{
    if (_searchBar.isHidden) {
        _searchBar.hidden = NO;
        
        [UIView beginAnimations:@"" context:nil];
        _searchBar.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        _navigationView.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        _tableView.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        
        CGRect rect = _tableView.frame;
        rect.size.height -= 44.0f;
        _tableView.frame = rect;
        _initialTVHeight = _tableView.frame.size.height;

        [UIView commitAnimations];
        
    } else {
        
        [_searchBar resignFirstResponder];
        //[_searchBar setText:@""];
        [_searchBar setHidden:YES];
        
        isSearching = NO;
        
        [UIView beginAnimations:@"" context:nil];
        _searchBar.transform = CGAffineTransformIdentity;
        _navigationView.transform = CGAffineTransformIdentity;
        _tableView.transform = CGAffineTransformIdentity;
        
        CGRect rect = _tableView.frame;
        rect.size.height += 44.0f;
        _tableView.frame = rect;
        _initialTVHeight = _tableView.frame.size.height;

        [UIView commitAnimations];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Keyboard Notification
-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 5.0f + 35.0f;
    _tableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    self.textField_Selected = nil;
    CGRect tvFrame = _tableView.frame;
    tvFrame.size.height = _initialTVHeight;
    _tableView.frame = tvFrame;
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0) {
        [self setIsSearching:YES];
        [self initSearchArrayByText:searchText];
        serviceArray = [_serviceSearchArray mutableCopy];
        [_tableView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        serviceArray = [NSMutableArray arrayWithArray: _serviceOrigArray];
        [_tableView reloadData];
    }
}

- (void)initSearchArrayByText:(NSString *)text
{
    if(!_serviceSearchArray)
        _serviceSearchArray = [NSMutableArray array];
    else
        [_serviceSearchArray removeAllObjects];
    NSString *condition = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (ServiceDoc *serviceDoc in _serviceOrigArray) {
        if ([serviceDoc.service_ServiceSearchField containsString:condition])
           [_serviceSearchArray addObject:serviceDoc];
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
    [_searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [serviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ProductListCell";
    PSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[PSListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
    }
    if (self.returnViewTag ==1) {
        cell.selectedButton.hidden = YES;
        cell.selectedButton.userInteractionEnabled = NO;
    }
    ServiceDoc *ser = [serviceArray objectAtIndex:indexPath.row];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:ser.service_ImgURL] placeholderImage:[UIImage imageNamed:@"GoodsImg"]];
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@", ser.service_ServiceName]];

//    NSLog(@"test =%Lf  UnitPrice =%.2f",ser.service_CalculatePrice, round(ser.service_CalculatePrice* 100)/100);

    [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,ser.service_UnitPrice]];
    [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ser.service_CalculatePrice]];
    [cell.newbrandImgView  setHidden:!ser.service_NewBrand];
    [cell.recommendImgView setHidden:!ser.service_Recommended];
    [cell.favoriteImageView setHidden:!ser.service_FavouriteID];
    
    [cell setDelegate:self];
    [cell.unitePriceLabel setIsShowMidLine:YES];

    cell.unitePriceLabel.hidden = ser.service_UnitPrice == ser.service_CalculatePrice;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    if (ser.service_MarketingPolicy == 0 || (ser.service_MarketingPolicy == 1 && customerId == 0) || (ser.service_UnitPrice == ser.service_CalculatePrice) ) {
        cell.unitePriceLabel.hidden = YES;
        cell.priceCategoryImageView.hidden = YES;
        cell.promotionPriceLabel.frame = CGRectMake(70.0f, 45.0f, 120.0f, 20.0f);
    } else if (ser.service_MarketingPolicy == 1 && customerId != 0) {
        cell.unitePriceLabel.hidden = NO;
        cell.priceCategoryImageView.hidden = NO;
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
        cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];

        CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
        cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
        [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
        
    } else if (ser.service_MarketingPolicy == 2) {
        cell.unitePriceLabel.hidden = NO;
        cell.priceCategoryImageView.hidden = NO;
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
        cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
        CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
        cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
        [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];

    }
    
    CGRect frame = cell.titleLabel.frame;
    CGSize size = [ser.service_ServiceName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 40.0f)];
    if (size.height > 20) {
        frame.size.height = 40.0f;
        cell.titleLabel.frame = frame;
        cell.titleLabel.numberOfLines = 0;
    } else {
        frame.size.height = 20.0f;
        cell.titleLabel.frame = frame;
        cell.titleLabel.numberOfLines = 1;
    }
    
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_Code == %d", ser.service_Code];//2014.9.9
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", ser.service_ID];
    NSArray *array = [self.tmp_Service filteredArrayUsingPredicate:predicate];
    if ([array count] > 0) {
        [cell.selectedButton setSelected:YES];
    } else {
        [cell.selectedButton setSelected:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  70.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.returnViewTag ==1) {//返回值创建预约页
//        for (UIViewController *temp in self.navigationController.viewControllers) {
//            if ([temp isKindOfClass:[AppointmenCreat_ViewController class]]) {
                 ServiceDoc *ser = [serviceArray objectAtIndex:indexPath.row];
                long long  ID = [[NSString stringWithFormat:@"%lld",ser.service_Code] longLongValue];
                NSDictionary * idDic = @{
                                         @"ID":@((long long)ID)
                                         };
        
            if ([self.delegate respondsToSelector:@selector(dismissServiceViewControllerWithSelectedService:userID:)]) {
                [self.delegate dismissServiceViewControllerWithSelectedService:ser.service_ServiceName userID:idDic];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];

//            }
//        }
    }else{
        //    if(!_searchBar.isHidden)
        //        [self searchAction];
        [self.searchBar resignFirstResponder];
        if ( serviceArray.count == 0 || indexPath.row >= serviceArray.count ) {
            [tableView reloadData];
            return;
        }
        ServiceDoc *ser = [serviceArray objectAtIndex:indexPath.row];
        ServiceDetailViewController *serviceDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
        serviceDetailVC.serviceCode = ser.service_Code;
        serviceDetailVC.favouriteID = ser.service_FavouriteID;
        [self.navigationController pushViewController:serviceDetailVC animated:YES];
    }
}

#pragma mark - PSListTableViewCellDelegate

- (void)didSelectedButtonInCell:(PSListTableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [self addOrRemoveCommodityInCommodity_SelectedArray:indexPath];
}

// 判断commodityDoc是否存在于commodity_SelectedArray
// <是否存在> ？ <remove commodityDoc from  commodity_SelectedArray> : <add commodityDoc in commodity_SelectedArray>

- (void)addOrRemoveCommodityInCommodity_SelectedArray:(NSIndexPath *)indexPath
{
    ServiceDoc *serviceDoc = [serviceArray objectAtIndex:indexPath.row];

   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_Code == %d", serviceDoc.service_Code]; //2014.9.9
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", serviceDoc.service_ID];
//    NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:predicate];
    NSArray *array = [self.tmp_Service filteredArrayUsingPredicate:predicate];

    if ([array count] > 0) {
        [self.tmp_Service removeObject:[array objectAtIndex:0]];
    } else {
       [self.tmp_Service addObject:serviceDoc];
    }
    [_tableView reloadData];
}

#pragma mark - 接口

- (void)request
{
    if (categoryDoc.CategoryID == 0)
        [self requstServiceListByCompanyID];
    else
        [self requstServiceListByCategoryID:categoryDoc.CategoryID];
    
}

- (void)requstServiceListByCompanyID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerID];

    _requestGetListByCompanyIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Service/getServiceListByCompanyID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        self.view.userInteractionEnabled = NO;
        if (serviceArray) {
            [serviceArray removeAllObjects];
        } else {
            serviceArray = [NSMutableArray array];
        }
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [serviceArray addObject:[[ServiceDoc alloc] initWithDictionary:obj]];
            }];
            service_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] serviceArray_Selected];
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:0];
            _serviceOrigArray = serviceArray;
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            self.view.userInteractionEnabled = YES;
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requstServiceListByCategoryID:(NSInteger)categoryID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;

    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld,\"CategoryID\":%ld,\"ImageHeight\":160,\"ImageWidth\":160}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerID, (long)categoryID];
    
    _requestGetListByCategoryIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Service/getServiceListByCategoryID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        self.view.userInteractionEnabled = NO;
        if (serviceArray) {
            [serviceArray removeAllObjects];
        } else {
            serviceArray = [NSMutableArray array];
        }
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [serviceArray addObject:[[ServiceDoc alloc] initWithDictionary:obj]];
            }];
            service_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] serviceArray_Selected];
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:0];
            _serviceOrigArray = serviceArray;
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            self.view.userInteractionEnabled = YES;
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
