
//
//  IndexViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/18.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

const CGFloat ktitleLabHeight = 20.0;
const CGFloat kSectionView_Height = 40.0;
const CGFloat kCell_Height = 113.0;

#import "IndexViewController.h"
#import "DCPicScrollView.h"
#import "DCWebImageManager.h"
#import "IndexCollectionViewCell.h"
#import "UIButton+InitButton.h"
#import "SectionView.h"
#import "IndexTableViewCell.h"
#import "ServiceOneViewController.h"
#import "CategoryOneViewController.h"
#import "ChooseCompanyViewController.h"
#import "SalesPromotionNewViewController.h"
#import "AppraiseViewController.h"
#import "BusinessInfoViewController.h"
#import "RemindViewController.h"
#import "GPCHTTPClient.h"
#import "CustomerInfoRes.h"
#import "RecommendedProductListRes.h"
#import "PromotionListRes.h"
#import "PromotionDetail_ViewController.h"
#import "ServiceDetailViewController.h"
#import "CommodityDetailViewController.h"
#import "IndexTopView.h"
#import "CycleScrollView.h"

@interface IndexViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,IndexTopViewDelegate>
{
    UIScrollView *scrollview;
    DCPicScrollView  *picView;
//    IndexTopView *topView;
    UIView *btnView;
    UICollectionView *indexCollectView;
    UITableView *indexTableView;
    SectionView *section_1;
    SectionView *section_2;
}
@property (weak, nonatomic) AFHTTPRequestOperation *GetPromotionListOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *GetRecommendedProductListOperation;

@property (nonatomic,strong) NSMutableArray *headImgData;
@property (nonatomic,strong) NSMutableArray *tableListData;

@property (nonatomic,strong) NSMutableArray *collectionData;


@property (nonatomic,strong) NSMutableArray *recommendDatas;


@property (assign, nonatomic) long long serviceCode_Selected;
@property (assign, nonatomic) CGFloat serviceDiscount_Selected;
@property (assign, nonatomic) long long commodityCode_Selected;
@property (assign, nonatomic) CGFloat commodityDiscount_Selected;

@property (nonatomic , retain) CycleScrollView *topView;

@end

