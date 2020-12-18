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
#import "UILabel+InitLabel.h"

@interface DetailNoticeViewController ()
@property (strong, nonatomic) UITableView *myTableView;
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
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"公告详情";    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height+22) style:UITableViewStyleGrouped];
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = kColor_White;
    [self.view addSubview:myTableView];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        size_noticeContent = [recievenoticeContent sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(272.0f, MAXFLOAT)];
        NSInteger lines = (NSInteger)(size_noticeContent.height / kNormalFont_14.lineHeight);
        return size_noticeContent.height + (lines * 5) + 20;
    } else {
        return kTableView_DefaultCellHeight;
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
        return 0;
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
        static NSString *identifier = @"ContentCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];

           UILabel *nameLab = [UILabel initNormalLabelWithFrame:CGRectMake(kCell_LabelToLeft, (kTableView_HeightOfRow - kCell_LabelHeight)/2, 160, kCell_LabelHeight) title:@"内容"];
            nameLab.textColor = kColor_TitlePink;
            nameLab.font =kNormalFont_14;
            nameLab.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:nameLab];
            UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, nameLab.frame.origin.y + nameLab.frame.size.height, kSCREN_BOUNDS.size.width - 20, kCell_LabelHeight)];
            contentLab.textAlignment = NSTextAlignmentLeft;
            contentLab.font = kNormalFont_14;
            contentLab.tag = kContentLabTag;
            contentLab.numberOfLines = 0;
            contentLab.textColor = kMainGrayColor;
            contentLab.lineBreakMode = NSLineBreakByCharWrapping;
            [cell.contentView addSubview:contentLab];
        }
        UILabel *contentLab = [cell.contentView viewWithTag:kContentLabTag];
        CGRect rect = contentLab.frame;
        NSInteger lines = (NSInteger)(size_noticeContent.height / kNormalFont_14.lineHeight);
        rect.size.height = size_noticeContent.height + (lines * 5);
        contentLab.frame = rect;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:recievenoticeContent];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing  = 5;
        [attributedString setAttributes:@{NSFontAttributeName:kNormalFont_14,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        contentLab.attributedText = attributedString;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

@end
