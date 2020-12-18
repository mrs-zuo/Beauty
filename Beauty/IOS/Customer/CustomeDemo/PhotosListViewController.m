//
//  PhotosListViewController.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "PhotosListViewController.h"
#import "PhotosDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "GPHTTPClient.h"
#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"
#import "PhotoDoc.h"

#define CELL_WITH 88.0f
#define CELL_HEIGHT 120.0f

@interface PhotosListViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *requestPhotosListOperation;
@property (assign, nonatomic) NSInteger index_Selected;
@property (strong, nonatomic) NSMutableArray *photosArray;
@end

@implementation PhotosListViewController
@synthesize index_Selected;
@synthesize photosArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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
    self.navigationController.navigationBarHidden = NO;
//    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:@"我的相册"]];
        self.title = @"我的相册";
    [self requestPhotosList];
    if ((IOS7 || IOS8)) {
      self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_collectionView setFrame:CGRectMake(0.0f, 0, 320.0f, kSCREN_BOUNDS.size.height - 22.0f)];
    [_collectionView setBackgroundView:nil];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
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
    UIImageView *bgView = (UIImageView *)[cell.contentView viewWithTag:100];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:102];
   
    bgView.autoresizingMask = UIViewAutoresizingNone;
    
    NSLog(@"%f  %f", bgView.frame.size.width, bgView.frame.size.height);
    NSLog(@"%f  %f", imageView.frame.size.width, imageView.frame.size.height);

    
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 4.0f;
    
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
        NSLog(@"++url:%@", photoDoc.photoURL);
        [imageView setImageWithURL:[NSURL URLWithString:photoDoc.photoURL]];
        [dateLabel setText:photoDoc.photoDate];
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
    self.hidesBottomBarWhenPushed = YES;
    index_Selected = indexPath.section * 3 + indexPath.row;
    if (index_Selected < photosArray.count) {
         [self performSegueWithIdentifier:@"goPhotosDetailViewControllerFromPhotosListViewController" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goPhotosDetailViewControllerFromPhotosListViewController"]) {
        PhotoDoc *photoDoc = [photosArray objectAtIndex:index_Selected];
        PhotosDetailViewController *photosDetailViewController  = segue.destinationViewController;
        photosDetailViewController.dateStr = photoDoc.photoDate;
    }
}

#pragma mark - 接口

- (void)requestPhotosList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID)};
    _requestPhotosListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/image/getPhotoAlbumList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        _collectionView.userInteractionEnabled = NO;
        NSMutableArray *temp = [NSMutableArray array];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PhotoDoc *photoDoc = [[PhotoDoc alloc] init];
                [photoDoc setPhotoDate:obj[@"CreateTime"]];
                [photoDoc setPhotoURL:obj[@"ImageURL"] == [NSNull null] ? nil : obj[@"ImageURL"]];
                [temp addObject:photoDoc];
            }];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        photosArray = temp;
        [_collectionView reloadData];

        _collectionView.userInteractionEnabled = YES;
    } failure:^(NSError *error) {

    }];
//    _requestPhotosListOperation = [[GPHTTPClient shareClient] requestGetPhotoAlbumListWithSuccess:^(id xml) {
//        [SVProgressHUD dismiss];
//        _collectionView.userInteractionEnabled = NO;
//        if (!photosArray) {
//            photosArray = [NSMutableArray array];
//        } else {
//            [photosArray removeAllObjects];
//        }
//        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
//            for (GDataXMLElement *data in [contentData elementsForName:@"PhotoAlbum"]) {
//                PhotoDoc *photoDoc = [[PhotoDoc alloc] init];
//                [photoDoc setPhotoDate:[[[data elementsForName:@"CreateTime"] objectAtIndex:0] stringValue]];
//                
//                NSString *dateStr = [[[data elementsForName:@"ImageURL"] objectAtIndex:0] stringValue];
//                [photoDoc setPhotoURL:dateStr];
//                [photosArray addObject:photoDoc];
//            }
//        } failure:^{}];
//        
//        [_collectionView reloadData];
//        _collectionView.userInteractionEnabled = YES;
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

@end
