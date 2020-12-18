//
//  WorkSheetViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "WorkSheetViewController.h"
#import "WSRightMasterView.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UserDoc.h"
#import "NSDate+Convert.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "NSString+Additional.h"
#import "TDArrow.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "AppDelegate.h"
#import "OrderDetailViewController.h"
#import "GPBHTTPClient.h"
#import "DFChooseAlertView.h"
#import "DFTableCell.h"
#import "Tags.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "UIButton+InitButton.h"

@interface WorkSheetViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *getAccountListOpeation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestUpdateTreatmentOperation;
@property (nonatomic, weak) AFHTTPRequestOperation *requestGroupList;

@property (strong, nonatomic) WSLeftMasterView *leftMasterView;
@property (strong, nonatomic) WSRightMasterView *rightMasterView;

@property (strong, nonatomic) NavigationView *naviView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UILabel *selectedInfoLabel;

@property (strong, nonatomic) TDArrow *scaleView;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) NSMutableArray *userList;
@property (strong, nonatomic) NSMutableArray *userList_Selected;

@property (strong, nonatomic) NSMutableOrderedSet *departmentSet;
@property (strong, nonatomic) NSString *department_Selected; // 部门搜索


@property (strong, nonatomic) NSString *workSheetDate; // yyyy-MM-dd
@property (strong, nonatomic) NSString *workSheetTime; // hh:mm
@property (assign, nonatomic) CGFloat initialTVHeight;

@property (assign, nonatomic) int type;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) BOOL isShowDatePicker;

@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, copy) NSString *tagIDs;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@end

@implementation WorkSheetViewController
@synthesize leftMasterView;
@synthesize rightMasterView;
@synthesize selected_UserArray;
@synthesize multipleSelection;
@synthesize searchBar;
@synthesize naviView;
@synthesize type;
@synthesize isSearching;
@synthesize departmentSet;
@synthesize userList;
@synthesize department_Selected;
@synthesize userList_Selected;
@synthesize datePicker;
@synthesize isShowDatePicker;
@synthesize delegate;
@synthesize scaleView;
@synthesize selectedInfoLabel;
@synthesize workSheetDate, workSheetTime, wsDate;
//@synthesize treatment;
@synthesize customerId;
@synthesize orderId;
@synthesize groupArray;
@synthesize tagIDs;


- (NSString *)tagIDs {
    if ([self.groupArray count]) {
        NSMutableString *string = [NSMutableString string];
        [self.groupArray enumerateObjectsUsingBlock:^(Tags *obj, NSUInteger idx, BOOL *stop) {
            if (obj.isChoose) {
                [string appendFormat:@"|%ld", (long)obj.tagID];
            }
        }];
        [string appendString:@"|"];
        return [string copy];
    } else {
        return @"";
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kColor_Background_View;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getAccountListOpeation && [_getAccountListOpeation isExecuting]) {
        [_getAccountListOpeation cancel];
    }
    
    if (_requestUpdateTreatmentOperation && [_requestUpdateTreatmentOperation isExecuting]) {
        [_requestUpdateTreatmentOperation cancel];
    }
    
    _getAccountListOpeation = nil;
    _requestUpdateTreatmentOperation = nil;
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor_Background_View;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    department_Selected = @"全部";
    [self initLayout];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearch)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.groupArray = [NSMutableArray array];
    [self requestGroup];
}

