//
//  RecordListCell.h
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define HEIGHT_CELL_TITLE 39.0f

@class RecordListCell;
@class RecordDoc;
@protocol RecordListCellDelegate <NSObject>
-(void) editeRecordInfoWithRecordListCell:(RecordListCell *)cell;
@end

@interface RecordListCell : UITableViewCell
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *titleBgView;
@property (strong, nonatomic) UIView *contentBgView;
@property (strong, nonatomic) UIView *permitView;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *customerLabel;
@property (strong, nonatomic) UILabel *creatorLabel;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UILabel *problemLabel;
@property (strong, nonatomic) UILabel *suggestionLabel;
@property (strong, nonatomic) UILabel *customerPermit;
@property (strong, nonatomic) UILabel *permitFlag;
@property (strong, nonatomic) UIImageView *divisionImage;

@property (strong, nonatomic) UIImageView *permView;

@property (assign,nonatomic) id<RecordListCellDelegate> delegate;

-(void) updateDate:(RecordDoc *)recordDoc;

@end
