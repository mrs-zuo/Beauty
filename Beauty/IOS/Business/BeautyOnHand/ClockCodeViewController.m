//
//  ClockCodeViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/30.
//  Copyright © 2016年 ace-009. All rights reserved.
//

const NSInteger kTimeInterval = 60;

#import "ClockCodeViewController.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "UIImageView+WebCache.h"
#import "NavigationView.h"
#import "AttendanceCodeTableViewCell.h"


@interface ClockCodeViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak ,nonatomic)  AFHTTPRequestOperation * requestAttendanceQRCodeOperation;

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NavigationView *navigationView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger currentTime;
@property (nonatomic,strong) NSURL *attendanceUrl;



@end

@implementation ClockCodeViewController
-(void)dealloc
{
    [self removeTimer];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTimer];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self requestGetAttendanceQRCode];
    [self initTimer];
}
- (void)initView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"考勤码"];
    [self.view addSubview:self.navigationView];
    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderRefresh"] selector:@selector(filterOpp)];

    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW + 5), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )style:UITableViewStyleGrouped];
    _myTableView.showsHorizontalScrollIndicator = NO;
    _myTableView.showsVerticalScrollIndicator = NO;
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorColor = kTableView_LineColor;
    _myTableView.autoresizingMask = UIViewAutoresizingNone;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_myTableView setTableFooterView:view];
    [self.view addSubview:_myTableView];
    
    if ((IOS7 || IOS8)) {
        _myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }



}
- (void)initData
{
    _currentTime = 0;
}
#pragma mark - timer
- (void)removeTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
- (void)initTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerRun:) userInfo:self repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)timerRun:(NSTimer *)timer
{
    _currentTime ++;
    if ((_currentTime % kTimeInterval) == 0) {
        [self requestGetAttendanceQRCode];
    }
}

#pragma mark - 按钮事件
- (void)filterOpp
{
    _currentTime = 0;
    [self requestGetAttendanceQRCode];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"AttendanceCell";
    AttendanceCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"AttendanceCodeTableViewCell" owner:self options:nil].firstObject;
    }
    [cell.attendanceImgView setImageWithURL:self.attendanceUrl placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 接口
-(void)requestGetAttendanceQRCode
{
//    /Account/GetAttendanceQRCode 生成二维码
//    所需参数
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    _requestAttendanceQRCodeOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/GetAttendanceQRCode" andParameters:nil failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            self.attendanceUrl = data;
            [_myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                
            }];
        }];
    } failure:^(NSError *error) {
    
    }];
}
@end


