//
//  WelfareDetailsViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/23.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "WelfareDetailsViewController.h"
#import "NavigationView.h"
#import "MJRefresh.h"
#import "WelfareDetailsRes.h"
#import "BranchListRes.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"
#import "GPHTTPClient.h"

@interface WelfareDetailsViewController () <UITableViewDelegate,UITableViewDataSource>
{
    WelfareDetailsRes *welfareRes;
}
@property (weak, nonatomic) AFHTTPRequestOperation *getCustomerBenefitDetailOperation;
@property (nonatomic,strong) UITableView *welfareDetailsTableView;
@property (nonatomic,strong) NSArray *welfareDetailsHeaderDatas;
@property (nonatomic,copy) NSMutableString *branchListName;

@end

@implementation WelfareDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)initData
{
    _welfareDetailsHeaderDatas = @[@"",@"规则内容",@"细则说明",@"适用门店"];
    _branchListName = [[NSMutableString alloc]init];
}
-(void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"福利详情"];
    navigationView.titleLabel.textColor =RGBA(0, 0, 137, 1);
    [self.view addSubview:navigationView];
    
    _welfareDetailsTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, navigationView.frame.size.height + navigationView.frame.origin.y + 5, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.size.height + navigationView.frame.origin.y) - 64 + 20) style:UITableViewStyleGrouped];
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
    [self requestGetCustomerBenefitDetail];
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
        nameLab.textColor =RGBA(0, 0, 137, 1);
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
            CGRect rect = [welfareRes.PolicyComments  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];

//            CGSize size = [welfareRes.PolicyDescription sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            if (rect.size.height > 44) {
                return rect.size.height + 20;
            }else{
                return 44;
            }
        }
            break;
        case 2:
        {
            CGRect rect = [welfareRes.PolicyComments  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];

//            CGSize size = [welfareRes.PolicyComments sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(kSCREN_BOUNDS.size.width - 10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            if (rect.size.height > 44) {
                return rect.size.height + 20;
            }else{
                return 44;
            }
        }
            break;
        case 3:
        {
            CGRect rect = [_branchListName boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
            if (rect.size.height > 44) {
                return rect.size.height + 20;
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
                
                UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, kSCREN_BOUNDS.size.width - 10, 30)];
                labelName.textAlignment = NSTextAlignmentCenter;
                labelName.textColor = kColor_Black;
                labelName.font = [UIFont boldSystemFontOfSize:17];
                labelName.tag = 110;
                [cell.contentView addSubview:labelName];

                UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 48, dateLabWidth, 30)];
                labelTitle.textAlignment = NSTextAlignmentRight;
                labelTitle.textColor = kColor_Black;
                UILabel *labelTitle1 = [[UILabel alloc]initWithFrame:CGRectMake(dateLabWidth + 10, 48, 20, 30)];
                labelTitle1.textAlignment = NSTextAlignmentCenter;
                UILabel *labelTitle2 = [[UILabel alloc]initWithFrame:CGRectMake(dateLabWidth + 15 + 20, 48, dateLabWidth, 30)];
                labelTitle2.textColor = kColor_Black;
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
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    if (rect.size.height > 44) {
        lab.frame = CGRectMake(10, 7, kSCREN_BOUNDS.size.width - 30, rect.size.height);
        [lab sizeToFit];
    }else{
        lab.frame  = CGRectMake(10, 7, kSCREN_BOUNDS.size.width - 30, 30);
    }

}
#pragma mark -  接口
-(void)requestGetCustomerBenefitDetail
{
//    /ECard/GetCustomerBenefitDetail 福利白详情
//    所需参数
//    {"BenefitID":"CBE1602240000000002","CustomerID":2569}
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSInteger  customerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
    NSDictionary * par = @{
                                @"BenefitID":self.benefitID,
                                @"CustomerID":@(customerID),
                                };
//        NSString *par = [NSString stringWithFormat:@"{\"BenefitID\":%@,\"CustomerID\":%ld}",self.benefitID, (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
    
        _getCustomerBenefitDetailOperation= [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerBenefitDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
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
                        temp =[NSString stringWithFormat:@"%@\n",branchList.BranchName];
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
