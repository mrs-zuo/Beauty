//
//  ProductDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//
static CGFloat const kScrollViewTag = 999999;

#import "ProductDetailViewController.h"
#import "InitialSlidingViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "PictureDisplayView.h"
#import "CommodityDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "UIImageView+WebCache.h"
#import "GPBHTTPClient.h"
#import "SJAvatarBrowser.h"

@interface  ProductDetailViewController() <UIGestureRecognizerDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *requestDetailProductInfoOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddFavouriteOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDelFavouriteOpeartion;

@property (nonatomic) CommodityDoc *theCommodity;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIPageControl *pageControl;
@end

@implementation ProductDetailViewController
@synthesize theCommodity;
@synthesize commodityCode;
@synthesize dataArray;
@synthesize scrollView;
@synthesize pageControl;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
     dataArray = [NSMutableArray array];
    
    [super viewDidLoad];
    [self initLayout];
}

- (void)initLayout
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"商品详细"];
    [self.view addSubview:navigationView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f) style:UITableViewStyleGrouped];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 10;
    }
    [self.view addSubview:_tableView];
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, 300, 145)];
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, 300, 145)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestDetailProductInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestDetailProductInfoOpeartion && [_requestDetailProductInfoOpeartion isExecuting]) {
        [_requestDetailProductInfoOpeartion cancel];
    }
    
    if (_requestAddFavouriteOpeartion && [_requestAddFavouriteOpeartion isExecuting]) {
        [_requestAddFavouriteOpeartion cancel];
    }
    
    if (_requestDelFavouriteOpeartion && [_requestDelFavouriteOpeartion isExecuting]) {
        [_requestDelFavouriteOpeartion cancel];
    }
    
    _requestDetailProductInfoOpeartion = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((self.scrollView.contentOffset.x-150)/300) + 1 ;
    pageControl.currentPage = page;
}
-(void)addFavourite
{
    [self requestAddFavourite:theCommodity.comm_Code];//2014.9.9
}

-(void)delFavourite
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"确定要取消收藏？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestDelFavourite:theCommodity.comm_FavouriteID];
        }
    }];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [dataArray objectAtIndex:section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [dataArray objectAtIndex:indexPath.section];
    NSString *key = [array objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"图像"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DisplayPicCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DisplayPicCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = [UIColor whiteColor];
        
        if (scrollView != nil) {
            [scrollView removeFromSuperview];
        }
        scrollView.directionalLockEnabled = YES; //只能一个方向滑动
        scrollView.pagingEnabled = YES; //是否翻页
        scrollView.showsVerticalScrollIndicator =NO;
        scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
        scrollView.delegate = self;
        scrollView.tag = kScrollViewTag;
        CGSize newSize = CGSizeMake(300 * [theCommodity.comm_DisplayImgArray count], 145);//140
        [scrollView setContentSize:newSize];
        
        for (int i = 0 ; i<[theCommodity.comm_DisplayImgArray count];i++){
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[theCommodity.comm_DisplayImgArray objectAtIndex:i]]]];
//            NSLog(@"width = %f      height = %f", image.size.width, image.size.height);
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:[theCommodity.comm_DisplayImgArray objectAtIndex:i]]];
            [imageView setFrame:CGRectMake(300 * i + 80, 5, 140, 140)]; //135
            imageView.userInteractionEnabled = YES;
            imageView.tag = 100 + i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
            tap.delegate = self;
            [imageView addGestureRecognizer:tap];
            
            [scrollView addSubview:imageView];
        }
        
        pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(125,145,60,10)]; //140
        pageControl.backgroundColor =[UIColor clearColor];
        pageControl.numberOfPages = [theCommodity.comm_DisplayImgArray count];
        pageControl.currentPage = 0;
        pageControl.hidesForSinglePage = YES;
        pageControl.currentPageIndicatorTintColor = kColor_LightBlue;
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        [cell.contentView addSubview:pageControl];
        [cell.contentView addSubview:scrollView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"名称"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"名称";
        cell.valueText.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"名称内容"])
    {
        ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
        [cell setContentText:theCommodity.comm_CommodityName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"规格"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"规格";
        cell.valueText.text = theCommodity.comm_Specification;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"单价"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"单价";
        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theCommodity.comm_UnitPrice];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"优惠价"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"优惠价";
        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theCommodity.comm_PromotionPrice];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"库存"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"库存";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (ACC_BRANCHID == 0 || !theCommodity.comm_StockCalc) {
            cell.valueText.text = [NSString stringWithFormat:@"%ld", (long)theCommodity.comm_StockQuantity];
            return cell;
        } else {
            NSString *string = [NSString stringWithFormat:@"(%@)  %ld", theCommodity.comm_StockCalc, (long)theCommodity.comm_StockQuantity];
            NSMutableAttributedString *stock = [[NSMutableAttributedString alloc] initWithString:string];
            
            NSRange stockRange = [string rangeOfString:[NSString stringWithFormat:@"(%@)", theCommodity.comm_StockCalc]];
            NSRange countRange = [string rangeOfString:[NSString stringWithFormat:@"%ld", (long)theCommodity.comm_StockQuantity]];
            
            [stock addAttribute:NSForegroundColorAttributeName value:STOCK_COLOR range:stockRange];
            [stock addAttribute:NSFontAttributeName value:kFont_Light_14 range:stockRange];
            [stock addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:countRange];
            [stock addAttribute:NSFontAttributeName value:kFont_Light_16 range:countRange];

            cell.valueText.attributedText = stock;
            return cell;
        }
    }
    else if ([key isEqualToString:@"介绍"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = @"介绍";
        cell.valueText.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"介绍内容"])
    {
        ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
        [cell setContentText:theCommodity.comm_Describe];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        return nil;
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
        cell.backgroundColor = [UIColor whiteColor];
    }
    [cell.valueText setEnabled:NO];
    [cell.valueText setTextColor:[UIColor blackColor]];
    [cell.valueText setUserInteractionEnabled:NO];
    [cell.accessoryLabel setHidden:YES];
    return cell;
}

