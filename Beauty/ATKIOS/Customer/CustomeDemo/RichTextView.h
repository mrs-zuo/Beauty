//
//  RichTextView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RichTextViewBaseRun.h"

@class RichTextView;

@protocol RichTextViewDelegate <NSObject>

@optional
-(void)richTextView:(RichTextView *)richTextView touchBeginRun:(RichTextViewBaseRun *)run;
-(void)richTextView:(RichTextView *)richTextView touchEndRun:(RichTextViewBaseRun *)run;
@end

@interface RichTextView : UIView
@property (nonatomic,copy) NSString *text;
@property (nonatomic , strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpacing; //行高
@property (nonatomic, strong) NSMutableArray *richTextRunArray; //需要特殊处理的元素数组
@property (nonatomic, strong) NSMutableArray *richReplaceTextColorRunArray;//需要颜色替换的数组
@property (nonatomic, strong) NSMutableArray *richReplaceTextRunArray;//需要替换的数组
@property (nonatomic, strong) NSMutableArray *richPersonIdArray;//person数组
@property (nonatomic, strong) NSMutableDictionary *richTextRunRectDic;//需要点击事件Rect的Dictionary
@property (nonatomic, readonly, copy) NSString *textAnalyzed;
@property (nonatomic, weak) id<RichTextViewDelegate> delegate;


@end
