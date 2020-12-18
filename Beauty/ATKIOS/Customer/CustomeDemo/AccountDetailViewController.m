//
//  AccountDetailViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AccountDoc.h"
#import "CacheInDisk.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MessageDoc.h"
#import "GDataXMLDocument+ParseXML.h"
#import "MenuViewController.h"

@interface AccountDetailViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *accountDetailOperation;
@property (assign, nonatomic) CGSize size_Intro;
@property (assign, nonatomic) CGSize size_Expert;
@property (assign, nonatomic) CGSize size_Branch;
@property (strong, nonatomic) NSMutableArray *departArray;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) AccountDoc *account;
@property (strong, nonatomic) MessageDoc *message;

@property (strong, nonatomic) UIWebView *phoneCallWebView;

@end

@implementation AccountDetailViewController
@synthesize accountId;
@synthesize size_Intro;
@synthesize size_Expert;
@synthesize size_Branch;
@synthesize imageView;
@synthesize nameLabel;
@synthesize departArray,titleArray;
@synthesize account;
@synthesize message;
@synthesize phoneCallWebView;
- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self requestAccountDetail];
    
    titleArray = [NSMutableArray arrayWithObjects:@"电话", @"职称", @"分支机构", @"擅长", @"简介", nil];
    departArray = [NSMutableArray arrayWithObjects:@"职称", @"部门", nil];
    
    titleArray = [NSMutableArray array];
    departArray = [NSMutableArray array];

    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.showsVerticalScrollIndicator = NO;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20)];

    self.title = @"服务人员详情";

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = kColor_Clear;

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_accountDetailOperation || [_accountDetailOperation isExecuting]){
        [_accountDetailOperation cancel];
        _accountDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 5.0f;
    }else {
        return kTableView_Margin;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *titleStr = [titleArray objectAtIndex:section];
    if ([titleStr isEqualToString:@"电话"]) {
        return 1;
    } else if ([titleStr isEqualToString:@"职称"]) {
        return [departArray count];
    } else {
        return 2;
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"电话"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
        UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:102];
        UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:103];
        detailLable.textAlignment = NSTextAlignmentRight;
        detailLable.font = kNormalFont_14;
        [titleLable setText:@"电话"];
        titleLable.font = kNormalFont_14;
        titleLable.textColor = kColor_TitlePink;
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",account.acc_Phone]];
        NSRange strRange = {0,[str length]};
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [detailLable setAttributedText:str];
        detailLable.textColor = KColor_Blue;
        
    } else if ([titleStr isEqualToString:@"职称"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
        UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:102];
        UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:103];
        detailLable.textAlignment = NSTextAlignmentRight;
        detailLable.font = kNormalFont_14;
        NSString *deTitleStr = [departArray objectAtIndex:indexPath.row];
        [titleLable setText:deTitleStr];
        titleLable.font = kNormalFont_14;
        titleLable.textColor = kColor_TitlePink;
        
        if([deTitleStr isEqualToString:@"职称"]){
            [detailLable setText:account.acc_Title];
        }else{
            [detailLable setText:account.acc_Department];
        }
    } else if ([titleStr isEqualToString:@"分支机构"]) {
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            ;
            UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:104];
            [titleLable setText:@"所属门店"];
            titleLable.font = kNormalFont_14;
            titleLable.textColor = kColor_TitlePink;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:105];
            [detailLable setText:account.acc_Branch];
            detailLable.font = kFont_Light_16;
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
            detailLable.textColor = kColor_Black;
            [detailLable setFrame:CGRectMake(10.0f, 3.0f, 270.0f, size_Branch.height + 17)];
        }
    } else if ([titleStr isEqualToString:@"擅长"]) {
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:104];
            [titleLable setText:@"擅长"];
            titleLable.font = kNormalFont_14;
            titleLable.textColor = kColor_TitlePink;
        }else{
            NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
            UITableViewCell *cellDes = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,10, kSCREN_BOUNDS.size.width - 20,20)];
            label.tag = 300;
            label.numberOfLines = 0;
            label.textColor = kMainLightGrayColor;
            label.font = kNormalFont_14;
            label.textAlignment = NSTextAlignmentLeft;
            [cellDes.contentView addSubview:label];
            UILabel *deslab = [cellDes.contentView viewWithTag:300];
            CGRect tempRect = [account.acc_Expert  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            CGRect rect = deslab.frame;
            rect.size.height = tempRect.size.height + (lines * 5) ;
            deslab.frame = rect;
            if (account.acc_Expert) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:account.acc_Expert];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineSpacing  = 5;
                [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                deslab.attributedText = attributedString;
            }
            return cellDes;
        }
    }  else if ([titleStr isEqualToString:@"简介"]) {
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            ;
            UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:104];
            [titleLable setText:@"简介"];
            titleLable.font = kNormalFont_14;
            titleLable.textColor = kColor_TitlePink;
        }else{
            NSString *reuseidentifier = [NSString stringWithFormat:@"cell%@",indexPath];
            UITableViewCell *cellDes = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseidentifier];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10,-5, kSCREN_BOUNDS.size.width - 20,20)];
            label.tag = 300;
            label.numberOfLines = 0;
            label.textColor = kMainLightGrayColor;
            label.font = kNormalFont_14;
            label.textAlignment = NSTextAlignmentLeft;
            [cellDes.contentView addSubview:label];
            UILabel *deslab = [cellDes.contentView viewWithTag:300];
            CGRect tempRect = [account.acc_Introduction  boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            CGRect rect = deslab.frame;
            rect.size.height = tempRect.size.height + (lines * 5) ;
            deslab.frame = rect;
            if (account.acc_Introduction) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:account.acc_Introduction];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineSpacing  = 5;
                [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                deslab.attributedText = attributedString;
            }
            return cellDes;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"擅长"]) {
        if (indexPath.row == 0) {
            return kTableView_DefaultCellHeight;
        }else{
            CGRect tempRect = [account.acc_Expert boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            if (lines > 1) {
                return tempRect.size.height + (lines * 5) + 20;
            }else {
                return kTableView_DefaultCellHeight;
            }
        }
    }else if ([titleStr isEqualToString:@"分支机构"]) {
        if (indexPath.row == 0) {
            return kTableView_DefaultCellHeight;
        }else{
            size_Branch = [account.acc_Branch sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(272.0f, MAXFLOAT)];
            return size_Branch.height + 25;
        }
    } else if ([titleStr isEqualToString:@"简介"]) {
        if (indexPath.row == 0) {
            return kTableView_DefaultCellHeight;
        }else{
            CGRect tempRect = [account.acc_Introduction boundingRectWithSize:CGSizeMake(kSCREN_BOUNDS.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :kNormalFont_14} context:nil];
            CGFloat lines = ceil((tempRect.size.height / (kNormalFont_14.lineHeight - 5)));
            if (lines > 1) {
                return tempRect.size.height + (lines * 5)-5;
            }else {
                return kTableView_DefaultCellHeight;
            }
        }
    } else {
        return kTableView_DefaultCellHeight;
    }
}
#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"电话"]) {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:[NSString stringWithFormat:@"%@%@",@"呼叫:", account.acc_Phone] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self callThisNumber:account.acc_Phone];
    }
}


