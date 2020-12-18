//
//  AppointmentStoreModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
//门店model
@interface AppointmentStoreModel : NSObject
@property (nonatomic, assign) NSInteger BranchID;
@property (nonatomic, copy) NSString *BranchName;

- (instancetype)initWithDic:(NSDictionary *)dic;
//{
//    "Data": [
//             {
//                 "BranchID": 13123,
//                 "BranchName": "粗略"
//             },
//             {
//                 "BranchID": 13123,
//                 "BranchName": "粗略"
//             }
//             ],
//    "Code": "1",
//    "Message": null
//}
@end
