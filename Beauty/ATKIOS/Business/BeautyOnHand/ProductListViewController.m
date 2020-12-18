//
//  ProductListViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailViewController.h"
#import "CategoryDoc.h"
#import "CommodityDoc.h"
#import "AppDelegate.h"
#import "UILabel+InitLabel.h"
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
#import "OrderConfirmViewController.h"
#import "CusMainViewController.h"
#import "GPNavigationController.h"

@interface ProductListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetListByCompanyIDOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetListByCategoryIDOperation;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NavigationView *navigationView;
@property (strong, nonatomic) NSArray *commodityOrigArray;
@property (strong, nonatomic) NSMutableArray *commodityArray;
@property (strong, nonatomic) NSMutableArray *commoditySearchArray;
@property (strong, nonatomic) NSMutableArray *commodity_SelectedArray;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (nonatomic, strong) NSMutableArray *tmp_Commodity;
@end

@implementation ProductListViewController
@synthesize commodity_SelectedArray;
@synthesize isSearching;
@synthesize commodityArray;
@synthesize categoryDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
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
    commodity_SelectedArray = [(AppDelegate *) [[UIApplication sharedApplication] delegate] commodityArray_Selected];
    self.tmp_Commodity = [[NSMutableArray alloc] initWithArray:commodity_SelectedArray];
}

- (void)initLayOut
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [_searchBar setBackgroundImage:[self backgroundImage]];
    [_searchBar setBackgroundImage:[self backgroundImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    _searchBar.placeholder = @"来搜索你想要找的商品吧!";
//    _searchBar.hidden = YES;
    _searchBar.frame = CGRectMake(0.0f, kORIGIN_Y+3, kSCREN_BOUNDS.size.width, 44.0f);
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    if ((IOS7 || IOS8)) _searchBar.barTintColor = kColor_Background_View;
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f)
                                                         title:[NSString stringWithFormat:@"商品(%@)",
                                                                categoryDoc ? categoryDoc.CategoryName :@"全部"]];
//     [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Search"] selector:@selector(searchAction)];
    CGRect navFrame = _navigationView.frame;
    navFrame.origin.y += 44.0;
    _navigationView.frame = navFrame;
    [self.view addSubview:_navigationView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 69.0f - 40.0 - 44.0) style:UITableViewStylePlain];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _initialTVHeight = _tableView.frame.size.height;
    [self.view addSubview:_tableView];
    
    FooterView *footView = [[FooterView alloc] initWithTarget:self submitTitle:@"确定" submitAction:@selector(affrimOrder:)];
    
    footView.frame = CGRectMake(5, CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame), 36.0);
    
    [self.view addSubview:footView];

    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;

}

- (void)affrimOrder:(UIButton *)sender
{
    [commodity_SelectedArray removeAllObjects];
    if (self.tmp_Commodity.count) {
//        OrderConfirmViewController *orderCon = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
//        [self.navigationController pushViewController:orderCon animated:YES];
        [commodity_SelectedArray addObjectsFromArray:self.tmp_Commodity];
        CusMainViewController *completionVC = [[CusMainViewController alloc] init];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        completionVC.viewOrigin = CusMainViewOriginProductList;

        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:completionVC];
        navCon.canDragBack = YES;
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = navCon;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    } else {
        [SVProgressHUD showErrorWithStatus2:@"清空已选商品!" touchEventHandle:^{}];
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
        commodityArray = [_commoditySearchArray mutableCopy];
        [_tableView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        commodityArray = [NSMutableArray arrayWithArray: _commodityOrigArray];
        [_tableView reloadData];
    }
}

