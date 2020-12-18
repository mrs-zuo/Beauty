//
//  OpportunityDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OpportunityDoc.h"
#import "ProductAndPriceDoc.h"
#import "DEFINE.h"

@implementation OpportunityDoc

- (id)init
{
    self = [super init];
    if (self) {
        _productAndPriceDoc = [[ProductAndPriceDoc alloc] init];
        self.opp_Describe = @"";
    }
    return self;
}

- (void)setOpp_Describe:(NSString *)opp_Describe
{
    _opp_Describe = opp_Describe;
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _opp_Describe;
    textView.font = kFont_Light_16;
    float currentHeight = [textView sizeThatFits:CGSizeMake(300.0f, FLT_MAX)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _height_Prg_Describle = currentHeight;
    textView = nil;
    
}
@end
