//
//  ModifyAnswerController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/29.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ModifyAnswerController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "ChoiceQuestionsCell.h"
#import "ContentQuestionsCell.h"
#import "Questions.h"
#import "QuestionPaper.h"
#import "SVProgressHUD.h"

typedef NS_ENUM(NSInteger, NotificationManage) {
    NotificationAdd,
    NotificationRemove
};

@interface ModifyAnswerController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) DFUITableView  *modifyTable;
@property (nonatomic, strong) UIScrollView   *scroView;
@property (nonatomic, strong) Questions      *question;
@end

@implementation ModifyAnswerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self notificationManageWithNotificationManage:NotificationAdd];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self notificationManageWithNotificationManage:NotificationRemove];
}

static NSString *modifyChoiceCell = @"modifyChoiceCell";
static NSString *modifyContentCell = @"modifyContentCell";
static NSString *descrCell = @"descrCell";

- (void)initWithView
{
    self.view.backgroundColor = kColor_Background_View;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:self.questionPaper.Title];
    CGRect titleFrame = navigationView.titleLabel.frame;
    titleFrame.size.width = 310;
    navigationView.titleLabel.frame = titleFrame;

    _scroView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationView.frame), kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 64)];
    _scroView.contentSize = _scroView.bounds.size;
    [self.view addSubview:_scroView];
    
    _modifyTable = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStylePlain];
    if (IOS7 || IOS8) {
        _modifyTable.frame = CGRectMake(5.0f, 0, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        _modifyTable.frame = CGRectMake(-5.0f, 0, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    _modifyTable.dataSource = self;
    _modifyTable.delegate = self;
    _modifyTable.separatorColor = kColor_Background_View;
    
    FooterView *footer = [[FooterView alloc] initWithTarget:self subTitle:@"确定" submitAction:@selector(confirm:) deleteTitle:@"取消" deleteAction:@selector(cancel:)];
    
    footer.frame = CGRectMake( 5, CGRectGetMaxY(_modifyTable.frame), 310, 10.0 +5.0 + 36);

    footer.deleteButton.frame = CGRectMake(0, 10.0, 148, 36);
    footer.submitButton.frame = CGRectMake(CGRectGetMaxX(footer.deleteButton.frame) + 7.0, 10.0, 148, 36);
    [footer showInTableView:self.modifyTable];
    
    [self.modifyTable registerClass:[ChoiceQuestionsCell class] forCellReuseIdentifier:modifyChoiceCell];
    [self.modifyTable registerClass:[ContentQuestionsCell class] forCellReuseIdentifier:modifyContentCell];
    [self.modifyTable registerClass:[UITableViewCell class] forCellReuseIdentifier:descrCell];
    [self.view addSubview:navigationView];
    [self.scroView addSubview:_modifyTable];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initData
{
    self.question = self.questionPaper.questionsList[self.questionIndex];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notificationManageWithNotificationManage:(NotificationManage)manageType
{
    switch (manageType) {
        case NotificationAdd:
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
            break;
        case NotificationRemove:
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
            break;
    }
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scroView.contentInset = UIEdgeInsetsZero;
    }];
}

-(void)keyboardDidShown:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scroView.contentInset =  UIEdgeInsetsMake(0, 0, 240, 0);
    }];
}
- (void)confirm:(UIButton *)sender{
    [self.view endEditing:YES];
    [self.questionPaper modifyTheQuestionOfThisPaper:self.question CompletionBlock:^(NSInteger code, NSString *mesg) {
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus2:@"答题成功" duration:1.5 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [SVProgressHUD showSuccessWithStatus2:mesg touchEventHandle:^{}];
        }
    }];
}

- (void)cancel:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (self.question.QuestionDescription.length > 0 ? 2: 1);
    } else {
        if (self.question.QuestionType == QuestionTextMode) {
            return 1;
        } else {
            return self.question.answerList.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return (self.question.attributedSize.height > 15 ? self.question.attributedSize.height + 15: 38);
            case 1:
                return self.question.descriptionSize.height;
        }
    } else {
        if (self.question.QuestionType == QuestionTextMode) {
            return self.question.answerContentHeight;
        } else {
            return 38.0;
        }
    }
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
    return (self.question.attributedSize.height > 15 ? self.question.attributedSize.height + 15: 38);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self questionTitleHeaderViewAttributedQuestion:self.question.attributedQuestionTitle andHeight:self.question.attributedSize.height];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:descrCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = self.question.attributedQuestionTitle;
            return cell;
        } else {
            cell.textLabel.font = kFont_Light_14;
            cell.textLabel.text = self.question.QuestionDescription;
            return cell;
        }
    } else {
        if (self.question.QuestionType == QuestionTextMode) {
            ContentQuestionsCell *textCell = [tableView dequeueReusableCellWithIdentifier:modifyContentCell];
            textCell.textView.text = self.question.AnswerContent;
            textCell.textView.delegate = self;
            return textCell;
        } else {
            ChoiceQuestionsCell *choiCell = [tableView dequeueReusableCellWithIdentifier:modifyChoiceCell];
            choiCell.choice = self.question.answerList[indexPath.row];
            return choiCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.question.answerList.count && self.question.QuestionType != QuestionTextMode) {
        [self.question modifiedChoiceQuestion:indexPath.row];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self scrollToCursorForTextView:textView];
    int length = 200;
    if (textView.text.length >length && !textView.markedTextRange) {
        textView.text = [textView.text substringToIndex:length];
    }
    self.question.QuestionContent = textView.text;
    
//    CGSize size = [textView sizeThatFits:CGSizeMake(290, MAXFLOAT)];
//    if (size.height > self.question.answerContentHeight) {
//        self.question.answerContentHeight = size.height;
//        CGRect textFrame = textView.frame;
//        textFrame.size.height = self.question.answerContentHeight;
//        textView.frame = textFrame;
//        [self.modifyTable beginUpdates];
//        [self.modifyTable endUpdates];
//    }

}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.question.QuestionContent = textView.text;
}

- (void)scrollToCursorForTextView:(UITextView*)textView
{
    //20141029 修正输入地址时界面上下滚动，因下面这段代码引起。
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGPoint point1 = [self.scroView convertPoint:cursorRect.origin fromView:textView];
    [self.scroView scrollRectToVisible:CGRectMake( 0, point1.y , 320, 100) animated:YES];
}

#pragma mark praMothed
- (UITableViewHeaderFooterView *)questionTitleHeaderViewAttributedQuestion:(NSAttributedString *)attributedTitl andHeight:(CGFloat)height
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:nil];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 280, (height > 15 ? height + 15: 38))];
    label.font = kFont_Light_14;
    label.numberOfLines = 0;
    label.lineBreakMode  = NSLineBreakByTruncatingTail;
    label.attributedText = attributedTitl;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, CGRectGetMaxY(label.frame), 310, 1);
    layer.backgroundColor = kColor_Background_View.CGColor;
    [headerView.layer addSublayer:layer];
    [headerView.contentView addSubview:label];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

@end
