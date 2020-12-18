//
//  SalonDetailViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "SalonDetailViewController.h"
#import "GPHTTPClient.h"
#import "UIImageView+WebCache.h"
#import "CacheInDisk.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "GPAnnotation.h"
#import "TwoLabelCell.h"
#import "AccountListViewController.h"
#import "CompanyDoc.h"
#import "AppDelegate.h"
#import "TitleView.h"
#import "GPBHTTPClient.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;

@interface SalonDetailViewController () <BMKMapViewDelegate>

@property(weak  , nonatomic) AFHTTPRequestOperation *companyDetailOperation;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIPageControl *pageControl;
@property(assign, nonatomic) CGSize size_remark;
@property(assign, nonatomic) CGSize size_hours;
@property(assign, nonatomic) CGSize size_addr;
@property(assign, nonatomic) CGSize size_web;
@property(strong, nonatomic) NSMutableArray *contactTitleArray;
@property(strong, nonatomic) NSMutableArray *titleArray;
@property(strong, nonatomic) TitleView *titleView;
//@property(strong, nonatomic) MKMapView *mapView;
@property(strong, nonatomic) BMKMapView *mapView;

@end

@implementation SalonDetailViewController
@synthesize tablesView;
@synthesize company;
@synthesize scrollView;
@synthesize ImgList;
@synthesize pageControl;
@synthesize size_remark,size_addr,size_web,size_hours;
@synthesize contactTitleArray;
@synthesize titleArray;
@synthesize branchId;
@synthesize tag;
@synthesize businessName;
//@synthesize mapView;
@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    titleView = [[TitleView alloc] init];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [tablesView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 47.0f)];
    } else if (IOS6) {
        tablesView.frame = CGRectMake(-5.0f, titleView.frame.origin.y + titleView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 3.f);
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 0, 300, 140)];
    
    tablesView.separatorColor = kTableView_LineColor;
    tablesView.showsVerticalScrollIndicator = NO;
    tablesView.backgroundView = nil;
    tablesView.backgroundColor = [UIColor clearColor];
}

- (void)reloadData
{
    if (company.Latitude != 0 && company.Longitude != 0) {
        if (!_mapView) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 200.0f)];
            if ((IOS7 || IOS8))
                footerView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 200.0f);
            else
                footerView.frame = CGRectMake(10.0f, 0.0f, 290.0f, 200.0f);
            footerView.backgroundColor = [UIColor clearColor];
            [tablesView setTableFooterView:footerView];
            
             _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 310.0f, 200.0f)];
            _mapView.delegate = self;
            _mapView.zoomLevel = 16;
            _mapView.buildingsEnabled = YES;
            [_mapView setScrollEnabled:YES];
            [_mapView setMapType:BMKUserTrackingModeNone];
            
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude = company.Latitude;
            coor.longitude = company.Longitude;
            annotation.coordinate = coor;
            annotation.title = company.Name;
            annotation.subtitle = company.Address;
            [_mapView setCenterCoordinate:coor];
            [_mapView addAnnotation:annotation];
            [footerView addSubview:_mapView];
            
//            mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 200.0f)];
//            [mapView setScrollEnabled:NO];
//            [mapView setMapType:MKMapTypeStandard];
//            [mapView setRegion:MKCoordinateRegionMake([self transformFromWGSToGCJ:CLLocationCoordinate2DMake(company.Latitude,company.Longitude)], MKCoordinateSpanMake(0.01, 0.01))];
//            [footerView addSubview:mapView];

        }
        