// 配置ContentEditCell
- (ContentEditCell *)configContentEditCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ContentEditCell";
    ContentEditCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell.contentEditText setTextColor:[UIColor blackColor]];
    [cell.contentEditText setUserInteractionEnabled:NO];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *array = [dataArray objectAtIndex:indexPath.section];
    NSString *key = [array objectAtIndex:indexPath.row];
    
    if ([key isEqualToString:@"图像"]) {
        return 155.0f;//140
    } else if ([key isEqualToString:@"名称内容"]) {
        return theCommodity.comm_HeightForName ;
    }  else if ([key isEqualToString:@"介绍内容"]) {
        return theCommodity.comm_HeightForDescribe;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 4.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}
#pragma mark - 手势
- (void)tapImageView:(UIGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)ges.view;
        NSString *imageUrl = [theCommodity.comm_DisplayImgArray objectAtIndex:imgView.tag - 100];
        NSString *tempUrl = [imageUrl componentsSeparatedByString:@"&"].firstObject;
        UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tempUrl]]];
        [SJAvatarBrowser showImage:imgView img:image];
    }
}

#pragma mark - 接口

- (void)requestDetailProductInfo
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"ProductCode\":%lld,\"ImageWidth\":%d,\"ImageHeight\":%d}", commodityCode, 280, 280];

    _requestDetailProductInfoOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Commodity/getCommodityDetailByCommodityCode" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (!theCommodity) {
            theCommodity = [[CommodityDoc alloc] init];
        }
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            
            theCommodity = [[CommodityDoc alloc] initWithDictionary:data];
            
