//
//  NoteListController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "NoteListController.h"
#import "NavigationView.h"
#import "NoteViewCell.h"
#import "NormalEditCell.h"
#import "Note.h"
#import "UIButton+InitButton.h"
#import "EditNoteController.h"
#import "GPNavigationController.h"
#import "AFHTTPClient.h"
#import "GPHTTPClient.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "Tags.h"
#import "DFFilterSet.h"
#import "FRNViewController.h"
#import "GPBHTTPClient.h"

const CGFloat deletBtn_Width = 120;


#define DISPLAYWIDTH    150.0

typedef enum{
    REQUESTOLD = 0,
    REQUESTNEW = 1
}REQUESTTYPE;
@interface NoteListController ()<FRNViewDelegate,UIGestureRecognizerDelegate>
{
    NSIndexPath  *_longPressIndexPath;
    UIView *_delView;
}
@property (weak, nonatomic) AFHTTPRequestOperation *requestDeleteNotepadOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestNoteList;
@property (nonatomic, strong) UITableView *noteList;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) DFFilterSet *filterContent;
@property (nonatomic, strong) NavigationView *navigationView;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger noteCount;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) NSString *noteFileName;
@property (nonatomic, assign) BOOL      refresh;
@property (nonatomic ,assign) NSInteger viewForOder;
@end

@implementation NoteListController
@synthesize dataArray;
@synthesize filterContent;
@synthesize pageCount, noteCount, pageIndex;
@synthesize noteFileName;
@synthesize navigationView;

- (NSString *)noteFileName
{
    noteFileName = @"NoteFilter";
    return noteFileName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
    
    self.view.backgroundColor = kColor_Background_View;
 
    _viewForOder =  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder;
    self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:(kMenu_Type == 0 && _viewForOder== 0? @"与我相关的笔记" : @"笔记")];

    if (kMenu_Type == 0 && _viewForOder== 0) {
        UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(searchAction)
                                                     frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                             backgroundImg:[UIImage imageNamed:@"orderAdvancedFilterIcon"]
                                          highlightedImage:nil];
        
        [navigationView addSubview:searchButton];

    } else {
        UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(editAction)
                                                     frame:CGRectMake(314 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                             backgroundImg:[UIImage imageNamed:@"icon_AddRecord"]
                                          highlightedImage:nil];
        
        // search Button
        UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                    target:self
                                                  selector:@selector(searchAction)
                                                     frame:CGRectMake(CGRectGetMinX(filterButton.frame) - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                             backgroundImg:[UIImage imageNamed:@"orderAdvancedFilterIcon"]
                                          highlightedImage:nil];
#pragma mark 权限--顾客--笔记
        AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ( appde.customer_Selected.editStatus & CustomerEditStatusBasic) {
            [navigationView addSubview:filterButton];
            [navigationView addSubview:searchButton];
        }
    }
    
    ((GPNavigationController *)self.navigationController).canDragBack = YES;

    [self filterInit];
    
    _noteList = [[UITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height,kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    _noteList.delegate = self;
    _noteList.dataSource = self;
    _noteList.backgroundColor = [UIColor clearColor];
    _noteList.backgroundView = nil;
    _noteList.showsVerticalScrollIndicator = YES;
    _noteList.sectionHeaderHeight = 5.0;
    _noteList.sectionFooterHeight = 0.0;
    _noteList.autoresizingMask = UIViewAutoresizingNone;
    _noteList.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (IOS7 || IOS8) {
        _noteList.separatorInset = UIEdgeInsetsZero;
    }
    if (kMenu_Type == 0 && _viewForOder== 0) {
        _noteList.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height,kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) - 44 - 5);
    }else{
        _noteList.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height,kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) - 49 - 44 - 5);
    }
    [self.view addSubview:navigationView];
    [self.view addSubview:_noteList];
    [self.noteList addHeaderWithTarget:self action:@selector(HeardRefresh)];
    [self.noteList addFooterWithTarget:self action:@selector(FootRefresh)];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.refresh = YES;
    self.dataArray = [NSMutableArray array];
    
   
}

