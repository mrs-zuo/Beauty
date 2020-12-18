//
//  SalesProcessCell.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SalesProgressCellDelegate <NSObject>
- (void)chickStepButtonWithIndex:(NSInteger)index;
@end

@class OpportunityDoc;
@interface SalesProgressCell : UITableViewCell
@property (weak, nonatomic) id<SalesProgressCellDelegate> delegate;

- (void)updateData:(OpportunityDoc *)opportunityDoc;
@end
