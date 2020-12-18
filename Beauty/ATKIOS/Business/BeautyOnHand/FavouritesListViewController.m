//
//  FavouritesListViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-8-11.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//note: 该viewcontroller是在ServiceListViewController和ProductListViewController基础上合并而来，
//其中，添加了commodityOrServiceArray，commodityOrService_SelectedArray两个数组以及相关数据结构，
//同时，serviceArray和commodityArray也还在使用，用于和其他两个页面同步和协作，当点击详情时候，分别跳转到
//ServiceDetailViewController和ProductDetailViewController


#import "FavouritesListViewController.h"
#import "ServiceDetailViewController.h"
#import "ProductDetailViewController.h"
#import "OrderConfirmViewController.h"
#import "CategoryDoc.h"
#import "ServiceDoc.h"
#import "AppDelegate.h"
#import "CommodityDoc.h"
#import "UIButton+InitButton.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "UIImageView+WebCache.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "GPBHTTPClient.h"

@interface FavouritesListViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetFavouriteList;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDelFavouriteOpeartion;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NavigationView *navigationView;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (strong, nonatomic) NSMutableArray *service_SelectedArray;
@property (strong, nonatomic) NSMutableArray *commodityOrServiceArray;
@property (strong, nonatomic) NSMutableArray *commodityOrService_SelectedArray;
@property (strong, nonatomic) NSMutableArray *commodityArray;
@property (strong, nonatomic) NSMutableArray *commodity_SelectedArray;
@property (assign, nonatomic) BOOL isSearching;

@end

@implementation FavouritesListViewController
@synthesize serviceArray;
@synthesize isSearching;
@synthesize service_SelectedArray;
@synthesize commodityOrServiceArray,commodity_SelectedArray,commodityArray,commodityOrService_SelectedArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];;
    
    
    if (_requestGetFavouriteList && [_requestGetFavouriteList isExecuting]) {
        [_requestGetFavouriteList cancel];
    }
    
    _requestGetFavouriteList = nil;
    
    if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self request];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLayOut];
}

- (void)initLayOut
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    _searchBar.tintColor = kColor_Background_View;
    _searchBar.placeholder = @"来搜索你想要找的服务项目吧!";
    _searchBar.hidden = YES;
    _searchBar.frame = CGRectMake(0.0f, kORIGIN_Y -44.0f, kSCREN_BOUNDS.size.width, 44.0f);
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    if ((IOS7 || IOS8)) _searchBar.barTintColor = kColor_Background_View;
    
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f)
                                                         title:[NSString stringWithFormat:@"我的收藏"]];
    // [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Search"] selector:@selector(searchAction)];
    [self.view addSubview:_navigationView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f) style:UITableViewStylePlain];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
}

