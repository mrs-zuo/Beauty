//
//  ProductListViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "PCategoryOneViewController.h"
#import "PCategoryTwoViewController.h"
#import "ProductListViewController.h"
#import "CategoryDoc.h"

#import "CategoryTableCell.h"

#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "UIButton+InitButton.h"
#import "GPBHTTPClient.h"

@interface PCategoryOneViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByCompanyIDOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByCategoryIDOperation;

@property (strong, nonatomic) NSMutableArray *categoryArray;
@end

@implementation PCategoryOneViewController
@synthesize parentCategory;
@synthesize categoryArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"商品类目"];
    [self.view addSubview:navigationView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 310.0f, kSCREN_BOUNDS.size.height  - 64.0f - HEIGHT_NAVIGATION_VIEW - 5.0f - 5.0f) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (parentCategory.CategoryID == 0) {
        [self requestGetCategoryListByCompanyId];
    } else {
        [self requestGetCategoryListByParentId:parentCategory.CategoryID];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestCategoryListByCategoryIDOperation && [_requestCategoryListByCategoryIDOperation isExecuting]) {
        [_requestCategoryListByCategoryIDOperation cancel];
    }
    
    if (_requestCategoryListByCompanyIDOperation && [_requestCategoryListByCompanyIDOperation isExecuting]) {
        [_requestCategoryListByCompanyIDOperation cancel];
        
    }
    _requestCategoryListByCategoryIDOperation = nil;
    _requestCategoryListByCompanyIDOperation = nil;
    
    //if ([SVProgressHUD isVisible]) {
    //    [SVProgressHUD dismiss];
    //}
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
    return [categoryArray count] == 0 ? 1 : [categoryArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIndentify = @"parentNodeCell";
        CategoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[CategoryTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        }
        cell.imageView.image = [UIImage imageNamed:@"parentNode_bg"];
        cell.imageView.frame = CGRectMake(5.0f, (kTableView_HeightOfRow - 10.0f)/2, 10.0f, 10.0f);
        cell.nameLabel.frame = CGRectMake(CGRectGetMinX(cell.imageView.frame) + CGRectGetWidth(cell.imageView.bounds) + 5.0f, 0.0f, 180.0f, kTableView_HeightOfRow);
        
        UIImageView *accessoryImgView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0f, (kTableView_HeightOfRow - 12.0f)/2, 10.0f, 12.0f)];
        accessoryImgView.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:accessoryImgView];
        
        [cell updateData:parentCategory];
        return cell;
    } else {
        static NSString *cellIndentify = @"childNodeCell";
        CategoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[CategoryTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        }
        CategoryDoc *categoryDoc = [categoryArray objectAtIndex:indexPath.row - 1];
        [cell updateData:categoryDoc];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
            ProductListViewController *productListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
            productListVC.categoryDoc = parentCategory;
            [self.navigationController pushViewController:productListVC animated:YES];
    } else {
        CategoryDoc *categoryDoc = [categoryArray objectAtIndex:indexPath.row - 1];
        if (categoryDoc.NextCategoryCount == 0)
        {
                ProductListViewController *productListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
                productListVC.categoryDoc = categoryDoc;
                [self.navigationController pushViewController:productListVC animated:YES];
        } else {
            PCategoryTwoViewController *categoryTwoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PCategoryTwoViewController"];
            categoryTwoVC.parentCategory = categoryDoc;
            [self.navigationController pushViewController:categoryTwoVC animated:YES];
        }
    }
    
}

#pragma mark - 接口

