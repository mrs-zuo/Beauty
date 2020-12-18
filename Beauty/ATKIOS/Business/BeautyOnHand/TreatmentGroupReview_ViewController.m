//
//  TreatmentGroupReview_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/22.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TreatmentGroupReview_ViewController.h"
#import "ReviewDoc.h"
#import "NavigationView.h"
#import "DEFINE.h"

#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"

#import "UILabel+InitLabel.h"
#import "UIPlaceHolderTextView+InitTextView.h"
#import "GPBHTTPClient.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "OrderDoc.h"

@interface TreatmentGroupReview_ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReviewInfoOperationForTG;
@property (strong, nonatomic) ReviewDoc *reviewDoc;
@property (strong, nonatomic) NSMutableArray * treatmentReviewArr;

@end

@implementation TreatmentGroupReview_ViewController
@synthesize reviewDoc;
@synthesize treatmentReviewArr;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor_Background_View;
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"服务评价"];
    [self.view addSubview:navigationView];
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - (navigationView.frame.size.height) - 5.0f-49);
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.backgroundView = nil;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.autoresizesSubviews = UIViewAutoresizingNone;
    [self.view addSubview:_tableView];
    if ((IOS7 || IOS8)) {
        _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49);
        _tableView.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
}


- (void)viewWillAppear:(BOOL)animated
{
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
    if(treatmentReviewArr.count ==0)
        return 1;
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
            cell.valueText.text = [NSString stringWithFormat:@"服务%ld次/%@",(long)reviewDoc.TGFinishedCount,str];
            
        }else if (indexPath.row == 2) {
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
                    int pix_x = i * 60.0f + 15.0f;
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pix_x, 5.0f, 40.0f, 40.0f)];
                    imageView.tag = 100 + i;
                    [cell.contentView addSubview:imageView];
                }
                
                if ( i < reviewDoc.review_StarCnt) {
                    imageView.image = [UIImage imageNamed:@"icon_ lightStar"];
                } else {
                    imageView.image = [UIImage imageNamed:@"icon_grayStar"];
                }
                
            }
//            UIView * kuangView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 300, 48)];
//            kuangView.backgroundColor = [UIColor clearColor];
//            kuangView.layer.borderWidth = 0.5;
//            kuangView.layer.borderColor = [kColor_LightBlue CGColor];
//            [cell.contentView addSubview:kuangView];
            cell.layer.borderColor = [kTableView_LineColor CGColor];
            cell.layer.borderWidth = 1.0f;
            return cell;
        } else if(indexPath.row == 3) {
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (contentCell == nil) {
                contentCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            contentCell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [contentCell setContentText:reviewDoc.review_Comment];
            contentCell.backgroundColor = [UIColor whiteColor];
            [contentCell.contentEditText setTag:101];
            contentCell.contentEditText.editable = NO ;
            [contentCell.contentEditText setFrame:CGRectMake(0.0f, 2.0f, 310.0f, CONTENT_EDIT_CELL_HEIGHT)];
            
//            NSInteger height = [reviewDoc.review_Comment sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(310, CONTENT_EDIT_CELL_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping].height + 22;

//            UIView * kuangView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 300, height < 50 ? 50 : height)];
//            kuangView.backgroundColor = [UIColor clearColor];
//            kuangView.layer.borderWidth = 0.5;
//            kuangView.layer.borderColor = [kColor_LightBlue CGColor];
//            [contentCell.contentView addSubview:kuangView];
            contentCell.layer.borderColor = [kTableView_LineColor CGColor];
            contentCell.layer.borderWidth = 1.0f;
            return contentCell;
            
        }
    }else
    {
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
        if (indexPath.row%2 == 0) {
            
            cell.titleLabel.frame = CGRectMake(10, 0, 150, kTableView_HeightOfRow);
            cell.titleLabel.text = ReviewTreatmentDoc.ServiceName;
            cell.valueText.text = @"";
            
            for (int i = 0; i < 5; i++) {
                UIImageView *imageView = nil;
                if ([[cell.contentView viewWithTag:200 + i] isKindOfClass:[UIImageView class]] ) {
                    imageView = (UIImageView *)[cell.contentView viewWithTag:200+i];
                } else {
                    int pix_x = i * 20.0f + 200.0f;
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pix_x, 16.0f, 18.0f, 18.0f)];
                    imageView.tag = 200 + i;
                    imageView.backgroundColor = [UIColor whiteColor];
                    [cell.contentView addSubview:imageView];
                }
                
                if ( i < ReviewTreatmentDoc.review_StarCnt) {
                    imageView.image = [UIImage imageNamed:@"icon_ lightStar"];
                } else {
                    imageView.image = [UIImage imageNamed:@"icon_grayStar"];
                }
            }
            
            return cell;
            
        }else
        {
            
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *contentCell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (contentCell == nil) {
                contentCell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                contentCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            contentCell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [contentCell setContentText:ReviewTreatmentDoc.review_Comment];
            contentCell.backgroundColor = [UIColor whiteColor];
            [contentCell.contentEditText setTag:indexPath.row + 1000];
            contentCell.contentEditText.editable = NO ;
//            [contentCell.contentEditText setFrame:CGRectMake(10.0f, 2.0f, 280.0f, CONTENT_EDIT_CELL_HEIGHT)];
            contentCell.layer.borderColor = [kTableView_LineColor CGColor];
            contentCell.layer.borderWidth = 1.0f;
            
//            NSInteger height = [reviewDoc.review_Comment sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(280, CONTENT_EDIT_CELL_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            
//            UIView * kuangView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 285, height < kTableView_HeightOfRow ? kTableView_HeightOfRow : height)];
//            kuangView.backgroundColor = [UIColor clearColor];
//            kuangView.layer.borderWidth = 0.5;
//            kuangView.layer.borderColor = [kColor_LightBlue CGColor];
//            [contentCell.contentView addSubview:kuangView];
            
            return contentCell;
        }
    
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0  ) {
        if (indexPath.row ==2) {
            return 50;
        }
        if (indexPath.row ==3) {
            if (reviewDoc.review_Comment.length > 0) {
                NSInteger height = [reviewDoc.review_Comment sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(310, CONTENT_EDIT_CELL_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                return height < 50 ? 50 : height;
            }else
            {
                return 50;
            }
        }else if(indexPath.row == 2)
        {
            
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row%2 == 1) {
            ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
            if (ReviewTreatmentDoc.review_Comment.length > 0) {
                NSInteger height = [ReviewTreatmentDoc.review_Comment sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(280, CONTENT_EDIT_CELL_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                return height < kTableView_HeightOfRow ? kTableView_HeightOfRow : height;
            }
        }
    }
   
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==1) {
        return 30;
    }
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300, 30)];
    lable.text = @"操作评价";
    lable.font = kFont_Light_16;
    lable.tag = 1;
    if (section ==1) {
        
        [view addSubview:lable];
    }

    return view;
}

#pragma mark - 接口

- (void)requestReviewInfoForTG;
{
    NSString *par = [NSString stringWithFormat:@"{\"GroupNo\":%f}", (self.GroupNo)];
    
    _requestGetReviewInfoOperationForTG = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
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
                    doc.review_StarCnt = [[dic objectForKey:@"Satisfaction"] integerValue];
                doc.review_Comment = [dic objectForKey:@"Comment"];
                doc.ServiceName =  [dic objectForKey:@"SubServiceName"];
                [treatmentReviewArr addObject:doc];
            }

            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
}


@end