- (void)initLayout
{
    // -- Header View
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, -44.0f, kSCREN_BOUNDS.size.width, 44.0f)];
    searchBar.tintColor = kColor_Background_View;
    searchBar.placeholder = @"来搜索你想要找的人吧!";
    searchBar.hidden = YES;
    searchBar.delegate = self;
    if ((IOS7 || IOS8)) searchBar.barTintColor = kColor_Background_View;
    [self.view addSubview:searchBar];
    
    // filterButton
    UIButton *filterButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(filterAction)
                                                 frame:CGRectMake( 310 - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"group_respon"]
                                      highlightedImage:nil];
    
    // search Button
    UIButton *searchButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(searchAction)
                                                 frame:CGRectMake(filterButton.frame.origin.x - HEIGHT_NAVIGATION_VIEW, 0, HEIGHT_NAVIGATION_VIEW, HEIGHT_NAVIGATION_VIEW)
                                         backgroundImg:[UIImage imageNamed:@"icon_Search"]
                                      highlightedImage:nil];
    
    naviView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, 5.0f) title:@"工作时间表"];
    [naviView addSubview:filterButton];
    [naviView addSubview:searchButton];
    [self.view addSubview:naviView];
    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;

    
    // -- Body
    
    float  view_Height = kSCREN_BOUNDS.size.height - 64.0f - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 50.0f;
    leftMasterView = [[WSLeftMasterView alloc] initWithFrame:CGRectMake(5.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 130.0f, view_Height)];
    leftMasterView.multipleSelection = multipleSelection; // 多选
    leftMasterView.dateStr = workSheetDate;
    leftMasterView.select_UserArray = [NSMutableArray arrayWithArray:selected_UserArray];
    leftMasterView.workSheetVC = self;
    leftMasterView.clipsToBounds = YES;
    [self.view addSubview:leftMasterView];
    
    rightMasterView = [[WSRightMasterView alloc] initWithFrame:CGRectMake(120.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 195.0f, view_Height)];
    rightMasterView.contentSize = CGSizeMake(24.0f * 24 + 1.0f, rightMasterView.frame.size.height);
    rightMasterView.bounces = NO;
    [self.view addSubview:rightMasterView];
    
    leftMasterView.wsLeftMasterDelegate = self;
    leftMasterView.wsDelegate= self;
    rightMasterView.wsDelegate = self;
    
    // -- scaleView
    scaleView = [[TDArrow alloc] initWithFrame:CGRectMake(rightMasterView.frame.origin.x - 10.0f, HEIGHT_NAVIGATION_VIEW + 5.0f + 2.0f, 20.0f, 200.0f)];
    [self.view addSubview:scaleView];
    [self initScaleViewPostion];
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.minimumNumberOfTouches = 1;
    [scaleView addGestureRecognizer:panRecognizer];
    
    // -- Footer View
    selectedInfoLabel = [UILabel initNormalLabelWithFrame:CGRectMake(leftMasterView.frame.origin.x, leftMasterView.frame.origin.y + leftMasterView.frame.size.height + 10.0f, 180.0f, 34.0f) title:@""];
    selectedInfoLabel.textAlignment = NSTextAlignmentCenter;
    selectedInfoLabel.font = kFont_Medium_14;
    selectedInfoLabel.textColor = kColor_DarkBlue;
    selectedInfoLabel.backgroundColor = [UIColor colorWithRed:168.0f/255.0f green:222.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
    [self.view addSubview:selectedInfoLabel];
    [self setSelectedInfoText];
    
    
     UIButton *confirmButton = [UIButton buttonWithTitle:@"确定" target:self selector:@selector(confirmAction) frame:CGRectMake(selectedInfoLabel.frame.origin.x + selectedInfoLabel.frame.size.width + 10.0f, selectedInfoLabel.frame.origin.y , 120.0f , 34.0f) backgroundImg:ButtonStyleBlue];
     [self.view addSubview:confirmButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:)   name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Action Method

- (void)dismissSearch
{
    [searchBar resignFirstResponder];
    [self dismissDatePicker];
}

- (void)filterAction
{
    
    
    NSArray *array = @[@"取消",@"清除",@"确定"];
    
    NSMutableArray *chooseArray = [NSMutableArray array];
    [self.groupArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [chooseArray addObject:[obj copy]];
    }];
    
    DFChooseAlertView *alertView = [DFChooseAlertView DFchooseAlterTitle:@"  分组选择" numberOfRow:chooseArray.count ChooseCells:^UITableViewCell *(DFChooseAlertView *alert, NSIndexPath *indexPath) {
        static NSString *groupCell = @"groupCell";
        DFTableCell *chooseCell = [alert.table dequeueReusableCellWithIdentifier:groupCell];
        if (!chooseCell) {
            chooseCell = [[DFTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCell];
            chooseCell.textLabel.font = kFont_Light_18;
            chooseCell.selectionStyle = UITableViewCellSelectionStyleNone;
            chooseCell.textLabel.textColor = kColor_Black;
        }
        Tags *tag = chooseArray[indexPath.row];
        chooseCell.textLabel.text = tag.Name;
        chooseCell.imageView.image = (tag.isChoose ? [UIImage imageNamed:@"icon_Checked"]:[UIImage imageNamed:@"icon_unChecked"]);
        __weak DFTableCell *weakCell = chooseCell;
        chooseCell.layoutBlock = ^{
            weakCell.textLabel.frame = CGRectMake(9.0f, 9.0f, 200.0f, 20.0f);
            weakCell.imageView.frame = CGRectMake(225.0f, 2.0f, 36.0f, 36.0f);
        };
        return chooseCell;
        
    } selectionBlock:^(DFChooseAlertView *alert, NSIndexPath *selectedIndex) {
        Tags *tag = chooseArray[selectedIndex.row];
        tag.isChoose = !tag.isChoose;
        [alert.table reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationNone];
        
    } buttonsArray:array andClickButtonIndex:^(DFChooseAlertView *alert, UIButton *button, NSInteger index) {
        if (index == 0 || index == 2) {
            if (index == 2) {
                self.groupArray = [chooseArray mutableCopy];
                [leftMasterView.select_UserArray removeAllObjects];
                [self setSelectedInfoText];
                [self requestAccountListByDate];
            }
            [alert animateOut];
        } else {
            [chooseArray enumerateObjectsUsingBlock:^(Tags *obj, NSUInteger idx, BOOL *stop) {
                obj.isChoose = NO;
            }];
            [alert.table reloadData];
        }
        NSLog(@"the selectedIndex is %zd", index);
    }];
    
    [alertView show];

    
    
    
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"筛选";
    [actionSheet addButtonWithTitle:@"全部"];
    for (NSString *str in departmentSet) {
        [actionSheet addButtonWithTitle:str];
    }
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"取消"]];
    [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        NSString *str = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (![str isEqualToString:@"取消"]) {
            department_Selected = str;
            [self requestAndSortByDepartmentWithRefresh:NO];
        }
    }];
     */
}
#pragma mark - Keyboard Notification

