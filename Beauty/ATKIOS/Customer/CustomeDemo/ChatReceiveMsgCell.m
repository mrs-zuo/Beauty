
//
//  ChatReceiveMsgCell.m
//  CustomeDemo
//
//  Created by macmini on 13-7-18.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "ChatReceiveMsgCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+InitLabel.h"
#import "MessageDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"

#define MessageText_Width 220.0f
@implementation ChatReceiveMsgCell
@synthesize headImageView,dateLabel,contentImgView,messageLabel;
@synthesize errorImgView, activityView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(270.0f, 30.0f, 40.0f, 40.0f)];
//        [headImageView setImage:[UIImage imageNamed:@"People-default"]];
//        [self.contentView addSubview:headImageView];
//        
//        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0f, 10.0f, 117.0f, 21.0f)];
//        [self.contentView addSubview:dateLabel];
//        
//        contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(55.0f, 30.0f, 235, 55.0f)];
//        [self.contentView addSubview:contentImgView];;
//        
//        messageLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(12.5f, 4.5f, MessageText_Width, 20.0f)];
//        [messageLabel setFont:kFont_Light_16];
//        [messageLabel setTextAlignment:NSTextAlignmentLeft];
//        [self.contentImgView addSubview:messageLabel];
//        
//        [self initWithLabelLayout:dateLabel];
//        [self initWithLabelLayout:messageLabel];
//        
//        [dateLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        [dateLabel setTextAlignment:NSTextAlignmentRight];
//        [dateLabel setTextColor:kColor_Editable];
//        headImageView.layer.cornerRadius = 4.0f;
//        headImageView.layer.masksToBounds = YES;
//        headImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        headImageView.layer.borderWidth = 1.0f;
//        
//        [messageLabel setNumberOfLines:0];
//        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
//        
//        // --
//        errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(295.0f, 20.0f, 20.0f, 20.0f)];
//        [errorImgView setImage:[UIImage imageNamed:@"warn_bg"]];
//        [errorImgView setHidden:YES];
//        [errorImgView setUserInteractionEnabled:YES];
//        [self.contentView addSubview:errorImgView];
//        
//        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(295.0f, 20.0f, 15.0f, 15.0f)];
//        [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//        [activityView stopAnimating];
//        [activityView setHidesWhenStopped:YES];
//        [self.contentView addSubview:activityView];
//        
//        [contentImgView setImage:[[UIImage imageNamed:@"chat_messageBlue_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.5f, 31.0f, 19.5f, 31.0f)]];
//        
//        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presLong:)];
//        [errorImgView addGestureRecognizer:longPressGesture];
        
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(270.0f, 30.0f, 40.0f, 40.0f)];
        [headImageView setImage:[UIImage imageNamed:@"People-default"]];
        headImageView.layer.borderColor = RGB(238, 238, 238).CGColor;
        [self.contentView addSubview:headImageView];
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0f, 10.0f, 117.0f, 21.0f)];
        [self.contentView addSubview:dateLabel];
        
        contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(55.0f, 30.0f, 235, 55.0f)];
        [self.contentView addSubview:contentImgView];;
        //        
        //        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.5f, 4.5f, MessageText_Width, 20.0f)];
        //        [messageLabel setFont:kFont_Light_16];
        //        [messageLabel setTextAlignment:NSTextAlignmentLeft];
        //        [self.contentImgView addSubview:messageLabel];
        //        
        //        messageLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 220 - 10.0f, 20.0f)];
        //        messageLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        //        messageLabel.customEmojiPlistName = @"Expression_showImage.plist";
        //        [messageLabel setNumberOfLines:0];
        //        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        //        messageLabel.userInteractionEnabled = YES;
        //        contentImgView.userInteractionEnabled = YES;
        //        [self.contentImgView addSubview:messageLabel];
        //test
        
    
        [self initWithLabelLayout:dateLabel];
        [self initWithLabelLayout:messageLabel];
        
        [dateLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [dateLabel setTextAlignment:NSTextAlignmentRight];
        [dateLabel setTextColor:kColor_Editable];
        headImageView.layer.cornerRadius = 4.0f;
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        headImageView.layer.borderWidth = 1.0f;
        
        messageLabel.userInteractionEnabled = YES;
        contentImgView.userInteractionEnabled = YES;
        //        messageLabel = [UILabel initNormalLabelWithFrame:CGRectMake(8.0f, 0.0f, kChat_Message_WIDTH - 10.f, 20.0f) title:@"message"];//modify  by zhangwei map bug "聊天消息过长，显示不正常"
        
        //输入表情时候的正则表达式 将表情显示出来
        messageLabel = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(8.0f, 1.0f, (220 - 10.f), 20.0f)];
        messageLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        messageLabel.customEmojiPlistName = @"Expression_showImage.plist";
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        
        //[messageLabel setBackgroundColor:[UIColor redColor]];
        
        
        [self.contentImgView addSubview:messageLabel];
        
     
        errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(295.0f, 20.0f, 20.0f, 20.0f)];
        [errorImgView setImage:[UIImage imageNamed:@"warn_bg"]];
        [errorImgView setHidden:YES];
        [errorImgView setUserInteractionEnabled:YES];
        [self.contentView addSubview:errorImgView];
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(295.0f, 20.0f, 15.0f, 15.0f)];
        [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activityView stopAnimating];
        [activityView setHidesWhenStopped:YES];
        [self.contentView addSubview:activityView];
        
        [contentImgView setImage:[[UIImage imageNamed:@"chat_messageBlue_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.5f, 31.0f, 19.5f, 31.0f)]];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presLong:)];
        [errorImgView addGestureRecognizer:longPressGesture];
    }
    return self;
}

- (void)initWithLabelLayout:(UILabel *)label
{
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:kFont_Light_16];
    [label setTextAlignment:NSTextAlignmentLeft];
}

