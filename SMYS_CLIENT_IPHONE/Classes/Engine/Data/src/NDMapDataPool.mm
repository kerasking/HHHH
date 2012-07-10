//
//  NDMapDataPool.m
//  MapData
//
//  Created by jhzheng on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDMapDataPool.h"
#import "NDMapData.h"
#import "NDPath.h"

static NDMapDataPool*	shareMapDataPool;

@interface NDMapDataPool(heidden)

- (void) addMapData:(NDMapData*)mapData WithFileName:(NSString*)mapFile;

@end


@implementation NDMapDataPool

@synthesize mapDatas = _mapDatas;	

/* 获取地图池,如果未创建则创建
 返回值: 地图数据池
 */
+ (NDMapDataPool*)sharedMapDataPool
{
	if (!shareMapDataPool) 
	{
		shareMapDataPool = [[NDMapDataPool alloc] init];
	}
	
	return shareMapDataPool;
}

/* 释放地图数据池
 */
+ (void)purgeSharedMapDataPool
{
	[shareMapDataPool release];
}

+(id)alloc
{
	NDAsssert(shareMapDataPool == nil);
	return [super alloc];
}

-(id)init
{
	if( (self=[super init]) ) 
	{
		_mapDatas = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	}
	
	return self;
}

-(void)dealloc
{
	[_mapDatas release];
	shareMapDataPool = nil;
	[super dealloc];
}

- (void)addMapData:(NDMapData*)mapData WithFileName:(NSString*)mapFile
{
	if([_mapDatas objectForKey: mapFile])
	{
		return;
	}
	
	[_mapDatas setObject:mapData forKey:mapFile];
}


/* 通过地图文件名加载地图返回地图数据
 参数: 地图文件名(不包括路径)
 返回值: 地图数据
 */
- (NDMapData*)addMapDataWithFileName:(NSString*)mapFile
{
	if (![_mapDatas objectForKey: mapFile])
	{		
		if (![[NSFileManager defaultManager] fileExistsAtPath:mapFile]) 
		{
			return nil;
		}
		
		NDMapData *data = [[NDMapData alloc] initWithFile:mapFile];
		[self addMapData:data WithFileName:mapFile];
		[data release];
	}
	return [_mapDatas objectForKey: mapFile];
}

/* 通过地图文件名索引加载地图返回地图数据
 参数: 地图文件名索引	
 返回值: 地图数据
 */
- (NDMapData*)addMapDataWithFileNameIndex:(NSUInteger)index
{
	NSString *mapFile = [NSString stringWithFormat:@"map_%d.map", index];
	
	return [self addMapDataWithFileName:mapFile];
}

/* 通过地图文件名加载地图返回地图数据
 参数: 地图文件名(不包括路径)
 返回值: 地图数据
 */
- (void)removeMapDataWithFileName:(NSString*)mapFile
{
	[_mapDatas removeObjectForKey:mapFile];
}

/* 通过地图文件名索引加载地图返回地图数据
 参数: 地图文件名索引	
 返回值: 地图数据
 */
- (void)removeMapDataWithFileNameIndex:(NSUInteger)index
{
	NSString *mapFile = [NSString stringWithFormat:@"map_%d.map", index];
	
	[self removeMapDataWithFileName:mapFile];
}
	
@end
