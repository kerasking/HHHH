//
//  NDWorldMapData.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_WORLD_MAP_DATA_H_
#define _ND_WORLD_MAP_DATA_H_

#include "NDMapData.h"

class PlaceNode : public cocos2d::CCObject
{
	CC_SYNTHESIZE_RETAIN(cocos2d::CCTexture2D*, m_Texture, Texture)
	CC_PROPERTY(int, m_nPlaceId, PlaceId)
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nLDir, LDir)
	CC_PROPERTY(int, m_nRDir, RDir)
	CC_PROPERTY(int, m_nTDir, TDir)
	CC_PROPERTY(int, m_nBDir, BDir)
	CC_PROPERTY(std::string, m_Name, Name)
	CC_PROPERTY(std::string, m_Description, Description)

public:
	PlaceNode();
	~PlaceNode();
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

//class anigroup_param : public cocos2d::CCObject, public std::map<std::string, int>{};

class NDWorldMapData : public cocos2d::CCObject
{
public:
	CC_PROPERTY(std::string, m_Name, Name)
	CC_PROPERTY_READONLY(int, m_nLayerCount, LayerCount)
	CC_PROPERTY_READONLY(unsigned int, m_nColumns, Columns)
	CC_PROPERTY_READONLY(unsigned int, m_nRows, Rows)
	CC_PROPERTY_READONLY(int, m_nUnitSize, UnitSize)
	CC_PROPERTY_READONLY(CGSize, m_MapSize, MapSize)

	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<CCTexture2D*>**/, m_MapTiles, MapTiles)
	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<NDSceneTile*>**/, m_SceneTiles, SceneTiles)
	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<NDSceneTile*>**/, m_BgTiles, BgTiles)
	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<NDAnimationGroup*>**/, m_AnimationGroups, AnimationGroups)
	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<anigroup_param*>**/, m_AniGroupParams, AniGroupParams)
	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<PlaceNode*>**/, m_PlaceNodes, PlaceNodes)

public:
	static NDWorldMapData* SharedData();

	NDTile * getTileAtRow(unsigned int row, unsigned int column);
	int getDestMapIdWithSourceMapId(int mapId, int passwayIndex);
	PlaceNode * getPlaceNodeWithMapId(int mapId);

private:
	void initWithFile(const char* mapFile);
	void decode(FILE* stream);

private:
	NDWorldMapData();
public:
	~NDWorldMapData();
};

#endif