- (void)callThisNumber:(NSString*)phoneNum
{
    NSString *url = [NSString stringWithFormat:@"tel:%@", phoneNum];
    
     NSURL *phoneURL = [NSURL URLWithString:url];
    
    if (!phoneCallWebView ) {
         
         phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
     }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)SendMessage:(id)sender
{
    if(!message){
        message = [[MessageDoc alloc] init];
    }
    message.mesg_AccountName = account.acc_Name;
    message.mesg_AccountID = accountId;
    message.mesg_HeadImageURL = account.acc_HeadImgURL;
    message.mesg_Available = 1;
    message.mesg_Chat_Use = account.acc_Chat_Use;
    if(message.mesg_Chat_Use)
        [self performSegueWithIdentifier:@"goChatViewFromAccountDetailView" sender:self];
    else
    {
        [SVProgressHUD showSuccessWithStatus2:@"对方没有使用飞语权限！"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goChatViewFromAccountDetailView"]){
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.selectAccount = message;
    }
}
#pragma mark - 接口
-(void)requestAccountDetail
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSDictionary *para = @{@"AccountID":@(accountId)};
    _accountDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/account/getAccountDetail"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            
            if(account == nil)
                account = [[AccountDoc alloc] init];
            NSDictionary *dict = @{@"acc_Name":@"Name",
                                   @"acc_Department":@"Department",
                                   @"acc_Title":@"Title",
                                   @"acc_Branch":@"BranchName",
                                   @"acc_Introduction":@"Introduction",
                                   @"acc_Expert":@"Expert",
                                   @"acc_Phone":@"Mobile",
                                   @"acc_HeadImgURL":@"HeadImageURL",
                                   @"acc_Chat_Use":@"Chat_Use"};
            [account assignObjectPropertyWithDictionary:data andObjectPropertyAssociatedDictionary:dict];
            [account setAcc_ID:accountId];
            
            if(account.acc_Phone.length != 0){
                [titleArray addObject:@"电话"];
            }
            
            if(account.acc_Department.length != 0 || account.acc_Title.length != 0){
                [titleArray addObject:@"职称"];
                if(account.acc_Title.length != 0){
                    [departArray addObject:@"职称"];
                }
                if(account.acc_Department.length != 0){
                    [departArray addObject:@"部门"];
                }
            }
            
            if(account.acc_Branch.length != 0){
                [titleArray addObject:@"分支机构"];
            }
            
            if(account.acc_Expert.length != 0){
                [titleArray addObject:@"擅长"];
            }
            
            if(account.acc_Introduction.length != 0){
                [titleArray addObject:@"简介"];
            }
            
            [imageView setImageWithURL:[NSURL URLWithString:account.acc_HeadImgURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
            [nameLabel setText:account.acc_Name];
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


@end