-(void)keyboardDidShown:(NSNotification*)notification
{
    CGRect initialFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3f];
    CGRect tvFrame = leftMasterView.lTableView.frame;
    tvFrame.size.height = _initialTVHeight - initialFrame.size.height + 50.0f;
    leftMasterView.lTableView.frame = tvFrame;
    tvFrame.size.width = rightMasterView.rTableView.frame.size.width;
    rightMasterView.rTableView.frame = tvFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHidden:(NSNotification*)notification
{
    CGRect tvFrame = leftMasterView.lTableView.frame;
    tvFrame.size.height = _initialTVHeight;
    leftMasterView.lTableView.frame = tvFrame;
    tvFrame.size.width = rightMasterView.rTableView.frame.size.width;
    rightMasterView.rTableView.frame = tvFrame;
}

- (void)searchAction
{
    if (searchBar.isHidden) {
        searchBar.hidden = NO;
        // isSearching = YES;
        [UIView beginAnimations:@"" context:nil];
        searchBar.frame = CGRectMake(0.0f, 0, kSCREN_BOUNDS.size.width, 44.0f);
        
        CGRect rect_nav = naviView.frame;
        rect_nav.origin.y = searchBar.frame.origin.y + searchBar.frame.size.height;
        naviView.frame = rect_nav;
        
        CGRect rect_left = leftMasterView.frame;
        rect_left.origin.y += 44.0f;
        rect_left.size.height -= 44.0f;
        leftMasterView.frame = rect_left;
        rect_left = leftMasterView.lTableView.frame;
        rect_left.size.height -= 44.f;
        leftMasterView.lTableView.frame = rect_left;
        
        CGRect rect_right = rightMasterView.frame;
        rect_right.origin.y += 44.0f;
        rect_right.size.height -= 44.0f;
        rightMasterView.frame = rect_right;
        rect_right = rightMasterView.rTableView.frame;
        rect_right.size.height -= 44.f;
        rightMasterView.rTableView.frame = rect_right;
        rightMasterView.contentSize = CGSizeMake(24.0f * 24 + 1.0f, rightMasterView.frame.size.height);
        
        CGRect rect_scaleView = scaleView.frame;
        rect_scaleView.origin.y += 44.f;
        scaleView.frame = rect_scaleView;
        _initialTVHeight = leftMasterView.lTableView.frame.size.height;
        [UIView commitAnimations];
    } else {
        [searchBar resignFirstResponder];  searchBar.text = @"";
        searchBar.hidden = YES;
        isSearching = NO;
        
        [UIView beginAnimations:@"" context:nil];
        CGRect rect_nav = naviView.frame;
        rect_nav.origin.y = 5.0f;
        naviView.frame = rect_nav;
        
        leftMasterView.frame  = CGRectMake(5.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 130.0f, kSCREN_BOUNDS.size.height - 64.0f - HEIGHT_NAVIGATION_VIEW - 50.0f -5.0f);
        leftMasterView.lTableView.frame = CGRectMake(0, 0, leftMasterView.frame.size.width, leftMasterView.frame.size.height);
        rightMasterView.frame = CGRectMake(120.0f, HEIGHT_NAVIGATION_VIEW + 5.0f, 195.0f, kSCREN_BOUNDS.size.height - 64.0f - HEIGHT_NAVIGATION_VIEW - 50.0f - 5.0f);
        rightMasterView.rTableView.frame = CGRectMake(0, 0, rightMasterView.rTableView.frame.size.width, rightMasterView.frame.size.height);
        rightMasterView.contentSize = CGSizeMake(24.0f * 24 + 1.0f, rightMasterView.frame.size.height);
        
        CGRect rect_scaleView = scaleView.frame;
        rect_scaleView.origin.y = 43.f;
        scaleView.frame = rect_scaleView;
        _initialTVHeight = leftMasterView.lTableView.frame.size.height;
        
        [UIView commitAnimations];
    }
}
- (void)confirmAction
{
    if ([leftMasterView.select_UserArray count] == 0 && self.chooseType == 2) {
        [SVProgressHUD showSuccessWithStatus2:@"请选择服务人员" touchEventHandle:^{}];
        return;
    }
    
    NSDate *currentDate =  [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate])+8*3600];

    NSDate *start = [[NSDate  alloc ]initWithTimeIntervalSinceReferenceDate:([[NSDate stringToDate:[NSString stringWithFormat:@"%@ %@", workSheetDate, workSheetTime] dateFormat:@"yyyy-MM-dd HH:mm"] timeIntervalSinceReferenceDate])+8*3600];
    

    if (!start || !currentDate || [currentDate compare:start] == NSOrderedDescending) {
        [SVProgressHUD showErrorWithStatus2:@"预约时间早于当前时间！" touchEventHandle:^{}];
        return;
    }

