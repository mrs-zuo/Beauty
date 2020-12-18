//
//  ServiceRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceRes : NSObject

@property (nonatomic,assign)NSInteger RecordCount;
@property (nonatomic,assign)NSInteger PageCount;
@property (nonatomic,strong)NSMutableArray *TGList;

@end
