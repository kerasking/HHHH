//
//  NDMapDataPool.h
//  MapData
//
//  Created by jhzheng on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NDMapData;

@interface NDMapDataPool : NSObject 
{
	NSMutableDictionary	*_mapDatas;	
}

@property (nonatomic, readonly)NSDictionary	*mapDatas;					// 所有地图数据

/* 获取地图池,如果未创建则创建
   返回值: 地图数据池
*/
+ (NDMapDataPool*)sharedMapDataPool;

/* 释放地图数据池
*/
+ (void)purgeSharedMapDataPool;

/* 通过地图文件名加载地图返回地图数据
   参数: 地图文件名(不包括路径)
   返回值: 地图数据
*/
- (NDMapData*)addMapDataWithFileName:(NSString*)mapFile;

/* 通过地图文件名索引加载地图返回地图数据
   参数: 地图文件名索引	
   返回值: 地图数据
 */
- (NDMapData*)addMapDataWithFileNameIndex:(NSUInteger)index;

/* 通过地图文件名加载地图返回地图数据
 参数: 地图文件名(不包括路径)
 返回值: 地图数据
 */
- (void)removeMapDataWithFileName:(NSString*)mapFile;

/* 通过地图文件名索引加载地图返回地图数据
 参数: 地图文件名索引	
 返回值: 地图数据
 */
- (void)removeMapDataWithFileNameIndex:(NSUInteger)index;

@end


