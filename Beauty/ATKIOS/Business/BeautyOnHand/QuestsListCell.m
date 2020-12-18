//
//  QuestsListCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/5/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "QuestsListCell.h"
#import "QuestionPaper.h"


#define MarginTop       3.0
#define MarginRight     12.0

//wugang->
//#define TitleLabelWidth     230.0
#define TitleLabelWidth     200.0
//<-wugang
#define ImageWidthAndHeight 30.0

#define DateLabelWidth      130.0
#define NameLabelWidth      80.0
#define NormalLabelHeight   25.0

@interface QuestsListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *editImage;
@property (nonatomic, strong) UIImageView *showImage;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *responsibleLabel;
@property (nonatomic, strong) UILabel *customerLabel;
@property (nonatomic, strong) UIImage *delbtnImg;
@property (retain, nonatomic) UIButton *delButton;

@end

@implementation QuestsListCell
@synthesize titleLabel;
@synthesize editImage;
@synthesize showImage;
@synthesize dateLabel;
@synthesize responsibleLabel;
@synthesize customerLabel;
@synthesize delbtnImg;
@synthesize delButton;

- (void)setPaper:(QuestionPaper *)questPaper
{
    _paper = questPaper;
    
    self.titleLabel.attributedText = _paper.attriTitle;
    
    CGFloat height = (_paper.titleSize.height > NormalLabelHeight ? _paper.titleSize.height: NormalLabelHeight);
    CGRect frame = self.titleLabel.frame;
    frame.size.height = height;
    self.titleLabel.frame = frame;
    self.editImage.image = (_paper.CanEditAnswer ? [UIImage imageNamed:@"IOS2_60_edit"]: [UIImage imageNamed:@"IOS2_60_nedit"]);
    self.showImage.image = (_paper.IsVisible ? [UIImage imageNamed:@"eye60"]: [UIImage imageNamed:@"neye60"]);
    //wugang->
    delbtnImg = (_paper.IsVisible ? [UIImage imageNamed:@"del60"]: [UIImage imageNamed:@"nodel60"]);
    [self.delButton setImage:delbtnImg forState:UIControlStateNormal];
    self.delButton.userInteractionEnabled=YES;
    //<-wugang
    NSString *date = [_paper.UpdateTime substringToIndex:16];
    self.dateLabel.text = date;
    if (_displayStyle == QuestsListDisplayStyleHidden) {
        self.responsibleLabel.hidden = YES;
        self.customerLabel.hidden   = YES;
        self.editImage.hidden = YES;
        self.showImage.hidden = YES;
        self.delButton.hidden = YES;
        self.imageView.image = [UIImage imageWithCGImage:[UIImage imageNamed:@"jiantous"].CGImage scale:2.0 orientation:UIImageOrientationRight];

        //        UIImage *imageHidden = [UIImage imageWithCGImage:@"jiantous" scale:2.0 orientation:UIImageOrientationLeft];

    } else {
        self.editImage.hidden = NO;
        self.showImage.hidden = NO;
        if (_paper.GroupID){
            self.delButton.hidden = NO;
        }else{
            self.delButton.hidden = YES;
        }
        self.responsibleLabel.text = _paper.ResponsiblePersonName;
        self.customerLabel.text = _paper.CustomerName;
        self.imageView.hidden = YES;
    }
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
         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, MarginTop, TitleLabelWidth, NormalLabelHeight)];
            label.numberOfLines = 0;
            label.textColor = kColor_Black;
            label.font = kFont_Light_15;
            label;
        });
        editImage = ({
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 10.0, 0, ImageWidthAndHeight, ImageWidthAndHeight)];
            
            image;
        });
        showImage = ({
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(editImage.frame)+3.0, 0, ImageWidthAndHeight, ImageWidthAndHeight)];

            image;
        });
        //wugang->
        delButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake( CGRectGetMaxX(showImage.frame)+3.0, 0, ImageWidthAndHeight, ImageWidthAndHeight);
            [button setImage:delbtnImg forState:UIControlStateNormal];
            button;
        });
        //<-wugang
        dateLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = kFont_Light_14;
            label.textColor = kColor_Editable;
            label;
        });
        responsibleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = kFont_Light_14;
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = kColor_Editable;
            label;
        });
        customerLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = kFont_Light_14;
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = kColor_Editable;
            label;
        });
        _displayStyle = QuestsListDisplayStyleNormol;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:editImage];
        [self.contentView addSubview:showImage];
        [self.contentView addSubview:delButton];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:responsibleLabel];
        [self.contentView addSubview:customerLabel];
    }
    return self;
}

- (void)checkAction:(UIButton *)sender {
    if (self.delRecord) {
        self.delRecord();
    }
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
    self.dateLabel.frame = CGRectMake(5, CGRectGetMaxY(titleLabel.frame)-3, DateLabelWidth, NormalLabelHeight);
    self.responsibleLabel.frame = CGRectMake(305.0 - self.paper.responsiblePersonWidth, CGRectGetMinY(dateLabel.frame)-3, self.paper.responsiblePersonWidth, NormalLabelHeight);//CGRectGetMaxX(dateLabel.frame)
    self.customerLabel.frame = CGRectMake(CGRectGetMinX(responsibleLabel.frame) - NameLabelWidth, CGRectGetMinY(dateLabel.frame)-3, NameLabelWidth, NormalLabelHeight);
    if (_displayStyle == QuestsListDisplayStyleHidden) {
        self.imageView.frame = CGRectMake(295, CGRectGetMinY(dateLabel.frame) + 5 , 15, 22.5);
    }
}


@end
