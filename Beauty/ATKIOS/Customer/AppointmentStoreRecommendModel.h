//
//  AppointmentStoreRecommendModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppointmentStoreRecommendModel : NSObject
@property (assign, nonatomic) long long ProductCode;
@property (assign, nonatomic) long ProductID;
@property (copy, nonatomic) NSString *ProductName;
@property (assign, nonatomic) CGFloat UnitPrice;
@property (assign, nonatomic) NSInteger SortID;
@property (assign, nonatomic) BOOL New;
@property (nonatomic,copy) NSString *Recommended;
@property (copy, nonatomic) NSString *ThumbnailURL;
@property (nonatomic,copy) NSString *SearchField;
@property (copy, nonatomic) NSString *Specification;
@property (assign, nonatomic) NSInteger ProductType;


@property (nonatomic,strong) NSArray *BranchList;


- (instancetype)initWithDic:(NSDictionary *)dic;
/*
{
    "Data": [
             {
                 "ProductCode": 1507080000000001,
                 "ProductID": 1798,
                 "ProductName": "粗略",
                 "UnitPrice": 100,
                 "SortID": 16,
                 "New": false,
                 "Recommended": false,
                 "ThumbnailURL": "",
                 "SearchField": "粗略|",
                 "Specification": null,
                 "ProductType": 0
             },
             {
                 "ProductCode": 1507080000000002,
                 "ProductID": 1678,
                 "ProductName": "daf",
                 "UnitPrice": 100,
                 "SortID": 17,
                 "New": false,
                 "Recommended": false,
                 "ThumbnailURL": "",
                 "SearchField": "daf|",
                 "Specification": null,
                 "ProductType": 0
             }
             ],
    "Code": "1",
    "Message": null
}
 */
@end
