//
//  NDWorldMapData.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 世界地图数据的加载
 */

#import <Foundation/Foundation.h>
#import "NDMapData.h"

@interface PlaceNode : NSObject
{
	int _placeId, _x, _y, _lDir, _rDir, _tDir, _bDir;
	NSString* _name;
	NSString* _description;
	CCTexture2D *_texture;
}
@property (nonatomic, assign)int placeId;
@property (nonatomic, retain)CCTexture2D* texture;
@property (nonatomic, assign)int x;	
@property (nonatomic, assign)int y;
@property (nonatomic, assign)int lDir;
@property (nonatomic, assign)int rDir;
@property (nonatomic, assign)int tDir;
@property (nonatomic, assign)int bDir;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *description;

@end

typedef struct PASS_WAY
{
	int fromMapID;
	int fromPassIndex;
	int desMapID;
	
	PASS_WAY(int mapID, int passIndex, int desMapID)
	{
		this->fromMapID = mapID;
		this->fromPassIndex = passIndex;
		this->desMapID = desMapID;
	}
}PassWay; 


@interface NDWorldMapData : NSObject 
{
	NSString		*_name;
	int				_layerCount;
	uint			_columns;
	uint			_rows;
	CGSize			_mapSize;
	int				_unitSize;
	
	NSMutableArray	*_mapTiles;
	NSMutableArray	*_sceneTiles;
	NSMutableArray  *_bgTiles;
	NSMutableArray	*_animationGroups;
	NSMutableArray  *_aniGroupParams;
	NSMutableArray  *_placeNodes;
	
}
@property (nonatomic, copy)NSString *name;						//地图名
@property (nonatomic, assign, readonly)int layerCount;			//层数
@property (nonatomic, assign, readonly)uint columns;			//列数
@property (nonatomic, assign, readonly)uint rows;				//行数
@property (nonatomic, assign, readonly)CGSize mapSize;
@property (nonatomic, assign, readonly)int unitSize;
@property (nonatomic, readonly)NSArray *mapTiles;				//所有地表瓦片
@property (nonatomic, readonly)NSArray *bgTiles;				//所有背景
@property (nonatomic, readonly)NSArray *sceneTiles;				//所有场景瓦片
@property (nonatomic, readonly)NSArray *animationGroups;        //地表动画组
@property (nonatomic, readonly)NSArray *aniGroupParams;         //地表动画参数
@property (nonatomic, readonly)NSArray *placeNodes;

+ (id)SharedData;

- (NDTile *)getTileAtRow:(uint)row column:(uint)column;
- (int) getDestMapIdWithSourceMapId:(int)mapId passwayIndex:(int)passwayIndex;
- (PlaceNode *)getPlaceNodeWithMapId:(int)mapId;
@end