//    UserDoc *userDoc = [[UserDoc alloc] init];
//    userDoc = (UserDoc *)[leftMasterView.select_UserArray firstObject];
//    [self requestUpdateTreatmentWithTreatmentAndScheduleTime:[NSString stringWithFormat:@"%@ %@", workSheetDate, workSheetTime] andExecutorID:userDoc.user_Id];
    
    if ([delegate respondsToSelector:@selector(dismissViewController:userArray:dateStr:)]) {
        [delegate dismissViewController:self userArray:leftMasterView.select_UserArray dateStr:[NSString stringWithFormat:@"%@ %@", workSheetDate, workSheetTime]];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

#pragma mark - Set Method

- (void)setWsDate:(NSDate *)nwsDate
{
    wsDate = nwsDate;
    
    NSArray *array = [[NSDate dateToString:wsDate dateFormat:@"yyyy-MM-dd||HH:mm"] componentsSeparatedByString:@"||"];
    workSheetDate = [array objectAtIndex:0];
    workSheetTime = [array objectAtIndex:1];
    
    [self requestAndSortByDepartmentWithRefresh:YES];
}

- (void)setMultipleSelection:(BOOL)newmultipleSelection
{
    multipleSelection = newmultipleSelection;
    leftMasterView.multipleSelection = multipleSelection;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - selected time

- (void)setSelectedInfoText
{
    [self calculateWorkSheetTime];
    
    if (multipleSelection == NO && [leftMasterView.select_UserArray count] > 0) {
        UserDoc *userDoc = [leftMasterView.select_UserArray firstObject];
        selectedInfoLabel.text = [NSString stringWithFormat:@"%@ %@ %@", [userDoc.user_Name length] == 0 ? @"" : userDoc.user_Name, workSheetDate, workSheetTime];
    } else {
        selectedInfoLabel.text = [NSString stringWithFormat:@"%@ %@", workSheetDate, workSheetTime];
    }
}

- (void)calculateWorkSheetTime
{
    float time = (rightMasterView.contentOffset.x + scaleView.frame.origin.x  + scaleView.frame.size.width/2.0f  - 120.0f) / kWSPrecision;
    int hour = (int)time;
    int minu = (int)((time - hour) * 60.0f);
    
    int min_mod = minu % 5;
    int min_new = minu / 5 * 5 + (min_mod < 2.5 ? 0 : 1) * 5;
    
    if (min_new == 60) {
        hour += 1;
        min_new = 0;
    }
    workSheetTime = [NSString stringWithFormat:@"%@:%@",
                     hour    < 10 ? [NSString stringWithFormat:@"0%d", hour] : [NSString stringWithFormat:@"%d", hour] ,
                     min_new < 10 ? [NSString stringWithFormat:@"0%d", min_new] : [NSString stringWithFormat:@"%d", min_new]];

}

- (void)initScaleViewPostion
{
    NSArray *array = [workSheetTime componentsSeparatedByString:@":"];
    int hour = [[array objectAtIndex:0] intValue];
    int minu = [[array objectAtIndex:1] intValue];
    
    const int extra_hour = 1;
    if (hour < 16) {
        if (hour > extra_hour) {
            float pix_ScrollView =  ((hour - extra_hour) * 60 + minu) * (kWSPrecision / 60.0f);
            [rightMasterView setContentOffset:CGPointMake(pix_ScrollView, 0) animated:YES];
            
            float pix_ScaleView = extra_hour * 60 * (kWSPrecision / 60.0f);
            CGRect rect = scaleView.frame;
            rect.origin.x += pix_ScaleView;
            scaleView.frame = rect;
        } else {
            float pix_ScaleView = (hour * 60 + minu) * (kWSPrecision / 60.0f);
            CGRect rect = scaleView.frame;
            rect.origin.x += pix_ScaleView;
            scaleView.frame = rect;
        }
    } else {
        float pix_ScrollView =  16 * 60 * (kWSPrecision / 60.0f);
        [rightMasterView setContentOffset:CGPointMake(pix_ScrollView, 0) animated:YES];
        
        float pix_ScaleView = ((hour - 16 ) * 60 + minu) * (kWSPrecision / 60.0f);
        CGRect rect = scaleView.frame;
        rect.origin.x += pix_ScaleView;
        scaleView.frame = rect;
    }
}


#pragma mark - UIPanGesture Method

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    float scaleView_W = kWSPrecision * 8;
    float new_x0 = MIN(scaleView.frame.origin.x + translation.x, 120.0f + scaleView_W - recognizer.view.frame.size.width/2);
    float new_x1 = MAX(new_x0, 120.0f - recognizer.view.frame.size.width/2);
    CGRect newFrame = CGRectMake(new_x1, recognizer.view.frame.origin.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
    recognizer.view.frame = newFrame;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    [self setSelectedInfoText];
}

#pragma mark - WSScrollViewDelegate

-(void)WSScrollViewDidScroll:(UIScrollView *)WSScrollView
{
    if (WSScrollView == leftMasterView.lTableView) {
        [rightMasterView.rTableView setContentOffset:CGPointMake(rightMasterView.rTableView.contentOffset.x, WSScrollView.contentOffset.y)];
    } else if (WSScrollView == rightMasterView.rTableView) {
        
        [leftMasterView.lTableView setContentOffset:CGPointMake(leftMasterView.lTableView.contentOffset.x, WSScrollView.contentOffset.y)];
    } else if (WSScrollView == rightMasterView) {
       [self setSelectedInfoText];
    }
}

#pragma mark - WSLeftMasterViewDelegate

- (void)leftMasterView:(WSLeftMasterView *)view didChangeDate:(NSDate *)date
{
    department_Selected = @"全部";
    workSheetDate = [NSDate dateToString:date dateFormat:@"yyyy-MM-dd"];
    [self requestAndSortByDepartmentWithRefresh:YES];
    
    [self setSelectedInfoText];
}

- (void)displayDatePickerInLeftMasterView:(WSLeftMasterView *)view
{
    if(!datePicker) {
        isShowDatePicker = NO;
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        [datePicker setDate:[NSDate date]];
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        datePicker.backgroundColor = [UIColor whiteColor];
        CGSize size = [datePicker sizeThatFits:CGSizeMake(320.0f, 400.0f)];
        datePicker.frame = CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f, size.width, size.height);
        datePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:datePicker];
    }
    
    if (!isShowDatePicker)
        [self showDatePicker];
    else
        [self dismissDatePicker];
}

