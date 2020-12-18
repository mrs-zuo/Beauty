//
//  LevelAddCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "LevelAddCell.h"
#import "UILabel+InitLabel.h"

@implementation LevelAddCell
@synthesize promptLabel, addButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        promptLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100.0f, 7.0f, 170.0f, 30.0f) title:@""];
        [promptLabel setTextColor:[UIColor grayColor]];
        [promptLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:promptLabel];
        
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        [addButton setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = addButton;
    }
    return self;
}

- (void)addButtonAction
{
    if ([delegate respondsToSelector:@selector(chickAddButton:)]) {
        [delegate chickAddButton:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