//        [mapView removeAnnotations:mapView.annotations];
//        GPAnnotation *annotation = [[GPAnnotation alloc] init];
//        [annotation setTitle:company.Name];
//        [annotation setSubtitle:company.Address];
//        [annotation setCoordinate:[self transformFromWGSToGCJ:CLLocationCoordinate2DMake(company.Latitude,company.Longitude)]];
//        [mapView addAnnotation:annotation];

    }
    
    [tablesView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    contactTitleArray = [NSMutableArray arrayWithObjects:@"联系人", @"电话", @"传真", nil];
    titleArray = [NSMutableArray arrayWithObjects:@"图片", @"服务团队", @"简介", @"营业时间", @"联系人", @"网址", @"地址", nil];
    
    if (tag == 0)
        [self requestBusinessDetail:0];
    else
        [self requestBusinessDetail:branchId];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_companyDetailOperation || [_companyDetailOperation isExecuting]) {
        [_companyDetailOperation cancel];
        _companyDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [ImgList removeAllObjects];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((self.scrollView.contentOffset.x-150)/300) + 1 ;
    pageControl.currentPage = page;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *titleStr = [titleArray objectAtIndex:section];
    if ([titleStr isEqualToString:@"图片"]) {
        return 1;
    } else if ([titleStr isEqualToString:@"服务团队"]) {
        return 1;
    } else if ([titleStr isEqualToString:@"简介"]) {
        return 2;
    } else if ([titleStr isEqualToString:@"营业时间"]) {
        return 2;
    } else if ([titleStr isEqualToString:@"联系人"]) {
        return [contactTitleArray count];
    } else if ([titleStr isEqualToString:@"地址"]) {
        return 2;
    } else if ([titleStr isEqualToString:@"网址"]) {
        return 2;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = @"BusinessCell";
    TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    
    if ([titleStr isEqualToString:@"图片"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScrollCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScrollCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (scrollView != nil) {
            [scrollView removeFromSuperview];
        }
        scrollView.directionalLockEnabled = YES; //只能一个方向滑动
        scrollView.pagingEnabled = YES; //是否翻页
        scrollView.showsVerticalScrollIndicator =NO;
        scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
        scrollView.delegate = self;
        CGSize newSize = CGSizeMake(300 * [ImgList count], 140);
        [scrollView setContentSize:newSize];
        
        for (int i = 0 ; i<[ImgList count];i++){
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:[ImgList objectAtIndex:i]]];
            NSLog(@"width = %f      height = %f", imageView.frame.size.width, imageView.frame.size.height);
            [imageView setFrame:CGRectMake(300 * i + 10, 2, 280, 135)];
            [scrollView addSubview:imageView];
        }
        
        pageControl =[[UIPageControl alloc] initWithFrame:CGRectMake(125,140,60,10)];
        pageControl.backgroundColor =[UIColor clearColor];
        pageControl.numberOfPages = [ImgList count];
        pageControl.currentPage = 0;
        pageControl.hidesForSinglePage = YES;
        pageControl.currentPageIndicatorTintColor = kColor_LightBlue;
        pageControl.pageIndicatorTintColor = [UIColor grayColor];

        [cell.contentView addSubview:pageControl];
        [cell.contentView addSubview:scrollView];
        return cell;
    }
    else if ([titleStr isEqualToString:@"服务团队"]) {
        static NSString *twoCellIndentify = @"teamCell";
        TwoLabelCell *twoLabelCell = [tableView dequeueReusableCellWithIdentifier:twoCellIndentify];
        if (twoLabelCell == nil) {
            twoLabelCell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:twoCellIndentify];
            twoLabelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            twoLabelCell.selectionStyle = UITableViewCellSelectionStyleGray;
            CGRect textFrame = twoLabelCell.valueText.frame;
            textFrame.origin.x = textFrame.origin.x - 15.0f;
            twoLabelCell.valueText.frame = textFrame;
        }
        [twoLabelCell setTitle:@"服务团队"];
        [twoLabelCell setValue:[NSString stringWithFormat:@"(%ld)", (long)company.AccountCount] isEditing:NO];
        return twoLabelCell;
    }
    else if ([titleStr isEqualToString:@"简介"]) {
        if(indexPath.row == 0 ){
            [cell setTitle:@"简介"];
            [cell setValue:@"" isEditing:NO];
            return cell;
        }else{
            static NSString *cellIndentify = @"DetailCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:102];
            [detailLable setText:company.Summary];
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
           [detailLable setFrame:CGRectMake(10.0f, 3.0f, 300.0f, size_remark.height + 17)];
           //  [detailLable sizeToFit];
            detailLable.font = kFont_Light_16;
            return cell;
        }
    }
    else if ([titleStr isEqualToString:@"营业时间"]) {
        if(indexPath.row == 0 ){
            [cell setTitle:@"营业时间"];
            [cell setValue:@"" isEditing:NO];
            return cell;
        }else{
            static NSString *cellIndentify = @"DetailCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:102];
            [detailLable setText:company.BusinessHours];
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
            [detailLable setFrame:CGRectMake(10.0f, 3.0f, 300.0f, size_hours.height + 17)];
            detailLable.font = kFont_Light_16;
            return cell;
        }
    }
    else if ([titleStr isEqualToString:@"联系人"]) {
        NSString *contactTitleStr = [contactTitleArray objectAtIndex:indexPath.row];
        [cell setTitle:contactTitleStr];
        if([contactTitleStr isEqualToString:@"联系人"]){
            [cell setValue:company.Contact isEditing:NO];
            return cell;
        }else if([contactTitleStr isEqualToString:@"电话"]){
            [cell setValue:company.Phone isEditing:NO];
            return cell;
        }else{
            [cell setValue:company.Fax isEditing:NO];
            return cell;
        }
    }
    else if ([titleStr isEqualToString:@"地址"]) {
        if(indexPath.row == 0 ){
            [cell setTitle:@"地址"];
            [cell setValue:company.Zip isEditing:NO];
            return cell;
        }else{
            static NSString *cellIndentify = @"DetailCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:102];
            [detailLable setText:company.Address];
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
            [detailLable setFrame:CGRectMake(10.0f, 3.0f, 300.0f, size_addr.height + 17)];
            detailLable.font = kFont_Light_16;
            return cell;
        }
    }
    else if ([titleStr isEqualToString:@"网址"]) {
        if(indexPath.row == 0 ){
            [cell setTitle:@"网址"];
            [cell setValue:@"" isEditing:NO];
            return cell;
        }else{
            static NSString *cellIndentify = @"DetailCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:102];
            [detailLable setText:company.Web];
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
            [detailLable setFrame:CGRectMake(10.0f, 3.0f, 270.0f, size_web.height + 17)];
            detailLable.font = kFont_Light_16;
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"图片"]) {
        return 150;
    } else if ([titleStr isEqualToString:@"服务团队"]) {
        return 38;
    } else if ([titleStr isEqualToString:@"简介"]) {
        if(indexPath.row == 0){
            return 38;
        }else{
            size_remark = [company.Summary sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 420.0f)];
           // UITableViewCell *cell =[self tableView:tableView cellForRowAtIndexPath:indexPath];//add by zhangwei 2014.7.9;
           // UILabel *label = (UILabel*)[cell viewWithTag:102];
            //return label.frame.size.height;
            return size_remark.height + 25;
        }
    } else if ([titleStr isEqualToString:@"营业时间"]) {
        if(indexPath.row == 0){
            return 38;
        }else{
            size_hours = [company.BusinessHours sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 300.0f)];
            return size_hours.height + 20;
        }
    } else if ([titleStr isEqualToString:@"联系人"]) {
        return 38;
    } else if ([titleStr isEqualToString:@"地址"]) {
        if(indexPath.row == 0){
            return 38;
        }else{
            size_addr = [company.Address sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 155.0f)];
            return size_addr.height + 20;
        }
    } else if ([titleStr isEqualToString:@"网址"]) {
        if(indexPath.row == 0){
            return 38;
        }else{
            size_web = [company.Web sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 155.0f)];
            return size_web.height + 20;
        }
    } else {
        return 38;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 5.0f;
    } else {
        return kTableView_Margin;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [titleArray objectAtIndex:indexPath.section];
    if ([str isEqualToString:@"服务团队"]) {
        [self performSelector:@selector(goAccountListViewController) withObject:nil afterDelay:0.0f];
    }
}

