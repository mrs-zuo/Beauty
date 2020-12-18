//
//  IndexCollectionViewCell.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/21.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "IndexCollectionViewCell.h"
#import "RecommendedProductListRes.h"

@implementation IndexCollectionViewCell


- (void)awakeFromNib {
    
}

-(void)setData:(id)data
{
    if ([data isKindOfClass:[RecommendedProductListRes class]]) {
        RecommendedProductListRes *res = (RecommendedProductListRes *)data;
        [_imgView setImageWithURL:[NSURL URLWithString:res.ThumbnailURL] placeholderImage:[UIImage imageNamed:@"collectDefaultImage"] options:SDWebImageCacheMemoryOnly];
        _nameLab.text = res.ProductName;
    }
}
@end
