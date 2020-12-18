//
//  AnswerQuestionsController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AnswerQuestionsController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "Questions.h"
#import "QuestionPaper.h"
#import "ChoiceQuestionsCell.h"
#import "SubjectCell.h"
#import "FooterView.h"
#import "UIButton+InitButton.h"
#import "ContentQuestionsCell.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h" 
#import "QuestionnaireListController.h"
#import "CusTabBarController.h"

typedef NS_ENUM(NSInteger, NotificationManage) {
    NotificationAdd,
    NotificationRemove
};
@interface AnswerQuestionsController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, weak) AFHTTPRequestOperation *addAnswer;
@property (nonatomic, strong) DFUITableView *selectionTable;
@property (nonatomic, strong) Questions *question;
@property (nonatomic, weak)   UILabel *showLabel;
@property (nonatomic, strong) UIScrollView *scroView;
@end

@implementation AnswerQuestionsController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self initWithData];
    [self initWithView];

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
    if ([_addAnswer isExecuting] && _addAnswer) {
        [_addAnswer cancel];
    }
    _addAnswer = nil;
}

static NSString *choiceCell = @"choiceCell";
static NSString *contentCell = @"contentCell";
static NSString *descriCell = @"descriCell";

- (void)initWithView
{
    self.view.backgroundColor = kColor_Background_View;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:self.quesPaper.Title];
    CGRect titleFrame = navigationView.titleLabel.frame;
    titleFrame.size.width = 310;
    navigationView.titleLabel.frame = titleFrame;
    
    _scroView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationView.frame), 320, kSCREN_BOUNDS.size.height - 64)];
    _scroView.contentSize = _scroView.bounds.size;
    [self.view addSubview:_scroView];

    _selectionTable = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStylePlain];
    if (IOS7 || IOS8) {
        _selectionTable.frame = CGRectMake(5.0f, 0, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f - 97.0);
    } else if (IOS6) {
        _selectionTable.frame = CGRectMake(-5.0f, 0, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f - 97.0);
    }
    
    _selectionTable.dataSource = self;
    _selectionTable.delegate = self;
    _selectionTable.separatorColor = kColor_Background_View;
    
    FooterView *footer = [[FooterView alloc] initWithTarget:self subTitle:@"提交" submitAction:@selector(buttonEven:) deleteTitle:@"取消" deleteAction:@selector(buttonEven:)];
                          
                            
    UIButton *backButton = [UIButton buttonWithTitle:@"上一题" target:self selector:@selector(buttonEven:) frame:CGRectMake(30, 10, 60, 30) titleColor:[UIColor whiteColor] backgroudColor:[UIColor colorWithRed:102.0/255.0f green:102.0/255.0f blue:102.0/255.0f alpha:1]];
    UIButton *nextButton = [UIButton buttonWithTitle:@"下一题" target:self selector:@selector(buttonEven:) frame:CGRectMake(150, 10, 60, 30)  titleColor:[UIColor whiteColor] backgroudColor:[UIColor colorWithRed:102.0/255.0f green:102.0/255.0f blue:102.0/255.0f alpha:1]];

    UIButton *jumpButton = [UIButton buttonWithTitle:@"跳过" target:self selector:@selector(buttonEven:) frame:CGRectMake(220, 10, 60, 30) titleColor:[UIColor whiteColor] backgroudColor:[UIColor colorWithRed:102.0/255.0f green:102.0/255.0f blue:102.0/255.0f alpha:1]];
    
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 60, 30)];
    [pageLabel setBackgroundColor:[UIColor colorWithRed:54.0/255.0f green:54.0/255.0f blue:54.0/255.0f alpha:1]];
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    
    pageLabel.text = [NSString stringWithFormat:@"%ld/%zd", (long)self.questionIndex + 1, self.quesPaper.questionsList.count];
    self.showLabel = pageLabel;
    [footer addSubview:backButton];
    [footer addSubview:nextButton];
    [footer addSubview:jumpButton];
    [footer addSubview:pageLabel];
    footer.frame = CGRectMake( 5, CGRectGetMaxY(_selectionTable.frame), 310, 36.0 + 10.0 +5.0 + 10 + 36);
    footer.deleteButton.frame = CGRectMake(0, 56.0, 148, 36);
    footer.submitButton.frame = CGRectMake(CGRectGetMaxX(footer.deleteButton.frame) + 7.0, 56.0, 148, 36);
    
    [self.scroView addSubview:footer];
    
    [self.selectionTable registerClass:[ChoiceQuestionsCell class] forCellReuseIdentifier:choiceCell];
    [self.selectionTable registerClass:[ContentQuestionsCell class] forCellReuseIdentifier:contentCell];
    [self.selectionTable registerClass:[UITableViewCell class] forCellReuseIdentifier:descriCell];
    [self.view addSubview:navigationView];
    [self.scroView addSubview:_selectionTable];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)initWithData {

    [self thePaperFromSetsAddOrRemove:YES andPaper:self.quesPaper];
    
    if (self.quesPaper.PaperStatus == PaperStatusNormol) {
        [self.quesPaper getQuestionsOfThePaperCompletion:^(NSArray *array) {
            self.question = [self.quesPaper.questionsList objectAtIndex:self.questionIndex];
            self.questionIndex = 0;
            self.quesPaper.PaperStatus = PaperStatusStorage;
            [self.selectionTable reloadData];
        }];
    }
}

