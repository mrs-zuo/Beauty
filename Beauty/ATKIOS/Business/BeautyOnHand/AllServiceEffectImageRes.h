//
//  AllServiceEffectImageRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/22.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllServiceEffectImageRes : NSObject

@property (nonatomic,assign) NSInteger TreatmentImageID;
@property (nonatomic,assign) NSInteger ImageType;
@property (nonatomic,copy) NSString *ThumbnailURL;
@property (nonatomic,copy) NSString *OriginalImageURL;

@end
