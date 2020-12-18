
//
//  RecordListCell.m
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "RecordListCell.h"
#import "RecordDoc.h"
#import "DEFINE.h"
#import "UILabel+InitLabel.h"
#import "UIButton+InitButton.h"

#define DISPLAYWIDTH    160.0
#define CELLWIDTH       310.0
@interface RecordListCell()
@property (strong,nonatomic) UILabel *pro_Label;
@property (strong,nonatomic) UILabel *sug_Label;

@end

@implementation RecordListCell
@synthesize titleBgView, contentBgView, editButton;
@synthesize dateLabel,suggestionLabel,problemLabel,divisionImage;
@synthesize pro_Label,sug_Label;
@synthesize delegate;
@synthesize bgView;
@synthesize creatorLabel, customerLabel;
@synthesize customerPermit;
@synthesize permitFlag;
@synthesize permitView;
@synthesize permView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // -- TitleView
        titleBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, HEIGHT_CELL_TITLE)];
        [titleBgView setBackgroundColor:BACKGROUND_COLOR_TITLE];
        
        dateLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 0, 100.0f, HEIGHT_CELL_TITLE) title:@"--"];
        dateLabel.font = kFont_Light_16;
        dateLabel.textColor = [UIColor whiteColor];
        //GPB-1399 取消咨询记录编辑功能 增加一行记录人
        /*
        editButton = [UIButton buttonWithTitle:@""
                                        target:self
                                      selector:@selector(editButtonAction)
                                         frame:CGRectMake(270.0f, (HEIGHT_CELL_TITLE - 36.0f)/2, 36.0f, 36.0f)
                                 backgroundImg:[UIImage imageNamed:@"icon_Edit2"]
                              highlightedImage:nil];
        [titleBgView addSubview:editButton];
        */
        permView = [[UIImageView alloc] initWithFrame:CGRectMake(127.0f, (HEIGHT_CELL_TITLE - 24 ) / 2, 24, 24)];
        
        permView.image = [UIImage imageNamed:@"kejian"];
        
        customerLabel = [UILabel initNormalLabelWithFrame:CGRectMake(152.0f, 0.0f, 75.0f, HEIGHT_CELL_TITLE - 1.0f) title:@"--"];
        customerLabel.textAlignment = NSTextAlignmentRight;
        customerLabel.font = kFont_Light_16;
        customerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        customerLabel.textColor = [UIColor whiteColor];

//        UILabel *customerLine = [UILabel initNormalLabelWithFrame:CGRectMake(0.0f, HEIGHT_CELL_TITLE - 1, 312.0f, 1.0f) title:@""];
//        customerLine.backgroundColor = BACKGROUND_COLOR_TITLE;

        
        creatorLabel = [UILabel initNormalLabelWithFrame:CGRectMake(225.0f, 0.0f, 80.0f, HEIGHT_CELL_TITLE - 1.0f) title:@"--"];
        creatorLabel.textAlignment = NSTextAlignmentLeft;
        creatorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        creatorLabel.font = kFont_Light_16;
        creatorLabel.textColor = [UIColor whiteColor];
        
        
        [titleBgView addSubview:dateLabel];
        
        [titleBgView addSubview:permView];
        
        [titleBgView addSubview:customerLabel];

        [titleBgView addSubview:creatorLabel];

        
//        UILabel *lineLabel = [UILabel initNormalLabelWithFrame:CGRectMake(0.0f, HEIGHT_CELL_TITLE * 2 - 1, 312.0f, 1.0f) title:@""];
//        lineLabel.backgroundColor = BACKGROUND_COLOR_TITLE;
//        [createrView addSubview:lineLabel];
        
        
        // -- ContentView
        contentBgView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, titleBgView.frame.size.height + titleBgView.frame.origin.y, 310.0f, 100.0f)];
        [contentBgView setBackgroundColor:[UIColor clearColor]];
        
        pro_Label = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 5.0f, 180.0f, 20.0f) title:@"咨询"];
        pro_Label.textColor = kColor_DarkBlue;
        pro_Label.font = kFont_Light_16;
        [contentBgView addSubview:pro_Label];
        
        problemLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 26.0f, 295.0f, 20.0f) title:@"--"];
        problemLabel.font = kFont_Light_16;
        problemLabel.textColor = [UIColor blackColor];
        problemLabel.numberOfLines = 0;
        [contentBgView addSubview:problemLabel];
        
        divisionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, problemLabel.frame.size.height +  problemLabel.frame.origin.y + 10.0f, 312.0f, 1.0f)];
     //   [divisionImage setImage:[[UIImage imageNamed:@"line"] resizableImageWithCapInsets:{0.0f, 0.0f, 0.0f, 0.0f}]];
        divisionImage.backgroundColor = BACKGROUND_COLOR_TITLE;
//        divisionImage.backgroundColor = [UIColor redColor];
        [contentBgView addSubview:divisionImage];
        
        sug_Label = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, problemLabel.frame.size.height +  problemLabel.frame.origin.y + 10.0f, 120.0f, 20.0f) title:@"建议"];
        sug_Label.textColor = kColor_DarkBlue;
        sug_Label.font = kFont_Light_16;
        [contentBgView addSubview:sug_Label];
        
        suggestionLabel = [UILabel initNormalLabelWithFrame:CGRectMake(10.0f, 22.0f + sug_Label.frame.origin.y, 295.0f, 20.0f) title:@"--"];
        suggestionLabel.font = kFont_Light_16;
        suggestionLabel.textColor = [UIColor blackColor];
        suggestionLabel.numberOfLines = 0;
        [contentBgView addSubview:suggestionLabel];
        
        
