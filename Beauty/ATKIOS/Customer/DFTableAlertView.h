//
//  DFPickAlertView.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-5.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFTableAlertView;
typedef NSInteger (^DFTableAlertNumberOfRowsBlock)(NSInteger section);
typedef UITableViewCell* (^DFTableAlertTableCellsBlock)(DFTableAlertView *alert, NSIndexPath *indexPath);
typedef void (^DFTableAlertRowSelectionBlock)(NSIndexPath *selectedIndex);
typedef void (^DFTableAlertCompletionBlock)(void);


@interface DFTableAlertView : UIView
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, assign) float      height;
@property (nonatomic, strong) DFTableAlertCompletionBlock completionBlock;	// Called when Cancel button pressed
@property (nonatomic, strong) DFTableAlertRowSelectionBlock selectionBlock;	// Called when a row in table view is pressed
- (void)show;
+ (instancetype)tableAlertTitle:(NSString *)title NumberOfRows:(DFTableAlertNumberOfRowsBlock)rowNumber CellOfIndexPath:(DFTableAlertTableCellsBlock)cell;

- (void)configureSelectionBlock:(DFTableAlertRowSelectionBlock)selection Completion:(DFTableAlertCompletionBlock)completion;

@end
