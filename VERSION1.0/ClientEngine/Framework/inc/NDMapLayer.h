//
//  NDMapLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	－－介绍－－
//	地图层是游戏中主要的层，游戏中的人物活动都在该层上

#ifndef	__NDMapLayer_H
#define __NDMapLayer_H

#include "NDLayer.h"
#include <string>
#include "NDPicture.h"

#include "NDMapData.h"
#include "NDAnimationGroup.h"
#include "CCLayer.h"
#include "NDUILayer.h"
#include "NDLightEffect.h"
#include "NDUIImage.h"
#include "NDTimer.h"
#include "UISpriteNode.h"

#define blockTimerTag	(5)
#define titleTimerTag	(6)
#define switch_ani_modelId		(106)	//传送点动画的model ID
#define ZORDER_MASK_ANI			(999)	//遮罩动画的Z次序，在game scene里

enum MAP_SWITCH_TYPE
{
	SWITCH_NONE = 0,
	SWITCH_TO_BATTLE,
	SWITCH_BACK_FROM_BATTLE,
	SWITCH_START_BATTLE
};

enum BOX_STATUS
{
	BOX_NONE = 0,
	BOX_SHOWING,
	BOX_CLOSE,
	BOX_OPENING,
	BOX_OPENED,
};

namespace NDEngine
{
class NDMapLayer: public NDLayer,public ITimerCallback
{
DECLARE_CLASS(NDMapLayer)
public:
	class MAP_ORDER:
		public cocos2d::CCObject,
		public std::map<std::string, int>
	{
	};
public:
	NDMapLayer();
	~NDMapLayer();
public:

	virtual void AddChild(NDNode* node, int z, int tag);
//		
//		函数：Initialization(const char* mapFile)
//		作用：初始化地图
//		参数：mapFile地图文件
//		返回值：无
	void Initialization(const char* mapFile);
//		
//		函数：Initialization(int mapIndex)
//		作用：初始化地图
//		参数：mapIndex地图索引号
//		返回值：无
	void Initialization(int mapIndex);

	int GetMapIndex();
//		
//		函数：DidFinishLaunching
//		作用：地图初始化完成后由框架回调该方法
//		参数：无
//		返回值：无
	virtual void DidFinishLaunching();
//		
//		同基类
	//bool TouchBegin(NDTouch* touch); override
//		
//		同基类
	//void TouchEnd(NDTouch* touch); override
//		
//		同基类
	//void TouchCancelled(NDTouch* touch); override
//		
//		同基类
	//void TouchMoved(NDTouch* touch); override
//		
//		函数：ConvertToMapPoint
//		作用：将屏幕坐标转化成地图坐标
//		参数：screenPoint屏幕坐标
//		返回值：地图坐标
	CGPoint ConvertToMapPoint(CGPoint kScreenPoint);
//		
//		函数：isMapPointInScreen
//		作用：判断地图坐标点是否在屏幕范围内
//		参数：mapPoint地图坐标
//		返回值：true是，false否
	bool isMapPointInScreen(CGPoint mapPoint);
//		
//		函数：isMapRectIntersectScreen
//		作用：判断地图上的矩形区域是否在屏幕范围内
//		参数：mapRect地图上的矩形区域
//		返回值：true是，false否
	bool isMapRectIntersectScreen(CGRect mapRect);
//		
//		函数：SetScreenCenter
//		作用：设置地图坐标点对应屏幕中心；如果超出地图的表现范围，则该点并不对应于屏幕的中心
//		参数：p地图坐标点
//		返回值：true 到边界了, false 还没到边界
	bool SetScreenCenter(CGPoint kPoint);
//		
//		函数：GetScreenCenter
//		作用：获取屏幕中心点的地图坐标
//		参数：无
//		返回值：地图坐标
	CGPoint GetScreenCenter();
//		
//		函数：SetBattleBackground
//		作用：设置进入战斗
//		参数：bBattleBackground如果为true就进入战斗，否则退出战斗
//		返回值：无
	//void SetBattleBackground(bool bBattleBackground);
	//bool IsBattleBackground(){ return m_bBattleBackground;}

	void SetNeedShowBackground(bool bNeedShow);

	void MapSwitchRefresh();

	void ShowRoadSign(bool bShow, int nX = 0, int nY = 0);
public:
	virtual void draw();
	virtual void debugDraw();
	NDMapData *GetMapData();
	void setStartRoadBlockTimer(int time, int x, int y);
	
	void setAutoBossFight(bool isAuto);
	bool isAutoFight() {return isAutoBossFight;}
	void walkToBoss();
	 
