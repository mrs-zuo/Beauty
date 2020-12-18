//
//  ZXPhotoViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/20.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXPhotoViewController.h"
#import "ZXPhotoHeaderCollectionReusableView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "SVProgressHUD.h"
#import "AllServiceEffectImageRes.h"
#import "AllServiceEffectRes.h"
#import "UIImageView+WebCache.h"
#import "NavigationView.h"
#import "SJAvatarBrowser.h"
#import "OrderDetailViewController.h"

@interface ZXPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectView;
@property (nonatomic,strong) NSMutableArray *photoDatas;

@property (nonatomic,weak) AFHTTPRequestOperation *requestGetAllServiceEffectByCustomerID;


@end

@implementation ZXPhotoViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getAllServiceEffectByCustomerID];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //wugang->
    //self.view.backgroundColor = [UIColor colorWithRed:208.0 /255.0 green:235.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:242.0 /255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
    //-<wugang
    self.view.userInteractionEnabled = YES;
    NavigationView *  navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"照片"];
    [self.view addSubview:navigationView];
    
  
    
    self.photoDatas = [NSMutableArray array];
}
- (void)initCollectView
{
    if (!_collectView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(5,44, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 10 - 44 - 64) collectionViewLayout:flowLayout];
        _collectView.alwaysBounceVertical  =YES;
        _collectView.userInteractionEnabled = YES;
        _collectView.backgroundColor = kColor_White;
        _collectView.delegate = self;
        _collectView.dataSource = self;
        [_collectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
        
        
        UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([ZXPhotoHeaderCollectionReusableView class])  bundle:[NSBundle mainBundle]];
        [_collectView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
        //    [collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
        //获取布局
        flowLayout = (UICollectionViewFlowLayout *)_collectView.collectionViewLayout;
        //设置属性
        flowLayout.itemSize = CGSizeMake(100 - 8, 100 - 8);
        //设置内边距
        flowLayout.sectionInset = UIEdgeInsetsMake(8,8,8,8);
//        flowLayout.sectionInset = UIEdgeInsetsZero;
        
        [self.view addSubview:_collectView];
    }
   
}
#pragma mark -  UICollectionViewDelegate &&dataSource
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{

    return 8;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kSCREN_BOUNDS.size.width - 10, 54);
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
 
    ZXPhotoHeaderCollectionReusableView *reusableView = (ZXPhotoHeaderCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
    reusableView.tag = indexPath.section + 100;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadView:)];
    [reusableView addGestureRecognizer:tap];
    
    AllServiceEffectRes *serviceRes = self.photoDatas[indexPath.section];
    reusableView.nameLab.text = serviceRes.ServiceName;
    reusableView.dateLab.text = serviceRes.TGStartTime;
    
    return reusableView;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.photoDatas.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AllServiceEffectRes *serviceRes = self.photoDatas[section];
    return serviceRes.ImageEffects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.contentView.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor redColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100 - 8, 100 - 8)];
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.tag = 10086;
    imageView.userInteractionEnabled = YES;
    [cell.contentView addSubview:imageView];
    
    AllServiceEffectRes *serviceRes = self.photoDatas[indexPath.section];
    AllServiceEffectImageRes *imageRes = serviceRes.ImageEffects[indexPath.row];
    [imageView setImageWithURL:[NSURL URLWithString:imageRes.ThumbnailURL] placeholderImage:[UIImage imageNamed:@"People-default"]];

    

    return cell;
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLOG(@"didSelectItemAtIndexPathdidSelectItemAtIndexPathdidSelectItemAtIndexPath");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:10086];
    AllServiceEffectRes *serviceRes = self.photoDatas[indexPath.section];
    AllServiceEffectImageRes *imageRes = serviceRes.ImageEffects[indexPath.row];
    UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageRes.OriginalImageURL]]];
    [SJAvatarBrowser showImage:imageView img:image];
}
#pragma  mark - 手势
- (void)tapHeadView:(UITapGestureRecognizer *)ges
{
    if ([ges.view isKindOfClass:[ZXPhotoHeaderCollectionReusableView class]]) {
        ZXPhotoHeaderCollectionReusableView *reusableView = (ZXPhotoHeaderCollectionReusableView *)ges.view;
        AllServiceEffectRes *serviceRes = self.photoDatas[reusableView.tag - 100];
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        OrderDetailViewController *orderDetail = [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
        orderDetail.orderID = serviceRes.OrderID;
        orderDetail.productType = 0;
        orderDetail.objectID  = serviceRes.OrderObjectID;
        [self.navigationController pushViewController:orderDetail animated:YES];

        
    }
}
#pragma mark - 接口
- (void)getAllServiceEffectByCustomerID
{
    [SVProgressHUD showSuccessWithStatus:@"loading..."];
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%lld,\"ImageThumbWidth\":150,\"ImageThumbHeight\":150,\"ImageWidth\":150,\"ImageHeight\":150}",(long long)_customerID];

    _requestGetAllServiceEffectByCustomerID = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Image/GetAllServiceEffectByCustomerID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *datas = (NSArray *)data;
                if (datas.count > 0) {
                    for (int i = 0;i < datas.count; i ++) {
                        NSDictionary *tempDic = [datas objectAtIndex:i];
                        AllServiceEffectRes *serviceRes = [[AllServiceEffectRes alloc]init];
                        serviceRes.GroupNo = [[tempDic objectForKey:@"GroupNo"] doubleValue];
                        serviceRes.TGStartTime = [tempDic objectForKey:@"TGStartTime"];
                        serviceRes.ServiceName = [tempDic objectForKey:@"ServiceName"];
                        serviceRes.OrderID = [[tempDic objectForKey:@"OrderID"] integerValue];
                        serviceRes.OrderObjectID = [[tempDic objectForKey:@"OrderObjectID"] integerValue];
                        //照片
                        NSArray *imageEffects = [tempDic objectForKey:@"ImageEffect"];
                        if (imageEffects.count > 0) {
                            for (int i = 0 ; i < imageEffects.count ; i ++) {
                                AllServiceEffectImageRes *effectImageRes = [[AllServiceEffectImageRes alloc]init];
                                effectImageRes.TreatmentImageID = [[[imageEffects objectAtIndex:i] objectForKey:@"TreatmentImageID"] integerValue];
                                effectImageRes.ImageType = [[[imageEffects objectAtIndex:i] objectForKey:@"ImageType"] integerValue];
                                effectImageRes.ThumbnailURL = [[imageEffects objectAtIndex:i] objectForKey:@"ThumbnailURL"];
                                effectImageRes.OriginalImageURL = [[imageEffects objectAtIndex:i] objectForKey:@"OriginalImageURL"];
                                [serviceRes.ImageEffects addObject:effectImageRes];
                            }
                        }
                        [self.photoDatas addObject:serviceRes];
                    }
                }
                [self initCollectView];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{
                
            }];
        }];
    } failure:^(NSError *error) {
       
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    //    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIImageView"]) {
        return NO;
    }
    return  YES;
}

@end
