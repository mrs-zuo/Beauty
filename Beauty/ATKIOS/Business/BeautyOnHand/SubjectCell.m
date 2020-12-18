//
//  SubjectCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SubjectCell.h"
#import "Questions.h"
#define MarginRight         2.0
#define MarginTop           10.0
#define TextLabelHeight     14.0
#define TextLabelWidth      25.0

#define DetailLabelWidth    250.0
#define NormalLabelHeight   20.0


@implementation SubjectCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = kColor_Black;
        self.textLabel.font = kFont_Light_15;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQuestion:(Questions *)ques
{
    _question = ques;
    self.detailTextLabel.attributedText = ques.attributedQuestionTitle;
    self.imageView.image = (ques.isShow ? [UIImage imageNamed:@"jiantous"]: [UIImage imageNamed:@"jiantoux"]);
    if (ques.isEdit) {
        self.imageView.image = [UIImage imageNamed:@"IOS2_60_edit"];
    }
}

+ (CGFloat)getQuestHeight:(Questions *)ques
{
    CGFloat height = (ques.attributedSize.height > 15.0 ? ques.attributedSize.height + MarginTop * 2: 38.0);
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake((self.question.isEdit ? 270: 282), (self.question.isEdit ? 2: 15), (self.question.isEdit ? 30: 15), (self.question.isEdit ? 30: 10));
    self.textLabel.frame = CGRectMake(MarginRight, MarginTop + 2 , TextLabelWidth, TextLabelHeight);
    self.detailTextLabel.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame) - 6, MarginTop, DetailLabelWidth, self.question.attributedSize.height);
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
}
@end
