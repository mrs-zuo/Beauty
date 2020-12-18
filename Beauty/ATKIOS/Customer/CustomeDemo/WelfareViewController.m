//
//  WelfareViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/23.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "WelfareViewController.h"
#import "MJRefresh.h"
#import "WelfareDetailsViewController.h"
#import "GPHTTPClient.h"
#import "AppDelegate.h"
#import "WelfareRes.h"

#define CUS_CUSTOMERID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue]

@interface WelfareViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UIView *lineView;
    NSInteger lineView_Width;
    NSInteger selectSegIndex;
}
@property (nonatomic,strong) UITableView *welfareTableView;
@property (nonatomic,strong) NSMutableArray *welfareDatas;

@property (weak  , nonatomic) AFHTTPRequestOperation *getCustomerBenefitListOperation;


@end

@implementation WelfareViewController

-(void)initSegmentControl
{
    NSArray *arr = @[@"未使用",@"已过期",@"已使用"];

    //先创建一个数组用于设置标题
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:arr];
    [segment setApportionsSegmentWidthsByContent:YES];//时，每个的宽度按segment的宽度平分
    segment.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 40);
    segment.selectedSegmentIndex= selectSegIndex;
    segment.tintColor = kColor_Clear;
    segment.backgroundColor = kColor_White;
    
    //修改字体的默认颜色与选中颜色
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:kColor_TitlePink,UITextAttributeTextColor,  [UIFont fontWithName:@"Helvetica" size:14.f],UITextAttributeFont ,kColor_TitlePink,UITextAttributeTextShadowColor ,nil];
    [segment setTitleTextAttributes:dic forState:UIControlStateSelected];
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    [self.view addSubview:segment];
    
    segment.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
    [segment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    
    UIView * lightLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39,320, 0.5f)];
    lightLineView.backgroundColor = kTableView_LineColor;
    [self.view addSubview:lightLineView];
    
    lineView_Width = (kSCREN_BOUNDS.size.width - 10) / 3;
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, lineView_Width, 0.5f)];
    lineView.backgroundColor = kColor_TitlePink;
    [self.view addSubview:lineView];
    
}

