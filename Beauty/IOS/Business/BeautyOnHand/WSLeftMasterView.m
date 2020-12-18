
//
//  WSLeftMasterView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "WSLeftMasterView.h"
#import "WorkSheetViewController.h"
#import "DEFINE.h"

#import "UIButton+InitButton.h"
#import "UILabel+InitLabel.h"
#import "NSDate+Convert.h"

@interface WSLeftMasterView ()
@property (strong, nonatomic) UILabel *dateLabel;
@end

@implementation WSLeftMasterView
@synthesize userArray;
@synthesize dateLabel;
@synthesize wsDelegate;
@synthesize select_UserArray;
@synthesize multipleSelection;
@synthesize dateStr;
@synthesize wsLeftMasterDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _lTableView = [[UITableView alloc] initWithFrame:self.bounds];
        _lTableView.dataSource = self;
        _lTableView.delegate = self;
        _lTableView.backgroundColor = [UIColor clearColor];
        _lTableView.backgroundView = nil;
        //_lTableView.showsHorizontalScrollIndicator = NO;
        //_lTableView.showsVerticalScrollIndicator = NO;
        
         if ((IOS7 || IOS8)) _lTableView.separatorInset = UIEdgeInsetsZero;
        [self addSubview:_lTableView];
    }
    return self;
}

- (void)setDateStr:(NSString *)ndateStr
{
    NSDate *date = [NSDate stringToDate:ndateStr dateFormat:@"yyyy-MM-dd"];
    dateStr = [NSDate dateToString:date dateFormat:@"yyyy MM/dd"];
    dateLabel.text = dateStr;
}

- (void)setUserArray:(NSArray *)newuserArray
{
    userArray = newuserArray;
    [_lTableView reloadData];
}

- (void)setSelect_UserArray:(NSMutableArray *)newselect_UserArray
{
    select_UserArray = newselect_UserArray;
    [_lTableView reloadData];
}

#pragma mark - TableView DataSource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        NSString *cellIdentity = @"LTableViewCell_Title";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        
//        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, kWSHeight_TitleCell - 2.0f, tableView.bounds.size.width, 0.8f)];
//        line.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
//        
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, kWSHeight_TitleCell)];
//        headerView.backgroundColor = [UIColor whiteColor];
//        
//        
//        UIButton *leftButton = [UIButton buttonWithTitle:@""
//                                                  target:self
//                                                selector:@selector(leftAction)
//                                                   frame:CGRectMake(10.0f, 12.0f, 20.0f, 20.0f)
//                                           backgroundImg:[UIImage imageNamed:@"time_left"]
//                                        highlightedImage:nil];
//        
//        UIButton *rightButton = [UIButton buttonWithTitle:@""
//                                                   target:self
//                                                 selector:@selector(rightAction)
//                                                    frame:CGRectMake(80.0f, 12.0f, 20.0f, 20.0f)
//                                            backgroundImg:[UIImage imageNamed:@"time_right"]
//                                         highlightedImage:nil];
//        
//        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f, 0.0f, 50.0f, kWSHeight_TitleCell) title:@"-/-"];
//        dateLabel.textAlignment = NSTextAlignmentCenter;
//        dateLabel.numberOfLines = 0;
//        dateLabel.font = kFont_Light_14;
//        dateLabel.textColor = kColor_DarkBlue;
//        dateLabel.text = dateStr;
//        dateLabel.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chickDateLabelAction)];
//        [dateLabel addGestureRecognizer:tapGesture];
//        
//        [headerView addSubview:leftButton];
//        [headerView addSubview:rightButton];
//        [headerView addSubview:dateLabel];
//        [headerView addSubview:line];
//        [cell.contentView addSubview:headerView];
//
//        return cell;
//    } else {
        NSString *cellIdentity = @"LTableViewCell";
        WSLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (cell == nil) {
            cell = [[WSLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UserDoc *userDoc = [userArray objectAtIndex:indexPath.row];
        [cell updateData:userDoc];
        [cell setDelegate:self];
    
        [cell.selectButton setSelected:NO];
        for (UserDoc *us in select_UserArray) {
            if (us.user_Id == userDoc.user_Id) {
                [cell.selectButton setSelected:YES];
                break;
            }
        }
        return cell;
    //}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kWSHeight_NormalCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kWSHeight_TitleCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, kWSHeight_TitleCell - 2.0f, tableView.bounds.size.width, 0.8f)];
    line.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, kWSHeight_TitleCell)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *leftButton = [UIButton buttonWithTitle:@""
                                              target:self
                                            selector:@selector(leftAction)
                                               frame:CGRectMake(10.0f, (kWSHeight_TitleCell - 20.0f)/2, 20.0f, 20.0f)
                                       backgroundImg:[UIImage imageNamed:@"time_left"]
                                    highlightedImage:nil];
    
    UIButton *rightButton = [UIButton buttonWithTitle:@""
                                               target:self
                                             selector:@selector(rightAction)
                                                frame:CGRectMake(80.0f, (kWSHeight_TitleCell - 20.0f)/2, 20.0f, 20.0f)
                                        backgroundImg:[UIImage imageNamed:@"time_right"]
                                     highlightedImage:nil];
    
    dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(30.0f, 0.0f, 50.0f, kWSHeight_TitleCell) title:@"-/-"];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.numberOfLines = 0;
    dateLabel.font = kFont_Light_14;
    dateLabel.textColor = kColor_DarkBlue;
    dateLabel.text = dateStr;
    dateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chickDateLabelAction)];
    [dateLabel addGestureRecognizer:tapGesture];
    
    [headerView addSubview:leftButton];
    [headerView addSubview:rightButton];
    [headerView addSubview:dateLabel];
    [headerView addSubview:line];
    
    return headerView;
}

