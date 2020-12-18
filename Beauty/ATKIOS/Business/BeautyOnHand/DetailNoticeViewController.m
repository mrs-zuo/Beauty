//
//  DetailNoticeViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-7.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//
const NSInteger kContentLabTag = 100000;

#import "DetailNoticeViewController.h"
#import "GDataXMLNode.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "NoticeDoc.h"
#import "TwoLabelCell.h"
#import "TitleView.h"
#import "UILabel+InitLabel.h"

@interface DetailNoticeViewController ()
@property(assign, nonatomic) CGSize size_noticeContent;
@end

@implementation DetailNoticeViewController
@synthesize myTableView;
@synthesize recievenoticeContent;
@synthesize recieveNoticeTime;
@synthesize recieveNoticeTitle;
@synthesize size_noticeContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [myTableView setFrame:CGRectMake(5.0f, 41.0f, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 41.0f - 5.0f)];
    }
    
    TitleView *titleView = [[TitleView alloc] init];
    [self.view addSubview:[titleView getTitleView:@"公告详情"]];
    
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

//-(void )tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == 2){
//         UITextView *textView = (UITextView *)[cell.contentView viewWithTag:100];
//        CGRect rect = textView.frame;
//        rect.size.height = size_noticeContent.height + 15;
//        textView.frame = rect;
//        cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    }
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
//        size_noticeContent = [recievenoticeContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, 420.0f)];
//        return size_noticeContent.height + 50;
        size_noticeContent = [recievenoticeContent sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(272.0f, MAXFLOAT)];
        NSInteger lines = (NSInteger)(size_noticeContent.height / kFont_Light_16.lineHeight);
        return size_noticeContent.height + (lines * 5) + 20 + (kTableView_HeightOfRow - 20);

    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = @"NoticeCell";
    TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[TwoLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        [cell setTitle:@"标题"];
        [cell setValue:recieveNoticeTitle isEditing:NO];
        return cell;
    } else if (indexPath.row == 1) {
        [cell setTitle:@"时间"];
        [cell setValue:recieveNoticeTime isEditing:NO];
        return cell;
    } else {
//        static NSString *cellIndentify = @"contentCell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        }
//        UITextView *textView = (UITextView *)[cell.contentView viewWithTag:100];
//        [textView setEditable:NO];
//        [textView setText:recievenoticeContent];
//        [textView setFont:kFont_Light_16];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.backgroundColor = [UIColor redColor];
//        textView.backgroundColor = [UIColor greenColor];
//        return cell;
        static NSString *identifier = @"ContentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            
            UILabel *nameLab = [UILabel initNormalLabelWithFrame:CGRectMake(5, (kTableView_HeightOfRow - 20)/2, 100, 20) title:@"内容"];
            nameLab.textColor = kColor_DarkBlue;
            nameLab.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:nameLab];
            UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, nameLab.frame.origin.y + nameLab.frame.size.height + 5, kSCREN_BOUNDS.size.width - 20, kCell_LabelHeight)];
            contentLab.textAlignment = NSTextAlignmentLeft;
            contentLab.font = kFont_Light_16;
            contentLab.tag = kContentLabTag;
            contentLab.numberOfLines = 0;
            contentLab.lineBreakMode = NSLineBreakByCharWrapping;
            [cell.contentView addSubview:contentLab];
        }
        UILabel *contentLab = [cell.contentView viewWithTag:kContentLabTag];
        CGRect rect = contentLab.frame;
        NSInteger lines = (NSInteger)(size_noticeContent.height / kFont_Light_16.lineHeight);
        rect.size.height = size_noticeContent.height + (lines * 5);
        contentLab.frame = rect;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:recievenoticeContent];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing  = 5;
        [attributedString setAttributes:@{NSFontAttributeName:kFont_Light_16,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        contentLab.attributedText = attributedString;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;

    }
}

@end
