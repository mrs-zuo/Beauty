//
//  ZXServiceEffectViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/1/25.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//
#define IMG_SCROLL_LEFT_0 [UIImage imageNamed:@"imgScroll_L0"]
#define IMG_SCROLL_LEFT_1 [UIImage imageNamed:@"imgScroll_L1"]

#define IMG_SCROLL_RIGHT_0 [UIImage imageNamed:@"imgScroll_R0"]
#define IMG_SCROLL_RIGHT_1 [UIImage imageNamed:@"imgScroll_R1"]

#import "ZXServiceEffectViewController.h"
#import "UILabel+InitLabel.h"
#import "PictureDisplayView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "EffectImgDoc.h"
#import "TMListDoc.h"
#import "OrderTabBarController.h"
#import "TreatmentDetailViewController.h"
#import "EffectDisplayViewController.h"
#import "TreatmentCommentViewController.h"
#import "TreatmentDoc.h"


@interface ZXServiceEffectViewController ()

@property (weak, nonatomic) AFHTTPRequestOperation *requestEffectDisplayImages;
@property (assign, nonatomic) BOOL isSynchronized;
@property (strong, nonatomic) NSMutableArray *beforeEffectImgArray; // 保存着 EffectImgDoc
@property (strong, nonatomic) NSMutableArray * afterEffectImgArray; // 保存着 EffectImgDoc
@property (strong, nonatomic) NSArray *beforePicArray;
@property (strong, nonatomic) NSArray *afterPicArray;
@property(strong ,nonatomic)NSString * titleStr;
@property(strong,nonatomic)TitleView *titleView;

// -- view
@property (strong, nonatomic) UIButton *prevButton;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *afterPervBtn;
@property (strong, nonatomic) UIButton *afterNextBtn;
@property (strong, nonatomic) PictureDisplayView *beforePictureDisplayView;
@property (strong, nonatomic) PictureDisplayView *afterPictureDisplayView;

@property (strong, nonatomic) NSMutableArray *serviceEffectDatas;


@end

@implementation ZXServiceEffectViewController
@synthesize isSynchronized;
@synthesize beforePicArray;
@synthesize afterPicArray;
@synthesize beforePictureDisplayView, nextButton, prevButton;
@synthesize afterPictureDisplayView, afterNextBtn, afterPervBtn;
@synthesize treat_ID;
@synthesize titleStr;
@synthesize titleView;
@synthesize GroupNo;
@synthesize beforeEffectImgArray, afterEffectImgArray;


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

- (void)viewWillAppear:(BOOL)animated
{
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewWillAppear:animated];
    [self getServiceEffectImage];
    self.tabBarController.title =  @"服务效果";
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
     self.view.backgroundColor = kDefaultBackgroundColor;
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewDidLoad];
    if (self.treatMentOrGroup ==1) {
        titleStr = @"服务";
        //        [self GetTGDetail];
        
    }else
    {
        titleStr = @"操作";
        //        [self getTreatmentDetail];
    }
        _serviceEffectDatas = [NSMutableArray array];

}
- (void)initTableView
{
    
    if (IOS7 || IOS8) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height -  49 + 20) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = kTableView_LineColor;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];

    }else{
        [_tableView reloadData];
    }
    
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

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            return kTableView_DefaultCellHeight;
//        }else{
            return 355.0f;
