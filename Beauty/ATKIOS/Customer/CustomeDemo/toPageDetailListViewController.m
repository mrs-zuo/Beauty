//
//  toPageDetailListViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/24.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "toPageDetailListViewController.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"
#import "NormalEditCell.h"

@interface toPageDetailListViewController ()
@property (weak, nonatomic)AFHTTPRequestOperation *requestBalanceListByCustomerID;
@property (strong, nonatomic)NSMutableArray *arrayForBalanceListByCustomerID;
@end

@implementation toPageDetailListViewController
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20)];
    
    self.title = @"账户交易记录";
    
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [self getBalanceListByCustomerID];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayForBalanceListByCustomerID.count;
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 100, kCell_LabelHeight)];
    titleLabel.textColor = kColor_TitlePink;
    titleLabel.font = kFont_Light_16;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    UITextField *valueText = [[UITextField alloc ]initWithFrame:CGRectMake(100.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 160, kCell_LabelHeight)];
    valueText.textColor = kColor_Black;
    valueText.font = kFont_Light_16;
    valueText.textAlignment = NSTextAlignmentRight;
    valueText.borderStyle = UITextBorderStyleNone;
    valueText.returnKeyType = UIReturnKeyDone;
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    [titleLabel setText:[_arrayForBalanceListByCustomerID[indexPath.row] objectForKey:@"ChangeTypeName"]];
    [valueText setText:[_arrayForBalanceListByCustomerID[indexPath.row] objectForKey:@"CreateTime"]];
    valueText.userInteractionEnabled = NO;
    [cell addSubview:titleLabel];
    [cell addSubview:valueText];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kTableView_Margin)];
    headerView.backgroundColor = kDefaultBackgroundColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return kTableView_WithTitle;
       
        default: return kTableView_Margin;
    }
}
#pragma mark -  接口
-(void)getBalanceListByCustomerID{
    
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID)};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestBalanceListByCustomerID = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBalanceListByCustomerID"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _arrayForBalanceListByCustomerID = [[NSMutableArray alloc]init];
            for (NSDictionary *dict in data)
            {
                [_arrayForBalanceListByCustomerID addObject:dict];
            }
            
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end
