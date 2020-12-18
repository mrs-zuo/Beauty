//
//  OrderDetailAboutServiceViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderDetailAboutServiceViewController.h"
#import "ContactDetailViewController.h"
#import "TreatmentDetailViewController.h"
#import "EffectDisplayViewController.h"
#import "TreatmentCommentViewController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "NSMutableString+Dictionary.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "OneLabelCell.h"
#import "TwoLabelCell.h"
#import "UILabelStrikeThrough.h"
#import "UILabel+InitLabel.h"
#import "NormalEditCell.h"
#import "OrderDateCell.h"
#import "OrderDoc.h"
#import "ServiceDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDoc.h"
#import "CourseDoc.h"
#import "ContactDoc.h"
#import "ProductAndPriceView.h"
#import "OrderTreatmentCell.h"
#import "PayInfoDoc.h"
#import "ZWJson.h"
#import "OrderPaymentDetailViewController.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "TreatmentDetailViewController.h"
#import "ReservationDetailViewController.h"
#import "AppointmentDetail_ViewController.h"
#import "AppointmenCreat_ViewController.h"
#define kColorNewLightBrown [UIColor colorWithRed:213.0/255.0f green:197.0f/255.0f blue:181.0f/255.0f alpha:1.0f]

#import "OrderDetailModel.h"
#import "OrderDetailCell.h"
#import "Treatments.h"  
#import "OrderProgressCell.h"
#import "TreatmentGroupTabbarController.h"
#import "TreatmentGroupReview_ViewController.h"
#import "ZXServiceEffectViewController.h"

#define PaymentStatus (self.orderDetail.PaymentStatus == 2 || self.orderDetail.PaymentStatus == 3)

@interface OrderDetailAboutServiceViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetTreatGroupByOrderObjectID;

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOrderDetailAboutServiceOperation;
@property (nonatomic) ProductAndPriceView *productAndPriceView;
@property (nonatomic) ContactDoc *contactDoc_Selected;
@property (nonatomic) TreatmentDoc *treatmentDoc_Selected;
@property (nonatomic, copy) NSMutableArray *payment_Info;
@property (nonatomic, strong) OrderDetailModel *orderDetail;
@property (nonatomic, assign) BOOL isRefresh;

@property (assign, nonatomic)long long taskID;
@end

@implementation OrderDetailAboutServiceViewController
@synthesize orderDoc;
@synthesize contactDoc_Selected;
@synthesize treatmentDoc_Selected;
@synthesize productAndPriceView;
@synthesize payment_Info;

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    
    if (self.isRefresh) {
        [self requestGetOrderDetailAboutServiceListByJson];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderDetailAboutServiceOperation || [_requestGetOrderDetailAboutServiceOperation isExecuting]) {
        [_requestGetOrderDetailAboutServiceOperation cancel];
        _requestGetOrderDetailAboutServiceOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isRefresh = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 44);
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self.tableView registerClass:[OrderDetailCell class] forCellReuseIdentifier:@"detailCell"];
    [self.tableView registerClass:[OrderProgressCell class] forCellReuseIdentifier:@"ProgressCell"];
    self.title = @"订单详情（服务)";
    self.isRefresh = YES;
}

-(void)initAppointmentButtonWithTableFooterView//预约按钮
{
    if ( self.orderDetail.Status ==1) {
        if ((self.orderDetail.SurplusCount>0 && self.orderDetail.TotalCount >0)|| self.orderDetail.TotalCount == 0) {

            UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, 320.0f, 36.0f)];
            footView.tag = 119;
            footView.backgroundColor = kColor_Clear;
            [self.view addSubview:footView];
            
            UIButton *add_Button = [UIButton buttonWithTitle:@"预约"
                                                      target:self
                                                    selector:@selector(gotoAppointmentCreate)
                                                       frame:CGRectMake(5.0f, 0.0f, 60.0f, 30.0f)
                                               backgroundImg:nil
                                            highlightedImage:nil];
            [footView addSubview:add_Button];
            add_Button.tag = 110;
            add_Button.titleLabel.font=kNormalFont_14;
            add_Button.layer.cornerRadius = 6;
            add_Button.backgroundColor = [UIColor colorWithRed:203/255. green:184/255. blue:166/255. alpha:1.];
            [_tableView setTableFooterView:footView];
        }
    }
}