- (void)showDatePicker
{
    isShowDatePicker = YES;
    datePicker.date = [NSDate stringToDate:workSheetDate dateFormat:@"yyyy-MM-dd"];
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3f];
    datePicker.transform = CGAffineTransformMakeTranslation(0.0f, -datePicker.bounds.size.height);
    [UIView commitAnimations];
}

- (void)dismissDatePicker
{
    isShowDatePicker = NO;
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3f];
    datePicker.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void)dateChanged:(UIDatePicker *)picker
{
    NSString *date =  [NSDate dateToString:picker.date dateFormat:@"yyyy-MM-dd"];
    leftMasterView.dateStr = date;
    workSheetDate = date;
    [self setSelectedInfoText];
    [self requestAndSortByDepartmentWithRefresh:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0) {
        isSearching = YES;
        [self refreshSelectedUserList:searchText];
        
        [leftMasterView setUserArray:userList_Selected];
        [rightMasterView setUserArray:userList_Selected];
    } else {
        [self.searchBar resignFirstResponder];
        [userList_Selected removeAllObjects];
        [leftMasterView setUserArray:userList];
        [rightMasterView setUserArray:userList];
    }
}

- (void)refreshSelectedUserList:(NSString *)keyword
{
    if (userList_Selected) {
        [userList_Selected removeAllObjects];
    } else {
        userList_Selected = [NSMutableArray array];
    }
    NSString *string = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    for (UserDoc *us in userList) {
        if ([us.user_Name containsString:string] ||
            [us.user_QuanPinYin containsString:string] ||
            [us.user_ShortPinYin containsString:string] ||
            [us.user_Code containsString:string])
        {
            [userList_Selected addObject:us];
        }
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    const char * ch=[text cStringUsingEncoding:NSUTF8StringEncoding];
    if (*ch == 0) return YES;
    if (*ch == 32) return NO;
    
    return YES;
}

#pragma mark - 接口

- (void)requestAndSortByDepartmentWithRefresh:(BOOL)isRefresh
{
    if (isRefresh) {
        [self requestAccountListByDate];
    } else {
        if (!userList) [self requestAccountListByDate];
    }
    
    // --leftMasterView、rightMasterView赋值 navigationView.titleLabel赋值
    if ([department_Selected isEqualToString:@"全部"]) {
        [leftMasterView setUserArray:userList];
        [rightMasterView setUserArray:userList];
        
        naviView.titleLabel.text = @"工作时间表";
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (UserDoc *us in userList) {
            if ([us.user_Department isEqualToString:department_Selected]) {
                [array addObject:us];
            }
        }
        [leftMasterView setUserArray:array];
        [rightMasterView setUserArray:array];
        
        naviView.titleLabel.text = [NSString stringWithFormat:@"工作时间表(%@)",department_Selected];
    }
    
    // --scaleView布局
    if ([leftMasterView.userArray count] > 0) {
        scaleView.hidden = NO;
        float tableHeight = self.rightMasterView.rTableView.frame.size.height;
        float dataHeight  = kWSHeight_TitleCell + kWSHeight_NormalCell * [leftMasterView.userArray count];
        if (dataHeight > tableHeight) {
            CGRect scaleView_frame = scaleView.frame;
            scaleView_frame.size.height = tableHeight - 2.0f;
            scaleView.frame = scaleView_frame;
        } else {
            CGRect scaleView_frame = scaleView.frame;
            scaleView_frame.size.height = dataHeight -2.0f;
            scaleView.frame = scaleView_frame;
        }
        [scaleView setNeedsDisplay];
    } else {
        scaleView.hidden = YES;
    }
}
#pragma mark 请求分组
- (void)requestGroup {
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Type\":2}", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    _requestGroupList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Tag/getTagList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.groupArray addObject:[[Tags alloc] initWithDictionary:obj]];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestAccountListByDate
{
    if ([workSheetDate length] == 0) return;
    
    NSString *par = [NSString stringWithFormat:@"{\"CompanyID\":%ld,\"BranchID\":%ld,\"Date\":\"%@\",\"TagIDs\":\"%@\"}", (long)ACC_COMPANTID, (long)ACC_BRANCHID, workSheetDate, self.tagIDs];

    _getAccountListOpeation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Account/getAccountSchedule" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (userList) {
                [userList removeAllObjects];
            } else {
                userList = [NSMutableArray array];
            }
            
            if (departmentSet) {
                [departmentSet removeAllObjects];
            } else {
                departmentSet = [[NSMutableOrderedSet alloc] init];
            }
            for (NSDictionary *dictionary in data) {
                UserDoc *user = [[UserDoc alloc] init];
                user.user_Id = [[dictionary objectForKey:@"AccountID"] integerValue];
                user.user_Name = [dictionary objectForKey:@"AccountName"];
                user.user_Code = [dictionary objectForKey:@"AccountCode"];
                user.user_ShortPinYin = [dictionary objectForKey:@"PinYinFirst"];
                user.user_QuanPinYin = [dictionary objectForKey:@"PinYin"];
                user.user_ShortPinYin = [dictionary objectForKey:@"PinYinFirst"];
//                NSString *department = [dictionary objectForKey:@"Department"];
                
//                if (department.length == 0) {
//                    department = @"其他";
//                }
//                user.user_Department = department;
//                [departmentSet addObject:department];
//                
                NSMutableArray *schArray = [NSMutableArray array];
                for (NSDictionary *sch in [dictionary objectForKey:@"ScheduleList"]) {
                    workTime wt;
                    
                    int hourStartTime = [[[sch objectForKey:@"ScdlStartTime"]substringWithRange:NSMakeRange(11,2) ] intValue];
                    int hourEndTime = [[[sch objectForKey:@"ScdlEndTime"]substringWithRange:NSMakeRange(11,2) ] intValue];
                    int minitStarTime = [[[sch objectForKey:@"ScdlStartTime"]substringWithRange:NSMakeRange(14,2) ] intValue];
                    int minitEndTime = [[[sch objectForKey:@"ScdlEndTime"]substringWithRange:NSMakeRange(14,2) ] intValue];
                    
                    wt.startTime = hourStartTime*60 +minitStarTime;
                    wt.duration = ( hourEndTime*60+minitEndTime)-wt.startTime;
                    
                    [schArray addObject:[NSValue value:&wt withObjCType:@encode(workTime)]];
                }
                user.worktimeArray = schArray;
                [userList addObject:user];
                
                
            }
            [self requestAndSortByDepartmentWithRefresh:NO];

        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
    
    }];
    
    /*
    _getAccountListOpeation = [[GPHTTPClient shareClient] requestGetAccountListViaJsonWithDate:workSheetDate success:^(id xml) {
        
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data ,id message) {
            if (userList) {
                [userList removeAllObjects];
            } else {
                userList = [NSMutableArray array];
            }
            
            if (departmentSet) {
                [departmentSet removeAllObjects];
            } else {
                departmentSet = [[NSMutableOrderedSet alloc] init];
            }
            for (NSDictionary *dictionary in data) {
                UserDoc *user = [[UserDoc alloc] init];
                user.user_Id = [[dictionary objectForKey:@"AccountID"] integerValue];
                user.user_Name = [dictionary objectForKey:@"AccountName"];
                user.user_Code = [dictionary objectForKey:@"AccountCode"];
                user.user_ShortPinYin = [dictionary objectForKey:@"PinYinFirst"];
                user.user_QuanPinYin = [dictionary objectForKey:@"PinYin"];
                user.user_ShortPinYin = [dictionary objectForKey:@"PinYinFirst"];
                NSString *department = [dictionary objectForKey:@"Department"];
                
                if (department.length == 0) {
                    department = @"其他";
                }
                user.user_Department = department;
                [departmentSet addObject:department];
                
                NSMutableArray *schArray = [NSMutableArray array];
                for (NSDictionary *sch in [dictionary objectForKey:@"ScheduleList"]) {
                    workTime wt;
                    wt.startTime = [[sch objectForKey:@"ScheduleTime"] intValue];
                    wt.duration  = [[sch objectForKey:@"SpendTime"] intValue];
//                    wt.name =  [[sch objectForKey:@"SpendTime"] cStringUsingEncoding:NSUTF8StringEncoding];
                    [schArray addObject:[NSValue value:&wt withObjCType:@encode(workTime)]];
                }
                user.worktimeArray = schArray;
                [userList addObject:user];
                
                [self requestAndSortByDepartmentWithRefresh:NO];
            }
        } failure:^(NSString *error) {
        }];
        */
        