- (void)thePaperFromSetsAddOrRemove:(BOOL)add andPaper:(QuestionPaper *)paper
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerID = %ld AND PaperID = %ld", app.customer_Selected.cus_ID, paper.PaperID];
    NSArray *tmpArray = [app.paperStorageOfCustomer filteredArrayUsingPredicate:predicate];
    if (add) {
        if (tmpArray.count == 0) {
            paper.customerID = app.customer_Selected.cus_ID;
            paper.CustomerName = app.customer_Selected.cus_Name;
            paper.ResponsiblePersonName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            paper.UpdateTime = [formatter stringFromDate:[NSDate date]];
            [app.paperStorageOfCustomer addObject:paper];
        } else {
            paper.PaperStatus = PaperStatusStorage;
            paper.questionsList = [((QuestionPaper *)[tmpArray firstObject]).questionsList mutableCopy];
        }
    } else {
        paper.PaperStatus = PaperStatusNormol;
        [app.paperStorageOfCustomer removeObjectsInArray:tmpArray];
    }
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

-(void)keyboardDidShown:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scroView.contentInset =  UIEdgeInsetsMake(0, 0, 240, 0);
    } completion:^(BOOL finished) {
        [self.selectionTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    [UIView animateWithDuration:0.2 animations:^{
        self.scroView.contentInset = UIEdgeInsetsZero;
    }];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setQuestionIndex:(NSInteger)qIndex
{
    if (qIndex >= 0 && qIndex < self.quesPaper.questionsList.count) {
        _questionIndex = qIndex;
        self.showLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)_questionIndex + 1, (unsigned long)self.quesPaper.questionsList.count];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (Questions *)question {
    _question = self.quesPaper.questionsList[self.questionIndex];
    _question.quesStatus = QuestionStatusModified;
    return _question;
}

- (void)backUp{
    if (self.questionIndex == 0) {
        [SVProgressHUD showErrorWithStatus2:@"已经是第一道题目了" duration:kSvhudtimer touchEventHandle:^{
        }];
    } else {
        self.questionIndex--;
        [self.selectionTable reloadData];
    }
}

- (void)nextQuestion{
    if (self.questionIndex + 1 == self.quesPaper.questionsList.count) {
        [SVProgressHUD showErrorWithStatus2:@"已经是最后一道题目了" duration:kSvhudtimer touchEventHandle:^{
        }];
    } else {
        self.questionIndex++;
        [self.selectionTable reloadData];
    }
}

- (void)jumpQuestion{
    
    [self.question skipThisQuestion];
    self.questionIndex++;
    [self.selectionTable reloadData];
}
- (void)buttonEven:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *title = sender.currentTitle;
    if ([title isEqualToString:@"取消"]) {
        [self cancel];
    } else if ([title isEqualToString:@"提交"]) {
        [self confirm];
    } else if ([title isEqualToString:@"上一题"]) {
        [self backUp];
    } else if ([title isEqualToString:@"下一题"]) {
        [self nextQuestion];
    } else if ([title isEqualToString:@"跳过"]) {
        [self.question skipThisQuestion];
        self.questionIndex++;
        [self.selectionTable reloadData];
    }
}

- (void)confirm{
    _addAnswer = [self.quesPaper requestAddAnswerOfPaperCompletion:^(NSInteger code, NSString *mesg) {
        if (code == 1) {
            [SVProgressHUD showSuccessWithStatus2:@"答题成功" duration:1.5 touchEventHandle:^{
                [self thePaperFromSetsAddOrRemove:NO andPaper:self.quesPaper];
                
                for (UIViewController *temp in self.navigationController.viewControllers) {
                    NSLog(@"tmp +%@",temp);
                    if ([temp isMemberOfClass:[CusTabBarController class]]) {
                        [self.navigationController popToViewController:temp animated:YES];
                    }
                }
            }];
        } else {
            [SVProgressHUD showSuccessWithStatus2:mesg touchEventHandle:^{}];
        }
    }];
}

- (void)cancel{
    [self thePaperFromSetsAddOrRemove:NO andPaper:self.quesPaper];
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
            return 120;
        } else {
            return 38.0;
        }
    }
    return 38.0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:descriCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300, (self.question.attributedSize.height > 15 ? self.question.attributedSize.height + 15: 38))];
        lable.font = kFont_Light_16;
        lable.tag = indexPath.row + 1000;
        [cell.contentView addSubview:lable];
        cell.textLabel.numberOfLines = 0;
        UILabel * titellabel = (UILabel *)[cell.contentView viewWithTag:1000+indexPath.row];
        
        if (indexPath.row == 0) {
            CGRect temp = titellabel.frame;
            temp.size.height = (self.question.attributedSize.height > 15 ? self.question.attributedSize.height + 15: 38);
            titellabel.frame = temp;
            titellabel.numberOfLines = 0;
            titellabel.attributedText = self.question.attributedQuestionTitle;
            return cell;
        } else {
            titellabel.text = self.question.QuestionDescription;
            return cell;
        }
    } else {
        if (self.question.QuestionType == QuestionTextMode) {
            ContentQuestionsCell *textCell = [tableView dequeueReusableCellWithIdentifier:contentCell];
            textCell.textView.text = self.question.QuestionContent;
            textCell.textView.delegate = self;
            return textCell;
        } else {
            ChoiceQuestionsCell *choiCell = [tableView dequeueReusableCellWithIdentifier:choiceCell];
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
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
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
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.question.QuestionContent = textView.text;
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


- (void)scrollToCursorForTextView:(UITextView*)textView
{
    //20141029 修正输入地址时界面上下滚动，因下面这段代码引起。
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    CGPoint point1 = [self.scroView convertPoint:cursorRect.origin fromView:textView];
    [self.scroView scrollRectToVisible:CGRectMake( 0, point1.y , 320, 100) animated:YES];
}

@end
