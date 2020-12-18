//
//  CustomerBasicViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "CustomerDetailEditController.h"
#import "CustomerDoc.h"
#import "CacheInDisk.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "ContentEditCell.h"

#import "NavigationView.h"
#import "GPBHTTPClient.h"

@interface CustomerDetailViewController ()
@property (strong, nonatomic) AFHTTPRequestOperation *requestCustomerDetailOperation;
@property (strong, nonatomic) CustomerDoc *customer;

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *valueArray;

@end

@implementation CustomerDetailViewController
@synthesize customer;
@synthesize titleArray, valueArray;

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
    
#pragma mark 权限--顾客
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.customer_Selected.editStatus & CustomerEditStatusBasic)  { //[[PermissionDoc sharePermission] rule_CustomerInfo_Write]
        [self requestDetailInfo];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestCustomerDetailOperation || [_requestCustomerDetailOperation isExecuting]) {
        [_requestCustomerDetailOperation cancel];
        _requestCustomerDetailOperation = nil;
    }
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"详细信息"];
    [self.view addSubview:navigationView];

#pragma mark 权限--顾客
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.customer_Selected.editStatus & CustomerEditStatusBasic)  { //[[PermissionDoc sharePermission] rule_CustomerInfo_Write]
        [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(editCustomerDetailAction)];
    }
    
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView  = nil;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f );
        _tableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f );
    }
}

- (void)editCustomerDetailAction
{
    [self performSegueWithIdentifier:@"goCustomerDetailEditViewFromCustomerDetailView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goCustomerDetailEditViewFromCustomerDetailView"]) {
        CustomerDetailEditController *customerDetailEditController = segue.destinationViewController;
        customerDetailEditController.customer = customer;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [valueArray count];
    } else {
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([customer.cus_Remark length] > 0 ? 2 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *titleString = [titleArray objectAtIndex:indexPath.row];
        NSString *valueString = [valueArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [self configCell:tableView titleStr:titleString valueStr:valueString];
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [self configCell:tableView titleStr:@"备注" valueStr:@""];
            return cell;
        } else {
            ContentEditCell *cell = [self configContentEditCell:tableView cellForRowAtIndexPath:indexPath];
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:customer.cus_Remark];
            return cell;
        }
    }
    return nil;
}

- (UITableViewCell *)configCell:(UITableView *)tableView titleStr:(NSString *)titleStr valueStr:(NSString *)valueStr
{
    static NSString *cellIdentifier = @"detailInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
       
    }
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:101];
    [titleLable setFont:kFont_Light_16];
    [valueLabel setFont:kFont_Light_16];
    [titleLable setTextColor:kColor_DarkBlue];
    [valueLabel setTextColor:[UIColor blackColor]];
    [titleLable setFrame:CGRectMake(10.0f, 4.0f, 100.0f, 30.0f)];
    [valueLabel setFrame:CGRectMake(40.0f, 4.0f, 255.0f, 30.0f)];
    [titleLable setText:titleStr];
    [valueLabel setText:valueStr];
    return cell;
}

