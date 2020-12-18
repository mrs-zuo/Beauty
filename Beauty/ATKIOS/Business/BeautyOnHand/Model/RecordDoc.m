//
//  RecordDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//


#import "RecordDoc.h"
#import "DEFINE.h"

@implementation RecordDoc

- (id)init
{
    self = [super init];
    if (self) {
        [self setSuggestion:@""];
        [self setProblem:@""];
    }
    return self;
}

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"the UndefinedKey is %@", key);
}




    /*
- (void)setRec_Problem:(NSString *)rec_Problem
{
    _rec_Problem = rec_Problem;
    NSLog(@"the uitextview alloc");
//    textView.text = _rec_Problem;
//    textView.font = kFont_Light_16;
    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    CGSize problemSize = [_rec_Problem sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.0f, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    NSLog(@"setRec_Problem _height_Problem is %f", currentHeight);
    NSLog(@"sizeWithFont problemSize.height is %f", problemSize.height);
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_Problem = currentHeight;

//    textView = nil;

}

- (void)setRec_Suggestion:(NSString *)rec_Suggestion
{
    _rec_Suggestion = rec_Suggestion;
    NSLog(@"the uitextview alloc");

    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    CGSize suggestSize = [_rec_Suggestion sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.0f, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    NSLog(@"setRec_Suggestion _height_Suggestion is %f", currentHeight);
    NSLog(@"sizeWithFont suggestSize.height is %f", suggestSize.height);

    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    NSLog(@"the uitextview relece");

    _height_Suggestion = currentHeight;

}

*/

- (NSString *)TagName
{
    NSArray *array = [_TagName componentsSeparatedByString:@"|"];

    NSArray *ar = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 length]> [obj2 length]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([obj1 length]< [obj2 length])
            return (NSComparisonResult)NSOrderedAscending;
        else
            return (NSComparisonResult)NSOrderedSame;
    }];
//    for (NSString *str in ar) {
//        [string appendString:[NSString stringWithFormat:@"%@、",str]];
//    }
//    NSString *result  = [string substringToIndex:(string.length -1)];
    NSString *result = [ar componentsJoinedByString:@"、"];
    return result;
}


- (float)height_Problem
{
    float currentHeight = [_Problem sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(295.0f, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    return fmaxf(30.0f, currentHeight + 10.0f);
}

- (float)height_Suggestion
{
    float currentHeight = [_Suggestion sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(295.0f, FLT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    return fmaxf(30.0f, currentHeight + 10.0f);
}
@end
