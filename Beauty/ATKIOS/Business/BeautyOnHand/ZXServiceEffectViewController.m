//
//  ZXServiceEffectViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/19.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXServiceEffectViewController.h"
#import "EffectImgEditViewController.h"
#import "UILabel+InitLabel.h"
#import "PictureDisplayView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLNode.h"
#import "DEFINE.h"
#import "NavigationView.h"
#import "GPBHTTPClient.h"
#import "SJAvatarBrowser.h"
#import "EffectImgEditViewController.h"
#import "TreatmentTabBarController.h"
#import "EffectDisplayViewController.h"
#import "ReviewViewController.h"
#import "TreatmentDetailViewController.h"

const NSInteger kPrevButtonTag =  1000000;
const NSInteger kNextButtonTag =  2000000;


#define IMG_SCROLL_LEFT_0 [UIImage imageNamed:@"imgScroll_L0"]
#define IMG_SCROLL_LEFT_1 [UIImage imageNamed:@"imgScroll_L1"]

#define IMG_SCROLL_RIGHT_0 [UIImage imageNamed:@"imgScroll_R0"]
#define IMG_SCROLL_RIGHT_1 [UIImage imageNamed:@"imgScroll_R1"]


@implementation TMListDoc

@end


@interface ZXServiceEffectViewController () <UIGestureRecognizerDelegate>

{
    UIView* goBackgroundView;
    CGRect defaultRect;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestEffectDisplayImages;
@property (assign, nonatomic) BOOL isSynchronized;

@property (strong, nonatomic) NSMutableArray *beforeEffectImgArray; // 保存着 EffectImgDoc
@property (strong, nonatomic) NSMutableArray * afterEffectImgArray; // 保存着 EffectImgDoc
@property (strong, nonatomic) NSArray *beforePicArray;
@property (strong, nonatomic) NSArray *afterPicArray;

// -- view
@property (strong, nonatomic) UIButton *prevButton;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *afterPervBtn;
@property (strong, nonatomic) UIButton *afterNextBtn;
@property (strong, nonatomic) PictureDisplayView *beforePictureDisplayView;
@property (strong, nonatomic) PictureDisplayView *afterPictureDisplayView;
@property (nonatomic , assign) NSString * titleStr;
@property (strong ,nonatomic)NavigationView *navigationView;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *serviceEffectDatas;


@end

@implementation ZXServiceEffectViewController
@synthesize isSynchronized;
@synthesize beforePicArray;
@synthesize afterPicArray;
@synthesize beforePictureDisplayView, nextButton, prevButton;
@synthesize afterPictureDisplayView, afterNextBtn, afterPervBtn;
@synthesize treat_ID;
@synthesize beforeEffectImgArray, afterEffectImgArray;
@synthesize titleStr;
@synthesize navigationView;
@synthesize GroupNo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getServiceEffectImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"服务效果"];
    [self.view addSubview:navigationView];
    
    
    if (_permission_Write)
    [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(editAction)];
    
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
//    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49.0f - 5.0f);
    [self.view addSubview:_tableView];
    
    _serviceEffectDatas = [NSMutableArray array];
    
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    beforePictureDisplayView = nil;
    afterPictureDisplayView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)editAction
{
    EffectImgEditViewController  *effectImgController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"EffectImgEditViewController"];
    effectImgController.beforeEffectArray = beforeEffectImgArray;
    effectImgController.afterEffectArray  = afterEffectImgArray;
    effectImgController.treat_ID = treat_ID;
    effectImgController.customerID = _customerID;
    effectImgController.groupNo = GroupNo;
    effectImgController.effectType = EffectImgEditViewControllerType_TG;
    [self.navigationController pushViewController:effectImgController animated:YES];
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return _serviceEffectDatas.count;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellIndetity = @"imageCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetity];
        cell.backgroundColor = [UIColor whiteColor];
        // 服务前
