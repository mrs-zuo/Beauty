//
//  ProductDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ServiceDetailViewController.h"
#import "InitialSlidingViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "PictureDisplayView.h"
#import "OrderConfirmViewController.h"
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
#import "PictureDisplayView.h"
#import "SJAvatarBrowser.h"

@interface  ServiceDetailViewController() <PictureDisplayViewDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestDetailProductInfoOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestAddFavouriteOpeartion;
@property (weak, nonatomic) AFHTTPRequestOperation *requestDelFavouriteOpeartion;
@property (nonatomic) ServiceDoc *theService;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIPageControl *pageControl;
@end

@implementation ServiceDetailViewController
@synthesize theService;
@synthesize serviceCode;
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
    
    [self requestDetailServiceInfoByJson];
}

- (void)initLayout
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"服务详细"];
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
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.width * 0.75) + 20 )];
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.width * 0.75) + 20)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [self requestAddFavourite:theService.service_Code];
}

-(void)delFavourite
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"确定要取消收藏？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestDelFavourite:theService.service_FavouriteID];
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
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
        scrollView.delegate = self;
        CGSize newSize = CGSizeMake((kSCREN_BOUNDS.size.width - 10) * [theService.service_DisplayImgArray count], (kSCREN_BOUNDS.size.width * 0.75));//140
        [scrollView setContentSize:newSize];
        
//         for (int i = 0 ; i<[theService.service_DisplayImgArray count];i++){
//            ServiceDetailTopView *topView = [[ServiceDetailTopView alloc]initWithFrame:CGRectMake((kSCREN_BOUNDS.size.width - 10) * i, 5, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.width * 0.75))];
//             [topView setUserInteractionEnabled:YES];
//             topView.datas = theService.service_DisplayImgArray;
//            [scrollView addSubview:topView];
//         }
        for (int i = 0 ; i<[theService.service_DisplayImgArray count];i++){
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tag = i + 1;
            [imageView setImageWithURL:[NSURL URLWithString:[theService.service_DisplayImgArray objectAtIndex:i]]];
            [imageView setFrame:CGRectMake((kSCREN_BOUNDS.size.width - 10) * i, 5, kSCREN_BOUNDS.size.width - 10, (kSCREN_BOUNDS.size.width * 0.75))];//135
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            UITapGestureRecognizer *tapImageView  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageViewGestureRecognizer:)];
            tapImageView.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:tapImageView];
            [imageView setUserInteractionEnabled:YES];
            [scrollView addSubview:imageView];
            
        }
        
        pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(0,(kSCREN_BOUNDS.size.width * 0.75) + 5,(kSCREN_BOUNDS.size.width - 10),10)];//140
        pageControl.backgroundColor =[UIColor clearColor];
        pageControl.numberOfPages = [theService.service_DisplayImgArray count];
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
        cell.titleLabel.text = key;
        cell.valueText.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"名称内容"])
    {
        ContentEditCell *cell = [self configContentEditCell:tableView indexPath:indexPath];
        [cell setContentText:theService.service_ServiceName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"服务时间"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = key;
        cell.valueText.text = [NSString stringWithFormat:@"%ld分钟", (long)theService.service_SpendTime];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"服务次数"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = key;
        cell.valueText.text = [NSString stringWithFormat:@"%ld次", (long)theService.service_CourseFrequency];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"子服务"]){
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        SubServiceDoc *subservice = [theService.service_subService objectAtIndex:indexPath.row - 2];
        cell.titleLabel.text = subservice.service_subServiceName;
        CGRect rect = cell.titleLabel.frame;
        rect.origin.x = 25;
        cell.titleLabel.frame = rect;
        cell.titleLabel.textColor = kColor_Black;
        cell.valueText.text = [NSString stringWithFormat:@"%@分钟",subservice.service_subServiceTime];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"单价"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = key;
        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theService.service_UnitPrice];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ([key isEqualToString:@"优惠价"])
    {
        NormalEditCell *cell = [self configNormalEditCell:tableView indexPath:indexPath];
        cell.titleLabel.text = key;
        cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf", MoneyIcon, theService.service_PromotionPrice];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
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
        [cell setContentText:theService.service_Describe];
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
//        return 155.0f;//140
        return (kSCREN_BOUNDS.size.width * 0.75) + 20;
    } else if ([key isEqualToString:@"名称内容"]) {
        return theService.service_HeightForProductName ;
    }  else if ([key isEqualToString:@"介绍内容"]) {
        return theService.service_HeightForDescribe;
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

- (void)tapImageViewGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)gestureRecognizer.view;
//        [SJAvatarBrowser showImage:imgView];
         NSString *imgUrlStr = [theService.service_DisplayImgArray objectAtIndex:(imgView.tag) - 1];
        NSArray *imgUrlArr = [imgUrlStr componentsSeparatedByString:@"&"];
       NSString *tempImgUrlStr =  [imgUrlArr firstObject];
        UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tempImgUrlStr]]];
        [SJAvatarBrowser showImage:imgView img:image];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    //    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIScrollView"]) {
        return NO;
    }
    return  YES;
}


