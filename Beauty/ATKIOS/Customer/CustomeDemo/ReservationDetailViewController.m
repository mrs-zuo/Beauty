//
//  ReservationDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ReservationDetailViewController.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"
#import "getScheduleDetailModal.h"

#import "OrderDetailCell.h"

@interface ReservationDetailViewController ()

@property (weak, nonatomic)AFHTTPRequestOperation *requestGetScheduleDetail;

@property (strong, nonatomic)getScheduleDetailModal *getSchDetail;

@end

@implementation ReservationDetailViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 88.0f);
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self.tableView registerClass:[OrderDetailCell class] forCellReuseIdentifier:@"detailCell"];

    self.title = @"预约详情";
}

-(void)viewDidAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewDidAppear:animated];
    [self getScheduleDetail];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 5;
            break;
        case 1:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailCell *detailCell = [_tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if (detailCell == nil){
        
    }
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                detailCell.textLabel.text = @"预约编号";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%lld",self.getSchDetail.TaskID] ;
                break;
            case 1:
                detailCell.textLabel.text = @"预约状态";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.TaskStatusString] ;
                break;
            case 2:
                detailCell.textLabel.text = @"预约门店";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.BranchName] ;
                break;
            case 3:
                detailCell.textLabel.text = @"到店时间";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.TaskScdlStartTime] ;
                break;
            case 4:
                detailCell.textLabel.text = @"预约内容";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.ProductName] ;
                break;
                
            default:
                
                break;
                
        }
    }else {
        switch (indexPath.row) {
            case 0:
                detailCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                
                detailCell.textLabel.text = @"订单编号";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.OrderNumber] ;
                break;
            case 1:
                detailCell.textLabel.textColor = kColor_Black;
                detailCell.textLabel.text = [NSString stringWithFormat:@"%@",self.getSchDetail.ProductName];
              
                break;
            case 2:
                
                detailCell.textLabel.text = @"订单金额";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,self.getSchDetail.TotalSalePrice] ;
                break;
            default:
                break;
                
        }
    }
  
    
    return detailCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

-(void)getScheduleDetail
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"LongID":@(self.taskID)};
    
    _requestGetScheduleDetail = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Task/GetScheduleDetail"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            self.getSchDetail = [[getScheduleDetailModal alloc]initWithDic:data];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        
    }];
}


@end
