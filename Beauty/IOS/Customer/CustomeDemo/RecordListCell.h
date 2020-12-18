//
//  RecordListCell.h
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordListCell;
@class RecordDoc;
@protocol RecordListCellDelegate <NSObject>

-(void) deleteRecordInfoWithRecordListCell:(RecordListCell *)cell;
-(void) editeRecordInfoWithRecordListCell:(RecordListCell *)cell;

@end

@interface RecordListCell : UITableViewCell

@property (strong,nonatomic) UIView *bgView;
@property (strong,nonatomic) UIView *timeView;
@property (strong,nonatomic) UILabel *dateLabel;
@property (strong,nonatomic) UILabel *creatorLabel;
@property (strong,nonatomic) UILabel *problemLabel;
@property (strong,nonatomic) UILabel *suggestionLabel;
@property (strong,nonatomic) UIImageView *timeImage;
@property (strong,nonatomic) UIImageView *divisionImage;

@property (assign,nonatomic) id<RecordListCellDelegate> delegate;

-(void) updateDate:(RecordDoc *)recordDoc;

@end
