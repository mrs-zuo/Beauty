//
//  DFPickAlertView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-5.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFPickAlertView;
typedef NSInteger (^DFTableAlertNumberOfRowsBlock)(NSInteger section);
typedef UITableViewCell* (^DFTableAlertTableCellsBlock)(DFPickAlertView *alert, NSIndexPath *indexPath);
typedef void (^DFTableAlertRowSelectionBlock)(NSIndexPath *selectedIndex);
typedef void (^DFTableAlertCompletionBlock)(void);


@interface DFPickAlertView : UIView
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, strong) DFTableAlertCompletionBlock completionBlock;	// Called when Cancel button pressed
@property (nonatomic, strong) DFTableAlertRowSelectionBlock selectionBlock;	// Called when a row in table view is pressed
- (void)show;
+ (instancetype)tableAlertTitle:(NSString *)title NumberOfRows:(DFTableAlertNumberOfRowsBlock)rowNumber CellOfIndexPath:(DFTableAlertTableCellsBlock)cell;

- (void)configureSelectionBlock:(DFTableAlertRowSelectionBlock)selection Completion:(DFTableAlertCompletionBlock)completion;

@end
