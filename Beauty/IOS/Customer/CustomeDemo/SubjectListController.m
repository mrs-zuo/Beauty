//
//  SubjectListController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SubjectListController.h"
//#import "NavigationView.h"
#import "SubjectCell.h"
#import "QuestionPaper.h"   
#import "Questions.h"
#import "ChoiceQuestionsCell.h"
#import "RecordView.h"


#define HEIGHT_NAVIGATION_VIEW  36.0f
#define DescriptionShow     (quest.QuestionDescription.length > 0 ? 2: 1)


@interface SubjectListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *questionsList;
@property (nonatomic, assign) BOOL   isShowAll;

@property (nonatomic,strong) RecordView *recordView;
@property (nonatomic,assign) BOOL isExpand;
@property (nonatomic,strong)UIView *grayView;

@end

@implementation SubjectListController
@synthesize listTableView;
@synthesize questionsList;

static NSString *titleCell = @"titleCell";
static NSString *textCell = @"textCell";
static NSString *choice = @"choice";


- (void)initNavigationItem
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 20.0f, 30.0f, 30.0f)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(kSCREN_BOUNDS.size.width - 50.0f, 0 , 44, 44)];
    rightBtn.titleEdgeInsets = UIEdgeInsetsMake(-15, 0, 0, 0);
    rightBtn.titleLabel.font = kNormalFont_28;
    [rightBtn setTitle:@"..." forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)removeRecordView
{
    _isExpand = NO;
    if (_recordView) {
        [_recordView removeFromSuperview];
        _recordView = nil;
    }
    if (_grayView) {
        [_grayView removeFromSuperview];
        _grayView = nil;
    }
}
- (void)filterAction
{
    //默认值
    BOOL isAllYes = YES;
    if (self.questionsList.count > 0) {
        for (Questions *obj in self.questionsList) {
            if (obj.isShow == NO) {
                isAllYes =NO;
                break;
            }
        }
    }
    _isShowAll = isAllYes;
    
    //是否展开
    if (_isExpand) {
        _isExpand = NO;
        [self removeRecordView];
    }else{
        
        //灰色背景
        _grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
        _grayView.backgroundColor =RGBA(184, 184, 184, 0.5);
        [self.view addSubview:_grayView];
        
        _isExpand = YES;
        _recordView = [[RecordView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, 153)];
        _recordView.isShowAll = _isShowAll;
        __weak typeof(self) weakSelf = self;
        _recordView.canceBlock = ^(){
            [weakSelf removeRecordView];
        };
        
        _recordView.expandBlock = ^(UIButton *butt,BOOL showAll){
            weakSelf.isShowAll = showAll;
            if (weakSelf.isShowAll) {
                [butt setTitle:@"全部收缩" forState:UIControlStateNormal];
            }else{
                [butt setTitle:@"全部展开" forState:UIControlStateNormal];
            }
            [weakSelf.questionsList enumerateObjectsUsingBlock:^(Questions *obj, NSUInteger idx, BOOL *stop) {
                obj.isShow = weakSelf.isShowAll;
            }];
            [weakSelf.listTableView reloadData];
        };

        _recordView.indexBlock = ^(){
            [weakSelf removeRecordView];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        };
        [self.view addSubview:_recordView];
    }
    
}

- (void)viewDidLoad {
    self.isShowButton = NO;
    [super viewDidLoad];
    [self initNavigationItem];
    self.title = self.quesPaper.Title;
    [self initWithView];
    [self initWithData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.quesPaper getQuestionsOfThePaperCompletion:^(NSArray *array) {
    self.questionsList = [self.quesPaper.questionsList mutableCopy];
       
        [self.listTableView reloadData];
    }];
}

- (void)initWithView
{
    self.view.backgroundColor = kDefaultBackgroundColor;

    listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 5,kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height+ 20) style:UITableViewStylePlain];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.autoresizingMask = UIViewAutoresizingNone;
    listTableView.backgroundColor = [UIColor clearColor];
    //[listTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    listTableView.separatorColor = kTableView_LineColor;
    //listTableView.backgroundView = nil;
    if ((IOS7 || IOS8)) self.listTableView.separatorInset = UIEdgeInsetsZero;
    [self.listTableView registerClass:[SubjectCell class] forCellReuseIdentifier:titleCell];
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:textCell];
    [self.listTableView registerClass:[ChoiceQuestionsCell class] forCellReuseIdentifier:choice];
    [self.view addSubview:listTableView];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initWithData {
    self.questionsList = [NSMutableArray array];
    self.isShowAll = NO;
    _isExpand = NO;
}


#pragma mark SubjectList Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.questionsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Questions *object = [self.questionsList objectAtIndex:section];
    NSInteger rowCount = 1;
    if (object.isShow) {
        switch (object.QuestionType) {
            case QuestionSingleSelection:
                rowCount += object.answerList.count;
                break;
            case QuestionMutalSelection:
                rowCount += object.answerList.count;
                break;
            case QuestionTextMode:
                ++rowCount;
                break;
        }
    }
    if (object.QuestionDescription.length > 0 && object.isShow) {
        ++rowCount;
    }
    return rowCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Questions *ques = [self.questionsList objectAtIndex:indexPath.section];

    if (indexPath.row == 0) {
        return [SubjectCell getQuestHeight:[self.questionsList objectAtIndex:indexPath.section]];
    } else if (indexPath.row == 1 && ques.QuestionDescription.length > 0 && ques.isShow) {
        if (ques.descriptionSize.height > kTableView_DefaultCellHeight ) {
            return ques.descriptionSize.height;
        }else{
            return kTableView_DefaultCellHeight;
        }
    } else {
        if (ques.QuestionType == QuestionSingleSelection ||ques.QuestionType == QuestionMutalSelection) {
            return kTableView_DefaultCellHeight;
        } else {
            if (ques.contentSize.height > kTableView_DefaultCellHeight ) {
                return ques.contentSize.height;
            }else{
                return kTableView_DefaultCellHeight;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Questions *quest = [self.questionsList objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        SubjectCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCell];
        cell.question = quest;
        return cell;
    } else if (quest.QuestionDescription.length > 0 && indexPath.row == 1 && quest.isShow) {
        UITableViewCell *contextCell = [tableView dequeueReusableCellWithIdentifier:textCell];
        contextCell.backgroundColor = [UIColor whiteColor];
        contextCell.textLabel.font = kNormalFont_14;
        contextCell.textLabel.textColor = kColor_Black;
        contextCell.textLabel.text = quest.QuestionDescription;
        contextCell.textLabel.numberOfLines = 0;
        contextCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return contextCell;
    } else {
        if (quest.QuestionType == QuestionTextMode) {
            UITableViewCell *contextCell = [tableView dequeueReusableCellWithIdentifier:textCell];
            contextCell.backgroundColor = [UIColor whiteColor];
            contextCell.textLabel.font = kNormalFont_14;
            contextCell.textLabel.text = quest.AnswerContent;
            contextCell.textLabel.numberOfLines = 0;
            contextCell.textLabel.textColor = kColor_Black;
            contextCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return contextCell;
        } else {
            ChoiceQuestionsCell *answerCell = [tableView dequeueReusableCellWithIdentifier:choice];
            answerCell.choice = ((ChoiceQuestion *)quest.answerList[indexPath.row - DescriptionShow]);
            return answerCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 ) {
        Questions  *ques = [self.questionsList objectAtIndex:indexPath.section];
        ques.isShow = !ques.isShow;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
