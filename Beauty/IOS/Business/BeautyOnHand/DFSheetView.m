//
//  DFSheetView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-20.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFSheetView.h"

@interface DFSheetView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *sheetView;
@property (nonatomic, strong) UIView *backView;
@end


@implementation DFSheetView
@synthesize sheetView;
@synthesize backView;


- (void)createBackgroudView
{
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.opaque = YES;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    }];

}



- (void)show
{
    [self createBackgroudView];
    self.backView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.backView];
    
    self.sheetView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.sheetView.backgroundColor = [UIColor blueColor];
    self.sheetView.frame = CGRectMake(0, 0, 320, 127.5);
    self.sheetView.scrollEnabled = NO;
    self.sheetView.rowHeight = 30.0f;
    self.sheetView.autoresizingMask = UIViewAutoresizingNone;
    self.sheetView.delegate = self;
    self.sheetView.dataSource = self;
    self.sheetView.sectionHeaderHeight = 0.1f;
    self.sheetView.sectionFooterHeight = 0.1f;
    self.sheetView.showsHorizontalScrollIndicator = NO;
    [self.backView addSubview:self.sheetView];
    
    [self becomeFirstResponder];
    
    [self AnimationIn];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)AnimationIn
{

    self.backView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height, 320, 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height - 128, 320,  128);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)AnimationOut
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.frame = CGRectMake(0, kSCREN_BOUNDS.size.height, 320, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self AnimationOut];
}

#pragma mark uitableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = [NSString stringWithFormat:@"测试测试%ld", (long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"the select is %@",@"select");
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 7.0f;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

@end
