//
//  RechargeDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-11.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RechargeDetailViewController.h"
#import "SVProgressHUD.h"
#import "ZWJson.h"
#import "GPHTTPClient.h"

@interface RechargeDetailViewController ()
@property (strong, nonatomic) NSString *remarkString;
@property (strong, nonatomic) TitleView *titleView;
@property (weak  , nonatomic) AFHTTPRequestOperation *requestGetBalanceDetailOperation;
@property (strong, nonatomic) NSArray *modeArray;
@end

@implementation RechargeDetailViewController

#pragma mark -

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _modeArray = [NSArray arrayWithObjects:@"现金",@"银行卡",@"赠送",@"转入",@"消费",@"转出",@"退款", nil];

    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = NO;
 
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height- 88 );
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];

    NSString *string = nil;
    if(_mode < 4)
        string = @"充值";
    else if(_mode == 5)
        string = @"转出";
    else
        string = @"退款";
//    [_titleView getTitleView:[NSString stringWithFormat:@"%@%@",string,@"详情"]];
    self.title = [NSString stringWithFormat:@"%@%@",string,@"详情"];
    [self getPaymentDetailById:_rechargeId];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (_requestGetBalanceDetailOperation || [_requestGetBalanceDetailOperation isExecuting]) {
        [_requestGetBalanceDetailOperation cancel];
        _requestGetBalanceDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_mode < 4)
        return 5 + (_remarkString.length > 0 ? 2 : 0);
    return 4 + (_remarkString.length > 0 ? 2 : 0 );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = kColor_White;
    if((_mode > 4 && indexPath.row == 5) || (_mode < 4 && indexPath.row == 6)  ){
        NSInteger height = [_remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
        UITextView *record = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 2, ((IOS6) ? 310.f : 300.f), height <= 38 ? 34:height)];
        record.font = kFont_Light_16;
        record.scrollEnabled = NO;
        record.editable = NO;
        record.text = _remarkString;
        record.backgroundColor = [UIColor clearColor];
        [cell addSubview:record];
        return cell;
    }
    CGFloat origin = 10;
    if(IOS6)
        origin = 20;
    UILabel *title = (UILabel *)[cell viewWithTag:10000];
    if (!title) {
        title = [[UILabel alloc] initWithFrame:CGRectMake( origin, 8, 100 , 22)];
        [cell addSubview:title];
    }
    title.font = kFont_Light_16;
    title.textColor = kColor_TitlePink;
    
    UILabel *value = (UILabel *)[cell viewWithTag:10001];
    if (!value) {
        value = [[UILabel alloc] initWithFrame:CGRectMake( 110 + origin, 8, 180 , 22)];
        [cell addSubview:value];
    }
    value.font = kFont_Light_16;
    value.textColor = kColor_Black;
    value.textAlignment = NSTextAlignmentRight;
    if(_mode > 4){
        switch (indexPath.row) {
            case 0:
                title.text = [NSString stringWithFormat:@"%@%@",[_modeArray objectAtIndex:_mode],@"时间"];
                value.text = _rechargeTime;
                break;
            case 1:
                title.text = @"操作人";
                value.text = _rechargeOperator;
                break;
            case 2:
                title.text = [NSString stringWithFormat:@"%@%@",[_modeArray objectAtIndex:_mode],@"金额"];
                value.text = _rechargeMoney ? [NSString stringWithFormat:@"%@ %@", CUS_CURRENCYTOKEN, _rechargeMoney] : @"";
                break;
            case 3:
                title.text = @"余额";
                value.text = _moneyLeft ? [NSString stringWithFormat:@"%@ %@", CUS_CURRENCYTOKEN, _moneyLeft] : @"";
                break;
            case 4:
                title.text = @"备注";
                break;
        }
    }else if(_mode < 4){
        switch (indexPath.row) {
            case 0:
                title.text = [NSString stringWithFormat:@"%@",@"充值时间"];
                value.text = _rechargeTime;
                break;
            case 1:
                title.text = @"操作人";
                value.text = _rechargeOperator;
                break;
            case 2:
                title.text = [NSString stringWithFormat:@"%@",@"充值金额"];
                value.text = _rechargeMoney ? [NSString stringWithFormat:@"%@ %@", CUS_CURRENCYTOKEN, _rechargeMoney] : @"";
                break;
            case 3:
                title.text = [NSString stringWithFormat:@"%@",@"充值方式"];
                value.text = _rechargeMode;
                break;
            case 4:
                title.text = @"余额";
                value.text = _moneyLeft ? [NSString stringWithFormat:@"%@ %@", CUS_CURRENCYTOKEN, _moneyLeft] : @"";
                break;
            case 5:
                title.text = @"备注";
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((_mode > 4 && indexPath.row == 5) || (_mode < 4 && indexPath.row == 6)){
        NSInteger height = [_remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
        return height < 38 ? 38 : height;
    }
    return 38.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

#pragma mark - 接口

- (void)getPaymentDetailById:(NSInteger)Id
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para  = @{@"ID":@(Id)};
    _requestGetBalanceDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/getBalanceDetail"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _rechargeMode = data[@"Mode"];;
            _rechargeMoney = [NSString stringWithFormat:@"%.2f",[data[@"Amount"] doubleValue]];
            _rechargeTime = data[@"CreateTime"] == [NSNull null] ? nil : data[@"CreateTime"];
            _rechargeOperator = data[@"Operator"] == [NSNull null] ? nil : data[@"Operator"];
            _moneyLeft = [NSString stringWithFormat:@"%.2f",[data[@"Balance"] doubleValue]]; //从上级页面传
            _remarkString = data[@"Remark"] == [NSNull null] ? nil : data[@"Remark"];

            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {

    }];
//    _requestGetBalanceDetailOperation= [[GPHTTPClient shareClient] requestGetBalanceDetailByID:Id withSuccess:^(id xml) {
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:NO success:^(id data , NSInteger code, id message) {
//            _rechargeMode = data[@"Mode"];;
//            _rechargeMoney = data[@"Amount"];
//            _rechargeTime = data[@"CreateTime"];
//            _rechargeOperator = data[@"Operator"];
//            _moneyLeft = data[@"Balance"] ; //从上级页面传
//            _remarkString = data[@"Remark"];
//            _rechargeTime = [_rechargeTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//            
//            [_tableView reloadData];
//            [SVProgressHUD dismiss];
//        } failure:^( NSInteger code, NSString *error) {
//            [SVProgressHUD dismiss];
//        }];
//        
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