#pragma mark Filter init
- (void)filterInit
{
    self.filterContent = [[DFFilterSet alloc] init];
    if (kMenu_Type || (kMenu_Type==0 && _viewForOder== 1)) { //右侧菜单
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.filterContent.customerID = appDelegate.customer_Selected.cus_ID;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.refresh) {
        if (kMenu_Type == 1|| (kMenu_Type==0 && _viewForOder== 1)) {
#pragma mark 权限--顾客--笔记
            AppDelegate *appde = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ( appde.customer_Selected.editStatus & CustomerEditStatusBasic) {
                [self HeardRefresh];
            } else {
                [SVProgressHUD showSuccessWithStatus2:@"没有权限,不能查看笔记!" touchEventHandle:^{
                }];
            }
        } else {
            [self HeardRefresh];
        }
    } else {
        self.refresh = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"the view did Appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestNoteList && [_requestNoteList isExecuting]) {
        [_requestNoteList cancel];
    }
    _requestNoteList = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    if (_delView) {
        _delView = nil;
    }
    DLOG(@"NoteList viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Select
- (void)editAction
{
    EditNoteController *editController = [[EditNoteController alloc] init];
    ((GPNavigationController *)self.navigationController).canDragBack = YES;

    [self.navigationController pushViewController:editController animated:YES];
}

#pragma mark searchTag
- (void)searchAction
{
    ((GPNavigationController *)self.navigationController).canDragBack = YES;
    FRNViewController *frnView = [[FRNViewController alloc] init];
    frnView.supFilter = self.filterContent;
    frnView.filterTitle = @"笔记筛选";
    frnView.filePath = self.noteFileName;
    frnView.delegate = self;
    [self.navigationController pushViewController:frnView animated:YES];
}
#pragma mark FrnViewDelegate
- (void)didnotRefresh
{
    self.refresh = NO;
}

#pragma mark refresh
- (void)HeardRefresh
{
    if (self.noteList.footerHidden) {
        self.noteList.footerHidden = NO;
    }
    self.pageIndex = 1;
    [self reloadNoteWithID:0 Page:self.pageIndex Type:REQUESTNEW];
}

- (void)FootRefresh
{
    if (self.pageCount <= self.pageIndex || self.noteCount == self.dataArray.count){
        [self.noteList footerEndRefreshing];
        self.noteList.footerHidden = YES;
        [SVProgressHUD showSuccessWithStatus:@"没有更多数据了"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } else {
        self.pageIndex ++;
        Note *onte = [dataArray firstObject];
        [self reloadNoteWithID:onte.noteID Page:self.pageIndex Type:REQUESTOLD];
    }
}

#pragma mark noteList
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = dataArray[indexPath.section];

    if (indexPath.row == 1) {
        return note.height;
    }
    return 38.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Note *note = dataArray[indexPath.section];
    if (indexPath.row == 1) {
        static NSString *identifier = @"note";
        NoteViewCell *cell = [_noteList dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[NoteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
            [cell addGestureRecognizer:longPress];
        }
        [cell showAllContent:note];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *info = @"info";
    UITableViewCell *infoCell = [_noteList dequeueReusableCellWithIdentifier:info];
    if (!infoCell) {
        infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:info];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [infoCell addGestureRecognizer:longPress];
        
        infoCell.textLabel.frame = CGRectMake(5, (kTableView_HeightOfRow-20 )/2, 100, 20);
        infoCell.textLabel.textColor = kColor_DarkBlue;
        infoCell.textLabel.font = kFont_Light_16;
        infoCell.detailTextLabel.textColor = kColor_Editable;
        infoCell.detailTextLabel.font = kFont_Light_15;
        infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        
        UILabel *customer = [[UILabel alloc] init];
        customer.font = kFont_Light_15;
        customer.textColor = kColor_Editable;
        customer.lineBreakMode = NSLineBreakByTruncatingTail;
        customer.textAlignment = NSTextAlignmentRight;
        customer.backgroundColor = [UIColor clearColor];
        customer.tag = 100;
        
        UILabel *creater = [[UILabel alloc] init];
        creater.font = kFont_Light_15;
        creater.textColor = kColor_Editable;
        creater.lineBreakMode = NSLineBreakByTruncatingTail;
        creater.backgroundColor = [UIColor clearColor];
        creater.tag = 101;

        [infoCell.contentView addSubview:customer];
        [infoCell.contentView addSubview:creater];
        
        UILabel *timeLable = [[UILabel alloc] init];
        timeLable.frame = CGRectMake(5, (kTableView_HeightOfRow-20 )/2, 150, 20);
        timeLable.textColor = kColor_DarkBlue;
        timeLable.font = kFont_Light_16;
        [infoCell.contentView addSubview:timeLable];
        timeLable.tag =  201;
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 310, 0.5)];
        if (IOS6) {
            infoCell.backgroundColor = [UIColor whiteColor];

        } else {
            line.backgroundColor = [UIColor colorWithRed:235.f/255 green:235.f/255 blue:235.f/255 alpha:1.f];
            [infoCell.contentView addSubview:line];
        }
    }
    static NSString *title = @"title";
    UITableViewCell *label = [_noteList dequeueReusableCellWithIdentifier:title];
    
    if (!label) {
        label = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:title];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [label addGestureRecognizer:longPress];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"biaoqian"]];
        imageView.frame = CGRectMake(0, 4, 30, 30);
        UILabel *textLa = [[UILabel alloc] initWithFrame:CGRectMake(35, 9, 270, 20)];
        textLa.tag = 601;
        textLa.textColor = kColor_Editable;
        textLa.font = kFont_Light_14;
        textLa.backgroundColor = [UIColor clearColor];
        label.selectionStyle = UITableViewCellSelectionStyleNone;
        [label.contentView addSubview:imageView];
        [label.contentView addSubview:textLa];
        
        UILabel *lineOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 0.5)];
        UILabel *lineTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 310, 1)];
        if (IOS6) {
            label.backgroundColor = [UIColor whiteColor];
        } else {
            lineOne.backgroundColor =  [UIColor colorWithRed:235.f/255 green:235.f/255 blue:235.f/255 alpha:1.f];
            lineTwo.backgroundColor = [UIColor colorWithRed:235.f/255 green:235.f/255 blue:235.f/255 alpha:1.f];
            [label.contentView addSubview:lineOne];
            [label.contentView addSubview:lineTwo];
        }
    }
    if (indexPath.row == 0) {
       
        UILabel *timelable = (UILabel *)[infoCell.contentView viewWithTag:201];
        timelable.text = note.CreateTime;
        
        UILabel *customer = (UILabel *)[infoCell.contentView viewWithTag:100];
        UILabel *creater = (UILabel *)[infoCell.contentView viewWithTag:101];
        
        NSString *createrString = [NSString stringWithFormat:@"|%@", note.CreatorName];
        CGSize size = [createrString sizeWithFont:kFont_Light_15 forWidth:84 lineBreakMode:NSLineBreakByTruncatingTail];
        CGRect createrFrame = CGRectMake(305 - size.width, 9.0f, size.width, 20.0f);
        creater.frame = createrFrame;
        customer.frame = CGRectMake(305 - DISPLAYWIDTH , 9.0f, DISPLAYWIDTH - size.width, 20.0f);
        customer.text = note.CustomerName;
        creater.text = createrString;
        return infoCell;
    } else {
        UILabel *labe = (UILabel *)[label.contentView viewWithTag:601];
        labe.text = note.TagName;
        return label;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        NoteViewCell *cell = (NoteViewCell *)[_noteList cellForRowAtIndexPath:indexPath];
        Note *note = dataArray[indexPath.section];
        
        note.showContent = !note.showContent;
        [cell showAllContent:note];
        [_noteList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark endRefreshing Status
- (void)endRefreshOfNoteList:(REQUESTTYPE)type
{
    switch (type) {
        case REQUESTNEW:
            [self.noteList headerEndRefreshing];
            break;
        case REQUESTOLD:
            [self.noteList footerEndRefreshing];
            break;
    }
}


#pragma mark  - 手势
-(void)longPress:(UIGestureRecognizer *)ges
{
    DLOG(@"长按");
    if (kMenu_Type == 1 || (kMenu_Type==0 && _viewForOder== 1)) {
        if ([ges.view isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)ges.view;
            _longPressIndexPath = [_noteList indexPathForCell:cell];
            if (!_delView) {
                _delView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height)];
                _delView.backgroundColor = [UIColor blackColor];
                _delView.alpha = 0.7;
                UIButton *delBtn = [UIButton buttonWithTitle:@"删除该条笔记" target:self selector:@selector(deletBtn:) frame:CGRectMake((kSCREN_BOUNDS.size.width - 10 - deletBtn_Width) / 2, (kSCREN_BOUNDS.size.height - 64 - 49 - 44) / 2, deletBtn_Width, 44) backgroundImg:nil highlightedImage:nil];
                delBtn.backgroundColor = kColor_White;
                [delBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_delView addSubview:delBtn];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
                [_delView addGestureRecognizer:tap];
            }
            [self.view addSubview:_delView];
        }
    }
}
- (void)tap:(UIGestureRecognizer *)ges
{
    [_delView removeFromSuperview];
}
- (void)deletBtn:(UIButton *)sender
{
    if (dataArray) {
        Note *note = [dataArray objectAtIndex:_longPressIndexPath.section];
        [self requestDeleteNotePad:note];
    }
}
#pragma mark -接口
- (void)reloadNoteWithID:(NSInteger)noteID Page:(NSInteger)page Type:(REQUESTTYPE)type
{
    if ((kMenu_Type == 1 || (kMenu_Type==0 && _viewForOder== 1))&& ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID == 0 ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        [self endRefreshOfNoteList:type];
        return;
    }
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestNoteList = [Note requestFilter:self.filterContent NoteID:noteID PageIndex:page andPageSize:10 completionBlock:^(NSArray *array, NSInteger pagCount, NSInteger notCount, NSString *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            if (type == REQUESTNEW) {
                [dataArray removeAllObjects];
            }
            [dataArray addObjectsFromArray:array];
            self.pageCount = pagCount;
            self.noteCount = notCount;
            [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)(self.pageCount == 0 ? 0:page), (long)self.pageCount]];
            [self endRefreshOfNoteList:type];
            [self.noteList reloadData];
        } else {
            [self endRefreshOfNoteList:type];
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }
    }];
}

-(void)requestDeleteNotePad:(Note *)note
{
    //    /Notepad/deleteNotepad 删除笔记
    //    所需参数
    //    {"ID": 123456}
    //    返回参数
    //    {"Data":true,"Code":"1","Message":"删除记事本失败"}
    //    {"Data":false,"Code":"0","Message":"删除记事本失败"}
    [SVProgressHUD showWithStatus:@"Loading"];
    NSString *par = [NSString stringWithFormat:@"{\"ID\":%ld}",(long)note.noteID];
    _requestDeleteNotepadOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Notepad/deleteNotepad" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            if (code == 1) {
                [dataArray removeObjectAtIndex:_longPressIndexPath.section];
                if (dataArray.count == 0) {
                    self.pageCount = 0;
                    [self.navigationView setSecondLabelText:@"（第0/0页）"];
                }
                [self.noteList reloadData];
                [_delView removeFromSuperview];
            }else{
                DLOG(@"删除笔记失败");
                [SVProgressHUD showErrorWithStatus2:message touchEventHandle:^{}];
            }
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
    }];
    
}







@end