-(void)gotoAppointmentCreate
{
    AppointmenCreat_ViewController * create = [[AppointmenCreat_ViewController alloc] init];
    create.orderID = self.orderDetail.OrderID;
    create.BranchID = self.orderDetail.BranchID;
    create.branchName = self.orderDetail.BranchName;
    create.serviceName = self.orderDetail.ProductName;
    create.serviceID =  self.orderDetail.OrderObjectID;
    create.ReservedOrderType = 1;
    create.taskSourceType = 3;
    [self.navigationController pushViewController:create animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.orderDetail.isShowFirst)
            return 5;
        else
            return 1;
    } else if (section == 1) {
        if (self.orderDetail.isShowSecond) {
            if (self.orderDetail.TotalSalePrice == self.orderDetail.TotalCalcPrice) {
                return 4;
            } else {
                return 5;
            }
        }
        else
            return 1;
    } else if (section == 2) {//订单状态
        if (PaymentStatus) {
            return 2;
        }
        return 1;
    } else if (section == 3) {//订单进度
        if (self.orderDetail.GroupList.count == 0 ) {
            return 1;
        } else {
            return self.orderDetail.groupCount + 1;
        }
    } else if (section == 4) {//预约
       // return 0; //暂时屏蔽
        if (self.orderDetail.ScdlList.count == 0) {
            return 0;
        } else {
            if (self.orderDetail.isShowTask) {
                return self.orderDetail.ScdlList.count + 1;
            } else {
                return 1;
            }
        }
    } else if (section == 5) { //完成
        if (self.orderDetail.FinishedCount == 0 && self.orderDetail.PastCount ==0 && self.orderDetail.completionCount == 0) {
            return 0;
        } else {
            NSInteger count = 0;
            if (self.orderDetail.isShowCompletion) {
                count = self.orderDetail.completionCount + 1;
                if (self.orderDetail.PastCount > 0) {
                    ++count;
                }
            } else {
                count = 1;
            }
            return count;
        }
    } else { //备注
//        if (self.orderDetail.Remark.length > 0) {
//            return 2;
//        } else {
            return 0;
//        /}
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setCellSpearatorInsetOfCell:(UITableViewCell *)cell separtorInset:(UIEdgeInsets)separaInsets
{
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:separaInsets];
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = [NSString stringWithFormat:@"detailCell_%@",indexPath];
    
    OrderDetailCell *detailCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (detailCell == nil) {
        detailCell = [[OrderDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }else{
        //解决向下偏移时候的复用问题
        [detailCell removeFromSuperview];
         detailCell = [[OrderDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
    }
    detailCell.accessoryView = nil;
    detailCell.accessoryType = UITableViewCellAccessoryNone;
    detailCell.textLabel.textColor = kColor_TitlePink;
    detailCell.textLabel.numberOfLines = 1;
    
    NSString *progressIdentifier = [NSString stringWithFormat:@"ProgressCell%@",indexPath];
    OrderProgressCell *progressCell = [self.tableView dequeueReusableCellWithIdentifier:progressIdentifier];
    if (progressCell == nil) {
        progressCell = [[OrderProgressCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:progressIdentifier];
    }
    
    [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsZero];
    progressCell.accessoryView = nil;
    progressCell.accessoryType = UITableViewCellAccessoryNone;
    progressCell.textLabel.textColor = kColor_TitlePink;
    progressCell.textLabel.numberOfLines = 1;

    UIImageView * downImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight-15)/2, 20, 15)];
    downImage.tag = indexPath.section +1000;
    [detailCell.contentView addSubview:downImage];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                detailCell.detailLabel.frame = CGRectMake(160, 15, 130, kLabel_DefaultHeight);
                detailCell.textLabel.text = @"订单编号";
                detailCell.detailLabel.text = self.orderDetail.OrderNumber;
                UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
                image.image = [UIImage imageNamed:self.orderDetail.isShowFirst ? @"jiantous.png" : @"jiantoux.png"];
                [detailCell.contentView addSubview:image];
            }
                break;
            case 1:
                detailCell.textLabel.text = @"下单门店";
                detailCell.detailTextLabel.text = self.orderDetail.BranchName;

                break;
            case 2:
                detailCell.textLabel.text = @"下单时间";
                detailCell.detailTextLabel.text = self.orderDetail.OrderTime ;
                break;
            case 3:
            {
                detailCell.textLabel.text = @"服务有效期";
                detailCell.detailTextLabel.text = [self.orderDetail.ExpirationTime substringToIndex:10];
                
                UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"outOfDate"]];
                imageView.frame = CGRectMake(165.0f, (kTableView_DefaultCellHeight - 30.0f)/2 + 5, 45.0f, 18.0f);
                imageView.tag = 1006;
                imageView.hidden = YES;
                
                if (self.orderDetail.ExpirationTime) {
                    
                    NSDate *date = nil;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    date = [dateFormatter dateFromString:[self.orderDetail.ExpirationTime substringToIndex:10]];
                    date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 8*3600)];
                    
                    NSDate *currentDate = [NSDate date];
                    date = [dateFormatter dateFromString:[date.description substringToIndex:10]];
                    currentDate = [dateFormatter dateFromString:[currentDate.description substringToIndex:10]];
                    
                    if([date compare:currentDate] == NSOrderedDescending || [date compare:currentDate] == NSOrderedSame)
                        imageView.hidden = YES;
                    else{
                        imageView.hidden = NO;
                    }
                }
                [detailCell addSubview:imageView];
            }
                break;
            case 4:
                detailCell.textLabel.text = @"美丽顾问";
                detailCell.detailTextLabel.text = self.orderDetail.ResponsiblePersonName;
                break;
        }
        return detailCell;
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                detailCell.textLabel.text = @"";
                
                NSInteger height = [self.orderDetail.ProductName sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width- 35, 500) lineBreakMode:NSLineBreakByCharWrapping].height;
              
                UILabel * pdNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, kSCREN_BOUNDS.size.width - 20 -15, (height+20)<kTableView_DefaultCellHeight?kTableView_DefaultCellHeight:(height+20))];
                
                UILabel * checkname = (UILabel *)[detailCell.contentView viewWithTag:808];
                if (!checkname) {
                    pdNameLabel.numberOfLines = 0;
                    pdNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                    pdNameLabel.textColor = kColor_TitlePink;
                    pdNameLabel.font = kNormalFont_14;
                    [detailCell.contentView addSubview:pdNameLabel];
                }
                pdNameLabel.text = self.orderDetail.ProductName;
                detailCell.detailTextLabel.text = @"";
                UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
                image.image = [UIImage imageNamed:self.orderDetail.isShowSecond ? @"jiantous.png" : @"jiantoux.png"];
                [detailCell.contentView addSubview:image];
            }
                break;
            case 1:
                detailCell.textLabel.text = @"数量";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)self.orderDetail.Quantity];
                break;
            case 2:
                detailCell.textLabel.text = @"原价小计";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalOrigPrice];
                break;
            case 3:
                detailCell.textLabel.text = @"会员价";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalCalcPrice];
                break;
            case 4:
                detailCell.textLabel.text = @"成交价";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", CUS_CURRENCYTOKEN, self.orderDetail.TotalSalePrice];
                break;
        }
        return detailCell;
    }
    
    if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                detailCell.textLabel.text = @"订单状态";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%@|%@",self.orderDetail.progressStatus, self.orderDetail.payStatus];
                break;
            case 1:
                detailCell.textLabel.text = @"支付详情";
                detailCell.detailTextLabel.text = @"";
                
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [detailCell.contentView addSubview:arrowsImage];
                break;
        }
        return detailCell;
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = self.orderDetail.orderProgressInfo;
            if (self.orderDetail.TotalCount == 0) {
                 detailCell.detailTextLabel.text = @"";
            }else
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"剩余%ld次", (long)self.orderDetail.SurplusCount];
            return detailCell;
        } else {
            NSIndexPath *progressIndexPath = [self computeOrderProgressIndexPath:indexPath type:0];
            [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsMake(0, 310, 0, 0)];

            TreatmentGroup *treatGroup = [self.orderDetail.GroupList objectAtIndex:progressIndexPath.section];
            if (progressIndexPath.row == 0) {
                //时间  状态
                progressCell.textLabel.text = treatGroup.StartTime;
                progressCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[OrderDetailModel orderProgressStatus:treatGroup.Status]];
            } else if (progressIndexPath.row == 1) {
                //服务人名称
                progressCell.textLabel.text = treatGroup.ServicePicName; //.length == 0 ? @"服务操作" : treatGroup.ServicePicName
                progressCell.detailTextLabel.text = @"";
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [progressCell.contentView addSubview:arrowsImage];
            } else {
                //子服务名（没有:操作人员） 操作人
                Treatments  *treat = [treatGroup.TreatmentList objectAtIndex:(progressIndexPath.row -2 )];
                progressCell.textLabel.text = [NSString stringWithFormat:@"    %@",treat.SubServiceName.length == 0 ? @"服务操作" : treat.SubServiceName];
                progressCell.textLabel.textColor = kColor_Black;
                progressCell.detailLabel.text = treat.ExecutorName;
                progressCell.detailLabel.frame = CGRectMake(160, (kTableView_DefaultCellHeight -kLabel_DefaultHeight)/2, 130, kLabel_DefaultHeight);
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [progressCell.contentView addSubview:arrowsImage];
                if ([treat isEqual:[treatGroup.TreatmentList lastObject]]) {
                    [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsZero];
                }
            }
            return progressCell;
        }
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = @"已确认预约";
            detailCell.detailTextLabel.text = @"";
            UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
            image.image = [UIImage imageNamed:self.orderDetail.isShowTask ? @"jiantous.png" : @"jiantoux.png"];
            [detailCell.contentView addSubview:image];

            return detailCell;
        } else {
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [detailCell.contentView addSubview:arrowsImage];
            detailCell.detailLabel.frame = CGRectMake(160, (kTableView_DefaultCellHeight -kLabel_DefaultHeight)/2, 130, kLabel_DefaultHeight);
            TaskModel *task = self.orderDetail.ScdlList[indexPath.row -1];
            detailCell.textLabel.text = [NSString stringWithFormat:@"%ld %@", (long)indexPath.row, task.ResponsiblePersonName];
            detailCell.detailLabel.text = task.TaskScdlStartTime;
            return detailCell;
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = @"已完成服务记录";
            detailCell.detailTextLabel.text = @"";
            
            UIImageView * image = (UIImageView *)[detailCell.contentView viewWithTag:(indexPath.section+1000)];
            image.image = [UIImage imageNamed:self.orderDetail.isShowCompletion ? @"jiantous.png" : @"jiantoux.png"];
            [detailCell.contentView addSubview:image];
            

            return detailCell;
            
        } else {
            if (indexPath.row == 1 && self.orderDetail.PastCount > 0) {
                detailCell.textLabel.textColor = kColor_Black;
                detailCell.textLabel.text = @"过去完成次数";
                detailCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld次", (long)self.orderDetail.PastCount];
                return detailCell;
            } else {
                NSIndexPath *progressIndexPath = [self computeOrderProgressIndexPath:indexPath type:1];
                [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsMake(0, 310, 0, 0)];
                
                TreatmentGroup *treatGroup = [self.orderDetail.CompletionGroupList objectAtIndex:(indexPath.row-1-(self.orderDetail.PastCount >0 ?1 :0))/self.orderDetail.treatmentCount];
                
                if (progressIndexPath.row == 0) {
                    //时间  状态
                    Treatments  *treat = [treatGroup.TreatmentList objectAtIndex:progressIndexPath.row];
                    CGRect rect=progressCell.textLabel.frame;
                    rect.origin.x=5;
                    progressCell.textLabel.frame=rect;
                    progressCell.textLabel.text =treatGroup.StartTime;
                    progressCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[OrderDetailModel orderProgressStatus:treat.Status]];
                    
                } else if (progressIndexPath.row == 1) {
                    
                    progressCell.textLabel.text = treatGroup.ServicePicName;
                    CGRect rect=progressCell.textLabel.frame;
                    rect.origin.x=5;
                    progressCell.textLabel.frame=rect;
                    progressCell.detailTextLabel.text = @"";
                    UIImageView * arrowsImage = (UIImageView *)[progressCell.contentView viewWithTag:3000+indexPath.row];
                    if (!arrowsImage) {
                         arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
                        arrowsImage.tag = 3000+indexPath.row;
                        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                        [progressCell.contentView addSubview:arrowsImage];
                    }
                    
                } else {
                    Treatments  *treat = [treatGroup.TreatmentList objectAtIndex:(progressIndexPath.row -2 )];
                    progressCell.textLabel.text = [NSString stringWithFormat:@"    %@",treat.SubServiceName.length == 0 ? @"服务操作" : treat.SubServiceName];
                    progressCell.textLabel.textColor = kColor_Black;
                    progressCell.detailLabel.frame = CGRectMake(160, 0, 130,kTableView_DefaultCellHeight);
                    progressCell.detailLabel.text = treat.ExecutorName;
                    UIImageView * arrowsImage = (UIImageView *)[progressCell.contentView viewWithTag:3000+indexPath.row];
                    if (!arrowsImage) {
                        arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295,(kTableView_DefaultCellHeight -12 )/2, 10, 12)];
                        arrowsImage.tag = 4000+indexPath.row;
                        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                        [progressCell.contentView addSubview:arrowsImage];
                    }
                    if ([treat isEqual:[treatGroup.TreatmentList lastObject]]) {
                        [self setCellSpearatorInsetOfCell:progressCell separtorInset:UIEdgeInsetsZero];
                    }
                }
                return progressCell;
            }
        }
    }
    
    if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            detailCell.textLabel.text = @"备注";
            detailCell.detailTextLabel.text = @"";
        } else {
            detailCell.textLabel.text = self.orderDetail.Remark;
            detailCell.textLabel.textColor = kColor_Black;
            detailCell.textLabel.numberOfLines = 0;
            detailCell.detailTextLabel.text = @"";
        }
        return detailCell;
    }
    return detailCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 6 && indexPath.row == 1) {
        return self.orderDetail.remarkHeight;
    }
    if(indexPath.section ==1 && indexPath.row ==0)
    {
        NSInteger height = [self.orderDetail.ProductName sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width-35, 500) lineBreakMode:NSLineBreakByCharWrapping].height;
        
        
        return (height+20)<kTableView_DefaultCellHeight?kTableView_DefaultCellHeight:(height+20);
    }
    return kTableView_DefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section >= 3){
        return 0.00001;
    }else{
        return kTableView_Margin_Bottom;
    }
}

