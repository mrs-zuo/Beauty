//
//  AccountInAndOutDetail_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AccountInAndOutDetail_ViewController.h"
#import "TitleView.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "GPHTTPClient.h"
#import "AccountCellTableViewCell.h"
#import "OrderDetailViewController.h"
#import "ProfitListRes.h"
#import "PerformanceTableViewCell.h"



@interface AccountInAndOutDetail_ViewController ()<UITableViewDataSource, UITableViewDelegate>


@property(strong,nonatomic) UITableView * tableView;
@property (strong, nonatomic) TitleView *titleView;
@property (weak  , nonatomic) AFHTTPRequestOperation *requestGetBalanceDetailOperation;
@property (strong,nonatomic) NSString * accountBalanceID;
@property (strong,nonatomic) NSString * ChangeTypeName;
@property (strong,nonatomic) NSString * Operator;
@property (strong,nonatomic) NSString * remarkString;
@property (strong,nonatomic) NSString * CreateTime;
@property (assign,nonatomic) double Amount;
@property (strong,nonatomic) NSString * branchName;
@property (strong,nonatomic) NSArray * OrderListArr;
@property (strong,nonatomic) NSMutableArray * ProfitListArr;//业绩参与者
@property (strong ,nonatomic) NSMutableArray *balanceInfoListMuArr;
@end