- (ContentEditCell *)configContentEditCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *cellIdentity = @"Cell_RemindContent";
    ContentEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    cell.contentEditText.userInteractionEnabled = NO;
    cell.contentEditText.textColor = [UIColor blackColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return customer.cell_Remark_Height;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark - 接口

- (void)requestDetailInfo
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    if (customerId == 0 && kMenu_Type == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择顾客" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }

    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)customerId];

    _requestCustomerDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            customer = [[CustomerDoc alloc] init];

            [customer setCus_ID:[[data objectForKey:@"CustomerID"] integerValue]];
            [customer setCus_Name:[data objectForKey:@"CustomerName"] == [NSNull null] ? @"" :[data objectForKey:@"CustomerName"]];
            [customer setCus_Height:([data objectForKey:@"Height"] == [NSNull null] ? 0: [[data objectForKey:@"Height"] floatValue])];
            [customer setCus_Weight:([data objectForKey:@"Weight"] == [NSNull null] ? 0: [[data objectForKey:@"Weight"] floatValue])];
            [customer setCus_BloodType:[data objectForKey:@"BloodType"] == [NSNull null] ? nil: [data objectForKey:@"BloodType"]];
            [customer setCus_BirthDay:[data objectForKey:@"BirthDay"] == [NSNull null] ? @"":[data objectForKey:@"BirthDay"]];
            [customer setCus_Profession:[data objectForKey:@"Profession"] == [NSNull null] ? @"":[data objectForKey:@"Profession"]];
            [customer setCus_Remark:[data objectForKey:@"Remark"] == [NSNull null] ? @"":[data objectForKey:@"Remark"]];

            
            if (valueArray != nil)
                [valueArray removeAllObjects];
            else
                valueArray = [[NSMutableArray alloc] init];
            
            if (titleArray != nil)
                [titleArray removeAllObjects];
            else
                titleArray = [[NSMutableArray alloc] init];
            
            if ([data objectForKey:@"Gender"] == [NSNull null] || [[data objectForKey:@"Gender"]isEqual: @""]) {
                [customer setCus_Gender:-1];
            }
