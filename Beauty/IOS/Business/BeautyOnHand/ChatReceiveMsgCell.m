//
//  ChatReceiveMsgCell.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-12.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ChatReceiveMsgCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+InitLabel.h"
#import "MessageDoc.h"
#import "DEFINE.h"
#import "PublicMethod.h"
#import "UIAlertView+AddBlockCallBacks.h"

#define HeadImage_WIDTH 40.0f

@implementation ChatReceiveMsgCell
@synthesize headImageView, stateLabel, dateLabel, contentImgView, messageLabel;
@synthesize errorImgView, activityView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(275.0f, 20.0f, HeadImage_WIDTH, HeadImage_WIDTH)];
        [headImageView setImage:[UIImage imageNamed:@"loading_HeadImg40"]];
        [self.contentView addSubview:headImageView];
        
//        headImageView.layer.cornerRadius = 3.0f;
//        headImageView.layer.masksToBounds = YES;
//        headImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        headImageView.layer.borderWidth = 1.0f;
//        headImageView.layer.shadowOpacity = 0.6f;
//        headImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
//        headImageView.layer.shadowOffset = CGSizeMake(-2.0f, 4.0f);
//        
//        
        headImageView.layer.shadowOffset = CGSizeZero;
        headImageView.layer.shadowOpacity = 0.8f;
        headImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:headImageView.layer.bounds] CGPath];
        
        // -----
        stateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(320.0f - 65.0f - 120.0f, 5.0f, 115.0f, 15.0f) title:@"点阅0/发送2"];
        dateLabel  = [UILabel initNormalLabelWithFrame:CGRectMake(320.0f - 65.0f - 120.0f, 5.0f, 120.0f, 15.0f) title:@"2013-09-03 04:54:34"];
        stateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.textAlignment = NSTextAlignmentRight;
        //[self.contentView addSubview:stateLabel];
        [self.contentView addSubview:dateLabel];
        
        CGRect dateRect = self.dateLabel.frame;
        dateRect.origin.x = 320.0f - 65.0f - 120.0f;
        dateLabel.frame = dateRect;
        
        CGRect stateRect = self.stateLabel.frame;
        stateRect.origin.x = dateRect.origin.x - 120.0f;
        stateLabel.frame = stateRect;
        
        
        stateLabel.font = kFont_Light_12;
        dateLabel.font  = kFont_Light_12;
        stateLabel.textColor = [UIColor blackColor];
        dateLabel.textColor  = kColor_Editable;
        
        // ---
        UIImage *bg_image = [UIImage imageNamed:@"chat_messageWhite_bg"];
        contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(320.0f - 50.0f, 20.0f, 230.0f, 55.0f)];
        contentImgView.image = [bg_image stretchableImageWithLeftCapWidth:floor(bg_image.size.width/ 2) topCapHeight:floor(bg_image.size.height/ 2)];
//        contentImgView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:contentImgView];
        
        //test
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkUrlAndGoTo:)];
        tap.delegate = self;
        [contentImgView addGestureRecognizer:tap];
        messageLabel.userInteractionEnabled = YES;
        contentImgView.userInteractionEnabled = YES;
//        messageLabel = [UILabel initNormalLabelWithFrame:CGRectMake(8.0f, 0.0f, kChat_Message_WIDTH - 10.f, 20.0f) title:@"message"];//modify  by zhangwei map bug "聊天消息过长，显示不正常"
//        messageLabel = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(8.0f, 0.0f, kChat_Message_WIDTH - 10.f, 20.0f)];
//        messageLabel = [MLEmojiLabel initMLEmoLabelWithFrame:CGRectMake(12.0f, 0.0f, kChat_Message_WIDTH - 10.f, 20.0f) title:@"message"];
        messageLabel = [MLEmojiLabel initMLEmoLabelWithFrame:CGRectZero title:@"message"];
