//
//  DFChooseAlertView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFChooseAlertView;
typedef NSInteger (^DFChooseAlertViewNumberOfRowsBlock)(NSInteger section);
typedef UITableViewCell* (^DFChooseAlertViewCellsBlock)(DFChooseAlertView *alert, NSIndexPath *indexPath);
typedef void (^DFChooseAlertViewRowSelectionBlock)(DFChooseAlertView *alert, NSIndexPath *selectedIndex);
typedef void (^DFChooseAlertViewCompletionBlock)(void);
typedef void (^DFChooseAlertButtonIndex)(DFChooseAlertView *alert, UIButton *button, NSInteger index);


@interface DFChooseAlertView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView  *table;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, assign) NSInteger numOfRow;
@property (nonatomic, strong) DFChooseAlertViewCellsBlock cellsBlock;
@property (nonatomic, strong) DFChooseAlertViewRowSelectionBlock selection;
@property (nonatomic, strong) DFChooseAlertButtonIndex  buttonIndex;
@property (nonatomic, assign) NSInteger butttonFlag;
+ (instancetype)DFchooseAlterTitle:(NSString *)title  numberOfRow:(NSInteger)number ChooseCells:(DFChooseAlertViewCellsBlock)cells selectionBlock:(DFChooseAlertViewRowSelectionBlock)select buttonsArray:(NSArray *)buttons andClickButtonIndex:(DFChooseAlertButtonIndex)index;

- (instancetype)initWithTitle:(NSString *)title numberOfRow:(NSInteger)number ChooseCells:(DFChooseAlertViewCellsBlock)cells selectionBlock:(DFChooseAlertViewRowSelectionBlock)select buttonsArray:(NSArray *)buttons andClickButtonIndex:(DFChooseAlertButtonIndex)index;
- (void)show;
-(void)animateOut;

@end
