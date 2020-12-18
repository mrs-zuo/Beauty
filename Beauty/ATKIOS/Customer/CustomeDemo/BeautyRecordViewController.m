//
//  BeautyRecordViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyRecordViewController.h"
#import "UIButton+InitButton.h"
#import "GPHTTPClient.h"
#import "BeautyRecordPhotoTableViewCell.h"
#import "NSDate+Convert.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "BeautyRecordRes.h"
#import "SelectYearView.h"
#import "BeautyRecordDetailsViewController.h"

const CGFloat yearView_Height = 256;
const CGFloat kHeight = 3.0;

@interface BeautyRecordViewController () <UITableViewDataSource,UITableViewDelegate>
{
    SelectYearView *yearView;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetCustomerRecPicOperation;
@property (nonatomic,strong) UITableView *beautyRecordTableView;
@property (nonatomic,strong) NSMutableArray *beautyRecordDatas;
@property (nonatomic,strong) NSString *yearString;

@end

@implementation BeautyRecordViewController

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getCustomerRecPic];
}
- (void)initData
{
    self.title = @"美丽记录";
    _beautyRecordDatas = [NSMutableArray array];
}
- (void)initView
{
    self.view.backgroundColor = kDefaultBackgroundColor;

    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavigationBar_Height, kSCREN_BOUNDS.size.width, 44)];
    //topView.backgroundColor = RGBA(241, 241, 241, 1);
    topView.backgroundColor=kDefaultBackgroundColor;
    [self.view addSubview:topView];

    UILabel *yearLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, kSCREN_BOUNDS.size.width - 20 - 44, 44)];
    self.yearString = [NSDate stringFromDate:[NSDate date]];
    yearLab.font=kNormalFont_14;
    yearLab.text  = [NSString stringWithFormat:@"%@年",[self.yearString substringToIndex:4]];
    [topView addSubview:yearLab];
    UIImage *image = [UIImage imageNamed:@"order_select"];
    UIButton *rightButton  = [UIButton buttonWithTitle:nil target:self selector:@selector(selectYear:) frame:CGRectMake(kSCREN_BOUNDS.size.width - 44, 0,44, 44) backgroundImg:image highlightedImage:nil];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:rightButton];
    
    _beautyRecordTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,kNavigationBar_Height + 44, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 44 + 20) style:UITableViewStyleGrouped];
    _beautyRecordTableView.dataSource = self;
    _beautyRecordTableView.delegate = self;
    _beautyRecordTableView.separatorColor = kTableView_LineColor;
    _beautyRecordTableView.showsHorizontalScrollIndicator = NO;
    _beautyRecordTableView.showsVerticalScrollIndicator = NO;
    _beautyRecordTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_beautyRecordTableView];
    
    yearView = [[SelectYearView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height + 20, kSCREN_BOUNDS.size.width, yearView_Height)];
    yearView.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    yearView.disSelectYearViewBlock = ^(NSString *yearStr){
        [weakSelf dismissYearView];
    };
    yearView.selectYearViewBlock = ^(NSString *yearStr){
        if (yearStr) {
            weakSelf.yearString = yearStr;
        }
        yearLab.text  = [NSString stringWithFormat:@"%@年",[ weakSelf.yearString substringToIndex:4]];
        [weakSelf dismissYearView];
        [weakSelf getCustomerRecPic];
    };
    [self.view addSubview:yearView];

 
}

#pragma mark -  UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeautyRecordRes *beautyRes = [_beautyRecordDatas objectAtIndex:indexPath.section];
    if (indexPath.row == 0) {
        return kTableView_DefaultCellHeight;
    }else{
        const CGFloat interval = 10.0f;
        const CGFloat imageView_Height = (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
        if (beautyRes.imageURLArrs.count > 0) {
            NSInteger col;
            if (beautyRes.imageURLArrs.count % 4 == 0) {
                col = beautyRes.imageURLArrs.count / 4;
            }else{
                col = beautyRes.imageURLArrs.count / 4 + 1;
            }
            return (col  * imageView_Height) + 20;
        }else{
            return 0;
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _beautyRecordDatas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BeautyRecordRes *beautyRes = [_beautyRecordDatas objectAtIndex:section];
    return  beautyRes.imageURLArrs > 0 ? 2 : 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.row == 0) {
        static  NSString *identifier = @"Cell";
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        BeautyRecordRes *beautyRes = [_beautyRecordDatas objectAtIndex:indexPath.section];
        cell.textLabel.text = beautyRes.serviceName;
        cell.textLabel.font=kNormalFont_14;
        CGRect rect=cell.frame;
        rect.origin.x=10;
        cell.textLabel.frame=rect;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
    NSString *identifier = [NSString stringWithFormat:@"PhotoCell%ld",(long)indexPath.section];
      BeautyRecordPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BeautyRecordPhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        BeautyRecordRes *beautyRes = [_beautyRecordDatas objectAtIndex:indexPath.section];
        cell.data = beautyRes.imageURLArrs;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //从二级菜单返回，直接是非选中状态
    self.hidesBottomBarWhenPushed = YES;
    if (indexPath.row == 0) {
        BeautyRecordRes *beautyRes = [_beautyRecordDatas objectAtIndex:indexPath.section];
        BeautyRecordDetailsViewController *beautyDetailsVC = [[BeautyRecordDetailsViewController alloc]init];
        beautyDetailsVC.serviceName = beautyRes.serviceName;
        beautyDetailsVC.serviceCode = beautyRes.serviceCode;
        beautyDetailsVC.serviceYear = [self.yearString substringToIndex:4];
        [self.navigationController  pushViewController:beautyDetailsVC animated:YES];
    }
}

#pragma mark - 事件
- (void)selectYear:(UIButton *)sender
{
    [self showYearView];
}

- (void)showYearView
{
    [UIView animateWithDuration:0.35  delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        yearView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height - yearView_Height + 20, kSCREN_BOUNDS.size.width, yearView_Height);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dismissYearView
{
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        yearView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height + 20, kSCREN_BOUNDS.size.width, yearView_Height);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 接口

-(void)getCustomerRecPic{
    
//    /image/getCustomerRecPic 获取年度所有记录
//    所需参数
//    {"ServiceYear":2015,"ImageWidth":160,"ImageHeight":160}
    
    NSDictionary *paraGet = @{@"ServiceYear":[self.yearString substringToIndex:4],
                              @"ImageWidth":@(160),
                              @"ImageHeight":@(160)};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetCustomerRecPicOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/getCustomerRecPic"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if([data isKindOfClass:[NSArray class]]){
                [self.beautyRecordDatas removeAllObjects];
                NSArray *arrs = (NSArray *)data;
                if (arrs.count > 0) {
                    for (int i = 0 ; i < arrs.count; i ++) {
                        NSDictionary *dic = arrs[i];
                        BeautyRecordRes *beautyRes = [[BeautyRecordRes alloc]init];
                        beautyRes.serviceName = [dic objectForKey:@"ServiceName"];
                        beautyRes.serviceCode = [dic objectForKey:@"ServiceCode"];
                        beautyRes.imageURLArrs = [dic objectForKey:@"ImageURL"];
                        [self.beautyRecordDatas addObject:beautyRes];
                    }
                }
            }
            [_beautyRecordTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}



@end