- (NSIndexPath *)computeOrderProgressIndexPath:(NSIndexPath *)indexPath type:(NSInteger)type
{
    __block NSInteger indexRow = indexPath.row - 1;
    __block NSIndexPath *progressIndexPath = nil;
    // type == 0 计算订单进度  type == 1 计算已完成的小单
    if (type == 0) {
        [self.orderDetail.GroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            if (indexRow - obj.treatCount < 0) {
                progressIndexPath = [NSIndexPath indexPathForRow:indexRow inSection:idx];
            } else {
                indexRow -= obj.treatCount;
            }
        }];
    } else {
        if (self.orderDetail.PastCount > 0) {
            indexRow --;
        }
        if (indexRow < 0) {
            return nil;
        }
        [self.orderDetail.CompletionGroupList enumerateObjectsUsingBlock:^(TreatmentGroup *obj, NSUInteger idx, BOOL *stop) {
            if (indexRow - obj.treatCount < 0) {
                progressIndexPath = [NSIndexPath indexPathForRow:indexRow inSection:idx];
            } else {
                indexRow -= obj.treatCount;
            }
        }];
    }
    return progressIndexPath;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;

    if (indexPath.section == 0 && indexPath.row == 0) {
        self.orderDetail.isShowFirst = !self.orderDetail.isShowFirst;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        self.orderDetail.isShowSecond = !self.orderDetail.isShowSecond;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self goToThePayHistory];
    }
    if (indexPath.section == 3 && indexPath.row > 0) {
        NSIndexPath *progressIndex = [self computeOrderProgressIndexPath:indexPath type:0];
        TreatmentGroup *progressGroup = [self.orderDetail.GroupList objectAtIndex:progressIndex.section];
        
        if (progressIndex.row == 1) {

            orderDoc.groupNo = progressGroup.GroupNo;
            [self gotoTreatmentGroupDetail];

        }
        if (progressIndex.row > 1) {
            
            Treatments  *treat = [progressGroup.TreatmentList objectAtIndex:(progressIndex.row -2 )];
            treatmentDoc_Selected = [[TreatmentDoc alloc] init];
            treatmentDoc_Selected.treat_ID = treat.TreatmentID;
            orderDoc.groupNo = progressGroup.GroupNo;

            [self performSegueWithIdentifier:@"goOrderTabBarFromOrderDetailView" sender:self];
        }
    }
    
    if (indexPath.section == 4 && indexPath.row == 0) {
        self.orderDetail.isShowTask = !self.orderDetail.isShowTask;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (indexPath.section == 4 && indexPath.row > 0) {

        AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
        detail.viewFor = 3 ;
        detail.LongID = [[[self.orderDetail.ScdlList objectAtIndex:indexPath.row - 1] valueForKey:@"TaskID"] longLongValue];
        [self.navigationController pushViewController:detail animated:YES];

        
    }
    if (indexPath.section == 5 ) {
        if (indexPath.row == 0) {
            self.orderDetail.isShowCompletion = !self.orderDetail.isShowCompletion;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            /**
            点击cell 滚动到tableView的最底层
             */
            [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX) animated:YES];
           
          
        } else {
            NSIndexPath *completionIndex = [self computeOrderProgressIndexPath:indexPath type:1];
            if (completionIndex == nil) {
                return;
            }
            TreatmentGroup *comGroup = [self.orderDetail.CompletionGroupList objectAtIndex:(indexPath.row-1-(self.orderDetail.PastCount >0 ?1 :0))/self.orderDetail.treatmentCount];
            
            if (completionIndex.row == 1) {
                orderDoc.groupNo = comGroup.GroupNo;
                [self gotoTreatmentGroupDetail];
            }
            if (completionIndex.row > 1) {
                Treatments  *treat = [comGroup.TreatmentList objectAtIndex:(completionIndex.row -2 )];
                treatmentDoc_Selected = [[TreatmentDoc alloc] init];
                treatmentDoc_Selected.treat_ID = treat.TreatmentID;
                orderDoc.groupNo = comGroup.GroupNo;
                [self performSegueWithIdentifier:@"goOrderTabBarFromOrderDetailView" sender:self];
            }
        }
    }
}
//跳转TG详情页

