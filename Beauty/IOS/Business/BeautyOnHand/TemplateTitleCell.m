//
//  TemplateTitleCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TemplateTitleCell.h"
#import "UILabel+InitLabel.h"
#import "DEFINE.h"

@implementation TemplateTitleCell
@synthesize titleLabel, editButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:156.0f/255.0f green:219.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
        
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, kTableView_HeightOfRow/2- 12.0f, 250.0f, 24.0f) title:@""];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = kFont_Medium_18;
        [self.contentView addSubview:titleLabel];
        
        editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setBackgroundImage:[UIImage imageNamed:@"editBtn1_bg"] forState:UIControlStateNormal];
        [editButton setFrame:CGRectMake(270.0f, kTableView_HeightOfRow/2 - 14.0f, 32.0f, 28.0f)];
        [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editButton];
    }
    return self;
}

- (void)editAction:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    if ([delegate respondsToSelector:@selector(editTemplateWithIndex:)]) {
        [delegate editTemplateWithIndex:theButton.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
