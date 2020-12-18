//
//  FavoritesTableViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "GPBHTTPClient.h"
#import "PSListTableViewCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "CommodityOrServiceDoc.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "ServiceDetailViewController.h"
#import "ProductDetailViewController.h"
#import "OrderConfirmViewController.h"
#import "CategoryDoc.h"
#import "ServiceDoc.h"
#import "AppDelegate.h"
#import "CommodityDoc.h"
#import "UIButton+InitButton.h"
#import "UIImageView+WebCache.h"
#import "CusMainViewController.h"
#import "OrderConfirmViewController.h"

#define subwidth 65
@interface FavoritesTableViewController ()<UITableViewDelegate, UITableViewDataSource, PSListTableViewCellDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetFavouriteList;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDelFavouriteOpeartion;

@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (strong, nonatomic) NSMutableArray *service_SelectedArray;
@property (strong, nonatomic) NSMutableArray *commodityOrServiceArray;
@property (strong, nonatomic) NSMutableArray *commodityOrService_SelectedArray;
@property (strong, nonatomic) NSMutableArray *commodityArray;
@property (strong, nonatomic) NSMutableArray *commodity_SelectedArray;

@property (nonatomic, strong) NSMutableArray *tmpServiceArray;
@property (nonatomic, strong) NSMutableArray *tmpCommodityArray;
@property (nonatomic, strong) NSMutableArray *olderArray;

@end

@implementation FavoritesTableViewController
@synthesize serviceArray;
@synthesize service_SelectedArray;
@synthesize commodityOrServiceArray,commodity_SelectedArray,commodityArray,commodityOrService_SelectedArray;


- (NSMutableArray *)olderArray
{
    if (_olderArray == nil) {
        CusMainViewController *cusMain = (CusMainViewController *)[self parentViewController];
        _olderArray = cusMain.oldOrderList;
    }
    return _olderArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tmpServiceArray = [[NSMutableArray alloc] init];
    self.tmpCommodityArray = [[NSMutableArray alloc] init];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Favori"];
    
    [self.firstButton addTarget:self action:@selector(addOrderList) forControlEvents:UIControlEventTouchUpInside];
    [self.secondButton addTarget:self action:@selector(startOrder) forControlEvents:UIControlEventTouchUpInside];

    [self.firstButton setTitle:@"加入开单列表" forState:UIControlStateNormal];
    [self.secondButton setTitle:@"立即开单" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateData
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)addOrderList
{
    if ((self.tmpServiceArray.count + self.tmpCommodityArray.count) > 0) {
        if (self.tmpServiceArray.count) {
            [self.tmpServiceArray enumerateObjectsUsingBlock:^(ServiceDoc *obj, NSUInteger idx, BOOL *stop) {
                NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", obj.service_ID];
                NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:prdicate];
                if (array.count == 0) {
                    [service_SelectedArray addObject:obj];
                }
            }];
        }

        if (self.tmpCommodityArray.count) {
            [self.tmpCommodityArray enumerateObjectsUsingBlock:^(CommodityDoc *obj, NSUInteger idx, BOOL *stop) {
                NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", obj.comm_ID];
                NSArray *array = [commodity_SelectedArray filteredArrayUsingPredicate:prdicate];
                if (array.count == 0) {
                    [commodity_SelectedArray addObject:obj];
                }
            }];
        }
        [SVProgressHUD showSuccessWithStatus2:@"添加成功!" touchEventHandle:^{
            if ([self.parentViewController respondsToSelector:@selector(gotoAwaitOrderView)]) {
                [self.parentViewController performSelector:@selector(gotoAwaitOrderView)];
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择商品或者服务!" touchEventHandle:^{}];
    }

}

- (void)startOrder
{
    if (((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected == nil) {
        [SVProgressHUD showErrorWithStatus2:@"请选择顾客!" touchEventHandle:^{}];
        return;
    }
    if ((self.tmpCommodityArray.count + self.tmpServiceArray.count) > 0) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObjectsFromArray:[self.tmpServiceArray copy]];
        [array addObjectsFromArray:[self.tmpCommodityArray copy]];

        OrderConfirmViewController *orderCon = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
        orderCon.orderEditMode = OrderEditModeFavour;
        orderCon.favouritestList = array;
        [self.navigationController pushViewController:orderCon animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus2:@"请选择商品或者服务!" touchEventHandle:^{}];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commodityOrServiceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ProductListCell";
    PSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[PSListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.imageView.hidden = YES ;
        cell.titleLabel.frame = CGRectMake(70.0f- subwidth, 5.0f, 250.0f, 20.0f);
        cell.unitePriceLabel.frame = CGRectMake(215.0f- subwidth, 30.0f, 90.0f, 20.0f);
        cell.promotionPriceLabel.frame = CGRectMake(105.0f- subwidth, 30.0f, 110.0f, 20.0f);
        cell.newbrandImgView.hidden = YES;
        cell.recommendImgView.hidden = YES;
        [cell.favoriteImageView setHidden:YES];
        cell.titleLabel.numberOfLines = 1;
        cell.priceCategoryImageView.frame = CGRectMake(70.0f- subwidth, 31.5f, 17.0f, 17.0f);
        cell.selectedButton.frame = CGRectMake(19.0, 9.5, 36.0, 36.0);
    }
    if(((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0)//如果是服务构造服务cell，由于ServiceDoc和CommodityDoc两者结构差距很大，不太好再往上抽象，所有这么处理
    {
        ServiceDoc *ser = (ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        
       // [cell.imageView setImageWithURL:[NSURL URLWithString:ser.service_ImgURL] placeholderImage:[UIImage imageNamed:@"GoodsImg"]];

        
        [cell.titleLabel setText:[NSString stringWithFormat:@"%@", ser.service_ServiceName]];
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon,
                                       ser.service_UnitPrice]];
        [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ser.service_CalculatePrice]];
//        [cell.newbrandImgView  setHidden:!ser.service_NewBrand];
//        [cell.recommendImgView setHidden:!ser.service_Recommended];
      
        [cell setDelegate:self];
        [cell.unitePriceLabel setIsShowMidLine:YES];
        cell.unitePriceLabel.hidden = ser.service_UnitPrice == ser.service_CalculatePrice;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger customerId = appDelegate.customer_Selected.cus_ID;
        
        if (ser.service_MarketingPolicy == 0 || (ser.service_MarketingPolicy == 1 && customerId == 0) || (ser.service_UnitPrice == ser.service_CalculatePrice)) {
            cell.unitePriceLabel.hidden = YES;
            cell.priceCategoryImageView.hidden = YES;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
            cell.promotionPriceLabel.frame = CGRectMake(70.0f - subwidth, 30.0f, 120.0f, 20.0f);
        } else if (ser.service_MarketingPolicy == 1 && customerId != 0) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f- subwidth, 30.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f- subwidth + size.width + 10, 30.f, 90.f, 20.f)];
        } else if (ser.service_MarketingPolicy == 2) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f- subwidth, 30.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f- subwidth + size.width + 10, 30.0f, 90.f, 20.f)];
        }
        
