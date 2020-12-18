//
//  MyProfiel_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/13.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "MyProfiel_ViewController.h"
#import "MyProfielEdit_ViewController.h"
#import "AccountDetailViewController.h"

@interface MyProfiel_ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestMyProfiel;
@property (nonatomic,strong) NSArray * personalArr;
@property (nonatomic,strong) NSDictionary * infoDic;
@end

@implementation MyProfiel_ViewController
@synthesize myTableView;
@synthesize personalArr;
@synthesize infoDic;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getMyProfiel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"我的资料";
    [self initTableView];
}

#pragma mark -init

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height  - kNavigationBar_Height - 49)];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];


    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kSCREN_BOUNDS.size.width, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    UIButton *add_Button = [UIButton buttonWithTitle:@"编辑"
                                              target:self
                                            selector:@selector(editAction:)
                                               frame:CGRectMake(5, 5, kSCREN_BOUNDS.size.width - 10,39.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    
    add_Button.backgroundColor = kColor_BtnBackground;
    add_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:add_Button];
}

-(void)editAction:(UIButton *)sender
{
    MyProfielEdit_ViewController *  edit = [[MyProfielEdit_ViewController alloc] init];
    edit.customerName = [infoDic objectForKey:@"CustomerName"];
    edit.gender =[[infoDic objectForKey:@"Gender"] integerValue];
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        return 70;
    }
    return kTableView_DefaultCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5+personalArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            cell.titleLabel.frame = CGRectMake(10, 0, 130, 70);
            cell.titleLabel.text = @"头像";
            cell.valueText.text= @"";
            
            UIImageView *portraitImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
            if (!portraitImageView) {
                portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 5, 60, 60)];
                if (IOS6) {
                    [portraitImageView setFrame:CGRectMake(235, 5, 60, 60)];
                }
                portraitImageView.tag = 1000;
                portraitImageView.layer.masksToBounds = YES;
                portraitImageView.layer.cornerRadius = CGRectGetHeight(portraitImageView.bounds) / 2;
                [cell.contentView addSubview:portraitImageView];
            }
            [portraitImageView setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_HEADIMAGE"]] placeholderImage:[UIImage imageNamed:@"People-default"]];
        }
            break;
        case 1:
        {
            cell.titleLabel.text = @"姓名";
            cell.valueText.text= [infoDic objectForKey:@"CustomerName"];

        }
            break;
        case 2:
        {
            cell.titleLabel.text = @"性别";
            cell.valueText.text= [[infoDic objectForKey:@"Gender"] integerValue] == 0 ?@"女":@"男";
        }
            break;
        case 3:
        {
            cell.titleLabel.text = @"会员号";
            cell.valueText.text= [infoDic objectForKey:@"LoginMobile"];;
        }
            break;
        case 4:
        {
            cell.titleLabel.text = @"专属顾问";
            cell.valueText.text= @"";
        }
            break;
        default:
        {
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(303, (kTableView_DefaultCellHeight -12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
            cell.titleLabel.frame = CGRectMake(25, 15, 160, kLabel_DefaultHeight);
            cell.valueText.frame = CGRectMake(190, 15, 108, kLabel_DefaultHeight);
            cell.valueText.textAlignment = NSTextAlignmentRight;
            NSDictionary * dic = [personalArr objectAtIndex:indexPath.row - 5];
            
            cell.titleLabel.text = [dic objectForKey:@"BranchName"];
            cell.valueText.text= [dic objectForKey:@"ResponsiblePersonName"];
        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     if (indexPath.row > 4)
    {
        
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        NSDictionary * dic = [personalArr objectAtIndex:indexPath.row - 5];
        AccountDetailViewController * account = (AccountDetailViewController*)[sb instantiateViewControllerWithIdentifier:@"AccountDetail"];
        account.accountId = [[dic objectForKey:@"ResponsiblePersonID"] integerValue];
        [self.navigationController pushViewController:account animated:YES];
        
    }
}

#pragma mark - 接口

-(void)getMyProfiel{
    
    [SVProgressHUD showWithStatus:@"Loading..."];

    NSDictionary * para = @{@"ImageHeight":@160,@"ImageWidth":@160};
    _requestMyProfiel = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/getCustomerBasic"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
       
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message){

            infoDic = data;
            
            personalArr = [data objectForKey:@"BranchList"];
            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"HeadImageURL"] forKey:@"CUSTOMER_HEADIMAGE"];
            [myTableView reloadData];
            
        }failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        
        
    } failure:^(NSError *error) {
        
    }];
    
}

@end
