//
//  TemplateContentCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TemplateContentCell.h"
#import "UILabel+InitLabel.h"
#import "TemplateDoc.h"
#import "DEFINE.h"

@implementation TemplateContentCell
@synthesize contentLabel, createrLabel, menderLabel, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        contentLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 5.0f, 290.0f, 30.0f) title:@""];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.adjustsLetterSpacingToFitWidth = YES;
        [self.contentView addSubview:contentLabel];
        
        createrLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, contentLabel.frame.size.height + contentLabel.frame.origin.y, 80.0f, 20.0f) title:@""];
        menderLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100.0f, contentLabel.frame.size.height + contentLabel.frame.origin.y, 80.0f, 20.0f) title:@""];
        dateLabel   = [UILabel initNormalLabelWithFrame:CGRectMake(200.0f, contentLabel.frame.size.height + contentLabel.frame.origin.y, 100.0f, 20.0f) title:@""];
        createrLabel.font = kFont_Light_12;
        menderLabel.font  = kFont_Light_12;
        dateLabel.font    = kFont_Light_12;
        createrLabel.textColor = [UIColor lightGrayColor];
        menderLabel.textColor  = [UIColor lightGrayColor];
        dateLabel.textColor    = [UIColor lightGrayColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:createrLabel];
        [self.contentView addSubview:menderLabel];
        [self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)updateData:(TemplateDoc *)newTemplateDoc type:(int)type;
{
    contentLabel.text = newTemplateDoc.TemplateContent;
    
    CGRect rect_Content = self.contentLabel.frame;
    rect_Content.size.height = newTemplateDoc.height_Tmp_TemplateContent;
    self.contentLabel.frame = rect_Content;
    
    createrLabel.frame = CGRectMake(10.0f,  contentLabel.frame.size.height + contentLabel.frame.origin.y - 5.0f , 80.0f, 20.0f);
    menderLabel.frame  = CGRectMake(100.0f, contentLabel.frame.size.height + contentLabel.frame.origin.y - 5.0f, 80.0f, 20.0f);
    dateLabel.frame    = CGRectMake(180.0f, contentLabel.frame.size.height + contentLabel.frame.origin.y - 5.0f, 120.0f, 20.0f);
    
    dateLabel.text = newTemplateDoc.OperateTime;
//    if (type == 1) {
//        createrLabel.hidden = NO;
//        menderLabel.hidden = NO;
//        createrLabel.text = [NSString stringWithFormat:@"作者:%@",newTemplateDoc.tmp_CreatorName];
//        menderLabel.text = [NSString stringWithFormat:@"最后编辑:%@", newTemplateDoc.tmp_UpdaterName];
//    } else if (type == 0){
        createrLabel.hidden = YES;
        menderLabel.hidden = YES;
   // }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
