//
//  ServiceListViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ServiceListViewController.h"
#import "UIImageView+WebCache.h"
#import "ServiceDetailViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"
#import "CategoryDoc.h"
#import "UILabelStrikeThrough.h"
#import "NSString+Additional.h"
#import "ServiceObject.h"

@interface ServiceListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getBalanceOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getCommodityListOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *addCommodityToCartOperation;
@property (strong, nonatomic) NSMutableArray *theServiceArray;
@property (strong, nonatomic) NSMutableArray *serviceOrigArray;
@property (strong, nonatomic) NSMutableArray *serviceSearchArray;
@property (assign, nonatomic) long long serviceCode_Selected;
@property (assign, nonatomic) CGFloat serviceDiscount_Selected;
@property (strong, nonatomic) TitleView *titleView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) NSInteger isSearching;
@property (assign, nonatomic) CGFloat initialTVHeight;
@end

@implementation ServiceListViewController
@synthesize parentCategory;
@synthesize serviceCode_Selected;

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    _searchBar.frame = CGRectMake(5, 5, kSCREN_BOUNDS.size.width - 10, 44.0f);
    _searchBar.tintColor = kDefaultBackgroundColor;
    _searchBar.placeholder = @"来搜索你想要找的服务吧!";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor clearColor];
    [_searchBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [obj removeFromSuperview];
        }
    }];
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width - 10, 44)];
    searchView.backgroundColor = kColor_SearchBarTint;
    [_searchBar insertSubview:searchView atIndex:1];
    
    [self.view addSubview:_searchBar];
    
  
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake( 0, 44 + 10, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 44);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchBar setText:@""];
    
    if (parentCategory.category_ID == 0) {
        [self requestGetAllCategoryList];
    } else {
        [self requestGetCategoryListByParentId:parentCategory.category_ID];
    }
    self.title = parentCategory.category_CategoryName;

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getBalanceOperation || [_getBalanceOperation isExecuting]) {
        [_getBalanceOperation cancel];
        [self setGetBalanceOperation:nil];
    }
    
    if (_getCommodityListOperation || [_getCommodityListOperation isExecuting]) {
        [_getCommodityListOperation cancel];
        [self setGetCommodityListOperation:nil];
    }
    
    if (_addCommodityToCartOperation || [_addCommodityToCartOperation isExecuting]) {
        [_addCommodityToCartOperation cancel];
        [self setAddCommodityToCartOperation:nil];
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
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
        _theServiceArray = [_serviceSearchArray mutableCopy];
        [_tableView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        _theServiceArray = [NSMutableArray arrayWithArray: _serviceOrigArray];
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
    for (ServiceObject *serviceDoc in _serviceOrigArray) {
        if ([serviceDoc.product_searchField  containsString:condition])
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
#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_theServiceArray count];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"productCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    UIImageView *proImgView = (UIImageView *)[cell viewWithTag:100];
    UILabel *proNameLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *promotionPriceLabel  = (UILabel *)[cell viewWithTag:106];
    ServiceObject *serviceObject = [_theServiceArray objectAtIndex:indexPath.section];
    [proImgView setImageWithURL:[NSURL URLWithString:serviceObject.product_thumbnail] placeholderImage:[UIImage imageNamed:@"productDefaultImage"]];
    
    proNameLabel.font = kNormalFont_14;
    promotionPriceLabel.textColor = kMainLightGrayColor;
    promotionPriceLabel.font = kNormalFont_14;
    promotionPriceLabel.textColor = kColor_TitlePink;
    
    proNameLabel.text = [NSString stringWithFormat:@"%@", serviceObject.product_name];
    proNameLabel.numberOfLines = 2;

    
    [promotionPriceLabel setText:[NSString stringWithFormat:@"%@ %@",CUS_CURRENCYTOKEN, serviceObject.product_originalPriceStr]];
    
    return cell;
}


#pragma mark -  UITabelViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ServiceObject *serviceObject = [_theServiceArray objectAtIndex:indexPath.section];
    serviceCode_Selected = serviceObject.product_code;
    _serviceDiscount_Selected = serviceObject.product_discountPrice;
    [self performSegueWithIdentifier:@"gotoServiceDetailFromServiceList" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoServiceDetailFromServiceList"]) {
        ServiceDetailViewController *detailProductController = segue.destinationViewController;
        detailProductController.commodityCode = serviceCode_Selected;
        detailProductController.commodityDiscount = _serviceDiscount_Selected;
    }
}

#pragma mark - 接口
- (void)requestGetAllCategoryList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{
                           @"ImageWidth":@80,
                           @"ImageHeight":@80,
                           @"isShowAll":@0};
    _getCommodityListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Service/GetServiceListByCompanyID"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        _tableView.userInteractionEnabled = NO;
        if (!_theServiceArray) {
            _theServiceArray = [NSMutableArray array];
        }else
            [_theServiceArray removeAllObjects];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"product_ID":@"ProductID",
                                   @"product_code":@"ProductCode",
                                   @"product_name":@"ProductName",
                                   @"product_searchField":@"SearchField",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",
                                   @"product_discountPrice":@"PromotionPrice",
                                   @"product_thumbnail":@"ThumbnailURL"};
            
             if (![[data objectForKey:@"ProductList"] isKindOfClass:[NSNull class]]) {
                [[data objectForKey:@"ProductList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ServiceObject *serviceObject = [[ServiceObject alloc] init];
                    [serviceObject assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                    [serviceObject valuationProductSalesPrice];
                    [_theServiceArray addObject:serviceObject];
                }];
            }
            _serviceOrigArray = _theServiceArray;
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [_tableView reloadData];
        
        _tableView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestGetCategoryListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"CategoryID":@(parentId),
                           @"ImageWidth":@160,
                           @"ImageHeight":@160,
                           @"isShowAll":@0};
    _getCommodityListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Service/getServiceListByCategoryID"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        _tableView.userInteractionEnabled = NO;

        if (!_theServiceArray) {
            _theServiceArray = [NSMutableArray array];
        }else
            [_theServiceArray removeAllObjects];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"product_ID":@"ProductID",
                                   @"product_code":@"ProductCode",
                                   @"product_name":@"ProductName",
                                   @"product_searchField":@"SearchField",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",
                                   @"product_discountPrice":@"PromotionPrice",
                                   @"product_thumbnail":@"ThumbnailURL"};
              if (![[data objectForKey:@"ProductList"] isKindOfClass:[NSNull class]]) {
                [[data objectForKey:@"ProductList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ServiceObject *serviceObject = [[ServiceObject alloc] init];
                    [serviceObject assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                    [serviceObject valuationProductSalesPrice];
                    [_theServiceArray addObject:serviceObject];
                }];
             }
            _serviceOrigArray = _theServiceArray;
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
        _tableView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];
}

@end
