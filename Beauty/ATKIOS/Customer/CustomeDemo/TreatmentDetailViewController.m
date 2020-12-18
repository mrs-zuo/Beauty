//
//  TreatmentDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentDetailViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "TreatmentDoc.h"
#import "ScheduleDoc.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"

@interface TreatmentDetailViewController ()
@property (weak, nonatomic)AFHTTPRequestOperation *requestForGetPaymentDetail;
@property(strong ,nonatomic)NSString * titleStr;
@property(strong,nonatomic)TitleView *titleView;
@property (strong ,nonatomic) NSDictionary * detailDic;
@property (nonatomic ,strong) NSString * remarkStr;
@property (nonatomic ,assign) float remarkHeight;
@property (strong, nonatomic) OrderDoc *theOrder;

@end

@implementation TreatmentDetailViewController
@synthesize myTableView;
@synthesize treatmentDoc;
@synthesize titleStr;
@synthesize titleView;
@synthesize detailDic;
@synthesize remarkHeight,remarkStr;
@synthesize theOrder;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.treatMentOrGroup ==1) {
        titleStr = @"服务";
        [self GetTGDetail];
        
    }else
    {
        titleStr = @"操作";
        [self getTreatmentDetail];
    }
    self.tabBarController.title =  [NSString stringWithFormat:@"%@详情",titleStr];
}

- (void)viewDidLoad
{
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
    myTableView.autoresizesSubviews = UIViewAutoresizingNone;
    [self.view addSubview:myTableView];
    
    //在(IOS7 || IOS8)的情况下重新计算起始点
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)editSuccessWithTreatmentDoc:(TreatmentDoc *)newTreament
{
    treatmentDoc = newTreament;
    [myTableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kTableView_WithTitle)];
    header.backgroundColor = [UIColor clearColor];
    
    return header;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([titleStr isEqualToString:@"服务"]) {
            return 5;
        }
        return 4;
        
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int cellRow = (int)indexPath.row;
    if (indexPath.row > 0 && [titleStr isEqualToString:@"操作"]) {
        cellRow += 1;
    }
    if (indexPath.section == 0) {
        switch (cellRow) {
            case 0:
            {
                static NSString *cellIndentify = @"numCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                if (!self.treatMentOrGroup) {//treatment
                    cell.valueText.text = [NSString stringWithFormat:@"%@",[detailDic objectForKey:@"ID"]];
                }else
                {
                    cell.valueText.text = [NSString stringWithFormat:@"%@",[detailDic objectForKey:@"GroupNo"]];
                }
                cell.titleLabel.text = [NSString stringWithFormat:@"%@编号",titleStr];
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                
            }
                break;
            case 1:
            {
                static NSString *cellIndentify = @"Cell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                
                cell.titleLabel.text = [NSString stringWithFormat:@"服务门店"];
                cell.valueText.text = [[detailDic allKeys] containsObject:@"BranchName"]== 0?@" " : [detailDic objectForKey:@"BranchName"];
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
                
            }
                break;
            case 2:
            {
                static NSString *cellIndentify = @"stateCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"状态";
                cell.valueText.text =theOrder.order_TGStatusStr;
                cell.valueText.textColor = [UIColor blackColor];
                cell.valueText.enabled = NO;
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case 3:
            {
                static NSString *cellIndentify = @"timeCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"开始时间";
                if (!self.treatMentOrGroup) {//treatment
                    
                    cell.valueText.text = [detailDic objectForKey:@"StartTime"];
                }else
                {
                    cell.valueText.text = [detailDic objectForKey:@"TGStartTime"];
                }
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case 4:
            {
                static NSString *cellIndentify = @"timeCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"结束时间";
                if (theOrder.order_TGStatus == 1) {
                    cell.valueText.text = @" " ;
                }else{
                    if (!self.treatMentOrGroup) {//treatment
                        cell.valueText.text = [detailDic objectForKey:@"FinishTime"];
                    }else
                    {
                        cell.valueText.text = [detailDic objectForKey:@"TGEndTime"];
                    }
                }
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
                
            default:
                break;
        }
        
    } else {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"contactRecordCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = [NSString stringWithFormat:@"%@记录",titleStr];
            cell.valueText.enabled = NO;
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else {
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:remarkStr];
            cell.backgroundColor = [UIColor whiteColor];
            [cell.contentEditText setTag:101];
            cell.contentEditText.userInteractionEnabled = NO;
            cell.contentEditText.editable = YES ;
            [cell.contentEditText setFrame:CGRectMake(0.0f, 2.0f, 312.0f, 120.0f)];
            
            return cell;
        }
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        if (remarkStr.length > 0) {
            NSInteger height = [remarkStr sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
        }
        return kTableView_DefaultCellHeight;
    } else {
        return kTableView_DefaultCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    } else {
        return kTableView_Margin;
    }
}


#pragma mark - 接口
-(void)getTreatmentDetail
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    
    NSDictionary *para = @{
                           @"TreatmentID":@((long)treatmentDoc.treat_ID)
                           };


    _requestForGetPaymentDetail = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetTreatmentDetail" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:NO
                  success:^(id data, NSInteger code, id message) {
                      
                      if (data == nil) {
                          return ;
                      }
                    
                      theOrder = [[OrderDoc alloc] init];
                      detailDic = data;
                      remarkStr = [detailDic objectForKey:@"Remark"];

                      int status;
                      status = [[detailDic objectForKey:@"Status"] intValue];
                      [theOrder setOrder_TGStatus:status];
                      
                      [myTableView reloadData];
                      
                      [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD dismiss];
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


-(void)GetTGDetail
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"OrderID":@((long)self.OrderID),
                           @"GroupNo":@((long long)_GroupNo)};

    _requestForGetPaymentDetail = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetTGDetail" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:NO
                  success:^(id data, NSInteger code, id message) {
                      
                      if (data == nil) {
                          return ;
                      }
                      theOrder = [[OrderDoc alloc] init];
                      detailDic = data;
                      remarkStr = [detailDic objectForKey:@"Remark"];
         
                      int status;
                      status = [[detailDic objectForKey:@"TGStatus"] intValue];
                      [theOrder setOrder_TGStatus:status];
                      
                      [myTableView reloadData];
                      
                      [SVProgressHUD dismiss];

                  } failure:^(NSInteger code, NSString *error) {
                  }];

    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];
    
}

@end
