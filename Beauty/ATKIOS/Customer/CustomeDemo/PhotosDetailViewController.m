//
//  PhotosDetailViewController.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "PhotosDetailViewController.h"
#import "PhotosListViewController.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"
#import "PhotoDoc.h"
#import "UIButton+InitButton.h"
#import "ECSlidingViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "GPActivity.h"
#import "GPActivityActionView.h"

#import "AppDelegate.h"

//#import "WeiboSDK.h"
//#import "WXApi.h"

#define CELL_WITH 85.0f
#define CELL_HEIGHT 120.0f
#define isSimulator (NSNotFound == [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

@interface PhotosDetailViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *requestPhotosDetailOperation;
@property (strong, nonatomic) NSMutableArray *photosArray;

@property (strong, nonatomic) UIImageView *displayOriginalImageView;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) GPActivityActionView *activityActionView;

@property (strong, nonatomic) UIImage *shareImage;

//@property (strong, nonatomic) TitleView *titleView;

@end

@implementation PhotosDetailViewController
@synthesize photosArray;
@synthesize dateStr;
@synthesize displayOriginalImageView;
@synthesize backgroundView;
@synthesize activityActionView;
@synthesize shareImage;
//@synthesize titleView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestPhotosDetail];
    
//    [titleView getTitleView:dateStr];
    self.title = dateStr;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (titleView == nil) {
//        titleView = [[TitleView alloc] init];
//        [self.view addSubview:titleView];
//    }
    
    [_collectionView setFrame:CGRectMake(0.0f, 0, 320.0f, kSCREN_BOUNDS.size.height - 40.0f)];
    [_collectionView setBackgroundView:nil];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [_collectionView setFrame:CGRectMake(0.0f, 0, 320.0f, kSCREN_BOUNDS.size.height - 22.0f)];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    double num = (double)[photosArray count] / 3;
    return ceil(num);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    double num = (double)[photosArray count] / 3;
    if (section == num - 1) {
        return [photosArray count] % 3 == 0 ? 3 : [photosArray count] % 3;
    } else
        return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity = @"DisplayPhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identity forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(CELL_WITH * indexPath.row , CELL_HEIGHT * indexPath.section, CELL_WITH, CELL_HEIGHT)];
    }
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:102];
    
    imageView.layer.cornerRadius = 4.0f;
    imageView.layer.masksToBounds = YES;

    
    dateLabel.textColor = kColor_TitlePink;
    dateLabel.font = kFont_Light_14;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    
    NSInteger index = indexPath.section * 3 + indexPath.row + 1;
    if (index > [photosArray count]) {
        cell.contentView.hidden = YES;
        return cell;
    } else {
        cell.contentView.hidden = NO;
        PhotoDoc *photoDoc = [photosArray objectAtIndex:index - 1];
        [imageView setImageWithURL:[NSURL URLWithString:photoDoc.photoURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
        [dateLabel setHidden:YES];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CELL_WITH, CELL_HEIGHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    int lef = (320 - CELL_WITH * 3)/(4 + 4 + 5 + 5) * 4;
    return UIEdgeInsetsMake(5.0f, lef, -15.0f, lef);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImage *smallImage = ((UIImageView *)[cell.contentView viewWithTag:101]).image;
    if (!backgroundView && (indexPath.section * 3 + indexPath.row) < photosArray.count) {
        CGRect rect = kSCREN_BOUNDS;
        rect.origin.y = 0;
        rect.size.height += 20.0f;
        
        backgroundView = [[UIView alloc] initWithFrame:rect];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0;
        [[UIApplication sharedApplication].keyWindow addSubview:backgroundView];
        
        displayOriginalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WITH * indexPath.row, CELL_HEIGHT * indexPath.section + 90, CELL_WITH, CELL_HEIGHT)];
        //displayOriginalImageView.contentMode = UIViewContentModeCenter;
        displayOriginalImageView.image = smallImage;
        displayOriginalImageView.backgroundColor = [UIColor clearColor];
        displayOriginalImageView.userInteractionEnabled = YES;
        displayOriginalImageView.contentScaleFactor = [UIScreen mainScreen].scale;
        [backgroundView addSubview:displayOriginalImageView];
        displayOriginalImageView.frame = CGRectMake((kSCREN_BOUNDS.size.width - displayOriginalImageView.image.size.width)/2, (kSCREN_BOUNDS.size.height - displayOriginalImageView.image.size.height)/2, displayOriginalImageView.image.size.width, displayOriginalImageView.image.size.height);
        
        __block UIActivityIndicatorView *activityIndicator;
        __weak __block UIImage *tmpSharImage = shareImage;
        __weak __block UIImageView *weakImageView = self.displayOriginalImageView;
        __weak __block PhotosDetailViewController *photoViewController = self;
        
        PhotoDoc *ph = [photosArray objectAtIndex:indexPath.section * 3 + indexPath.row];
        NSString *url = ph.photoOriginalURL;
        
        [displayOriginalImageView setImageWithURL:[NSURL URLWithString:url]
                                 placeholderImage:[UIImage imageNamed:@""]
                                          options:SDWebImageProgressiveDownload
                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                             if (!activityIndicator) {
                                                 activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                                                 activityIndicator.center = CGPointMake(weakImageView.frame.size.width/2 , weakImageView.frame.size.height/2);
                                                 NSLog(@"**********%f,%f",weakImageView.center.x,weakImageView.center.y);
                                                 [weakImageView addSubview:activityIndicator];
                                                 [activityIndicator startAnimating];
                                             }
                                         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                             if (!image)  return ;
                                             
                                             tmpSharImage = image;
                                             photoViewController.shareImage = image;
                                             
                                             NSData *data = UIImagePNGRepresentation(image);
                                             UIImage *img = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                             [weakImageView setImage:img];
                                             
                                             [activityIndicator removeFromSuperview];
                                             activityIndicator = nil;
                                             CGSize imageSize;
                                             if(image.size.width > image.size.height){
                                                 imageSize.width = image.size.width/2 > 320 ? 320 : image.size.width/2;
                                                 imageSize.width = image.size.width/2 < 160 ? 160 : imageSize.width;
                                                 imageSize.height = imageSize.width/(float)image.size.width * image.size.height;
                                             }else{
                                                 imageSize.height = image.size.height/2 > 320 ? 320 : image.size.height/2;
                                                 imageSize.height = image.size.height/2 < 160 ? 160 : imageSize.height;
                                                 imageSize.width = imageSize.height/(float)image.size.height * image.size.width;
                                             }
                                             UIButton *shareButton = [UIButton buttonWithTitle:@""
                                                                                        target:photoViewController
                                                                                      selector:@selector(sharePicture:)
                                                                                         frame:CGRectMake(imageSize.width - 45.0f, 10.0f, 45.0f, 35.0f)
                                                                                 backgroundImg:[UIImage imageNamed:@"shareButton"]
                                                                              highlightedImage:nil];
                                             [weakImageView addSubview:shareButton];
                                             [UIView animateWithDuration:0.3 animations:^{
                                                 /*
                                                  if ((indexPath.section * 3 + indexPath.row) < photosArray.count) {
                                                  [self.navigationController setNavigationBarHidden:YES];
                                                  }*/

                                                 if ((IOS7 || IOS8))
                                                     weakImageView.frame = CGRectMake((kSCREN_BOUNDS.size.width - imageSize.width)/2, (kSCREN_BOUNDS.size.height - imageSize.height)/2, imageSize.width, imageSize.height);
                                                 else
                                                     weakImageView.frame = CGRectMake((kSCREN_BOUNDS.size.width - imageSize.width)/2, (kSCREN_BOUNDS.size.height - imageSize.height)/2, imageSize.width, imageSize.height);
                                            } completion:^(BOOL finished) {
                                             }];
                                         }];
        
        [UIView animateWithDuration:0.5 animations:^{
            backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        
        UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapForHideOriginalPhotoView:)];
        tapGestureRecoginzer.delegate = self;
        [displayOriginalImageView addGestureRecognizer:tapGestureRecoginzer];
    }
}

