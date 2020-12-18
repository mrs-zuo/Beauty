//
//  ContentQuestionsCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ContentQuestionsCell.h"

@implementation ContentQuestionsCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textView = ({
           UITextView *textV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 310, 120)];
            textV.textAlignment = NSTextAlignmentLeft;
            textV.font = kFont_Light_15;
            textV.textColor = kColor_Editable;
            textV.clipsToBounds = YES;
            textV;
        });
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.clipsToBounds = YES;
        [self.contentView addSubview:_textView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
