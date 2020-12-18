//
//  BeautyRecordDetailsViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "BeautyRecordDetailsViewController.h"
#import "UIButton+InitButton.h"
#import "GPHTTPClient.h"
#import "BeautyRecordPhotoTableViewCell.h"
#import "NSDate+Convert.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "BeautyRecordRes.h"
#import "SelectYearView.h"
#import "BeautyRecordDetailsRes.h"
#import "BranchShopRes.h"
#import "BeautyRecordDetailsOneTableViewCell.h"
#import "BeautyEditViewController.h"
#import "BeautyCommentsTableViewCell.h"
#import <ShareSDK/ShareSDK.h>
const CGFloat kHeight = 3.0;




@interface BeautyRecordDetailsViewController ()  <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestShareGroupNoOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetCustomerServicePicOperation;
@property (nonatomic,strong) UITableView *beautyRecordDetailsTableView;
@property (nonatomic,strong) NSMutableArray *beautyRecordDetailsDatas;

@end

@implementation BeautyRecordDetailsViewController

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getCustomerServicePic];
}
- (void)initData
{
    self.title = @"美丽记录";
    self.beautyRecordDetailsDatas = [NSMutableArray array];

}
- (void)initView
{
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    
    CGRect rect = [self.serviceName boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:kNormalFont_14} context:nil];

    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavigationBar_Height, kSCREN_BOUNDS.size.width,  (rect.size.height + 10)<44 ? 44:(rect.size.height + 10))];
    //topView.backgroundColor = RGBA(241, 241, 241, 1);
    topView.backgroundColor=kDefaultBackgroundColor;
    
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10,(topView.frame.size.height -rect.size.height)/2,kSCREN_BOUNDS.size.width-20, rect.size.height)];
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.font=kNormalFont_14;
    nameLab.text  = self.serviceName;
    nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLab.numberOfLines = 0;
    
    [topView addSubview:nameLab];
    
    [self.view addSubview:topView];
    
    _beautyRecordDetailsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,kNavigationBar_Height + 44, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height - 44 + 20) style:UITableViewStyleGrouped];
    _beautyRecordDetailsTableView.dataSource = self;
    _beautyRecordDetailsTableView.delegate = self;
    _beautyRecordDetailsTableView.separatorColor = kTableView_LineColor;
    _beautyRecordDetailsTableView.showsHorizontalScrollIndicator = NO;
    _beautyRecordDetailsTableView.showsVerticalScrollIndicator = NO;
    _beautyRecordDetailsTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_beautyRecordDetailsTableView];
    
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
    BeautyRecordDetailsRes *beautyDetailsRes = _beautyRecordDetailsDatas.firstObject;
    BranchShopRes *shopRes = [beautyDetailsRes.servicePicArrs objectAtIndex:indexPath.section];
    NSString *title = shopRes.rowDatas[indexPath.row];
    if ([title isEqualToString:@"照片"]){
        const CGFloat interval = 10.0f;
        const CGFloat imageView_Height = (kSCREN_BOUNDS.size.width - (5 * interval)) / 4;
        if (shopRes.imageURLArrs.count > 0) {
            NSInteger col;
            if (shopRes.imageURLArrs.count % 4 == 0) {
                col = shopRes.imageURLArrs.count / 4;
            }else{
                 col = shopRes.imageURLArrs.count / 4 + 1;
            }
            return (col  * imageView_Height) + 20;
        }else{
            return 0;
        }
    }else if ([title isEqualToString:@"心情"]){
        CGRect rect = [shopRes.comments boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:kNormalFont_14} context:nil];
        return rect.size.height > kTableView_DefaultCellHeight? rect.size.height : kTableView_DefaultCellHeight;
    }else{
        return kTableView_DefaultCellHeight;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   BeautyRecordDetailsRes *beautyDetailsRes = _beautyRecordDetailsDatas.firstObject;
    return beautyDetailsRes.servicePicArrs.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BeautyRecordDetailsRes *beautyDetailsRes = _beautyRecordDetailsDatas.firstObject;
    BranchShopRes *shopRes = [beautyDetailsRes.servicePicArrs objectAtIndex:section];
    if (shopRes.rowDatas) {
        [shopRes.rowDatas removeAllObjects];
    }
    if (shopRes.imageURLArrs && shopRes.imageURLArrs.count > 0) {
        NSArray *arrs = @[@"服务",@"照片",@"心情"];
        [shopRes.rowDatas addObjectsFromArray:arrs];
    }else{
        NSArray *arrs = @[@"服务",@"心情"];
        [shopRes.rowDatas addObjectsFromArray:arrs];
    }
    return shopRes.rowDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeautyRecordDetailsRes *beautyDetailsRes = _beautyRecordDetailsDatas.firstObject;
    BranchShopRes *shopRes = [beautyDetailsRes.servicePicArrs objectAtIndex:indexPath.section];
    NSString *title = shopRes.rowDatas[indexPath.row];
    
    if ([title isEqualToString:@"服务"]) {
        NSString *identifier = [NSString stringWithFormat:@"DetailsOneCell%ld",(long)indexPath.section];

        BeautyRecordDetailsOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"BeautyRecordDetailsOneTableViewCell" owner:self options:nil].firstObject;
        }
        cell.dateLab.font=kNormalFont_14;
        cell.dateLab.text =shopRes.TGStartTime;
        cell.branchLab.text = shopRes.branchName;
        cell.branchLab.font=kNormalFont_14;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        __weak typeof(self) weakSelf = self;
        cell.editBlock = ^(UIButton *button){
            BeautyEditViewController *beautyEditVC = [[BeautyEditViewController alloc]init];
            BeautyRecordDetailsOneTableViewCell *selectCell;
            if (IOS7) { // IOS7层级结构不同
               selectCell=  (BeautyRecordDetailsOneTableViewCell *)button.superview.superview.superview;
            }else{
               selectCell =  (BeautyRecordDetailsOneTableViewCell *)button.superview.superview;
            }
            NSIndexPath *selectIndexPath = [tableView indexPathForCell:selectCell];
            BranchShopRes *shopRes = [beautyDetailsRes.servicePicArrs objectAtIndex:selectIndexPath.section];
            beautyEditVC.shopRes = shopRes;
            [weakSelf.navigationController pushViewController:beautyEditVC animated:YES];
        };
        cell.shareBlock = ^(UIButton *button){
            BeautyRecordDetailsOneTableViewCell *selectCell =  (BeautyRecordDetailsOneTableViewCell *)button.superview.superview;
            NSIndexPath *selectIndexPath = [tableView indexPathForCell:selectCell];
            BranchShopRes *shopRes = [beautyDetailsRes.servicePicArrs objectAtIndex:selectIndexPath.section];
            [weakSelf requestShareGroupNo:shopRes];
        };
        return cell;
    }else  if ([title isEqualToString:@"照片"]){
        NSString *identifier = [NSString stringWithFormat:@"PhotoCell%ld",(long)indexPath.section];
        BeautyRecordPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[BeautyRecordPhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.data = shopRes.imageURLArrs;
        return cell;
    }else{
            static  NSString *identifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
        cell.textLabel.font=kNormalFont_14;
        if (shopRes.comments.length > 0) {
            cell.textLabel.text = @"";
            cell.textLabel.textColor = kColor_Black;
            cell.textLabel.text = shopRes.comments;
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"还没有写心情,赶快留下你的心情吧！";
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark - 
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UITableView class]]) {
        return NO;
    }
    return YES;
}
#pragma mark - 分享
- (void)share:(NSString *)urlStr
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"美丽分享"]
                                       defaultContent:nil
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"美丽分享"
                                                  url:urlStr
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建iPad弹出菜单容器,详见第六步
    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}
