//
//  BeautyRecordPhotoTableViewCell.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TapImage) (UIImageView *imgView,NSMutableArray *arrs);
@interface BeautyRecordPhotoTableViewCell : UITableViewCell

@property(nonatomic,strong)NSMutableArray *tGList;

@property (nonatomic,assign,getter=isAddImage) BOOL addImage;
@property (nonatomic,strong) id data;

@property (nonatomic,copy) TapImage tapImage;
@end
