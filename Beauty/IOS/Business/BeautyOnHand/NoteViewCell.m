//
//  NoteViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-10.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "NoteViewCell.h"
#import "Note.h"

@interface NoteViewCell ()

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UIImageView *stateImage;


@end



@implementation NoteViewCell
@synthesize title, stateImage;
@synthesize content;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];//kCellView_backColor
        content = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 290, 70 - 20.0f)];
        content.textAlignment = NSTextAlignmentLeft;
        content.textColor = [UIColor blackColor];
        content.lineBreakMode = NSLineBreakByTruncatingTail;
        content.numberOfLines = 0;
        content.font = kFont_Light_15;
        if (IOS6) {
            content.backgroundColor = [UIColor clearColor];
        }
        stateImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, content.frame.size.height, 15, 10)];
        stateImage.image = [UIImage imageNamed:@"jiantou"];
        
        [self.contentView addSubview:content];
        [self.contentView addSubview:stateImage];
        
    }
    
    
    return self;
    
}

- (void)showAllContent:(Note *)note
{
    CGSize sizeToFit;
    CGRect contentFrame = content.frame;
    self.content.text = note.Content;
    sizeToFit = [content.text sizeWithFont:kFont_Light_15 constrainedToSize:CGSizeMake(290, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    if (sizeToFit.height < 52.0) {
        stateImage.hidden = YES;
        contentFrame.origin.y = 0;
        contentFrame.size.height = fmaxf(sizeToFit.height + 10, 38);
        content.frame = contentFrame;

        note.height = contentFrame.size.height;
    } else {
        stateImage.hidden = NO;
        if (note.showContent) {
            contentFrame.origin.y = 10;
            contentFrame.size.height = sizeToFit.height;
            content.frame = contentFrame;
            
        } else {
            contentFrame.origin.y = 10;
            contentFrame.size.height = 50;
            content.frame = contentFrame;
        }
        stateImage.frame = CGRectMake(285, content.frame.size.height + 10, 15, 10);
        
        stateImage.image = [UIImage imageNamed:(note.showContent ? @"jiantou" : @"jiantoux")];
        note.height = (note.showContent ? sizeToFit.height + 25 : 75);

    }

}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
