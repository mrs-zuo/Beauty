//
//  DFChooseAlertView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFChooseAlertView.h"
#define BACKVIEW_WIDTH      270.0f
#define LABEL_HIGHT         40.0f
#define CELL_HIGHT          40.0f

@implementation DFChooseAlertView
@synthesize titleLabel;

@synthesize backView;

@synthesize numOfRow;
@synthesize cellsBlock;
@synthesize selection;
@synthesize buttonIndex;

+ (instancetype)DFchooseAlterTitle:(NSString *)title numberOfRow:(NSInteger)number ChooseCells:(DFChooseAlertViewCellsBlock)cells selectionBlock:(DFChooseAlertViewRowSelectionBlock)select buttonsArray:(NSArray *)buttons andClickButtonIndex:(DFChooseAlertButtonIndex)index
{
    return [[self alloc] initWithTitle:title numberOfRow:number ChooseCells:cells selectionBlock:select buttonsArray:buttons andClickButtonIndex:index];
}

- (instancetype)initWithTitle:(NSString *)title numberOfRow:(NSInteger)number ChooseCells:(DFChooseAlertViewCellsBlock)cells selectionBlock:(DFChooseAlertViewRowSelectionBlock)select buttonsArray:(NSArray *)buttons andClickButtonIndex:(DFChooseAlertButtonIndex)index
{
    if (cells == nil || select == nil || index == nil) {
        [[NSException exceptionWithName:@"rowsBlock and cellsBlock Error" reason:@"These blocks MUST NOT be nil" userInfo:nil] raise];
        return nil;
    }
    self = [super init];

    if (self) {
        cellsBlock = cells;
        selection = select;
        buttonIndex = index;
        numOfRow = number;
        
        self.backView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.cornerRadius = 6.0;
        self.backView.layer.masksToBounds = YES;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BACKVIEW_WIDTH, CELL_HIGHT - 0.5)];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = kColor_SysBlue;
        self.titleLabel.opaque = NO;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = kFont_Light_18;
        self.titleLabel.text = title;

        [self.backView addSubview:self.titleLabel];
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, CELL_HIGHT - 0.55, BACKVIEW_WIDTH, 0.5);
        layer.backgroundColor = kColor_LightBlue.CGColor;
        [self.backView.layer addSublayer:layer];
        
        self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.rowHeight = LABEL_HIGHT;
        self.table.tableFooterView = [[UIView alloc] init];
        self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if (IOS7 || IOS8) {
            self.table.separatorInset = UIEdgeInsetsZero;
        }
        if (IOS8) {
            self.table.layoutMargins = UIEdgeInsetsMake(0, -10, 0, 0);
        }
        self.table.frame = CGRectMake(0, CELL_HIGHT, BACKVIEW_WIDTH,(numOfRow * LABEL_HIGHT < 180 ? numOfRow * LABEL_HIGHT : 180));
        
        [self.backView addSubview:self.table];

        float width = BACKVIEW_WIDTH / (buttons.count);
        for (int i = 0; i < buttons.count; ++i) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.showsTouchWhenHighlighted = YES;
            button.frame = CGRectMake(width * i , CGRectGetMaxY(self.table.frame) , width, LABEL_HIGHT);
            [button setTitle:buttons[i] forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
//            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            button.tag = i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button.layer.borderWidth = 0.5f;
//            button.layer.borderColor = [UIColor grayColor].CGColor;
//            button.layer.masksToBounds = YES;
//            button.layer.cornerRadius = 4.0f;
            button.backgroundColor = [UIColor whiteColor];
            button.layer.shadowColor = [[UIColor grayColor] CGColor];
            button.layer.shadowRadius = 0.5;
            button.layer.shadowOpacity = 1;
            button.layer.shadowOffset = CGSizeZero;
            button.layer.masksToBounds = NO;

            [self.backView addSubview:button];
        }

        if (buttons == nil) {
            self.butttonFlag = 0;
        } else {
            self.butttonFlag = 1;
        }
    }
    
    return self;
}


- (void)createBackgroundView {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    self.opaque = NO;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    }];
}

- (void)show {
    [self createBackgroundView];
    
    [self addSubview:backView];
    [self becomeFirstResponder];
    
    [self animateIn];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)animateIn
{
    self.backView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, 0, 0);
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.frame = CGRectMake((self.frame.size.width - BACKVIEW_WIDTH) / 2, (self.frame.size.height - 20 - CGRectGetHeight(self.table.frame) - LABEL_HIGHT * 2 - 10) / 2, BACKVIEW_WIDTH, self.table.frame.size.height + (LABEL_HIGHT * self.butttonFlag) + CELL_HIGHT);
    }];
//    
//    self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
//    [UIView animateWithDuration:0.2 animations:^{
//        self.backView.transform = CGAffineTransformMakeScale(1.1, 1.1);
//    } completion:^(BOOL finished){
//        [UIView animateWithDuration:1.0/15.0 animations:^{
//            self.backView.transform = CGAffineTransformMakeScale(0.9, 0.9);
//        } completion:^(BOOL finished){
//            [UIView animateWithDuration:1.0/7.5 animations:^{
//                self.backView.transform = CGAffineTransformIdentity;
//            }];
//        }];
//    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [[touches allObjects] firstObject];
    CGPoint touchPoint = [oneTouch locationInView:self.backView];
    
    BOOL isInBackView = [self.backView pointInside:touchPoint withEvent:event];
    if (!isInBackView) {
        [self animateOut];
    }
}
-(void)animateOut
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.3;
        self.backView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, 0, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)buttonClick:(UIButton *)button {
    self.buttonIndex(self, button, button.tag);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numOfRow;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellsBlock(self, indexPath);
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selection(self, indexPath);
    
}

@end
