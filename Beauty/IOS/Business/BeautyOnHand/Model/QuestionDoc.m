//
//  QuestionDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-23.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "QuestionDoc.h"
@implementation QuestionDoc
- (id)copyWithZone:(NSZone *)zone {
    QuestionDoc *newDoc = [[[self class] allocWithZone:zone] init];
    newDoc.question_ID = self.question_ID;
    newDoc.question_Name = self.question_Name;
    newDoc.question_Type = self.question_Type;
    newDoc.question_Content = self.question_Content;
    newDoc.question_Answer = self.question_Answer;
    newDoc.question_AnswerWord = self.question_AnswerWord;
    newDoc.question_AnswerID = self.question_AnswerID;
    newDoc.question_OptionNumber = self.question_OptionNumber;
    return newDoc;
}

- (CGFloat)question_Height
{
    CGSize  size_hours = [_question_Name sizeWithFont:kFont_Medium_16 constrainedToSize:CGSizeMake(290.0f, 220.0f)];
    
    _question_Height = ((size_hours.height + 8.0) < kTableView_HeightOfRow ?  kTableView_HeightOfRow : size_hours.height + 8.0);
    
    return _question_Height;
    
}
@end