//        UILabel *beforLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 12.0f, 200.0f, 20.0f) title:[NSString stringWithFormat:@"%@前照片",titleStr]];
        UILabel *beforLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 12.0f, 200.0f, 20.0f) title:@"服务前照片"];

        beforLabel.font = kFont_Light_16;
        beforLabel.textColor = kColor_DarkBlue;
        [cell.contentView addSubview:beforLabel];
        
        for (int i = 0; i < 2; i++) {
            prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [prevButton setFrame:CGRectMake(0.0f, 70.0f + 170.0f * i, 14.0f, 20.0f)];
            [prevButton setBackgroundImage:IMG_SCROLL_LEFT_1 forState:UIControlStateNormal];
            [prevButton setBackgroundImage:IMG_SCROLL_LEFT_0 forState:UIControlStateSelected];
            [prevButton addTarget:self action:@selector(previousPageAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:prevButton];
            [prevButton setSelected:YES];
            prevButton.tag = kPrevButtonTag + i;
            
            nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [nextButton setFrame:CGRectMake(310.0f - 14.0f, 70.0f + 170*i, 14.0f, 20.0f)];
            [nextButton setBackgroundImage:IMG_SCROLL_RIGHT_1 forState:UIControlStateNormal];
            [nextButton setBackgroundImage:IMG_SCROLL_RIGHT_0 forState:UIControlStateSelected];
            [nextButton addTarget:self action:@selector(nextPageAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:nextButton];
            nextButton.tag = kNextButtonTag + i;
            
            if (i == 0) {
                if ([beforePicArray count] == 0)
                    [nextButton setSelected:YES];
                else
                    [nextButton setSelected:NO];
                
            } else if (i == 1) {
                if ([afterPicArray count] == 0)
                    [nextButton setSelected:YES];
                else
                    [nextButton setSelected:NO];
            }
        }
        
        beforePictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(30.0f, 35.0f, 250.0f, 120.0f) picSize:CGSizeMake(120.0f, 120.0f) spacing:10.0f];
        beforePictureDisplayView.tag = indexPath.row;
        [beforePictureDisplayView setPicturesWithURLs:beforePicArray];
        [beforePictureDisplayView setDelegate:self];
        [cell.contentView addSubview:beforePictureDisplayView];
        
        // 服务后
//        UILabel *afterLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 175.0f, 160.0f, 20.0f) title:[NSString stringWithFormat:@"%@后照片",titleStr]];
        UILabel *afterLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 175.0f, 160.0f, 20.0f) title:@"服务后照片"];

        afterLabel.font = kFont_Light_16;
        afterLabel.textColor = kColor_DarkBlue;
        [cell.contentView addSubview:afterLabel];
        
        afterPictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(30.0f, 200.0f, 250.0f, 120.0f) picSize:CGSizeMake(120.0f, 120.0f) spacing:10.0f];
        afterPictureDisplayView.tag = indexPath.row;
        [afterPictureDisplayView setPicturesWithURLs:afterPicArray];
        [afterPictureDisplayView setDelegate:self];
        
        [cell.contentView addSubview:afterPictureDisplayView];
        
        return cell;

    }else{
        NSString *cellIndetity = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndetity];
        cell.backgroundColor = [UIColor whiteColor];
        TMListDoc *tmListDoc = _serviceEffectDatas[indexPath.row];
        cell.textLabel.text =tmListDoc.subServiceName;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

- (void)changeBrowseType:(id)sender
{
    UISwitch *ctlSh = (UISwitch *)sender;
    isSynchronized = ctlSh.on;
    
    [beforePictureDisplayView bindWithOtherPictureDisplayView:afterPictureDisplayView];
}

- (void)previousPageAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == kPrevButtonTag) {
        [beforePictureDisplayView scrollToPreviouPicture];
    } else if (button.tag == kPrevButtonTag + 1) {
        [afterPictureDisplayView scrollToPreviouPicture];
    }
}

- (void)nextPageAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == kNextButtonTag) {
        [beforePictureDisplayView scrollToNextPicture];
    } else if (button.tag == kNextButtonTag + 1) {
        [afterPictureDisplayView scrollToNextPicture];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 330.0f;
    }else{
        return 44.0f;
    }
    //    if (indexPath.row == 0) {
    //        return kTableView_HeightOfRow;
    //    } else {
//    return 330.0f;
    // }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        TMListDoc *tmListDoc = _serviceEffectDatas[indexPath.row];
        TreatmentTabBarController *treatmentTabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TreatmentTabBarController"];

        TreatmentDetailViewController *treatmentDetailViewController = [treatmentTabBar.viewControllers objectAtIndex:0];
        treatmentDetailViewController.TreatmentID = tmListDoc.treatmentID;
        treatmentDetailViewController.OrderID = self.OrderID;
        treatmentDetailViewController.GroupNo = GroupNo;
        treatmentDetailViewController.customerId =self.customerID;
        treatmentDetailViewController.treatMentOrGroup = 1;
        
#pragma mark 权限
        treatmentDetailViewController.permission_Write = self.permission_Write;
        
        // effec
        EffectDisplayViewController *effectDosplayeController = [treatmentTabBar.viewControllers objectAtIndex:1];
        effectDosplayeController.treat_ID = tmListDoc.treatmentID;
        effectDosplayeController.OrderID = self.OrderID;
        effectDosplayeController.customerID = self.customerID;
        effectDosplayeController.GroupNo = GroupNo;
        effectDosplayeController.treatMentOrGroup = 1;