-(void)gotoTreatmentGroupDetail
{
    UITabBarController *tabBarController = [[TreatmentGroupTabbarController alloc] init];
    
    TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
    treatmentDetailViewController.treatMentOrGroup = 1;
    treatmentDetailViewController.OrderID =  orderDoc.order_ID;
    treatmentDetailViewController.GroupNo =orderDoc.groupNo;
    
    //review
    ZXServiceEffectViewController *serviceEffectVC = [tabBarController.viewControllers objectAtIndex:1];
    serviceEffectVC.OrderID =  orderDoc.order_ID;
    serviceEffectVC.GroupNo =orderDoc.groupNo;
    serviceEffectVC.treatMentOrGroup = 1;
    
    //review
    TreatmentGroupReview_ViewController *reviewVC = [tabBarController.viewControllers objectAtIndex:2];
    reviewVC.OrderID =  orderDoc.order_ID;
    reviewVC.GroupNo =orderDoc.groupNo;
    
    tabBarController.selectedIndex = 0;
    
    [self.navigationController pushViewController:tabBarController animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goContactDetailViewFromOrderDetailView"]) {
        ContactDetailViewController *contactController = segue.destinationViewController;
        contactController.contactDoc = contactDoc_Selected;
        
    } else if ([segue.identifier isEqualToString:@"goOrderTabBarFromOrderDetailView"]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
        treatmentDetailViewController.treatmentDoc = treatmentDoc_Selected;
        treatmentDetailViewController.GroupNo = orderDoc.groupNo;

        EffectDisplayViewController *effectDosplayeController = [tabBarController.viewControllers objectAtIndex:1];
        effectDosplayeController.treat_ID = treatmentDoc_Selected.treat_ID;
        effectDosplayeController.GroupNo = orderDoc.groupNo;
        
        TreatmentCommentViewController *treatmentCommentViewController = [tabBarController.viewControllers objectAtIndex:2];
        treatmentCommentViewController.treatmentComment.comment_TreatmentID = treatmentDoc_Selected.treat_ID;
        treatmentCommentViewController.orderId = orderDoc.order_ID;
        treatmentCommentViewController.GroupNo = orderDoc.groupNo;

    }else if ([segue.identifier isEqualToString:@"toReserveDetailSegue"]){
        ReservationDetailViewController *reserveDetailController = [segue destinationViewController];
        reserveDetailController.taskID = self.taskID;
    }

    treatmentDoc_Selected = nil;
}
- (void)changeOrderPayStatus:(id)sender
{
    
}
- (void)goToThePayHistory
{
    OrderPaymentDetailViewController *detailCon = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderPaymentDetailViewController"];
    detailCon.orderID = self.orderDetail.OrderID;
    detailCon.totalMoney = orderDoc.order_TotalSalePrice;
    [self.navigationController pushViewController:detailCon animated:YES];
}