@implementation IndexViewController
@synthesize serviceCode_Selected,commodityCode_Selected;
@synthesize serviceDiscount_Selected,commodityDiscount_Selected;
@synthesize topView;
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (_GetPromotionListOperation || [_GetPromotionListOperation isExecuting]) {
        [_GetPromotionListOperation cancel];
        _GetPromotionListOperation = nil;
    }
    if (_GetRecommendedProductListOperation || [_GetRecommendedProductListOperation isExecuting]) {
        [_GetRecommendedProductListOperation cancel];
        _GetRecommendedProductListOperation = nil;
    }
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = NO;
    [super viewWillAppear:animated];
    self.title = @"首页";
    [self requestGetPromotionListWithType:@(1)]; // 顶部
}
- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kToolBar_Height  + kStateBar_Height)];
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollview];
    
    _headImgData = [NSMutableArray array];
    _tableListData = [NSMutableArray array];
    _recommendDatas = [NSMutableArray array];
    
    NSMutableArray *sec1_arr = [NSMutableArray array];
    NSMutableArray *sec2_arr = [NSMutableArray array];
    _collectionData = [NSMutableArray arrayWithObjects:sec1_arr,sec2_arr, nil];

}
#pragma mark - 创建UI
- (void)initTableView
{
    if (self.tableListData.count > 0 ) { // 有数据
        if (!section_1){
            //促销
            section_1  = [[SectionView alloc]initWithFrame:CGRectMake(0, btnView.frame.origin.y +btnView.frame.size.height, kSCREN_BOUNDS.size.width, kSectionView_Height)];
            section_1.name = @"促销";
            section_1.isMore = YES;
            __weak typeof(self) weakSelf  = self;
            section_1.moreClick = ^(UIButton *button){
                weakSelf.hidesBottomBarWhenPushed = YES;
                UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                SalesPromotionNewViewController *SalesPromotionNewVC = [board instantiateViewControllerWithIdentifier:@"SalesPromotion"];
                [weakSelf.navigationController pushViewController:SalesPromotionNewVC animated:YES];
                weakSelf.hidesBottomBarWhenPushed = NO;
            };
            [scrollview addSubview:section_1];
        }else{
            section_1.frame = CGRectMake(0, btnView.frame.origin.y +btnView.frame.size.height, kSCREN_BOUNDS.size.width, kSectionView_Height);
        }
        if (!indexTableView) {
            indexTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, section_1.frame.origin.y +section_1.frame.size.height, kSCREN_BOUNDS.size.width, (kCell_Height + 5) *self.tableListData.count) style:UITableViewStylePlain];
            indexTableView.backgroundColor = [UIColor blueColor];
            indexTableView.separatorColor = kTableView_LineColor;
            indexTableView.backgroundColor = kColor_Clear;
            indexTableView.backgroundView = nil;
            indexTableView.showsHorizontalScrollIndicator = NO;
            indexTableView.showsVerticalScrollIndicator = NO;
            indexTableView.delegate = self;
            indexTableView.dataSource = self;
            indexTableView.scrollEnabled = NO;
            indexTableView.separatorInset = UIEdgeInsetsZero;
            [scrollview addSubview:indexTableView];
            
        }else{
            indexTableView.frame = CGRectMake(0, section_1.frame.origin.y +section_1.frame.size.height, kSCREN_BOUNDS.size.width, (kCell_Height + 5) *self.tableListData.count);
            [indexTableView reloadData];
        }
        
        if (self.headImgData.count > 0) { // 有图片
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width,indexTableView.frame.size.height + (kSCREN_BOUNDS.size.width * 0.75) + kNavigationBar_Height + btnView.frame.size.height  + section_1.frame.size.height);
        }else{
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width,indexTableView.frame.size.height + btnView.frame.size.height  + section_1.frame.size.height);
        }
    }else{ //没有数据
        if (section_1) {
            [section_1 removeFromSuperview];
            section_1 = nil;
        }
        if (indexTableView) {
            [indexTableView removeFromSuperview];
            indexTableView = nil;
        }
        if (self.headImgData.count > 0) { // 有图片
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width,(kSCREN_BOUNDS.size.width * 0.75) + kNavigationBar_Height + btnView.frame.size.height);
        }else{
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, btnView.frame.size.height);
        }
    }
    [self requestGetRecommendedProductList];
   
}
- (void)initCollectionView
{

    if (_recommendDatas.count > 0) {  //有数据
        CGRect rect;
        if (indexTableView) {
            rect = indexTableView.frame;
        }else{
            rect = btnView.frame;
        }
        if (!section_2) {
            //推荐
            section_2 = [[SectionView alloc]initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height, kSCREN_BOUNDS.size.width, kSectionView_Height)];
            section_2.name = @"推荐";
            section_2.isMore = NO;
            [scrollview addSubview:section_2];
            
        }else{
            section_2.frame = CGRectMake(0, rect.origin.y + rect.size.height, kSCREN_BOUNDS.size.width, kSectionView_Height);
        }
        
        float  collect_height = ceilf(_recommendDatas.count / 2.0);
        CGFloat col = 5.0f;
        CGFloat collectionItemView_Height = ((kSCREN_BOUNDS.size.width - 5) / 2) + 30 + col;

        if (!indexCollectView) {
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
            indexCollectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, section_2.frame.origin.y + section_2.frame.size.height, kSCREN_BOUNDS.size.width,collect_height * collectionItemView_Height) collectionViewLayout:flowLayout];
            indexCollectView.delegate = self;
            indexCollectView.dataSource = self;
            indexCollectView.scrollEnabled = NO;
            indexCollectView.backgroundView = nil;
            indexCollectView.backgroundColor = kColor_Clear;
            [indexCollectView registerNib:[UINib nibWithNibName:@"IndexCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
            [scrollview addSubview:indexCollectView];
        }else{
            indexCollectView.frame = CGRectMake(0, section_2.frame.origin.y + section_2.frame.size.height, kSCREN_BOUNDS.size.width,collect_height * collectionItemView_Height) ;
            [indexCollectView reloadData];
        }
    
        if (self.headImgData.count > 0) { // 有图片
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, rect.size.height + rect.origin.y + indexCollectView.frame.size.height - 5.0f);
        }else{
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, rect.size.height + rect.origin.y + indexCollectView.frame.size.height - 5.0f);
        }
    }else{ //没有数据
        if (section_2) {
            [section_2 removeFromSuperview];
            section_2 = nil;
        }
        if (indexCollectView) {
            [indexCollectView removeFromSuperview];
            indexCollectView = nil;
        }
        CGRect rect;
        if (indexTableView) {
            rect = indexTableView.frame;
        }else{
            rect = btnView.frame;
        }
        if (self.headImgData.count > 0) { // 有图片
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, rect.size.height + rect.origin.y);
        }else{
            scrollview.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, rect.size.height + rect.origin.y);
        }
    }
}
- (void)downHeadImage {
   
    //网络加载
    NSMutableArray *UrlStringArray = [NSMutableArray array];
    NSMutableArray * imageViewArr = [NSMutableArray array];
    
    for (PromotionListRes *res  in self.headImgData) {
        [UrlStringArray addObject:res.PromotionPictureURL];

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width , 0, kSCREN_BOUNDS.size.width, (kSCREN_BOUNDS.size.width *0.75))];
        imageView.userInteractionEnabled = YES;
        [imageView setImageWithURL:[NSURL URLWithString:res.PromotionPictureURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
        }];
        [imageViewArr addObject:imageView];
    }


    if (UrlStringArray.count > 0) { // 有图片
        if (!topView) {
            if(UrlStringArray.count == 1){
                topView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.width * 0.75) animationDuration:0];
            }
            else{
                topView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.width * 0.75) animationDuration:2];
            }
            topView.backgroundColor = [UIColor clearColor];
            
            topView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                return imageViewArr[pageIndex];
            };
            topView.totalPagesCount = ^NSInteger(void){
                return UrlStringArray.count;
            };
            topView.TapActionBlock = ^(NSInteger pageIndex){
                NSLog(@"点击了第%ld个",(long)pageIndex);
                
                PromotionListRes * promoRes = [self.headImgData objectAtIndex:pageIndex];
                self.hidesBottomBarWhenPushed = YES;
                PromotionDetail_ViewController *promotionController = [[PromotionDetail_ViewController alloc]init];
                promotionController.promotionCode = promoRes.PromotionCode;
                //    promotionController.promotionCode = [self.tableListData[indexPath.row] valueForKey:@"PromotionCode"];
                [self.navigationController pushViewController:promotionController animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            };
            [scrollview addSubview:topView];
//            topView = [[IndexTopView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.width * 0.75)];
//            topView.delegate = self;
//            topView.datas = UrlStringArray;
//            [scrollview addSubview:topView];
        }
    }else{
        if (topView) {
            [topView removeFromSuperview];
            topView = nil;
        }
    }
    //按钮
    CGFloat btnWidth =   (kSCREN_BOUNDS.size.width - 80) / 4; // 80是总间隙
    CGFloat btnHeight = 44;
    if(!btnView){
        NSArray *btnArr = @[@"服务",@"商品",@"商家",@"提醒"];
        NSArray *imgArr = @[@"navigation_service_icon",@"navigation_commodity_icon",@"navigation_company_icon",@"navigation_remind_icon"];
        btnView  = [[UIView alloc]initWithFrame:CGRectMake(0, topView.frame.origin.y + topView.frame.size.height, kSCREN_BOUNDS.size.width, btnHeight + ktitleLabHeight + 20 + 5 + 20)];
        btnView.backgroundColor = kColor_White;
        for (int i = 0; i < btnArr.count; i ++) {
            NSInteger  row = 20;
            UIButton *btn = [UIButton buttonWithTitle:nil target:self selector:@selector(btnClick:) frame:CGRectMake(10 +row * i + i * btnWidth ,20, btnWidth, btnHeight) backgroundImg:nil highlightedImage:nil];
            [btn setImage:[UIImage imageNamed:imgArr[i]] forState:UIControlStateNormal];
            btn.tag = i + 100;
            UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10 +row * i + i * btnWidth, btn.frame.origin.y + btn.frame.size.height + 5, btnWidth, ktitleLabHeight)];
            titleLab.text = btnArr[i];
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.font = kNormalFont_14;
            titleLab.textColor = kMainLightGrayColor;
            [btnView addSubview:titleLab];
            [btnView addSubview:btn];
        }
        [scrollview addSubview:btnView];
    }else{
        btnView.frame = CGRectMake(0, topView.frame.origin.y + topView.frame.size.height, kSCREN_BOUNDS.size.width, btnHeight + ktitleLabHeight + 20 + 5 + 20);
    }
    
    [self requestGetPromotionListWithType:@(2)]; //列表
}

