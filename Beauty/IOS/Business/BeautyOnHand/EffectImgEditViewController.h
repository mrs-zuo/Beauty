//
//  EffectImgEditViewController.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

typedef NS_ENUM(NSInteger, EffectImgEditViewControllerType) {
    EffectImgEditViewControllerType_TG = 0,
    EffectImgEditViewControllerType_TM = 1
};

#import <UIKit/UIKit.h>
#import "PictureDisplayView.h"



@interface EffectImgDoc : NSObject
@property (assign, nonatomic) NSInteger imageID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *originalImgURL;
@end

@interface EffectImgEditViewController : BaseViewController  <PictureDisplayViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *beforeEffectArray;
@property (strong, nonatomic) NSMutableArray *afterEffectArray;
@property (assign, nonatomic) NSInteger treat_ID;
@property (assign, nonatomic) NSInteger customerID;
@property (assign, nonatomic) double groupNo;


@property (nonatomic,assign) EffectImgEditViewControllerType effectType;

@end
