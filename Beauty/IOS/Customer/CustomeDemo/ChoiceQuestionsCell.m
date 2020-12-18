//
//  ChoiceQuestionsCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/26.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "ChoiceQuestionsCell.h"
#import "Questions.h"   
@implementation ChoiceQuestionsCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = kFont_Light_14;
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setChoice:(ChoiceQuestion *)choiceQues
{
    _choice = choiceQues;
    self.textLabel.text = _choice.optionName;
    self.imageView.image = (_choice.optionStatus == 1 ? [UIImage imageNamed:@"icon_Selected"]: [UIImage imageNamed:@"icon_unSelected"]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(280,15,21,21);
    self.textLabel.frame = CGRectMake(15,15,260,20);
}
@end