//            NSMutableArray *array = [NSMutableArray array];
//                if ([theCommodity.comm_ count] > 0) {
//                    for (int i = 0; i < [imageArray count]; i++) {
//                        [array addObject:[[imageArray objectAtIndex:i] stringValue]];
//                    }
//                }
//            [theCommodity setComm_DisplayImgArray:array];
//            theCommodity = [productDetailVC setCalculatePrice:theCommodity];

            if((theCommodity.comm_FavouriteID > 0 || self.isShowFavourites) && ACC_BRANCHID != 0)
            {
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil  submitTitle:@"取消收藏" submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
                
            }else if(ACC_BRANCHID != 0){
                
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"]  submitTitle:@"加入收藏" submitAction:@selector(addFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
            
            [self checkDisplayContent];


        } failure:^(NSInteger code, NSString *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该商品不存在或已下架" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];

        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    /*
    _requestDetailProductInfoOpeartion = [[GPHTTPClient shareClient] requestGetCommodityDetail:commodityCode success:^(id xml) {
        [SVProgressHUD dismiss];
        if (!theCommodity) {
            theCommodity = [[CommodityDoc alloc] init];
        }
        __autoreleasing GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml encoding:NSUTF8StringEncoding error:0];
        __autoreleasing GDataXMLElement *resultData = [[document nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
        NSInteger result_Flag   = [[[[resultData elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
        
        if(result_Flag == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该商品不存在或已下架" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            __block __weak ProductDetailViewController *productDetailVC = self;
            [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
                [theCommodity setComm_ID:[[[[contentData elementsForName:@"CommodityID"] objectAtIndex:0] stringValue] integerValue]];
                [theCommodity setComm_Code:commodityCode];
                [theCommodity setComm_CommodityName:[[[contentData elementsForName:@"CommodityName"] objectAtIndex:0] stringValue]];
                [theCommodity setComm_Describe:[[[contentData elementsForName:@"Describe"] objectAtIndex:0] stringValue]];
                [theCommodity setComm_Specification:[[[contentData elementsForName:@"Specification"] objectAtIndex:0] stringValue]];
                [theCommodity setComm_MarketingPolicy:[[[[contentData elementsForName:@"MarketingPolicy"] objectAtIndex:0] stringValue] integerValue]];
                [theCommodity setComm_FavouriteID:[[[[contentData elementsForName:@"FavoriteID"] objectAtIndex:0] stringValue] integerValue]];
                [theCommodity setComm_StockCalc:[[[contentData elementsForName:@"StockCalcType"] objectAtIndex:0] stringValue]];
                
                NSArray *UnitPriceArray = [contentData elementsForName:@"UnitPrice"];
                if (UnitPriceArray.count !=0 )
                {
                    [theCommodity setComm_UnitPrice:[[[[contentData elementsForName:@"UnitPrice"] objectAtIndex:0] stringValue] floatValue]];
                } else {
                    [theCommodity setComm_UnitPrice:-1];
                }
                NSArray *PromotionPriceArray = [contentData elementsForName:@"PromotionPrice"];
                if (PromotionPriceArray.count !=0 )
                {
                    [theCommodity setComm_PromotionPrice:[[[[contentData elementsForName:@"PromotionPrice"] objectAtIndex:0] stringValue] floatValue]];
                } else {
                    [theCommodity setComm_PromotionPrice:-1];
                }
                NSArray *StockQuantityArray = [contentData elementsForName:@"StockQuantity"];
                if (StockQuantityArray.count !=0 )
                {
                    [theCommodity setComm_StockQuantity:[[[[contentData elementsForName:@"StockQuantity"] objectAtIndex:0] stringValue] integerValue]];
                } else {
                    [theCommodity setComm_StockQuantity:-1];
                }
                
                NSMutableArray *array = [NSMutableArray array];
                for (GDataXMLElement *imageURL in [contentData elementsForName:@"CommodityImage"]) {
                    NSArray *imageArray = [imageURL elementsForName:@"ImageURL"];
                    if ([imageArray count] > 0) {
                        for (int i = 0; i < [imageArray count]; i++) {
                            [array addObject:[[imageArray objectAtIndex:i] stringValue]];
                        }
                    }
                }
                [theCommodity setComm_DisplayImgArray:array];
                theCommodity = [productDetailVC setCalculatePrice:theCommodity];
                
                if((theCommodity.comm_FavouriteID > 0 || self.isShowFavourites) && ACC_BRANCHID != 0)
                {
                    FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                    [footerViewOld removeFromSuperview];
                    
                    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"delFavourite"] submitAction:@selector(delFavourite)];
                    footerView.tag = 1000;
                    [footerView showInTableView:_tableView];
                    
                }else if(ACC_BRANCHID != 0){
                    
                    FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                    [footerViewOld removeFromSuperview];
                    
                    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"] submitAction:@selector(addFavourite)];
                    footerView.tag = 1000;
                    [footerView showInTableView:_tableView];
                }
                
                [self checkDisplayContent];
            } failure:^{}];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    */
    
}
-(void)requestAddFavourite:(long long)productCode
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"ProductType\":%d,\"ProductCode\":%lld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, 1, productCode];

    
    _requestAddFavouriteOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/addFavorite" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (ACC_BRANCHID !=0 ) {
                theCommodity.comm_FavouriteID = self.favouriteID = [[data objectForKey:@"FavoriteID"] integerValue];
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitTitle:@"取消收藏" submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error.length ? error : @"收藏失败！" touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
    }];
    
    /*
    _requestAddFavouriteOpeartion = [[GPHTTPClient shareClient] requestAddFavouriteByProductType:1 andProductCode:productCode success:^(id xml) {
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if (ACC_BRANCHID !=0 ) {
                theCommodity.comm_FavouriteID = self.favouriteID = [[[[contentData elementsForName:@"FavoriteID"] objectAtIndex:0]stringValue]integerValue];
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"delFavourite"] submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
        } failure:^{}];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该商品已下架" delegate:nil cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
        [SVProgressHUD dismiss];
    }];
    */
}

