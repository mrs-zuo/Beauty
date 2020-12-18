//
//  SubjectCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "SubjectCell.h"
#import "Questions.h"
#define MarginRight         10.0
#define MarginTop           10.0
#define TextLabelHeight     14.0
#define TextLabelWidth      20.0

#define DetailLabelWidth    235.0
#define NormalLabelHeight   20.0


@implementation SubjectCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.titelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 30, 20)];
        self.titelLabel.backgroundColor = [UIColor colorWithRed:251/255. green:127/255. blue:25/255. alpha:1.];
        self.titelLabel.font = kNormalFont_14;
        self.titelLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titelLabel];
        
        self.textLabel.textColor = kColor_Black;
        self.textLabel.frame = CGRectMake(MarginRight+32, 15, 250, 30);
        self.textLabel.font = kNormalFont_14;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 0;
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
    
    self.titelLabel.text = ques.titelForType;
    self.textLabel.text = ques.QuestionName;
    self.textLabel.attributedText = ques.attributedQuestionTitle;
    self.imageView.image = (ques.isShow ? [UIImage imageNamed:@"jiantous"]: [UIImage imageNamed:@"jiantoux"]);
}

+ (CGFloat)getQuestHeight:(Questions *)ques
{
    CGFloat height = (ques.attributedSize.height > kTableView_DefaultCellHeight ? ques.attributedSize.height + MarginTop * 2: kTableView_DefaultCellHeight);
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 282,  (kTableView_DefaultCellHeight - 10) / 2, 15, 10);
    
    self.titelLabel.frame = CGRectMake(MarginRight, (self.question.attributedSize.height > kTableView_DefaultCellHeight ?self.question.attributedSize.height:kTableView_DefaultCellHeight)/2-10, 30, 20);
    
    self.textLabel.frame = CGRectMake(MarginRight+35, (self.question.attributedSize.height > kTableView_DefaultCellHeight ? 10:(kTableView_DefaultCellHeight-self.self.question.attributedSize.height)/2), DetailLabelWidth, self.question.attributedSize.height);
}

@end