- (void)tapForHideOriginalPhotoView:(UITapGestureRecognizer *)recoginzer
{
    if (backgroundView) {
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [displayOriginalImageView removeFromSuperview];
        displayOriginalImageView = nil;
        [backgroundView removeFromSuperview];
        backgroundView = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]  || activityActionView.isShowing) {
        return NO;
    }
    return YES;
}

#pragma mark - Share

- (void)sharePicture:(id)sender
{
    
    if  (backgroundView) {
//        __weak PhotosDetailViewController *photosDetailViewController = self;
//        NSMutableArray *appArray = [NSMutableArray array];
        
        // 微博
        if (/*[WeiboSDK isWeiboAppInstalled] ||*/ isSimulator ) {
//            GPActivity *activity_WeiBo = [[GPActivity alloc] initWithTitle:@"微博" image:[UIImage imageNamed:@"share_WeiBo.png"] activityHander:^(GPActivity *activity, NSArray *activityItems) {
//                [photosDetailViewController shareImageByWeibo:nil];
//            }];
//            [appArray addObject:activity_WeiBo];
            [self shareImageByWeibo:sender];
        }
        
//        // 微信 分享给好友
//        if ([WXApi isWXAppInstalled] || isSimulator) {
//            GPActivity *activity_WeiXin_Friend = [[GPActivity alloc] initWithTitle:@"微信" image:[UIImage imageNamed:@"share_WeiXin.png"] activityHander:^(GPActivity *activity, NSArray *activityItems) {
//                [photosDetailViewController shareImageToFriendByWeiXin:nil];
//            }];
//            [appArray addObject:activity_WeiXin_Friend];
//        }
//        
//        // 微信到朋友圈
//        if ([WXApi isWXAppInstalled] || isSimulator) {
//            GPActivity *activity_WeiXin_CrileOfFriend = [[GPActivity alloc] initWithTitle:@"朋友圈" image:[UIImage imageNamed:@"share_CircleofFriends.png"] activityHander:^(GPActivity *activity, NSArray *activityItems) {
//                [photosDetailViewController shareImageToCircleofFriendsByWeiXin:nil];
//            }];
//            [appArray addObject:activity_WeiXin_CrileOfFriend];
//        }
        
        
//        if ([appArray count] == 0) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"未安装微博或微信" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alertView show];
//            return;
//        }
        
//        activityActionView = [[GPActivityActionView alloc] initWithActivityViewItems:@[@"http://www.apple.com/"]
//                                                               applicationActivities:appArray];
//        [activityActionView showInView:displayOriginalImageView];
    }
}