//    --追加咨询查看权限
        permitView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, contentBgView.frame.size.height + contentBgView.frame.origin.y, 310.0f, HEIGHT_CELL_TITLE)];
        [permitView setBackgroundColor:[UIColor whiteColor]];
        UIImageView *tagView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 5, 30, 30)];
        tagView.image = [UIImage imageNamed:@"biaoqian"];
        
        customerPermit = [UILabel initNormalLabelWithFrame:CGRectMake(42.0f, 0, 260,HEIGHT_CELL_TITLE ) title:@""];
        customerPermit.textColor = [UIColor blackColor];
        customerPermit.font = kFont_Light_16;
        customerPermit.textAlignment = NSTextAlignmentLeft;
        [permitView addSubview:tagView];
        [permitView addSubview:customerPermit];
        
        CALayer *lineLayer = [CALayer layer];
        lineLayer.frame = CGRectMake(0.0f, 0.0f, permitView.frame.size.width, 1.0f);
        lineLayer.backgroundColor = BACKGROUND_COLOR_TITLE.CGColor;
        
        [permitView.layer addSublayer:lineLayer];

    // --
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 100.0f)];
        
        
        [bgView addSubview:titleBgView];
        [bgView addSubview:contentBgView];
        [bgView addSubview:permitView];
        
        bgView.backgroundColor = [UIColor clearColor];
        bgView.layer.cornerRadius = 4.0f;
        bgView.layer.masksToBounds = YES;
        [[self contentView] addSubview:bgView];

        
        self.backgroundColor = [UIColor whiteColor];
        
        if (![[PermissionDoc sharePermission] rule_Record_Write])  {
            [editButton removeFromSuperview];
            editButton = nil;
        }
    }
    return self;
}

- (void)editButtonAction
{
    if ([delegate respondsToSelector:@selector(editeRecordInfoWithRecordListCell:)]) {
        [delegate editeRecordInfoWithRecordListCell:self];
    }
}

- (void)updateDate:(RecordDoc *)recordDoc
{

    customerPermit.text = recordDoc.TagName;
    permView.image = (recordDoc.IsVisible ? [UIImage imageNamed:@"kejian"] : [UIImage imageNamed:@"bukejian"]);
    
    NSString *creatString = [NSString stringWithFormat:@"|%@",recordDoc.ResponsiblePersonName];//(kMenu_Type == 0 ? recordDoc.CreatorName : recordDoc.ResponsiblePersonName)
    CGSize creatSize = [creatString sizeWithFont:kFont_Light_16 forWidth:80.0 lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGRect creatFrame = CGRectMake(CELLWIDTH - creatSize.width - 5.0f, (HEIGHT_CELL_TITLE - 24 ) / 2, creatSize.width, 24);
    
    creatorLabel.frame = creatFrame;
    
    CGSize customerSize = [recordDoc.CustomerName sizeWithFont:kFont_Light_16 forWidth:(DISPLAYWIDTH - creatSize.width) lineBreakMode:NSLineBreakByTruncatingTail];

    customerLabel.frame = CGRectMake(CELLWIDTH - customerSize.width - creatSize.width - 5.0f, (HEIGHT_CELL_TITLE - 24 ) / 2, customerSize.width, 24);
    
    creatorLabel.text = creatString;

    customerLabel.text = recordDoc.CustomerName;

    
    CGRect seeFrame = CGRectMake(customerLabel.frame.origin.x - 26, (HEIGHT_CELL_TITLE - 24 ) / 2, 24, 24);
    permView.frame = seeFrame;
    
    dateLabel.text = recordDoc.RecordTime;
    problemLabel.text = recordDoc.Problem;
    suggestionLabel.text = recordDoc.Suggestion;
    //咨询问题内容显示
    CGRect proFrame = problemLabel.frame;
    proFrame.size.height = recordDoc.height_Problem ;
    [problemLabel setFrame:proFrame];
    
    //咨询与建议 间隔线
    CGRect divisionImageFrame = divisionImage.frame;
    divisionImageFrame.origin.y = problemLabel.frame.size.height + problemLabel.frame.origin.y;
    [divisionImage setFrame:divisionImageFrame];
    
    //建议的位置
    CGRect sug_LabelFrame = sug_Label.frame;
    sug_LabelFrame.origin.y = problemLabel.frame.size.height + problemLabel.frame.origin.y + 5.0f ; //+10.0f
    [sug_Label setFrame:sug_LabelFrame];
    
    
    //建议内容
    CGRect sugFrame = suggestionLabel.frame;
    sugFrame.origin.y = sug_Label.frame.origin.y + sug_Label.frame.size.height;//+ 10.0f
    sugFrame.size.height = recordDoc.height_Suggestion; // + 10.0f
    [suggestionLabel setFrame:sugFrame];
    
    CGRect contentBgViewFrame = contentBgView.frame;
    contentBgViewFrame.origin.y = titleBgView.frame.size.height + titleBgView.frame.origin.y;
    contentBgViewFrame.size.height = 50.0f +recordDoc.height_Problem + recordDoc.height_Suggestion;//40 + ~51 = 2 * 20 + 5 + 6
    [contentBgView setFrame:contentBgViewFrame];
    
    //顾客查看权限
    CGRect permitViewFrame = permitView.frame;
    permitViewFrame.origin.y = contentBgView.frame.size.height + 40.0f;
    [permitView setFrame:permitViewFrame];
//
    CGRect bgFrame = bgView.frame;
    bgFrame.size.height = contentBgView.frame.size.height + titleBgView.frame.size.height + permitView.frame.size.height;
    [bgView setFrame:bgFrame];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
