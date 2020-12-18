//
//  QuestsListCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionPaper;
@interface QuestsListCell : UITableViewCell
@property (nonatomic, strong) QuestionPaper *paper;
+ (CGFloat)computeQuestsListCellHeightWith:(QuestionPaper *)ques;
@end