#pragma mark - Weibo Method

- (void)shareImageByWeibo:(id)sender
{

    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享："
                                       defaultContent:@""
                                                image:[ShareSDK imageWithData:UIImageJPEGRepresentation(shareImage, 1.0) fileName:nil mimeType:@".jpg"]//[ShareSDK imageWithUrl:_pic_selected]
                                                title:@"图片分享"
                                                  url:@"http://www.glamise.com"
                                          description:@"分享图片到您的社交账号"
                                            mediaType:SSPublishContentMediaTypeImage];

    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //自定义标题栏相关委托
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"美丽约定"],
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"安缔克"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    nil]];
//    //自定义标题栏相关委托
//    __weak id wself = self;
//    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"美丽约定"
//                                                              oneKeyShareList:[NSArray defaultOneKeyShareList]
//                                                               qqButtonHidden:YES
//                                                        wxSessionButtonHidden:YES
//                                                       wxTimelineButtonHidden:YES
//                                                         showKeyboardOnAppear:NO
//                                                            shareViewDelegate:wself
//                                                          friendsViewDelegate:nil
//                                                        picViewerViewDelegate:nil];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                        content:publishContent
                    statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    [SVProgressHUD showSuccessWithStatus2:@"分享成功"];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSString *string = [NSString stringWithFormat:@"%@,错误码:%ld",@"分享失败",(long)[error errorCode]];
                                    [SVProgressHUD showErrorWithStatus2:string];
                                }
                            }];
}

#pragma mark - Weixin Method

- (void)shareImageToFriendByWeiXin:(NSArray *)array
{
//    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setShareType:ShareTypeWeixin];
//    
//    //  NSString *shareStr = @"SDK 测试!";
//  //  UIImage  *shareImg = shareImage;
//    
//    WXMediaMessage *mediaMessage = [WXMediaMessage message];
//    // mediaMessage.title = @"Beauty On Hand";   // 少于512字节
//    // mediaMessage.description = @"Hello, This is a test about sharing"; // 小于1k
//    //??????   [mediaMessage setThumbImage:shareImg];  // 少于32k
//    // [mediaMessage setThumbData:UIImagePNGRepresentation(shareImg)];  // 少于32k
//    
//    WXImageObject *imageObject = [WXImageObject object];
//    imageObject.imageData = UIImagePNGRepresentation(shareImage); // 小于10M
//    mediaMessage.mediaObject = imageObject;
//    
//    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
//    //request.text = shareStr;
//    request.message = mediaMessage;
//    request.scene = WXSceneSession;
//    request.bText = NO; // YES 文本消息  NO多媒体消息
//    [WXApi sendReq:request];
}

- (void)shareImageToCircleofFriendsByWeiXin:(NSArray *)array
{
//    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setShareType:ShareTypeWeixin];
//    
//    // NSString *shareStr = @"SDK 测试!";
//    UIImage  *shareImg = shareImage;
//    
//    WXMediaMessage *mediaMessage = [WXMediaMessage message];
//    // mediaMessage.title = @"Beauty On Hand";   // 少于512字节
//    // mediaMessage.description = @"Hello, This is a test about sharing"; // 小于1k
//    // [mediaMessage setThumbImage:shareImg];  // 少于32k
//    // [mediaMessage setThumbData:UIImagePNGRepresentation(shareImg)];  // 少于32k
//    
//    WXImageObject *imageObject = [WXImageObject object];
//    imageObject.imageData = UIImagePNGRepresentation(shareImg); // 小于10M
//    mediaMessage.mediaObject = imageObject;
//    
//    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
//    //request.text = shareStr;
//    request.message = mediaMessage;
//    request.scene = WXSceneTimeline;
//    request.bText = NO; // YES 文本消息  NO多媒体消息
//    [WXApi sendReq:request];
}

#pragma mark - 接口

- (void)requestPhotosDetail
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"CreateDate":dateStr,
                           @"ImageHeight":@(kSCREN_BOUNDS.size.width * 2),
                           @"ImageWidth":@(kSCREN_BOUNDS.size.width * 2),
                           @"ThumbImageWidth":@160,
                           @"ThumbImageHeight":@160};
    _requestPhotosDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/getPhotoAlbumDetail"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        if (!photosArray) {
            photosArray = [NSMutableArray array];
        } else {
            [photosArray removeAllObjects];
        }
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PhotoDoc *photoDoc = [[PhotoDoc alloc] init];
                [photoDoc setPhotoID:[obj[@"ImageID"] integerValue]];
                [photoDoc setPhotoURL:obj[@"ThumbnailURL"]];
                [photoDoc setPhotoOriginalURL:obj[@"OriginalImageURL"]];
                [photosArray addObject:photoDoc];
            }];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
        [_collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end


