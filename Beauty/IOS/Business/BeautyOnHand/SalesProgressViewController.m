//
//  SalesProcessViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "SalesProgressViewController.h"
#import "OrderConfirmViewController.h"
#import "OpportunityDoc.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SVProgressHUD.h"
#import "ProgressDoc.h"
#import "NormalEditCell.h"
#import "DEFINE.h"
#import "ProgressEditViewController.h"
#import "NavigationView.h"
#import "ProductAndPriceView.h"
#import "ServiceDoc.h"
#import "CommodityDoc.h"
#import "UIButton+InitButton.h"
#import "FooterView.h"
#import "OppListViewController.h"
#import "InitialSlidingViewController.h"
#import "GPBHTTPClient.h"

@interface SalesProgressViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetOppportunityDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDeleteOpportunityOperation;

@property (strong, nonatomic) ProductAndPriceView *productAndPriceView;

@property (strong, nonatomic) OpportunityDoc *theOpportunityDoc;

@property (strong, nonatomic) ProgressDoc *progress_Selected;
@end

@implementation SalesProgressViewController
@synthesize theOpportunityDoc;
@synthesize progress_Selected;
@synthesize opportunityID;
@synthesize productType;
@synthesize responsibleName;
@synthesize responsibleID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestOpportunityDetail];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOppportunityDetailOperation && [_requestGetOppportunityDetailOperation isExecuting]) {
        [_requestGetOppportunityDetailOperation cancel];
    }
    
    if (_requestDeleteOpportunityOperation && [_requestDeleteOpportunityOperation isExecuting]) {
        [_requestDeleteOpportunityOperation cancel];
    }
    
    _requestGetOppportunityDetailOperation = nil;
    _requestDeleteOpportunityOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLayout];
}

- (void)initLayout
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"销售进度"];
    [self.view addSubview:navigationView];
    
    _tableView.allowsSelection = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
     if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (navigationView.frame.size.height + 5.0f) - 64.0f - 49.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (navigationView.frame.size.height + 5.0f) - 64.0f - 49.0f- 5.0f);
    }
    
        FooterView *footerView = [[FooterView alloc] initWithTarget:self
                                                          submitImg:[UIImage imageNamed:@"button_AddOrderFromOpp"]
                                                       submitAction:@selector(createOrderAction)
                                                          deleteImg:[UIImage imageNamed:@"button_CancelOpp"]
                                                       deleteAction:@selector(deleteOrderAction)];
        [footerView showInTableView:_tableView];
    
}

#pragma mark - Acton

- (void)createOrderAction
{
    OrderConfirmViewController *orderConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
    orderConfirmVC.theOpportunityDoc = theOpportunityDoc;
    orderConfirmVC.orderEditMode = OrderEditModeConfirm2;
    [self.navigationController pushViewController:orderConfirmVC animated:YES];
}

- (void)deleteOrderAction
{
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除该需求?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alterView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
             [self requestDeleteOpportunity];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString *cellIndentify = @"SalesProperyCell";
        NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"时间";
                cell.valueText.text = theOpportunityDoc.opp_UpdateTime;
                cell.valueText.userInteractionEnabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                [cell setAccessoryText:@""];
                
                return cell;
            }
            case 1:
            {
                cell.titleLabel.text = @"顾客";
                cell.valueText.text = theOpportunityDoc.customerName;
                cell.valueText.userInteractionEnabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                [cell setAccessoryText:@""];
                
                return cell;
                
            }
            case 2:
            {
                cell.titleLabel.text = @"美丽顾问";
                cell.valueText.text = theOpportunityDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonName;
                cell.valueText.userInteractionEnabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                [cell setAccessoryText:@""];
                
                return cell;
            }
            default:
                NSLog(@"the indexPath error %@",indexPath);
                return cell;
                break;
        }
    } else {
        static NSString *cellIndentify = @"SalesProgressCell";
        SalesProgressCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[SalesProgressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        [cell updateData:theOpportunityDoc];
        return cell;
    } 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSArray *stepContentArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
        return  40.0f * [stepContentArray count] + 50.0f ;
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 && theOpportunityDoc.productAndPriceDoc) {
         return theOpportunityDoc.productAndPriceDoc.table_Height;
    }
    return kTableView_Margin_Bottom;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 && theOpportunityDoc.productAndPriceDoc) {
        _productAndPriceView = [[ProductAndPriceView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 330.0f, theOpportunityDoc.productAndPriceDoc.table_Height)];
        [_productAndPriceView setTheProductAndPriceDoc:theOpportunityDoc.productAndPriceDoc];
        return _productAndPriceView;
    }
    return nil;
}

#pragma mark  - SalesProgressCellDelegate

- (void)chickStepButtonWithIndex:(NSInteger)index
{
    NSArray *stepContentArray = [theOpportunityDoc.opp_StepContent componentsSeparatedByString:@"|"];
    NSString *progressStr = [stepContentArray objectAtIndex:index -1];
   
    [theOpportunityDoc setOpp_Progress:index];
    [theOpportunityDoc setOpp_ProgressStr:progressStr];
    [self performSegueWithIdentifier:@"goProgressEditViewFromSalesProgressView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goProgressEditViewFromSalesProgressView"]) {
        ProgressEditViewController *progressEditVC = segue.destinationViewController;
        progressEditVC.oppInvalid = self.opportunityInvalid;
        progressEditVC.theOpportunityDoc = theOpportunityDoc;
    }
}

#pragma mark -- 接口

