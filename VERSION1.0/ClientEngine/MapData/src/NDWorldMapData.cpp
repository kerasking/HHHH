//
//  NDWorldMapData.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDWorldMapData.h"
#include "JavaMethod.h"
#include "NDPath.h"
#include "CCTextureCache.h"
#include "NDAnimationGroupPool.h"

using namespace cocos2d;
using namespace NDEngine;

PlaceNode::PlaceNode()
: m_Texture(NULL)
, m_nPlaceId(0)
, m_nX(0)
, m_nY(0)
, m_nLDir(0)
, m_nRDir(0)
, m_nTDir(0)
, m_nBDir(0)
{

}

PlaceNode::~PlaceNode()
{
	CC_SAFE_RELEASE(m_Texture);
}

#define IMAGE_PATH	[NSString stringWithUTF8String:NDEngine::NDPath::GetImagePath().c_str()]

const int TileWidth		= 16;
const int TileHeight	= 16;

std::vector<PassWay> m_passWayInfos;

NDWorldMapData::NDWorldMapData()
: m_nLayerCount(0)
, m_nColumns(0)
, m_nRows(0)
, m_nUnitSize(0)
, m_MapTiles(NULL)
, m_SceneTiles(NULL)
, m_BgTiles(NULL)
, m_AnimationGroups(NULL)
, m_AniGroupParams(NULL)
, m_PlaceNodes(NULL)
{
	m_MapSize = CGSizeZero;
}

NDWorldMapData *NDWorldMapData_SharedData = NULL;
NDWorldMapData * NDWorldMapData::SharedData()
{
	if (NDWorldMapData_SharedData == NULL)
	{
		std::string mapFile = NDPath::GetMapPath()+ "map_99999.map";
		NDWorldMapData_SharedData = new NDWorldMapData;
		NDWorldMapData_SharedData->initWithFile(mapFile.c_str());
		
		if (m_passWayInfos.empty()) 
		{
			m_passWayInfos.push_back(PassWay(21001,0,23002));
			m_passWayInfos.push_back(PassWay(21001,1,23001));
			m_passWayInfos.push_back(PassWay(21002,2,23003));
			m_passWayInfos.push_back(PassWay(21002,1,23005));
			m_passWayInfos.push_back(PassWay(21002,0,23006));
			m_passWayInfos.push_back(PassWay(21003,0,23013));
			m_passWayInfos.push_back(PassWay(21003,1,23014));
			m_passWayInfos.push_back(PassWay(21003,2,23011));
			m_passWayInfos.push_back(PassWay(21005,0,23001));
			m_passWayInfos.push_back(PassWay(21006,0,23011));
			m_passWayInfos.push_back(PassWay(21006,1,23012));
			m_passWayInfos.push_back(PassWay(21006,2,23009));
			m_passWayInfos.push_back(PassWay(21007,0,23017));
			m_passWayInfos.push_back(PassWay(21007,1,23018));
			m_passWayInfos.push_back(PassWay(22001,0,23022));
			m_passWayInfos.push_back(PassWay(22003,0,23024));
			m_passWayInfos.push_back(PassWay(22004,0,23023));
			m_passWayInfos.push_back(PassWay(23001,0,21001));
			m_passWayInfos.push_back(PassWay(23001,1,21005));
			m_passWayInfos.push_back(PassWay(23002,0,23004));
			m_passWayInfos.push_back(PassWay(23002,1,21001));
			m_passWayInfos.push_back(PassWay(23003,1,23004));
			m_passWayInfos.push_back(PassWay(23003,0,21002));
			m_passWayInfos.push_back(PassWay(23004,0,23003));
			m_passWayInfos.push_back(PassWay(23004,1,23002));
			m_passWayInfos.push_back(PassWay(23005,0,21002));
			m_passWayInfos.push_back(PassWay(23005,1,23007));
			m_passWayInfos.push_back(PassWay(23006,0,21002));
			m_passWayInfos.push_back(PassWay(23007,0,23005));
			m_passWayInfos.push_back(PassWay(23007,1,23008));
			m_passWayInfos.push_back(PassWay(23008,0,23009));
			m_passWayInfos.push_back(PassWay(23008,1,23007));
			m_passWayInfos.push_back(PassWay(23009,0,21006));
			m_passWayInfos.push_back(PassWay(23009,1,23008));
			m_passWayInfos.push_back(PassWay(23009,2,23010));
			m_passWayInfos.push_back(PassWay(23010,0,23009));
			m_passWayInfos.push_back(PassWay(23010,1,23025));
			m_passWayInfos.push_back(PassWay(23011,0,21003));
			m_passWayInfos.push_back(PassWay(23011,1,21006));
			m_passWayInfos.push_back(PassWay(23012,0,21006));
			m_passWayInfos.push_back(PassWay(23013,0,23022));
			m_passWayInfos.push_back(PassWay(23013,1,23023));
			m_passWayInfos.push_back(PassWay(23013,2,23024));
			m_passWayInfos.push_back(PassWay(23013,3,21003));
			m_passWayInfos.push_back(PassWay(23014,0,23015));
			m_passWayInfos.push_back(PassWay(23014,1,21003));
			m_passWayInfos.push_back(PassWay(23014,2,23016));
			m_passWayInfos.push_back(PassWay(23015,0,23014));
			m_passWayInfos.push_back(PassWay(23016,0,23014));
			m_passWayInfos.push_back(PassWay(23016,1,23017));
			m_passWayInfos.push_back(PassWay(23017,0,23016));
			m_passWayInfos.push_back(PassWay(23017,1,21007));
			m_passWayInfos.push_back(PassWay(23018,0,21007));
			m_passWayInfos.push_back(PassWay(23018,1,23025));
			m_passWayInfos.push_back(PassWay(23022,0,22001));
			m_passWayInfos.push_back(PassWay(23022,1,23013));
			m_passWayInfos.push_back(PassWay(23023,0,22004));
			m_passWayInfos.push_back(PassWay(23023,1,23013));
			m_passWayInfos.push_back(PassWay(23024,0,23013));
			m_passWayInfos.push_back(PassWay(23024,1,22003));
			m_passWayInfos.push_back(PassWay(23025,0,23018));
			m_passWayInfos.push_back(PassWay(23025,1,23010));
		}		
	}
	return NDWorldMapData_SharedData;
}
/*通过地图文件(不包含路径)加载地图数据
 参数:mapFile-地图文件名
 */
