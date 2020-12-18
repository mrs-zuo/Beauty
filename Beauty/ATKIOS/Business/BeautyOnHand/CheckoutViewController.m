//
//  CheckoutViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "CheckoutViewController.h"
#import "OrderPayListViewController.h"
#import "PayInfoDoc.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "TitleView.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "CustomerForPayDoc.h"
#import "NSString+Additional.h"
@interface CheckoutViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate,UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchVC;
@property (strong ,nonatomic) CustomerForPayDoc *customerForPayDoc_select;
@property (weak  , nonatomic) AFHTTPRequestOperation *getCustomerUpaidListOperation;
@property (strong ,nonatomic) NSMutableArray *paymentArray;
@property (nonatomic, strong) NSMutableArray *searchArray;
@end

@implementation CheckoutViewController
@synthesize paymentArray;

#pragma mark 搜索控制器的懒加载
-(UISearchController *)searchVC{
    if (! _searchVC) {
        _searchVC=[[UISearchController alloc]init];
    }
    return _searchVC;
}
#pragma mark 表格的懒加载
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]init];
    }
    return _tableView;
}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //重新计算起始点
    self.edgesForExtendedLayout= UIRectEdgeNone;
    
    self.searchVC = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchVC.searchResultsUpdater = self;
    self.searchVC.delegate = self;
    self.paymentArray = [[NSMutableArray alloc] init];
    self.searchArray = [[NSMutableArray alloc] init];
    
    TitleView *titleView = [[TitleView alloc] init];
    [titleView getTitleView:@"结账"];
    //titleView.transform = CGAffineTransformMakeTranslation(0, 0);
    [self.view addSubview:titleView];
    
    //设置UISearchController的显示属性，以下3个属性默认为YES
    //搜索时，背景变暗色
    self.searchVC.dimsBackgroundDuringPresentation = NO;
    //搜索时，背景变模糊
    self.searchVC.obscuresBackgroundDuringPresentation = NO;
    //隐藏导航栏
    self.searchVC.hidesNavigationBarDuringPresentation = NO;
    self.searchVC.searchBar.placeholder = @"来搜索你想要查看的顾客吧!";
    [self.searchVC.searchBar setBackgroundImage:[self backgroundImage]];
    [self.searchVC.searchBar setBackgroundColor:kColor_Background_View];
    self.tableView.tableHeaderView = self.searchVC.searchBar;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = nil;
    self.tableView.allowsSelection = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorColor = kTableView_LineColor;
    self.tableView.frame = CGRectMake(0.0f, titleView.frame.origin.y + titleView.frame.size.height, [UIScreen  mainScreen].bounds.size.width, [UIScreen  mainScreen].bounds.size.height - titleView.frame.size.height - 64.0f);
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.view.backgroundColor = kColor_Background_View;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnpaidList];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getCustomerUpaidListOperation || [_getCustomerUpaidListOperation isExecuting]) {
        [_getCustomerUpaidListOperation cancel];
        _getCustomerUpaidListOperation = nil;
    }
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UItableViewDelegate & UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchVC.isActive ) {
        return 1;
    } else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchVC.isActive ) {
        return self.searchArray.count;
    } else {
        return paymentArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (65-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    
    CustomerForPayDoc *customerForPayDoc;
    
    if (self.searchVC.isActive ) {
        customerForPayDoc = [self.searchArray objectAtIndex:indexPath.row];
    } else {
        customerForPayDoc = [paymentArray objectAtIndex:indexPath.row];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:9996];
    if(!title) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 100, 20)];
        [cell addSubview:title];
    }
    title.tag = 9996;
    title.textColor = kColor_DarkBlue;
    title.font = kFont_Light_16;
    title.text = customerForPayDoc.customerName;
    
    UILabel *time = (UILabel *)[cell viewWithTag:9997];
    if(!time){
        time = [[UILabel alloc] initWithFrame:CGRectMake(155, 8, 130, 20)];
        [cell addSubview:time];
    }
    time.tag = 9997;
    time.textColor = kColor_Editable;
    time.font = kFont_Light_14;
    time.textAlignment = NSTextAlignmentRight;
    time.text = customerForPayDoc.customerPhoneNum;
    
    
    UILabel *orderCount = (UILabel *)[cell viewWithTag:9999];
    if(!orderCount){
        orderCount = [[UILabel alloc] initWithFrame:CGRectMake(155, 35, 130, 20)];
        [cell addSubview:orderCount];
    }
    orderCount.tag = 9999;
    orderCount.textColor = kColor_Black;
    orderCount.font = kFont_Light_14;
    orderCount.text = [NSString stringWithFormat:@"%ld笔待支付", (long)customerForPayDoc.unpaidCount];
    orderCount.textAlignment  = NSTextAlignmentRight;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchVC.isActive ) {
        if ( indexPath.row >= self.searchArray.count){
            [tableView reloadData];
            return;
        }
        _customerForPayDoc_select = [self.searchArray objectAtIndex:indexPath.row];
        if (self.searchVC.isActive) {
            self.searchVC.active = NO;
        }
    } else {
        if ( indexPath.row >= paymentArray.count){
            [tableView reloadData];
            return;
        }
        _customerForPayDoc_select = [paymentArray objectAtIndex:indexPath.row];
    }
    [self performSegueWithIdentifier:@"gotoDetailFromCheckOut" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"gotoDetailFromCheckOut"]) {
        OrderPayListViewController *payController = segue.destinationViewController;
        payController.customerId = _customerForPayDoc_select.customerId;
        //        NSLog(@"cus id =%ld   cus name      =%@",_customerForPayDoc_select.customerId,_customerForPayDoc_select.customerName);
        payController.customerName = _customerForPayDoc_select.customerName;
        payController.pageFrom = 2;
        payController.branchID = ACC_BRANCHID;
    }
}

- (void)searchCustomerName:(NSString *)searchString
{
    [self.searchArray removeAllObjects];
    
    for (CustomerForPayDoc *customer in self.paymentArray) {
        if ([customer.customerName containsString:searchString] || [customer.searchPhone containsString:searchString]) {
            [self.searchArray addObject:customer];
        }
    }
}

#pragma mark - 接口

- (void)getUnpaidList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    //    NSString *str = [NSString stringWithFormat:@"{\"BranchID\":%ld}"];
    
    
    _getCustomerUpaidListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/getUnPaidList" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(!paymentArray)
                paymentArray = [NSMutableArray array];
            else
                [paymentArray removeAllObjects];
            
            for (NSDictionary *dic in data){
                CustomerForPayDoc *customerForPayDoc = [[CustomerForPayDoc alloc] init];
                customerForPayDoc.customerId = [[dic objectForKey:@"CustomerID"] integerValue];
                customerForPayDoc.customerName = [ dic objectForKey:@"CustomerName"];
                customerForPayDoc.customerPhoneNum = [dic objectForKey:@"LoginMobileShow"];
                customerForPayDoc.listTime = [dic objectForKey:@"LastTime"];
                customerForPayDoc.unpaidCount = [[dic objectForKey:@"OrderCount"] integerValue];
                customerForPayDoc.searchPhone = [dic objectForKey:@"LoginMobileSearch"];
                [paymentArray addObject:customerForPayDoc];
            }
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark 更新表格的显示结果
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchVC.searchBar text];
    if (self.searchArray != nil) {
        [self.searchArray removeAllObjects];
    }
    //过滤数据
    [self searchCustomerName:searchString];
    
    //刷新表格
    [self.tableView reloadData];
}

@end