//        messageLabel = (MLEmojiLabel *)[MLEmojiLabel initNormalLabelWithFrame:CGRectMake(8.0f, 0.0f, kChat_Message_WIDTH - 10.f, 20.0f) title:@"message"];
        messageLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        messageLabel.customEmojiPlistName = @"Expression_showImage.plist";
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentImgView addSubview:messageLabel];
        
        // --
        errorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(295.0f, 30.0f, 20.0f, 20.0f)];
        [errorImgView setImage:[UIImage imageNamed:@"warn_bg"]];
        [errorImgView setHidden:YES];
        [errorImgView setUserInteractionEnabled:YES];
        [self.contentView addSubview:errorImgView];
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(295.0f, 30.0f, 15.0f, 15.0f)];
        [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [activityView stopAnimating];
        [activityView setHidesWhenStopped:YES];
        [self.contentView addSubview:activityView];
        
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

- (void)updateData:(MessageDoc *)message
{
    [headImageView setImageWithURL:[NSURL URLWithString:message.mesg_FromUserImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    [stateLabel setText:[NSString stringWithFormat:@"点阅%ld/发送%ld", (long)message.mesg_ReadMsgCount,  (long)message.mesg_AllMsgCount]];
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
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
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


    /*
    [dateLabel setText:message.mesg_SendTime];
    
    PublicMethod *check =   [[PublicMethod alloc] init];
    NSArray *array =  [check checkString:message.mesg_MessageContent];
    
    if ([array count]) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:message.mesg_MessageContent];
        for (NSValue *va in array) {
            NSRange range =  [va rangeValue];
            //@{NSLinkAttributeName:@{NSForegroundColorAttributeName:[UIColor redColor]}}
            [att  addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} range:range];
        }
        messageLabel.attributedText = att;
    } else {
        messageLabel.emojiText = message.mesg_MessageContent;
    }
    */
    
    
    if (message.mesg_GroupFlag  == 1) {
        self.stateLabel.hidden = NO;
        self.dateLabel.hidden = NO;
        [stateLabel setText:[NSString stringWithFormat:@"点阅%ld/发送%ld", (long)message.mesg_ReadMsgCount,  (long)message.mesg_AllMsgCount]];
        [dateLabel setText:message.mesg_SendTime];
    } else {
        self.stateLabel.hidden = YES;
        self.dateLabel.hidden = NO;
        [stateLabel setText:[NSString stringWithFormat:@"点阅%ld/发送%ld", (long)message.mesg_ReadMsgCount,  (long)message.mesg_AllMsgCount]];
        [dateLabel setText:message.mesg_SendTime];
    }
    
    self.messageLabel.font = kFont_Light_16;
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(kChat_Message_WIDTH, FLT_MAX)];

    CGRect rect_ContentImgView = self.contentImgView.frame;
    rect_ContentImgView.size.height = size.height + 20.0f;
    rect_ContentImgView.size.width = size.width + 15.0f + 10.0f;
    rect_ContentImgView.origin.x = kSCREN_BOUNDS.size.width - 55.0f - rect_ContentImgView.size.width;
    [contentImgView setFrame:rect_ContentImgView];
    
    UIImage *bg_image = [UIImage imageNamed:@"chat_messageWhite_bg"];
    contentImgView.image = [bg_image stretchableImageWithLeftCapWidth:floor(bg_image.size.width/ 2) topCapHeight:floor(bg_image.size.height/ 2)];
    
    
    CGRect rect_MessageLabel = self.messageLabel.frame;
    rect_MessageLabel.size.height =size.height;
    rect_MessageLabel.size.width = size.width;//remove  by zhangwei map bug "聊天消息过长，显示不正常"
    rect_MessageLabel.origin.x = 10.0f;
    rect_MessageLabel.origin.y = 10.0f;
    if (rect_MessageLabel.size.width > kChat_Message_WIDTH) {
        rect_MessageLabel.size.width = kChat_Message_WIDTH;
    }
    [messageLabel setFrame:rect_MessageLabel];
    
    
    
    
    
    CGRect rect_Error = self.errorImgView.frame;
    rect_Error.origin.x = contentImgView.frame.origin.x - 25.0f;
    [errorImgView setFrame:rect_Error];
    
    CGRect rect_ActivityView = self.activityView.frame;
    rect_ActivityView.origin.x = contentImgView.frame.origin.x - 25.0f;
    [activityView setFrame:rect_ActivityView];

    
//    CGRect rect_ContentImgView = self.contentImgView.frame;
//    rect_ContentImgView.size.height = message.mesg_MsgHegiht;
//    rect_ContentImgView.size.width = message.mesg_MsgWith + 15.0f + 10.0f;
//    rect_ContentImgView.origin.x = kSCREN_BOUNDS.size.width - 55.0f - rect_ContentImgView.size.width;
//    [contentImgView setFrame:rect_ContentImgView];
//    
//    UIImage *bg_image = [UIImage imageNamed:@"chat_messageWhite_bg"];
//    contentImgView.image = [bg_image stretchableImageWithLeftCapWidth:floor(bg_image.size.width/ 2) topCapHeight:floor(bg_image.size.height/ 2)];
//    
//    
//    CGRect rect_MessageLabel = self.messageLabel.frame;
//    rect_MessageLabel.size.height = message.mesg_MsgHegiht;
//    rect_MessageLabel.size.width = message.mesg_MsgWith; //remove  by zhangwei map bug "聊天消息过长，显示不正常"
//    if (rect_MessageLabel.size.width > kChat_Message_WIDTH) {
//        rect_MessageLabel.size.width = kChat_Message_WIDTH;
//    }
//    [messageLabel setFrame:rect_MessageLabel];
//    
//    CGRect rect_Error = self.errorImgView.frame;
//    rect_Error.origin.x = contentImgView.frame.origin.x - 25.0f;
//    [errorImgView setFrame:rect_Error];
//    
//    CGRect rect_ActivityView = self.activityView.frame;
//    rect_ActivityView.origin.x = contentImgView.frame.origin.x - 25.0f;
//    [activityView setFrame:rect_ActivityView];
    
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
//
- (void)checkUrlAndGoTo:(id)sender
{
//    UIImageView *image =(UIImageView *) ((UIGestureRecognizer *)sender).view;
//    UILabel *label = [[image subviews] firstObject];
//    
//    PublicMethod *check =   [[PublicMethod alloc] init];
//    NSArray *array =  [check checkString:label.text];
//    
//    if ([array count]){
//        for (NSValue *resu in array) {
//            NSString *str = [label.text substringWithRange:[resu rangeValue]];
//            NSURL *url = nil;
//
//            if ([str rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location != NSNotFound || [str rangeOfString:@"ftp://" options:NSCaseInsensitiveSearch].location != NSNotFound )
//            {
//                url = [NSURL URLWithString:str];
//            }else {
//                url  = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",str]];
//            }
//            if (url) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"是否打开该链接？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//                [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    if (buttonIndex == 0) {
//                        [[UIApplication sharedApplication] openURL:url];
//                    }
//                }];
//            }
//        }
//    }

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
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
