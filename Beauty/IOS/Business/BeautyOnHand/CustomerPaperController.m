//
//  CustomerPaperController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/29.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "CustomerPaperController.h"
#import "NavigationView.h"
#import "DFUITableView.h"
#import "QuestsListCell.h"
#import "QuestionPaper.h"
#import "AnswerQuestionsController.h"

@interface CustomerPaperController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) DFUITableView *paperTable;
@property (nonatomic, strong) NSMutableArray *papersList;
@end

@implementation CustomerPaperController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithView];
    [self initWithData];
}

- (void)initWithView
{
    self.view.backgroundColor = kColor_Background_View;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"请选择模板"];
    _paperTable = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    if (IOS7 || IOS8) {
        _paperTable.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        _paperTable.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }

    _paperTable.dataSource = self;
    _paperTable.delegate = self;
    _paperTable.separatorColor = kTableView_LineColor;
    
    [self.paperTable registerClass:[QuestsListCell class] forCellReuseIdentifier:@"Question"];
    [self.view addSubview:navigationView];
    [self.view addSubview:_paperTable];
    
}

- (void)initWithData {
    self.papersList = [NSMutableArray array];
    [QuestionPaper requestPaperListCompletion:^(NSArray *array, NSString *mesg) {
            self.papersList = [array copy];
            [self.paperTable reloadData];
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.papersList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [QuestsListCell computeQuestsListCellHeightWith:[self.papersList objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Question"];
    cell.displayStyle = QuestsListDisplayStyleHidden;
    cell.paper = [self.papersList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AnswerQuestionsController *answerVC = [[AnswerQuestionsController alloc] init];
    answerVC.quesPaper = [self.papersList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:answerVC animated:YES];
}

@end
