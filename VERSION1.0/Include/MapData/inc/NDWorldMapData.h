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

#ifndef _ND_WORLD_MAP_DATA_H_
#define _ND_WORLD_MAP_DATA_H_

#include "NDMapData.h"

class PlaceNode : public cocos2d::CCObject
{
	CC_SYNTHESIZE_RETAIN(CCTexture2D*, m_Texture, Texture)
	CC_PROPERTY(int, m_nPlaceId, PlaceId)
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nLDir, LDir)
	CC_PROPERTY(int, m_nRDir, RDir)
	CC_PROPERTY(int, m_nTDir, TDir)
	CC_PROPERTY(int, m_nBDir, BDir)
	CC_PROPERTY(std::string, m_Name, Name)
	CC_PROPERTY(std::string, m_Description, Description)
};

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


class NDWorldMapData : public cocos2d::CCObject
{
public:
	class anigroup_param : public cocos2d::CCObject, public std::map<std::string, int>{};
	
	CC_PROPERTY(std::string, m_Name, Name)
	CC_PROPERTY_READONLY(int, m_nLayerCount, LayerCount)
	CC_PROPERTY_READONLY(unsigned int, m_nColumns, Columns)
	CC_PROPERTY_READONLY(unsigned int, m_nRows, Rows)
	CC_PROPERTY_READONLY(int, m_nUnitSize, UnitSize)
	CC_PROPERTY_READONLY(CCSize, m_MapSize, MapSize)

	CC_PROPERTY_READONLY(CCArray<CustomCCTexture2D*>*, m_MapTiles, MapTiles)
	CC_PROPERTY_READONLY(CCArray<NDSceneTile*>*, m_SceneTiles, SceneTiles)
	CC_PROPERTY_READONLY(CCArray<NDSceneTile*>*, m_BgTiles, BgTiles)
	CC_PROPERTY_READONLY(CCArray<NDAnimationGroup*>*, m_AnimationGroups, AnimationGroups)
	CC_PROPERTY_READONLY(CCArray<anigroup_param*>*, m_AniGroupParams, AniGroupParams)
	CC_PROPERTY_READONLY(CCArray<PlaceNode*>*, m_PlaceNodes, PlaceNodes)

public:
	static NDWorldMapData* SharedData();

	NDTile * getTileAtRow(unsigned int row, unsigned int column);
	int getDestMapIdWithSourceMapId(int mapId, int passwayIndex);
	PlaceNode * getPlaceNodeWithMapId(int mapId);

private:
	void initWithFile(const char* mapFile);
	void decode(FILE* stream);

	NSString		*_name;
	int				_layerCount;
	uint			_columns;
	uint			_rows;
	CCSize			_mapSize;
	int				_unitSize;
	
	NSMutableArray	*_mapTiles;
	NSMutableArray	*_sceneTiles;
	NSMutableArray  *_bgTiles;
	NSMutableArray	*_animationGroups;
	NSMutableArray  *_aniGroupParams;
	NSMutableArray  *_placeNodes;
	
};

@property (nonatomic, copy)NSString *name;						//地图名
@property (nonatomic, assign, readonly)int layerCount;			//层数
@property (nonatomic, assign, readonly)uint columns;			//列数
@property (nonatomic, assign, readonly)uint rows;				//行数
@property (nonatomic, assign, readonly)CCSize mapSize;
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

#endif