- (void)updateData:(MessageDoc *)message headImg:(NSString *) headImg
{
    [headImageView setImageWithURL:[NSURL URLWithString:headImg] placeholderImage:[UIImage imageNamed:@"People-default"]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = CGRectGetHeight(headImageView.bounds) / 2;
    
    [dateLabel setText:message.mesg_SendTime];
    
    self.message = message.mesg_MessageContent;
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:message.mesg_MessageContent];
    NSError *error;
    NSString *regulaStr = @"(((http[s]{0,1})://)?[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:message.mesg_MessageContent options:0 range:NSMakeRange(0, [message.mesg_MessageContent length])];
    
    if(arrayOfAllMatches.count >= 1){
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            [str  addAttributes:@{NSLinkAttributeName:@{NSForegroundColorAttributeName:[UIColor redColor]}} range:match.range];
        }
        NSTextCheckingResult *match = [arrayOfAllMatches firstObject];
        NSString* substringForMatch = [_message substringWithRange:match.range];
        self.urlStr = substringForMatch;
        if ([substringForMatch rangeOfString:@"http://" options:NSCaseInsensitiveSearch].length == 0) {
            self.urlStr = substringForMatch = [NSString stringWithFormat:@"%@%@",@"http://",substringForMatch];
        }
        [messageLabel setAttributedText:str];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoURL:)];
        tap.delegate = self;
        [contentImgView addGestureRecognizer:tap];
        contentImgView.userInteractionEnabled = YES;
    }else{
        messageLabel.emojiText = message.mesg_MessageContent;
    }
  
    

    
//    CGSize size_Msg = [message.mesg_MessageContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(MessageText_Width, FLT_MAX)];
//    self.messageLabel.font = kFont_Light_16;
//    CGSize size_Msg = [self.messageLabel sizeThatFits:CGSizeMake(220, FLT_MAX)];
//    
//    CGRect rect_ContentImgView = self.contentImgView.frame;
//    rect_ContentImgView.size.height = size_Msg.height + 20.0f;
//    if (size_Msg.width > 200) {
//        rect_ContentImgView.size.width = size_Msg.width + 40.0f;
//    } else {
//        rect_ContentImgView.size.width = size_Msg.width + 30.0f;
//    }
//    rect_ContentImgView.origin.x = kSCREN_BOUNDS.size.width - 55.0f - rect_ContentImgView.size.width;
//    [contentImgView setFrame:rect_ContentImgView];
//    
//    [contentImgView setFrame:CGRectMake(265.0f - rect_ContentImgView.size.width, rect_ContentImgView.origin.y, rect_ContentImgView.size.width, rect_ContentImgView.size.height)];
//    
//    CGRect rect_MessageLabel = self.messageLabel.frame;
//    rect_MessageLabel.size.height = (size_Msg.height) + 10.0f;
//    rect_MessageLabel.size.width = (size_Msg.width) + 10.0f;
//    rect_MessageLabel.origin.x = 10.0f;
//    rect_MessageLabel.origin.y = 10.0f;
//    if (rect_MessageLabel.size.width > 220) {
//        rect_MessageLabel.size.width = 220;
//    }
//    [messageLabel setFrame:rect_MessageLabel];
//
    
    
    
    
//
//    self.messageLabel.font = kFont_Light_16;
//    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(220, FLT_MAX)];
    
    CGSize size = [message.mesg_MessageContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(210.0f, 300.0f)];
    CGRect rect_ContentImgView = self.contentImgView.frame;
    rect_ContentImgView.size.height = size.height + 20.0f;
    
    
    
    //    rect_ContentImgView.size.width = message.mesg_MsgWith + 10.0f;
    rect_ContentImgView.size.width = size.width + 15.0f + 10.0f;
    rect_ContentImgView.origin.x = kSCREN_BOUNDS.size.width - 55.0f - rect_ContentImgView.size.width;
    [contentImgView setFrame:rect_ContentImgView];
    
    CGRect rect_MessageLabel = self.messageLabel.frame;
    rect_MessageLabel.size.height = size.height;
    rect_MessageLabel.size.width = size.width;  //remove  by zhangwei map bug "聊天消息过长，显示不正常"
    rect_MessageLabel.origin.y = 10.0f;
    if (rect_MessageLabel.size.width > 220) {
        rect_MessageLabel.size.width =220;
    }
    [messageLabel setFrame:rect_MessageLabel];
    
    
    CGRect rect_Error = self.errorImgView.frame;
    rect_Error.origin.x = contentImgView.frame.origin.x - 20.0f;
    rect_Error.origin.y = contentImgView.frame.origin.y + 6.0f;
    [errorImgView setFrame:rect_Error];
    
    CGRect rect_ActivityView = self.activityView.frame;
    rect_ActivityView.origin.x = contentImgView.frame.origin.x - 20.0f;
    rect_ActivityView.origin.y = contentImgView.frame.origin.y - 6.0f;
    rect_ActivityView.origin.y = contentImgView.frame.origin.y + 10.0f;
    [activityView setFrame:rect_ActivityView];
    
    if (message.mesg_Status == 0) {
        [activityView stopAnimating];
        [errorImgView setHidden:YES];
    } else if (message.mesg_Status == 1) {
        [activityView startAnimating];
        [errorImgView setHidden:YES];
    } else if (message.mesg_Status == 2) {
        [activityView stopAnimating];
        [errorImgView setHidden:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)gotoURL:(UILabel*)sender
{
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    if (url) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否打开该链接？" delegate:nil cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
    }
    
}
@end
