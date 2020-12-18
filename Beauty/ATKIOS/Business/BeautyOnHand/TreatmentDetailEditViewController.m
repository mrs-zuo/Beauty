//
//  TreatmentDetailEditViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentDetailEditViewController.h"
#import "DEFINE.h"
#import "UILabel+InitLabel.h"
#import "TreatmentDoc.h"
#import "ScheduleDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "TreatmentDetailViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "GPBHTTPClient.h"

@interface TreatmentDetailEditViewController ()
@property (nonatomic) UITextView *textView_selected;
@property (assign, nonatomic) CGFloat tableView_Height;

@property (assign, nonatomic) CGRect prevCaretRect;

@property (weak, nonatomic) AFHTTPRequestOperation *updateTreatmentOperation;
@property (strong, nonatomic) UISwitch *stateSwitch;
@end

@implementation TreatmentDetailEditViewController
@synthesize myTableview;
@synthesize textView_selected;
@synthesize tableView_Height;
@synthesize treatmentDoc;
@synthesize delegate;
@synthesize prevCaretRect;
@synthesize isLastTreatment;
@synthesize stateSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.baseEditing = YES;
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"服务信息编辑"];
     [self.view addSubview:navigationView];

    myTableview.showsHorizontalScrollIndicator = NO;
    myTableview.showsVerticalScrollIndicator = NO;
    myTableview.backgroundColor = [UIColor clearColor];
    myTableview.backgroundView = nil;
    tableView_Height = myTableview.frame.size.height;
    myTableview.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        myTableview.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        myTableview.separatorInset = UIEdgeInsetsZero;
    } else if (IOS6) {
        myTableview.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footerView = [[FooterView alloc] initWithTarget:self submitImg:[[UIImage alloc] init] submitTitle:@"确定" submitAction:@selector(isMakeOrderConfirm)];
    [footerView showInTableView:myTableview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return treatmentDoc.height_Treat_Remark;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"timeCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"时间";
            cell.valueText.text = treatmentDoc.treat_Schedule.sch_ScheduleTime;
            cell.valueText.enabled = NO;
            cell.valueText.tag = 100;
            cell.valueText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        } else {
            static NSString *cellIndentify = @"stateCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"状态（未完成/待顾客确认）";
            cell.valueText.enabled = NO;
            cell.valueText.textColor = [UIColor blackColor];
            
            stateSwitch = [[UISwitch alloc] init];
            if (treatmentDoc.treat_Schedule.sch_Completed == 0) {
                stateSwitch.on = NO;
                stateSwitch.userInteractionEnabled = YES;
            } else {
                stateSwitch.on = YES;
                stateSwitch.userInteractionEnabled = NO;
            }
            [stateSwitch addTarget:self action:@selector(changeBrowseType:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = stateSwitch;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"contactRecordCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"服务记录";
            cell.valueText.enabled = NO;
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        } else {
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
            [cell setContentText:treatmentDoc.treat_Remark];
            [[cell contentEditText] setPlaceholder:@"输入服务记录"];
            [cell.contentEditText setTag:101];
            [cell setDelegate:self];
            return cell;
        }
    }
}

#pragma mark - Switch

- (void)changeBrowseType:(id)sender
{
    UISwitch *ctlSh = (UISwitch *)sender;
    if (ctlSh.on == true) {
        treatmentDoc.treat_Schedule.sch_Completed = 2;
    } else {
        treatmentDoc.treat_Schedule.sch_Completed = 0;
    }
}

//#pragma mark - ContentEditCellDelegate

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldBeginEditing:(UITextView *)contentText
{
    self.textView_Selected = contentText;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textViewShouldEndEditing:(UITextView *)contentText
{
    treatmentDoc.treat_Remark = contentText.text;
    return YES;
}

- (BOOL)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([contentText.text length] > 300) return NO;
    return YES;
}

- (void)contentEditCell:(ContentEditCell *)cell textView:(UITextView *)contentText textViewCurrentHeight:(CGFloat)height
{
    [self scrollToCursorForTextView:contentText];
    treatmentDoc.treat_Remark = contentText.text;
    treatmentDoc.height_Treat_Remark = height;
    [myTableview beginUpdates];
    [myTableview endUpdates];
}

- (void)scrollToCursorForTextView: (UITextView*)textView
{
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGRect newCursorRect = [myTableview convertRect:cursorRect fromView:textView];
    
    if (prevCaretRect.size.height != newCursorRect.size.height) {
        newCursorRect.size.height += 15;
        prevCaretRect = newCursorRect;
        [myTableview scrollRectToVisible:newCursorRect animated:YES];
    }
}

#pragma mark - 询问是否在用户确认后结束整个订单

- (void)isMakeOrderConfirm
{
    if (isLastTreatment) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"已是最后一次服务。将在用户确认后完成整个订单。是否继续?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self updateTreatmentInfo];
            } else if (buttonIndex == 0) {
                [stateSwitch setOn:false animated:YES];
            }
        }];
    } else {
        [self updateTreatmentInfo];
    }
}

#pragma mark - 接口

- (void)updateTreatmentInfo
{
    if (treatmentDoc.treat_Remark == nil) {
        treatmentDoc.treat_Remark = @"";
    }
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *par = [NSString stringWithFormat:@"{\"Remark\":\"%@\",\"TreatmentID\":%ld,\"Status\":%ld,\"ScheduleID\":%ld}", treatmentDoc.treat_Remark, (long)treatmentDoc.treat_ID, (long)treatmentDoc.treat_Schedule.sch_Completed, (long)treatmentDoc.treat_Schedule.sch_ID];

    
    _updateTreatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/updateTreatment" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:message duration:kSvhudtimer touchEventHandle:^{
                if ([delegate respondsToSelector:@selector(editSuccessWithTreatmentDoc:)]) {
                    [delegate editSuccessWithTreatmentDoc:treatmentDoc];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    
    
    
    
    
    /*
    _updateTreatmentOperation = [[GPHTTPClient shareClient] requestUpdateTreatmentDetailInfoWith:treatmentDoc success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML2:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            if ([delegate respondsToSelector:@selector(editSuccessWithTreatmentDoc:)]) {
                [delegate editSuccessWithTreatmentDoc:treatmentDoc];
            }
        } failure:^{
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } ];
     */
}

@end