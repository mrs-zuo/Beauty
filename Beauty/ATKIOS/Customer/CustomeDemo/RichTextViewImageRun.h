//
//  RichTextViewImageRun.h
//  GlamourPromise.Beauty.Customer
//
//  Created by ZW on 14-9-16.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RichTextViewBaseRun.h"
static NSMutableArray* runArray;

@interface RichTextViewImageRun : RichTextViewBaseRun
@property (nonatomic,strong ) UIImage *imageForReplace;

+ (NSString *)analyzeText:(NSString *) originalString withRunArray:(NSMutableArray **) runArray andReplaceRunArray:(NSArray *)runReplaceArray andPersonIdArray:(NSArray *)personArray;

@end
