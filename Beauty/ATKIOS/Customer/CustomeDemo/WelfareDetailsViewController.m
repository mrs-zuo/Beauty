//
//  WelfareDetailsViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/23.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "WelfareDetailsViewController.h"
#import "MJRefresh.h"
#import "GPHTTPClient.h"
#import "AppDelegate.h"
#import "WelfareRes.h"
#import "WelfareDetailsRes.h"
#import "BranchListRes.h"

@interface WelfareDetailsViewController () <UITableViewDataSource,UITableViewDelegate>
{
    WelfareDetailsRes *welfareRes;
}

@property (nonatomic,strong) UITableView *welfareDetailsTableView;
@property (nonatomic,strong) NSArray *welfareDetailsHeaderDatas;
@property (nonatomic,strong) NSMutableArray *welfareDetailsStoreDatas;

@property (weak, nonatomic) AFHTTPRequestOperation *getCustomerBenefitDetailOperation;
@property (nonatomic,copy) NSMutableString *branchListName;

@end

@implementation WelfareDetailsViewController

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    [self initData];
    [self initView];

}
- (void)initData
{
    _welfareDetailsHeaderDatas = @[@"",@"规则内容",@"规则说明",@"使用门店"];
    _welfareDetailsStoreDatas = [NSMutableArray array];
    _branchListName = [[NSMutableString alloc]init];
}
-(void)initView
{
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.title = @"福利包详情";
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _welfareDetailsTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20) style:UITableViewStyleGrouped];
    _welfareDetailsTableView.showsHorizontalScrollIndicator = NO;
    _welfareDetailsTableView.showsVerticalScrollIndicator = NO;
    _welfareDetailsTableView.backgroundColor = [UIColor clearColor];
    _welfareDetailsTableView.separatorColor = kTableView_LineColor;
    _welfareDetailsTableView.autoresizingMask = UIViewAutoresizingNone;
    _welfareDetailsTableView.delegate = self;
    _welfareDetailsTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_welfareDetailsTableView setTableFooterView:view];
    [self.view addSubview:_welfareDetailsTableView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestWelfareDetailsDatas];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }else {
        UIView *vi = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kSCREN_BOUNDS.size.width - 10, 44)];
        vi.backgroundColor = kColor_White;
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 7,vi.frame.size.width, 30)];
        nameLab.textColor =kColor_TitlePink;
        nameLab.font=kNormalFont_14;
        nameLab.textAlignment = NSTextAlignmentLeft;
        nameLab.text = _welfareDetailsHeaderDatas[section];
        [vi addSubview:nameLab];
        return vi;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _welfareDetailsHeaderDatas.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return 88;
        }
            break;
        case 1:
        {
            CGSize size = [welfareRes.PolicyDescription sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.height > 44) {
                return size.height;
            }else{
                return 44;
            }
        }
            break;
        case 2:
        {
            CGSize size = [welfareRes.PolicyComments sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.height > 44) {
                return size.height;
            }else{
                return 44;
            }
        }
            break;
        case 3:
        {
            CGSize size = [_branchListName sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.height > 44) {
                return size.height;
            }else{
                return 44;
            }
        }
            break;
        default:
        {
            return 44;
        }
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseidentifier];
    if (sec == 0) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            CGFloat dateLabWidth = (kSCREN_BOUNDS.size.width - 40) / 2;
            
            UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, kSCREN_BOUNDS.size.width - 10, 30)];
            labelName.textAlignment = NSTextAlignmentCenter;
            labelName.textColor = kColor_Black;
            labelName.font =kNormalFont_14;
            labelName.tag = 110;
            [cell.contentView addSubview:labelName];
            
            UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 48, dateLabWidth, 30)];
            labelTitle.textAlignment = NSTextAlignmentRight;
            labelTitle.font=kNormalFont_14;
            labelTitle.textColor = kColor_Black;
            UILabel *labelTitle1 = [[UILabel alloc]initWithFrame:CGRectMake(dateLabWidth + 10, 48, 20, 30)];
            labelTitle1.textAlignment = NSTextAlignmentCenter;
            UILabel *labelTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(dateLabWidth + 15 + 20, 48, dateLabWidth, 30)];
            labelTitle2.textColor = kColor_Black;
            labelTitle2.font=kNormalFont_14;
            labelTitle2.textAlignment = NSTextAlignmentLeft;
            labelTitle.tag = 1;
            labelTitle1.tag = 2;
            labelTitle2.tag = 3;
            [cell.contentView addSubview:labelTitle];
            [cell.contentView addSubview:labelTitle1];
            [cell.contentView addSubview:labelTitle2];
        }
        UILabel *labelName = (UILabel *)[cell viewWithTag:110];
        labelName.text = welfareRes.PolicyName;
        
        UILabel *labeltitle = (UILabel *)[cell viewWithTag:1];
        UILabel *labeltitle1 = (UILabel *)[cell viewWithTag:2];
        UILabel *labeltitle2 = (UILabel *)[cell viewWithTag:3];
        labeltitle.text = welfareRes.GrantDate;
        labeltitle1.text = @"至";
        labeltitle1.font=kNormalFont_14;
        labeltitle2.text = welfareRes.ValidDate;
        return cell;
    }else{
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 7, kSCREN_BOUNDS.size.width - 30, 30)];
            nameLab.textAlignment =NSTextAlignmentLeft;
            nameLab.tag = 1;
            nameLab.numberOfLines = 0;
            nameLab.lineBreakMode = NSLineBreakByCharWrapping;
            [cell.contentView addSubview:nameLab];
        }
        UILabel *nameLab = (UILabel *)[cell viewWithTag:1];
        nameLab.font=kNormalFont_14;
        switch (sec) {
            case 1:
            {
                nameLab.text = welfareRes.PolicyDescription;
                [self changeNameLabelFrameWithString: welfareRes.PolicyDescription lab:nameLab];
                
            }
                break;
            case 2:
            {
                nameLab.text = welfareRes.PolicyComments;
                
                [self changeNameLabelFrameWithString:welfareRes.PolicyComments lab:nameLab];
            }
                break;
            case 3:
            {
                nameLab.text = _branchListName;
                nameLab.textColor=kColor_Editable;
                [self changeNameLabelFrameWithString:_branchListName lab:nameLab];
            }
                break;
                
            default:
                break;
        }
        return cell;
    }
}
- (void)changeNameLabelFrameWithString:(NSString *) string lab:(UILabel *)lab
{
    CGSize size = [string sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (size.height > 44) {
        lab.frame = CGRectMake(10, 7, kSCREN_BOUNDS.size.width - 30, size.height);
    }else{
        lab.frame  = CGRectMake(10, 7, kSCREN_BOUNDS.size.width - 30, 30);
    }
    
}

-(void)requestWelfareDetailsDatas
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID),
                              @"BenefitID":self.benefitID};
    _getCustomerBenefitDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerBenefitDetail"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)data;
                welfareRes = [[WelfareDetailsRes alloc]init];
                welfareRes.PolicyID = [dic objectForKey:@"PolicyID"];
                welfareRes.PolicyName = [dic objectForKey:@"PolicyName"];
                welfareRes.PolicyDescription = [dic objectForKey:@"PolicyDescription"];
                welfareRes.PolicyComments = [dic objectForKey:@"PolicyComments"];
                welfareRes.GrantDate = [dic objectForKey:@"GrantDate"];
                welfareRes.ValidDate = [dic objectForKey:@"ValidDate"];
                welfareRes.PRCode = [dic objectForKey:@"PRCode"];
                welfareRes.PRValue1 = [dic objectForKey:@"PRValue1"];
                welfareRes.PRValue2 = [dic objectForKey:@"PRValue2"];
                welfareRes.PRValue3 = [dic objectForKey:@"PRValue3"];
                welfareRes.PRValue4 = [dic objectForKey:@"PRValue4"];
                welfareRes.BenefitStatus = [dic objectForKey:@"BenefitStatus"];
                welfareRes.BranchList = [dic objectForKey:@"BranchList"];
                if (welfareRes.BranchList.count > 0) {
                    for (int  i = 0; i < welfareRes.BranchList.count; i ++) {
                        NSDictionary *branchDic = welfareRes.BranchList[i];
                        BranchListRes *branchList = [[BranchListRes alloc]init];
                        branchList.BranchID = [branchDic objectForKey:@"BranchID"];
                        branchList.BranchName = [branchDic objectForKey:@"BranchName"];
                        NSString *temp = [[NSString alloc]init];
                        temp =[NSString stringWithFormat:@"%@\n\n",branchList.BranchName];
                        [_branchListName appendString:temp];
                    }
                }
            }
            [_welfareDetailsTableView headerEndRefreshing];
            [_welfareDetailsTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}

-(void)dealloc
{
    _branchListName = nil;
    welfareRes = nil;
}

@end
