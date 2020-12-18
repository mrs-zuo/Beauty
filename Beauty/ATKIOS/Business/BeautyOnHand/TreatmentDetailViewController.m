//
//  TreatmentDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentDetailViewController.h"
#import "DEFINE.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "TreatmentDoc.h"
#import "ScheduleDoc.h"
#import "TreatmentDetailEditViewController.h"
#import "NavigationView.h"
#import "NSString+Base64.h"
#import "FooterView.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "GPBHTTPClient.h"
#import "UIPlaceHolderTextView.h"
#import "UILabel+InitLabel.h"
#import "TreatmentTabBarController.h"
#import "OrderDoc.h"
#import "UIImageView+WebCache.h"


NSInteger const kImageViewTag = 20000;


@interface TreatmentDetailViewController ()
@property (nonatomic,strong) UITableView *myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *updateTreatmentOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestTreatmentDetailOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGroupDetailOperation;
@property (strong, nonatomic) OrderDoc *theOrder;
@property (assign, nonatomic) CGRect prevCaretRect;
@property (strong, nonatomic) FooterView *footerView;
@property (strong, nonatomic) UITextView *textView_Selected;
@property (strong ,nonatomic) NSDictionary * detailDic;
@property (nonatomic , assign) NSString * titleStr;
@property (nonatomic ,strong) NSString * remarkStr;
@property (nonatomic ,assign) float remarkHeight;

@end

@implementation TreatmentDetailViewController
@synthesize myTableView;
@synthesize treatmentDoc;
@synthesize isLastTreatment;
@synthesize prevCaretRect;
@synthesize footerView;
@synthesize customerId;
@synthesize textView_Selected;
//@synthesize remark;
@synthesize detailDic;
@synthesize titleStr;
@synthesize remarkHeight,remarkStr;
@synthesize theOrder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /*
     * 屏蔽UIButton UITextView的tap
     */
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UITextView class]]) {
        return NO;
    }
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.treatMentOrGroup) {
        titleStr = @"操作";
        [self requestTreatmentDetail];

    }else
    {
        titleStr = @"服务";

        [self requestGroupDetail];
    }
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, 5.0f) title:[NSString stringWithFormat:@"%@详情",titleStr]];
    [self.view addSubview:navigationView];
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) - 49.0 - 40.0f -  5.0f - 5.0f) style:UITableViewStyleGrouped];
    
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        myTableView.sectionFooterHeight = 0;
        myTableView.sectionHeaderHeight = 10;
    }
    myTableView.autoresizesSubviews = UIViewAutoresizingNone;
    NSLog(@"the mytableView is x:%f y:%f w:%f h:%f",myTableView.frame.origin.x,myTableView.frame.origin.y,myTableView.frame.size.width,myTableView.frame.size.height);
    [self.view addSubview:myTableView];
    footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(postTreatmentRemark)];
    [footerView showInTableView:myTableView];
    footerView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)goTreatmentDetailEditPage
{
    [self performSegueWithIdentifier:@"goTreatmentDetailEditView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goTreatmentDetailEditView"]) {
        TreatmentDetailEditViewController *treatmentDetailEditViewController = segue.destinationViewController;
        treatmentDetailEditViewController.treatmentDoc = treatmentDoc;
        treatmentDetailEditViewController.isLastTreatment = isLastTreatment;
        treatmentDetailEditViewController.delegate = self;
    }
}

- (void)editSuccessWithTreatmentDoc:(TreatmentDoc *)newTreament
{
    treatmentDoc = newTreament;
    [myTableView reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyBoard];
}

- (void)dismissKeyBoard
{
    [textView_Selected resignFirstResponder];
}

