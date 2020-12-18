//
//  WSRight.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-31.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#define kWSPrecision 24.0f

#define kWSHeight_TitleCell 52.0f

#define kWSHeight_NormalCell 44.0f

@protocol WSScrollViewDelegate <NSObject>
-(void)WSScrollViewDidScroll:(UIScrollView *)WSScrollView;
@end