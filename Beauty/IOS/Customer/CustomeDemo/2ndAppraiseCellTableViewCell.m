//
//  2ndAppraiseCellTableViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/9.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "2ndAppraiseCellTableViewCell.h"
#import "UILabel+InitLabel.h"

@implementation _ndAppraiseCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _commentName = [UILabel initNormalLabelWithFrame:CGRectMake(5.0f, 20.0f, 100.0f, 16.0f) title:@""];
  
    [self.contentView addSubview:_commentName];
    
    return self;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