#pragma mark - 接口
- (void)requestGetOrderDetailAboutServiceListByJson
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    NSDictionary *para = @{@"OrderObjectID":@(orderDoc.order_ObjectID),
                           @"ProductType":@0};
    _requestGetOrderDetailAboutServiceOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/order/getorderdetail"  showErrorMsg:YES  parameters:para
    
    WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.orderDetail = [[OrderDetailModel alloc] initWithDic:data];
            
            [self getTreatGroupByOrderObjectID];
            
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) {

        }];
    } failure:^(NSError *error) {
    
    }];

}

-(void)popViewController
{
    double delayInSeconds = 1.f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)getTreatGroupByOrderObjectID
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"OrderObjectID":@(orderDoc.order_ObjectID),
                           @"ProductType":@(orderDoc.order_Type),
                           @"Status":@(-1)};
    _requestGetTreatGroupByOrderObjectID = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetTreatGroupByOrderObjectID" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:NO
                  success:^(id data, NSInteger code, id message) {
                      NSMutableArray *array = [NSMutableArray array];
                      
                      [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                          [array addObject:[[TreatmentGroup alloc] initWithDic:obj]];
                      }];
                      
                      self.orderDetail.CompletionGroupList = [array copy];

                      [SVProgressHUD dismiss];

                  } failure:^(NSInteger code, NSString *error) {

                  }];
        //预约按钮
        [self initAppointmentButtonWithTableFooterView];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}
