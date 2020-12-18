//
//  ProductListViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-4.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "SCategoryTwoViewController.h"
#import "SCategoryOneViewController.h"
#import "ServiceListViewController.h"
#import "CategoryDoc.h"

#import "CategoryTableCell.h"

#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"

#import "NavigationView.h"
#import "UIButton+InitButton.h"

@interface SCategoryTwoViewController ()<SelectServiceControllerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByCompanyIDOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCategoryListByCategoryIDOperation;

@property (strong, nonatomic) NSMutableArray *categoryArray;
@end

@implementation SCategoryTwoViewController
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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"服务类目"];
    [self.view addSubview:navigationView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - HEIGHT_NAVIGATION_VIEW - 5.0f - 5.0f) style:UITableViewStylePlain];
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
        ServiceListViewController *serviceListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
        serviceListVC.categoryDoc = parentCategory;
        serviceListVC.delegate = self;
        serviceListVC.returnViewTag = self.returnViewTag;
        [self.navigationController pushViewController:serviceListVC animated:YES];
        
    } else {
        CategoryDoc *categoryDoc = [categoryArray objectAtIndex:indexPath.row - 1];
        if (categoryDoc.NextCategoryCount == 0) {
            ServiceListViewController *serviceListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
            serviceListVC.categoryDoc = categoryDoc;
            serviceListVC.delegate = self;
            serviceListVC.returnViewTag = self.returnViewTag;
            [self.navigationController pushViewController:serviceListVC animated:YES];
        } else {
            SCategoryOneViewController *categoryOneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SCategoryOneViewController"];
            categoryOneVC.parentCategory = categoryDoc;
            [self.navigationController pushViewController:categoryOneVC animated:YES];
        }
    }
    
}

#pragma mark - 接口

- (void)requestGetCategoryListByCompanyId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"Type\":%d,\"AccountID\":%ld,\"BranchID\":%ld}", (long)ACC_COMPANTID, 0, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    
    _requestCategoryListByCompanyIDOperation = [CategoryDoc requestGetCategoryListByCompanyIdAndBranchIdWithType:par completionBlock:^(NSArray *array, int count, NSString *mesg, NSError *error) {
        if (error == nil) {
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
    _requestCategoryListByCompanyIDOperation = [[GPHTTPClient shareClient] requestGetCategoryListByCompanyIdAndBranchIdWithType:0 Success:^(id xml) {
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
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            parentCategory.ProductCount = [[[[contentData elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue];
            for (GDataXMLElement *data in [contentData elementsForName:@"Category"]) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc setCategoryID:[[[[data elementsForName:@"CategoryID"] objectAtIndex:0] stringValue] integerValue]];
                [categoryDoc setCategoryName:[[[data elementsForName:@"CategoryName"] objectAtIndex:0] stringValue]];
                [categoryDoc setProductCount:[[[[data elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryDoc setNextCategoryCount:[[[[data elementsForName:@"NextCategoryCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryArray addObject:categoryDoc];
            }
            
        } failure:^{}];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

- (void)requestGetCategoryListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CategoryID\":%ld,\"Type\":%d,\"AccountID\":%ld,\"BranchID\":%ld}", (long)parentId, 0, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    
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
    _requestCategoryListByCompanyIDOperation = [[GPHTTPClient shareClient] requestGetCategoryListByCategoryId:parentId type:0 success:^(id xml) {
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
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            parentCategory.ProductCount = [[[[contentData elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue];
            for (GDataXMLElement *data in [contentData elementsForName:@"Category"]) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc setCategoryID:[[[[data elementsForName:@"CategoryID"] objectAtIndex:0] stringValue] integerValue]];
                [categoryDoc setCategoryName:[[[data elementsForName:@"CategoryName"] objectAtIndex:0] stringValue]];
                [categoryDoc setProductCount:[[[[data elementsForName:@"ProductCount"] objectAtIndex:0] stringValue] intValue]];
                [categoryDoc setNextCategoryCount:[[[[data elementsForName:@"NextCategoryCount"] objectAtIndex:0] stringValue] intValue]];
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
