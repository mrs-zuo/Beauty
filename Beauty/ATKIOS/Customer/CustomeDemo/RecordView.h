//
//  RecordView.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/5/20.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RecordViewCanceBlock)(void);
typedef void(^RecordViewIndexBlock)(void);
typedef void(^RecordViewExpandBlock)(UIButton *butt ,BOOL showAll);

@interface RecordView : UIView

@property (nonatomic,copy) RecordViewCanceBlock canceBlock;
@property (nonatomic,copy) RecordViewIndexBlock indexBlock;
@property (nonatomic,copy) RecordViewExpandBlock expandBlock;

@property (nonatomic,assign) BOOL isShowAll;
@end
