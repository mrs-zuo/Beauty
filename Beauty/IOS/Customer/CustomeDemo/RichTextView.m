//
//  RichTextView.m
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextView.h"
#import "RichTextViewImageRun.h"
#import "RichTextViewColorRun.h"
#import <CoreText/CoreText.h>


@implementation RichTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _text = @"";
        _font = [UIFont  systemFontOfSize:14];
        _lineSpacing = 5;
        _richTextRunArray = [NSMutableArray array];
        _richTextRunRectDic = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSString *)analyzeText:(NSString *)originalString
{
    [_richTextRunArray removeAllObjects];
    [self.richTextRunRectDic removeAllObjects];
    
    NSString *resultString ;
    NSMutableArray *array = self.richTextRunArray;
    
    //解析其中的特殊文本，将其替换成特殊的元素和属性
    resultString = [RichTextViewImageRun analyzeText:originalString
                                        withRunArray:&array
                                  andReplaceRunArray:_richReplaceTextRunArray
                                    andPersonIdArray:_richPersonIdArray];
    
    resultString = [RichTextViewColorRun analyzeText:resultString
                                           runsArray:&array
                         andReplaceTextColorRunArray:_richReplaceTextColorRunArray];
    
    [self.richTextRunArray makeObjectsPerformSelector:@selector(setOriginalFont:) withObject:self.font];
    return resultString;
}
//根据属性字符串中的元素和属性绘制其到屏幕
-(void)drawRect:(CGRect)rect
{
    _textAnalyzed = [self analyzeText:_text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.textAnalyzed];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)_font.fontName, _font.pointSize, NULL);

    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, attributedString.length)];
    CFRelease(font);
    //替换特殊文本，将其RichTextAttributed属性赋值，如：RichTextViewImageRun，将CTRunDelegate赋值，绘图
    for (RichTextViewBaseRun *run in self.richTextRunArray) {
        [run replaceTextWithAttributedString:attributedString];
    }
    //获取当前绘图区域，设置仿射矩阵
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform textTransform = CGAffineTransformIdentity;
    textTransform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    textTransform = CGAffineTransformScale(textTransform, 1.0, -1.0); //y坐标需要反向（用户交互坐标和手机屏幕坐标，竖直方向上正好相反，需要反向）
    CGContextConcatCTM(context, textTransform);
    
    
    int lineCount = 0;
    CFRange lineRange = CFRangeMake(0, 0);
    //用当前的属性字符串创建排版
    CTTypesetterRef typeSetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    float drawLineX = 0 ; //绘制起点X坐标
    float drawLineY = self.bounds.origin.y + self.bounds.size.height + _font.ascender - 32;//绘制起点Y坐标
    BOOL drawFlag = YES;
    [self.richTextRunRectDic removeAllObjects];
    while (drawFlag) {
        //得到当前行在排版元素（字符串）的哪个location，本次为尝试排版
        CFIndex testLineLength = CTTypesetterSuggestLineBreak(typeSetter,lineRange.location ,self.bounds.size.width - 5 );
        //当前行需要显示的字符Range
check:  lineRange = CFRangeMake(lineRange.location, testLineLength);
        CTLineRef line = CTTypesetterCreateLine(typeSetter, lineRange); //根据要排版元素（文字）范围和排版创建行
        CFArrayRef runs = CTLineGetGlyphRuns(line);//获取该行需要特殊处理的元素
        
        //处理排版是否超出显示范围
        CTRunRef lastRun = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs)-1);//找到最后一个特殊处理的run
        CGFloat lastRunAscent;
        CGFloat lastRunDescent;
        CGFloat lastRunWith = CTRunGetTypographicBounds(lastRun, CFRangeMake(0, 0),&lastRunAscent, &lastRunDescent, NULL);//获取宽度
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(lastRun).location, NULL);//获取起始点
        if((lastRunPointX + lastRunWith) > self.bounds.size.width) //如果最后一个run的排版超出显示范围，则去掉一个排版的元素，在重新创建line
        {
            testLineLength -- ;
            CFRelease(line);
            goto check;
        }
        
        //绘制普通文字到屏幕
        drawLineX = CTLineGetPenOffsetForFlush(line, 0, self.bounds.size.width);//获取笔刷偏移量
        CGContextSetTextPosition(context, drawLineX, drawLineY);//在绘图上下文设置文字绘制坐标
        CTLineDraw(line, context);//绘制行
        
        //处理特殊元素
        for (int i = 0; i < CFArrayGetCount(runs); i++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            NSDictionary *attributed = (__bridge NSDictionary*)CTRunGetAttributes(run);
            RichTextViewBaseRun *textRun = [attributed objectForKey:@"RichTextAttributed"]; //获取当前需要绘制的特殊元素的类型
            if(textRun)
            {
                CGFloat runAscent,runDescent;
                CGFloat runWith = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent,NULL);//获取当前绘制元素的宽度
                CGFloat runHeight = runAscent + (-runDescent);
                CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);//获取当前绘制元素的X坐标
                CGFloat runPointY = drawLineY - (-runDescent); //获取Y坐标
                
                CGRect runRect = CGRectMake(runPointX, runPointY, runWith, runHeight);
                BOOL  isDraw = [textRun drawRunWithRect:runRect];//调用具体的绘图函数，完成特殊元素的绘制
                if(textRun.isResponseTouchEvent)
                {
                    CGRect tapRect = CGRectMake(runPointX - 6, runPointY - 6, runWith + 12, runHeight + 12);
                    
                    if(isDraw)//将特殊元素相关的Rect添加到字典，以备判断后面的点击事件是否落在该范围
                        [self.richTextRunRectDic setObject:textRun forKey:[NSValue valueWithCGRect:tapRect]];
//                    else{
//                        runRect = CTRunGetImageBounds(run, context, CFRangeMake(0, 0));
//                        runRect.origin.x = runPointX;
//                        [self.richTextRunRectDic setObject:textRun  forKey:[NSValue valueWithCGRect:tapRect]];
//                    }
                }
            }
        }
        CFRelease(line);
        if(lineRange.location + lineRange.length >= attributedString.length)
            drawFlag = NO;
        lineCount ++ ;
        drawLineY -= self.font.ascender + (-self.font.descender) + self.lineSpacing; //新行的Y坐标
        lineRange.location += lineRange.length;
    
    }
    CFRelease(typeSetter);
}

