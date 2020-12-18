//
//  ServiceTowViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-6-19.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ServiceTowViewController.h"
#import "ServiceOneViewController.h"
#import "ServiceListViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "CategoryDoc.h"
#import "UIButton+InitButton.h"
#import "GDataXMLDocument+ParseXML.h"
@interface ServiceTowViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestServiceListByCompanyIdOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestServiceListByParentIdOperation;
@property (nonatomic) NSMutableArray *theServiceArray;
@property (strong, nonatomic) TitleView *titleView;
@end

@implementation ServiceTowViewController
@synthesize parentCategory;
@synthesize theServiceArray;
@synthesize serviceName;
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
    NSLog(@"parentCategory-Two--%@",parentCategory);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20);
    _tableView.separatorColor = kTableView_LineColor;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = serviceName;
    [self requestGetServiceListByParentId:parentCategory.category_ID];
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
        titleLabel.text = [NSString stringWithFormat:@"%@", parentCategory.category_CategoryName];
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


#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;

    if (indexPath.row == 0)
    {
        ServiceListViewController *productDetailListController = (ServiceListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
        productDetailListController.parentCategory = parentCategory;
        [self.navigationController pushViewController:productDetailListController animated:YES];
    }
    else
    {
        CategoryDoc *categoryDoc = [theServiceArray objectAtIndex:indexPath.row - 1];
        if (categoryDoc.category_Flag == 0)  // 进入
        {
            ServiceListViewController *productDetailListController = (ServiceListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
            productDetailListController.parentCategory = categoryDoc;
            [self.navigationController pushViewController:productDetailListController animated:YES];
        }
        else
        {
            ServiceOneViewController *productOneListController = (ServiceOneViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceOneViewController"];
            productOneListController.parentCategory = categoryDoc;
            productOneListController.serviceName =categoryDoc.category_CategoryName;
            [self.navigationController pushViewController:productOneListController animated:YES];
            
        }
    }
}


#pragma mark - 接口

- (void)requestGetServiceListByParentId:(NSInteger)parentId
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{
                           @"CategoryID":@(parentId),
                           @"Type":@0
                           };
    _requestServiceListByParentIdOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Category/GetCategoryList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        NSMutableArray *temp = [NSMutableArray array];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSDictionary *dict = @{@"category_ID":@"CategoryID",
                                   @"category_CategoryName":@"CategoryName",
                                   @"category_Count":@"ProductCount",
                                   @"category_Flag":@"NextCategoryCount"};
            
            if (![[data objectForKey:@"CategoryList"] isKindOfClass:[NSNull class]]) {
                [[data objectForKey:@"CategoryList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    CategoryDoc *categoryDoc = [[CategoryDoc alloc] init];
                    [categoryDoc assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                    [temp addObject:categoryDoc];
                }];
            }
            theServiceArray = temp;
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) { }];
        
    } failure:^(NSError *error) {

    }];

}


@end