- (void)postTreatmentRemark
{
    [self dismissKeyBoard];
    remarkStr = textView_Selected.text;
    if (self.treatMentOrGroup) {
        [self updateTreatmentInfo];
    }else
    {
        [self updateTGRemark];
    }

}
// add by zhangwei map bug GPB-715
-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue ].size;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(rect.size.height > 480)
        self.myTableView.frame = CGRectMake(5, 41.0f, kSCREN_BOUNDS.size.width - 10, 458.0f - keyboardSize.height);
    else
        self.myTableView.frame = CGRectMake(5, 41.0f, kSCREN_BOUNDS.size.width - 10, 370.0f - keyboardSize.height );
    NSLog(@"the keyboardWillChangeFrame is x:%f y:%f w:%f h:%f",myTableView.frame.origin.x,myTableView.frame.origin.y,myTableView.frame.size.width,myTableView.frame.size.height);
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isConfirmed && theOrder.ThumbnailURL.length >0) {
        return 3;
    }else{
        return 2;
    }
//    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([titleStr isEqualToString:@"服务"]) {
            return 5;
        }
        return 4;
        
    }else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellRow = (int)indexPath.row;
    if (indexPath.row > 0 && [titleStr isEqualToString:@"操作"]) {
        cellRow += 1;
    }
    if (indexPath.section == 0) {
        switch (cellRow) {
            case 0:
            {
                static NSString *cellIndentify = @"numCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                //            cell.titleLabel.text = @"服务编号";
                //            cell.valueText.text = treatmentDoc.treat_CodeString;
                if (self.treatMentOrGroup) {//treatment
                    cell.valueText.text = [NSString stringWithFormat:@"%@",[detailDic objectForKey:@"ID"]];
                }else
                {
                    cell.valueText.text = [NSString stringWithFormat:@"%@",[detailDic objectForKey:@"GroupNo"]];
                }
                cell.titleLabel.text = [NSString stringWithFormat:@"%@编号",titleStr];
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;

            }
                break;
            case 1:
            {
                static NSString *cellIndentify = @"Cell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                
                cell.titleLabel.text = [NSString stringWithFormat:@"服务门店"];
                cell.valueText.text = [[detailDic allKeys] containsObject:@"BranchName"]== 0?@" " : [detailDic objectForKey:@"BranchName"];
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;

            }
                break;
            case 2:
            {
                static NSString *cellIndentify = @"stateCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"状态";
                cell.valueText.text =theOrder.order_TGStatusStr;
                cell.valueText.textColor = [UIColor blackColor];
                cell.valueText.enabled = NO;
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;

            }
                break;
            case 3:
            {
            
                static NSString *cellIndentify = @"timeCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"开始时间";
                if (self.treatMentOrGroup) {//treatment
                    cell.valueText.text = [detailDic objectForKey:@"StartTime"];
                }else
                {
                    cell.valueText.text = [detailDic objectForKey:@"TGStartTime"];
                }
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;

            }
                break;
            case 4:
            {
                static NSString *cellIndentify = @"timeCell";
                NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                if (cell == nil) {
                    cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                }
                cell.titleLabel.text = @"结束时间";
                if (theOrder.order_TGStatus == 1) {
                    cell.valueText.text = @" " ;
                }else{
                    if (self.treatMentOrGroup) {//treatment
                        cell.valueText.text = [detailDic objectForKey:@"FinishTime"];
                    }else
                    {
                        cell.valueText.text = [detailDic objectForKey:@"TGEndTime"];
                    }
                }
                cell.valueText.enabled = NO;
                cell.valueText.textColor = [UIColor blackColor];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
                
            default:
                break;
        }
        
    } else {
        if (self.isConfirmed && theOrder.ThumbnailURL.length > 0) { // 有签名
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    static NSString *cellIndentify = @"contactRecordCell";
                    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                    if (cell == nil) {
                        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                    }
                    cell.titleLabel.text = @"顾客签字";
                    cell.valueText.enabled = NO;
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }else{
                    static NSString *cellIndentify = @"imageCell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
                        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,cell.frame.size.width,kSCREN_BOUNDS.size.width *( kSCREN_BOUNDS.size.width / kSCREN_BOUNDS.size.height))];
                        imageView.tag = kImageViewTag;
                        [cell.contentView addSubview:imageView];
                    }
                    UIImageView *imageView =[cell.contentView viewWithTag:kImageViewTag];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [imageView setImageWithURL:[NSURL URLWithString:theOrder.ThumbnailURL] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        
                    }];
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
            }else{ //服务记录
               return  [self serverRecordWithIndexPath:indexPath tableView:tableView];
            }
        }else{ //服务记录
            return  [self serverRecordWithIndexPath:indexPath tableView:tableView];
        }
    }
    
    return nil;
}

