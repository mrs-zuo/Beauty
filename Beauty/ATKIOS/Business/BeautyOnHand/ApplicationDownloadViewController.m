//
//  ApplicationDownloadViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-10-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ApplicationDownloadViewController.h"
#import "GPHTTPClient.h"
#import "NavigationView.h"
#import "UIImageView+WebCache.h"
@interface ApplicationDownloadViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestAppDownloadOperation;
@property (assign, nonatomic) int currentPage;
@property (strong , nonatomic) UIScrollView *myScrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *mutableImgArray;
@end

@implementation ApplicationDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"应用下载"];
    [self.view addSubview:navigationView];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _imageArray = [[NSMutableArray alloc] init];
    _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10,51, 300, 288)];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake( 81, _myScrollView.frame.origin.y +_myScrollView.frame.size.height + 10, 157, 36)];
    _myScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_myScrollView];
    [self.view addSubview:_pageControl];
    [self getAppDownload];
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}
- (void)viewDidUnload {
    [self setPageControl:nil];
    [self setMyScrollView:nil];
    [super viewDidUnload];
}

-(void)reloadScroll
{
    [self addData];
    _myScrollView.pagingEnabled = YES;
    _myScrollView.bounces = NO;
    _myScrollView.delegate = self;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.directionalLockEnabled = YES; //只能一个方向滑动
    _myScrollView.showsVerticalScrollIndicator =NO;
    
    _pageControl.layer.cornerRadius = 8.f;
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;
    _pageControl.enabled = YES;
}
-(void)addData
{
    if (_mutableImgArray == nil) {
        _mutableImgArray = [NSMutableArray array];
    }
    [_mutableImgArray addObjectsFromArray:_imageArray];
    [_mutableImgArray addObjectsFromArray:_imageArray];
    
    _myScrollView.contentSize = CGSizeMake(_myScrollView.frame.size.width * 2, _myScrollView.frame.size.height);
    
    UIImageView *customerImage = [[UIImageView alloc] init];
    [customerImage setImageWithURL:[NSURL URLWithString:@"http://beauty.glamise.com/assets/img/adkcustomerdownload.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [_imageArray addObject:[NSNumber numberWithInt:0]];
        
    }];
    
    customerImage.frame =  CGRectMake(20, 35, _myScrollView.frame.size.width - 45, _myScrollView.frame.size.width - 45);
    
    UILabel *customerLabel =  [[UILabel alloc] init];
    customerLabel.text = @"客户端下载";
    customerLabel.font = kFont_Light_16;
    customerLabel.frame = CGRectMake(_myScrollView.frame.size.width/2 - 38, 0, _myScrollView.frame.size.width/2 - 40, 30);
    customerLabel.backgroundColor = [UIColor clearColor];
    [_myScrollView addSubview:customerImage];
    [_myScrollView addSubview:customerLabel];
    
    UIImageView *businessImage = [[UIImageView alloc] init];
    [businessImage setImageWithURL:[NSURL URLWithString:@"http://beauty.glamise.com/assets/img/adkbusinessdownload.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [_imageArray addObject:[NSNumber numberWithInt:1]];
    }];

    businessImage.frame = CGRectMake(_myScrollView.frame.size.width + 20, 35, _myScrollView.frame.size.width - 45,  _myScrollView.frame.size.width - 45);
    
    UILabel *businessLabel =  [[UILabel alloc] init];
    businessLabel.text = @"商家端下载";
    businessLabel.font = kFont_Light_16;
    businessLabel.frame = CGRectMake( _myScrollView.frame.size.width + _myScrollView.frame.size.width/2 - 38, 0, _myScrollView.frame.size.width/2 - 40, 30);
    businessLabel.backgroundColor = [UIColor clearColor];
    [_myScrollView addSubview:businessImage];
    [_myScrollView addSubview:businessLabel];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -ScrollDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth=self.myScrollView.frame.size.width;
    CGFloat pageHeigth=self.myScrollView.frame.size.height;
    _currentPage = floor((_myScrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    
    self.pageControl.currentPage = _currentPage % _imageArray.count;
    
    if (_currentPage == 0) {
        if (_imageArray.count != 1) {
            [self.myScrollView scrollRectToVisible:CGRectMake(pageWidth * _imageArray.count, 0, pageWidth, pageHeigth) animated:NO];
            return;
        } else {
            return;
        }
    }else  if(_currentPage == [_mutableImgArray count] - 1){
        [self.myScrollView scrollRectToVisible:CGRectMake(pageWidth * ([_imageArray count] -1), 0, pageWidth, pageHeigth) animated:NO];
        return;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollView  page is %ld", (long)_pageControl.currentPage);
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"scrollView  page is %ld  %f   %f   %f   %f", (long)_pageControl.currentPage, velocity.x, velocity.y, targetContentOffset->x, targetContentOffset->y);
    if( _pageControl.currentPage == 0 && velocity.x < 0)
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)getAppDownload
{
   // _requestAppDownloadOperation = [GPHTTPClient shareClient] ;
    [self reloadScroll];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
