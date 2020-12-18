//
//  SubjectCell.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Questions;

@interface SubjectCell : UITableViewCell
@property (nonatomic, strong) Questions *question;

+ (CGFloat)getQuestHeight:(Questions *)ques;
@end
