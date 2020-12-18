//
//  DEFINE.h
//  GlamourPromise
//
//  Created by TRY-MAC01 on 13-6-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 颜色标准 ------------------------------------------------------------------------------------------
//主要颜色
#define kMainColor [UIColor colorWithRed:247.0/255.0f green:84.0/255.0f blue:131.0/255.0f alpha:1.0f]
//黑色
#define kMainBlackColor [UIColor colorWithRed:30.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f]
//深灰色
#define kMainGrayColor [UIColor colorWithRed:113.0/255.0f green:113.0/255.0f blue:113.0/255.0f alpha:1.0f]
//浅灰色
#define kMainLightGrayColor [UIColor colorWithRed:136.0/255.0f green:136.0/255.0f blue:136.0/255.0f alpha:1.0f]
//红色
#define kMainRedColor [UIColor colorWithRed:195.0/255.0f green:13.0/255.0f blue:35.0/255.0f alpha:1.0f]
//蓝色
#define kMainBlueColor [UIColor colorWithRed:0.0/255.0f green:159.0/255.0f blue:232.0/255.0f alpha:1.0f]
//橙色
#define kMainOrangeColor [UIColor colorWithRed:233.0/255.0f green:85.0/255.0f blue:19.0/255.0f alpha:1.0f]
//绿色
#define kMainGreenColor [UIColor colorWithRed:141.0/255.0f green:194.0/255.0f blue:131.0/255.0f alpha:1.0f]

//粉红
#define kMainPinkColor [UIColor colorWithRed:241.0/255.0f green:124.0/255.0f blue:131.0/255.0f alpha:1.0f]

//默认背景颜色
#define kDefaultBackgroundColor RGBA(238, 238, 238, 1)

//清除背景色
#define kColor_Clear [UIColor clearColor]

//系统颜色
#define kColor_Black  [UIColor blackColor]                                                                          //黑色字体
#define kColor_White  [UIColor whiteColor]

#pragma mark - 按钮颜色标准 ------------------------------------------------------------------------------------------
#define kButtonColor_Pink [UIColor colorWithRed:246.0/255.0f green:146.0/255.0f blue:149.0/255.0f alpha:1.0f]


#pragma mark - 字体标准 ------------------------------------------------------------------------------------------
#define kNormalFont_28  [UIFont systemFontOfSize:28.0f]
#define kNormalFont_14  [UIFont systemFontOfSize:14.0f]
#define kNormalFont_12  [UIFont systemFontOfSize:12.0f]
#define kNormalFont_16  [UIFont systemFontOfSize:16.0f]


#pragma mark - UITableView 标准 ------------------------------------------------------------------------------------------

#define kTableView_DefaultHeaderViewHeight 5.9
#define kTableView_DefaultFooterViewHeight 0.1
#define kTableView_DefaultCellHeight 50
#define kTableView_SecondCellHeight 70
#define kTableView_ThirdCellHeight 100


#pragma mark - UILabel 标准 ------------------------------------------------------------------------------------------

#define kLabel_DefaultHeight 20












//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#pragma mark - 系统UI高
#define kNavigationBar_Height 64
#define kToolBar_Height 49
#define kStateBar_Height 20


#pragma mark - 设备相关 ------------------------------------------------------------------------------------------
//__IPHONE_OS_VERSION_MAX_ALLOWED
#define IOS9   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
#define IOS7   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define IOS6   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
#define kSCREN_BOUNDS  [[UIScreen mainScreen] applicationFrame]



#pragma mark - tableView相关 ------------------------------------------------------------------------------------------

#define kTableView_Width 312

#pragma mark - title相关 ------------------------------------------------------------------------------------------

#define kTitle_Width 312
#define kTitle_Height 36
#define kTitle_X 4
#define kTitle_Y 5
#define kTitle_TitleLabelX 10    //title上label距离左侧的距离


#pragma mark - URL ------------------------------------------------------------------------------------------

#define kGPBaseURLString @"https://capi.beauty.glamise.com"
//#define kGPBaseURLString @"http://10.0.0.109:8888"
#define kGPBaseURLString_Demo @"https://capi.beauty.glamourpromise.com"
#define kGPBaseURLString_Test @"https://capi.test.beauty.glamise.com"


#pragma mark - PhotoSize ------------------------------------------------------------------------------------------

#define kBusiness_Height 135*2        //Business图片尺寸
#define kBusiness_Width  135*2        //^
#define kTwoDimensionalCode_Size 9    //TwoDimensionalCode尺寸


#pragma mark - Color ------------------------------------------------------------------------------------------

/// NavBar前景色
#define KColor_NavBarTintColor [UIColor colorWithRed:205.0/255.0f green:186.0/255.0f blue:162.0/255.0f alpha:1.0f]
/// 所有按钮背景颜色
#define kColor_BtnBackground [UIColor colorWithRed:182.0f / 255.0f green:165.0f / 255.0f blue:145.0f / 255.0f alpha:1.0f]
/// 所有边框的颜色
#define kColor_Border [UIColor colorWithRed:236.0f / 255.0f green:236.0f / 255.0f blue:236.0f / 255.0f alpha:1.0f].CGColor
/// 搜索前景色
#define kColor_SearchBarTint [UIColor colorWithRed:240.0f / 255.0f green:240.0f / 255.0f blue:240.0f / 255.0f alpha:1.0f]


