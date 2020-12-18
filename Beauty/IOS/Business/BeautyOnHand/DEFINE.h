//
//  DEFINE.h
//  GlamourPromise
//
//  Created by GuanHui on 13-6-25.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define IOS13  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
#define IOS9   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0000 ? YES : NO)
#define IOS7_0   [[[UIDevice currentDevice] systemVersion] floatValue] == 7.0
#define IOS7_1   [[[UIDevice currentDevice] systemVersion] floatValue] == 7.1
#define IOS6   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

#define kORIGIN_Y  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? 0.0f : 0.0f)

#define kSCREN_BOUNDS   [[UIScreen mainScreen] bounds]
#define kSCREN_480   ([[UIScreen mainScreen] bounds].size.height == 480)
#define kSCREN_568   ([[UIScreen mainScreen] bounds].size.height == 568)

#define kMenu_Type [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_MENU_TYPE"] intValue]

#define ACC_COMPANTID      [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANTID"] integerValue]
#define ACC_BRANCHID       [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_BRANCHID"] integerValue]  // BranchId = 0 则没有Branch
#define ACC_ACCOUNTID      [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue]
#define ACC_ACCOUNTName    [[NSUserDefaults standardUserDefaults]  objectForKey:@"ACCOUNT_NAME"]
#define ACC_ACCOUNTHeadImg [[NSUserDefaults standardUserDefaults]  objectForKey:@"ACCOUNT_HEADIMAGE"]
#define ACC_COMPANTCODE    [[NSUserDefaults standardUserDefaults]  objectForKey:@"ACCOUNT_COMPANTCODE"]
#define ACC_COMPANTSCALE   [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANTSCALE"] integerValue]

#define MoneyIcon          [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_CURRENCY_ICON"]

#define ACC_LAST_LoginMoblie [[NSUserDefaults standardUserDefaults] objectForKey:@"ACC_LAST_LoginMoblie"]
#define SettlementCurrency [[[NSUserDefaults standardUserDefaults] objectForKey:@"SettlementCurrency"] intValue]

#define OrderTotalSalePrice_Write [[[NSUserDefaults standardUserDefaults] objectForKey:@"OrderTotalSalePrice_Write"] boolValue]
#define Money_Out           [[[NSUserDefaults standardUserDefaults] objectForKey:@"Money_Out"] boolValue]

#define ACC_RSAUSERID       [[NSUserDefaults standardUserDefaults] objectForKey:@"RSA_USERID"]
#define ACC_RSAPWD          [[NSUserDefaults standardUserDefaults] objectForKey:@"RSA_PWD"]

#define TAG(indexPath)    ((indexPath).section * 20 + (indexPath).row)
#define INDEX(viewtag)    ([NSIndexPath indexPathForRow:(viewtag) % 20 inSection:(viewtag) / 20]);
#define RMO(Flag)    ([[[PermissionDoc sharePermission] record_marketing_oppotun] rangeOfString:(Flag)].length > 0 ? YES : NO)


#define HEIGHT_NAVIGATION_VIEW  36.0f
#define kTableView_Margin 2.0f                  //tableView group间距
#define kTableView_WithTitle 5.0f               //tableView group与title的间距
// --服务器路径
// --10月之后
#define kGPBaseURLString      @"https://api.beauty.glamise.com"
//#define kGPBaseURLString       @"http://10.0.0.112:3324"

#define kGPBaseURLString_Demo   @"https://api.beauty.glamourpromise.com" 
#define kGPBaseURLString_Test  @"https://api.test.beauty.glamise.com"
#define kSOAPHeader_UserName @"GlamourPromiseUser"
#define kSOAPHeader_UserPwd  @"resUesimorPruomalG"

// --Image
#define kImage_CompressSize CGSizeMake(1280.0f, 1280.0f)

// --Display
//字体
#define kFont_Light_10 [UIFont fontWithName:@"STHeitiSC-Light" size:10.0f]
#define kFont_Light_12 [UIFont fontWithName:@"STHeitiSC-Light" size:12.0f]
#define kFont_Light_13 [UIFont fontWithName:@"STHeitiSC-Light" size:13.0f]
#define kFont_Light_14 [UIFont fontWithName:@"STHeitiSC-Light" size:14.0f]
#define kFont_Light_15 [UIFont fontWithName:@"STHeitiSC-Light" size:15.0f]
#define kFont_Light_16 [UIFont fontWithName:@"STHeitiSC-Light" size:16.0f]
#define kFont_Light_17 [UIFont fontWithName:@"STHeitiSC-Light" size:17.0f]
#define kFont_Light_18 [UIFont fontWithName:@"STHeitiSC-Light" size:18.0f]
#define kFont_Light_20 [UIFont fontWithName:@"STHeitiSC-Light" size:20.0f]

