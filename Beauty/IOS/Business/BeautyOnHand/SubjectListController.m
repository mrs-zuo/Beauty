//
//  SubjectListController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SubjectListController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "SubjectCell.h"
#import "QuestionPaper.h"   
#import "Questions.h"
#import "ChoiceQuestionsCell.h"
#import "ModifyAnswerController.h"
#import "UIButton+InitButton.h" 

#define DescriptionShow  (quest.QuestionDescription.length > 0 ? 2 : 1)
#define DescriptionIsShow   (object.QuestionDescription.length > 0 && object.isShow)
@interface SubjectListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) DFUITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *questionsList;
@property (nonatomic, assign) BOOL  isEdit;
@property (nonatomic, assign) BOOL  isShowAll;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *showButton;
@end

@implementation SubjectListController
@synthesize listTableView;
@synthesize questionsList;

static NSString *titleCell = @"titleCell";
static NSString *textCell = @"textCell";
static NSString *choice = @"choice";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWithView];
    [self initWithData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isEdit = NO;
    self.isShowAll = NO;
    self.editButton.selected = self.isEdit;
    self.showButton.selected = self.isShowAll;

    [self.quesPaper getQuestionsOfThePaperCompletion:^(NSArray *array) {
        self.questionsList = [self.quesPaper.questionsList mutableCopy];
        [self.listTableView reloadData];
    }];
}

- (void)initWithView
{
    self.view.backgroundColor = kColor_Background_View;
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:self.quesPaper.Title];
    CGRect titleFrame = navigationView.titleLabel.frame;
    
    self.showButton = [UIButton buttonWithTitle:@""
                                          target:self
                                        selector:@selector(showAll:)
                                           frame:CGRectMake(314.0f - HEIGHT_NAVIGATION_VIEW, 0.0f, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                   backgroundImg:[UIImage imageNamed:@"unfold_ios"]
                                highlightedImage:nil];
    [self.showButton setBackgroundImage:[UIImage imageNamed:@"call_ios"] forState:UIControlStateSelected];

    if ([[PermissionDoc sharePermission] rule_Record_Write] && self.quesPaper.CanEditAnswer) {
        self.editButton = [UIButton buttonWithTitle:@"" target:self selector:@selector(editAction:) frame:CGRectMake(314 - 2 * HEIGHT_NAVIGATION_VIEW, 0.0f, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW) backgroundImg:[UIImage imageNamed:@"edit_paper"] highlightedImage:nil];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"edit_nopaper"] forState:UIControlStateSelected];
        
        [navigationView addSubview:self.editButton];
        titleFrame.size.width = 235;
        [navigationView addSubview:self.showButton];
    } else {
        [navigationView addSubview:self.showButton];
        titleFrame.size.width = 280;
    }
    navigationView.titleLabel.frame = titleFrame;

    listTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    if (IOS7 || IOS8) {
        listTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        listTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.separatorColor = kColor_Background_View;
    
    [self.listTableView registerClass:[SubjectCell class] forCellReuseIdentifier:titleCell];
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:textCell];
    [self.listTableView registerClass:[ChoiceQuestionsCell class] forCellReuseIdentifier:choice];
    
    [self.view addSubview:navigationView];
    [self.view addSubview:listTableView];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)initWithData {
    self.questionsList = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editAction:(UIButton *)button
{
    self.isEdit = !self.isEdit;
    button.selected = self.isEdit;

    [self.questionsList enumerateObjectsUsingBlock:^(Questions *obj, NSUInteger idx, BOOL *stop) {
        obj.isEdit = self.isEdit;
    }];
    [self.listTableView reloadData];
}

- (void)showAll:(UIButton *)button
{
    self.isShowAll = !self.isShowAll;
    button.selected = self.isShowAll;
    [self.questionsList enumerateObjectsUsingBlock:^(Questions * obj, NSUInteger idx, BOOL *stop) {
        obj.isShow = self.isShowAll;
    }];
    [self.listTableView reloadData];
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
            case QuestionMutalSelection:
                rowCount += object.answerList.count;
                break;
            case QuestionTextMode:
                ++rowCount;
                break;
        }
    }
    if (DescriptionIsShow) {
        ++rowCount;
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Questions *ques = [self.questionsList objectAtIndex:indexPath.section];

    if (indexPath.row == 0) {
        return [SubjectCell getQuestHeight:[self.questionsList objectAtIndex:indexPath.section]];
    } else if (indexPath.row == 1 && ques.QuestionDescription.length > 0 && ques.isShow) {
        return ques.descriptionSize.height;
    } else {
        if (ques.QuestionType == QuestionSingleSelection ||ques.QuestionType == QuestionMutalSelection) {
            return kTableView_HeightOfRow;
        } else {
            return ques.contentSize.height;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Questions *quest = [self.questionsList objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        SubjectCell *cell = [tableView dequeueReusableCellWithIdentifier:titleCell];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section + 1];
        cell.question = quest;
        return cell;
    } else if (indexPath.row == 1 && quest.QuestionDescription.length > 0 && quest.isShow) {
        UITableViewCell *contextCell = [tableView dequeueReusableCellWithIdentifier:textCell];
        contextCell.backgroundColor = [UIColor whiteColor];
        contextCell.selectionStyle = UITableViewCellSelectionStyleNone;
        contextCell.textLabel.font = kFont_Light_14;
        contextCell.textLabel.text = quest.QuestionDescription;
        contextCell.textLabel.textColor = kColor_Black;
        contextCell.textLabel.numberOfLines = 0;
        return contextCell;
    } else {
        if (quest.QuestionType == QuestionTextMode) {
            UITableViewCell *contextCell = [tableView dequeueReusableCellWithIdentifier:textCell];
            contextCell.backgroundColor = [UIColor whiteColor];
            contextCell.textLabel.font = kFont_Light_15;
            contextCell.textLabel.text = quest.AnswerContent;
            contextCell.textLabel.numberOfLines = 0;
            contextCell.textLabel.textColor = kColor_Editable;
            return contextCell;
        } else {
            ChoiceQuestionsCell *answerCell = [tableView dequeueReusableCellWithIdentifier:choice];
            answerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            answerCell.choice = ((ChoiceQuestion *)quest.answerList[indexPath.row - DescriptionShow]);
            return answerCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0 ) {
        if (self.isEdit) {
            ModifyAnswerController *modifyVC = [[ModifyAnswerController alloc] init];
            modifyVC.questionPaper = self.quesPaper;
            modifyVC.questionIndex = indexPath.section;
            [self.navigationController pushViewController:modifyVC animated:YES];
        } else {
            Questions  *ques = [self.questionsList objectAtIndex:indexPath.section];
            ques.isShow = !ques.isShow;
             [self checkShowStatus];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)checkShowStatus
{
    __block int i = 0;
    [self.questionsList enumerateObjectsUsingBlock:^(Questions *obj, NSUInteger idx, BOOL *stop) {
        if (obj.isShow) {
            ++i;
        }
    }];
    
    if ( i != 0 && i == self.questionsList.count) {
        self.isShowAll = YES;
    } else {
        self.isShowAll = NO;
    }
    self.showButton.selected = self.isShowAll;
}

@end
