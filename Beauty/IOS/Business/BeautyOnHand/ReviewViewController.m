//
//  CommentViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-14.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReviewViewController.h"
#import "ReviewDoc.h"
#import "NavigationView.h"
#import "DEFINE.h"

#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"

#import "UILabel+InitLabel.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "GPBHTTPClient.h"   

@interface ReviewViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReviewInfoOperationForTM;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReviewInfoOperationForTG;
@property (strong, nonatomic) ReviewDoc *reviewDoc;
@property (strong ,nonatomic)NavigationView *navigationView;
@property (nonatomic , assign) NSString * titleStr;
@end

@implementation ReviewViewController
@synthesize treatmentID;
@synthesize reviewDoc;
@synthesize navigationView;
@synthesize titleStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor_Background_View;
    
    navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"操作评价"];
    [self.view addSubview:navigationView];

    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizesSubviews = UIViewAutoresizingNone;
    
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
}

-(void)initData
{
    if (self.treatMentOrGroup) {
        titleStr = @"操作";
        [self requestReviewInfoForTM];
    }
    navigationView.titleLabel.text = [NSString stringWithFormat:@"%@评价",titleStr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetReviewInfoOperationForTM && [_requestGetReviewInfoOperationForTM isExecuting]) {
        [_requestGetReviewInfoOperationForTM cancel];
    }
    _requestGetReviewInfoOperationForTM = nil;
    
    if (_requestGetReviewInfoOperationForTG && [_requestGetReviewInfoOperationForTG isExecuting]) {
        [_requestGetReviewInfoOperationForTG cancel];
    }
    _requestGetReviewInfoOperationForTG = nil;
    
    if ([SVProgressHUD isVisible])
        [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *cellIdentity = @"CommentCell_Star";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectedBackgroundView = nil;
        }
        for (int i = 0; i < 5; i++) {
            UIImageView *imageView = nil;
            if ([[cell.contentView viewWithTag:100 + i] isKindOfClass:[UIImageView class]] ) {
                imageView = (UIImageView *)[cell.contentView viewWithTag:100+i];
            } else {
                int pix_x = i * 60.0f + 5.0f;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pix_x, 10.0f, 60.0f, 60.0f)];
                imageView.tag = 100 + i;
                [cell.contentView addSubview:imageView];
            }
            
            if ( i < reviewDoc.review_StarCnt) {
                imageView.image = [UIImage imageNamed:@"icon_ lightStar"];
            } else {
                imageView.image = [UIImage imageNamed:@"icon_grayStar"];
            }
        }
        return cell;
    } else {
        NSString *cellIdentity = @"CommentCell_Context";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectedBackgroundView = nil;
        }
        
        UIPlaceHolderTextView *contentTxtView = nil;
        if ([[cell.contentView viewWithTag:1000] isKindOfClass:[UIPlaceHolderTextView class]]) {
            contentTxtView = (UIPlaceHolderTextView *)[cell.contentView viewWithTag:1000];
        } else {
            contentTxtView = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(5.0f, 5.0f, 300.0f, 210.0f)
                                                                           text:reviewDoc.review_Comment
                                                                    placeHolder:@"该顾客暂时没有评价"];
            contentTxtView.tag = 1000;
            contentTxtView.userInteractionEnabled = NO;
            [cell.contentView addSubview:contentTxtView];
        }
        contentTxtView.text = reviewDoc.review_Comment;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80.0f;
    } else {
        return 220.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 接口

- (void)requestReviewInfoForTM;
{
    NSString *par = [NSString stringWithFormat:@"{\"TreatmentID\":%ld}", (long)treatmentID];
    
    _requestGetReviewInfoOperationForTM = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetailForTM" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            reviewDoc = [[ReviewDoc alloc] init];
            reviewDoc.review_ID = [[data objectForKey:@"ReviewID"] integerValue];
            reviewDoc.review_StarCnt = [[data objectForKey:@"Satisfaction"] integerValue];
            reviewDoc.review_Comment = [data objectForKey:@"Comment"];
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
}


@end
