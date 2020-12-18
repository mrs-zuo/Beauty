//
//  Questions.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "Questions.h"
#define DetailLabelWidth    250.0

@implementation Questions

@synthesize attributedSize;
@synthesize QuestionContent;
@synthesize QuestionDescription;
@synthesize isShow;
@synthesize AnswerContent;
@synthesize AnswerID;
@synthesize answerList;

- (id)init
{
    self = [super init];
    if (self) {
        _QuestionName = @"";
        QuestionContent = @"";
        QuestionDescription = @"";
        isShow = NO;
        AnswerContent = @"";
        _isEdit = NO;
        _quesStatus = QuestionStatusNone;
        _answerContentHeight = 120;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [self init];
    [self setValuesForKeysWithDictionary:dic];
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    printf("%c--%s",__LINE__, __FUNCTION__ );
}

- (NSMutableArray *)answerList
{
    if (!answerList) {
        answerList = [NSMutableArray array];
        NSArray *contentArray = [QuestionContent componentsSeparatedByString:@"|"];
        NSArray *answerArray = [AnswerContent componentsSeparatedByString:@"|"];
        [contentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ChoiceQuestion *choice = [[ChoiceQuestion alloc] init];
            choice.optionName = obj;
            if (idx < answerArray.count) {
                choice.optionStatus = [answerArray[idx] integerValue];
            }
            [answerList addObject:choice];
        }];
        
    }
    return answerList;
}

- (NSString *)choiceAnswer {
    if (self.answerList.count) {
        NSArray *tmpArray = [self.answerList valueForKeyPath:@"@unionOfObjects.optionStatus"];
        _choiceAnswer = [tmpArray componentsJoinedByString:@"|"];
    } else {
        _choiceAnswer = @"";
    }
    return _choiceAnswer;
}

- (NSString *)questionAnswer
{
    if (self.QuestionType == QuestionTextMode) {
        _questionAnswer = [NSString stringWithFormat:@"{\"QuestionID\":%ld,\"AnswerContent\":\"%@\"}", (long)self.QuestionID, self.QuestionContent];
    } else {
        _questionAnswer = [NSString stringWithFormat:@"{\"QuestionID\":%ld,\"AnswerContent\":\"%@\"}", (long)self.QuestionID, self.choiceAnswer];
    }
    
    return _questionAnswer;
}

- (NSAttributedString *)attributedQuestionTitle
{
    if (!_attributedQuestionTitle) {
        NSString *tmpStri = nil;
        switch (_QuestionType) {
            case QuestionSingleSelection:
                tmpStri = [NSString stringWithFormat:@"【单选】%@", _QuestionName];
                break;
            case QuestionMutalSelection:
                tmpStri = [NSString stringWithFormat:@"【多选】%@", _QuestionName];
                break;
            case QuestionTextMode:
                tmpStri = [NSString stringWithFormat:@"【文本】%@", _QuestionName];
                break;
        }
        NSMutableAttributedString  *attriString = [[NSMutableAttributedString alloc] initWithString:tmpStri];
//        [attriString addAttributes:@{NSForegroundColorAttributeName:kColor_Editable, NSFontAttributeName: kFont_Light_15} range:NSMakeRange(0, 4)];
        NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
        parStyle.lineSpacing = 2.0;
        [attriString addAttributes:@{NSParagraphStyleAttributeName: parStyle} range:NSMakeRange(0, tmpStri.length)];
        [attriString addAttributes:@{NSForegroundColorAttributeName:kColor_Black, NSFontAttributeName: kFont_Light_15} range:NSMakeRange(0, tmpStri.length)];
        
        _attributedQuestionTitle = [attriString copy];
    }
    return _attributedQuestionTitle;
}

- (CGSize)attributedSize
{
    attributedSize = [self.attributedQuestionTitle boundingRectWithSize:CGSizeMake(DetailLabelWidth, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) context:NULL].size;
    return attributedSize;
}

- (CGSize)contentSize
{
    CGSize size;
    if (IOS6) {
        size = [AnswerContent sizeWithFont:kFont_Light_15 constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
       size = [AnswerContent boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:kFont_Light_15} context:NULL].size;

    }
    _contentSize = size;
    _contentSize.height = _contentSize.height > 28 ? _contentSize.height + 16 : 38.0;
    
    return _contentSize;
}

- (CGSize)descriptionSize
{
    CGSize size;
    if (IOS6) {
        size = [QuestionDescription sizeWithFont:kFont_Light_13 constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
        size = [QuestionDescription boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:kFont_Light_13} context:NULL].size;
    }
    
    _descriptionSize = size;
    _descriptionSize.height = _descriptionSize.height > 28 ? _descriptionSize.height + 16 : 38.0;
    
    return _descriptionSize;
}

- (void)skipThisQuestion
{
    if (self.QuestionType == QuestionTextMode){
        self.QuestionContent = @"";
    } else {
        [self.answerList enumerateObjectsUsingBlock:^(ChoiceQuestion *obj, NSUInteger idx, BOOL *stop) {
            obj.optionStatus = 0;
        }];
    }
    self.quesStatus = QuestionStatusIgnore;
}
- (void)modifiedChoiceQuestion:(NSInteger)choiceIndex
{
    if (self.QuestionType == QuestionSingleSelection) {
        [self.answerList enumerateObjectsUsingBlock:^(ChoiceQuestion *obj, NSUInteger idx, BOOL *stop) {
            if (idx == choiceIndex) {
                [obj modifiedOptionStatus];
            } else {
                obj.optionStatus = 0;
            }
        }];
    }
    if (self.QuestionType == QuestionMutalSelection) {
        [self.answerList[choiceIndex] modifiedOptionStatus];
    }
}

@end


@implementation ChoiceQuestion

- (void)modifiedOptionStatus
{
    self.optionStatus = (self.optionStatus == 1 ? 0: 1);
}

@end