//        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
//            
//            if (userList) {
//                [userList removeAllObjects];
//            } else {
//                userList = [NSMutableArray array];
//            }
//            
//            if (departmentSet) {
//                [departmentSet removeAllObjects];
//            } else {
//                departmentSet = [[NSMutableOrderedSet alloc] init];
//            }
//            
//            for (GDataXMLElement *ele in [contentData elementsForName:@"Account"]) {
//                UserDoc *user = [[UserDoc alloc] init];
//                user.user_Id  =  [[[[ele elementsForName:@"AccountID"] objectAtIndex:0] stringValue] integerValue];
//                user.user_Name = [[[ele elementsForName:@"AccountName"] objectAtIndex:0] stringValue];
//                user.user_Code = [[[ele elementsForName:@"AccountCode"] objectAtIndex:0] stringValue];
//                user.user_ShortPinYin = [[[ele elementsForName:@"PinYinFirst"] objectAtIndex:0] stringValue];
//                user.user_QuanPinYin  = [[[ele elementsForName:@"PinYin"] objectAtIndex:0] stringValue];
//                NSString *department = [[[ele elementsForName:@"Department"] objectAtIndex:0] stringValue];
//                
//                if (department.length == 0) {
//                  department = @"其他";
//                }
//                user.user_Department = department;
//                
//                [departmentSet addObject:department];
//                
//                NSMutableArray *schArray = [NSMutableArray array];
//                for (GDataXMLElement *sch in [ele elementsForName:@"Schedule"]) {
//                    workTime wt;
//                    wt.startTime = [[[[sch elementsForName:@"ScheduleTime"] objectAtIndex:0] stringValue] intValue];
//                    wt.duration  = [[[[sch elementsForName:@"SpendTime"] objectAtIndex:0] stringValue] intValue];
//                    [schArray addObject:[NSValue value:&wt withObjCType:@encode(workTime)]];
//                }
//                user.worktimeArray = schArray;
//                [userList addObject:user];
//            }
//        
//            [self requestAndSortByDepartmentWithRefresh:NO];
//            
//        } failure:^{}];
        
