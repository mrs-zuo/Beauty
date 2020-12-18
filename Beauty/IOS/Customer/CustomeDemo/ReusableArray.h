//
//  ReusableArray.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-20.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.

//  Designed  by  wei
/*
 *  复用数组主要解决解决以下问题：
 *  1、内存分配是一种昂贵的操作（操作系统有介绍），而网络请求返回时，一次性解析json大数组为本地object数组时候，
 * 要不断的分配内存，而事实上很多时候这些数据并不会全部用到，也不会一次性用到
 *  2、解决内存的碎片化问题，不断的申请和释放内存，将导致内存严重碎片化，加重内存分配操作的负担
 *  3、减少CPU使用，减小续航压力
 *
 *  适用范围：不需要交互的静态列表页
 *  当然，这还只是一个初步的方案，还需要进行改进支持交互乃至于更强大
 */
#import <Foundation/Foundation.h>

@protocol ReusableArrayDelegate <NSObject>

@required

///#begin zh-cn
/**
 *      @brief   本协议返回一个 NSindexPath的数组
 */
///#end

-(NSArray *)getObjectsOnShown;

///#begin zh-cn
/**
 *      @brief   数组要保存的数据的数量，和实际数量（显示的个数）相对
 */
///#end

-(NSUInteger)vitrualCount;

@end

@interface ReusableArray : NSArray

@property (assign) id<ReusableArrayDelegate> delegate;

///#begin zh-cn
/**
 *      @brief    tableView:cellForRowAtIndexPath: 调用
 *                     获取“未使用数组”中的一个对象实例的引用；
 *                     如果“未使用数组”为空，则在显示的字典里面查找有没有未被显示的对象，然后将其移到“未使用数组”;
 *                     如果“未使用数组”依旧为空，则new一个新对象，加入显示字典，否则从“未使用数组”中找一个对象的引用返回
 */
///#end

-(id)getObjectWithClass:(Class)cls indexPath:(NSIndexPath *)indexPath;



///#begin zh-cn
/**
 *      @brief   tableView: didSelectRowAtIndexPath:调用
 *                       获取点击cell所对应的数据模型
 */
///#end

- (id)getObjectWithIndexPath:(NSIndexPath *)indexPath;

///#begin zh-cn
/**
 *      @brief   tableView: numberOfRowsInSection: 调用，告诉tableView有多少行要显示
 */
///#end

- (NSUInteger)Count;

@end
