//
//  ServiceOneViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-19.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ServiceOneViewController.h"
#import "ServiceListViewController.h"
#import "ServiceTowViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CategoryDoc.h"
#import "GDataXMLDocument+ParseXML.h"
#import "UIButton+InitButton.h"

@interface ServiceOneViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestServiceListByCompanyIdOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestServiceListByParentIdOperation;
@property (nonatomic, strong) TitleView *titleView;
@property (nonatomic) NSMutableArray *theServiceArray;
@end

@implementation ServiceOneViewController
@synthesize titleView;
@synthesize serviceName;
@synthesize theServiceArray;
@synthesize parentCategory;

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
    
    if (_requestServiceListByCompanyIdOperation && [_requestServiceListByCompanyIdOperation isExecuting]) {
        [_requestServiceListByCompanyIdOperation cancel];
        [self setRequestServiceListByCompanyIdOperation:nil];
    }
    
    if (_requestServiceListByParentIdOperation && [_requestServiceListByParentIdOperation isExecuting]) {
        [_requestServiceListByParentIdOperation cancel];
        [self setRequestServiceListByParentIdOperation:nil];
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShowButton = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20);

}

- (void)setParentCategory:(CategoryDoc *)_parentCategory
{
    parentCategory = _parentCategory;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (serviceName == nil) {
        self.title = @"服务类目";
    } else {
        self.title = serviceName;
    }
    if (parentCategory.category_ID == 0) {
        [self requestGetServiceListByCompanyId];
    }
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [theServiceArray count] + 1;
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
        titleLabel.text =  parentCategory.category_CategoryName;
        titleLabel.font = kNormalFont_14;
        return cell;
    } else {
        static NSString *cellIndentify = @"productNormalCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify forIndexPath:indexPath];
        cell.backgroundColor = kColor_White;
        CategoryDoc *categoryDoc = [theServiceArray objectAtIndex:indexPath.row - 1];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
        titleLabel.text = [NSString stringWithFormat:@"%@", categoryDoc.category_CategoryName];
        titleLabel.font = kNormalFont_14;
        return cell;
    }
    
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;

    if (indexPath.row == 0) {
        ServiceListViewController   *serviceList = (ServiceListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
        serviceList.parentCategory = parentCategory;
        [self.navigationController pushViewController:serviceList animated:YES];
    } else {
        CategoryDoc *categoryDoc = [theServiceArray objectAtIndex:indexPath.row - 1];
        if (categoryDoc.category_Flag == 0) {
            ServiceListViewController   *serviceList = (ServiceListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
            serviceList.parentCategory = categoryDoc;
            [self.navigationController pushViewController:serviceList animated:YES];
        } else {
            ServiceTowViewController    *serviceTwo = (ServiceTowViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceTowViewController"];
            serviceTwo.parentCategory = categoryDoc;
            serviceTwo.serviceName = categoryDoc.category_CategoryName;
            [self.navigationController pushViewController:serviceTwo animated:YES];
        }
    }
}

#pragma  mark - 接口
- (void)requestGetServiceListByCompanyId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{
                           @"Type":@0};
    _requestServiceListByCompanyIdOperation = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Category/GetCategoryList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        NSMutableArray *temp = [NSMutableArray array];
        
        if (!parentCategory) {
            parentCategory = [[CategoryDoc alloc] init];
            parentCategory.category_CategoryName = @"全部服务";
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"category_ID":@"CategoryID",
                                   @"category_CategoryName":@"CategoryName",
                                   @"category_Flag":@"NextCategoryCount"};
            [[data objectForKey:@"CategoryList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [temp addObject:categoryDoc];
            }];
            theServiceArray = temp;
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {}];
        
    } failure:^(NSError *error) {

    }];

    
}

- (void)requestGetServiceListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *dict = @{ @"CategoryID":@(parentId),
                            @"Type":@0};
    _requestServiceListByParentIdOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Category/GetCategoryList"  showErrorMsg:YES  parameters:dict WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *temp = [NSMutableArray array];
            NSDictionary *dict = @{@"category_ID":@"CategoryID",
                                   @"category_CategoryName":@"CategoryName",
                                   @"category_Count":@"ProductCount",
                                   @"category_Flag":@"NextCategoryCount"};
            
            [[data objectForKey:@"CategoryList"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                [categoryDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [temp addObject:categoryDoc];
            }];
            theServiceArray = temp;
            [_tableView reloadData];
            [SVProgressHUD dismiss];

        } failure:^(NSInteger code, NSString *error) {}];
    } failure:^(NSError *error) {

    }];
}
@end
