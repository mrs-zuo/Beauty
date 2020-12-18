//
//  CustomerListCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "CustomerSelectListCell.h"
#import "UIImageView+WebCache.h"
#import "MessageDoc.h"
#import "DEFINE.h"

@interface CustomerSelectListCell ()
@property (strong, nonatomic) UIImageView *newsImageView;
@end

@implementation CustomerSelectListCell
@synthesize headImageView, nameLabel, dateLabel, mesgLabel, newsCountLabel, newsImageView;
//@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 10.0f, 40.0f, 40.0f)];
        [headImageView setImage:[UIImage imageNamed:@"loading_HeadImg40"]];
        [self.contentView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 8.0f, 85.0f, 21.0f)];
        [self.contentView addSubview:nameLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0f, 8.0f, 150.0f, 21.0f)];
        [self.contentView addSubview:dateLabel];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        
        mesgLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(55.0f, 33.0f, 240.0f, 21.0f)];
        mesgLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        mesgLabel.customEmojiPlistName = @"Expression_showImage.plist";
        [self.contentView addSubview:mesgLabel];
        
        [self initWithLabelLayout:nameLabel];
        [self initWithLabelLayout:dateLabel];
        [self initWithLabelLayout:mesgLabel];
        [self initWithLabelLayout:newsCountLabel];
        
        [nameLabel setFont:kFont_Light_14];
        [nameLabel setTextColor:kColor_DarkBlue];
        [dateLabel setFont:kFont_Light_14];
        [mesgLabel setFont:kFont_Light_14];
        dateLabel.textColor = kColor_Editable;
        mesgLabel.textColor = kColor_Editable;
        
        newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0f, 00.0f, 25.0f, 20.0f)];
        [newsImageView setImage:[UIImage imageNamed:@"newsCount_bgImage"]];
        [self.contentView addSubview:newsImageView];
        [newsImageView sendSubviewToBack:self.contentView];
        
        newsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 18.0f)];
        newsCountLabel.textColor = [UIColor whiteColor];
        newsCountLabel.backgroundColor = [UIColor clearColor];
        newsCountLabel.font = kFont_Light_12;
        [newsCountLabel setTextAlignment:NSTextAlignmentCenter];
        newsCountLabel.text = @"0";
        [newsImageView addSubview:newsCountLabel];
    }
    return self;
}

- (void)initWithLabelLayout:(UILabel *)label
{
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:kFont_Light_16];
    
}

- (void)updateData:(MessageDoc *)message
{
    [headImageView setImageWithURL:[NSURL URLWithString:message.customerHeadImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    [nameLabel setText:message.mesg_ToUserName];
    [mesgLabel setEmojiText:message.mesg_MessageContent];
//    [mesgLabel setText:message.mesg_MessageContent];
    [dateLabel setText:message.mesg_SendTime];
    
    if (message.mesg_NewsCount > 0 && message.mesg_NewsCount < 99) {
        [newsImageView setHidden:NO];
        [newsCountLabel setHidden:NO];
        [newsCountLabel setText:[NSString stringWithFormat:@"%ld", (long)message.mesg_NewsCount]];
    } else if(message.mesg_NewsCount > 99) {
        [newsImageView setHidden:NO];
        [newsCountLabel setHidden:NO];
        [newsCountLabel setText:@"N"];
    } else {
        [newsImageView setHidden:YES];
        [newsCountLabel setHidden:YES];
    }
}

//- (void)selectCustomerAction
//{
//    if ([delegate respondsToSelector:@selector(chickSelectBtnWithCell:)]) {
//        [delegate chickSelectBtnWithCell:self];
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