#pragma mark - 接口

-(void)getCustomerServicePic{
    
//    /image/getCustomerServicePic 获取项目图片
//    所需参数
//    {"ServiceCode":2012568547854,"ServiceYear":2015,"ImageWidth":160,"ImageHeight":160}
    NSDictionary *paraGet = @{@"ServiceCode":self.serviceCode,
                              @"ServiceYear":self.serviceYear,
                              @"ImageWidth":@(160),
                              @"ImageHeight":@(160)};
        [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetCustomerServicePicOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/getCustomerServicePic"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [_beautyRecordDetailsDatas removeAllObjects];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)data;
             BeautyRecordDetailsRes *beautyDetailsRes = [[BeautyRecordDetailsRes alloc]init];
                beautyDetailsRes.serviceCode = [dic objectForKey:@"ServiceCode"];
                beautyDetailsRes.serviceName = [dic objectForKey:@"ServiceName"];
                NSArray *servicePicList = [dic objectForKey:@"ServicePicList"];
                if (![servicePicList isKindOfClass:[NSNull class]] && servicePicList.count > 0) {
                    for (int i =0 ; i< servicePicList.count; i ++) {
                        NSDictionary *dic = servicePicList[i];
                        BranchShopRes *shopRes = [[BranchShopRes alloc]init];
                        shopRes.TGStartTime = [dic objectForKey:@"TGStartTime"];
                        shopRes.branchID = [dic objectForKey:@"BranchID"];
                        shopRes.branchName = [dic objectForKey:@"BranchName"];
                        shopRes.comments = [dic objectForKey:@"Comments"];
                        shopRes.groupNo = [dic objectForKey:@"GroupNo"];
                        shopRes.imageURLArrs = [dic objectForKey:@"ImageURL"];
                        [beautyDetailsRes.servicePicArrs addObject:shopRes];
                    }
                }
                [_beautyRecordDetailsDatas addObject:beautyDetailsRes];
                [_beautyRecordDetailsTableView reloadData];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)requestShareGroupNo:(BranchShopRes *)branchShopRes
{
    //    /ShareToOther/ShareGroupNo
    //    参数 GroupNo
    //
    NSNumber  *type;
    NSString *serviceURLStr  = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"];
    if ([serviceURLStr isEqualToString:kGPBaseURLString_Test]) {
        type = @(2);
    }else{
        type = @(1);
    }
    NSDictionary *paraGet = @{@"GroupNo":branchShopRes.groupNo,@"Type":type};
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestShareGroupNoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ShareToOther/ShareGroupNo"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if([data isKindOfClass:[NSString class]]){
                NSString *urlStr = (NSString *)data;
                [self share:urlStr];
            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


@end