//            if ([data objectForKey:@"Gender"] != [NSNull null] && ![[data objectForKey:@"Gender"] isEqual: @""]) {
//                customer.cus_Gender = [[data objectForKey:@"Gender"] integerValue];
//                [valueArray addObject:[NSString stringWithFormat:@"%@", customer.cus_Gender == 1 ? @"男" : @"女"]];
//                [titleArray addObject:@"性别"];
//            }
            if ( customer.cus_BirthDay.length > 0) {
                if ([customer.cus_BirthDay hasPrefix:@"2104-"]) {
                    NSMutableString *temp = [[NSMutableString alloc]initWithString:customer.cus_BirthDay];
                    [temp deleteCharactersInRange:NSMakeRange(0,5)];
                    customer.cus_BirthDay = temp;
                }
                [valueArray addObject:customer.cus_BirthDay];
                [titleArray addObject:@"出生日期"];
            }
            if (customer.cus_Height > 0) {
                if (customer.cus_Height != 0.0f) {
                    [valueArray addObject:[NSString stringWithFormat:@"%.1f", customer.cus_Height]];
                    [titleArray addObject:@"身高（厘米）"];
                }
            }
        
            if ( customer.cus_Weight > 0) {
                if (customer.cus_Weight != 0.0f) {
                    [valueArray addObject:[NSString stringWithFormat:@"%.1f", customer.cus_Weight]];
                    [titleArray addObject:@"体重（公斤）"];
                }
            }
            if (customer.cus_BloodType.length > 0) {
                [valueArray addObject:customer.cus_BloodType];
                [titleArray addObject:@"血型"];
            }
            if ([data objectForKey:@"Marriage"] == [NSNull null] ) {
                [customer setCus_Marriage:-1];
            }
            
            if ([data objectForKey:@"Marriage"]!= [NSNull null] && customer.cus_Marriage != -1) {
                customer.cus_Marriage = [[data objectForKey:@"Marriage" ]integerValue];
                [valueArray addObject:[NSString stringWithFormat:@"%@", customer.cus_Marriage == 0 ? @"未婚" : @"已婚"]];
                [titleArray addObject:@"婚姻状况"];
            }
            if ( customer.cus_Profession.length > 0) {
                [valueArray addObject:customer.cus_Profession];
                [titleArray addObject:@"职业"];
            }
            
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {}];
        
    } failure:^(NSError *error) {
   
    }];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    _requestCustomerDetailOperation = [[GPHTTPClient shareClient] requestGetCustomerDetailInfoWithCustomerId:customerId success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD dismiss];
         //   if (customer == nil){
                customer = [[CustomerDoc alloc] init];
           // }
            [customer setCus_ID:[[[[contentData elementsForName:@"CustomerID"] objectAtIndex:0] stringValue] integerValue]];
            [customer setCus_Name:[[[contentData elementsForName:@"CustomerName"] objectAtIndex:0] stringValue]];
            [customer setCus_Height:[[[[contentData elementsForName:@"Height"] objectAtIndex:0] stringValue] floatValue]];
            [customer setCus_Weight:[[[[contentData elementsForName:@"Weight"] objectAtIndex:0] stringValue] floatValue]];
            [customer setCus_BloodType:[[[contentData elementsForName:@"BloodType"] objectAtIndex:0] stringValue]];
            [customer setCus_BirthDay:[[[contentData elementsForName:@"BirthDay"] objectAtIndex:0] stringValue]];
            [customer setCus_Profession:[[[contentData elementsForName:@"Profession"] objectAtIndex:0] stringValue]];
            [customer setCus_Remark:[[[contentData elementsForName:@"Remark"] objectAtIndex:0] stringValue]];
            
            if (valueArray != nil)
                [valueArray removeAllObjects];
            else
                valueArray = [[NSMutableArray alloc] init];
            
            if (titleArray != nil)
                [titleArray removeAllObjects];
            else
               titleArray = [[NSMutableArray alloc] init];
            
            if ([[[contentData elementsForName:@"Gender"] objectAtIndex:0] stringValue] == nil || [[[[contentData elementsForName:@"Gender"] objectAtIndex:0] stringValue] isEqual: @""]) {
                [customer setCus_Gender:-1];
            }
            if ([[[contentData elementsForName:@"Gender"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"Gender"] objectAtIndex:0] stringValue] isEqual: @""]) {
                customer.cus_Gender = [[[[contentData elementsForName:@"Gender"] objectAtIndex:0] stringValue] integerValue];
                [valueArray addObject:[NSString stringWithFormat:@"%@", customer.cus_Gender == 1 ? @"男" : @"女"]];
                [titleArray addObject:@"性别"];
            }
            if ([[[contentData elementsForName:@"BirthDay"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"BirthDay"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                [valueArray addObject:customer.cus_BirthDay];
                [titleArray addObject:@"出生日期"];
            }
            if ([[[contentData elementsForName:@"Height"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"Height"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                if (customer.cus_Height != 0.0f) {
                    [valueArray addObject:[NSString stringWithFormat:@"%.1f", customer.cus_Height]];
                    [titleArray addObject:@"身高（厘米）"];
                }
            }
            if ([[[contentData elementsForName:@"Weight"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"Weight"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                if (customer.cus_Weight != 0.0f) {
                    [valueArray addObject:[NSString stringWithFormat:@"%.1f", customer.cus_Weight]];
                    [titleArray addObject:@"体重（公斤）"];
                }
            }
            if ([[[contentData elementsForName:@"BloodType"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"BloodType"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                [valueArray addObject:customer.cus_BloodType];
                [titleArray addObject:@"血型"];
            }
            if ([[[contentData elementsForName:@"Marriage"] objectAtIndex:0] stringValue] == nil || [[[[contentData elementsForName:@"Marriage"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                [customer setCus_Marriage:-1];
            }
            if ([[[contentData elementsForName:@"Marriage"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"Marriage"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                customer.cus_Marriage = [[[[contentData elementsForName:@"Marriage"] objectAtIndex:0] stringValue] integerValue];
                [valueArray addObject:[NSString stringWithFormat:@"%@", customer.cus_Marriage == 0 ? @"未婚" : @"已婚"]];
                [titleArray addObject:@"婚姻状况"];
            }
            if ([[[contentData elementsForName:@"Profession"] objectAtIndex:0] stringValue] != nil && ![[[[contentData elementsForName:@"Profession"] objectAtIndex:0] stringValue]  isEqual: @""]) {
                [valueArray addObject:customer.cus_Profession];
                [titleArray addObject:@"职业"];
            }
            
            [_tableView reloadData];
        } failure:^{
        }];
    } failure:^(NSError *error) {}];
     */
}

@end