-(void)requestDelFavourite:(NSInteger)favouriteID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"FavoriteID\":%ld}", (long)favouriteID];

    _requestDelFavouriteOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/delFavorite" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if(ACC_BRANCHID != 0)
            {
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"] submitTitle:@"加入收藏" submitAction:@selector(addFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestDelFavouriteOpeartion = [[GPHTTPClient shareClient] requestDelFavouriteByFavouriteID:favouriteID  success:^(id xml) {
        [SVProgressHUD dismiss];
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if(ACC_BRANCHID != 0)
            {
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"] submitAction:@selector(addFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
        } failure:^{}];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    */
}
// 给CalculatePrice赋值
//- (CommodityDoc *)setCalculatePrice:(CommodityDoc *)commodityDoc
//{
//    switch (commodityDoc.comm_MarketingPolicy) {
//        case 0:
//        {
//            [commodityDoc setComm_CalculatePrice:commodityDoc.comm_UnitPrice];
//        }
//            break;
//        case 1:
//        {
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            CustomerDoc *cus_Selected = [appDelegate customer_Selected];
//            [commodityDoc setComm_CalculatePrice: cus_Selected ? commodityDoc.comm_PromotionPrice : commodityDoc.comm_UnitPrice * 1.0f];
//        }
//            break;
//        case 2:
//        {
//            [commodityDoc setComm_CalculatePrice:commodityDoc.comm_PromotionPrice];
//        }
//            break;
//        default:
//            break;
//    }
//    return commodityDoc;
//}

- (void)checkDisplayContent
{
    if (dataArray) {
        [dataArray removeAllObjects];
    }
    
    //section 0
    if ([theCommodity.comm_DisplayImgArray count] > 0) {
        [dataArray addObject:@[@"图像"]];
    }
    
    //section 1
    NSMutableArray *array_section1 = [NSMutableArray array];
    if ([theCommodity.comm_CommodityName length] > 0) {
        [array_section1 addObject:@"名称"];
        [array_section1 addObject:@"名称内容"];
    }
    
    if ([theCommodity.comm_Specification length] > 0) {
        [array_section1 addObject:@"规格"];
    }
    
    if ([array_section1 count] > 0)
        [dataArray addObject:array_section1];
    
    //section2
    NSMutableArray *array_section2 = [NSMutableArray array];
    if (theCommodity.comm_UnitPrice >= 0) {
        [array_section2 addObject:@"单价"];
    }
    
    if (theCommodity.comm_PromotionPrice >= 0 ) {
  //      [array_section2 addObject:@"优惠价"];
    }
    
//    if(theCommodity.comm_StockQuantity >= 0) {
        [array_section2 addObject:@"库存"];
//    }
    
    if ([array_section2 count] > 0)
        [dataArray addObject:array_section2];
    
    // section3
    if ([theCommodity.comm_Describe length] > 0) {
        [dataArray addObject:@[@"介绍", @"介绍内容"]];
    }
    [_tableView reloadData];
}

@end