- (void)initSearchArrayByText:(NSString *)text
{
    if(!_commoditySearchArray)
        _commoditySearchArray = [NSMutableArray array];
    else
        [_commoditySearchArray removeAllObjects];
    NSString *condition = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (CommodityDoc *commDoc in _commodityOrigArray) {
        if ([commDoc.comm_CommoditySearchField containsString:condition])
            [_commoditySearchArray addObject:commDoc];
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
    return [commodityArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ProductListCell";
    PSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[PSListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
    }
    CommodityDoc *com = [commodityArray objectAtIndex:indexPath.row];

    CGRect frame = cell.titleLabel.frame;
    CGSize size = [[NSString stringWithFormat:@"%@  %@", com.comm_CommodityName, com.comm_Specification] sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 40.0f)];
    if (size.height > 20) {
        frame.size.height = 40.0f;
        cell.titleLabel.frame = frame;
        cell.titleLabel.numberOfLines = 0;
    } else {
        frame.size.height = 20.0f;
        cell.titleLabel.frame = frame;
        cell.titleLabel.numberOfLines = 1;
    }
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:com.comm_ImgURL] placeholderImage:[UIImage imageNamed:@"GoodsImg"]];
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@  %@", com.comm_CommodityName, com.comm_Specification]];
    [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_UnitPrice]];
    // 没有set方法，是因为IOS8 下 [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_CalculatePrice] 转化不了。
    switch (com.comm_MarketingPolicy) {
        case 0:
            com.comm_CalculatePrice = com.comm_UnitPrice;
            break;
        case 1:
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CustomerDoc *cus_Selected = [appDelegate customer_Selected];
            com.comm_CalculatePrice = cus_Selected ? com.comm_PromotionPrice: com.comm_UnitPrice;
            
            break;
        }
        case 2:
            com.comm_CalculatePrice = com.comm_PromotionPrice;
            
            break;
            
        default:
            break;
    }
    [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_CalculatePrice]];
    [cell.newbrandImgView setHidden:!com.comm_NewBrand];
    [cell.recommendImgView setHidden:!com.comm_Recommended];
    [cell.favoriteImageView setHidden:!com.comm_FavouriteID];
    
    [cell setDelegate:self];
    [cell.unitePriceLabel setIsShowMidLine:YES];

    cell.unitePriceLabel.hidden = com.comm_UnitPrice == com.comm_CalculatePrice;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    if (com.comm_MarketingPolicy == 0 ||(com.comm_MarketingPolicy == 1 && customerId == 0) || (com.comm_UnitPrice == com.comm_CalculatePrice)) {
        cell.unitePriceLabel.hidden = YES;
        cell.priceCategoryImageView.hidden = YES;
        cell.promotionPriceLabel.frame = CGRectMake(70.0f, 45.0f, 120.0f, 20.0f);
        [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_CalculatePrice]];

    } else if (com.comm_MarketingPolicy == 1 && customerId != 0) {
        cell.unitePriceLabel.hidden = NO;
        cell.priceCategoryImageView.hidden = NO;
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
        cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];
        CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120.0f, 20.0f)]; // 95.0f, 45.0f, size.width + 2, 20.0f
        cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常" 95.f + size.width + 10, 46.f, 80.f, 20.f
        [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
    } else if (com.comm_MarketingPolicy == 2) {
        cell.unitePriceLabel.hidden = NO;
        cell.priceCategoryImageView.hidden = NO;
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
        cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
        CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120.0f, 20.0f)];
        cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
        [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
    }
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_Code == %d", com.comm_Code];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", com.comm_ID];
//    NSArray *array = [self.commodity_SelectedArray filteredArrayUsingPredicate:predicate];
    NSArray *array = [self.tmp_Commodity filteredArrayUsingPredicate:predicate];
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
//    if(!_searchBar.isHidden)
//        [self searchAction];
    [self.searchBar resignFirstResponder];
    if ( commodityArray.count == 0 || indexPath.row >= commodityArray.count ) {
        [tableView reloadData];
        return;
    }
    CommodityDoc *comm = [commodityArray objectAtIndex:indexPath.row];
    ProductDetailViewController *productDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
    productDetailVC.commodityCode = comm.comm_Code;
    productDetailVC.favouriteID = comm.comm_FavouriteID;
    [self.navigationController pushViewController:productDetailVC animated:YES];
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
    CommodityDoc *commodityDoc = [commodityArray objectAtIndex:indexPath.row];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", commodityDoc.comm_ID];     //2014.9.9
    NSArray *array = [self.tmp_Commodity filteredArrayUsingPredicate:predicate];
    if ([array count] > 0) {
        [self.tmp_Commodity removeObject:[array objectAtIndex:0]];
    } else {
        [self.tmp_Commodity addObject:commodityDoc];
    }
    [_tableView reloadData];
}

#pragma mark - 接口

- (void)request
{
    if (categoryDoc.CategoryID == 0 )
        [self requstProductListByCompanyID];
    else
        [self requstProductListByCategoryID:categoryDoc.CategoryID];
}

- (void)requstProductListByCompanyID
{
    
    [SVProgressHUD showWithStatus:@"Loading"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;

//    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerID];
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}",(long)customerID];

    _requestGetListByCompanyIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Commodity/getCommodityListByCompanyID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        self.view.userInteractionEnabled = NO;
        if (commodityArray) {
            [commodityArray removeAllObjects];
        } else {
            commodityArray = [NSMutableArray array];
        }
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [data  enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CommodityDoc *commodityDoc = [[CommodityDoc alloc] initWithSpecialDictionary:obj];
                [commodityDoc setCustomer_ID:customerID];
                
                [commodityArray addObject:commodityDoc];
            }];
            commodity_SelectedArray = [(AppDelegate *) [[UIApplication sharedApplication] delegate] commodityArray_Selected];
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:1];
            _commodityOrigArray = commodityArray;
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
            self.view.userInteractionEnabled = YES;
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requstProductListByCategoryID:(NSInteger)categoryID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerID = appDelegate.customer_Selected.cus_ID;
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld,\"CategoryID\":%ld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerID, (long)categoryID];

    _requestGetListByCategoryIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Commodity/getCommodityListByCategoryID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        self.view.userInteractionEnabled = NO;
        if (commodityArray) {
            [commodityArray removeAllObjects];
        } else {
            commodityArray = [NSMutableArray array];
        }
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CommodityDoc *commodityDoc = [[CommodityDoc alloc] initWithSpecialDictionary:obj];
                [commodityDoc setCustomer_ID:customerID];
                [commodityArray addObject:commodityDoc];
            }];
            
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:1];
            _commodityOrigArray = commodityArray;
            [_tableView reloadData];
            self.view.userInteractionEnabled = YES;

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
            self.view.userInteractionEnabled = YES;
        }];
    } failure:^(NSError *error) {
    }];
}

@end
