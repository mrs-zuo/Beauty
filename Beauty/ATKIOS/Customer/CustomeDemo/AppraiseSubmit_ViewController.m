//
//  AppraiseSubmit_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/29.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "AppraiseSubmit_ViewController.h"
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
#import "CWStarRateView.h"

@interface AppraiseSubmit_ViewController ()<UITableViewDelegate,UITableViewDataSource,ContentEditCellDelegate,CWStarRateViewDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestGetReviewInfoOperationForTG;
@property (weak, nonatomic)AFHTTPRequestOperation *requestEditDetail;
@property (strong, nonatomic) ReviewDoc *reviewDoc;
@property (strong, nonatomic) NSMutableArray * treatmentReviewArr;
@property (strong, nonatomic)  UITableView *myTableView;
@property (assign, nonatomic) CGFloat table_Height;
@property (assign, nonatomic) CGRect previousCaretRect;

@end

@implementation AppraiseSubmit_ViewController

@synthesize reviewDoc;
@synthesize treatmentReviewArr;
@synthesize myTableView;

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }

    self.title = @"服务评价";
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -kNavigationBar_Height-5)style:UITableViewStyleGrouped];

    
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor =kDefaultBackgroundColor;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    
    if ((IOS7 || IOS8)) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"提交评价"
                                              target:self
                                            selector:@selector(confirm)
                                               frame:CGRectMake(5.0f, 5.0f, kSCREN_BOUNDS.size.width-10, 39.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    [footView addSubview:add_Button];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    add_Button.titleLabel.font=kNormalFont_14;
    _table_Height = myTableView.frame.size.height +49;
    //点击收起键盘
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:tap];
}
- (void)tapClick
{
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [self requestReviewInfoForTG];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetReviewInfoOperationForTG && [_requestGetReviewInfoOperationForTG isExecuting]) {
        [_requestGetReviewInfoOperationForTG cancel];
    }
    _requestGetReviewInfoOperationForTG = nil;
    
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)confirm
{
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismiss:) name:SVProgressHUDDidDisappearNotification object:nil];
    
    if (reviewDoc.review_Comment == nil) {
        reviewDoc.review_Comment = @"";
    }
    if (reviewDoc.review_StarCnt == 0) {
        reviewDoc.review_StarCnt = 5;
    }
    if (reviewDoc.review_Comment.length >300) {
        [reviewDoc.review_Comment substringToIndex:300];
    }
    NSMutableArray *listTMArray = [NSMutableArray new];
    for (ReviewDoc * ReviewTreatmentDoc in treatmentReviewArr)
    {
        if (ReviewTreatmentDoc.review_Comment == nil) {
            ReviewTreatmentDoc.review_Comment = @"";
        }
        if (ReviewTreatmentDoc.review_StarCnt ==0) {
            ReviewTreatmentDoc.review_StarCnt = 5;
        }
        NSDictionary *dict = @{@"TreatmentID":@((long)ReviewTreatmentDoc.TreatmentID),@"Satisfaction":@((long)ReviewTreatmentDoc.review_StarCnt),
                               @"Comment":ReviewTreatmentDoc.review_Comment};
        [listTMArray addObject:dict];
    }
    
    
    
    NSDictionary *para = @{@"mTGReview":@{@"GroupNo":@((long long)_orderDoc.groupNo),@"Satisfaction":@((long)reviewDoc.review_StarCnt),@"Comment":reviewDoc.review_Comment},@"listTMReview":listTMArray};
    
    _requestEditDetail = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Review/EditReview" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD showSuccessWithStatus2:@"评价成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error];
        }];
        
    } failure:^(NSError *error) {
        
    }];
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
            cell.valueText.text = [NSString stringWithFormat:@"服务%ld次/%@",(long)reviewDoc.TGFinishedCount,str];
            
        }else if (indexPath.row == 2) {
            static NSString *cellIdentity = @"CommentCell_Star";
            UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:cellIdentity];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.selectedBackgroundView = nil;
                CWStarRateView * starRateView = (CWStarRateView *)[cell.contentView viewWithTag:2001];
                if (!starRateView) {
                    starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(5.0f, 10.0f, 300.0f, 40.0f) numberOfStars:5];
                    starRateView.scorePercent = [self countToCore:reviewDoc.review_StarCnt];
                    starRateView.allowIncompleteStar = NO;
                    starRateView.hasAnimation = NO;
                    starRateView.delegate = self;
                    starRateView.tag = 2001 ;
                    [cell.contentView addSubview:starRateView];
                }
            }
            //cell.layer.borderColor = [kTableView_LineColor CGColor];
            //cell.layer.borderWidth = 1.0f;
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
            contentCell.delegate = self;
            contentCell.contentEditText.placeholder = @"请输入评论";
            
            return contentCell;
            
        }
    }else
    {
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
        if (indexPath.row%2 == 0) {
            cell.titleLabel.frame = CGRectMake(10, 15, 150, 18);
            cell.titleLabel.text = ReviewTreatmentDoc.ServiceName;
            cell.titleLabel.textColor=kColor_Editable;
            cell.valueText.text = @"";
            
            CWStarRateView * starRateView = (CWStarRateView *)[cell.contentView viewWithTag:1000+indexPath.row];
            if (!starRateView) {
                CWStarRateView * starRateView = [[CWStarRateView alloc]initWithFrame:CGRectMake(205.0f, 15.0f, 100.0f, 18.0f) numberOfStars:5];
                starRateView.scorePercent = [self countToCore:ReviewTreatmentDoc.review_StarCnt];;
                starRateView.allowIncompleteStar = NO;
                starRateView.hasAnimation = NO;
                starRateView.delegate = self;
                starRateView.tag = 1000+indexPath.row ;
                [cell.contentView addSubview:starRateView];
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
            contentCell.delegate = self;
            contentCell.contentEditText.placeholder = @"请输入评论";
          
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
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width,kTableView_DefaultCellHeight)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(10,0,kSCREN_BOUNDS.size.width,kTableView_DefaultCellHeight)];
    lable.text = @"操作评价";
    lable.font = kNormalFont_14;
    lable.tag = 1;
    if (section ==1) {
        
        [view addSubview:lable];
    }
    
    return view;
}