//        CGRect frame = cell.titleLabel.frame;
//        CGSize size = [ser.service_ServiceName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 20.0f)];
//        if (size.height > 20) {
//            frame.size.height = 40.0f;
//            cell.titleLabel.frame = frame;
//            cell.titleLabel.numberOfLines = 0;
//        } else {
//            frame.size.height = 20.0f;
//            cell.titleLabel.frame = frame;
//            cell.titleLabel.numberOfLines = 1;
//        }
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_Code == %d", ser.service_Code];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", ser.service_ID]; //2014.9.9
        NSArray *array = [self.tmpServiceArray filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [cell.selectedButton setSelected:YES];
        } else {
            [cell.selectedButton setSelected:NO];
        }
        UIImageView *invalidImage = (UIImageView *)[cell viewWithTag:10000];
        if(!invalidImage)
            invalidImage = [[UIImageView alloc] init];
        invalidImage.frame = CGRectMake(0, 0, 55, 55);
        invalidImage.tag = 10000;
        invalidImage.image = [UIImage imageNamed:@"invalid.png"];
        [cell addSubview:invalidImage];
        if(ser.service_Available)
            invalidImage.hidden = YES;
        else
            invalidImage.hidden = NO;
        return cell;
    }
    
    else  //如果是商品构造商品cell
    {
        
        CommodityDoc *com = (CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        
//        CGRect frame = cell.titleLabel.frame;
//        CGSize size = [[NSString stringWithFormat:@"%@  %@", com.comm_CommodityName, com.comm_Specification] sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 40.0f)];
//        if (size.height > 20) {
//            frame.size.height = 40.0f;
//            cell.titleLabel.frame = frame;
//            cell.titleLabel.numberOfLines = 0;
//        } else {
//            frame.size.height = 20.0f;
//            cell.titleLabel.frame = frame;
//            cell.titleLabel.numberOfLines = 1;
//        }
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:com.comm_ImgURL] placeholderImage:[UIImage imageNamed:@"GoodsImg"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"%@  %@", com.comm_CommodityName , com.comm_Specification]];
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_UnitPrice]];
        [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, com.comm_CalculatePrice]];
        [cell.newbrandImgView setHidden:!com.comm_NewBrand];
        [cell.recommendImgView setHidden:!com.comm_Recommended];
        [cell.favoriteImageView setHidden:YES];
        [cell setDelegate:self];
        [cell.unitePriceLabel setIsShowMidLine:YES];
        
        cell.unitePriceLabel.hidden = com.comm_UnitPrice == com.comm_CalculatePrice;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger customerId = appDelegate.customer_Selected.cus_ID;
        
        if (com.comm_MarketingPolicy == 0 ||(com.comm_MarketingPolicy == 1 && customerId == 0) || (com.comm_UnitPrice == com.comm_CalculatePrice)) {
            cell.unitePriceLabel.hidden = YES;
            cell.priceCategoryImageView.hidden = YES;
            cell.promotionPriceLabel.frame = CGRectMake(70.0f- subwidth, 30.0f, 120.0f, 20.0f);
        } else if (com.comm_MarketingPolicy == 1 && customerId != 0) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f- subwidth, 30.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f - subwidth+ size.width + 10, 30.0f, 90.f, 20.f)];
        } else if (com.comm_MarketingPolicy == 2) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f- subwidth, 30.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f - subwidth+ size.width + 10, 30.0f, 80.f, 20.f)];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", com.comm_ID];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_Code == %d", com.comm_Code];
        NSArray *array = [self.tmpCommodityArray filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [cell.selectedButton setSelected:YES];
        } else {
            [cell.selectedButton setSelected:NO];
        }
        UIImageView *invalidImage = (UIImageView *)[cell viewWithTag:10000];
        if(!invalidImage)
            invalidImage = [[UIImageView alloc] init];
        invalidImage.frame = CGRectMake(0, 0, 55, 55);
        invalidImage.tag = 10000;
        invalidImage.image = [UIImage imageNamed:@"invalid.png"];
        [cell addSubview:invalidImage];
        if(com.comm_Available)
            invalidImage.hidden = YES;
        else
            invalidImage.hidden = NO;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([commodityOrServiceArray count] < indexPath.row) {
        return;
    }
    if(((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0
       && ((ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).service_Available == YES )//服务跳转到ServiceDetailViewController
    {
        ServiceDoc *serviceDoc = (ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        ServiceDetailViewController *serviceDetailVC =[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
        serviceDetailVC.serviceCode = serviceDoc.service_Code;
        serviceDetailVC.isShowFavourites = YES;
        [self.navigationController pushViewController:serviceDetailVC animated:YES];
    }
    else if( ((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 1
            && ((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_Available == YES)
    {//商品跳转到ProductDetailViewController
        CommodityDoc *commodityDoc = (CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        ProductDetailViewController *productDetailVC =[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
        productDetailVC.commodityCode = commodityDoc.comm_Code;
        productDetailVC.isShowFavourites = YES;
        [self.navigationController pushViewController:productDetailVC animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该商品/服务已下架，确定要将其从收藏列表中删除？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (((CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0) {
                    [self requestDelFavourite:((ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).service_FavouriteID];
                }else
                    [self requestDelFavourite:((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_FavouriteID];
                if ([commodityOrServiceArray containsObject:(CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]]) {
                    [commodityOrServiceArray removeObject:(CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]];
                    [self.tableView reloadData];
                }
            }
        }];
    }
}

#pragma mark - PSListTableViewCellDelegate

- (void)didSelectedButtonInCell:(PSListTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self addOrRemoveCommodityInCommodity_SelectedArray:indexPath];
}


- (void)addOrRemoveCommodityInCommodity_SelectedArray:(NSIndexPath *)indexPath
{
    
    if(((CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0
       &&  ((ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).service_Available == YES )//服务
    {
        ServiceDoc *serviceDoc = (ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        //在服务选择列表选择或者去选
        
        //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_Code == %d", serviceDoc.service_Code];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", serviceDoc.service_ID]; //2014.9.9
//        NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:predicate];
        NSArray *array = [self.tmpServiceArray filteredArrayUsingPredicate:predicate];

        if ([array count] > 0) {
            [self.tmpServiceArray removeObject:[array objectAtIndex:0]];
        } else {
            [self.tmpServiceArray addObject:serviceDoc];
        }
        //在收藏选择列表选择或者去选
        //  NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.service_Code == %d", serviceDoc.service_Code];
        
        /*
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.service_ID == %d", serviceDoc.service_ID]; //2014.9.9
        NSArray *array1 = [commodityOrService_SelectedArray filteredArrayUsingPredicate:predicate1];
        if ([array1 count] > 0) {
            [commodityOrService_SelectedArray removeObject:[array1 objectAtIndex:0]];
        } else {
            [commodityOrService_SelectedArray addObject:(CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]];
        }
         */
        
    }else if (((CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 1
              && ((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_Available == YES )//商品
    {
        CommodityDoc *commodityDoc = (CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        //在商品选择列表选择或者去选
        
        //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_Code == %d", commodityDoc.comm_Code];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", commodityDoc.comm_ID]; //2014.9.9
//        NSArray *array = [commodity_SelectedArray filteredArrayUsingPredicate:predicate];
        NSArray *array = [self.tmpCommodityArray filteredArrayUsingPredicate:predicate];

        if ([array count] > 0) {
            [self.tmpCommodityArray removeObject:[array objectAtIndex:0]];
        } else {
            [self.tmpCommodityArray addObject:commodityDoc];
        }
        //在收藏选择列表选择或者去选
        //  NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.comm_Code == %d", commodityDoc.comm_Code];
        /*
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.comm_ID == %d", commodityDoc.comm_ID]; //2014.9.9
        NSArray *array1 = [commodityOrService_SelectedArray filteredArrayUsingPredicate:predicate1];
        if ([array1 count] > 0) {
            [commodityOrService_SelectedArray removeObject:[array1 objectAtIndex:0]];
        } else {
            [commodityOrService_SelectedArray addObject:(CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]];
        }
        */
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该商品/服务已下架，\n确定要将其从收藏列表中删除？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (((CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0) {
                    [self requestDelFavourite:((ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).service_FavouriteID];
                }else
                    [self requestDelFavourite:((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_FavouriteID];
                if ([commodityOrServiceArray containsObject:(CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]]) {
                    [commodityOrServiceArray removeObject:(CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]];
                    [self.tableView reloadData];
                }
            }
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 接口

- (void)request
{
    if (commodityOrServiceArray)
        [commodityOrServiceArray removeAllObjects];
    else
        commodityOrServiceArray = [NSMutableArray array];
    
    if(serviceArray)
        [serviceArray removeAllObjects];
    else
        serviceArray = [NSMutableArray array];
    
    if(commodityArray)
        [commodityArray removeAllObjects];
    else
        commodityArray = [NSMutableArray array];
    
    [self requstGetFavouriteList];
    
}

-(void)requestDelFavourite:(NSInteger)favouriteID
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear ];
    
    NSString *par = [NSString stringWithFormat:@"{\"FavoriteID\":%ld}", (long)favouriteID];
    
    _requestDelFavouriteOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/delFavorite" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)requstGetFavouriteList
{
    NSInteger productType = -1;
    if ([[PermissionDoc sharePermission] rule_Service_Read] && ![[PermissionDoc sharePermission] rule_Commodity_Read]) {
        productType = 0;
    }else if(![[PermissionDoc sharePermission] rule_Service_Read] && [[PermissionDoc sharePermission] rule_Commodity_Read])
        productType = 1;
    else if(![[PermissionDoc sharePermission] rule_Service_Read] && ![[PermissionDoc sharePermission] rule_Commodity_Read])
        return;
    if (![SVProgressHUD isVisible])
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ProductType\":%ld}", (long)customerId, (long)productType];
    
        
    _requestGetFavouriteList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/getFavoriteList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            self.view.userInteractionEnabled = NO;
            if (serviceArray) {
                [serviceArray removeAllObjects];
            } else {
                serviceArray = [NSMutableArray array];
            }
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSInteger type = [[obj objectForKey:@"ProductType"] integerValue];
                if (type ==0) {
                    ServiceDoc *service = [[ServiceDoc alloc] initWithDictionary:obj];
                    [service setCustomer_ID:customerId];
                    [serviceArray addObject:service];
                    
                    
                    CommodityOrServiceDoc *newCommodityOrService = [[CommodityOrServiceDoc alloc]init];
                    newCommodityOrService.productType = 0;
                    newCommodityOrService.commodityOrService = service;
                    if(!service.service_Available) //如果该服务不可用，但已有服务被选中，则删除
                    {
                        for(int i = 0; i<[service_SelectedArray count] ;i++) {
                            if(((ServiceDoc *)[service_SelectedArray objectAtIndex:i]).service_ID == service.service_ID)
                                [service_SelectedArray removeObjectAtIndex:i];
                        }
                        for(int i = 0; i<[commodityOrService_SelectedArray count] ;i++) {
                            if(((ServiceDoc *)((CommodityOrServiceDoc *)[commodityOrService_SelectedArray objectAtIndex:i]).commodityOrService).service_ID == service.service_ID)
                                [commodityOrService_SelectedArray removeObjectAtIndex:i];
                        }
                    }
                    [commodityOrServiceArray addObject:newCommodityOrService];
                    
                } else {
                    CommodityDoc *commodityDoc = [[CommodityDoc alloc] init];
                    [commodityDoc setComm_FavouriteID:[[obj objectForKey:@"ID"]integerValue]];
                    [commodityDoc setComm_ID:[[obj objectForKey:@"ProductID"] integerValue]];
                    [commodityDoc setComm_Code:[[obj objectForKey:@"ProductCode"]longLongValue]];
                    [commodityDoc setComm_CommodityName:[obj objectForKey:@"ProductName"]];
                    [commodityDoc setComm_UnitPrice:[[obj objectForKey:@"UnitPrice"] doubleValue]];
                    [commodityDoc setComm_PromotionPrice:[[obj objectForKey:@"PromotionPrice"] doubleValue]];
                    [commodityDoc setComm_NewBrand:[[obj objectForKey:@"New"] intValue]];
                    [commodityDoc setComm_Recommended:[[obj objectForKey:@"Recommended"] intValue]];
                    [commodityDoc setComm_Specification:[obj objectForKey:@"Specification"] ];
                    [commodityDoc setComm_MarketingPolicy:[[obj objectForKey:@"MarketingPolicy"] intValue]];
                    [commodityDoc setComm_ImgURL:[obj objectForKey:@"FileUrl"]];
                    [commodityDoc setComm_Available:[[obj objectForKey:@"Available"]boolValue]];
                    [commodityDoc setCustomer_ID:customerId];
                    
                    [commodityArray addObject:commodityDoc];
                    
                    CommodityOrServiceDoc *newCommodityOrService = [[CommodityOrServiceDoc alloc]init];
                    newCommodityOrService.productType = 1;
                    newCommodityOrService.commodityOrService = commodityDoc;
                    if(!commodityDoc.comm_Available)  //如果该商品不可用，但已有商品被选中，则删除
                    {
                        for(int i = 0; i<[commodity_SelectedArray count] ;i++) {
                            if(((CommodityDoc *)[commodity_SelectedArray objectAtIndex:i]).comm_ID == commodityDoc.comm_ID)
                                [commodity_SelectedArray removeObjectAtIndex:i];
                        }
                        for(int i = 0; i<[commodityOrService_SelectedArray count] ;i++) {
                            if(((CommodityDoc *)((CommodityOrServiceDoc *)[commodityOrService_SelectedArray objectAtIndex:i]).commodityOrService).comm_ID == commodityDoc.comm_ID)
                                [commodityOrService_SelectedArray removeObjectAtIndex:i];
                        }
                    }
                    [commodityOrServiceArray addObject:newCommodityOrService];
                    
                }
                
            }];
            
            service_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] serviceArray_Selected];
            commodity_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] commodityArray_Selected];
            self.tmpServiceArray = [[NSMutableArray alloc] init];
            self.tmpCommodityArray = [[NSMutableArray alloc] init];
            
            [service_SelectedArray enumerateObjectsUsingBlock:^(ServiceDoc *obj, NSUInteger idx, BOOL *stop) {
                NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", obj.service_ID];
                NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:prdicate];
                if (array.count) {
                    [self.tmpServiceArray addObject:obj];
                }
            }];
            
            [commodity_SelectedArray enumerateObjectsUsingBlock:^(CommodityDoc *obj, NSUInteger idx, BOOL *stop) {
                NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", obj.comm_ID];
                NSArray *array = [commodity_SelectedArray filteredArrayUsingPredicate:prdicate];
                if (array.count) {
                    [self.tmpCommodityArray addObject:obj];
                }
            }];
            
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:0];
            self.view.userInteractionEnabled = YES;
            self.title = [NSString stringWithFormat:@"收藏(%lu)", (unsigned long)self.commodityOrServiceArray.count];
            [self.parentViewController performSelector:@selector(updateButtonFieldTitle)];

            [self.tableView reloadData];
            
        }
                          failure:^(NSInteger code, NSString *error) {
                              [SVProgressHUD dismiss];
                              self.view.userInteractionEnabled = YES;
                          }];
    } failure:^(NSError *error) {
        self.view.userInteractionEnabled = YES;
        
    }];
}
@end