- (UITableViewCell *)serverRecordWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (indexPath.row == 0) {
        static NSString *cellIndentify = @"contactRecordCell";
        NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        cell.titleLabel.text = [NSString stringWithFormat:@"%@记录",titleStr];
        cell.valueText.enabled = NO;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        static NSString *cellIndentify = @"contactContentCell";
        ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
            cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentEditText.returnKeyType = UIReturnKeyDefault;
        [cell setContentText:remarkStr];
        cell.backgroundColor = [UIColor whiteColor];
        [cell.contentEditText setTag:101];
        [cell setDelegate:self];
        //            if (treatmentDoc.treat_Schedule.sch_Completed) {
        //                cell.userInteractionEnabled = NO;
        //            }
        //            cell.contentEditText.textColor = [UIColor blackColor];
        //            cell.contentEditText.editable = NO;
        cell.contentEditText.editable = YES ;
        [cell.contentEditText setFrame:CGRectMake(0.0f, 2.0f, 310.0f, CONTENT_EDIT_CELL_HEIGHT)];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isConfirmed && theOrder.ThumbnailURL.length > 0) { // 有签名
         if (indexPath.section == 1 && indexPath.row == 1) { // 图片
             return kSCREN_BOUNDS.size.width *( kSCREN_BOUNDS.size.width / kSCREN_BOUNDS.size.height);
         }else if (indexPath.section == 2 && indexPath.row == 1) { //服务记录
            if (remarkStr.length > 0) {
                NSInteger height = [remarkStr sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                return height < 38 ? 38 : height;
            }
            return kTableView_HeightOfRow;
        } else {
            return kTableView_HeightOfRow;
        }
    }else{
        if (indexPath.section == 1 && indexPath.row == 1) {
            if (remarkStr.length > 0) {
                NSInteger height = [remarkStr sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                return height < 38 ? 38 : height;
            }
            return kTableView_HeightOfRow;
        } else {
            return kTableView_HeightOfRow;
        }
    }
//    if (indexPath.section == 1 && indexPath.row == 1) {
//        if (remarkStr.length > 0) {
//            NSInteger height = [remarkStr sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
//            return height < 38 ? 38 : height;
//        }
//        return kTableView_HeightOfRow;
//    } else {
//        return kTableView_HeightOfRow;
//    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark -WordCheck

- (void)wordCountCheck:(NSNotification *)notiFi
{
    UITextView *textView = (UITextView *)notiFi.object;
    NSString *textContext = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:range.start offset:0];
        if (!position) {
            if (textView.text.length >= 300) {
                textView.text = [textContext substringToIndex:300];
            }
        }
    } else {
        if (textView.text.length >= 300) {
            textView.text = [textContext substringToIndex:300];
        }
    }
}
#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    if(!_permission_Write)
        return  NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wordCountCheck:) name:UITextViewTextDidChangeNotification object:contentText];
    self.textView_Selected = contentText;// add by zhangwei map bug GPB-715
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:contentText];
    // add by zhangwei map bug GPB-715
    remarkStr = contentText.text;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(rect.size.height > 480)
        self.myTableView.frame = CGRectMake(5, 41.f, kSCREN_BOUNDS.size.width - 10, 410.f);
    else
        self.myTableView.frame = CGRectMake(5, 41.f, kSCREN_BOUNDS.size.width - 10, 320.f);
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    NSLog(@"the contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing is x:%f y:%f w:%f h:%f",myTableView.frame.origin.x,myTableView.frame.origin.y,myTableView.frame.size.width,myTableView.frame.size.height);

    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    const char *ch = [text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch != 0) {
        footerView.hidden = NO;
        return YES;
    }else
        return YES;
    //if (*ch == 32)   return NO;
    
    if (![contentText.text isEqualToString:remarkStr]) {
        footerView.hidden = NO;
    } else {
        footerView.hidden = YES;
    }
    
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *range = [contentText markedTextRange];
        UITextPosition *position = [contentText positionFromPosition:range.start offset:0];
        if (!position) {
            if (contentText.text.length >= 300) {
                return NO;
            }
        }
    } else {
        if (contentText.text.length >= 300) {
            return NO;
        }
    }
    if ([text isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

//开始拖拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self.view endEditing:YES];
}


- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    remarkStr = contentText.text;
    remarkHeight = height;
    [myTableView beginUpdates];
    [myTableView endUpdates];
}

