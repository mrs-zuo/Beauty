//
//  TemplateDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-19.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "TemplateDoc.h"
#import "DEFINE.h"

@implementation TemplateDoc

- (id)init
{
    self = [super init];
    if (self) {
      self.TemplateContent = @"";
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"the UndefinedKey is %@", key);
}

- (void)setTemplateContent:(NSString *)tmp_TemplateContent
{
   _TemplateContent = tmp_TemplateContent;
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _TemplateContent;
    textView.font = kFont_Light_16;
    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_Tmp_TemplateContent = currentHeight;
    textView = nil;
}

@end