@implementation AccountInAndOutDetail_ViewController
@synthesize accountCardType,ChangeTypeName,Operator;
@synthesize remarkString,CreateTime,Amount,accountBalanceID;
@synthesize OrderListArr,ProfitListArr;
@synthesize balanceInfoListMuArr;
@synthesize branchName;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor_Background_View;
    
    _titleView = [[TitleView alloc] init];
    [self.view addSubview:_titleView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, _titleView.frame.origin.y + _titleView.frame.size.height, kSCREN_BOUNDS.size.width -10, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f)style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    //    _tableView.allowsSelection = NO;
    //    _tableView.autoresizingMask = UIViewAutoresizingNone;
    //    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.delegate = self;
    _tableView.dataSource = self ;
    [self.view addSubview:_tableView];
    if (IOS7 || IOS8) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _tableView.userInteractionEnabled = YES;
    [self getPaymentDetailById];
    
}
-(void)initdata
{
    Operator = @"";
    remarkString = @"";
    CreateTime = @"";
    Amount = 0;
    accountBalanceID = @"";
    branchName = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = kColor_Background_View;
    
    [_titleView getTitleView:[NSString stringWithFormat:@"交易明细"]];
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
    return (2+OrderListArr.count+balanceInfoListMuArr.count) + (remarkString.length > 0 ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 6 + self.ProfitListArr.count;
    }else if(section ==1)
        return 1;
    else if(section >1 &&(section<balanceInfoListMuArr.count+2))
    {
        if ([[[balanceInfoListMuArr objectAtIndex:section-2] objectForKey:@"type"] isEqualToString:@"Title"]) {
            return 0;
        }else
            return 2;
    }else if (section >= (balanceInfoListMuArr.count +2) &&section <=(balanceInfoListMuArr.count +OrderListArr.count+1) &&  OrderListArr.count>0)
        return 3;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = [NSString stringWithFormat: @"AccountCell%@",indexPath];
    AccountCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.contentText.frame =CGRectMake(140.0f, 3.0f, 160.0f, 32.0f);
    cell.contentText.textAlignment = NSTextAlignmentRight;
    if (indexPath.section ==0) {
        switch (indexPath.row) {
            case 0:
                cell.titleNameLabel.text = @"交易编号";
                cell.contentText.text = [NSString stringWithFormat:@"%@",accountBalanceID];
                break;
            case 1:
                cell.titleNameLabel.text = @"交易时间";
                cell.contentText.text = CreateTime;
                break;
            case 2:
                cell.titleNameLabel.text = @"交易门店";
                cell.contentText.text = [NSString stringWithFormat:@"%@",branchName] ;
                break;
            case 3:
                cell.titleNameLabel.text = @"交易类型";
                cell.contentText.text = ChangeTypeName;
                break;
            case 4:
                cell.titleNameLabel.text = @"操作人";
                cell.contentText.text = Operator;
                break;
            case 5:{
                cell.titleNameLabel.text = @"业绩参与";
//                NSString *nameString = [self.ProfitListArr componentsJoinedByString:@"、"];
//                NSInteger height = [nameString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height;
//                if (height > 20) {
//                    cell.contentText.frame = CGRectMake( 110 + ((IOS6) ? 20.f : 10.f), 8, 180 , height);
//                    cell.contentText.numberOfLines = 0;
//                    cell.contentText.textAlignment = NSTextAlignmentLeft;
//                }
                cell.contentText.text = self.ProfitListArr.count == 0 ? @"无" : @"";
            }
                break;
                
            default:{
                return [self configPerformanceProportionCell:tableView indexPath:indexPath];
            }
                break;
        }
    }else if(indexPath.section ==1)
    {
        if (self.accountCardType == 2) {
            cell.contentText.text = [NSString stringWithFormat:@"%.2f",Amount];
        }else
        {
           cell.contentText.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,Amount];

        }
        cell.titleNameLabel.text =[NSString stringWithFormat:@"%@总额",ChangeTypeName];
        
        
    }else if(indexPath.section >1 &&( indexPath.section<balanceInfoListMuArr.count+2))
    {
        AccountCellTableViewCell *editCell = [self AccountCellTableViewCellEditCell:tableView indexPath:indexPath];
        return editCell;
    }else if (indexPath.section >= (balanceInfoListMuArr.count +2) &&indexPath.section <=(balanceInfoListMuArr.count +OrderListArr.count+1) &&  OrderListArr.count>0)//订单
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        switch (indexPath.row) {
            case 0:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.contentText.frame = CGRectMake(140.0f, 3.0f, 140.0f, 32.0f);
                cell.titleNameLabel.text = @"订单编号";
                cell.contentText.text = [NSString stringWithFormat:@"%@",[[OrderListArr objectAtIndex:(indexPath.section-balanceInfoListMuArr.count -2)] objectForKey:@"OrderNumber"]];
                break;
            case 1:
                cell.titleNameLabel.text = [[OrderListArr objectAtIndex:(indexPath.section-balanceInfoListMuArr.count -2)] objectForKey:@"ProductName"];
                cell.contentText.text = @"";
                cell.frame = CGRectMake(10.0f, 9.0f, 300.0f, 20.0f);
                break;
            case 2:
                cell.titleNameLabel.text = @"订单金额";
                cell.contentText.text = [NSString stringWithFormat:@"%@%@",MoneyIcon,[[OrderListArr objectAtIndex:(indexPath.section-balanceInfoListMuArr.count -2)] objectForKey:@"TotalSalePrice"]];
                break;
            default:
                break;
        }
    }else if(indexPath.section ==(balanceInfoListMuArr.count +2 + OrderListArr.count) &&remarkString.length>0)//备注
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.titleNameLabel.text = @"备注";
            cell.contentText.text = @"";
        } else {
            cell.titleNameLabel.text = @"";
            NSInteger height = [remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            cell.contentText.frame = CGRectMake(((IOS6) ? 10.f : 5.f), 2, ((IOS6) ? 310.f : 300.f), height <= 38 ? 39: height);
            cell.contentText.font = kFont_Light_16;
            cell.contentText.text = remarkString;
            cell.contentText.lineBreakMode = UILineBreakModeCharacterWrap;
            cell.contentText.numberOfLines = 0;
            cell.contentText.textAlignment = NSTextAlignmentLeft;
            cell.contentText.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}

- (AccountCellTableViewCell *)AccountCellTableViewCellEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = [NSString stringWithFormat:@"AccountEditCell%@",indexPath];
    AccountCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
    }else
    {
        [cell removeFromSuperview];
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
    }
    
     cell.backgroundColor = [UIColor whiteColor];
    
    cell.contentText.frame =CGRectMake(140.0f, 3.0f, 160.0f, 32.0f);
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary * listDic = [[balanceInfoListMuArr objectAtIndex:indexPath.section-2]objectForKey:@"balanceCardDic"];
    
    if ( 0 == indexPath.row) {
        NSInteger type = [[listDic objectForKey:@"CardType"]integerValue];
        if (type == 2) {
            UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(60 + ((IOS6) ? 20.f : 10.f), 8, 130, 20)];
            lable.textColor = kColor_Black;
            lable.font = kFont_Light_16;
            lable.textAlignment  = NSTextAlignmentRight;
            lable.text = [NSString stringWithFormat:@"%.2f 抵",fabs([[listDic objectForKey:@"CardPaidAmount"] doubleValue])];
            
            if ([[listDic objectForKey:@"ActionMode"] integerValue] ==1 || [[listDic objectForKey:@"ActionMode"] integerValue] ==9 || [[listDic objectForKey:@"ActionMode"] integerValue] ==11) {
                
                cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,fabs([[listDic objectForKey:@"Amount"] doubleValue])];
                [cell addSubview:lable];
            }else if([[listDic objectForKey:@"ActionMode"] integerValue] ==13)
            {
                cell.contentText.text =  [NSString stringWithFormat:@"%.2f",fabs([[listDic objectForKey:@"CardPaidAmount"] doubleValue])];
            }
            else
            {
                cell.contentText.text =  [NSString stringWithFormat:@"%.2f",fabs([[listDic objectForKey:@"Amount"] doubleValue])];
            }
        }else if(type == 1)
        {
            cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,fabs([[listDic objectForKey:@"Amount"] doubleValue])];
        }else if(type == 3)
        {
            UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(60 + ((IOS6) ? 20.f : 10.f), 8, 130, 20)];
            lable.textColor = kColor_Black;
            lable.font = kFont_Light_16;
            lable.textAlignment  = NSTextAlignmentRight;
            lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,fabs([[listDic objectForKey:@"CardPaidAmount"] doubleValue])];
            
            if ([[listDic objectForKey:@"ActionMode"] integerValue] ==1|| [[listDic objectForKey:@"ActionMode"] integerValue] ==9 || [[listDic objectForKey:@"ActionMode"] integerValue] ==11) {
                cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,fabs([[listDic objectForKey:@"Amount"] doubleValue])];
                [cell addSubview:lable];
            }else if([[listDic objectForKey:@"ActionMode"] integerValue] ==13)
            {
                cell.contentText.text =  [NSString stringWithFormat:@"%.2f",fabs([[listDic objectForKey:@"CardPaidAmount"] doubleValue])];
            }else
            {
                cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,fabs([[listDic objectForKey:@"Amount"] doubleValue])];
                
            }
            
        }
        
        cell.titleNameLabel.text = [listDic objectForKey:@"CardName"];
        
    }else
    {
        NSInteger type = [[listDic objectForKey:@"CardType"]integerValue];
        if (type == 2) {
            cell.contentText.text =  [NSString stringWithFormat:@"%.2f",[[listDic objectForKey:@"Balance"] doubleValue]];
        }else if(type == 1)
        {
            cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,[[listDic objectForKey:@"Balance"] doubleValue]];
        }else if(type == 3)
        {
            cell.contentText.text =  [NSString stringWithFormat:@"%@%.2f",MoneyIcon,[[listDic objectForKey:@"Balance"] doubleValue]];
        }
        cell.titleNameLabel.text = @"余额";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section >= (balanceInfoListMuArr.count +2) &&indexPath.section <=(balanceInfoListMuArr.count +OrderListArr.count+1) &&  OrderListArr.count>0){
        if (indexPath.row ==0) {//进入订单详情
            NSDictionary * dic = [OrderListArr objectAtIndex:(indexPath.section-balanceInfoListMuArr.count -2)];
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OrderDetailViewController *orderDetail = [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
            orderDetail.orderID = [[dic objectForKey:@"OrderID"] integerValue];
            orderDetail.productType = [[dic objectForKey:@"ProductType"] integerValue];
            orderDetail.objectID  = [[dic objectForKey:@"OrderObjectID"] integerValue];
            [self.navigationController pushViewController:orderDetail animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==(balanceInfoListMuArr.count +2 + OrderListArr.count) &&remarkString.length>0){
        if (indexPath.row==1) {
            NSInteger height = [remarkString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < 38 ? 38 : height;
        }
    }
//    if (indexPath.section==0 &&indexPath.row==5) {
//        NSString *accString = [self.ProfitListArr componentsJoinedByString:@"、"];
//        NSInteger height = [accString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height + 18;
//        return height < 38 ? 38 : height;
//    }
    return 38.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (balanceInfoListMuArr.count > 0 && (section >1 &&(section<balanceInfoListMuArr.count+2))){
        if ([[[balanceInfoListMuArr objectAtIndex:section-2] objectForKey:@"type"] isEqualToString:@"Title"]) {
            
            return 25;
        }
    }
    return kTableView_Margin_Bottom;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 25)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel * headerlable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    headerlable.font = [UIFont systemFontOfSize:16];
    if (balanceInfoListMuArr.count > 0 && (section >1 &&(section<balanceInfoListMuArr.count+2))){
        if ([[[balanceInfoListMuArr objectAtIndex:section-2] objectForKey:@"type"] isEqualToString:@"Title"]) {
            
            headerlable.text = [[balanceInfoListMuArr objectAtIndex:section-2] objectForKey:@"ActionModeName"];
        }
    }
    [view addSubview:headerlable];
    return view;
}

#pragma mark -  配置cell
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {

    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.numText.enabled = NO;
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (self.ProfitListArr.count > 0) {
        ProfitListRes *profitRes = [self.ProfitListArr objectAtIndex:indexPath.row - 6];
        performanceCell.nameLab.text = profitRes.accountName;
        double temp =  profitRes.profitPct.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
    }
    return performanceCell;
}
#pragma mark - 接口

- (void)getPaymentDetailById
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary * par = @{
                           @"ID":self.BalanceID,
                           @"CardType":@(self.accountCardType),
                           @"ChangeType":@(self.changeType)
                           };
    _requestGetBalanceDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBalanceDetailInfo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSLog(@"date =%@",data);
            NSDictionary * dic = data;
            Amount =  fabs([[dic objectForKey:@"Amount"] doubleValue]);
            Operator = [dic objectForKey:@"Operator"];
            CreateTime = [dic objectForKey:@"CreateTime"];
            accountBalanceID = [dic objectForKey:@"BalanceNumber"];
            ChangeTypeName = [dic objectForKey:@"ChangeTypeName"];
            if ([[dic allKeys] containsObject:@"BranchName"]) {
                branchName = [dic objectForKey:@"BranchName"];
            }
            NSString *string = [dic objectForKey:@"Remark"];
            remarkString = [string stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            OrderListArr = [dic objectForKey:@"OrderList"];

//            ProfitListArr = [[NSMutableArray alloc] init];
//            for (NSDictionary *dict in [dic objectForKey:@"ProfitList"]) {
//                NSString *name = [dict objectForKey:@"AccountName"];
//                [ProfitListArr addObject:name];
//            }
            ProfitListArr = [[NSMutableArray alloc] init];
            NSArray *proList = [dic objectForKey:@"ProfitList"] == [NSNull null] ? nil : [dic objectForKey:@"ProfitList"];
            for (NSDictionary *proDic in proList) {
                ProfitListRes *profitRes = [[ProfitListRes alloc]init];
                profitRes.accountID = [proDic objectForKey:@"AccountID"];
                profitRes.accountName = [proDic objectForKey:@"AccountName"];
                profitRes.profitPct = [proDic objectForKey:@"ProfitPct"];
                [ProfitListArr addObject:profitRes];
            }
            
            if ([OrderListArr isKindOfClass:[NSNull class]]) {
                OrderListArr = nil ;
            }
            
            balanceInfoListMuArr = [[NSMutableArray alloc] init];
            for (NSDictionary * balanceInfoDic in [data objectForKey:@"BalanceInfoList"]) {
                NSDictionary *dic1 = @{
                                       @"type":@"Title",
                                       @"ActionModeName":[balanceInfoDic objectForKey:@"ActionModeName"]
                                       };
                [balanceInfoListMuArr addObject:dic1];
                
                for (NSDictionary * balanceCardDic in [balanceInfoDic objectForKey:@"BalanceCardList"]) {
                    NSDictionary *dic2 = @{
                                           @"type":@"Content",
                                           @"balanceCardDic":balanceCardDic
                                           };
                    [balanceInfoListMuArr addObject:dic2];
                }
            }
        
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