- (void)searchAction
{
    if (_searchBar.isHidden) {
        _searchBar.hidden = NO;
        
        [UIView beginAnimations:@"" context:nil];
        _searchBar.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        _navigationView.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        _tableView.transform = CGAffineTransformMakeTranslation(0.0f, 44.0f);
        
        CGRect rect = _tableView.frame;
        rect.size.height -= 44.0f;
        _tableView.frame = rect;
        [UIView commitAnimations];
        
    } else {
        
        [_searchBar resignFirstResponder];
        [_searchBar setText:@""];
        [_searchBar setHidden:YES];
        
        isSearching = NO;
        
        [UIView beginAnimations:@"" context:nil];
        _searchBar.transform = CGAffineTransformIdentity;
        _navigationView.transform = CGAffineTransformIdentity;
        _tableView.transform = CGAffineTransformIdentity;
        
        CGRect rect = _tableView.frame;
        rect.size.height += 44.0f;
        _tableView.frame = rect;
        
        [UIView commitAnimations];    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

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
    }
    if(((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 0)//如果是服务构造服务cell，由于ServiceDoc和CommodityDoc两者结构差距很大，不太好再往上抽象，所有这么处理
    {
        ServiceDoc *ser = (ServiceDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:ser.service_ImgURL] placeholderImage:[UIImage imageNamed:@"GoodsImg"]];
        [cell.titleLabel setText:[NSString stringWithFormat:@"%@", ser.service_ServiceName]];
        [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ser.service_UnitPrice]];
        [cell.promotionPriceLabel setText:[NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, ser.service_CalculatePrice]];
        [cell.newbrandImgView  setHidden:!ser.service_NewBrand];
        [cell.recommendImgView setHidden:!ser.service_Recommended];
        [cell.favoriteImageView setHidden:YES];
        [cell setDelegate:self];
        [cell.unitePriceLabel setIsShowMidLine:YES];
        
        cell.unitePriceLabel.hidden = ser.service_UnitPrice == ser.service_CalculatePrice;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger customerId = appDelegate.customer_Selected.cus_ID;
        
        if (ser.service_MarketingPolicy == 0 || (ser.service_MarketingPolicy == 1 && customerId == 0) || (ser.service_UnitPrice == ser.service_CalculatePrice)) {
            cell.unitePriceLabel.hidden = YES;
            cell.priceCategoryImageView.hidden = YES;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
            cell.promotionPriceLabel.frame = CGRectMake(70.0f, 45.0f, 120.0f, 20.0f);
        } else if (ser.service_MarketingPolicy == 1 && customerId != 0) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf",
                                           ser.service_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
        } else if (ser.service_MarketingPolicy == 2) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", ser.service_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
        }
        
        CGRect frame = cell.titleLabel.frame;
        CGSize size = [ser.service_ServiceName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 40.0f)];
        if (size.height > 20) {
            frame.size.height = 40.0f;
            cell.titleLabel.frame = frame;
            cell.titleLabel.numberOfLines = 0;
        } else {
            frame.size.height = 20.0f;
            cell.titleLabel.frame = frame;
            cell.titleLabel.numberOfLines = 1;
        }
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_Code == %d", ser.service_Code];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.service_ID == %d", ser.service_ID]; //2014.9.9
        NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:predicate];
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
        
        CGRect frame = cell.titleLabel.frame;
        CGSize size = [[NSString stringWithFormat:@"%@  %@", com.comm_CommodityName, com.comm_Specification] sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(200.0f, 40.0f)];
        if (size.height > 20) {
            frame.size.height = 40.0f;
            cell.titleLabel.frame = frame;
            cell.titleLabel.numberOfLines = 0;
        } else {
            frame.size.height = 20.0f;
            cell.titleLabel.frame = frame;
            cell.titleLabel.numberOfLines = 1;
        }
        
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
            cell.promotionPriceLabel.frame = CGRectMake(70.0f, 45.0f, 120.0f, 20.0f);
        } else if (com.comm_MarketingPolicy == 1 && customerId != 0) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"zhe"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 90.f, 20.f)];
        } else if (com.comm_MarketingPolicy == 2) {
            cell.unitePriceLabel.hidden = NO;
            cell.priceCategoryImageView.hidden = NO;
            [cell.unitePriceLabel setText:[NSString stringWithFormat:@"%.2Lf", com.comm_UnitPrice]];
            cell.priceCategoryImageView.image = [UIImage imageNamed:@"cu"];
            CGSize size = [cell.promotionPriceLabel.text sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(120, 20)];
            cell.promotionPriceLabel.frame = CGRectMake(92.0f, 45.0f, size.width + 2, 20.0f); //modify by zhangwei "价格过大显示不正常"
            [cell.unitePriceLabel setFrame:CGRectMake(92.0f + size.width + 10, 46.f, 80.f, 20.f)];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", com.comm_ID];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_Code == %d", com.comm_Code];
        NSArray *array = [commodity_SelectedArray filteredArrayUsingPredicate:predicate];
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
    return  70.0f;
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
        ServiceDetailViewController *serviceDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
        serviceDetailVC.serviceCode = serviceDoc.service_Code;
        serviceDetailVC.isShowFavourites = YES;
        [self.navigationController pushViewController:serviceDetailVC animated:YES];
    }
    else if( ((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 1
        && ((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_Available == YES)
    {//商品跳转到ProductDetailViewController
        CommodityDoc *commodityDoc = (CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        ProductDetailViewController *productDetailVC =[self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewController"];
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
                    [_tableView reloadData];
                }
            }
        }];
    }
}

#pragma mark - PSListTableViewCellDelegate

- (void)didSelectedButtonInCell:(PSListTableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
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
        NSArray *array = [service_SelectedArray filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [service_SelectedArray removeObject:[array objectAtIndex:0]];
        } else {
            [service_SelectedArray addObject:serviceDoc];
        }
        //在收藏选择列表选择或者去选
      //  NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.service_Code == %d", serviceDoc.service_Code];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.service_ID == %d", serviceDoc.service_ID]; //2014.9.9
        NSArray *array1 = [commodityOrService_SelectedArray filteredArrayUsingPredicate:predicate1];
        if ([array1 count] > 0) {
            [commodityOrService_SelectedArray removeObject:[array1 objectAtIndex:0]];
        } else {
            [commodityOrService_SelectedArray addObject:(CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]];
        }
        
    }else if (((CommodityOrServiceDoc *)[commodityOrServiceArray objectAtIndex:indexPath.row]).productType == 1
         && ((CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService).comm_Available == YES )//商品
    {
        CommodityDoc *commodityDoc = (CommodityDoc*)((CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]).commodityOrService;
        //在商品选择列表选择或者去选

     //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_Code == %d", commodityDoc.comm_Code];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.comm_ID == %d", commodityDoc.comm_ID]; //2014.9.9
        NSArray *array = [commodity_SelectedArray filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [commodity_SelectedArray removeObject:[array objectAtIndex:0]];
        } else {
            [commodity_SelectedArray addObject:commodityDoc];
        }
        //在收藏选择列表选择或者去选
        //  NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.comm_Code == %d", commodityDoc.comm_Code];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF.commodityOrService.comm_ID == %d", commodityDoc.comm_ID]; //2014.9.9
        NSArray *array1 = [commodityOrService_SelectedArray filteredArrayUsingPredicate:predicate1];
        if ([array1 count] > 0) {
            [commodityOrService_SelectedArray removeObject:[array1 objectAtIndex:0]];
        } else {
            [commodityOrService_SelectedArray addObject:(CommodityOrServiceDoc*)[commodityOrServiceArray objectAtIndex:indexPath.row]];
        }
        
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
                    [_tableView reloadData];
                }
            }
        }];
    }
    
    [_tableView reloadData];
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
    
    
    __block __weak FavouritesListViewController *favouriteListVC = self;

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
            commodityOrService_SelectedArray = [(AppDelegate *)[[UIApplication sharedApplication] delegate] commodityOrServiceArray_Selected];
            
            [(AppDelegate *) [[UIApplication sharedApplication] delegate] setFlag_Selected:0];
            self.view.userInteractionEnabled = YES;

            [_tableView reloadData];

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

