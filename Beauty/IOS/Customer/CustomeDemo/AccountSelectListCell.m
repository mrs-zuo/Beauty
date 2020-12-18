//
//  AccountSelectListCell.m
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AccountSelectListCell.h"
#import "MessageDoc.h"
#import "UIImageView+WebCache.h"



@interface AccountSelectListCell ()
@property (strong, nonatomic) UIImageView *newsImageView;

@end

@implementation AccountSelectListCell
@synthesize headImageView, nameLabel,dateLabel,mesgLabel,newsCountLabel,newsImageView;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, 20, 40.0f, 40.0f)];
        [headImageView setImage:[UIImage imageNamed:@"People-default"]];
        [self.contentView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, (40/3), 100, kLabel_DefaultHeight)];
        [self.contentView addSubview:nameLabel];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, (40/3), 120, kLabel_DefaultHeight)];
        dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:dateLabel];
        
        mesgLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(60.0f, 2 * (40/3) + kLabel_DefaultHeight, 220, kLabel_DefaultHeight)];
        mesgLabel.textAlignment = NSTextAlignmentLeft;
        mesgLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        mesgLabel.customEmojiPlistName = @"Expression_showImage.plist";
        [self.contentView addSubview:mesgLabel];
        
        newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0f, 2.0f, 25.0f, kLabel_DefaultHeight)];
        [newsImageView setImage:[UIImage imageNamed:@"selectList_News_bg"]];
        [self.contentView addSubview:newsImageView];
        
        newsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0f, 15.0f, 25.0f, kLabel_DefaultHeight)];
        newsCountLabel.textColor = [UIColor whiteColor];
        [newsCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:newsCountLabel];
        
        [self initWithLabelLayout:nameLabel];
        [self initWithLabelLayout:dateLabel];
        [self initWithLabelLayout:mesgLabel];
        [self initWithLabelLayout:newsCountLabel];
        
        [nameLabel setFont:kNormalFont_14];
        [nameLabel setTextColor:kColor_TitlePink];
        [dateLabel setTextColor:kColor_Editable];
        [dateLabel setFont:kNormalFont_14];
        [mesgLabel setFont:kNormalFont_14];
        [newsCountLabel setFont:kNormalFont_14];
        [newsCountLabel setTextColor:[UIColor whiteColor]];
        [newsCountLabel setTextAlignment:NSTextAlignmentCenter];
        [newsCountLabel setCenter:newsImageView.center];
        [newsCountLabel setFrame:CGRectMake(newsCountLabel.frame.origin.x, newsCountLabel.frame.origin.y-1, newsCountLabel.frame.size.width, newsCountLabel.frame.size.height)];
    }
    return self;
}

- (void)initWithLabelLayout:(UILabel *)label
{
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:kNormalFont_14];
    
}

- (void)updateData:(MessageDoc *)message
{
    [headImageView setImageWithURL:[NSURL URLWithString:message.mesg_HeadImageURL] placeholderImage:[UIImage imageNamed:@"People-default"]];
    // 必須加上這一行，這樣圓角才會加在圖片的「外側」
    headImageView.layer.masksToBounds = YES;
    // 其實就是設定圓角，只是圓角的弧度剛好就是圖片尺寸的一半
    headImageView.layer.cornerRadius =CGRectGetHeight(headImageView.bounds) / 2;
    
    [nameLabel setText:message.mesg_AccountName];
//    [mesgLabel setText:message.mesg_MessageContent];
    mesgLabel.emojiText = message.mesg_MessageContent;
    [dateLabel setText:message.mesg_SendTime];
    [nameLabel setTextColor:kColor_TitlePink];
    if (message.mesg_Available == 0) {
        nameLabel.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    }
    
    if (message.mesg_NewMessageCount > 0) {
        [newsImageView setHidden:NO];
        [newsCountLabel setHidden:NO];
        if (message.mesg_NewMessageCount < 100) {
            [newsCountLabel setText:[NSString stringWithFormat:@"%ld", (long)message.mesg_NewMessageCount]];
        } else {
            [newsCountLabel setText:@"N"];
        }
    } else {
        [newsImageView setHidden:YES];
        [newsCountLabel setHidden:YES];
    }
}

- (void)selectCustomerAction
{
    if ([delegate respondsToSelector:@selector(chickSelectBtnWithCell:)]) {
        [delegate chickSelectBtnWithCell:self];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
