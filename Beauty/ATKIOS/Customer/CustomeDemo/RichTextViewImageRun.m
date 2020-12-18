//
//  RichTextViewImageRun.m
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextViewImageRun.h"
#import <CoreText/CoreText.h>

@implementation RichTextViewImageRun


-(id)init
{
    self = [super init];
    if (self) {
        //runArray = [[NSMutableArray alloc]init];
        self.textRunType = richTextImageRunType;
        self.isResponseTouchEvent = YES;
    }
    return self;
}
-(void)replaceTextWithAttributedString:(NSMutableAttributedString *)attribuedString
{
    [attribuedString deleteCharactersInRange:self.textRunRange];//删除插入的空格
    CTRunDelegateCallbacks imageCallBack;//创建CoreText回调函数，并设置参数
    imageCallBack.version = kCTRunDelegateVersion1;
    imageCallBack.dealloc = RichTextViewImageRunDelegateDeallocCallback;
    imageCallBack.getAscent = RichTextViewImageRunDelegateGetAscentCallback;
    imageCallBack.getDescent = RichTextViewImageRunDelegateGetDescentCallback;
    imageCallBack.getWidth = RichTextViewImageRunDelegateGetWidthCallback;
    
    unichar objectChar = 0xFFFC;
    NSString *objectStr = [NSString stringWithCharacters:&objectChar length:1];
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc]initWithString:objectStr];
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallBack, (__bridge void* )self);//将回调函数和self创建为代理的引用
    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];//将代理的引用设置到对应文本的位置
    CFRelease(runDelegate);
    [attribuedString insertAttributedString:imageAttributedString atIndex:self.textRunRange.location];
    [super replaceTextWithAttributedString:attribuedString];
}

-(BOOL)drawRunWithRect:(CGRect)rect
{
    //重写父类的绘制函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *imagePathString = @"flyMessage";
    UIImage *image = [UIImage imageNamed:imagePathString];
    _imageForReplace = image;
    if(image)
        CGContextDrawImage(context, rect, image.CGImage);
    
    return YES;
}

+ (NSString *)analyzeText:(NSString *)originalString
             withRunArray:(NSMutableArray **)runArray
       andReplaceRunArray:(NSArray *)runReplaceArray
         andPersonIdArray:(NSArray *)personIdArray
{
    //搜索需要特殊处理（替换成图标）的文本单元，将其替换为回调的对象，并添加到回调的数组中
    NSMutableString *newString = [[NSMutableString alloc] initWithString:originalString];
    for (int i = 0 ; i < runReplaceArray.count ; i++) {
        NSString *string = (NSString *)[runReplaceArray objectAtIndex:i];
        NSRange range = [newString rangeOfString:string];
        NSInteger location = range.location + range.length;
        if(range.length == 0)
            continue;
        if(location >= newString.length - 1) //不替换末尾的门店的电话号码（该号码与之前的美丽顾问、服务人员一样的时候）
            break ;
        RichTextViewImageRun *imageRun = [[RichTextViewImageRun alloc]init];
        imageRun.textRunRange = NSMakeRange(range.location, 1);
        imageRun.originalText = string;
        imageRun.personID = [[personIdArray objectAtIndex:i] integerValue];
        unichar objectChar = 0xFFFC;
        NSString *objectStr = [NSString stringWithCharacters:&objectChar length:1];
        [newString replaceCharactersInRange:range withString:objectStr];
        [*runArray addObject:imageRun];
    }
    return newString;
}
#pragma mark - RunDelegateCallback

void RichTextViewImageRunDelegateDeallocCallback(void *refCon)
{
    
}

//--上行高度
CGFloat RichTextViewImageRunDelegateGetAscentCallback(void *refCon)
{
    RichTextViewImageRun *run =(__bridge RichTextViewImageRun *) refCon;
    return run.originalFont.ascender + 5 ;
}

//--下行高度
CGFloat RichTextViewImageRunDelegateGetDescentCallback(void *refCon)
{
    RichTextViewImageRun *run =(__bridge RichTextViewImageRun *) refCon;
    return run.originalFont.descender - 5;
}

//-- 宽
CGFloat RichTextViewImageRunDelegateGetWidthCallback(void *refCon)
{
    RichTextViewImageRun *run =(__bridge RichTextViewImageRun *) refCon;
    return (run.originalFont.ascender - run.originalFont.descender) + 10;
}
@end