//
//  WSRightMasterView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "WSRightMasterView.h"
#import "WSRightTableViewCell.h"
#import "DEFINE.h"

@implementation WSRightMasterView
@synthesize userArray;
@synthesize wsDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.delegate = self;
        
        _rTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kWSPrecision * 24 + 1.0f, self.bounds.size.height) style:UITableViewStylePlain];
        _rTableView.backgroundColor = [UIColor clearColor];
        _rTableView.backgroundView = nil;
        _rTableView.dataSource = self;
        _rTableView.delegate = self;
        _rTableView.showsHorizontalScrollIndicator = NO;
        _rTableView.showsVerticalScrollIndicator = NO;
        
        
        
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = NO;
        _rTableView.alwaysBounceVertical = NO;
        _rTableView.alwaysBounceHorizontal = NO;
    
        
        if ((IOS7 || IOS8)) _rTableView.separatorInset = UIEdgeInsetsZero;
        [self addSubview:_rTableView];
    }
    return self;
}

- (void)setUserArray:(NSArray *)newuserArray
{
    userArray = newuserArray;
    [_rTableView reloadData];
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
//        NSString *cellIdentity = @"RTableViewCell_Title";
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
//        for (int i = 0; i< 25; i++) {
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 24.0f, kWSHeight_TitleCell - 10.0f, 24.0f, 8.0f)];
//            imageView.image = [UIImage imageNamed:@"timeline"];
//            [headerView addSubview:imageView];
//            imageView = nil;
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 24.0f - 10.0f, kWSHeight_TitleCell - 10.0f - 15.0f, 20.0f, 15.0f)];
//            label.font = [UIFont systemFontOfSize:12.0f];
//            label.backgroundColor = [UIColor clearColor];
//            label.textAlignment = NSTextAlignmentCenter;
//            label.textColor = kColor_DarkBlue;
//            label.text = [NSString stringWithFormat:@"%d", i];
//            if (i == 0) {
//                CGRect rect = label.frame;
//                rect.origin.x += 5.0f;
//                label.frame = rect;
//            } else if (i == 24) {
//                CGRect rect = label.frame;
//                rect.origin.x -= 5.0f;
//                label.frame = rect;
//            }
//            [headerView addSubview:label];
//            label = nil;
//        }
//        [headerView addSubview:line];
//        [cell.contentView addSubview:headerView];
//        
//        return cell;
//    } else {
    
        NSString *cellIdentity = @"RTableViewCell";
        WSRightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (cell == nil) {
            cell = [[WSRightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UserDoc *userDoc = [userArray objectAtIndex:indexPath.row ];
        [cell updateData:userDoc];
        return cell;
   // }
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
    
    for (int i = 0; i< 25; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 24.0f, kWSHeight_TitleCell - 10.0f, 24.0f, 8.0f)];
        imageView.image = [UIImage imageNamed:@"timeline"];
        [headerView addSubview:imageView];
        imageView = nil;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 24.0f - 10.0f, kWSHeight_TitleCell - 30.0f, 20.0f, 20.0f)];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kColor_DarkBlue;
        label.text = [NSString stringWithFormat:@"%d", i];
        if (i == 0) {
            CGRect rect = label.frame;
            rect.origin.x += 5.0f;
            label.frame = rect;
        } else if (i == 24) {
            CGRect rect = label.frame;
            rect.origin.x -= 5.0f;
            label.frame = rect;
        }
        [headerView addSubview:label];
        label = nil;
    }
    [headerView addSubview:line];

    return headerView;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([wsDelegate respondsToSelector:@selector(WSScrollViewDidScroll:)]) {
        [wsDelegate WSScrollViewDidScroll:scrollView];
    }
}

@end