#pragma mark 权限
        effectDosplayeController.permission_Write = self.permission_Write;
        
        // reviewVC
        ReviewViewController *reviewVC = [treatmentTabBar.viewControllers objectAtIndex:2];
        reviewVC.treatmentID = tmListDoc.treatmentID;
        reviewVC.OrderID = self.OrderID;
        reviewVC.GroupNo = GroupNo;
        reviewVC.treatMentOrGroup = 1;

#pragma mark 权限
        reviewVC.permission_Write = self.permission_Write;
        
        treatmentTabBar.selectedIndex = 101;
        [self.navigationController pushViewController:treatmentTabBar animated:YES];
    }
}

#pragma mark - PictureDisplayViewDelegate

- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost
{
    if (pictureDisplayView == beforePictureDisplayView) {
        UIButton *prevBtn = (UIButton *)[self.view viewWithTag:kPrevButtonTag];
        UIButton *nextBtn = (UIButton *)[self.view viewWithTag:kNextButtonTag];
        [prevBtn setSelected:isLeftmost];
        [nextBtn setSelected:isRightmost];
    } else if (pictureDisplayView == afterPictureDisplayView) {
        UIButton *prevBtn = (UIButton *)[self.view viewWithTag:kPrevButtonTag + 1];
        UIButton *nextBtn = (UIButton *)[self.view viewWithTag:kNextButtonTag + 1];
        [prevBtn setSelected:isLeftmost];
        [nextBtn setSelected:isRightmost];
    }
}
- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView selectedView:(UIImageView *)selectedView
{
    EffectImgDoc *effectImgDoc;
    if (pictureDisplayView == beforePictureDisplayView) {
        effectImgDoc = [beforeEffectImgArray objectAtIndex:selectedView.tag];
        
    } else if (pictureDisplayView == afterPictureDisplayView) {
        effectImgDoc = [afterEffectImgArray objectAtIndex:selectedView.tag];
    }
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:effectImgDoc.originalImgURL]];
    UIImage *image = [UIImage imageWithData:data];
    [self showcode:pictureDisplayView image:image];
}
-(void)showcode:(PictureDisplayView *)pictureDisplayView image:(UIImage *)image
{
    if (!image) return;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    goBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    defaultRect = [pictureDisplayView convertRect:pictureDisplayView.bounds toView:window];//关键代码，坐标系转换
    goBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:defaultRect];
    imageView.image = image;
    imageView.tag = 1;
    UIImageView *fakeImageView = [[UIImageView alloc]initWithFrame:defaultRect];
    [goBackgroundView addSubview:fakeImageView];
    [goBackgroundView addSubview:imageView];
    [window addSubview:goBackgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [goBackgroundView addGestureRecognizer:tap];
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        NSData *data =  UIImageJPEGRepresentation(image, 1.0);
        UIImage *img = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
        [imageView setImage:img];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        goBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    } completion:^(BOOL finished) {
    }];
    
}
- (void)hideImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.5f animations:^{
        imageView.frame = defaultRect;
        goBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        [goBackgroundView removeFromSuperview];
    }];
}

#pragma mark - 接口

