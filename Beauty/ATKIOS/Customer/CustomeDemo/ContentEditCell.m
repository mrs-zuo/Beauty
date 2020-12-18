//
//  ContentEditCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-6.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContentEditCell.h"
#import "UIPlaceHolderTextView+InitTextView.h"

@implementation ContentEditCell
@synthesize contentEditText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColor_White;
        contentEditText = [UIPlaceHolderTextView initNormalTextViewWithFrame:CGRectMake(10.0f,10.0f, kSCREN_BOUNDS.size.width - 10, 34.0f) text:@"" placeHolder:@""];
        contentEditText.textAlignment = NSTextAlignmentLeft;
        contentEditText.textColor = kMainGrayColor;
        contentEditText.showsHorizontalScrollIndicator = NO;
        contentEditText.showsVerticalScrollIndicator = NO;
        contentEditText.scrollEnabled = NO;
        contentEditText.returnKeyType = UIReturnKeyDone;
        contentEditText.font = kNormalFont_14;
        [self.contentView addSubview:contentEditText];
    }
    return self;
}

- (void)setContentText:(NSString *)contentText
{
    contentEditText.text = contentText;
    CGSize size = [contentText sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(300.0f, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect = contentEditText.frame;
    rect.size.height = size.height + 5 < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : size.height + 20.0f;
    contentEditText.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