#pragma mark - touchEventDelegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    CGPoint location = [(UITouch*)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    if (self.delegate && [self.delegate respondsToSelector:@selector(richTextView:touchBeginRun:)]) {
        __weak RichTextView *weakSelf = self;
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CGRect rect = [key CGRectValue];
            RichTextViewBaseRun *run =  obj;
            if (CGRectContainsPoint(rect, runLocation))
                [weakSelf.delegate richTextView:weakSelf touchBeginRun:run];
        }];
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
    CGPoint runLocation = CGPointMake(location.x, self.frame.size.height - location.y);
    if (self.delegate && [self.delegate respondsToSelector:@selector(richTextView:touchEndRun:)]) {
        __weak RichTextView *weakSelf = self;
        [self.richTextRunRectDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CGRect rect = [key CGRectValue];
            RichTextViewBaseRun *run = obj;
            if (CGRectContainsPoint(rect, runLocation))
               [weakSelf.delegate richTextView:weakSelf touchEndRun:run];
        }];
    }
}
#pragma mark - setter

-(void)setText:(NSString *)text{
    [self setNeedsDisplay];
    _text = text;
}

-(void)setFont:(UIFont *)font{
    [self setNeedsDisplay];
    _font = font;
}

-(void)setTextColor:(UIColor *)textColor{
    [self setNeedsDisplay];
    _textColor = textColor;
}

-(void)setLineSpacing:(CGFloat)lineSpacing{
    [self setNeedsDisplay];
    _lineSpacing = lineSpacing;
}

@end
