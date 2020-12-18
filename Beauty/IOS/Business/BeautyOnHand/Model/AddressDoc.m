//
//  AddressDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "AddressDoc.h"
#import "DEFINE.h"

@implementation AddressDoc
@synthesize adrs_Id;
@synthesize adrs_Type;
@synthesize adrs_Address;
@synthesize adrs_ZipCode;
@synthesize adrsType;

- (id)init
{
    self = [super init];
    if (self) {
      self.adrs_Address = @"";
    }
    return self;
}

- (void)setAdrs_Type:(NSInteger)newAdrs_Type
{
    adrs_Type = newAdrs_Type;
    [self setAdrsTypeByType];
}

- (void)setAdrsTypeByType
{
    switch (self.adrs_Type) {
        case 0:  adrsType = @"住宅";  break;
        case 1:  adrsType = @"工作";  break;
        case 2:  adrsType = @"其他";  break;
        default: adrsType = @"";     break;
    }
}

- (void)setAdrs_Address:(NSString *)newAdrs_Address
{
    adrs_Address = [newAdrs_Address copy];
    
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 290.0f, 200.0f)];
    textView.text = adrs_Address;
    textView.font = kFont_Light_16;
    CGFloat currentHeight = [textView sizeThatFits:CGSizeMake(290.0f, 200.0f)].height;
    
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    _cell_Address_Height = currentHeight;
    textView = nil;
}
@end