	void OnTimer(OBJID tag);
	void replaceMapData(int mapId, int center_x, int center_y);
	void ShowTitle(int name_col, int name_row);
	void refreshTitle();
	void showSwitchSprite(MAP_SWITCH_TYPE type);
	void ShowTreasureBox();
	void OpenTreasureBox();
	bool isTouchTreasureBox(CGPoint touchPoint);
	//		void setRoadBlock(int x,int y){roadBlockX=x;roadBlockY=y;}
public:

	virtual bool TouchBegin( NDTouch* touch );
	virtual void TouchEnd( NDTouch* touch );
	virtual void TouchCancelled( NDTouch* touch );
	virtual void TouchMoved( NDTouch* touch );
	virtual bool TouchDoubleClick( NDTouch* touch );

	CC_SYNTHESIZE(int,m_nBattleType,BattleType);

	void PlayNDSprite(const char* pszSpriteFile, int nPosx, int nPosy,
			int nAnimationNo, int nPlayTimes);
private:
	void MakeOrders();
	void MakeOrdersOfMapscenesAndMapanimations();
	int InsertIndex(int order, cocos2d::CCArray* inArray);
	void QuickSort(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low, int high);
	int Partition(cocos2d::CCArray*/*<MAP_ORDER*>*/array, int low, int high);

	void SetPosition(CGPoint kPosition);

	void DrawMapTiles();
	void DrawScenesAndAnimations();
	void DrawBgs();

	void MakeFrameRunRecords();

	void ReflashMapTexture(CGPoint oldScreenCenter, CGPoint newScreenCenter);
	void ReplaceMapTexture(cocos2d::CCTexture2D* tex, CGRect replaceRect,
			CGRect tilesRect);
	void ScrollSplit(int x, int y);
	void ScrollVertical(int y, CGRect newRect);
	void ScrollHorizontal(int x, CGRect newRect);
	void RefreshBoxAnimation();

private:

	CGPoint m_kScreenCenter;
	cocos2d::CCArray* m_pkOrders;
	cocos2d::CCArray* m_pkOrdersOfMapscenesAndMapanimations;
	NDMapData *m_pkMapData;

	//cocos2d::CCMutableArray<cocos2d::CCMutableArray<NDFrameRunRecord*>*>* m_pkFrameRunRecordsOfMapAniGroups;
	//cocos2d::CCMutableArray<NDFrameRunRecord*>* m_pkFrameRunRecordsOfMapSwitch;
	cocos2d::CCArray* m_pkFrameRunRecordsOfMapAniGroups;
	cocos2d::CCArray* m_pkFrameRunRecordsOfMapSwitch;

	NDAnimationGroup* m_pkSwitchAniGroup;
	NDSprite* m_pkTreasureBox;
	NDUILabel* m_lbTime;
	NDUIImage* m_lbTitle;
	NDUIImage* m_lbTitleBg;
	CUISpriteNode* m_pkSwitchSpriteNode;
	bool m_bBattleBackground;
	bool m_bNeedShow;
	NDTimer* m_ndBlockTimer;
	NDTimer* m_ndTitleTimer;
	int m_nRoadBlockTimeCount;
	bool isAutoBossFight;
	//CCColorLayer* m_battleBgColor;
	int m_nTitleAlpha;
	//cocos2d::CCTexture2D *m_texMap;
	NDPicture* m_pkPicMap;
	CGPoint m_kCamarkSplit;
	NDNode* m_pkSubNode;
	BOX_STATUS m_eBoxStatus;

	typedef enum
	{
		IntersectionAreaLT,
		IntersectionAreaLB,
		IntersectionAreaRT,
		IntersectionAreaRB,
		IntersectionAreaNone
	} IntersectionArea;

	void RectIntersectionRect(CGRect rect1, CGRect rect2,
			CGRect& intersectionRect, IntersectionArea& intersectionArea);
	IntersectionArea m_areaCamarkSplit;

	int m_nMapIndex;

	bool m_bShowTitle;
	MAP_SWITCH_TYPE m_eSwitchType;

	NDLightEffect* m_pkRoadSignLightEffect;

private:

	bool GetMapDataAniParamReverse(int nIndex);
	CGPoint GetMapDataAniParamPos(int nIndex);
	CGSize GetMapDataAniParamMapSize(int nIndex);
	int GetMapDataAniParamOrderId(int nIndex);
	int GetMapOrderId(MAP_ORDER *dict);
};

}

#endif
