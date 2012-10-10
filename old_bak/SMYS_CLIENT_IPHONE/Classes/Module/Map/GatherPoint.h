/*
 *  GatherPoint.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-3.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GATHER_POINT_H_
#define _GATHER_POINT_H_

#include "NDMonster.h"
#include "NDPicture.h"
#include "NDUILabel.h"
#include <string>

using namespace NDEngine;


class GatherPoint : public NDBaseRole
{
	DECLARE_CLASS(GatherPoint)
public:
	GatherPoint();
	GatherPoint(int iID, int iTypeID, int xx, int yy,bool isBoss ,std::string name);
	~GatherPoint();
	
	bool OnDrawBegin(bool bDraw); override
	 
	void OnDrawEnd(bool bDraw); override
	
	int GetOrder(); override
	
	int getMapId();
	
	void setMapId(int mapId);
	
	std::string getName();
	
	void setGatherName(std::string gatherName);
	//带光环
	void enableRing(bool b);
	
	void sendCollection();
	
	int getBottom();
	
	int getHeight();
	
	//public Array getSubAniGroup() {
//		// Auto-generated method stub
//		return null;
//	}
	
	int getWidth();
	
	int getX();
	
	int getY();
	
	bool isJustCollided();
	
	void setJustCollided(bool isJustCollided);
	
	int getAttachArea();
	
	bool isCanDraw();
	
	void refreshData();
	
	void setCanDraw(bool b);
	
	int getId();
	
	bool isAlive();
	
	bool isCollides(int x1,int y1, int w,int h);
	
	void setId(int id);
	
	int getTypeId();
	
	void setState(int state);
	
	int getState();
private:
	int mapId;
	std::string gatherName;
	int x, y;
	NDSprite  *bossRing;
	int m_iTypeID; //类型
	int m_iID; //唯一标示
	bool m_isJustCollided;
	int  m_state;
	bool m_isCanDraw;
	NDPicture *m_pic;
	NDUILabel *m_lbName;
};

#endif // _GATHER_POINT_H_