- (void)goAccountListViewController
{
    AccountListViewController *accountListViewController = (AccountListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AccountList"];
    
    NSInteger beautySalonNumber = [[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_BRANCHCOUNT"] integerValue];
    if (beautySalonNumber == 1) {
        accountListViewController.branchId = 0;
        accountListViewController.requestType = 1;
        accountListViewController.businessName = businessName;
    } else {
        if (tag == 0) {
            accountListViewController.branchId = 0;
            accountListViewController.requestType = 1;
            accountListViewController.businessName = businessName;
        }
        else {
            accountListViewController.branchId = branchId;
            accountListViewController.requestType = 2;
            accountListViewController.businessName = businessName;
        }
    }
    
    [self.navigationController pushViewController:accountListViewController animated:YES];
}

//#pragma mark - 地图坐标转换（WGS-84 --> GCJ-02）
//
//- (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc
//{
//    CLLocationCoordinate2D adjustLoc;
//    if([self isLocationOutOfChina:wgsLoc]){
//        adjustLoc = wgsLoc;
//    }else{
//        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
//        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
//        double radLat = wgsLoc.latitude / 180.0 * pi;
//        double magic = sin(radLat);
//        magic = 1 - ee * magic * magic;
//        double sqrtMagic = sqrt(magic);
//        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
//        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
//        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
//        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
//    }
//    return adjustLoc;
//}
//
//- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
//{
//    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
//        return YES;
//    return NO;
//}
//
//- (double)transformLatWithX:(double)x withY:(double)y
//{
//    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
//    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
//    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
//    lat += (160.0 * sin(y / 12.0 * pi) + 3320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
//    return lat;
//}
//
//- (double)transformLonWithX:(double)x withY:(double)y
//{
//    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
//    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
//    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
//    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
//    return lon;
//}

#pragma mark - 接口

- (void)requestBusinessDetail:(NSInteger)businessId
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *par = [NSString stringWithFormat:@"{\"BranchID\":%ld,\"ImageHeight\":%d,\"ImageWidth\":%d}", (long)businessId, 270, 560];
    _companyDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Company/GetBusinessDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            CompanyDoc *tempDoc = [[CompanyDoc alloc] initWithDictionary:data];
            if (businessId == 0)
                [tempDoc setAccountCount:0];

            businessName = tempDoc.Name;
            company = tempDoc;
            ImgList = [[NSMutableArray alloc] initWithArray:tempDoc.ImageURL];

            [self.view addSubview:[titleView getTitleView:company.Name]];
            
            NSMutableArray *deleteArray = [NSMutableArray array];
            
            if(company.Contact.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:0]];
            }
            
            if(company.Phone.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:1]];
            }
            
            if(company.Fax.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:2]];
            }
            
            [contactTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if(company.ImageCount == 0){
                [deleteArray addObject:[titleArray objectAtIndex:0]];
            }
            
            if(company.AccountCount == 0){
                [deleteArray addObject:[titleArray objectAtIndex:1]];
            }
            
            if(company.Summary.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:2]];
            }
            
            if(company.BusinessHours.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:3]];
            }
            
            if([contactTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:4]];
            }
            
            if(company.Web.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:5]];
            }
            
            if(company.Address.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:6]];
            }
            
            [titleArray removeObjectsInArray:deleteArray];
            
            [self reloadData];

        } failure:^(NSInteger code, NSString *error) {}];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
    /*
    _companyDetailOperation = [[GPHTTPClient shareClient] requestBusinessDetailWithAccountId:businessId success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD dismiss];
            CompanyDoc *tempDoc = [[CompanyDoc alloc] init];
            [tempDoc setName:[[[contentData elementsForName:@"Name"] objectAtIndex:0] stringValue]];
            [tempDoc setSummary:[[[contentData elementsForName:@"Summary"] objectAtIndex:0]stringValue]];
            [tempDoc setContact:[[[contentData elementsForName:@"Contact"] objectAtIndex:0] stringValue]];
            [tempDoc setPhone:[[[contentData elementsForName:@"Phone"] objectAtIndex:0]stringValue]];
            [tempDoc setFax:[[[contentData elementsForName:@"Fax"] objectAtIndex:0] stringValue]];
            [tempDoc setZip:[[[contentData elementsForName:@"Zip"] objectAtIndex:0]stringValue]];
            [tempDoc setAddress:[[[contentData elementsForName:@"Address"] objectAtIndex:0]stringValue]];
            [tempDoc setWeb:[[[contentData elementsForName:@"Web"] objectAtIndex:0]stringValue]];
            [tempDoc setBusinessHours:[[[contentData elementsForName:@"BusinessHours"] objectAtIndex:0]stringValue]];
            [tempDoc setImageCount:[[[[contentData elementsForName:@"ImageCount"] objectAtIndex:0] stringValue] intValue]];
            if (businessId == 0)
               [tempDoc setAccountCount:0];
            else
                [tempDoc setAccountCount:[[[[contentData elementsForName:@"AccountCount"] objectAtIndex:0] stringValue] intValue]];
            [tempDoc setLongitude:[[[[contentData elementsForName:@"Longitude"] objectAtIndex:0] stringValue] floatValue]];
            [tempDoc setLatitude:[[[[contentData elementsForName:@"Latitude"] objectAtIndex:0] stringValue] floatValue]];
            businessName = tempDoc.Name;
            company = tempDoc;
            ImgList = [[NSMutableArray alloc] init];
//            for (GDataXMLElement *data in [contentData elementsForName:@"ImageURL"]) {
//                NSString *resultStr = [data stringValue];
//                [ImgList addObject:resultStr];
//            }
            
            [self.view addSubview:[titleView getTitleView:company.Name]];
            
            NSMutableArray *deleteArray = [NSMutableArray array];
            
            if(company.Contact.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:0]];
            }
            
            if(company.Phone.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:1]];
            }
            
            if(company.Fax.length == 0){
                [deleteArray addObject:[contactTitleArray objectAtIndex:2]];
            }
            
            [contactTitleArray removeObjectsInArray:deleteArray];
            [deleteArray removeAllObjects];
            
            if(company.ImageCount == 0){
                [deleteArray addObject:[titleArray objectAtIndex:0]];
            }
            
            if(company.AccountCount == 0){
                [deleteArray addObject:[titleArray objectAtIndex:1]];
            }
            
            if(company.Summary.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:2]];
            }
            
            if(company.BusinessHours.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:3]];
            }
            
            if([contactTitleArray count] == 0){
                [deleteArray addObject:[titleArray objectAtIndex:4]];
            }
            
            if(company.Web.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:5]];
            }
            
            if(company.Address.length == 0){
                [deleteArray addObject:[titleArray objectAtIndex:6]];
            }
            
            [titleArray removeObjectsInArray:deleteArray];
            
            [self reloadData];
        } failure:^{
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ address:%s",error.description, __FUNCTION__);
    }];
     
     */
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
   
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"renameMark"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        // 设置可拖拽
        newAnnotationView.draggable = YES;
        return newAnnotationView;
    }
    return nil;
}

@end
