//
//  CustomerLevelViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerLevelViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "LevelDateCell.h"
#import "LevelAddCell.h"
#import "LevelDoc.h"
#import "UILabel+InitLabel.h"
#import "NSDate+Convert.h"

#import "LevelDoc.h"
#import "DEFINE.h"

@interface CustomerLevelViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetLevelOperation;
@property (weak, nonatomic) AFHTTPRequestOperation *requestLevelOperation;

@property (strong, nonatomic) NSMutableArray *ctlLevelArray;    // 修改队列（包括所有添加，修改，删除的信息的队列）
@property (strong, nonatomic) NSMutableArray *showLevelArray;   // 显示队列（显示在界面上的信息的队列）
@property (strong, nonatomic) NSMutableArray *levelArray;       // 初始队列（后续不作修改）
@property (strong, nonatomic) NSMutableArray *endSendArray;     // 最终发送队列

@property (assign, nonatomic) NSInteger state;

@property (strong, nonatomic) NSString *levelIdString;
@property (strong, nonatomic) NSString *levelNameString;
@property (strong, nonatomic) NSString *levelDiscountString;
@property (strong, nonatomic) NSString *levelTagString;

@end

@implementation CustomerLevelViewController
@synthesize textView_Selected;
@synthesize levelDoc;
@synthesize levelArray;                                         
@synthesize ctlLevelArray, showLevelArray, endSendArray;
@synthesize state;
@synthesize levelDiscountString, levelIdString, levelNameString, levelTagString;
@synthesize text_Height,text_Y;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.allowsSelection = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    
    levelDiscountString = [[NSString alloc] init];
    levelIdString = [[NSString alloc] init];
    levelNameString = [[NSString alloc] init];
    levelTagString = [[NSString alloc] init];
    
    levelArray = [[NSMutableArray alloc] init];
    ctlLevelArray = [[NSMutableArray alloc] init];
    showLevelArray = [[NSMutableArray alloc] init];
    endSendArray = [[NSMutableArray alloc] init];
    
    [self requestLevelInfo];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 312.0f, 60.0f)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setFrame:CGRectMake(35.0f, 10.0f, 240.0f, 40.0f)];
    [submitBtn setBackgroundImage:[UIImage imageNamed:@"customer_AddButtonLong"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:submitBtn];
    _tableView.tableFooterView = footerView;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)dismissKeyBoard
{
    if (_tableView.frame.origin.y != 0) {
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        CGRect tableFrame = _tableView.frame;
        tableFrame.origin.y = 0;
        _tableView.frame = tableFrame;
        
        [_tableView setFrame:CGRectMake(5.0f, 38.0f, tableFrame.size.width, tableFrame.size.height)];
        [UIView commitAnimations];
    }
    [textView_Selected resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [showLevelArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == [showLevelArray count]) {
        return [self configLevelAddCell:tableView indexPath:indexPath];
    } else {        
        return [self configLevelDateCell:tableView indexPath:indexPath];
    }

}

// 配置OrderDateCell
- (LevelDateCell *)configLevelDateCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"LevelDateCell";
    LevelDateCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[LevelDateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.customerLevelViewController = self;
        cell.delegate = self;
    }
    
    LevelDoc *LevelDoc = [showLevelArray objectAtIndex:indexPath.row];
    [cell updateData:LevelDoc];
    
    return cell;
}

