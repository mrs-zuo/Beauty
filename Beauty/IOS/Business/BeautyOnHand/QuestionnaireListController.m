//
//  QuestionnaireListViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "QuestionnaireListController.h"
#import "DFUITableView.h"
#import "NavigationView.h"
#import "QuestsListCell.h"
#import "QuestionPaper.h"
#import "SubjectListController.h"
#import "DFFilterSet.h"
#import "AppDelegate.h"
#import "PaperFilterController.h"
#import "CustomerPaperController.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h" 
#import "AnswerQuestionsController.h"
//wugang->
#import "UIAlertView+AddBlockCallBacks.h"
#import "GPBHTTPClient.h"
//<-wugang

@interface QuestionnaireListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) DFUITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *papersList;
@property (nonatomic, strong) DFFilterSet *paperFilter;
@property (nonatomic, strong) NavigationView *navigationView;
@property (nonatomic, assign) NSInteger     pageIndex;
@property (nonatomic, assign) NSInteger     pageCount;
@property (nonatomic, assign) NSInteger     paperCount;
//wugang->
@property (nonatomic, weak) AFHTTPRequestOperation *requestDeleteTreatment;
//<-wugang
@end

@implementation QuestionnaireListController
@synthesize listTableView;
@synthesize papersList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithView];
    [self initWithData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#pragma mark 权限--专业记录
#pragma mark  权限--专业记录
    AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appde.noteForOrder == 1) {
        if (appde.customer_Selected.editStatus & CustomerEditStatusPro) {
            [self.listTableView headerBeginRefreshing];
        }
    } else {
        [self.listTableView headerBeginRefreshing];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appde.noteForOrder == 1) {
        AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!(appde.customer_Selected.editStatus & CustomerEditStatusPro)) {
            [SVProgressHUD showSuccessWithStatus2:@"没有权限，不能查看专业记录!" duration:1.5 touchEventHandle:^{}];
        }
    }
}

#pragma mark 离开 处理
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestDeleteTreatment && [_requestDeleteTreatment isExecuting]) {
        [_requestDeleteTreatment cancel];
    }

    _requestDeleteTreatment = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)initWithView
{

    self.view.backgroundColor = kColor_Background_View;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"专业记录"];
    AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appde.noteForOrder == 0) { //左边
        [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterOpp)];
    } else {
#pragma mark  权限--专业记录
        AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ( appde.customer_Selected.editStatus & CustomerEditStatusPro) {
            [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_AddRecord"] selector:@selector(addAnswer)];
            [_navigationView addButton1WithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterOpp)];
        }
//        else {
//            [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterOpp)];
//        }
    }
    
    //        if ([[PermissionDoc sharePermission] rule_Record_Write]) { //有写权限
    //            [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_AddRecord"] selector:@selector(addAnswer)];
    //            [_navigationView addButton1WithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterOpp)];

    listTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, _navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    if (IOS7 || IOS8) {
        listTableView.frame = CGRectMake(5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        listTableView.frame = CGRectMake(-5.0f, _navigationView.frame.origin.y + _navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.separatorColor = kTableView_LineColor;
    
    [self.listTableView registerClass:[QuestsListCell class] forCellReuseIdentifier:@"Question"];
    [self.view addSubview:_navigationView];
    [self.view addSubview:listTableView];
    
    [self.listTableView addHeaderWithTarget:self action:@selector(HeaderRefresh)];
    [self.listTableView addFooterWithTarget:self action:@selector(FooterRefresh)];
}

- (void)initWithData {
    self.papersList = [NSMutableArray array];
    self.paperFilter = [[DFFilterSet alloc] init];
    
    self.pageIndex = 1;
     AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appde.noteForOrder == 1) {
        self.paperFilter.customerID = ((AppDelegate *)[UIApplication sharedApplication].delegate).customer_Selected.cus_ID;
    }
}

- (BOOL)checkPermissEdit
{
    AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appde.noteForOrder == 1) {
        
        if (!(appde.customer_Selected.editStatus & CustomerEditStatusPro)) {
            return NO;
        }
    }
    return YES;

}