- (void)requestOpportunityDetail
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"OpportunityID\":%ld,\"ProductType\":%ld}", (long)opportunityID, (long)productType];

    _requestGetOppportunityDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/GetOpportunityDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            theOpportunityDoc = [[OpportunityDoc alloc] init];
            
            [theOpportunityDoc setOpp_ID:[((NSString *)[data objectForKey:@"OpportunityID"]) integerValue ]];
            [theOpportunityDoc setCustomerId:[((NSString *)[data objectForKey:@"CustomerID"]) integerValue ]];
            [theOpportunityDoc setCustomerName:(NSString *)[data objectForKey:@"CustomerName"]];
            [theOpportunityDoc setOpp_UpdateTime:(NSString *)[data objectForKey:@"CreateTime"]];
            [theOpportunityDoc setOpp_Progress:[((NSString *)[data objectForKey:@"Progress"]) integerValue]];
            [theOpportunityDoc setOpp_StepContent:(NSString *)[data objectForKey:@"StepContent"]];
            [theOpportunityDoc setOpp_BranchID:[((NSString *)[data objectForKey:@"BranchID"]) integerValue]];
            
            CGFloat  discount = [((NSString *)[data objectForKey:@"Discount"]) integerValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Discount = discount == 0 ? 1.0f : discount;
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ID = [((NSString *)[data objectForKey:@"ProductID"]) integerValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Code = [((NSString *)[data objectForKey:@"ProductCode"]) longLongValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Name = (NSString *)[data objectForKey:@"ProductName"];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Type = [((NSString *)[data objectForKey:@"ProductType"]) integerValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonID = [((NSString *)[data objectForKey:@"ResponsiblePersonID"]) integerValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity = [((NSString *)[data objectForKey:@"Quantity"]) integerValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney = [((NSString *)[data objectForKey:@"TotalOrigPrice"]) doubleValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalCalcPrice = [[data objectForKey:@"TotalCalcPrice"] doubleValue];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_Unitprice = [[NSString stringWithFormat:@"%.2Lf",(theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney/theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity)] doubleValue];
            //        oppDoc.productAndPriceDoc.productDoc.pro = [((NSString *)[dataDic objectForKey:@"TotalPrice"]) doubleValue ];
            //        TotalOriginalPrice
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_PromotionPrice = [((NSString *)[data objectForKey:@"PromotionPrice"]) doubleValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney = [((NSString *)[data objectForKey:@"TotalSalePrice"]) doubleValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ExpirationTime = (NSString *)[data objectForKey:@"ExpirationTime"];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_MarketingPolicy = [((NSString *)[data objectForKey:@"MarketingPolicy"]) doubleValue ];
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_CalculatePrice = [[NSString stringWithFormat:@"%.2Lf",(theOpportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney/theOpportunityDoc.productAndPriceDoc.productDoc.pro_quantity)] doubleValue];//[theOpportunityDoc.productAndPriceDoc.productDoc retCalculatePrice];
            [theOpportunityDoc.productAndPriceDoc initIsShowDiscountMoney];
            NSMutableArray *array1 = [NSMutableArray arrayWithObject:theOpportunityDoc.productAndPriceDoc.productDoc];
            theOpportunityDoc.productAndPriceDoc.productArray = array1;//GPB-922
            
            //GPB-1402 将该订单美丽顾问存入Model //GPB-2656  商机转订单后，订单的美丽顾问无值
            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonName = responsibleName;
//            theOpportunityDoc.productAndPriceDoc.productDoc.pro_ResponsiblePersonID = responsibleID;
            
            if ((ACC_BRANCHID == 0 ) || (ACC_BRANCHID != theOpportunityDoc.opp_BranchID) || !self.opportunityInvalid || ![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
                UIButton *button = (UIButton *)[_tableView.tableFooterView viewWithTag:801];
                [button removeFromSuperview];
                UIButton *button2 = (UIButton *)[_tableView.tableFooterView viewWithTag:802];
                button2.frame = CGRectMake(0.0f, 10.0f, 310.0f , 36.0f);
                if (IOS6) {
                    button2.frame = CGRectMake(10.0f, 10.0f, 310.0f , 36.0f);
                }
                [button2 setBackgroundImage:[UIImage imageNamed:@"button_OppCancel"] forState:UIControlStateNormal];
            }
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
  }

- (void)requestDeleteOpportunity
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"OpportunityID\":%ld}", (long)ACC_ACCOUNTID, (long)theOpportunityDoc.opp_ID];

    _requestDeleteOpportunityOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Opportunity/DeleteOpportunity" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        NSString *data = [json objectForKey:@"Code"];
        if ((NSNull *)data == [NSNull null]) {
            return;
        }

        if([data integerValue] == 1)
        {
            [SVProgressHUD showSuccessWithStatus2:@"删除商机成功！" duration:kSvhudtimer touchEventHandle:^{
                [self goToOppListViewController];
            }];
        } else {
            [SVProgressHUD showErrorWithStatus2:@"删除商机失败！" touchEventHandle:^{
            }];
        }

    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestDeleteOpportunityOperation = [[GPHTTPClient shareClient] requestJsonDeleteOpportunityWithOppId:theOpportunityDoc.opp_ID success:^(id xml) {
        [SVProgressHUD dismiss];
        NSString *origalString = (NSString*)xml;
         NSString *regexString = @"[{*}]";
         NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
         NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
         if(!array || [array count] < 2)
         return;
         origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
      
         NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
         NSString *data = [dataDic objectForKey:@"Code"];
         if ((NSNull *)data == [NSNull null]) {
             return;
         }
        if([data integerValue] == 1)
        {
            [SVProgressHUD showSuccessWithStatus2:@"删除商机成功！" duration:2.0 touchEventHandle:^{
                [self goToOppListViewController];
            }];
        } else {
            [SVProgressHUD showErrorWithStatus2:@"删除商机失败！" touchEventHandle:^{
            }];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}
-(void)goToOppListViewController
{
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OpportunityNavigation"];
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

@end
