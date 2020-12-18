//
//  QuestsListCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

//wugang->
@protocol TermCellDelegate <NSObject>
- (void)delRecord:(UIButton *)button;
@end
//<-wugang

typedef NS_ENUM(NSInteger, QuestsListDisplayStyle) {
    QuestsListDisplayStyleNormol,
    QuestsListDisplayStyleHidden
};
@class QuestionPaper;
@interface QuestsListCell : UITableViewCell
@property (nonatomic, strong) QuestionPaper *paper;
@property (nonatomic, assign) QuestsListDisplayStyle displayStyle;
//@property (retain, nonatomic) UIButton *delButton;
@property (strong, nonatomic) void(^delRecord)();

@property (nonatomic, weak) id delegate;

+ (CGFloat)computeQuestsListCellHeightWith:(QuestionPaper *)ques;
@end
