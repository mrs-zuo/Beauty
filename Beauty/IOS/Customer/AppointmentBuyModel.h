//
//  AppointmentBuyModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/12/1.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppointmentBuyModel : NSObject

//@property (assign,nonatomic) NSInteger orderID;
//@property (strong, nonatomic) NSString *productName;

//@property (nonatomic,copy) NSString *responsiblePersonName;
@property (nonatomic,assign) NSInteger tGFinishedCount;
@property (nonatomic,assign) NSInteger tGTotalCount;
//@property (nonatomic,assign) NSInteger productType;
@property (nonatomic,assign) NSInteger branchID;



@property (copy, nonatomic) NSString * productName;
@property (copy, nonatomic) NSString * tGStartTime;
@property (copy, nonatomic) NSString * accountName;
@property (copy, nonatomic) NSString * accountID;
@property (copy, nonatomic) NSString * paymentStatus;
@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger finisHedCount;
@property (assign, nonatomic) long long  groupNo;
@property (assign, nonatomic) NSInteger orderID;
@property (copy, nonatomic) NSString * orderObjectID;
@property (assign, nonatomic) NSInteger productType;
@property (copy, nonatomic) NSString * productTypeStatus;
@property (copy, nonatomic) NSString * headImageURL;
@property (assign, nonatomic) NSInteger statusNew;
@property (copy, nonatomic) NSString * customerName;
@property (copy, nonatomic) NSString * customerID;
@property (copy, nonatomic) NSString * isDesignated;
@property (copy, nonatomic) NSString * totalCalcPrice;
@property (assign, nonatomic) NSInteger tGStatus;
@property (copy, nonatomic) NSString * tG_StatusStr;
@property (copy, nonatomic) NSString * tGEndTime;
@property (copy, nonatomic) NSString * serviceName;
@property (copy, nonatomic) NSString * responsiblePersonName;
/*
{
    "Data": [
             {
                 "OrderID": 7801,
                 "ProductName": "胭",
                 "OrderTime": "2015-11-30 15:40",
                 "ResponsiblePersonName": "",
                 "TGFinishedCount": 0,
                 "TGTotalCount": 1,
                 "ProductType": 0,
                 "BranchID": 98
             },
             {
                 "OrderID": 7802,
                 "ProductName": "brddx",
                 "OrderTime": "2015-11-30 15:40",
                 "ResponsiblePersonName": "",
                 "TGFinishedCount": 0,
                 "TGTotalCount": 1,
                 "ProductType": 0,
                 "BranchID": 98
             }
             ],
    "Code": "1",
    "Message": null
}*/
@end