#pragma delegate

-(void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent
{
    if (starRateView.tag == 2001) {
        
        reviewDoc.review_StarCnt = starRateView.scorePercent * 5;
        
    }else{
        NSInteger row = starRateView.tag -1000;
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:row/2];
        ReviewTreatmentDoc.review_StarCnt = starRateView.scorePercent * 5;
    }
}

-(float)countToCore:(int)count
{
    float core ;
    NSString * str = [NSString stringWithFormat:@"0.%d",count % 5];
    core = [str floatValue] * 2;
    if(core == 0)
    {
        core = 1;
    }
    return core;
}

#pragma mark - 接口

- (void)requestReviewInfoForTG;
{
    NSString *para = [NSString stringWithFormat:@"{\"GroupNo\":%lld}", (long long)_orderDoc.groupNo];
    
    _requestGetReviewInfoOperationForTG = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Review/GetReviewDetail" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            reviewDoc = [[ReviewDoc alloc] init];
            
            reviewDoc.TGFinishedCount = [[data objectForKey:@"TGFinishedCount"] integerValue];
            reviewDoc.TGTotalCount = [[data objectForKey:@"TGTotalCount"] integerValue];
            reviewDoc.ServiceName = [data objectForKey:@"ServiceName"];
            reviewDoc.TGEndTime = [data objectForKey:@"TGEndTime"];
            
            treatmentReviewArr = [[NSMutableArray alloc] init];
            
            for (NSDictionary * dic in [data objectForKey:@"listTM"]) {
                ReviewDoc * doc = [[ReviewDoc alloc] init];
                doc.ServiceName = [dic objectForKey:@"SubServiceName"];
                doc.TreatmentID = [[dic objectForKey:@"TreatmentID"] integerValue];
                [treatmentReviewArr addObject:doc];
            }
            
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
    }];
}



#pragma mark 备注编辑

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    if (contentText.tag == 101) {
        reviewDoc.review_Comment = contentText.text;
    }else {
        NSIndexPath *indexPath =  [myTableView indexPathForCell:cell];
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:indexPath.row/2];
        ReviewTreatmentDoc.review_Comment = contentText.text;
    }
    contentText.returnKeyType = UIReturnKeyDefault;
    
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:textView];
    CGRect rect = textView.frame;
    rect.size.width = 300;
    textView.frame = rect;
}

-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length >= 300) {
                textView.text = [toBeString substringToIndex:300];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 300) {
            textView.text = [toBeString substringToIndex:300];
        }
    }
}

- (BOOL)contentEditCell:(RemarkEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    return YES;
}

- (BOOL)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)contentEditCell:(RemarkEditCell *)cell textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextViewTextDidChangeNotification" object:textView];

    NSInteger row = textView.tag - 1000;

     if (textView.tag == 101){
         
        reviewDoc.review_Comment = textView.text;
         
     }else {
         ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:row/2];
         ReviewTreatmentDoc.review_Comment = textView.text;
     }
    
}

- (void)contentEditCell:(RemarkEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
}

// 随着textView 滑动光标
- (void)scrollToCursorForTextView:(UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (_previousCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 20;
        _previousCaretRect = newCursorRect;
        [myTableView scrollRectToVisible:newCursorRect animated:YES];
    }
    
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(300.0f, 500.0f)];
    if (textViewSize.height < kTableView_HeightOfRow) {
        textViewSize.height = kTableView_HeightOfRow;
    }
    if (textViewSize.width < 300) {
        textViewSize.width = 300;
    }
    CGRect rect = textView.frame;
    rect.size = textViewSize;
    textView.frame = rect;
    
    NSInteger row = textView.tag - 1000;
    if (textView.tag == 101) {
        reviewDoc.review_Comment = textView.text;
    }else {
        ReviewDoc * ReviewTreatmentDoc = [treatmentReviewArr objectAtIndex:row/2];
        ReviewTreatmentDoc.review_Comment = textView.text;
    }
    
    [myTableView beginUpdates];
    [myTableView endUpdates];
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}

#pragma mark 点击收回键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = myTableView.frame;
    tvFrame.size.height = _table_Height - initialFrame.size.height + 5.0f;
    myTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    myTableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -49-44);

}


@end
