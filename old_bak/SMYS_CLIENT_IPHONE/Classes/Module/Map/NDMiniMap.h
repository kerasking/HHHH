/*
 *  NDMiniMap.h
 *  DragonDrive
 *
 *  Created by wq on 11-2-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_MINI_MAP_H__
#define __ND_MINI_MAP_H__

#include "define.h"
#include "NDLayer.h"
#include "GameScene.h"
#include "NDPlayer.h"
#include "NDUISpecialLayer.h"
#include "SMGameScene.h"

class NDEngine::NDUIRecttangle;
class NDEngine::NDUIPolygon;
using namespace NDEngine;

enum {
	SCALE_X = 9,
	SCALE_Y = 12,
	LIGHT_WH = 4,
	DARK_WH = 2,
	HALF_DARK_WH = 1,
	OFFSET_X = 3,
	OFFSET_Y = 5,
};

class Radar : public NDUILayer {
	DECLARE_CLASS(Radar)
public:
	Radar();
	~Radar();
	
	void Initialization();
	
	void draw();
	
	void SetGameScene(CSMGameScene* gs) { this->scene = gs; }
	
	bool TouchEnd(NDTouch* touch);
	
private:
	int startX;
	int startY;
	int x;
	int y;
	int timeCount;
	int scrollX;
	int scrollY;
	
	int MINI_W;
	int MINI_H;
	
	NDPicture* m_miniTaskPic;
	NDPlayer& m_role;
	CSMGameScene* scene;
	
private:
	void drawRole();
	void drawNpc();
	void drawEnemy();
	void drawOtherRoles();
	void drawSwitchMapPoint();
	void mapLogin();
	void drawMiniQuest(int npcState, int x, int y);
};

/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* this class
*/
// class NDMiniMap : public NDUIChildrenEventLayer,
// public NDUIButtonDelegate
// {
// 	DECLARE_CLASS(NDMiniMap)
// 	
// 	enum SHRINK_STATUS 
//  {
// 		SS_HIDE,
// 		SS_SHOW,
// 		SS_SHRINKING,
// 		SS_EXTENDING,
// 	};
// 	
// public:
// 	NDMiniMap();
// 	~NDMiniMap();
// 	
// 	void Initialization();
// 	
// 	void draw(); override
// 	
// 	void OnButtonClick(NDUIButton* button);
// 	
// 	void SetGameScene(CSMGameScene* gs) { 
// 		this->scene = gs;
// 		if (m_radar) {
// 			m_radar->SetGameScene(gs);
// 		}
// 	}
// 	
// 	void SetMapName(std::string name);
// 	
// 	static NDMiniMap* GetInstance();
// 	
// private:
// 	int startX;
// 	int startY;
// 	int x;
// 	int y;
// 	int timeCount;
// 	int scrollX;
// 	int scrollY;
// 	
// 	int MINI_W;
// 	int MINI_H;
// 	
// 	Radar* m_radar;
// 	
// 	CSMGameScene* scene;
// 	
// 	NDPlayer& m_role;
// 	
// 	//NDPicture* m_miniTaskPic;
// 	
// 	NDUILabel* m_lbMapName;
// 	NDUILabel* m_lbServerName;
// 	NDUILabel* m_lbCoord;
// 	
// 	NDUIButton* m_btnMap;
// 	NDUIButton* m_btnShrink;
// 
// 	SHRINK_STATUS m_status;
// 	
// 	static NDMiniMap* s_instance;
// 	
// private:
// 	void mapLogin();
// };

#endif