- (void)getServiceEffectImage
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *par = [NSString stringWithFormat:@"{\"GroupNo\":%f,\"ImageThumbWidth\":150,\"ImageThumbHeight\":150}",GroupNo];
    
    
    _requestEffectDisplayImages = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Image/getServiceEffectImage" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (beforeEffectImgArray)
                [beforeEffectImgArray removeAllObjects];
            else
                beforeEffectImgArray = [NSMutableArray array];
            
            if (afterEffectImgArray)
                [afterEffectImgArray removeAllObjects];
            else
                afterEffectImgArray = [NSMutableArray array];
            
            NSMutableArray *tmpBeforePicArray = [NSMutableArray array];
            NSMutableArray *tmpAfterPicArray  = [NSMutableArray array];
            
            for (NSDictionary *dic in [data objectForKey:@"ImageBeforeTreatment"]) {
                
                EffectImgDoc *effectDoc = [[EffectImgDoc alloc] init];
                
                effectDoc.imageID = [[dic objectForKey:@"TreatmentImageID"]integerValue];
                
                effectDoc.imageURL = ([dic objectForKey:@"ThumbnailURL"] == [NSNull null] ? @"" : [dic objectForKey:@"ThumbnailURL"]);
                
                effectDoc.originalImgURL = [dic objectForKey:@"OriginalImageURL"] == [NSNull null] ? @"": [dic objectForKey:@"OriginalImageURL"];
                
                [beforeEffectImgArray addObject:effectDoc];
                [tmpBeforePicArray addObject:effectDoc.imageURL];
                
            }
            
            for (NSDictionary *dic in [data objectForKey:@"ImageAfterTreatment"]) {
                EffectImgDoc *effectDoc = [[EffectImgDoc alloc] init];
                effectDoc.imageID = [[dic objectForKey:@"TreatmentImageID"]integerValue];
                
                effectDoc.imageURL = ([dic objectForKey:@"ThumbnailURL"] == [NSNull null] ? @"" : [dic objectForKey:@"ThumbnailURL"]);
                
                effectDoc.originalImgURL = [dic objectForKey:@"OriginalImageURL"] == [NSNull null] ? @"": [dic objectForKey:@"OriginalImageURL"];
                
                [afterEffectImgArray addObject:effectDoc];
                [tmpAfterPicArray addObject:effectDoc.imageURL];
                
            }
            [_serviceEffectDatas removeAllObjects];
            for (NSDictionary *dic in [data objectForKey:@"TMList"]) {
                TMListDoc *tmListDoc = [[TMListDoc alloc] init];
                tmListDoc.treatmentID = [[dic objectForKey:@"TreatmentID"]integerValue];
                tmListDoc.subServiceName = ([dic objectForKey:@"SubServiceName"] == [NSNull null] ? @"" : [dic objectForKey:@"SubServiceName"]);
                [_serviceEffectDatas addObject:tmListDoc];
            }

            
            beforePicArray = tmpBeforePicArray;
            afterPicArray = tmpAfterPicArray;
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    /*
     _requestEffectDisplayImages =[[GPHTTPClient shareClient] requestGetEffectDisplayImages:treat_ID success:^(id xml) {
     [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
     [SVProgressHUD dismiss];
     
     if (beforeEffectImgArray)
     [beforeEffectImgArray removeAllObjects];
     else
     beforeEffectImgArray = [NSMutableArray array];
     
     if (afterEffectImgArray)
     [afterEffectImgArray removeAllObjects];
     else
     afterEffectImgArray = [NSMutableArray array];
     
     NSMutableArray *tmpBeforePicArray = [NSMutableArray array];
     NSMutableArray *tmpAfterPicArray  = [NSMutableArray array];
     
     for (GDataXMLElement *beforeEle in [contentData elementsForName:@"ImageBeforeTreatment"]) {
     EffectImgDoc *effectDoc = [[EffectImgDoc alloc] init];
     effectDoc.imageID = [[[[beforeEle elementsForName:@"TreatmentImageID"] objectAtIndex:0] stringValue] integerValue];
     
     NSString *imgURL = [[[beforeEle elementsForName:@"ThumbnailURL"] objectAtIndex:0] stringValue];
     
     effectDoc.imageURL = [imgURL length] == 0 ? @"" : imgURL;
     
     NSString *originalImgURL = [[[beforeEle elementsForName:@"OriginalImageURL"] objectAtIndex:0] stringValue];
     effectDoc.originalImgURL = [originalImgURL length] == 0 ? @"" : originalImgURL;
     
     [beforeEffectImgArray addObject:effectDoc];
     [tmpBeforePicArray addObject:effectDoc.imageURL];
     }
     
     for (GDataXMLElement *afterEle in [contentData elementsForName:@"ImageAfterTreatment"]) {
     EffectImgDoc *effectDoc = [[EffectImgDoc alloc] init];
     effectDoc.imageID = [[[[afterEle elementsForName:@"TreatmentImageID"] objectAtIndex:0] stringValue] integerValue];
     
     NSString *imgURL = [[[afterEle elementsForName:@"ThumbnailURL"] objectAtIndex:0] stringValue];
     effectDoc.imageURL = [imgURL length] == 0 ? @"" : imgURL;
     
     NSString *originalImgURL = [[[afterEle elementsForName:@"OriginalImageURL"] objectAtIndex:0] stringValue];
     effectDoc.originalImgURL = [originalImgURL length] == 0 ? @"" : originalImgURL;
     
     [afterEffectImgArray addObject:effectDoc];
     [tmpAfterPicArray addObject:effectDoc.imageURL];
     }
     
     beforePicArray = tmpBeforePicArray;
     afterPicArray = tmpAfterPicArray;
     
     } failure:^{}];
     [_tableView reloadData];
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     }];
     */
}@end
