//
//  QuestsListCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "QuestsListCell.h"
#import "QuestionPaper.h"


#define MarginTop       10.0
#define MarginRight     10.0

#define TitleLabelWidth     300.0
#define ImageWidthAndHeight 30.0

#define DateLabelWidth      130.0
#define NameLabelWidth      60.0
#define NormalLabelHeight   40.0

@interface QuestsListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *responsibleLabel;

@end

@implementation QuestsListCell
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize responsibleLabel;

- (void)setPaper:(QuestionPaper *)questPaper
{
    _paper = questPaper;
    
    self.titleLabel.attributedText = _paper.attriTitle;
    
    CGFloat height = (_paper.titleSize.height > NormalLabelHeight ? _paper.titleSize.height: NormalLabelHeight-8);
    CGRect frame = self.titleLabel.frame;
    frame.size.height = height;
    self.titleLabel.frame = frame;
    NSString *date = [_paper.UpdateTime substringToIndex:16];
    self.dateLabel.text = date;
    self.responsibleLabel.text = _paper.ResponsiblePersonName;
    [self setNeedsLayout];
}

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        titleLabel = ({
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(MarginRight, MarginTop, TitleLabelWidth, NormalLabelHeight)];
            label.numberOfLines = 0;
            label.textColor = kColor_TitlePink;
            label.font = kFont_Light_15;
            label;
        });
        dateLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = kFont_Light_14;
            label.textColor = kColor_Black;
            label;
        });
        responsibleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = kFont_Light_14;
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = kColor_Black;
            label;
        });
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:responsibleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)computeQuestsListCellHeightWith:(QuestionPaper *)ques
{
    CGFloat height = (ques.titleSize.height > NormalLabelHeight ? ques.titleSize.height : NormalLabelHeight);
    return height + MarginTop + NormalLabelHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(MarginRight, CGRectGetMaxY(titleLabel.frame), DateLabelWidth, NormalLabelHeight);
    self.responsibleLabel.frame = CGRectMake(310.0 - DateLabelWidth, CGRectGetMinY(dateLabel.frame), DateLabelWidth, NormalLabelHeight);//CGRectGetMaxX(dateLabel.frame)
}


@end
