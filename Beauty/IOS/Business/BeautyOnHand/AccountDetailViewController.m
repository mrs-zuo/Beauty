//
//  AccountDetailViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-5.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AccountInfo.h"
#import "CacheInDisk.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MessageDoc.h"
#import "GDataXMLNode.h"
#import "TitleView.h"
#import "GPBHTTPClient.h"

@interface AccountDetailViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *accountDetailOperation;
@property (assign, nonatomic) CGSize size_Intro;
@property (assign, nonatomic) CGSize size_Expert;
@property (assign, nonatomic) CGSize size_Branch;
@property (strong, nonatomic) NSMutableArray *departArray;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) AccountInfo *account;
@property (strong, nonatomic) MessageDoc *message;

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

- (void)viewWillAppear:(BOOL)animated
{
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
    self.view.backgroundColor = kColor_Background_View;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.showsVerticalScrollIndicator = NO;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [_tableView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 47.0f)];
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, 41.f, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 3.f);
    }
    
    TitleView *titleView = [[TitleView alloc] init];
    [self.view addSubview:[titleView getTitleView:@"服务人员详情"]];
    
    
    UIImageView *headImageView = (UIImageView*)[_tableView viewWithTag:100];
    headImageView.layer.shadowOffset = CGSizeZero;
    headImageView.layer.shadowOpacity = .8f;
    headImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:headImageView.layer.bounds] CGPath];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];

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
        
        titleLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow);

        detailLable.textAlignment = NSTextAlignmentRight;
        detailLable.font = kFont_Light_16;
        [titleLable setText:@"电话"];
        titleLable.font = kFont_Light_16;
        titleLable.textColor = kColor_DarkBlue;
        [detailLable setText:account.acc_Phone];
        
    } else if ([titleStr isEqualToString:@"职称"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
        UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:102];
        titleLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow);
        UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:103];

        detailLable.textAlignment = NSTextAlignmentRight;
        detailLable.font = kFont_Light_16;
        NSString *deTitleStr = [departArray objectAtIndex:indexPath.row];
        [titleLable setText:deTitleStr];
        titleLable.font = kFont_Light_16;
        titleLable.textColor = kColor_DarkBlue;
        
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
            titleLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow);
            [titleLable setText:@"所属门店"];
            titleLable.font = kFont_Light_16;
            titleLable.textColor = kColor_DarkBlue;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:105];
            [detailLable setText:account.acc_Branch];
            detailLable.font = kFont_Light_16;
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;

            
        }
    } else if ([titleStr isEqualToString:@"擅长"]) {
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:104];
            titleLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow);
            [titleLable setText:@"擅长"];
            titleLable.font = kFont_Light_16;
            titleLable.textColor = kColor_DarkBlue;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:105];
            size_Expert = [account.acc_Expert sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 155.0f)];
            detailLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, size_Expert.height + 25);
            [detailLable setText:account.acc_Expert];
            detailLable.font = kFont_Light_16;
            detailLable.numberOfLines = 0;
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
//            [detailLable setFrame:CGRectMake(5.0f, 3.0f, 270.0f, size_Expert.height + 17)];
            
        }
    }  else if ([titleStr isEqualToString:@"简介"]) {
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            ;
            UILabel *titleLable =(UILabel *)[cell.contentView viewWithTag:104];
            titleLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, kTableView_HeightOfRow);
            [titleLable setText:@"简介"];
            titleLable.font = kFont_Light_16;
            titleLable.textColor = kColor_DarkBlue;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            ;
            UILabel *detailLable =(UILabel *)[cell.contentView viewWithTag:105];
             size_Intro = [account.acc_Introduction sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, MAXFLOAT)];
            detailLable.frame = CGRectMake(5, 0, kSCREN_BOUNDS.size.width - 10, size_Intro.height + 25);
            [detailLable setText:account.acc_Introduction];
            detailLable.font = kFont_Light_16;
            detailLable.lineBreakMode = NSLineBreakByWordWrapping;
            detailLable.numberOfLines = 0;
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
            return 38;
        }else{
            size_Expert = [account.acc_Expert sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 155.0f)];
            return size_Expert.height + 25;
        }
    }else if ([titleStr isEqualToString:@"分支机构"]) {
        if (indexPath.row == 0) {
            return 38;
        }else{
            size_Branch = [account.acc_Branch sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 155.0f)];
            return size_Branch.height + 25;
        }
    } else if ([titleStr isEqualToString:@"简介"]) {
        if (indexPath.row == 0) {
            return 38;
        }else{
            size_Intro = [account.acc_Introduction sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, MAXFLOAT)];
            return size_Intro.height + 25;
        }
    } else {
        return 38;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = [titleArray objectAtIndex:indexPath.section];
    if ([titleStr isEqualToString:@"电话"]) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"呼叫:" destructiveButtonTitle:[NSString stringWithFormat:@"%@%@",@"呼叫:", account.acc_Phone] otherButtonTitles: nil];
     //  [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self callThisNumber:account.acc_Phone];
    }
}