//        }
    }else{
        return kTableView_DefaultCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 0.1;
    }
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
//            NSString *cellIndetity = @"cell";
//            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetity];
//            cell.backgroundColor = [UIColor whiteColor];
//            UILabel *offLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 15.0f, 200, 21.0f) title:@"同步浏览"];
//            offLabel.font = kNormalFont_14;
//            offLabel.textColor = kColor_TitlePink;
//            [cell.contentView addSubview:offLabel];
//            
//            /*UISwitch *offSwitch = [[UISwitch alloc] init];
//             [offSwitch addTarget:self action:@selector(changeBrowseType:) forControlEvents:UIControlEventValueChanged];
//             cell.accessoryView = offSwitch;*/
//            return cell;
//        } else {
            NSString *cellIndetity = @"imageCell";
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetity];
            cell.backgroundColor = [UIColor clearColor];
            // 服务前
            UILabel *beforLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f,15.0f, 200.0f, 20.0f) title:[NSString stringWithFormat:@"%@前照片",titleStr]];
            beforLabel.font = kNormalFont_14;
            beforLabel.textColor = kColor_TitlePink;
            [cell.contentView addSubview:beforLabel];
            
            for (int i = 0; i < 2; i++) {
                prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [prevButton setFrame:CGRectMake(0.0f, 70.0f + 170.0f * i, 14.0f, 20.0f)];
                [prevButton setBackgroundImage:IMG_SCROLL_LEFT_1 forState:UIControlStateNormal];
                [prevButton setBackgroundImage:IMG_SCROLL_LEFT_0 forState:UIControlStateSelected];
                [prevButton addTarget:self action:@selector(previousPageAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:prevButton];
                [prevButton setSelected:YES];
                prevButton.tag = 100 + i;
                
                nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [nextButton setFrame:CGRectMake(310.0f - 14.0f, 70.0f + 170*i, 14.0f, 20.0f)];
                [nextButton setBackgroundImage:IMG_SCROLL_RIGHT_1 forState:UIControlStateNormal];
                [nextButton setBackgroundImage:IMG_SCROLL_RIGHT_0 forState:UIControlStateSelected];
                [nextButton addTarget:self action:@selector(nextPageAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:nextButton];
                nextButton.tag = 200 + i;
            }
            
            UIView * beforeBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 45.0f,320.0f, 120.0f) ];
            beforeBgView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:beforeBgView];
            
            beforePictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(30.0f, 45.0f, 250.0f, 120.0f) picSize:CGSizeMake(120.0f, 120.0f) spacing:10.0f];
            [beforePictureDisplayView setPicturesWithURLs:beforePicArray];
            [beforePictureDisplayView setDelegate:self];
            beforePictureDisplayView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:beforePictureDisplayView];
            
            // 服务后
            UILabel *afterLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 177.5f, 160.0f, 20.0f) title:[NSString stringWithFormat:@"%@后照片",titleStr]];
            afterLabel.font = kNormalFont_14;
            afterLabel.textColor = kColor_TitlePink;
            [cell.contentView addSubview:afterLabel];
            
            UIView * afterBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 210.0f,320.0f, 120.0f) ];
            afterBgView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:afterBgView];
            
            afterPictureDisplayView = [[PictureDisplayView alloc] initWithFrame:CGRectMake(30.0f, 210.0f, 250.0f, 120.0f) picSize:CGSizeMake(120.0f, 120.0f) spacing:10.0f];
            [afterPictureDisplayView setPicturesWithURLs:afterPicArray];
            [afterPictureDisplayView setDelegate:self];
            afterPictureDisplayView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:afterPictureDisplayView];
            return cell;
        }

    }else{
        NSString *cellIndetity = @"MyCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndetity];
        cell.backgroundColor = [UIColor whiteColor];
        TMListDoc *tmListDoc = _serviceEffectDatas[indexPath.row];
        cell.textLabel.text =tmListDoc.subServiceName;
        cell.textLabel.font=kNormalFont_14;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        TMListDoc *tmListDoc = _serviceEffectDatas[indexPath.row];
        OrderTabBarController *tabBarController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"OrderTabBarController"];
        
        TreatmentDetailViewController *treatmentDetailViewController = [tabBarController.viewControllers objectAtIndex:0];
        TreatmentDoc  *treatmentDoc_Selected = [[TreatmentDoc alloc]init];
        treatmentDoc_Selected.treat_ID = tmListDoc.treatmentID;
        
        treatmentDetailViewController.treatmentDoc = treatmentDoc_Selected;
        treatmentDetailViewController.OrderID = _OrderID;
        treatmentDetailViewController.GroupNo = GroupNo;
        
        EffectDisplayViewController *effectDosplayeController = [tabBarController.viewControllers objectAtIndex:1];
        effectDosplayeController.treat_ID = tmListDoc.treatmentID;
        effectDosplayeController.GroupNo = GroupNo;
        effectDosplayeController.OrderID = _OrderID;
        
        TreatmentCommentViewController *treatmentCommentViewController = [tabBarController.viewControllers objectAtIndex:2];
        treatmentCommentViewController.treatmentComment.comment_TreatmentID = tmListDoc.treatmentID;
        treatmentCommentViewController.orderId = _OrderID;
        treatmentCommentViewController.GroupNo = GroupNo;
        
        [tabBarController selectTab:101];
        tabBarController.selectedIndex = 1;
        [self.navigationController pushViewController:tabBarController animated:YES];
        
    }
}


- (void)changeBrowseType:(id)sender
{
    UISwitch *ctlSh = (UISwitch *)sender;
    isSynchronized = ctlSh.on;
}

- (void)previousPageAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 100) {
        [beforePictureDisplayView scrollToPreviouPicture];
    } else if (button.tag == 101) {
        [afterPictureDisplayView scrollToPreviouPicture];
    }
}

- (void)nextPageAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 200) {
        [beforePictureDisplayView scrollToNextPicture];
    } else if (button.tag == 201) {
        [afterPictureDisplayView scrollToNextPicture];
    }
}

#pragma mark - PictureDisplayViewDelegate

- (void)pictureDisplayView:(PictureDisplayView *)pictureDisplayView leftmost:(BOOL)isLeftmost rightmost:(BOOL)isRightmost
{
    if (pictureDisplayView == beforePictureDisplayView) {
        UIButton *prevBtn = (UIButton *)[self.view viewWithTag:100];
        UIButton *nextBtn = (UIButton *)[self.view viewWithTag:200];
        [prevBtn setSelected:isLeftmost];
        [nextBtn setSelected:isRightmost];
    } else if (pictureDisplayView == afterPictureDisplayView) {
        UIButton *prevBtn = (UIButton *)[self.view viewWithTag:101];
        UIButton *nextBtn = (UIButton *)[self.view viewWithTag:201];
        [prevBtn setSelected:isLeftmost];
        [nextBtn setSelected:isRightmost];
    }
}
#pragma mark - 接口

- (void)getServiceEffectImage
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
     NSDictionary *para = @{@"GroupNo":@(GroupNo),@"ImageThumbWidth":@(150),@"ImageThumbHeight":@(150)};

    _requestEffectDisplayImages = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Image/getServiceEffectImage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
          
            
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
            
            
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self initTableView];
    } failure:^(NSError *error) {
        
    }];

   
}


@end
