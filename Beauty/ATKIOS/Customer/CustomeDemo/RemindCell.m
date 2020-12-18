//
//  RemindCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-20.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "RemindCell.h"
#import "RemindDoc.h"
#import "ChatViewController.h"

@implementation RemindCell
@synthesize contentLabel;//用来显示提醒的内容

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColor_White;
        contentLabel = [[RichTextView alloc] initWithFrame:CGRectMake(5.0f, 10.0f, kSCREN_BOUNDS.size.width - 20, 20)];
        contentLabel.textColor = [UIColor blackColor];
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [contentLabel setFont:kNormalFont_14];
        [contentLabel setUserInteractionEnabled:YES];
        [self addSubview:contentLabel];
    }
    return self;
}
-(void)updateDate:(RemindDoc *)remind
{
    self.remindDoc = remind;
    NSString *contentStr = @"";
    
    if (remind.ResponsiblePersonName.length > 0 && remind.BranchPhone.length >0 ) {
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请拨打门店咨询电话%@或联系服务顾问(%@%@)。",[remind.TaskScdlStartTime substringToIndex:16],remind.BranchName,remind.TaskName,remind.BranchPhone,remind.ResponsiblePersonName,remind.remind_ExecutorNum];
        
    } else if(remind.ResponsiblePersonName.length == 0 && remind.BranchPhone.length > 0 ){
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请拨打门店咨询电话%@。",[remind.TaskScdlStartTime substringToIndex:16],remind.BranchName,remind.TaskName,remind.BranchPhone];
        
    }else if (remind.ResponsiblePersonName.length > 0 && remind.BranchPhone.length == 0 ){
        
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务，如有疑问，请联系服务顾问(%@%@)。",[remind.TaskScdlStartTime substringToIndex:16],remind.BranchName,remind.TaskName,remind.ResponsiblePersonName,remind.remind_ExecutorNum];
    }else
    {
        contentStr = [NSString stringWithFormat:@"您预约在%@到%@接受%@服务。",[remind.TaskScdlStartTime substringToIndex:16],remind.BranchName,remind.TaskName];
    }
    
    contentLabel.richReplaceTextRunArray = [[NSMutableArray alloc]init];
    contentLabel.richReplaceTextColorRunArray = [[NSMutableArray alloc]init];
    contentLabel.richPersonIdArray = [[NSMutableArray alloc]init];
    
    // run
    if(remind.remind_ExecutorNum)
        [contentLabel.richReplaceTextRunArray addObject:remind.remind_ExecutorNum];
    [contentLabel.richPersonIdArray addObject:@(remind.ResponsiblePersonID)];
    
    //设置字体变红
    if(remind.ResponsiblePersonName)
        [contentLabel.richReplaceTextColorRunArray addObject:remind.ResponsiblePersonName];

    if(remind.TaskScdlStartTime)
        [contentLabel.richReplaceTextColorRunArray addObject:[remind.TaskScdlStartTime substringToIndex:16]];
    
    if(remind.TaskName)
        [contentLabel.richReplaceTextColorRunArray addObject:remind.TaskName];
    
    if(remind.BranchPhone)
        [contentLabel.richReplaceTextColorRunArray addObject:remind.BranchPhone];
    
    if(remind.BranchName)
        [contentLabel.richReplaceTextColorRunArray addObject:remind.BranchName];
    
    contentLabel.textColor = [UIColor redColor];
    contentLabel.text = contentStr;
    contentLabel.delegate = self;
    
    
    CGSize sizeRemindContent = [contentStr sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(280.f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    NSInteger lines = (NSInteger)(sizeRemindContent.height / kNormalFont_14.lineHeight);
    CGRect proFrame = contentLabel.frame;
    proFrame.size.height = sizeRemindContent.height + (5 * (lines - 1)) + 10;
    contentLabel.frame = proFrame;
    
}

-(NSMutableAttributedString *)attributedStringFromStingWithString:(NSString *)string withFont:(UIFont *)font withLineSpacing:(CGFloat)lineSpacing
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:font}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    return attributedStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)richTextView:(RichTextView *)richTextView touchBeginRun:(RichTextViewBaseRun *)run
{

}

-(void)richTextView:(RichTextView *)richTextView touchEndRun:(RichTextViewBaseRun *)run
{
    if (run.textRunType == richTextImageRunType)
    {
        RemindCell *cell;
        if (IOS7)
            cell = (RemindCell*)richTextView.superview.superview.superview.superview;
        else
            cell = (RemindCell*)richTextView.superview.superview.superview;
        
        if(run.personID == _remindDoc.ResponsiblePersonID)
            [self goToChatPersonID:_remindDoc.ResponsiblePersonID andName:_remindDoc.ResponsiblePersonName andHeadImage:_remindDoc.HeadImageURL andChat_Use:_remindDoc.ResponsiblePersonChat_Use];
        else if(run.personID == _remindDoc.ResponsiblePersonID)
            [self goToChatPersonID:_remindDoc.ResponsiblePersonID andName:_remindDoc.ResponsiblePersonName andHeadImage:_remindDoc.HeadImageURL andChat_Use:_remindDoc.ResponsiblePersonChat_Use];
        
        NSLog(@"the image has been clicked!%@  %@",[cell class] ,run.originalText);
    }
}

-(void)goToChatPersonID:(NSInteger)personID andName:(NSString*)name andHeadImage:(NSString*)headImageURL andChat_Use:(BOOL)Chat_Use
{
    _remindViewController.hidesBottomBarWhenPushed = YES;
    NSArray *array = [name componentsSeparatedByString:@"-"];
    name = (NSString *)[array objectAtIndex:0];
    ChatViewController *chatview = (ChatViewController *) [self.remindViewController.storyboard instantiateViewControllerWithIdentifier:@"ChatView"];
    MessageDoc *msg = [[MessageDoc alloc] init];
    msg.mesg_AccountID = personID;
    msg.mesg_AccountName = name;
    msg.mesg_HeadImageURL = headImageURL;
    msg.mesg_Available = 1;
    if(Chat_Use)
        msg.mesg_Chat_Use = 1;
    else
        msg.mesg_Chat_Use = 0;
    chatview.selectAccount = msg;
    [_remindViewController.navigationController pushViewController:chatview animated:YES];
}

@end
