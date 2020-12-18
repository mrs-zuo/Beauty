//
//  WSLeftTableViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDoc.h"

@protocol WSLeftTableViewCellDelegate ;

@interface WSLeftTableViewCell : UITableViewCell
@property (strong, nonatomic) UIButton *selectButton;
@property (strong, nonatomic) UILabel *nameLabel;

@property (assign, nonatomic) id <WSLeftTableViewCellDelegate> delegate;
- (void)updateData:(UserDoc *)userDoc;
@end

@protocol WSLeftTableViewCellDelegate <NSObject>
- (void)chickSelectedButtonInCell:(WSLeftTableViewCell *)cell;
@end

