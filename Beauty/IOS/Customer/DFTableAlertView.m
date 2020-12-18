//
//  DFPickAlertView.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-5.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DFTableAlertView.h"

#define BACKVIEW_WIDTH      280.0f
#define LABEL_HIGHT         40.0f



@interface DFTableAlertView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) DFTableAlertNumberOfRowsBlock numberOfRowsBlock;
@property (nonatomic, strong) DFTableAlertTableCellsBlock   cellsBlock;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation DFTableAlertView
@synthesize backView;
@synthesize titleLabel;
@synthesize table;
@synthesize cancelButton;
@synthesize numberOfRowsBlock;
@synthesize cellsBlock;
@synthesize timer;

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
        _height = 160;
        
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
    self.titleLabel.opaque = NO;
//    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
//    self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.titleLabel.font = kFont_Light_18;
    self.titleLabel.frame = CGRectMake(0, 0, BACKVIEW_WIDTH, LABEL_HIGHT - 0.5);
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, LABEL_HIGHT - 0.55, BACKVIEW_WIDTH, 0.5);
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.backView.layer addSublayer:layer];

    [self.backView addSubview:self.titleLabel];

    
    
    self.table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.table.frame = CGRectMake(0, LABEL_HIGHT, BACKVIEW_WIDTH, fminf((float)_height, 160));
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.rowHeight = LABEL_HIGHT;
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (IOS7 || IOS8) {
        self.table.separatorInset = UIEdgeInsetsZero;
    }
    if (IOS8) {
        self.table.layoutMargins = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    [self.table flashScrollIndicators];
    self.table.tableFooterView = [[UIView alloc] init];
    self.table.backgroundView = [[UIView alloc] init];
    [self.backView addSubview:self.table];

    

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.table.frame.origin.y + self.table.frame.size.height, BACKVIEW_WIDTH, LABEL_HIGHT)];
//    self.cancelButton.frame = CGRectMake(0, self.table.frame.origin.y + self.table.frame.size.height, BACKVIEW_WIDTH, LABEL_HIGHT);
    self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelButton setTitleColor:kColor_TitlePink forState:UIControlStateNormal];
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
    
    self.backView.frame = CGRectMake((self.frame.size.width - BACKVIEW_WIDTH) / 2, (self.frame.size.height - 190) / 2, BACKVIEW_WIDTH, self.table.frame.size.height + LABEL_HIGHT * 2);

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
//    self.backView.transform = CGAffineTransformMakeScale(0.9, 0.9);

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
    [self showIndic];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(showIndic) userInfo:nil repeats:YES];
    
}

- (void)showIndic
{
    LOG(@"showIndic flashScrollIndicators");
    [self.table flashScrollIndicators];
}

-(void)animateOut
{
    [timer invalidate];
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
*/
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//    [self animateOut];
//}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRowsBlock(section);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellsBlock(self, indexPath);
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectionBlock(indexPath);

    [self animateOut];
}

@end
