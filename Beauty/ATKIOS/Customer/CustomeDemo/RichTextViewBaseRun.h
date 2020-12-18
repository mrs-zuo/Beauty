//
//  RichTextViewBaseRun.h
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

typedef enum richTextRunType
{
    richTextImageRunType,
    richTextViewColorRun,
    // add other type here
    
}RichTextViewRunType;

@interface RichTextViewBaseRun : NSObject
@property (nonatomic) RichTextViewRunType textRunType;
@property (nonatomic,copy) NSString *originalText;
@property (nonatomic,strong) UIFont *originalFont;
@property (nonatomic) NSRange textRunRange; //需要特殊处理的文字的范围
@property (nonatomic) BOOL isResponseTouchEvent; //响应点击事件
@property (assign , nonatomic) NSInteger personID;//响应事件时，判断要向那个Id发送消息
-(void)replaceTextWithAttributedString:(NSMutableAttributedString *)string;//将要特殊处理的文字替换成相应的元素，子类继承后需要重写
-(BOOL)drawRunWithRect:(CGRect)rect;//绘制函数，子类继承并重写
@end
