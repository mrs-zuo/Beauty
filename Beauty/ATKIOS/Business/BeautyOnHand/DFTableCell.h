//
//  EcardIndateCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^CellLayoutBlock)();//CGRect labelFrame, CGRect textLabel, CGRect imageFrame
@interface DFTableCell : UITableViewCell
@property (nonatomic, strong) CellLayoutBlock layoutBlock;
@end
