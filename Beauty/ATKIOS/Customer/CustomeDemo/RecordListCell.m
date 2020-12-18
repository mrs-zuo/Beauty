
//
//  RecordListCell.m
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "RecordListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RecordDoc.h"

@interface RecordListCell()
@property (strong,nonatomic) UILabel *pro_Label;
@property (strong,nonatomic) UILabel *sug_Label;

@end

@implementation RecordListCell
@synthesize bgView,timeView,timeImage,dateLabel,suggestionLabel,problemLabel,divisionImage;
@synthesize pro_Label,sug_Label;
@synthesize delegate;
@synthesize creatorLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bgView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 100.0f)];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [bgView.layer setBorderColor:[kColor_TitleOnly CGColor]];
        [bgView.layer setBorderWidth:1.0f];
        bgView.layer.masksToBounds = YES;
        bgView.layer.cornerRadius = 8.0f;
        [[self contentView]addSubview:bgView];
        
        timeView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 30.0f)];
        [timeView setBackgroundColor:kColor_TitleOnly];
        [bgView addSubview:timeView];
        
        timeImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 30.0f)];
        //[timeImage setImage:[UIImage imageNamed:@"timeTitlebg"]];
        [timeView addSubview:timeImage];
        
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 5.0f, 100.0f, 20.0f)];
        dateLabel.font = kFont_Light_16;
        dateLabel.textColor = [UIColor whiteColor];
        [self initializeLabel:dateLabel];
        [timeImage addSubview:dateLabel];
        
        creatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(200.0f, 5.0f, 100.0f, 20.0f)];
        creatorLabel.font = kFont_Light_16;
        creatorLabel.textColor = [UIColor whiteColor];
        creatorLabel.backgroundColor = [UIColor clearColor];
        [creatorLabel setFont:kFont_Light_16];
        [creatorLabel setTextAlignment:NSTextAlignmentRight];
        [timeImage addSubview:creatorLabel];
        
        pro_Label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 34.0f, 180.0f, 20.0f)];
        pro_Label.textColor = kColor_TitlePink;
        [pro_Label setText:@"咨询"];
        pro_Label.font = kFont_Light_16;
        [self initializeLabel:pro_Label];
        [bgView addSubview:pro_Label];
        
        problemLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 58.0f, 290.0f, 20.0f)];
        problemLabel.font = kFont_Light_16;
        problemLabel.textColor = [UIColor blackColor];
        [problemLabel setNumberOfLines:0];
        [self initializeLabel:problemLabel];
        [bgView addSubview:problemLabel];
        
        UIEdgeInsets edDiv = {0.0f, 0.0f, 0.0f, 0.0f};
        divisionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, problemLabel.frame.size.height + problemLabel.frame.origin.y + 4.0f, 310.0f, 1.0f)];
        [divisionImage setImage:[[UIImage imageNamed:@"line"] resizableImageWithCapInsets:edDiv]];
        [bgView addSubview:divisionImage];
        
        sug_Label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, problemLabel.frame.size.height + problemLabel.frame.origin.y + 10.0f, 120.0f, 20.0f)];
        sug_Label.textColor = kColor_TitlePink;
        sug_Label.font = kFont_Light_16;
        [sug_Label setText:@"建议"];
        [self initializeLabel:sug_Label];
        [bgView addSubview:sug_Label];
        
        suggestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 24.0f + sug_Label.frame.origin.y, 290.0f, 20.0f)];
        suggestionLabel.font = kFont_Light_16;
        suggestionLabel.textColor = [UIColor blackColor];
        [suggestionLabel setNumberOfLines:0];
        [self initializeLabel:suggestionLabel];
        [bgView addSubview:suggestionLabel];
    }
    return self;
}

- (void)initializeLabel:(UILabel *)label
{
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:kFont_Light_16];
    [label setTextAlignment:NSTextAlignmentLeft];
}

- (void)updateDate:(RecordDoc *)recordDoc
{
    [dateLabel setText:recordDoc.rec_Time];
    [creatorLabel setText:recordDoc.rec_CreatorName];
    [problemLabel setText:recordDoc.rec_Problem];
    [suggestionLabel setText:recordDoc.rec_Suggestion];
    
    CGSize size_problem = [recordDoc.rec_Problem sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, FLT_MAX)];
    CGSize size_suggestion = [recordDoc.rec_Suggestion sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, FLT_MAX)];
    
    CGRect proFrame = problemLabel.frame;
    proFrame.size.height = size_problem.height;
    [problemLabel setFrame:proFrame];
    
    CGRect divisionImageFrame = divisionImage.frame;
    divisionImageFrame.origin.y = problemLabel.frame.size.height + problemLabel.frame.origin.y + 4.0f;
    [divisionImage setFrame:divisionImageFrame];
    
    CGRect sug_LabelFrame = sug_Label.frame;
    sug_LabelFrame.origin.y = problemLabel.frame.size.height + problemLabel.frame.origin.y + 10.0f;
    [sug_Label setFrame:sug_LabelFrame];
    
    CGRect sugFrame = suggestionLabel.frame;
    sugFrame.origin.y = sug_Label.frame.origin.y + 24.0f;
    sugFrame.size.height = size_suggestion.height;
    [suggestionLabel setFrame:sugFrame];
    
    CGRect bgFrame = bgView.frame;
    bgFrame.size.height =30.0f + 28.0f + size_problem.height + 34.0f + size_suggestion.height + 7.0f;
    [bgView setFrame:bgFrame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