- (void)scrollToCursorForTextView: (UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableView convertRect:cursorRect fromView:textView];
    
    if (prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        prevCaretRect = newCursorRect;
        [myTableView scrollRectToVisible:newCursorRect animated:YES];
    }
}

#pragma mark - 接口
-(void)requestTreatmentDetail
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    
    NSDictionary * par = @{
                           @"TreatmentID":@(self.TreatmentID)
                           };
    
    _requestTreatmentDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetTreatmentDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
          [SVProgressHUD dismiss];
          [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
              if (data == nil) {
                  return ;
              }
               theOrder = [[OrderDoc alloc] init];
              detailDic = data;
              remarkStr = [detailDic objectForKey:@"Remark"];
              
              int status;
              status = [[detailDic objectForKey:@"Status"] intValue];
              [theOrder setOrder_TGStatus:status];
              
              [myTableView reloadData];
          } failure:^(NSInteger code, NSString *error) {
            
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];


}

-(void)requestGroupDetail
{
    [SVProgressHUD  showWithStatus:@"Loading"];
    NSString * url = @"/Order/GetTGDetail";
    NSDictionary * par = @{
                           @"GroupNo":@(self.GroupNo),
                           @"OrderID":@(self.OrderID)
                           };
    _requestGroupDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:url andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            theOrder = [[OrderDoc alloc] init];
            if (data == nil) {
                return ;
            }
            detailDic = data;
            remarkStr = [detailDic objectForKey:@"Remark"];
            
            int status;
            status = [[detailDic objectForKey:@"TGStatus"] intValue];
            [theOrder setOrder_TGStatus:status];
            [theOrder setThumbnailURL:[detailDic objectForKey:@"ThumbnailURL"]];
            [myTableView reloadData];
          } failure:^(NSInteger code, NSString *error) {
            
             [SVProgressHUD dismiss];
         }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
    }];
}

-(void)updateTGRemark
{
    if (remarkStr == nil) {
        remarkStr = @"";
    }
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par = @{
                            @"GroupNo":@(self.GroupNo),
                            @"OrderID":@((long)self.OrderID),
                            @"Remark":remarkStr
                           };
    _updateTreatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/UpdateTGRemark" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"服务记录修改成功。" touchEventHandle:^{}];
            footerView.hidden = YES;
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];

}

- (void)updateTreatmentInfo
{
    if (remarkStr == nil) {
        remarkStr = @"";
    }
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSString *par = [NSString stringWithFormat:@"{\"TreatmentID\":%ld,\"Remark\":\"%@\"}",(long)self.TreatmentID, remarkStr];

    _updateTreatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/updateTreatmentRemark" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"服务记录修改成功。" touchEventHandle:^{}];
            footerView.hidden = YES;
            [myTableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _updateTreatmentOperation = [[GPHTTPClient shareClient] requestUpdateTreatmentRemarkWithTreatment:treatmentDoc andCustomerID:customerId success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD showSuccessWithStatus2:@"服务记录修改成功。" touchEventHandle:^{}];
            remark = treatmentDoc.treat_Remark;
            footerView.hidden = YES;
            [myTableView reloadData];
        } failure:^{
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } ];
    */
}


@end
