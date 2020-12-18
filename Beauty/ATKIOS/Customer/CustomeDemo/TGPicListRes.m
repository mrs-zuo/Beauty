//
//  TGPicListRes.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/2.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "TGPicListRes.h"

@implementation TGPicListRes
-(void)setImageURL:(NSString *)imageURL
{
   _imageURL = [imageURL componentsSeparatedByString:@"&"].firstObject;
}
@end