- (void)leftAction
{
    NSDate *date = [NSDate stringToDate:dateLabel.text dateFormat:@"yyyy MM/dd"];
    NSDate *newDate = [date dateByAddingTimeInterval: -(24 * 60 * 60)];
    dateStr = [NSDate dateToString:newDate dateFormat:@"yyyy MM/dd"];
    
    if ([wsLeftMasterDelegate respondsToSelector:@selector(leftMasterView:didChangeDate:)]) {
        [wsLeftMasterDelegate leftMasterView:self didChangeDate:newDate];
    }
}

- (void)rightAction
{
    NSDate *date = [NSDate stringToDate:dateLabel.text dateFormat:@"yyyy MM/dd"];
    NSDate *newDate = [date dateByAddingTimeInterval: 24 * 60 * 60];
    dateStr = [NSDate dateToString:newDate dateFormat:@"yyyy MM/dd"];
    
    
    if ([wsLeftMasterDelegate respondsToSelector:@selector(leftMasterView:didChangeDate:)]) {
        [wsLeftMasterDelegate leftMasterView:self didChangeDate:newDate];
    }
}

- (void)chickDateLabelAction
{
    if ([wsLeftMasterDelegate respondsToSelector:@selector(displayDatePickerInLeftMasterView:)]) {
        [wsLeftMasterDelegate displayDatePickerInLeftMasterView:self];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([wsDelegate respondsToSelector:@selector(WSScrollViewDidScroll:)]) {
        [wsDelegate WSScrollViewDidScroll:scrollView];
    }
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    
//
//    NSLog(@"%f", _lTableView.contentOffset.y);
//    _pp(_lTableView.contentOffset);
//    _ps(_lTableView.contentSize);
//    _pr(_lTableView.frame);
//    
//    
//    if (_lTableView.contentOffset.y <= 0 || _lTableView.contentOffset.y > _lTableView.contentSize.height) {
//        [_lTableView setScrollEnabled:NO];
//    } else {
//        [_lTableView setScrollEnabled:YES];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row != 0) {
        [self addOrRemoveUserInSelect_UserArray:indexPath];
    }
}


#pragma mark - WSLeftTableViewCellDelegate

- (void)chickSelectedButtonInCell:(WSLeftTableViewCell *)cell
{
    NSIndexPath *indexPath = [_lTableView indexPathForCell:cell];
    [self addOrRemoveUserInSelect_UserArray:indexPath];
    
    [_workSheetVC setSelectedInfoText];
}

// 判断userDoc是否存在于select_UserArray
// <是否存在> ？ <delete user from  select_UserArray> : <add user in select_UserArray>

- (void)addOrRemoveUserInSelect_UserArray:(NSIndexPath *)indexPath
{
    UserDoc *userDoc = [userArray objectAtIndex:indexPath.row];
    UserDoc *tempUser = nil;
    for (UserDoc *us in select_UserArray) {
        if (us.user_Id == userDoc.user_Id) {
            tempUser = us;
            break;
        }
    }
    if (multipleSelection) {
        if (tempUser)
            [select_UserArray removeObject:tempUser];
        else
            [select_UserArray addObject:userDoc];
        
        [_lTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        if (tempUser)
            [select_UserArray removeObject:tempUser];
        else{
            [select_UserArray removeAllObjects];
            [select_UserArray addObject:userDoc];
        }
        [_lTableView reloadData];
    }
}

@end