#pragma mark - 接口
- (void)requestDetailServiceInfoByJson
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    CGFloat ImageWidth =  kSCREN_BOUNDS.size.width;
    CGFloat ImageHeight = kSCREN_BOUNDS.size.width *0.75;
//    NSString *par = [NSString stringWithFormat:@"{\"ProductCode\":%lld,\"ImageWidth\":%d,\"ImageHeight\":%d}", serviceCode, 280, 280];
    NSString *par = [NSString stringWithFormat:@"{\"ProductCode\":%lld,\"ImageWidth\":%ld,\"ImageHeight\":%ld}", serviceCode, (long)@(ImageWidth).integerValue, (long)@(ImageHeight).integerValue];
    
    _requestDetailProductInfoOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Service/getServiceDetailByServiceCode_2_1" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            theService = [[ServiceDoc alloc] initWithDictionary:data];
            
            theService.service_subService = [NSMutableArray array];
            theService.service_hasSubService = [[data objectForKey:@"HasSubServices"] boolValue];
            if(theService.service_hasSubService){
                NSArray *subServiceArray = [data objectForKey:@"SubServices"];
                if((NSNull *)subServiceArray != [NSNull null]){
                    for (NSDictionary *dict in subServiceArray){
                        SubServiceDoc *subService = [[SubServiceDoc alloc] init];
                        subService.service_subServiceCode = [[dict objectForKey:@"SubServiceCode"] integerValue];
                        subService.service_subServiceTime = [dict objectForKey:@"SpendTime"];
                        subService.service_subServiceName = [dict objectForKey:@"SubServiceName"];
                        [theService.service_subService addObject:subService];
                    }
                }
            }
            
            if((theService.service_FavouriteID > 0 || self.isShowFavourites) && ACC_BRANCHID != 0)
            {
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitTitle:@"取消收藏" submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
                
            }else if(ACC_BRANCHID != 0){
                
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"]submitTitle:@"加入收藏" submitAction:@selector(addFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
            
//            theService = [self setCalculatePrice:theService];
            [self checkDisplayContent];
            
        } failure:^(NSInteger code, NSString *error) {
            if(code == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该服务已下架" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取服务详情失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }

        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestDetailProductInfoOpeartion = [[GPHTTPClient shareClient] requestGetServiceDetailByJson:serviceCode success:^(id xml) {
        [SVProgressHUD dismiss];
        if (!theService) {
            theService = [[ServiceDoc alloc] init];
        }
        NSString *origalString = (NSString*)xml;
        NSString *regexString = @"[{*}]";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0,origalString.length)];
        if(!array || [array count] < 2)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取服务详情失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
        
        NSData *origalData = [origalString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:nil];
        if ((NSNull *)dataDictionary == [NSNull null] || dataDictionary.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"获取服务详情失败，请重试！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];;
            [alertView show];
            return;
        }
        NSDictionary *dataDic = [dataDictionary objectForKey:@"Data"];
        NSInteger dataCode = [[dataDictionary objectForKey:@"Code"] integerValue];

        if(dataCode == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该服务已下架" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else if(dataCode == 1){
            __block __weak ServiceDetailViewController *serviceDetailVC = self;
            [theService setService_ID:[[dataDic objectForKey:@"ServiceID"] integerValue]];
            [theService setService_Code:serviceCode];
            [theService setService_ServiceName:[dataDic objectForKey:@"ServiceName"]];
            [theService setService_Describe:[dataDic objectForKey:@"Describe"]];
            [theService setService_MarketingPolicy:[[dataDic objectForKey:@"MarketingPolicy"] integerValue]];
            [theService setService_SpendTime:[[dataDic objectForKey:@"SpendTime"] integerValue]];
            [theService setService_CourseFrequency:[[dataDic objectForKey:@"CourseFrequency"] integerValue]];
            [theService setService_FavouriteID:[[dataDic objectForKey:@"FavoriteID"] integerValue]];
            [theService setService_UnitPrice:[[dataDic objectForKey:@"UnitPrice"] floatValue]];
            [theService setService_PromotionPrice:[[dataDic objectForKey:@"PromotionPrice"] floatValue]];

            NSArray *imageURLList = [dataDic objectForKey:@"ServiceImage"];
            if((NSNull*)imageURLList != [NSNull null])
                [theService setService_DisplayImgArray:imageURLList];
            else
                [theService setService_DisplayImgArray:nil];
            
            theService.service_subService = [NSMutableArray array];
            theService.service_hasSubService = [[dataDic objectForKey:@"HasSubServices"] boolValue];
            if(theService.service_hasSubService){
                NSArray *subServiceArray = [dataDic objectForKey:@"SubServices"];
                if((NSNull *)subServiceArray != [NSNull null]){
                    for (NSDictionary *dict in subServiceArray){
                        SubServiceDoc *subService = [[SubServiceDoc alloc] init];
                        subService.service_subServiceCode = [[dict objectForKey:@"SubServiceCode"] integerValue];
                        subService.service_subServiceTime = [dict objectForKey:@"SpendTime"];
                        subService.service_subServiceName = [dict objectForKey:@"SubServiceName"];
                        [theService.service_subService addObject:subService];
                    }
                }
            }
            
            if((theService.service_FavouriteID > 0 || self.isShowFavourites) && ACC_BRANCHID != 0)
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
            
            theService = [serviceDetailVC setCalculatePrice:theService];
            [self checkDisplayContent];
        }
        
    } failure:^(NSError *error) {
        
    }];
     */
}