#pragma mark -  topView代理
-(void)IndexTopView:(IndexTopView *)indexTopView tapImageView:(UIImageView *)tapImageView
{
    PromotionListRes * promoRes = [self.headImgData objectAtIndex:tapImageView.tag - 100];
    self.hidesBottomBarWhenPushed = YES;
    PromotionDetail_ViewController *promotionController = [[PromotionDetail_ViewController alloc]init];
    promotionController.promotionCode = promoRes.PromotionCode;
//    promotionController.promotionCode = [self.tableListData[indexPath.row] valueForKey:@"PromotionCode"];
    [self.navigationController pushViewController:promotionController animated:YES];
    self.hidesBottomBarWhenPushed = NO;


    
}
#pragma mark --   UITableViewDelegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableListData.count;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier =@"Cell";
    IndexTableViewCell *cell = (IndexTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"IndexTableViewCell" owner:self options:nil] objectAtIndex:0];
        cell.backgroundColor = kColor_White;
        cell.tintColor = kColor_White;
    }
    if (self.tableListData.count > 0) {
        cell.data = self.tableListData[indexPath.section];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    PromotionDetail_ViewController *promotionController = [[PromotionDetail_ViewController alloc]init];
    promotionController.promotionCode = [self.tableListData[indexPath.section] valueForKey:@"PromotionCode"];
    [self.navigationController pushViewController:promotionController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}



#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _recommendDatas.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CollectionCell";
    IndexCollectionViewCell * cell = (IndexCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = kColor_White;
    cell.data =_recommendDatas[indexPath.row];

    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectionItemView_Height = ((kSCREN_BOUNDS.size.width - 5) / 2) + 30;
    return CGSizeMake((kSCREN_BOUNDS.size.width - 5) / 2, collectionItemView_Height);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}
#pragma mark --UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    self.hidesBottomBarWhenPushed = YES;
    RecommendedProductListRes *res = _recommendDatas[indexPath.row];
    [self enterDetailsViewControllerWithRecommendedProductListRes:res];
    self.hidesBottomBarWhenPushed = NO;
}
- (void)enterDetailsViewControllerWithRecommendedProductListRes:(RecommendedProductListRes *)res
{
    switch (res.ProductType) {
        case 0:
        {
            serviceCode_Selected = res.ProductCode;
            ServiceDetailViewController *detailProductController  =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
            detailProductController.commodityCode = serviceCode_Selected;
            
            [self.navigationController pushViewController:detailProductController animated:YES];
        }
            break;
        case 1:
        {
            commodityCode_Selected = res.ProductCode;
            CommodityDetailViewController *detailProductController  =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CommodityDetailViewController"];
            detailProductController.commodityCode = commodityCode_Selected;
            [self.navigationController pushViewController:detailProductController animated:YES];
            
        }
            break;
            
        default:
            break;
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 按钮事件
- (void)btnClick:(UIButton *)sender
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    switch (sender.tag) {
        case 100: //服务
        {
            ServiceOneViewController *ServiceOneVC = [board instantiateViewControllerWithIdentifier:@"ServiceOneViewController"];
            [self.navigationController pushViewController:ServiceOneVC animated:YES];
        }
            break;
        case 101: //商品
        {
            CategoryOneViewController *CategoryOneVC = [board instantiateViewControllerWithIdentifier:@"CategoryOneViewController"];
            [self.navigationController pushViewController:CategoryOneVC animated:YES];
        }
            break;
        case 102: //商家
        {
            BusinessInfoViewController * BusinessInfoVC = [board instantiateViewControllerWithIdentifier:@"BusinessInfoViewController"];
            [self.navigationController pushViewController: BusinessInfoVC animated:YES];

        }
            break;
        case 103: //提醒
        {
            RemindViewController * RemindVC = [board instantiateViewControllerWithIdentifier:@"RemindViewController"];
            [self.navigationController pushViewController: RemindVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - 接口

- (void)requestGetPromotionListWithType:(NSNumber *)type
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    NSInteger login_CompanyID = self.loginDoc.login_CompanyID;
    NSDictionary *para;
    switch (type.intValue) {
        case 1:
        {
            NSInteger ImageWidth = kSCREN_BOUNDS.size.width;
            para = @{@"ImageHeight":@(ImageWidth * 0.75),
                     @"ImageWidth":@(ImageWidth),
                     @"CompanyID":@(login_CompanyID),
                     @"Type":type};

        }
            break;
        case 2:
        {
            para = @{@"ImageHeight":@(kCell_Height),
                                   @"ImageWidth":@150,
                                   @"CompanyID":@(login_CompanyID),
                                   @"Type":type};
        }
            break;
        default:
            break;
    }
   

    _GetPromotionListOperation = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Promotion/GetPromotionList" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSArray class]]) {
                //删除老的数据
                if (type.intValue == 1) {
                    [self.headImgData removeAllObjects];
                };
                if (type.intValue == 2) {
                    [self.tableListData removeAllObjects];
                };

                
                NSArray *temp = (NSArray *)data;
                if (temp.count  > 0) {
                    for (NSDictionary *dic in temp) {
                        PromotionListRes * promoRes = [[PromotionListRes alloc]initWithDict:dic];
                        switch (type.intValue) {
                            case 1:
                            {
                                [self.headImgData addObject:promoRes];
                            }
                                break;
                            case 2:
                            {
                                [self.tableListData addObject:promoRes];
                            }
                                break;
                            default:
                                break;
                        }
                    }

                }
            }
            //解析结束
            if (type.intValue == 1) { 
                [self downHeadImage];
            }
            if (type.intValue == 2) {
                [self initTableView];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

    }];
}
- (void)requestGetRecommendedProductList
{
    NSInteger imageWidth = @((kSCREN_BOUNDS.size.width - 5) / 2).integerValue;
    NSDictionary *para = @{@"ImageHeight":@(imageWidth),
                           @"ImageWidth":@(imageWidth)
                           };
   _GetRecommendedProductListOperation = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Commodity/getRecommendedProductList" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
       [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *temp = (NSArray *)data;
                [_recommendDatas removeAllObjects];
                  if (temp.count  > 0) {
                      for (int i = 0; i< temp.count; i ++) {
                          NSDictionary *dic = temp[i];
                            RecommendedProductListRes * recoRes = [[RecommendedProductListRes alloc]initWithDict:dic];
                          [_recommendDatas addObject:recoRes];
                      }
                  }
            }
            [self initCollectionView];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

    }];
}



@end
