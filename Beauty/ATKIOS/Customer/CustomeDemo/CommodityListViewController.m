//
//  ProductLastListController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CommodityListViewController.h"
#import "UIImageView+WebCache.h"
#import "CommodityDetailViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"
#import "CategoryDoc.h"
#import "UILabelStrikeThrough.h"
#import "CommodityObject.h"
#import "NSString+Additional.h"

@interface CommodityListViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getBalanceOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *getCommodityListOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *addCommodityToCartOperation;
@property (strong, nonatomic) NSMutableArray *theCommodityArray;
@property (strong, nonatomic) NSMutableArray *commoditySearchArray;
@property (strong, nonatomic) NSMutableArray *commodityOrigArray;
@property (assign, nonatomic) long long commodityCode_Selected;
@property (strong, nonatomic) TitleView *titleView;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) CGFloat commodityDiscount_Selected;
@property (assign, nonatomic) CGFloat initialTVHeight;
@end

@implementation CommodityListViewController
@synthesize parentCategory;
@synthesize commodityCode_Selected;

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
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    _searchBar.frame = CGRectMake(5,5, kSCREN_BOUNDS.size.width - 10, 44.0f);
    _searchBar.tintColor = kDefaultBackgroundColor;
    _searchBar.placeholder = @"来搜索你想要找的商品吧!";
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

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(5.0f,44 + 10, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height -kNavigationBar_Height - 44);
   
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
        _theCommodityArray = [_commoditySearchArray mutableCopy];
        [_tableView reloadData];
    } else {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        [self setIsSearching:NO];
        _theCommodityArray = [NSMutableArray arrayWithArray: _commodityOrigArray];
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
    for (CommodityObject *commDoc in _commodityOrigArray) {
        if ([commDoc.product_searchField  containsString:condition])
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_searchBar resignFirstResponder];
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
    return [_theCommodityArray count];
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
    CommodityObject *commodityObject = [_theCommodityArray objectAtIndex:indexPath.section];
    [proImgView setImageWithURL:[NSURL URLWithString:commodityObject.product_thumbnail] placeholderImage:[UIImage imageNamed:@"productDefaultImage"]];
    
    proNameLabel.font = kNormalFont_14;
    promotionPriceLabel.textColor = kMainLightGrayColor;
    promotionPriceLabel.font = kNormalFont_14;
    promotionPriceLabel.textColor = kColor_TitlePink;
    
    NSString *strSpecification = [NSString stringWithFormat:@"%@", commodityObject.commodity_specification];
    if ([strSpecification isEqual:@""] || [strSpecification isKindOfClass:[NSNull class]]||[strSpecification isEqual:@"(null)"]) {
        proNameLabel.text = [NSString stringWithFormat:@"%@", commodityObject.product_name];
    } else {
        proNameLabel.text = [NSString stringWithFormat:@"%@ %@", commodityObject.product_name, strSpecification];
    }
    proNameLabel.numberOfLines = 2;
    [promotionPriceLabel setText:[NSString stringWithFormat:@"%@ %@",CUS_CURRENCYTOKEN, commodityObject.product_originalPriceStr]];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CommodityObject *commodityObject = [_theCommodityArray objectAtIndex:indexPath.section];
    commodityCode_Selected = commodityObject.product_code;
    _commodityDiscount_Selected = commodityObject.product_discountPrice;
    [self performSegueWithIdentifier:@"gotoCommodityDetailViewFromCommodityListView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoCommodityDetailViewFromCommodityListView"]) {
        CommodityDetailViewController *detailProductController = segue.destinationViewController;
        detailProductController.commodityCode = commodityCode_Selected;
        detailProductController.commodityDiscount = _commodityDiscount_Selected;
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

    _getCommodityListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Commodity/GetCommodityListByCompanyID"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *temp = [NSMutableArray array];
            NSDictionary *dict = @{@"product_code":@"ProductCode",
                                   @"product_ID":@"ProductID",
                                   @"product_name":@"ProductName",
                                   @"product_searchField":@"SearchField",
                                   @"commodity_stockQuantity":@"StockQuantity",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",
                                   @"product_discountPrice":@"PromotionPrice",
                                   @"commodity_specification":@"Specification",
                                   @"product_thumbnail":@"ThumbnailURL"};
            
             if (![[data objectForKey:@"ProductList"] isKindOfClass:[NSNull class]]) {
                [[data objectForKey:@"ProductList"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    CommodityObject *commodityObject = [[CommodityObject alloc] init];
                    
                    [commodityObject assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                    [commodityObject setCommodity_salesAttribute:([obj[@"Recommended"] intValue] << 1 | [obj[@"New"] intValue] << 0)];
                    [commodityObject valuationProductSalesPrice];
                    [temp addObject:commodityObject];
                }];
            }
            _theCommodityArray = temp;
            _commodityOrigArray = _theCommodityArray;
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestGetCategoryListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];

    NSDictionary  *para = @{@"CategoryID":@(parentId),
                            @"ImageWidth":@160,
                            @"ImageHeight":@160,
                            @"isShowAll":@0};
    _getCommodityListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Commodity/GetCommodityListByCategoryID"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *temp = [NSMutableArray array];
            NSDictionary *dict = @{@"product_code":@"ProductCode",
                                   @"product_ID":@"ProductID",
                                   @"product_name":@"ProductName",
                                   @"product_searchField":@"SearchField",
                                   @"commodity_stockQuantity":@"StockQuantity",
                                   @"product_sellingWay":@"MarketingPolicy",
                                   @"product_originalPrice":@"UnitPrice",
                                   @"product_promotionPrice":@"PromotionPrice",
                                   @"product_discountPrice":@"PromotionPrice",
                                   @"commodity_specification":@"Specification",
                                   @"product_thumbnail":@"ThumbnailURL"};
            
            if (![[data objectForKey:@"ProductList"] isKindOfClass:[NSNull class]]) {
                [[data objectForKey:@"ProductList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    CommodityObject *commodityObject = [[CommodityObject alloc] init];
                    [commodityObject assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                    [commodityObject setCommodity_salesAttribute:([obj[@"Recommended"]intValue] << 1|[obj[@"New"] intValue] << 0)];
                    [commodityObject valuationProductSalesPrice];
                    [temp addObject:commodityObject];
                }];
            }
            _theCommodityArray = temp;
            _commodityOrigArray = _theCommodityArray;
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
