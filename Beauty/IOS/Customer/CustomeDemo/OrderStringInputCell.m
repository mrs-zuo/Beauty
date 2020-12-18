//
//  OrderStringInputCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "OrderStringInputCell.h"
#import "UILabel+InitLabel.h"
#import "UITextView+Additional.h"
#import "OrderDoc.h"

@interface OrderStringInputCell ()
@property (strong, nonatomic) OrderDoc *theOrderDoc;
@end

@implementation OrderStringInputCell
@synthesize valueLable, titleLabel;
@synthesize theOrderDoc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 11.0f, 180.0f, 21.0f) title:@"title"];
        [titleLabel setFont:kFont_Light_16];
        titleLabel.textColor = kColor_TitlePink;
        [self.contentView addSubview:titleLabel];
        
        valueLable = [UILabel initNormalLabelWithFrame:CGRectMake(146.0f, 11.0f, 159.0f, 21.0f) title:@"Content"];
        [valueLable setFont:kFont_Light_16];
        valueLable.textColor = [UIColor blackColor];
        valueLable.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:valueLable];
    }
    return self;
}

@end