-(void)initView
{
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
     self.title = @"福利包";
    if ((IOS7 || IOS8)) {
        _welfareTableView.separatorInset = UIEdgeInsetsZero;
    }
    _welfareTableView = [[UITableView alloc]initWithFrame:CGRectMake( 5, 40, kSCREN_BOUNDS.size.width-10, kSCREN_BOUNDS.size.height-kNavigationBar_Height - 40 + 20) style:UITableViewStyleGrouped];
    _welfareTableView.allowsSelection = YES;
    _welfareTableView.showsHorizontalScrollIndicator = NO;
    _welfareTableView.showsVerticalScrollIndicator = NO;
    _welfareTableView.delegate =self;
    _welfareTableView.dataSource =self;
    _welfareTableView.autoresizingMask = UIViewAutoresizingNone;
    _welfareTableView.separatorColor = kTableView_LineColor;
    [self.view addSubview:_welfareTableView];
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_welfareTableView setTableFooterView:view];
    [_welfareTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
}
-(void)initData
{
     selectSegIndex = 0;
    _welfareDatas = [NSMutableArray array];
}
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initSegmentControl];
    [self initView];
    [self requestWelfareList];
}
-(void)headerRefresh
{
    [self requestWelfareList];
}
- (void)segmentedAction:(UISegmentedControl *)sender
{
    
        [UIImageView beginAnimations:@"anim" context:NULL];
        [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIImageView setAnimationBeginsFromCurrentState:YES];
        [UIImageView setAnimationDuration:0.5];
        CGRect listFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        UISegmentedControl *control = (UISegmentedControl *)sender;
        selectSegIndex = control.selectedSegmentIndex;
        switch (control.selectedSegmentIndex) {
            case 0:
                listFrame = CGRectMake(0.0f, 39.0f, lineView_Width, 0.5f);
                break;
            case 1:
                listFrame = CGRectMake(lineView_Width, 39.0f, lineView_Width, 0.5f);
                break;
            case 2:
                listFrame = CGRectMake(2 * lineView_Width, 39.0f, lineView_Width, 0.5f);
                break;
            default:
                break;
        }
        lineView.frame = listFrame;
        [UIImageView commitAnimations];
        [self requestWelfareList];
    
}
#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  [_welfareDatas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //福利包
    static NSString * str = @"cell";
    UITableViewCell * cell = [_welfareTableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    cell.layer.cornerRadius = 8 ;

    //init view
    
    UIView * whithView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, kSCREN_BOUNDS.size.width-13, 0)];
    UIView * checkWhithView = (UIView *)[cell.contentView viewWithTag:1000 *(selectSegIndex+1)+indexPath.row];
    if (!checkWhithView) {
        whithView.tag = 1000 *(selectSegIndex+1)+indexPath.row;
        whithView.backgroundColor = [UIColor whiteColor];
        whithView.layer.cornerRadius = 8 ;
        [cell.contentView addSubview:whithView];
    }
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, cell.frame.size.width - 20, 30)];
    UILabel *checkNameLab = (UILabel *)[cell.contentView viewWithTag:3000 *(selectSegIndex+1)+indexPath.row];
    if (!checkNameLab) {
        nameLab.tag = 4000 *(selectSegIndex+1)+indexPath.row;
        nameLab.font = kNormalFont_16 ;
        nameLab.textColor = kColor_Editable;
        nameLab.numberOfLines = 0;
        nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:nameLab];
    }
    
    UILabel *nameDetailsLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 55, cell.frame.size.width - 40, 30)];
    UILabel *checkNameDetailsLab = (UILabel *)[cell.contentView viewWithTag:40000 *(selectSegIndex+1)+indexPath.row];
    if (!checkNameDetailsLab) {
        nameDetailsLab.tag = 40000 *(selectSegIndex+1)+indexPath.row;
        nameDetailsLab.font = kNormalFont_14;
        nameDetailsLab.textColor = kColor_Editable;
        nameDetailsLab.numberOfLines = 0;
        nameDetailsLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:nameDetailsLab];
    }
    
    UIImageView * imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(_welfareTableView.frame.size.width-23, 31, 15, 18)];
    UIImageView * checkImageView = (UIImageView *)[cell.contentView viewWithTag:10000 *(selectSegIndex+1)+indexPath.row];
    if (!checkImageView) {
        imageNext.image = [UIImage imageNamed:@"arrows_bg"];
        imageNext.tag = 10000 *(selectSegIndex+1)+indexPath.row;
        [cell.contentView addSubview:imageNext];
    }
    
    //data
    WelfareRes *welfare = [_welfareDatas objectAtIndex:indexPath.section];
    nameLab.text = welfare.PolicyName;
    nameDetailsLab.text = welfare.PolicyDescription;
    NSInteger height = [welfare.PolicyDescription sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width-40, 500) lineBreakMode:NSLineBreakByCharWrapping].height;
   
    whithView.frame = CGRectMake(3, 0, kSCREN_BOUNDS.size.width-13, (height<20?20:height) + 70);
    
    nameDetailsLab.frame = CGRectMake(10, 55, cell.frame.size.width - 40, (height<20?20:height));
    
    imageNext.frame = CGRectMake(_welfareTableView.frame.size.width-23,((height<20?20:height) + 20 + 50)/2 -9, 15, 18);
   
    if (selectSegIndex == 0) {
        cell.backgroundColor = [UIColor colorWithRed:239/255.0f green:37/255.0f blue:104/255.0f alpha:1.0f];
        nameLab.textColor = [UIColor blackColor];
    }else {
        cell.backgroundColor = [UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f];
        nameLab.textColor = kColor_Editable;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WelfareRes *welfare = [_welfareDatas objectAtIndex:indexPath.section];
    
    NSInteger height = [welfare.PolicyDescription sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width-40, 500) lineBreakMode:NSLineBreakByCharWrapping].height;
    
    return ((height<20?20:height)+ 70);

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WelfareRes *welfare = [_welfareDatas objectAtIndex:indexPath.section];
    WelfareDetailsViewController *welfareDetailsVC = [[WelfareDetailsViewController alloc]init];
    welfareDetailsVC.benefitID = welfare.BenefitID;
    [self.navigationController  pushViewController:welfareDetailsVC animated:YES];
}
#pragma mark - 接口

- (void)requestWelfareList
{
//    [_welfareDatas removeAllObjects];
//    for (int i =0 ; i < 10; i ++) {
//        [_welfareDatas addObject:@(i)];
//    }
//    [_welfareTableView headerEndRefreshing];
//    [_welfareTableView reloadData];
    
    //    /ECard/GetCustomerBenefitList 我的福利包
    //    所需参数
    //    {"Type":1,"CustomerID":2569}
    //    Type=1 未使用
    //    Type=2 已经过期
    //    Type=3 已经使用

    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID),
                              @"Type":@(selectSegIndex + 1)};
    _getCustomerBenefitListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerBenefitList"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            [_welfareDatas removeAllObjects];
            if ([data isKindOfClass:[NSArray class]]) {
                NSArray *dataArrs = (NSArray *)data;
                if (dataArrs.count > 0) {
                    for (int i =0 ; i <dataArrs.count ; i ++) {
                        NSDictionary *dic = dataArrs[i];
                        WelfareRes *welfareRes = [[WelfareRes alloc]init];
                        welfareRes.PolicyID = [dic objectForKey:@"PolicyID"];
                        welfareRes.PolicyName = [dic objectForKey:@"PolicyName"];
                        welfareRes.BenefitID = [dic objectForKey:@"BenefitID"];
                        welfareRes.PolicyDescription = [dic objectForKey:@"PolicyDescription"];
                        welfareRes.PRCode = [dic objectForKey:@"PRCode"];
                        welfareRes.PRValue1 = [dic objectForKey:@"PRValue1"];
                        welfareRes.PRValue2 = [dic objectForKey:@"PRValue2"];
                        welfareRes.PRValue3 = [dic objectForKey:@"PRValue3"];
                        welfareRes.PRValue4 = [dic objectForKey:@"PRValue4"];
                        [_welfareDatas addObject:welfareRes];
                    }
                }
            }
            [_welfareTableView headerEndRefreshing];
            [_welfareTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];

}
@end
