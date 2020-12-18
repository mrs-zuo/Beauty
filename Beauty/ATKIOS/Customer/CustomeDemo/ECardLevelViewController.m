//
//  ECardLevelViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ECardLevelViewController.h"
#import "ECardLevel.h"
#import "GPHTTPClient.h"
#import "ZWJson.h"
#import "SVProgressHUD.h"

@interface ECardLevelViewController ()
@property (strong ,nonatomic) NSMutableArray *eCardLevelArray;
@property (weak  , nonatomic) AFHTTPRequestOperation *getECardLevelListOperation;
@end

@implementation ECardLevelViewController
@synthesize eCardLevelArray;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    eCardLevelArray = [NSMutableArray array];
    //在(IOS7 || IOS8)的情况下重新计算起始点
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
//    TitleView *titleView = [[TitleView alloc] init];
//    [titleView getTitleView:@"e卡等级和折扣详情"];
//    [self.view addSubview:titleView];
 
    self.title = @"e卡等级和折扣详情";
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        _tableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 88.0f);
    }else
        _tableView.frame = CGRectMake( 0, 15.0f, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 70.0f);
    
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getECardLevelByCustomerID];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getECardLevelListOperation || [_getECardLevelListOperation isExecuting]) {
        [_getECardLevelListOperation cancel];
        _getECardLevelListOperation = nil;
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
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    return eCardLevelArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ECardLevel *eCardLevel = nil;
    if(eCardLevelArray.count > 0)
        eCardLevel = [eCardLevelArray objectAtIndex:indexPath.row];
    
    UILabel *title = (UILabel *)[cell viewWithTag:9996];
    if(!title) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 100, 20)];
        [cell addSubview:title];
    }
    title.tag = 9996;
    title.textColor = kColor_TitlePink;
    title.font = kFont_Light_16;
    title.frame = CGRectMake(10, 8, 200, 20);
    if(indexPath.section == 0) {
        title.textColor = kColor_TitlePink;
        title.text = @"e卡等级";
        title.frame = CGRectMake(10, 8, 100, 20);
    }else
        title.text = eCardLevel.eCardLevelDiscountName;
    
    UILabel *value = (UILabel *)[ cell viewWithTag:1001];
    if(!value){
        value = [[UILabel alloc] init];
        [cell addSubview:value];
    }
    value.frame = CGRectMake(250, 8, 50, 20);
    value.textColor = kColor_Black;
    value.font = kFont_Light_16;
    value.tag = 1001;
    value.textAlignment = NSTextAlignmentRight;
    if(indexPath.section == 0) {
        value.text = _eCardLevel;
        value.frame = CGRectMake(150, 8, 150, 20);
    }else
        value.text = [NSString stringWithFormat:@"%.2f", eCardLevel.eCardLevelDiscount];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}
#pragma mark - 接口

- (void)getECardLevelByCustomerID
{
    [SVProgressHUD showWithStatus:@"Loading"];

    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"LevelID":@0};
    _getECardLevelListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/level/getDiscountListForWebService"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        if(eCardLevelArray)
            [eCardLevelArray removeAllObjects];
        else
            eCardLevelArray = [NSMutableArray array];
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            for (NSDictionary *dict in data){
                ECardLevel *eCardLevel = [[ECardLevel alloc] init];
                eCardLevel.eCardLevelDiscountName = dict[@"DiscountName"] == [NSNull null] ? nil : dict[@"DiscountName"];
                eCardLevel.eCardLevelDiscount = [dict[@"Discount"] floatValue];
                [eCardLevelArray addObject:eCardLevel];
            }
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) { }];
        [_tableView reloadData];
    } failure:^(NSError *error) {

    }];
//    _getECardLevelListOperation = [[GPHTTPClient shareClient] requestGetECardLevelDiscountListSuccess:^(id xml) {
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data , NSInteger code, id message) {
//            
//            if(eCardLevelArray)
//               [eCardLevelArray removeAllObjects];
//            else
//                eCardLevelArray = [NSMutableArray array];
//            
//            for (NSDictionary *dict in data){
//                ECardLevel *eCardLevel = [[ECardLevel alloc] init];
//                eCardLevel.eCardLevelDiscountName = dict[@"DiscountName"];
//                eCardLevel.eCardLevelDiscount = [dict[@"Discount"] floatValue];
//                [eCardLevelArray addObject:eCardLevel];
//            }
//            [_tableView reloadData];
//            [SVProgressHUD dismiss];
//        } failure:^( NSInteger code, NSString *error) {
//            [SVProgressHUD dismiss];
//        }];
//    }
//    failure:^(NSError *error) {
//          [SVProgressHUD dismiss];
//    }];
}


@end
