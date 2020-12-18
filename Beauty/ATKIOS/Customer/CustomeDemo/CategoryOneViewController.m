//
//  ProductListViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CategoryOneViewController.h"
#import "CategoryTwoViewController.h"
#import "CommodityListViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CategoryDoc.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIButton+InitButton.h"

@interface CategoryOneViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByCompanyIdOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByParentIdOperation;
@property (nonatomic) NSMutableArray *theCategoryArray;
@property (strong, nonatomic) TitleView *titleView;

@end

@implementation CategoryOneViewController
@synthesize parentCategory;
@synthesize theCategoryArray;
@synthesize categoryName;
@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kDefaultBackgroundColor;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestCategoryListByCompanyIdOperation && [_requestCategoryListByCompanyIdOperation isExecuting]) {
        [_requestCategoryListByCompanyIdOperation cancel];
        [self setRequestCategoryListByCompanyIdOperation:nil];
    }
    
    if (_requestCategoryListByParentIdOperation && [_requestCategoryListByParentIdOperation isExecuting]) {
        [_requestCategoryListByParentIdOperation cancel];
        [self setRequestCategoryListByParentIdOperation:nil];
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)setParentCategory:(CategoryDoc *)_parentCategory
{
    parentCategory = _parentCategory;
}
- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (categoryName == nil) {
        self.title = @"商品类目";
    } else {
        self.title = categoryName;
    }
    
    if (parentCategory.category_ID == 0) {
        [self requestGetCategoryListByCompanyId];
    }
}

#pragma mark -  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [theCategoryArray count] + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_DefaultCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIndentify = @"productFirstCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
        cell.backgroundColor = kColor_White;
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
        titleLabel.text = parentCategory.category_CategoryName;
        titleLabel.font = kNormalFont_14;
        return cell;
    } else {
        static NSString *cellIndentify = @"productNormalCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
        cell.backgroundColor = kColor_White;
        CategoryDoc *categoryDoc = [theCategoryArray objectAtIndex:indexPath.row - 1];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
        titleLabel.text = [NSString stringWithFormat:@"%@", categoryDoc.category_CategoryName];
        titleLabel.font = kNormalFont_14;
        return cell;
    }
}

#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    if (indexPath.row == 0)
    {
        CommodityListViewController *productDetailListController = (CommodityListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommodityListViewController"];
        productDetailListController.parentCategory = parentCategory;
        [self.navigationController pushViewController:productDetailListController animated:YES];
    }
    else
    {
        CategoryDoc *categoryDoc = [theCategoryArray objectAtIndex:indexPath.row - 1];
        if (categoryDoc.category_Flag == 0)  // 进入
        {
            CommodityListViewController *productDetailListController = (CommodityListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommodityListViewController"];
            productDetailListController.parentCategory = categoryDoc;
            [self.navigationController pushViewController:productDetailListController animated:YES];
        }
        else
        {
            CategoryTwoViewController *productTwoListController = (CategoryTwoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CategoryTwoViewController"];
            productTwoListController.parentCategory = categoryDoc;
            productTwoListController.categoryName =categoryDoc.category_CategoryName;
            [self.navigationController pushViewController:productTwoListController animated:YES];
            
        }
    }
}

#pragma mark - 接口
- (void)requestGetCategoryListByCompanyId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"Type":@1};
    _requestCategoryListByCompanyIdOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Category/GetCategoryList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        _tableView.userInteractionEnabled = NO;
        if (!theCategoryArray) {
            theCategoryArray = [NSMutableArray array];
        } else {
            [theCategoryArray removeAllObjects];
        }
        
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.category_CategoryName = @"全部商品";
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"category_ID":@"CategoryID",
                                   @"category_CategoryName":@"CategoryName",
                                   @"category_Flag":@"NextCategoryCount"};
            [[data objectForKey:@"CategoryList"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [theCategoryArray addObject:categoryDoc];
            }];
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
    NSDictionary *para = @{
                           @"CategoryID":@(parentId),
                           @"Type":@1};
    
    _requestCategoryListByCompanyIdOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Category/GetCategoryList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        _tableView.userInteractionEnabled = NO;
        if (!theCategoryArray) {
            theCategoryArray = [NSMutableArray array];
        } else {
            [theCategoryArray removeAllObjects];
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSDictionary *dict = @{@"category_ID":@"CategoryID",
                                   @"category_CategoryName":@"CategoryName",
                                   @"category_Count":@"ProductCount",
                                   @"category_Flag":@"NextCategoryCount"};
            
            [[data objectForKey:@"CategoryList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [theCategoryArray addObject:categoryDoc];
            }];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [_tableView reloadData];
        _tableView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        
    }];

}

@end