//    } failure:^(NSError *error) {}];
}

// updateTreatmentDetail
- (void)requestUpdateTreatmentWithTreatmentAndScheduleTime:(NSString *)time andExecutorID:(NSInteger)executorId
{
    if (self.ReservedOrderType ==2 ) {
        self.orderId = 0 ;
        self.orderObjectId = 0 ;
    }
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary * par = @{
                           @"ExecutorID":@((long)executorId),
                           @"TaskType":@(1),
                           @"TaskScdlStartTime":time,
                           @"ReservedOrderType":@((long)self.ReservedOrderType),
                           @"TaskOwnerID":@((long)customerId),
                           @"ReservedOrderID":@((long)self.orderId),
                           @"ReservedOrderServiceID":@((long)self.orderObjectId),
                           @"ReservedServiceCode":@((long long)self.orderServiceCode)
                           };
    
    _requestUpdateTreatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/AddSchedule" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message){
            [SVProgressHUD showSuccessWithStatus2:@"预约成功" duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        
        [SVProgressHUD dismiss];
    }];

    
    
   /*
    NSString *par = [NSString stringWithFormat:@"{\"OrderID\":%ld,\"CustomerID\":%ld,\"TreatmentID\":%ld,\"ScheduleID\":%ld,\"ScheduleTime\":\"%@\",\"ExecutorID\":%ld,\"UpdaterID\":%ld}", (long)self.orderId, (long)customerId, (long)treatmentDoc.treat_ID, (long)treatmentDoc.treat_Schedule.sch_ID, time, (long)executorId, (long)ACC_ACCOUNTID];
    
    
    _requestUpdateTreatmentOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/updateTreatmentDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD showSuccessWithStatus2:@"修改成功" duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    */

    /*
    _requestUpdateTreatmentOperation = [[GPHTTPClient shareClient] requestUpdateTreatmentWithTreatment:treatmentDoc OrderID:self.orderId andScheduleTime:time andExecutorID:executorId andCustomerID:customerId success:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:YES success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            [SVProgressHUD showSuccessWithStatus2:@"修改成功" duration:2.0 touchEventHandle:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^{}];
    } failure:^(NSError *error) {
    }];
     */
}

@end
