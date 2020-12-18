;//
//  NoteViewCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Note;

@interface NoteViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *content;


- (void)showAllContent:(Note *)note;
@end
