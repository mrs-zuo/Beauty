//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"

#define kMaxEmoBite 8

#define FACE_NAME_HEAD  @"["

// 表情转义字符的长度（ /s占2个长度，xxx占3个长度，共5个长度 ）
#define FACE_NAME_LEN   4

#define FACE_COUNT_ALL  32

#define FACE_COUNT_ROW  3

#define FACE_COUNT_CLU  7

#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )

#define FACE_ICON_SIZE  44


@implementation FaceBoard

@synthesize delegate;

@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;

- (id)init {

    self = [super initWithFrame:CGRectMake(0, 0, 320, 190)];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
     _faceMap =  [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ExpressionImage" ofType:@"plist"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:_faceMap forKey:@"FaceMap"];

        //表情盘
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
        faceView.pagingEnabled = YES;
        faceView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * 320, 160);
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        
        for (int i = 1; i <= FACE_COUNT_ALL; i++) {

            FaceButton *faceButton = [FaceButton buttonWithType:UIButtonTypeCustom];
            faceButton.buttonIndex = i;
            
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
           //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + ((i - 1) / FACE_COUNT_PAGE * 320);
            CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
            faceButton.frame = CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
            
            
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Expression_%d", i]]
                        forState:UIControlStateNormal];

            [faceView addSubview:faceButton];
        }
        
        //添加PageControl
        facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(110, 160, 100, 20)];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        facePageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:faceView];
        
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:@"删除" forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(272, 182 - 30, 38, 28);
        [self addSubview:back];
    }

    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [facePageControl setCurrentPage:faceView.contentOffset.x / 320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {

    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * 320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {

    int i = ((FaceButton*)sender).buttonIndex;
    if (self.inputTextField) {

        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
        _faceMap =  [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ExpressionImage" ofType:@"plist"]];
        NSDictionary *tempDic = _faceMap;
        NSString *tempStr = [tempDic objectForKey:[NSString stringWithFormat:@"Expression_%d", i]];
        [faceString appendString:tempStr];
        self.inputTextField.text = faceString;
        [faceString release];
    }

    if (self.inputTextView) {

        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
         _faceMap =  [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ExpressionImage" ofType:@"plist"]];
        NSDictionary *tempDic = _faceMap;
        NSString *tempStr = [tempDic objectForKey:[NSString stringWithFormat:@"Expression_%d", i]];
        NSLog([_faceMap description]);
        NSRange range = [self.inputTextView selectedRange];
        [faceString insertString:tempStr atIndex:range.location];
        self.inputTextView.text = faceString;
        [faceString release];
        [delegate textViewDidChange:self.inputTextView];
    }
}
- (NSString *)getDeleteStrWithInteger:(int)integer text:(NSString *)text{
    NSString *delegateStr = nil;
    NSString *tempThreeStr = [text substringFromIndex:(text.length -integer)];
    NSString *tempFirstStr = [tempThreeStr substringFromIndex:1];
    if ([tempFirstStr isEqualToString:@"["]) {
        delegateStr = [text substringFromIndex:(text.length - integer)];
    }
    return delegateStr;
}
/*
- (void)backFace{
    NSString *inputString;
    inputString = self.inputTextField.text;
    if ( self.inputTextView ) {
        inputString = self.inputTextView.text;
    }
    NSString *deleteStr;
    NSString *tempStr = [inputString substringFromIndex:(inputString.length - 1)];
    if ([tempStr isEqualToString:@"]"] ) {

//        for (int i = 2; i <= 6; i ++) {
//            if (inputString.length > 2) {
//                int k = inputString.length - 1 - i;
//                if ( k >= 0) {
//                    NSString *tempStr = [inputString substringToIndex:inputString.length - 1 - i];
//                    if ([tempStr isEqualToString:@"["]) {
//                        deleteStr = [inputString substringToIndex:inputString.length - 1 - 1 - i];
//                    }
//
//                }
//            }
//        }
    }else{
        deleteStr=  [inputString substringToIndex:inputString.length -1];
    }
    if ( self.inputTextField ) {
        self.inputTextField.text = deleteStr;
    }
    
    if ( self.inputTextView ) {
        
        self.inputTextView.text = deleteStr;
        
        [delegate textViewDidChange:self.inputTextView];
    }
}
*/


//判断是否是 emoji表情
+ (BOOL)isEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


- (void)backFace{
    
    NSString *inputString;
    inputString = self.inputTextField.text;
    if ( self.inputTextView ) {
        inputString = self.inputTextView.text;
    }
    if ( inputString.length ) {
        NSString *string = nil;
        NSInteger stringLength = inputString.length;

        if ([[inputString substringFromIndex:stringLength - 1] isEqualToString:@"]"]) {
            for (int i = 1; i  < kMaxEmoBite; i++) {
                NSString *tempStr = [inputString substringFromIndex:stringLength - i];
                if ([[tempStr substringToIndex:1] isEqualToString:@"["]) {
                    string = [inputString substringToIndex:stringLength - i];
                    break;
                }
            }
        }else{
            string = [inputString substringToIndex:stringLength - 1];
        }

//        if ( stringLength >= FACE_NAME_LEN ) {
//            
//            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
//            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
//            if ( range.location == 0 ) {
//                
//                string = [inputString substringToIndex:
//                          [inputString rangeOfString:FACE_NAME_HEAD
//                                             options:NSBackwardsSearch].location];
//            }
//            else {
//                
//                string = [inputString substringToIndex:stringLength - 1];
//            }
//        }
//        else {
//            
//            string = [inputString substringToIndex:stringLength - 1];
//        }
    
        if ( self.inputTextField ) {
            
            self.inputTextField.text = string;
        }
        if ( self.inputTextView ) {
            
            self.inputTextView.text = string;
            
            [delegate textViewDidChange:self.inputTextView];
        }
    }
}


- (void)dealloc {
    
//    [_faceMap release];
    [_inputTextField release];
    [_inputTextView release];
    [faceView release];
    [facePageControl release];
    
    [super dealloc];
}

@end
