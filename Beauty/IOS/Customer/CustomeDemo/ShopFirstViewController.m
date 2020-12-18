//
//  ShopFirstViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//
#define ImageScrollHeight  200.0f

#import "ShopFirstViewController.h"
#import "GPCHTTPClient.h"
#import "ShopInfoModel.h"
#import "BusinessInfoCell.h"
#import "BusinessInfoModel.h"
#import "GPAnnotation.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>

@interface ShopFirstViewController ()<UIAlertViewDelegate,UIWebViewDelegate,BMKMapViewDelegate,UIScrollViewDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *shopRequest;
@property (nonatomic, strong) BusinessInfoModel *shopBusInfo;
@property (nonatomic, strong) NSArray *manageArray;
@property(strong, nonatomic) BMKMapView *mapView;


@property (nonatomic, strong) UIWebView *phoneCallWebView;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *url;

@property (nonatomic,strong) UIView *headView;
@property (nonatomic,strong)UIScrollView *imageScrollView;

@end

@implementation ShopFirstViewController
static NSString *cellindity = @"ShopCell";
const double aa = 6378245.0;
const double eee = 0.00669342162296594323;
const double pii = 3.14159265358979324;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)initTableView
{
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    if (self.shopBusInfo.ImageURL.count > 0) {
        if (!_headView) {
            _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, ImageScrollHeight)];
            _imageScrollView  =[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, ImageScrollHeight)];
            _imageScrollView.delegate = self;
            _imageScrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width *self.shopBusInfo.ImageURL.count , ImageScrollHeight);
            _imageScrollView.showsHorizontalScrollIndicator =NO;
            _imageScrollView.showsVerticalScrollIndicator = NO;
            _imageScrollView.directionalLockEnabled = YES;
            if (self.shopBusInfo.ImageURL.count) {
                for (int i = 0 ; i < self.shopBusInfo.ImageURL.count; i ++) {
                    UIImageView *imageView  = [[UIImageView alloc]initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width * i, 0, kSCREN_BOUNDS.size.width, ImageScrollHeight)];
                    NSString *url = self.shopBusInfo.ImageURL[i];
                    [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        
                    }] ;
                    [_imageScrollView addSubview:imageView];
                }
            }
            UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, ImageScrollHeight, kSCREN_BOUNDS.size.width, 20)];
            pageControl.numberOfPages = self.shopBusInfo.ImageURL.count;
            [pageControl addTarget:self action:@selector(pageControlEvent:) forControlEvents:UIControlEventValueChanged];
            [_headView addSubview:_imageScrollView];
            [_headView addSubview:pageControl];
            [self.tableView setTableHeaderView:_headView];
        }
    }else{
        self.tableView.frame = CGRectMake(0, -40, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height);
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = kTableView_LineColor;
    [self.tableView registerClass:[BusinessInfoCell class] forCellReuseIdentifier:cellindity];

    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestShopInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.manageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BusinessInfoCell *busCell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (busCell == nil) {
        busCell = [[BusinessInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellindity];
    }else
    {
        [busCell removeFromSuperview];
        busCell = [[BusinessInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellindity];
    }
    NSDictionary *dic = [self.manageArray objectAtIndex:indexPath.row];
    busCell.infoDic = dic;
    return busCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.manageArray objectAtIndex:indexPath.row];
    NSString *title = dic[@"Title"];
    NSString *content = dic[@"Content"];
    
    if (title.length == 0) {
        
        CGSize constraint = CGSizeMake(300, 20000.0f);
        CGSize size = [content sizeWithFont:kNormalFont_14 constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        return ( size.height + 10) < kTableView_DefaultCellHeight?kTableView_DefaultCellHeight :( size.height + 10);
    }
    return kTableView_DefaultCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *dic = [self.manageArray objectAtIndex:indexPath.row];
    NSString *title = dic[@"Title"];
    NSString *content = dic[@"Content"];
    
    if ([title isEqualToString:@"网址简介"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"打开网址" message:[NSString stringWithFormat:@"%@%@",@"网址:",[dic objectForKey:@"Content"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _url = [dic objectForKey:@"Content"];
        alertView.tag = 2222;
        [alertView show];
    }
    
        if ([title isEqualToString:@"电话"]) {
          
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:[NSString stringWithFormat:@"%@%@",@"呼叫:", content] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            _phoneNumber = content;
            alertView.tag = 4444;
            [alertView show];
        }
    
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1) {
            if (alertView.tag == 2222) {
                 [self openThisUrl:_url];
            }
            if (alertView.tag == 4444) {
                [self callThisNumber:_phoneNumber];
            }
        }
}
    
    
- (void)callThisNumber:(NSString*)phoneNum
    {
        NSString *url = [NSString stringWithFormat:@"tel://%@", phoneNum];
        
        NSURL *phoneURL = [NSURL URLWithString:url];
        
        if (!_phoneCallWebView ) {
            
            _phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        [_phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

-(void)openThisUrl:(NSString *)url
{
    if ([url hasPrefix:@"https://"]) {
        
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    }
    
    if ([url hasPrefix:@"http://"]) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    }
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",url]]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.shopBusInfo.isMapView) {
        return 200.0f;
    } else {
        return kTableView_Margin;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.shopBusInfo.isMapView) {
        return [self businessMapView];
    } else {
        return nil;
    }
}

- (UIView *)businessMapView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 200.0f)];
    if ((IOS7 || IOS8))
        footerView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 200.0f);
    else
        footerView.frame = CGRectMake(10.0f, 0.0f, 290.0f, 200.0f);
    footerView.backgroundColor = [UIColor clearColor];
    
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 200.0f)];
    _mapView.delegate = self;
    _mapView.zoomLevel = 16;
    _mapView.buildingsEnabled = YES;
    [_mapView setScrollEnabled:YES];
    [_mapView setMapType:BMKUserTrackingModeNone];
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = self.shopBusInfo.Latitude;
    coor.longitude = self.shopBusInfo.Longitude;
    annotation.coordinate = coor;
    annotation.title = self.shopBusInfo.Name;
    annotation.subtitle = self.shopBusInfo.Address;
    [_mapView setCenterCoordinate:coor];
    [_mapView addAnnotation:annotation];
    
    [footerView addSubview:_mapView];

    return footerView;
}
#pragma mark - 网络请求
- (void)requestShopInfo
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSDictionary *para = @{@"BranchID":@(self.shopInfo.BranchID),
                           @"ImageHeight":@300,
                           @"ImageWidth":@400};

    _shopRequest = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Company/getBusinessDetail" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            self.shopBusInfo = [[BusinessInfoModel alloc] initWithDic:data];
            self.manageArray = [self.shopBusInfo shopBusinessInfoHandle];
            
            if (self.viewFor != 1) {
                [self.parentViewController setValue:self.shopBusInfo.ImageURL forKey:@"imageList"];
            }
            
            [self initTableView];
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"renameMark"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        // 设置可拖拽
        newAnnotationView.draggable = NO;
        return newAnnotationView;
    }
    return nil;
}

#pragma mark - pageControlEvent
- (void)pageControlEvent:(UIPageControl *)pageControl
{
    _imageScrollView.contentOffset = CGPointMake(kSCREN_BOUNDS.size.width * pageControl.currentPage, 0);
}
#pragma mark -   UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end