- (void)HeaderRefresh
{
    if ([self checkPermissEdit] == NO) {
        [self.listTableView headerEndRefreshing];
        return;
    }
    if (self.listTableView.footerHidden) {
        self.listTableView.footerHidden = NO;
    }
    AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.pageIndex = 1;
    [QuestionPaper requestAnswerPaperList:self.paperFilter pageIndex:self.pageIndex date:@"" completion:^(NSArray *array, NSInteger pCount, NSInteger nCount, NSString *mesg) {
        
        [self.listTableView headerEndRefreshing];
        if (array) {
            self.pageCount = pCount;
            self.paperCount = nCount;
            [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",self.pageCount == 0 ? 0 : self.pageIndex, (long)self.pageCount]];
            
            if (appde.noteForOrder == 1) {
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"customerID = %ld", app.customer_Selected.cus_ID];
                NSArray *test = [app.paperStorageOfCustomer filteredArrayUsingPredicate:predicate];
                self.papersList = [test mutableCopy];
                [self.papersList addObjectsFromArray:[array copy]];
            } else {
                self.papersList = [array mutableCopy];
            }

            [self.listTableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
        }
    }];
}

- (void)FooterRefresh
{
    if ([self checkPermissEdit] == NO) {
        [self.listTableView footerEndRefreshing];
        return;
    }
    if (self.pageIndex >= self.pageCount) {
        [self.listTableView footerEndRefreshing];
        self.listTableView.footerHidden = YES;
        [SVProgressHUD showSuccessWithStatus2:@"没有更多数据了" duration:kSvhudtimer touchEventHandle:^{}];
    } else {
        self.pageIndex++;
        QuestionPaper *questPaper = [self.papersList firstObject];
        [QuestionPaper requestAnswerPaperList:self.paperFilter pageIndex:self.pageIndex date:questPaper.UpdateTime completion:^(NSArray *array, NSInteger pCount, NSInteger nCount, NSString *mesg) {
            [self.listTableView footerEndRefreshing];
            if (array) {
                self.pageCount = pCount;
                self.paperCount = nCount;
                [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",
                                                         self.pageCount == 0 ? 0 : self.pageIndex, (long)self.pageCount]];
                [self.papersList addObjectsFromArray:[array copy]];
                [self.listTableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus2:mesg touchEventHandle:^{}];
            }
        }];
    }
}

- (void)addAnswer
{
    CustomerPaperController *cusPaper = [[CustomerPaperController alloc] init];
    [self.navigationController pushViewController:cusPaper animated:YES];
}

- (void)filterOpp
{
    PaperFilterController *paper = [[PaperFilterController alloc] init];
    paper.supFilter = self.paperFilter;
    [self.navigationController pushViewController:paper animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    cell.paper = [self.papersList objectAtIndex:indexPath.row];
    //wugang->
    //专业记录删除功能
    //NSInteger delGroupID = cell.paper.GroupID;
    cell.delegate = self;
    cell.delRecord = ^(){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否删除此专业记录？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *par = [NSString stringWithFormat:@"{\"GroupID\":%ld,}", (long)cell.paper.GroupID];
                //NSString *par = [NSString stringWithFormat:@"{\"GroupID\":%ld,}", (long)delGroupID];
                _requestDeleteTreatment = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Paper/DelAnswer" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
                    [self parserJsonData:json andComplete:NO];
                } failure:^(NSError *error) {
                }];
                [self.listTableView headerBeginRefreshing];
                [self.listTableView headerEndRefreshing];
            }
        }];
    };
    //<-wugang
    return cell;
}
//wugang->
- (void)parserJsonData:(id)data andComplete:(BOOL)isCompletion
{
    NSString *Message = [data objectForKey:@"Message"];
    NSInteger code = [[data objectForKey:@"Code"] integerValue];
    
    if(code == 1){
       [self.listTableView headerBeginRefreshing];
       [self.listTableView headerEndRefreshing];
    }
    else{
        if (code == -2 ) {
            [SVProgressHUD showErrorWithStatus2:Message duration:kSvhudtimer touchEventHandle:^{
                [self.listTableView headerBeginRefreshing];
                [self.listTableView headerEndRefreshing];
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus2:(Message.length == 0 ? @"操作失败" : Message) duration:kSvhudtimer touchEventHandle:^{
                [self.listTableView headerBeginRefreshing];
                [self.listTableView headerEndRefreshing];
            }];
        }
        
    }
}
//<-wugang

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QuestionPaper *paper = [self.papersList objectAtIndex:indexPath.row];
     AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (paper.PaperStatus == PaperStatusStorage && appde.noteForOrder == 1) {
        AnswerQuestionsController *answerVC = [[AnswerQuestionsController alloc] init];
        answerVC.quesPaper = paper;
        answerVC.questionIndex = 0;
        [self.navigationController pushViewController:answerVC animated:YES];
    } else {
        SubjectListController *subList = [[SubjectListController alloc] init];
        subList.quesPaper = paper;
        [self.navigationController pushViewController:subList animated:YES];
    }
}

@end
