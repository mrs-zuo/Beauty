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

-(NSString *)titelForType
{
    NSString *tmpStri = nil;
    if (!_titelForType) {
        switch (_QuestionType) {
            case QuestionSingleSelection:
                tmpStri = @"单选";
                break;
            case QuestionMutalSelection:
                tmpStri = @"多选";
                break;
            case QuestionTextMode:
                tmpStri =  @"文本";
                break;
        }
    }
 
    return tmpStri;
}


- (NSAttributedString *)attributedQuestionTitle
{
     NSString *tmpStri = nil;
    if (!_attributedQuestionTitle) {
        switch (_QuestionType) {
            case QuestionSingleSelection:
                tmpStri = _QuestionName;
                break;
            case QuestionMutalSelection:
                tmpStri = _QuestionName;
                break;
            case QuestionTextMode:
                tmpStri = _QuestionName;
                break;
        }

        NSMutableAttributedString  *attriString = [[NSMutableAttributedString alloc] initWithString:tmpStri];
//        [attriString addAttributes:@{NSForegroundColorAttributeName:kColor_Editable, NSFontAttributeName: kFont_Light_14} range:NSMakeRange(0, 4)];
        NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
        parStyle.lineSpacing = 2.0;
        [attriString addAttributes:@{NSParagraphStyleAttributeName: parStyle} range:NSMakeRange(0, tmpStri.length)];
        [attriString addAttributes:@{NSForegroundColorAttributeName:kColor_TitlePink, NSFontAttributeName: kFont_Light_15} range:NSMakeRange(0, tmpStri.length)];
        
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
        size = [QuestionDescription sizeWithFont:kFont_Light_14 constrainedToSize:CGSizeMake(280, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
        size  = [QuestionDescription boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:kFont_Light_14} context:NULL].size;
    }
    
    _descriptionSize = size;
    _descriptionSize.height = _descriptionSize.height > 28 ? _descriptionSize.height + 16 : 38.0;
    
    return _descriptionSize;
}


@end


@implementation ChoiceQuestion


@end