void NDWorldMapData::initWithFile(const char* mapFile)
{
	FILE* stream = fopen(mapFile, "rt");
	if (stream) 
	{
		this->decode(stream);
		fclose(stream);
	}
}

NDWorldMapData::~NDWorldMapData()
{
	CC_SAFE_RELEASE(m_MapTiles);
	CC_SAFE_RELEASE(m_SceneTiles);
	CC_SAFE_RELEASE(m_BgTiles);
	CC_SAFE_RELEASE(m_AnimationGroups);
	CC_SAFE_RELEASE(m_AniGroupParams);
	CC_SAFE_RELEASE(m_PlaceNodes);
}

/*  地图文件解析
 参数:地图文件流
 */

void NDWorldMapData::decode(FILE* stream)
{	
	FileOp op;
	//<-------------------地图名
	m_Name = op.readUTF8String(stream);//[self readUTF8String:stream];
	//<-------------------单元格尺寸
	m_nUnitSize=op.readByte(stream);
	int TileWidth		= m_nUnitSize;
	int TileHeight		= m_nUnitSize;
	//------------------->层数
	m_nLayerCount = op.readByte(stream);
	//<-------------------列数
	m_nColumns = op.readByte(stream);
	//------------------->行数
	m_nRows = op.readByte(stream);
	m_MapSize = CGSizeMake(m_nColumns << 5, m_nRows << 5);
	//<-------------------使用到的图块资源
	std::vector<std::string> _tileImages;
	int tileImageCount = op.readShort(stream);	
	for (int i = 0; i < tileImageCount; i++) 
	{
		int idx = op.readShort(stream);
		char imageName[256] = {0};
		sprintf(imageName, "%st%d.png", NDEngine::NDPath::GetImagePath().c_str(), idx);
		FILE* f = fopen(imageName, "rt");
		if (f ) 
		{
			_tileImages.push_back(imageName);
		}
		else 
		{
			return;
		}
	}
	
	//------------------->瓦片	
	m_MapTiles = CCArray::array();
	m_MapTiles->retain();
	for ( int lay = 0; lay < m_nLayerCount; lay++) 
	{
		for (uint r = 0; r < m_nRows; r++) 
		{
			for (uint c = 0; c < m_nColumns; c++)
			{					
				int imageIndex		= op.readByte(stream) - 1;	//资源下标
				if (imageIndex == -1) 
					imageIndex = 0;
				int	tileIndex		= op.readByte(stream);		//图块下标
				bool reverse		= op.readByte(stream) == 1;	//翻转

				if (imageIndex == -1)
				{
					imageIndex = 0;
					//continue;
				}

				if(_tileImages.size() > imageIndex)
				{
					std::string imageName	=_tileImages[imageIndex];

					NDTile *tile = new NDTile();
					tile->setMapSize(m_MapSize);
					tile->setTexture(MapTexturePool::defaultPool()->addImage(imageName.c_str(), true));
					int PicParts	= tile->getTexture()->getPixelsWide() *
						tile->getTexture()->getMaxS() / TileWidth;
					tile->setCutRect(CGRectMake(TileWidth * (tileIndex % PicParts),
						TileHeight*(tileIndex / PicParts), TileWidth, TileHeight));
					tile->setDrawRect(CGRectMake(TileWidth * c, TileHeight * r,
						TileWidth, TileHeight));
					//tile->setHorizontalReverse(reverse);				
					m_MapTiles->addObject(tile);
					tile->release();			
				}
			}
		}
	}
	//<---------------------使用到的背景资源
	std::vector<std::string> _bgImages;
	std::vector<int>_bgOrders;
	int bgImageCount = op.readShort(stream);
	for (int i = 0; i < bgImageCount; i++) 
	{
		int idx = op.readShort(stream);
		char imageName[256] = {0};
		sprintf(imageName, "%sb%d.png", NDEngine::NDPath::GetImagePath().c_str(), idx);
		FILE* f = fopen(imageName, "rt");
		if (f )  
		{
			_bgImages.push_back(imageName);
		}
		else 
		{
			//NDLog("背景资源%@没有找到!!!", imageName);
			_bgImages.push_back(imageName);
		}

		int v = op.readShort(stream);
		_bgOrders.push_back(v);
	}
	//---------------------->背景
	m_BgTiles = CCArray::array();
	m_BgTiles->retain();
	int bgCount = op.readShort(stream);
	for (int i = 0; i < bgCount; i++) 
	{		
		int resourceIndex	= op.readByte(stream);										//资源下标
		int	x				= op.readShort(stream);	//x坐标
		int y				= op.readShort(stream);	//y坐标
		bool reverse		= op.readByte(stream) > 0;									//翻转

		if (_bgImages.size() <= resourceIndex || _bgOrders.size() <= resourceIndex)
		{
			continue;
		}

		std::string imageName		= _bgImages [resourceIndex];
		NDSceneTile	*tile = new NDSceneTile;
		tile->setOrderID(_bgOrders[resourceIndex] + y);
		tile->setTexture(CCTextureCache::sharedTextureCache()->addImage(imageName.c_str()));
		int picWidth	= tile->getTexture()->getPixelsWide() * tile->getTexture()->getMaxS(); 
		int picHeight	= tile->getTexture()->getPixelsHigh() * tile->getTexture()->getMaxT();

		tile->setMapSize(CGSizeMake(m_nColumns*TileWidth, m_nRows*TileHeight));
		tile->setCutRect(CGRectMake(0, 0, picWidth, picHeight));
		tile->setDrawRect(CGRectMake(x, y, picWidth, picHeight));
//		tile->setReverse(reverse);	 ///< 临时性注释 郭浩

		tile->make();

		m_BgTiles->addObject(tile);
		tile->release();
	}
	//<-------------------使用到的布景资源
	std::vector<std::string> _sceneImages;
	std::vector<int> _sceneOrders;
	int sceneImageCount = op.readShort(stream);
	for (int i = 0; i < sceneImageCount; i++) 
	{
		int idx = op.readShort(stream);
		char imageName[256] = {0};
		sprintf(imageName, "%s%d.png", NDEngine::NDPath::GetImagePath().c_str(), idx);
		FILE* f = fopen(imageName, "rt");
		if (f )  
		{
			_sceneImages.push_back(imageName);
		}
		else 
		{
			//NDLog("布景资源%@没有找到!!!", imageName);
			_sceneImages.push_back(imageName);
		}

		int v = op.readShort(stream);
		_sceneOrders.push_back(v);
	}
	//------------------->布景
	m_SceneTiles = CCArray::array();
	m_SceneTiles->retain();
	int sceneCount = op.readShort(stream);
	for (int i = 0; i < sceneCount; i++) 
	{		
		int resourceIndex	= op.readByte(stream);										//资源下标
		int	x				= op.readShort(stream);	//x坐标
		int y				= op.readShort(stream);	//y坐标
		BOOL reverse		= op.readByte(stream) > 0;									//翻转

		if (_sceneImages.size() <= resourceIndex || _sceneOrders.size() <= resourceIndex)
		{
			continue;
		}

		NDSceneTile	*tile = new NDSceneTile;
		tile->setOrderID(_sceneOrders[resourceIndex] + y);
		tile->setTexture(CCTextureCache::sharedTextureCache()->addImage(_sceneImages[resourceIndex].c_str()));
		int picWidth	= tile->getTexture()->getPixelsWide() * tile->getTexture()->getMaxS(); 
		int picHeight	= tile->getTexture()->getPixelsHigh() * tile->getTexture()->getMaxT();

		tile->setMapSize(CGSizeMake(m_nColumns*TileWidth, m_nRows*TileHeight));
		tile->setCutRect(CGRectMake(0, 0, picWidth, picHeight));
		tile->setDrawRect(CGRectMake(x, y, picWidth, picHeight));
//		tile->setReverse(reverse); ///< 临时性注释 郭浩

		tile->make();

		m_SceneTiles->addObject(tile);
		tile->release();
	}
	//<-------------------动画
	m_AnimationGroups = CCArray::array();
	m_AniGroupParams  = CCArray::array();
	m_AnimationGroups->retain();
	m_AniGroupParams->retain();

	int aniGroupCount = op.readShort(stream);
	for (int i = 0; i < aniGroupCount; i++) 
	{			
		int identifer = op.readShort(stream);			//动画id
		NDAnimationGroup *aniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSceneAnimationId(identifer);
		if (!aniGroup) continue;
		m_AnimationGroups->addObject(aniGroup);
		aniGroup->release();

		int x = op.readShort(stream);		//x坐标
		int y = op.readShort(stream);		//y坐标
		int aniOrder = y + op.readShort(stream);	//排序重心

		anigroup_param* dict = new anigroup_param;
		dict->insert(std::make_pair("reverse", 0));
		dict->insert(std::make_pair("positionX", x));
		dict->insert(std::make_pair("positionY", y));
		dict->insert(std::make_pair("mapSizeW", m_nColumns * m_nUnitSize));
		dict->insert(std::make_pair("mapSizeH", m_nRows * m_nUnitSize));
		dict->insert(std::make_pair("orderId", aniOrder));
		dict->insert(std::make_pair("reverse", 0));
		dict->insert(std::make_pair("reverse", 0));

		m_AniGroupParams->addObject(dict);
		dict->release();	
	}
	//------------------->节点
	m_PlaceNodes = CCArray::array();
	m_PlaceNodes->retain();

	int nodeCount = op.readByte(stream);
	for (int i = 0; i < nodeCount; i++) 
	{
		PlaceNode *node = new PlaceNode;
		
		node->setPlaceId(op.readShort(stream));
		int imageIndex = op.readShort(stream);

		char imageName[256] = {0};
		sprintf(imageName, "%so%d.png", NDEngine::NDPath::GetImagePath().c_str(), imageIndex);
		FILE* f = fopen(imageName, "rt");
		if (f )  
		{
			node->setTexture(CCTextureCache::sharedTextureCache()->addImage(imageName));
		}		
		node->setX(op.readShort(stream));
		node->setY(op.readShort(stream));
		node->setLDir(op.readShort(stream));
		node->setRDir(op.readShort(stream));
		node->setTDir(op.readShort(stream));
		node->setBDir(
			op.readShort(stream));
		node->setName(op.readUTF8String(stream));
		node->setDescription(op.readUTF8String(stream));
		
		m_PlaceNodes->addObject(node);
		node->release();
	}
}

NDTile * NDWorldMapData::getTileAtRow(unsigned int row, unsigned int column)
{
	if (row >= m_nRows) 
	{
		return NULL;
	}
	if (column >= m_nColumns) 
	{
		return NULL;
	}
	
	int index =	row * m_nColumns + column;
	
	return (NDTile *)m_MapTiles->objectAtIndex(index);
}

int NDWorldMapData::getDestMapIdWithSourceMapId(int mapId, int passwayIndex)
{		
	for (std::vector<PassWay>::iterator it = m_passWayInfos.begin(); it != m_passWayInfos.end(); it++)
	{
		PassWay& pw = *it;
		if (pw.fromMapID == mapId && pw.fromPassIndex == passwayIndex) 
		{
			return pw.desMapID;
		}
	}
	
	return 0;
}

PlaceNode * NDWorldMapData::getPlaceNodeWithMapId(int mapId)
{
	PlaceNode *result = NULL;
	for (unsigned int i = 0; i < m_PlaceNodes->count(); i++) 
	{
		PlaceNode *node = (PlaceNode *)m_PlaceNodes->objectAtIndex(i);
		if (node->getPlaceId() == mapId) 
		{
			result = node;
			break;
		}
	}
	return result;
}