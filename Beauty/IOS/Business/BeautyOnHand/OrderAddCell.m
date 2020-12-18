//
//  OrderAddCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-6.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderAddCell.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"
#import "DEFINE.h"

@implementation OrderAddCell
@synthesize titleLabel;
@synthesize promptLabel, addButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        titleLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 0.0f, 80.0f, kTableView_HeightOfRow) title:@"-"];
        titleLabel.hidden = YES;
        [self.contentView addSubview:titleLabel];
        
        promptLabel = [UILabel initNormalLabelWithFrame:CGRectMake(100.0f, 0, 170.0f, kTableView_HeightOfRow) title:@""];
        [promptLabel setTextColor:[UIColor grayColor]];
        [promptLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:promptLabel];
    
        addButton = [UIButton buttonWithTitle:@""
                                       target:self
                                     selector:@selector(addButtonAction)
                                        frame:CGRectMake(275.0f, (kTableView_HeightOfRow - 30.0f)/2, 30.0f, 30.0f)
                                backgroundImg:[UIImage imageNamed:@"icon_add"]
                             highlightedImage:nil];
        [self.contentView addSubview:addButton];
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