- (void)requestDetailServiceInfo
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    
    _requestDetailProductInfoOpeartion = [[GPHTTPClient shareClient] requestGetServiceDetail:serviceCode success:^(id xml) {
   
        [SVProgressHUD dismiss];
        if (!theService) {
            theService = [[ServiceDoc alloc] init];
        }
        __autoreleasing GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml encoding:NSUTF8StringEncoding error:0];
        __autoreleasing GDataXMLElement *resultData = [[document nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
        NSInteger result_Flag   = [[[[resultData elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
        
        if(result_Flag == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该服务已下架" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
        __block __weak ServiceDetailViewController *serviceDetailVC = self;
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {

                [theService setService_ID:[[[[contentData elementsForName:@"ServiceID"] objectAtIndex:0] stringValue] integerValue]];
                [theService setService_Code:serviceCode];
                [theService setService_ServiceName:[[[contentData elementsForName:@"ServiceName"] objectAtIndex:0] stringValue]];
                [theService setService_Describe:[[[contentData elementsForName:@"Describe"] objectAtIndex:0] stringValue]];
                
                [theService setService_MarketingPolicy:[[[[contentData elementsForName:@"MarketingPolicy"] objectAtIndex:0] stringValue] intValue]];
                [theService setService_SpendTime:[[[[contentData elementsForName:@"SpendTime"] objectAtIndex:0] stringValue] intValue]];
                [theService setService_CourseFrequency:[[[[contentData elementsForName:@"CourseFrequency"] objectAtIndex:0] stringValue] intValue]];
                [theService setService_FavouriteID:[[[[contentData elementsForName:@"FavoriteID"] objectAtIndex:0] stringValue] integerValue]];
                
                NSArray *UnitPriceArray = [contentData elementsForName:@"UnitPrice"];
                if (UnitPriceArray.count !=0 )
                {
                    [theService setService_UnitPrice:[[[[contentData elementsForName:@"UnitPrice"] objectAtIndex:0] stringValue] doubleValue]];
                } else {
                    [theService setService_UnitPrice:-1];
                }
                NSArray *PromotionPriceArray = [contentData elementsForName:@"PromotionPrice"];
                if (PromotionPriceArray.count !=0 )
                {
                    [theService setService_PromotionPrice:[[[[contentData elementsForName:@"PromotionPrice"] objectAtIndex:0] stringValue] doubleValue]];
                } else {
                    [theService setService_PromotionPrice:-1];
                }
                
                NSMutableArray *array = [NSMutableArray array];
                for (GDataXMLElement *imageURL in [contentData elementsForName:@"ServiceImage"]) {
                    NSArray *imageArray = [imageURL elementsForName:@"ImageURL"];
                    if ([imageArray count] > 0) {
                        for (int i = 0; i < [imageArray count]; i++) {
                            [array addObject:[[imageArray objectAtIndex:i] stringValue]];
                        }
                    }
                }
                [theService setService_DisplayImgArray:array];
                if((theService.service_FavouriteID > 0 || self.isShowFavourites) && ACC_BRANCHID != 0)
                {
                    FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                    [footerViewOld removeFromSuperview];
                    
                    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitTitle:@"取消收藏"submitAction:@selector(delFavourite)];
                    footerView.tag = 1000;
                    [footerView showInTableView:_tableView];
                    
                }else if(ACC_BRANCHID != 0){
                    
                    FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                    [footerViewOld removeFromSuperview];
                    
                    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"addFavourite"] submitTitle:@"加入收藏"submitAction:@selector(addFavourite)];
                    footerView.tag = 1000;
                    [footerView showInTableView:_tableView];
                }
            
//                theService = [serviceDetailVC setCalculatePrice:theService];
                [self checkDisplayContent];
            
        } failure:^{}];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
-(void)requestAddFavourite:(long long)productCode
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"ProductType\":%d,\"ProductCode\":%lld}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, 0, productCode];
    
    
    _requestAddFavouriteOpeartion = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/addFavorite" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (ACC_BRANCHID !=0 ) {
                theService.service_FavouriteID = self.favouriteID = [[data objectForKey:@"FavoriteID"] integerValue];
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:nil submitTitle:@"取消收藏"submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error.length ? error : @"收藏失败！" touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
    }];

    /*
    _requestAddFavouriteOpeartion = [[GPHTTPClient shareClient] requestAddFavouriteByProductType:0 andProductCode:productCode success:^(id xml) {
        [SVProgressHUD dismiss];
        
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if (ACC_BRANCHID != 0) {
                theService.service_FavouriteID = self.favouriteID = [[[[contentData elementsForName:@"FavoriteID"] objectAtIndex:0]stringValue]integerValue];
                FooterView *footerViewOld = (FooterView *)[_tableView viewWithTag:1000];
                [footerViewOld removeFromSuperview];
                
                FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"delFavourite"] submitAction:@selector(delFavourite)];
                footerView.tag = 1000;
                [footerView showInTableView:_tableView];
            }
        } failure:^{}];
        
    } failure:^(NSError *error) {
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
        
    } failure:^(NSError *error) {
    }];
    */
}


- (void)checkDisplayContent
{
    if (dataArray) {
        [dataArray removeAllObjects];
    } else {
        dataArray = [NSMutableArray array];
    }
    
    //section 0
    if (theService.service_DisplayImgArray && [theService.service_DisplayImgArray count] > 0) {
        [dataArray addObject:@[@"图像"]];
    }
    
    //section 1
    NSMutableArray *array_section1 = [NSMutableArray array];
    if (theService.service_hasSubService) {
        [array_section1 addObject:@"名称"];
        [array_section1 addObject:@"名称内容"];
        for (int i = 0 ; i < theService.service_subService.count; i++) {
            [array_section1 addObject:@"子服务"];
        }
    } else {
        if ([theService.service_ServiceName length] > 0) {
            [array_section1 addObject:@"名称"];
            [array_section1 addObject:@"名称内容"];
        }
        
        if (theService.service_SpendTime != 0) {
            [array_section1 addObject:@"服务时间"];
        }
        
        if (theService.service_CourseFrequency != 0) {
            [array_section1 addObject:@"服务次数"];
        }
    }
    if ([array_section1 count] > 0)
        [dataArray addObject:array_section1];
    
    //section2
    NSMutableArray *array_section2 = [NSMutableArray array];
    if (theService.service_UnitPrice >= 0) {
        [array_section2 addObject:@"单价"];
    }
    
    if (theService.service_MarketingPolicy == 2 ) {
       // [array_section2 addObject:@"优惠价"];
    }
    
    if ([array_section2 count] > 0)
        [dataArray addObject:array_section2];
    
    // section3
    if ([theService.service_Describe length] > 0) {
        [dataArray addObject:@[@"介绍", @"介绍内容"]];
    }
    DLOG(@"dataArray:%@", dataArray);
    [_tableView reloadData];
}

// 给CalculatePrice赋值
//- (ServiceDoc *)setCalculatePrice:(ServiceDoc *)serviceDoc
//{
//    switch (serviceDoc.service_MarketingPolicy) {
//        case 0:
//        {
//            [serviceDoc setService_CalculatePrice:serviceDoc.service_UnitPrice];
//        }
//            break;
//        case 1:
//        {
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            CustomerDoc *cus_Selected = [appDelegate customer_Selected];
//            [serviceDoc setService_CalculatePrice: cus_Selected ? serviceDoc.service_PromotionPrice : serviceDoc.service_UnitPrice * 1.0f];
//        }
//            break;
//        case 2:
//        {
//            [serviceDoc setService_CalculatePrice:serviceDoc.service_PromotionPrice];
//        }
//            break;
//        default:
//            break;
//    }
//    return serviceDoc;
//}


@end
