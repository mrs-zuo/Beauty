//
//  TreatmentGroupReview_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/22.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TreatmentGroupReview_ViewController.h"
#import "ReviewDoc.h"
#import "DEFINE.h"

#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"

#import "UILabel+InitLabel.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "NormalEditCell.h"
#import "RemarkEditCell.h"
#import "OrderDoc.h"

@interface TreatmentGroupReview_ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReviewInfoOperationForTG;
@property (strong, nonatomic) ReviewDoc *reviewDoc;
@property (strong, nonatomic) NSMutableArray * treatmentReviewArr;

@end

@implementation TreatmentGroupReview_ViewController
@synthesize reviewDoc;
@synthesize treatmentReviewArr;
@synthesize myTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.tabBarController.title = @"服务评价";
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -kNavigationBar_Height + 20 - 49)style:UITableViewStyleGrouped];

     myTableView.showsHorizontalScrollIndicator = NO;
     myTableView.showsVerticalScrollIndicator = NO;
     myTableView.backgroundColor =kDefaultBackgroundColor;
     myTableView.separatorColor = kTableView_LineColor;
     myTableView.autoresizingMask = UIViewAutoresizingNone;
     myTableView.delegate = self;
     myTableView.dataSource = self;
     //myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
     UIView * view = [[UIView alloc] init];
     view.backgroundColor = [UIColor clearColor];
     [myTableView setTableFooterView:view];
     [self.view addSubview:myTableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.isShow_tab_nav_tab_vcButton = YES;
    [super viewWillAppear:animated];
    [self requestReviewInfoForTG];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    if (treatmentReviewArr.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return treatmentReviewArr.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [NSString stringWithFormat:@"cell%@",indexPath];
    NormalEditCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.valueText.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.valueText.textColor = [UIColor blackColor];
    
    if (indexPath.section ==0) {
        if (indexPath.row ==0) {
           
            cell.titleLabel.text = reviewDoc.ServiceName;
            cell.valueText.text = @"";
        }else if(indexPath.row ==1)
        {
            NSString * str = @"";
            if (reviewDoc.TGTotalCount ==0) {
                str = @"不限次";
            }else
            {
                str = [NSString stringWithFormat:@"共%ld次",(long)reviewDoc.TGTotalCount];
            }
            
            cell.titleLabel.text = reviewDoc.TGEndTime;
            cell.valueText.text = [NSString stringWithFormat:@"服务%ld/%@",(long)reviewDoc.TGFinishedCount,str];
            
        }else if (indexPath.row == 2) {
            NSString *cellIdentity = @"CommentCell_Star";
            UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:cellIdentity];
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
                    int pix_x = i * 60.0f + 15.0f;
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pix_x,8.0f, 40.0f, 40.0f)];
                    imageView.tag = 100 + i;
                    [cell.contentView addSubview:imageView];
                }
                
                if ( i < reviewDoc.review_StarCnt) {
                    imageView.image = [UIImage imageNamed:@"order_CommentStar_1"];
                } else {
                    imageView.image = [UIImage imageNamed:@"order_CommentStar_0"];
                }
            }
            return cell;
        } else if(indexPath.row == 3) {
            static NSString *cellIndentify = @"contactContentCell";
            RemarkEditCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (contentCell == nil) {
                contentCell = [[RemarkEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            contentCell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [contentCell setContentText:reviewDoc.review_Comment];
            contentCell.backgroundColor = [UIColor whiteColor];
            [contentCell.contentEditText setTag:101];
            contentCell.contentEditText.editable = NO ;
            [contentCell.contentEditText setFrame:CGRectMake(10.0f, 5.0f, 310.0f, 400)];
            return contentCell;
            
        }
    }else
    {
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
        if (indexPath.row%2 == 0) {
            
            cell.titleLabel.frame = CGRectMake(10, 5, 150, kTableView_HeightOfRow);
            cell.titleLabel.text = ReviewTreatmentDoc.ServiceName;
            cell.titleLabel.textColor=kColor_Editable;
            cell.valueText.text = @"";
            
            for (int i = 0; i < 5; i++) {
                UIImageView *imageView = nil;
                if ([[cell.contentView viewWithTag:200 + i] isKindOfClass:[UIImageView class]] ) {
                    imageView = (UIImageView *)[cell.contentView viewWithTag:200+i];
                } else {
                    int pix_x = i * 22.0f + 200.0f;
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pix_x, 16.0f, 18.0f, 18.0f)];
                    imageView.tag = 200 + i;
                    imageView.backgroundColor = [UIColor whiteColor];
                    [cell.contentView addSubview:imageView];
                }
                
                if ( i < ReviewTreatmentDoc.review_StarCnt) {
                    
                    imageView.image = [UIImage imageNamed:@"order_CommentStar_1"];
                } else {
                    imageView.image = [UIImage imageNamed:@"order_CommentStar_0"];
                }
            }
            
            return cell;
            
        }else
        {
            
            static NSString *cellIndentify = @"contactContentCell";
            RemarkEditCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (contentCell == nil) {
                contentCell = [[RemarkEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            contentCell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [contentCell setContentText:ReviewTreatmentDoc.review_Comment];
            contentCell.backgroundColor = [UIColor whiteColor];
            [contentCell.contentEditText setTag:indexPath.row + 1000];
            contentCell.contentEditText.editable = NO ;
            [contentCell.contentEditText setFrame:CGRectMake(5.0f,4.0f,310.f,180.0f)];
            return contentCell;
        }
    
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0  ) {
        if (indexPath.row ==2) {
            return 60;
        }
        if (indexPath.row ==3) {
            if (reviewDoc.review_Comment.length > 0) {
                NSInteger height = [reviewDoc.review_Comment sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(310, 400) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                return height < 60 ? 60 : height;
            }else
            {
                return 60;
            }
        }else if(indexPath.row == 2)
        {
            return 60;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row%2 == 1) {
            ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
            if (ReviewTreatmentDoc.review_Comment.length > 0) {
                NSInteger height = [ReviewTreatmentDoc.review_Comment sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(280, CONTENT_EDIT_CELL_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping].height + 38;
                return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
            }
        }
    }
   
    return kTableView_DefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==1) {
        return kTableView_DefaultCellHeight;
    }
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    lable.text = @"操作评价";
    lable.font = kNormalFont_14;
    lable.tag = 1;
    if (section ==1) {
        
        [view addSubview:lable];
    }

    return view;
}

#pragma mark - 接口

- (void)requestReviewInfoForTG;
{
    NSString *para = [NSString stringWithFormat:@"{\"GroupNo\":%lld}", (long long)self.GroupNo];

    _requestGetReviewInfoOperationForTG = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetailForTG" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            reviewDoc = [[ReviewDoc alloc] init];
            
            reviewDoc.review_StarCnt = [[data objectForKey:@"Satisfaction"] integerValue];
            reviewDoc.review_Comment = [data objectForKey:@"Comment"];
            reviewDoc.TGFinishedCount = [[data objectForKey:@"TGFinishedCount"] integerValue];
            reviewDoc.TGTotalCount = [[data objectForKey:@"TGTotalCount"] integerValue];
            reviewDoc.ServiceName = [data objectForKey:@"ServiceName"];
            reviewDoc.TGEndTime = [data objectForKey:@"TGEndTime"];
            
            treatmentReviewArr = [[NSMutableArray alloc] init];
            
            for (NSDictionary * dic in [data objectForKey:@"listTM"]) {
         
                ReviewDoc * doc = [[ReviewDoc alloc] init];
                doc.review_StarCnt =  [[dic objectForKey:@"Satisfaction"] integerValue];
                doc.review_Comment = [dic objectForKey:@"Comment"];
                doc.ServiceName = [dic objectForKey:@"SubServiceName"];
                [treatmentReviewArr addObject:doc];
            }
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
}


@end