- (void)requestGetCategoryListByCompanyId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"Type\":%d,\"AccountID\":%ld,\"BranchID\":%ld}", (long)ACC_COMPANTID, 1, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];

    _requestCategoryListByCompanyIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Category/getCategoryListByCompanyID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (!categoryArray) {
            categoryArray = [NSMutableArray array];
        } else {
            [categoryArray removeAllObjects];
        }
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.CategoryName = @"全部";
        }
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
//            NSArray *categList = [data objectForKey:@"CategoryList"];
//            parentCategory.ProductCount = [[data objectForKey:@"ProductCount"] intValue];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [categoryArray addObject:[[CategoryDoc alloc] initWithDictionary:obj]];
            }];
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    /*
    _requestCategoryListByCompanyIDOperation = [[GPHTTPClient shareClient] requestGetCategoryListByCompanyIdAndBranchIdWithType:1 Success:^(id xml) {
        [SVProgressHUD dismiss];
        if (!categoryArray) {
            categoryArray = [NSMutableArray array];
        } else {
            [categoryArray removeAllObjects];
        }
        
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.category_CategoryName = @"全部";
        }
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            parentCategory.category_Count = [[[[contentData elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue];
            for (GDataXMLElement *data in [contentData elementsForName:@"Category"]) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc setCategory_ID:[[[[data elementsForName:@"CategoryID"] objectAtIndex:0] stringValue] integerValue]];
                [categoryDoc setCategory_CategoryName:[[[data elementsForName:@"CategoryName"] objectAtIndex:0] stringValue]];
                [categoryDoc setCategory_Count:[[[[data elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryDoc setCategory_Flag:[[[[data elementsForName:@"NextCategoryCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryArray addObject:categoryDoc];
            }
            [_tableView reloadData];
            
        } failure:^{
            [_tableView reloadData];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

- (void)requestGetCategoryListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CategoryID\":%ld,\"Type\":%d,\"AccountID\":%ld,\"BranchID\":%ld}", (long)parentId, 1, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];

    
    _requestCategoryListByCompanyIDOperation = [CategoryDoc requestGetCategoryListByParentId:par completionBlock:^(NSArray *array, int count, NSString *mesg, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (error == nil) {
            if (!categoryArray) {
                categoryArray = [NSMutableArray array];
            } else {
                [categoryArray removeAllObjects];
            }
            
            if (!parentCategory) {
                parentCategory = [[CategoryDoc alloc] init];
                parentCategory.CategoryName = @"全部";
            }
            if (array) {
                [categoryArray addObjectsFromArray:array];
                parentCategory.ProductCount = count;
                [_tableView reloadData];
            } else {
                [_tableView reloadData];
            }
        } else {
            [SVProgressHUD dismiss];
        }
    }];
/*
    _requestCategoryListByCompanyIDOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Category/getCategoryListByCategoryID" andParameters:par WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (!categoryArray) {
            categoryArray = [NSMutableArray array];
        } else {
            [categoryArray removeAllObjects];
        }
        
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.CategoryName = @"全部";
        }
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *categList = [data objectForKey:@"CategoryList"];
            parentCategory.ProductCount = [[data objectForKey:@"ProductCount"] intValue];
            [categList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [categoryArray addObject:[[CategoryDoc alloc] initWithDictionary:obj]];
            }];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
    
    
    
    */
    
    
    /*
    _requestCategoryListByCompanyIDOperation = [[GPHTTPClient shareClient] requestGetCategoryListByCategoryId:parentId type:1 success:^(id xml) {
        [SVProgressHUD dismiss];
        if (!categoryArray) {
            categoryArray = [NSMutableArray array];
        } else {
            [categoryArray removeAllObjects];
        }
        
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.category_CategoryName = @"全部";
        }
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            parentCategory.category_Count = [[[[contentData elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue];
            for (GDataXMLElement *data in [contentData elementsForName:@"Category"]) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc setCategory_ID:[[[[data elementsForName:@"CategoryID"] objectAtIndex:0] stringValue] integerValue]];
                [categoryDoc setCategory_CategoryName:[[[data elementsForName:@"CategoryName"] objectAtIndex:0] stringValue]];
                [categoryDoc setCategory_Count:[[[[data elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryDoc setCategory_Flag:[[[[data elementsForName:@"NextCategoryCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryArray addObject:categoryDoc];
            }
            [_tableView reloadData];
            
        } failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

@end