-(void)addPaymentIcon:(UITableViewCell *)twoLabelCell andOrigin:(CGFloat)Origin
{
    for (int i = 0; i < 4; i++) {
        UIImageView *imageView = (UIImageView *)[twoLabelCell viewWithTag:1010 + i];
        if (imageView)
            [twoLabelCell removeFromSuperview];
    }
    UIImage *ekaImage = [UIImage imageNamed:@"Eka.png"];
    UIImage *cashImage = [UIImage imageNamed:@"xianjin.png"];
    UIImage *bankImage = [UIImage imageNamed:@"yinhangka.png"];
    UIImage *otherImage = [UIImage imageNamed:@"otherPayment.png"];
    
    UIImageView *ekaView = [[UIImageView alloc] initWithImage:ekaImage];
    ekaView.tag = 1010;
    UIImageView *cashView = [[UIImageView alloc] initWithImage:cashImage];
    cashView.tag = 1011;
    UIImageView *bankView = [[UIImageView alloc] initWithImage:bankImage];
    bankView.tag = 1012;
    UIImageView *otherView = [[UIImageView alloc] initWithImage:otherImage];
    otherView.tag = 1013;
    
    bankView.contentMode = UIViewContentModeScaleAspectFit;
    ekaView.contentMode = UIViewContentModeScaleAspectFit;
    cashView.contentMode = UIViewContentModeScaleAspectFit;
    otherView.contentMode = UIViewContentModeScaleAspectFit;
    int i = 1;
    for (PayInfoDoc *payment in payment_Info) {
        if ([payment.pay_Mode integerValue] == 2) {
            bankView.frame = CGRectMake(Origin - 30 * i, 12, bankImage.size.width / 2, bankImage.size.height /2);
            [twoLabelCell.contentView addSubview:bankView];
            i++;
        }
    }
    for (PayInfoDoc *payment in payment_Info) {
        if ([payment.pay_Mode integerValue] == 1) {
            ekaView.frame = CGRectMake(Origin - 30 * i, 12, ekaImage.size.width / 2, ekaImage.size.height /2);
            [twoLabelCell.contentView addSubview:ekaView];
            i++;
        }
    }
    for (PayInfoDoc *payment in payment_Info) {
        if ([payment.pay_Mode integerValue] == 0) {
            cashView.frame = CGRectMake(Origin - 30 * i, 12, cashImage.size.width / 2, cashImage.size.height /2);
            [twoLabelCell.contentView addSubview:cashView];
            i++;
        }
    }
    for (PayInfoDoc *payment in payment_Info) {
        if ([payment.pay_Mode integerValue] == 3) {
            otherView.frame = CGRectMake(Origin - 30 * i, 12, otherImage.size.width / 2, otherImage.size.height /2);
            [twoLabelCell.contentView addSubview:otherView];
            i++;
        }
    }
}
// 配置NormalEditCell
- (NormalEditCell *)configNormalEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"NormalEditCell";
    NormalEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    return cell;
}

// 配置OrderDateCell
- (OrderDateCell *)configOrderDateCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderDateCell";
    OrderDateCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderDateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == [orderDoc.courseArray count] + 1) {
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    } else {
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)(indexPath.row -1)];
    }
    cell.timeText.userInteractionEnabled = NO;
    return cell;
}

// 配置OrderTreatmentCell
- (OrderTreatmentCell *)configOrderTreatmentCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"OrderTreatmentCell";
    OrderTreatmentCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[OrderTreatmentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    //cell.titleLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    return cell;
}

@end
