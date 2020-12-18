//
//  PromotionDetail_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/22.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

const CGFloat kSectionView_Height = 50;
const CGFloat kCell_Height = 50;
const CGFloat kLabel_Height = 20.0;

#import "PromotionDetail_ViewController.h"
#import "SalesPromotionModel.h"
#import "BranchInfoModel.h"
#import "ShopInfoViewController.h"
#import "ShopInfoModel.h"
#import "PromoDetailsDateTableViewCell.h"

#define kColorPink [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:1.0]

@interface PromotionDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *getDetail;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSString * headerUrlStr;
@property(nonatomic,strong)SalesPromotionModel *salesPromotion;
@property(strong,nonatomic)NSMutableArray *sectionDatas;

@end

@implementation PromotionDetail_ViewController
@synthesize myTableView;
@synthesize headerUrlStr;

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.title = @"促销详情";
    [self initMyTableView];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _sectionDatas = [NSMutableArray arrayWithObjects:@"图片",@"活动细则",@"促销时间",@"适用门店一览", nil];
}

-(void)initMyTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 5)];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = kColor_Clear;
    myTableView.backgroundView = nil;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestListWithStatus];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionDatas.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = _sectionDatas[section];
    if ([title isEqualToString:@"适用门店一览"] ) {
        return [[_salesPromotion valueForKey:@"BranchList"]count] ;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *title = _sectionDatas[section];
    if ([title isEqualToString:@"图片"]) {
        return 0.1;
    }
    return kSectionView_Height;
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = _sectionDatas[indexPath.section];
    if ([title isEqualToString:@"图片"]) {
        CGRect tempRect = [self.salesPromotion.Title boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14}context:nil];
        CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
        if (lines > 1) {
            return (kSCREN_BOUNDS.size.width  * 0.75) + tempRect.size.height + (lines * 5) + 20 + 10;
        }else{
            return (kSCREN_BOUNDS.size.width  * 0.75) + kSectionView_Height;
        }
    }else if ([title isEqualToString:@"促销时间"]){
        return 80;
    }else if ([title isEqualToString:@"活动细则"]) {
        CGRect tempRect = [self.salesPromotion.Description boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
        CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
        if (lines > 1) {
            return tempRect.size.height + (lines * 5) +15;
        }else {
            return kCell_Height;
        }
    }else{
        return kCell_Height;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = _sectionDatas[section];
    if ([title isEqualToString:@"图片"]) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, (kSCREN_BOUNDS.size.width *0.75) + kSectionView_Height)];
        return headerView;
    }else{
        
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width,kSectionView_Height)];
        
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, kSCREN_BOUNDS.size.width, kLabel_Height)];
        nameLab.font = kNormalFont_14;
        nameLab.numberOfLines = 0;
        nameLab.text = title;
        [sectionView addSubview:nameLab];
        sectionView.backgroundColor = kDefaultBackgroundColor;
        return sectionView;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = _sectionDatas[indexPath.section];
    NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseidentifier];
    
    if ([title isEqualToString:@"图片"]) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DisplayPicCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,0 , kSCREN_BOUNDS.size.width, (kSCREN_BOUNDS.size.width  * 0.75))];
            imageView.tag = 101;
            [cell.contentView addSubview:imageView];

            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 15, kSCREN_BOUNDS.size.width - 20,kLabel_Height)];
            label.tag = 102;
            label.numberOfLines = 0;
            label.font = kNormalFont_14;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }

        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_salesPromotion.PromotionPictureURL]];
        BOOL valid = [NSURLConnection canHandleRequest:req];
        UIImageView *image = (UIImageView*)[cell viewWithTag:101];
        if (valid != NO) {
            image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_salesPromotion.PromotionPictureURL]]];
        }else {
            image.image = [UIImage imageNamed:@"indexDefaultImage"];
        }
        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        CGRect titleRect = [self.salesPromotion.Title boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
        
        CGFloat lines = ceil((titleRect.size.height / (kNormalFont_14.lineHeight - 5)));
        CGRect rect = label1.frame;
        if (lines > 1) {
            rect.size.height = titleRect.size.height + (lines * 5);
        }else{
            rect.size.height = kLabel_Height;
        }
        label1.frame = rect;
        if (self.salesPromotion.Title) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.salesPromotion.Title];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineSpacing  = 5;
            [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            label1.attributedText = attributedString;
            label1.textAlignment = NSTextAlignmentCenter;
        }
        
        

        return cell;
    }else if ([title isEqualToString:@"促销时间"]){
       static NSString *identifier = @"PromoDetailsDateCell";
        PromoDetailsDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"PromoDetailsDateTableViewCell" owner:self options:nil].firstObject;
        }
        cell.startLab.text = _salesPromotion.StartDate;
        cell.endLab.text = _salesPromotion.EndDate;
        
        return cell;
    }else if ([title isEqualToString:@"活动细则"]){
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,10, kSCREN_BOUNDS.size.width - 20,kLabel_Height)];
            label.tag = 300;
            label.numberOfLines = 0;
            label.textColor = kMainLightGrayColor;
            label.font = kNormalFont_14;
            label.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:label];
        }
        UILabel *deslab = [cell.contentView viewWithTag:300];
        CGRect tempRect = [self.salesPromotion.Description boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
       
        CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
        CGRect rect = deslab.frame;
        rect.size.height = tempRect.size.height + (lines * 5) ;
        deslab.frame = rect;
        if (self.salesPromotion.Description) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.salesPromotion.Description];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineSpacing  = 5;
            [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            deslab.attributedText = attributedString;
        }
        return cell;
    }
    else if ([title isEqualToString:@"适用门店一览"])
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, kSCREN_BOUNDS.size.width - 40, kLabel_Height)];
            label.tag = 300;
            label.font = kNormalFont_14;
            label.textColor = kMainLightGrayColor;
            [cell.contentView addSubview:label];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row >= 0) {
            UILabel *label1 = (UILabel *)[cell viewWithTag:300];
            BranchInfoModel * branchInfo = [[_salesPromotion valueForKey:@"BranchList"] objectAtIndex:indexPath.row];
            label1.text = branchInfo.BranchName ;
            return cell;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = _sectionDatas[indexPath.section];
    self.hidesBottomBarWhenPushed = YES;
    if ([title isEqualToString:@"适用门店一览"]) {
         BranchInfoModel * branchInfo = [[_salesPromotion valueForKey:@"BranchList"] objectAtIndex:indexPath.row];
        ShopInfoModel * model = [[ShopInfoModel alloc] init];
        model.BranchName = branchInfo.BranchName;
        model.BranchID = branchInfo.BranchID;
        self.navigationController.hidesBottomBarWhenPushed = YES;
        ShopInfoViewController * info = [[ShopInfoViewController alloc] init];
        info.currentShop = model;
        info.BranchID = model.BranchID;
        [self.navigationController pushViewController:info animated:YES];
        
    }
}

#pragma mark - 接口
-(void)requestListWithStatus
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary * para = @{
                            @"ImageWidth":@(kSCREN_BOUNDS.size.width),
                            @"ImageHeight":@(kSCREN_BOUNDS.size.width * 0.75),
                            @"Prama":self.promotionCode
                            };
    
    _getDetail = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Promotion/GetPromotionDetail" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
           self.salesPromotion = [[SalesPromotionModel alloc]initWithDic:data];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
        [myTableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}




@end
