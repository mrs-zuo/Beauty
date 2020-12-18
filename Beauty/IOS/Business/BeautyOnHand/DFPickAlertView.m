//
//  DFPickAlertView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-5.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFPickAlertView.h"

#define BACKVIEW_WIDTH      280.0f
#define LABEL_HIGHT         40.0f



@interface DFPickAlertView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) DFTableAlertNumberOfRowsBlock numberOfRowsBlock;
@property (nonatomic, strong) DFTableAlertTableCellsBlock   cellsBlock;

@end

@implementation DFPickAlertView
@synthesize backView;
@synthesize titleLabel;
@synthesize table;
@synthesize cancelButton;
@synthesize numberOfRowsBlock;
@synthesize cellsBlock;

+ (instancetype)tableAlertTitle:(NSString *)title NumberOfRows:(DFTableAlertNumberOfRowsBlock)rowNumber CellOfIndexPath:(DFTableAlertTableCellsBlock)cell
{
    
    return [[self alloc] initWithTitle:title NumberOfRows:rowNumber CellOfIndexPath:cell];
    
}


- (instancetype)initWithTitle:(NSString *)title NumberOfRows:(DFTableAlertNumberOfRowsBlock)rowNumber CellOfIndexPath:(DFTableAlertTableCellsBlock)cell
{
    if (rowNumber == nil || cell == nil)
    {
        [[NSException exceptionWithName:@"rowsBlock and cellsBlock Error" reason:@"These blocks MUST NOT be nil" userInfo:nil] raise];
        return nil;
    }

    self = [super init];
    if (self) {
        
        cellsBlock = cell;
        numberOfRowsBlock = rowNumber;
        _title = title;
        
    }
    return self;
}


- (void)configureSelectionBlock:(DFTableAlertRowSelectionBlock)selection Completion:(DFTableAlertCompletionBlock)completion
{
    self.selectionBlock = selection;
    self.completionBlock = completion;
}





-(void)createBackgroundView
{
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
//    self.backgroundColor = [UIColor redColor];
    self.opaque = NO;
    
    // adding it as subview of app's UIWindow
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    [appWindow addSubview:self];
    
    // get background color darker
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    }];

}

- (void)show
{
    [self createBackgroundView];
    self.backView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backView.layer.cornerRadius = 6.0;
    self.backView.layer.masksToBounds = YES;

    [self addSubview:self.backView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor blackColor];
//    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
//    self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.titleLabel.font = kFont_Light_18;
    self.titleLabel.frame = CGRectMake(0, 0, BACKVIEW_WIDTH, LABEL_HIGHT);
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0.0, LABEL_HIGHT - 0.5, BACKVIEW_WIDTH, 0.5);
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.titleLabel.layer addSublayer:layer];
    [self.backView addSubview:self.titleLabel];

    
    
    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.frame = CGRectMake(0, LABEL_HIGHT, BACKVIEW_WIDTH, 160);
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.rowHeight = LABEL_HIGHT;
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorInset = UIEdgeInsetsZero;
    if (IOS8) {
        self.table.layoutMargins = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    self.table.tableFooterView = [[UIView alloc] init];
    self.table.backgroundView = [[UIView alloc] init];
    [self.backView addSubview:self.table];

    

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.table.frame.origin.y + self.table.frame.size.height, BACKVIEW_WIDTH, LABEL_HIGHT)];
//    self.cancelButton.frame = CGRectMake(0, self.table.frame.origin.y + self.table.frame.size.height, BACKVIEW_WIDTH, LABEL_HIGHT);
    self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelButton setTitleColor:kColor_SysBlue forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
//    self.cancelButton.tintColor = [UIColor blueColor];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    self.cancelButton.opaque = NO;

    [self.cancelButton addTarget:self action:@selector(animateOut) forControlEvents:UIControlEventTouchUpInside];
    CALayer *lay = [CALayer layer];
    lay.frame = CGRectMake(0, 0, BACKVIEW_WIDTH, 0.5);
    lay.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.cancelButton.layer addSublayer:lay];
    
    
    
    
    [self.backView addSubview:self.cancelButton];
    
    self.backView.frame = CGRectMake((self.frame.size.width - BACKVIEW_WIDTH) / 2, (self.frame.size.height - 190) / 2, BACKVIEW_WIDTH, 160 + LABEL_HIGHT * 2);

    [self becomeFirstResponder];

    [self animateIn];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)animateIn
{
    // UIAlertView-like pop in animation
    self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    [UIView animateWithDuration:0.2 animations:^{
        self.backView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1.0/15.0 animations:^{
            self.backView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:1.0/7.5 animations:^{
                self.backView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

-(void)animateOut
{

    [UIView animateWithDuration:1.0/7.5 animations:^{
        self.alpha = 0.3;
    }];
    [self removeFromSuperview];
    /*
    [UIView animateWithDuration:1.0/7.5 animations:^{
        self.backView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0/15.0 animations:^{
            self.backView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.backView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                self.alpha = 0.3;
            } completion:^(BOOL finished){
                // table alert not shown anymore
                [self removeFromSuperview];
            }];
        }];
    }];
     */
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
- (void)testNotification
{
    UILocalNotification *loction = [[UILocalNotification alloc] init];
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:10];
    loction.fireDate = pushDate;
    loction.timeZone = [NSTimeZone defaultTimeZone];
    loction.repeatInterval = kCFCalendarUnitMinute;
    loction.soundName = UILocalNotificationDefaultSoundName;
    loction.alertBody = @"测试本地推送通知";
    loction.applicationIconBadgeNumber = loction.applicationIconBadgeNumber + 1;
    UIApplication *app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:loction];
    
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"the touchesBegan");
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // TODO: Allow multiple sections
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // according to the numberOfRows block code
    return self.numberOfRowsBlock(section);
//    return 10;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // according to the cells block code
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    cell.textLabel.text = [NSString stringWithFormat:@"tableView is %ld", indexPath.row];
//    return cell;

    return self.cellsBlock(self, indexPath);
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // set cellSelected to YES so the completionBlock won't be
    // executed because a cell has been pressed instead of the cancel button
//    self.cellSelected = YES;
    // dismiss the alert
    self.selectionBlock(indexPath);

    [self animateOut];
    
    // perform actions contained in the selectionBlock if it isn't nil
    // add pass the selected indexPath
//    if (self.selectionBlock != nil)
}

@end
