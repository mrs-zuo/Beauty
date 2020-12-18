//
//  OneLabelCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 13-12-26.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "OneLabelCell.h"
#import "UILabel+InitLabel.h"

@implementation OneLabelCell
@synthesize contentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        contentLabel = [UILabel initNormalLabelWithFrame:CGRectMake(kCell_LabelToLeft, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 290, kCell_LabelHeight) title:@"content"];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
    }
    return self;
}

- (void)setContent:(NSString *)content
{
    self.contentLabel.text = content;
    CGSize size = [content sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290, 600) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect = self.contentLabel.frame;
    rect.size.height = size.height + 10;
    self.contentLabel.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