#define kFont_Medium_12 [UIFont fontWithName:@"STHeitiSC-Medium" size:12.0f]
#define kFont_Medium_14 [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f]
#define kFont_Medium_16 [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f]
#define kFont_Medium_17 [UIFont fontWithName:@"STHeitiSC-Medium" size:17.0f]
#define kFont_Medium_18 [UIFont fontWithName:@"STHeitiSC-Medium" size:18.0f]

#define kColor_Background_View [UIColor colorWithRed:217.0/255.0f green:239.0f/255.0f blue:247.0f/255.0f alpha:1.0f]
#define BACKGROUND_COLOR_TITLE [UIColor colorWithRed:109.0f/255.0f green:204.0f/255.0f blue:244.0f/255.0f alpha:1.0f]
#define STOCK_COLOR         [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0f]

#define kColor_CellView_Backgroud   [UIColor colorWithRed:246.0f/255.0f green:255.0f/255.0f blue:246.0f/255.0f alpha:1.0f]


//字体颜色
#define kColor_Editable  [UIColor grayColor]
#define kColor_LightBlue [UIColor colorWithRed:30.0/255.0f green:194.0f/255.0f blue:254.0f/255.0f alpha:1.0f]
#define kColor_DarkBlue  [UIColor colorWithRed: 7.0/255.0f green: 63.0f/255.0f blue:160.0f/255.0f alpha:1.0f]
#define kColor_SysBlue   [UIColor colorWithRed: 0.0/255.0f green: 122.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
#define kColor_TitlePink [UIColor colorWithRed:127.0/255.0f green:110.0f/255.0f blue:90.0f/255.0f alpha:1.0f]
#define kColor_Black  [UIColor blackColor]
#define kColor_White [UIColor whiteColor]
#define KColor_Blue [UIColor colorWithRed:18.0/255.0f green:141.0/255.0f blue:227.0/255.0f alpha:1.0f]
#define KColor_Red [UIColor colorWithRed:252.0/255.0f green:75.0/255.0f blue:82.0/255.0f alpha:1.0f]
#define kColor_BackgroudBlue  [UIColor colorWithRed: 12.0/255.0f green: 87.0f/255.0f blue:157.0f/255.0f alpha:1.0f]
#define kColor_ButtonBlue  [UIColor colorWithRed: 62.0/255.0f green: 190.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

//line颜色
#define kTableView_LineColor  [UIColor colorWithRed:142.0f/255.0f green:209.0f/255.0f blue:238.0f/255.0f alpha:0.8f]
#define kTableView_Margin_TOP 4.9f
#define kTableView_Margin_Bottom 0.1f
#define kTableView_HeightOfRow 38.0f
//背景颜色
#define kCellView_backColor  [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f]
// --Other
#define kChat_Message_WIDTH 220.0f

// -- Function
#define MoneyFormat(money) SettlementCurrency == 0 ? [NSString stringWithFormat:@"%@%.2f", (MoneyIcon), (money)]: [NSString stringWithFormat:@"%.2f", (money)]
#define kCell_LabelHeight 20.0f                  //label的高度


// -- 图表颜色
#define ChartColor_1 [UIColor colorWithRed:182/255.0 green:4/255.0 blue:4/255.0 alpha:1.0]
#define ChartColor_2 [UIColor colorWithRed:182/255.0 green:71/255.0 blue:4/255.0 alpha:1.0]
#define ChartColor_3 [UIColor colorWithRed:182/255.0 green:146/255.0 blue:4/255.0 alpha:1.0]
#define ChartColor_4 [UIColor colorWithRed:113/255.0 green:182/255.0 blue:4/255.0 alpha:1.0]
#define ChartColor_5 [UIColor colorWithRed:38/255.0 green:182/255.0 blue:4/255.0 alpha:1.0]
#define ChartColor_6 [UIColor colorWithRed:4/255.0 green:182/255.0 blue:125/255.0 alpha:1.0]
#define ChartColor_7 [UIColor colorWithRed:4/255.0 green:151/255.0 blue:182/255.0 alpha:1.0]
#define ChartColor_8 [UIColor colorWithRed:4/255.0 green:79/255.0 blue:182/255.0 alpha:1.0]
#define ChartColor_9 [UIColor colorWithRed:4/255.0 green:8/255.0 blue:182/255.0 alpha:1.0]
#define ChartColor_10 [UIColor colorWithRed:92/255.0 green:4/255.0 blue:182/255.0 alpha:1.0]
#define ChartColor_11 [UIColor colorWithRed:167/255.0 green:4/255.0 blue:182/255.0 alpha:1.0]

// SVHUd
#define kSvhudtimer 2


#ifdef DEBUG_MODE
#define DLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif



