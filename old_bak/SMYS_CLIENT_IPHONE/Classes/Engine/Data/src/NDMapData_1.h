//
//  NDMapData.h
//  MapData
//
//  Created by jhzheng on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NDTile.h"
#import "NDAnimationGroup.h"
#import "UIImageCombiner.h"
#import "NDUILabel.h"

@interface MapTexturePool : NSObject
{
	NSMutableDictionary *m_dict;
}

/** for map render images only need data 
 *	add by xiezhenghai
 */

+ (MapTexturePool *)defaultPool;
+ (void)purgeDefaultPool;

-(CCTexture2D*) addImage:(NSString *)path keepData:(BOOL)keep;

@end



@class NDMapData;
//切屏点
@interface NDMapSwitch : NSObject
{
	int _x, _y, _mapIndex, _passIndex;
	NDUILabel *_lbName[2], *_lbDes[2];
	NSString		*_nameDesMap, *_descDesMap;
}
@property (nonatomic, assign)int x;
@property (nonatomic, assign)int y;
@property (nonatomic, assign)int mapIndex;
@property (nonatomic, assign)int passIndex;
@property (nonatomic, copy)NSString *nameDesMap;
@property (nonatomic, copy)NSString *descDesMap;

- (void)SetLabel:(NDMapData*) mapdata; 
- (void)SetLabelNew:(NDMapData *)mapdata;
- (void)draw;

@end

//布景
@interface NDSceneTile : NDTile
{
	int _orderID;
}
@property (nonatomic, assign)int orderID;

@end


//刷怪区
@interface NDMapMonsterRange : NSObject
{
	int _typeId, _column, _row;
	BOOL _boss;
}
@property (nonatomic, assign)int typeId;
@property (nonatomic, assign)int column;
@property (nonatomic, assign)int row;
@property (nonatomic, assign)BOOL boss;

@end

@interface NDMapData : NSObject {
	NSString		*_name;
	int				_layerCount;
	uint				_columns;
	uint				_rows;
	CGSize			_mapSize;
	int				_unitSize;
	int				_roadBlockX;
	int				_roadBlockY;

	NSMutableArray	*_mapTiles;
	NSMutableArray	*_obstacles;
	NSMutableArray	*_sceneTiles;
	NSMutableArray	*_bgTiles;
	NSMutableArray	*_switchs;
	NSMutableArray	*_animationGroups;
	NSMutableArray  *_aniGroupParams;
	
}
@property (nonatomic, copy)NSString *name;						//地图名
@property (nonatomic, assign, readonly)int layerCount;			//层数
@property (nonatomic, assign, readonly)uint columns;			//列数
@property (nonatomic, assign, readonly)uint rows;				//行数
@property (nonatomic, assign, readonly)int unitSize;				//单元格尺寸数
@property (nonatomic, assign)int roadBlockX;				//X轴路障
@property (nonatomic, assign)int roadBlockY;				//Y轴路障
@property (nonatomic, readonly)NSArray *mapTiles;				//所有地表瓦片
@property (nonatomic, readonly)NSArray *obstacles;				//障碍
@property (nonatomic, readonly)NSArray *sceneTiles;				//所有场景瓦片
@property (nonatomic, readonly)NSArray *bgTiles;				//所有背景瓦片
@property (nonatomic, readonly)NSArray *switchs;				//所有切屏
@property (nonatomic, readonly)NSArray *animationGroups;        //地表动画组
@property (nonatomic, readonly)NSArray *aniGroupParams;         //地表动画参数



/*通过地图文件(不包含路径)加载地图数据
  参数:mapFile-地图文件名
*/
- (id)initWithFile:(NSString *)mapFile;

/*判断某个位置是否可走
  参数:row-某行,column-某列
  返回值:YES/NO
*/
- (BOOL)canPassByRow:(uint)row andColumn:(uint)column;
//- (NDTile *)getTileAtRow:(uint)row column:(uint)column;
- (CustomCCTexture2D *)getTileAtRow:(uint)row column:(uint)column;

- (NDSceneTile *)getBackGroundTile:(uint)index;

- (void)moveBackGround:(int)x moveY:(int)y;

- (void)addObstacleCell:(uint)row andColumn:(uint)column;
- (void)removeObstacleCell:(uint)row andColumn:(uint)column;
- (void)addMapSwitch:(uint)x			// 切屏点 x
				   Y:(uint)y			// 切屏点 y
			   Index:(uint)index		// 切屏点索引
			DesMapID:(uint)mapid		// 目标地图id
		  DesMapName:(NSString*)name	// 目标地图名称
		  DesMapDesc:(NSString*)desc;	// 目标地图描述
- (void)setRoadBlock:(int)x roadBlockY:(int)y;
@end