#define KColor_SaveDanTitleColor [UIColor colorWithRed:150.0/255.0f green:150.0/255.0f blue:150.0/255.0f alpha:1.0f]

#define KColor_appointmentCellTitleColor [UIColor colorWithRed:110.0/255.0f green:110.0/255.0f blue:110.0/255.0f alpha:1.0f]

#define KColor_Blue [UIColor colorWithRed:18.0/255.0f green:141.0/255.0f blue:227.0/255.0f alpha:1.0f] 

#define kColor_TitlePink [UIColor colorWithRed:127.0/255.0f green:110.0f/255.0f blue:90.0f/255.0f alpha:1.0f]        //所有页面标题汉字的颜色（深灰色）
#define kColor_Editable  [UIColor grayColor]                                                                         //灰色字体
#define kColor_myGrayColor [UIColor colorWithRed:248.0/255.0f green:248.0/255.0f blue:248.0/255.0f alpha:1.0f]       //促销背景颜色--文字背景

#define kTableView_LineColor [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1]
  //tableView的line颜色
#define kColor_FootView [UIColor colorWithRed:250.0/255.0f green:248.0f/255.0f blue:245.0f/255.0f alpha:1.0f]  //tableView的line颜色
#define kColor_TitleOnly [UIColor colorWithRed:213.0/255.0f green:197.0f/255.0f blue:181.0f/255.0f alpha:1.0f]  //tableView的line颜色



#pragma mark - Font ------------------------------------------------------------------------------------------

#define kFont_Light_10 [UIFont fontWithName:@"STHeitiSC-Light" size:10.0f]
#define kFont_Light_12 [UIFont fontWithName:@"STHeitiSC-Light" size:12.0f]
#define kFont_Light_13 [UIFont fontWithName:@"STHeitiSC-Light" size:13.0f]
#define kFont_Light_14 [UIFont fontWithName:@"STHeitiSC-Light" size:14.0f]
#define kFont_Light_15 [UIFont fontWithName:@"STHeitiSC-Light" size:15.0f]
#define kFont_Light_16 [UIFont fontWithName:@"STHeitiSC-Light" size:16.0f]
#define kFont_Light_17 [UIFont fontWithName:@"STHeitiSC-Light" size:17.0f]
#define kFont_Light_18 [UIFont fontWithName:@"STHeitiSC-Light" size:18.0f]
#define kFont_Medium_12 [UIFont fontWithName:@"STHeitiSC-Medium" size:12.0f]
#define kFont_Medium_14 [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f]
#define kFont_Medium_16 [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f]
#define kFont_Medium_18 [UIFont fontWithName:@"STHeitiSC-Medium" size:18.0f]
#define kFont_Medium_22 [UIFont fontWithName:@"STHeitiSC-Medium" size:22.0f]

#define kFont_Number_Menu_12 [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:12.0f]
#define kFont_Number_Menu_14 [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14.0f]
#define kFont_Number_Menu_16 [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.0f]


#pragma mark - TableViewSpacing ------------------------------------------------------------------------------------------

#define kTableView_Margin 2.0f                  //tableView group间距
#define kTableView_WithTitle 5.0f               //tableView group与title的间距
#define kTableView_HeightOfRow 38.0f            //单行tableView cell高度
#define kTableView_HeightOfRow_Single 50.0f     //两行tableView cell高度
#define kTableView_HeightOfRow_Multiline 62.0f  //三行tableView cell高度
#define kTableView_Margin_TOP 5.9f              //顶部间隔
#define kTableView_Margin_Bottom 0.1f           //底部间隔


#pragma mark - CellSpacing ------------------------------------------------------------------------------------------

#define kCell_LabelToLeft 10.0f                  //cell里label到左边的间距
#define kCell_LabelHeight 20.0f                  //label的高度


#pragma mark - Time ------------------------------------------------------------------------------------------

#define kTime_Interval 24   //获取提醒、公告等处所设置的时间间隔


#pragma mark - Other ------------------------------------------------------------------------------------------

//#define ThirdPartyPush_Enable NO  // 是否使用第三方推送

//#define NSLog(format, ...)  fprintf(stderr, "\n>>>>>>>>>>>>>>>>>>>>\n"); fprintf(stderr, "<%s : %d> %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__, __func__); (NSLog)((format), ##__VA_ARGS__); fprintf(stderr, "<<<<<<<<<<<<<<<<<<<<\n");//A wrong version of NSLog
#define  APPSOTRELINK @"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"

#define CUS_CURRENCYTOKEN      [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_CURRENCYTOKEN"]
#define CUS_ADVANCED [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_ADVANCED"]
#define CUS_COMPANYCODE [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYCODE"]
#define CUS_COMPANYID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYID"] integerValue]
#define CUS_BRANCHID  [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_BRANCHID"] integerValue]
#define CUS_CUSTOMERID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue]
#define CUS_ISBUSINESS 0 ////modified by zhangwei for new function BUY_SERVICE (0 is customer,1 and null is business) 2014.7.9