- (void)callThisNumber:(NSString*)phoneNum
{
    NSString *url = [NSString stringWithFormat:@"tel:%@", phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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
//    message.mesg_ToUserName = account.acc_Name;
//    message.account_ID = accountId;
//    message.mesg_HeadImgURL = account.acc_HeadImgURL;
//    message.account_Available = 1;
    [self performSegueWithIdentifier:@"goChatViewFromAccountDetailView" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goChatViewFromAccountDetailView"]){
        ChatViewController *chatViewController = segue.destinationViewController;
        chatViewController.users_Selected = [[NSMutableArray alloc] initWithObjects:message,nil];
    }
}

-(void)requestAccountDetail
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    NSString *par = [NSString stringWithFormat:@"{\"AccountId\":%ld}", (long)accountId];

    _accountDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/getAccountDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];

        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(account == nil) {
                account = [[AccountInfo alloc] init];
            }
            [account setAcc_Name:[data objectForKey:@"Name"]];
            [account setAcc_Department:[data objectForKey:@"Department"] ];
            [account setAcc_Title:[data objectForKey:@"Title"]];
            [account setAcc_Branch:[data objectForKey:@"BranchName"]];
            [account setAcc_Introduction:[data objectForKey:@"Introduction"]];
            [account setAcc_Expert:[data objectForKey:@"Expert"]];
            [account setAcc_Phone:[data objectForKey:@"Mobile"]];
            [account setAcc_HeadImgURL:[data objectForKey:@"HeadImageURL"]];
            [account setAcc_Chat_Use:[[data objectForKey:@"HeadImageURL"] integerValue]];
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
            nameLabel.frame = CGRectMake(140, 40, 165, 20);
            nameLabel.textAlignment = NSTextAlignmentRight;

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    /*
    _accountDetailOperation = [[GPHTTPClient shareClient] requestAccountDetailWithAccountId:accountId success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData ,NSString *reslutMsg) {
            [SVProgressHUD dismiss];
            if(account == nil) {
                account = [[AccountInfo alloc] init];
            }
            [account setAcc_Name:[[[contentData elementsForName:@"Name"] objectAtIndex:0] stringValue]];
            [account setAcc_Department:[[[contentData elementsForName:@"Department"] objectAtIndex:0]stringValue]];
            [account setAcc_Title:[[[contentData elementsForName:@"Title"] objectAtIndex:0] stringValue]];
            [account setAcc_Branch:[[[contentData elementsForName:@"BranchName"] objectAtIndex:0] stringValue]];
            [account setAcc_Introduction:[[[contentData elementsForName:@"Introduction"] objectAtIndex:0] stringValue]];
            [account setAcc_Expert:[[[contentData elementsForName:@"Expert"] objectAtIndex:0] stringValue]];
            [account setAcc_Phone:[[[contentData elementsForName:@"Mobile"] objectAtIndex:0] stringValue]];
            [account setAcc_HeadImgURL:[[[contentData elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue]];
            [account setAcc_Chat_Use:[[[[contentData elementsForName:@"HeadImageURL"] objectAtIndex:0] stringValue] integerValue]];
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
        } failure:^{
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ address:%s",error.description,__FUNCTION__);
    }];
     */
}


@end
