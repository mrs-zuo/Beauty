//
//  FirstViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#define ImageScrollHeight  200.0f


#import "FirstViewController.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "BusinessInfoModel.h"
#import "BusinessInfoCell.h"


@interface FirstViewController ()<UIWebViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>
@property(weak  , nonatomic) AFHTTPRequestOperation *companyDetailOperation;
@property (nonatomic, strong) BusinessInfoModel *busInfo;
@property (nonatomic, strong) NSArray *fatModelArray;


@property (nonatomic, strong) UIWebView *phoneCallWebView;
@property (nonatomic, strong) UIWebView *urlWebView;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *url;


@property (nonatomic,strong) UIView *headView;
@property (nonatomic, strong)UIScrollView *imageScrollView;

@end

@implementation FirstViewController

static NSString *cellindity = @"BusinessCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)initTableView
{
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    if (self.busInfo.ImageURL.count > 0) {
    if (!_headView) {
            _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, ImageScrollHeight)];
            _imageScrollView  =[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, ImageScrollHeight)];
            _imageScrollView.delegate = self;
            _imageScrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width *self.busInfo.ImageURL.count , ImageScrollHeight);
            _imageScrollView.showsHorizontalScrollIndicator =NO;
            _imageScrollView.showsVerticalScrollIndicator = NO;
            _imageScrollView.directionalLockEnabled = YES;
            if (self.busInfo.ImageURL.count) {
                for (int i = 0 ; i < self.busInfo.ImageURL.count; i ++) {
                    UIImageView *imageView  = [[UIImageView alloc]initWithFrame:CGRectMake(10 + kSCREN_BOUNDS.size.width * i, 0, kSCREN_BOUNDS.size.width - 20, ImageScrollHeight)];
                    NSString *url = self.busInfo.ImageURL[i];
                    [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        
                    }] ;
                    [_imageScrollView addSubview:imageView];
                }
            }
            UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(10, ImageScrollHeight - 20, kSCREN_BOUNDS.size.width - 20, 20)];
            pageControl.numberOfPages = self.busInfo.ImageURL.count;
            [pageControl addTarget:self action:@selector(pageControlEvent:) forControlEvents:UIControlEventValueChanged];
            [_headView addSubview:_imageScrollView];
            [_headView addSubview:pageControl];
            [self.tableView setTableHeaderView:_headView];
        }
    }else{
        self.tableView.frame = CGRectMake(0, -40, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 40);
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[BusinessInfoCell class] forCellReuseIdentifier:cellindity];
    self.tableView.separatorColor = kTableView_LineColor;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestBusinessDetail];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fatModelArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.fatModelArray objectAtIndex:indexPath.row];
    NSString *title = dic[@"Title"];
    NSString *content = dic[@"Content"];
    if (title.length == 0) {
        
        CGRect tempRect = [content boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
        CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
        if (lines > 1) {
            return tempRect.size.height + (lines * 5) + 20;
        }else {
            return kTableView_DefaultCellHeight;
        }

    }
    return kTableView_DefaultCellHeight;
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
    NSDictionary *dic = [self.fatModelArray objectAtIndex:indexPath.row];
    busCell.infoDic = dic;
    return busCell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.fatModelArray objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"Title"];
    self.hidesBottomBarWhenPushed = YES;
    if ([title isEqualToString:@"网址简介"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"打开网址" message:[NSString stringWithFormat:@"%@%@",@"网址:",[dic objectForKey:@"Content"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _url = [dic objectForKey:@"Content"];
        alertView.tag = 998;
        [alertView show];

    }
    if ([title isEqualToString:@"电话"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:[NSString stringWithFormat:@"%@%@",@"呼叫:",[dic objectForKey:@"Content"] ] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        _phoneNumber = [dic objectForKey:@"Content"];
        alertView.tag = 999;
    
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        if (alertView.tag == 998) {
            [self openThisUrl:_url];
        }
        if (alertView.tag == 999) {
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


#pragma mark - 接口
- (void)requestBusinessDetail
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSDictionary *para = @{@"BranchID":@0,
                           @"ImageHeight":@300,
                           @"ImageWidth":@400};
    _companyDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Company/getBusinessDetail"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            self.busInfo = [[BusinessInfoModel alloc] initWithDic:data];
            self.fatModelArray = [self.busInfo businessInfoHandle];
            [self.parentViewController setValue:self.busInfo.ImageURL forKey:@"imageList"];
            [self initTableView];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
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
