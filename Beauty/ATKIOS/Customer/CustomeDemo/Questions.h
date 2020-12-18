//
//  Questions.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, QuestionMode) {
    QuestionTextMode = 0,
    QuestionSingleSelection = 1,
    QuestionMutalSelection = 2
};

@interface Questions : NSObject
@property (nonatomic, strong) NSAttributedString *attributedQuestionTitle;
@property (nonatomic, strong) NSString *titelForType;
@property (nonatomic, assign) CGSize attributedSize;

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isChoose;
@property (nonatomic, assign) NSInteger QuestionID;
@property (nonatomic, copy) NSString *QuestionName;
@property (nonatomic, copy) NSString *QuestionContent;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, copy) NSString *QuestionDescription;
@property (nonatomic, assign) CGSize descriptionSize;
@property (nonatomic, assign) NSInteger AnswerID;
@property (nonatomic, copy) NSString *AnswerContent;
@property (nonatomic, assign) CGFloat answerContentHeight;
@property (nonatomic, strong) NSMutableArray *answerList;
@property (nonatomic, assign) QuestionMode QuestionType;
- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

@interface ChoiceQuestion : NSObject
@property (nonatomic, copy) NSString *optionName;
@property (nonatomic, assign) NSInteger optionStatus;

@end
