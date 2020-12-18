//
//  EffectDisplayViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-8.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "EffectDisplayViewController.h"
#import "UILabel+InitLabel.h"
#import "PictureDisplayView.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"

#define IMG_SCROLL_LEFT_0 [UIImage imageNamed:@"imgScroll_L0"]
#define IMG_SCROLL_LEFT_1 [UIImage imageNamed:@"imgScroll_L1"]

#define IMG_SCROLL_RIGHT_0 [UIImage imageNamed:@"imgScroll_R0"]
#define IMG_SCROLL_RIGHT_1 [UIImage imageNamed:@"imgScroll_R1"]

@interface EffectDisplayViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestEffectDisplayImages;
@property (assign, nonatomic) BOOL isSynchronized;
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

@end

@implementation EffectDisplayViewController
@synthesize isSynchronized;
@synthesize beforePicArray;
@synthesize afterPicArray;
@synthesize beforePictureDisplayView, nextButton, prevButton;
@synthesize afterPictureDisplayView, afterNextBtn, afterPervBtn;
@synthesize treat_ID;
@synthesize titleStr;
@synthesize titleView;

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    
    if (self.treatMentOrGroup ==1) {
        titleStr = @"服务";
    }else{
        titleStr = @"操作";
    }
    self.tabBarController.title =  [NSString stringWithFormat:@"%@效果",titleStr];
    [self getServiceEffectImage];
}

- (void)viewWillDisappear:(BOOL)animated
{    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
- (void)viewDidLoad
{
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    if (IOS7 || IOS8) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    beforePictureDisplayView = nil;
    afterPictureDisplayView = nil;
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
//        NSString *cellIndetity = @"cell";
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetity];
//        cell.backgroundColor = [UIColor whiteColor];
//        UILabel *offLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 15.0f, 200, 21.0f) title:@"同步浏览"];
//        offLabel.font = kNormalFont_14;
//        offLabel.textColor = kColor_TitlePink;
//        [cell.contentView addSubview:offLabel];
//        return cell;
//    } else {
        NSString *cellIndetity = @"imageCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetity];
         cell.backgroundColor = [UIColor clearColor];
        // 服务前
        UILabel *beforLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 15.0f, 200.0f, 20.0f) title:[NSString stringWithFormat:@"%@前照片",titleStr]];
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
        return 0.1;
//    } else {
//        return kTableView_Margin_TOP;
//    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
//        return kTableView_DefaultCellHeight;
//    } else {
        return 365.0f;
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
    NSDictionary *para = @{@"TreatmentID":@(treat_ID),@"ImageThumbWidth":@(150),@"ImageThumbHeight":@(150)};
    _requestEffectDisplayImages = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Image/getServiceEffectImage"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {

        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpBeforeArray = [NSMutableArray array];
            NSMutableArray *tmpAfterArray = [NSMutableArray array];
            NSArray *imageBeforeTreatment = data[@"ImageBeforeTreatment"];
            [imageBeforeTreatment enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpBeforeArray addObject:obj[@"ThumbnailURL"]];
            }];
            NSArray *imageAfterTreatment = data[@"ImageAfterTreatment"];
            [imageAfterTreatment enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [tmpAfterArray addObject:obj[@"ThumbnailURL"]];
            }];
            beforePicArray = tmpBeforeArray;
            afterPicArray = tmpAfterArray;
            [_tableView reloadData];
            [SVProgressHUD dismiss];    
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
}

@end