// 配置OrderAddCell
- (LevelAddCell *)configLevelAddCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = @"addCell";
    LevelAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell == nil) {
        cell = [[LevelAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.delegate = self;
    }
    [cell.promptLabel setText:@"添加新的等级分类"];
    
    cell.addButton.tag = indexPath.section;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

#pragma mark - LevelDateCellDelete && LevelAddCellDelegate

// 添加LevelDoc
- (void)chickAddButton:(UITableViewCell *)cell
{
    LevelDoc *sch = [[LevelDoc alloc] init];
    sch.ctlFlag = 1;
    sch.level_ID = -1;
    sch.level_Name = @"等级";
    sch.level_Discount = 0.00;
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    [ctlLevelArray addObject:sch];
    [showLevelArray addObject:sch];
    
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // 刷新index = 0
    NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:0 ];
    [_tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 删除LevelDoc
- (void)chickDeleteRowButton:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    LevelDoc *theSch = [showLevelArray objectAtIndex:indexPath.row];
    theSch.ctlFlag = 3;  
    if (theSch.level_ID == -1) {
        [ctlLevelArray removeObject:theSch];
    } else {
        [ctlLevelArray addObject:theSch];
    }
    
    [showLevelArray removeObject:theSch];
    
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)updateWithLevelDoc:(LevelDoc *)sch cell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [self sortArrayByDateWithSection:indexPath.section]; // 排序
}

#pragma mark - Custom Method
- (void)sortArrayByDateWithSection:(int)section
{
    [self sortCourseFArrayByDate];
}

- (void)sortCourseFArrayByDate
{
    for (int i= 0; i < [showLevelArray count]; i++) {
        for (int j= 0; j < [showLevelArray count] - i -1; j++) {
            int index1 = j;
            int index2 = j+1;
            LevelDoc *sch1 = [showLevelArray objectAtIndex:index1];
            LevelDoc *sch2 = [showLevelArray objectAtIndex:index2];
            if (sch1.level_Discount > sch2.level_Discount) {
                [showLevelArray replaceObjectAtIndex:index1 withObject:sch2];
                [showLevelArray replaceObjectAtIndex:index2 withObject:sch1];
            }
        }
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)submitBtnAction
{
    
    for (int i = 0; i < [levelArray count]; i++) {
        for (int j = 0; j < [showLevelArray count]; j++) {
            if (([[showLevelArray objectAtIndex:j] level_ID] == [[levelArray objectAtIndex:i] level_ID] && [[showLevelArray objectAtIndex:j] level_Discount] != [[levelArray objectAtIndex:i] level_Discount]) ||
                ([[showLevelArray objectAtIndex:j] level_ID] == [[levelArray objectAtIndex:i] level_ID] && [[showLevelArray objectAtIndex:j] level_Name] != [[levelArray objectAtIndex:i] level_Name]) ||
                ([[showLevelArray objectAtIndex:j] level_ID] == [[levelArray objectAtIndex:i] level_ID] && [[showLevelArray objectAtIndex:j] level_Discount] != [[levelArray objectAtIndex:i] level_Discount] && [[showLevelArray objectAtIndex:j] level_Name] != [[levelArray objectAtIndex:i] level_Name])) {
                LevelDoc *updateLevel = [showLevelArray objectAtIndex:j];
                [updateLevel setCtlFlag:2];
                [ctlLevelArray addObject:updateLevel];
            }
        }
    }
    
    for (int i = 0; i < [ctlLevelArray count]; i++) {
        levelTagString = [levelTagString stringByAppendingString:[NSString stringWithFormat:@"%d",[[ctlLevelArray objectAtIndex:i] ctlFlag]]];
        levelNameString = [levelNameString stringByAppendingString:[[ctlLevelArray objectAtIndex:i] level_Name]];
        levelIdString = [levelIdString stringByAppendingString:[NSString stringWithFormat:@"%d",[[ctlLevelArray objectAtIndex:i] level_ID]]];
        levelDiscountString = [levelDiscountString stringByAppendingString:[NSString stringWithFormat:@"%.2lf",[[ctlLevelArray objectAtIndex:i] level_Discount]]];
        
        if (i < [ctlLevelArray count]-1) {
            levelTagString = [levelTagString stringByAppendingString:@","];
            levelNameString = [levelNameString stringByAppendingString:@","];
            levelIdString = [levelIdString stringByAppendingString:@","];
            levelDiscountString = [levelDiscountString stringByAppendingString:@","];
        }
    }
    
    [endSendArray addObject:levelTagString];
    [endSendArray addObject:levelNameString];
    [endSendArray addObject:levelIdString];
    [endSendArray addObject:levelDiscountString];
    
    [SVProgressHUD show];
    _requestLevelOperation = [[GPHTTPClient shareClient] requestLevelDetailInfoWithArray:endSendArray success:^(id xml) {
        [SVProgressHUD dismiss];
        [GDataXMLDocument parseXML:xml viewController:self showSuccessMsg:YES showFailureMsg:YES success:^(int code) {} failure:^{}];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ address:%s", error.description, __FUNCTION__);
        
    }];
    
}

#pragma mark - 接口

// 获取确认订单信息
- (void)requestLevelInfo
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetLevelOperation = [[GPHTTPClient shareClient] requestLevelInfoSuccess:^(id xml) {
        [SVProgressHUD dismiss];
        NSMutableArray *initLevelArray = [[NSMutableArray alloc] init];
        GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xml encoding:NSUTF8StringEncoding error:0];
        GDataXMLElement *data = [[xmlDoc nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
        int flag = [[[[data elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
        if (flag == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"信息获取错误!" delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (flag == 1) {
            NSArray *arry = [xmlDoc nodesForXPath:@"//Result" error:nil];
            NSArray *dates = [[arry objectAtIndex:0] elementsForName:@"Content"];
            NSArray *contentElement = [[dates objectAtIndex:0] elementsForName:@"Level"];
            for (GDataXMLElement *data in contentElement) {
                LevelDoc *levDoct = [[LevelDoc alloc] init];
                LevelDoc *WXlevDoct = [[LevelDoc alloc] init];
                
                [levDoct setLevel_ID:[[[[data elementsForName:@"LevelID"] objectAtIndex:0] stringValue] integerValue]];
                [levDoct setLevel_Name:[[[data elementsForName:@"LevelName"] objectAtIndex:0] stringValue]];
                [levDoct setLevel_Discount:[[[[data elementsForName:@"Discount"] objectAtIndex:0] stringValue] floatValue]];
                [levDoct setCtlFlag:0];
                
                [WXlevDoct setLevel_ID:[[[[data elementsForName:@"LevelID"] objectAtIndex:0] stringValue] integerValue]];
                [WXlevDoct setLevel_Name:[[[data elementsForName:@"LevelName"] objectAtIndex:0] stringValue]];
                [WXlevDoct setLevel_Discount:[[[[data elementsForName:@"Discount"] objectAtIndex:0] stringValue] floatValue]];
                [WXlevDoct setCtlFlag:0];
                
                [initLevelArray addObject:levDoct];
                
                [levelArray addObject:WXlevDoct];
            }
        }
        
        [showLevelArray addObjectsFromArray:initLevelArray];
        [self sortCourseFArrayByDate];
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Error:%@ Address:%s",error.description, __FUNCTION__);
    }];
}


@end
