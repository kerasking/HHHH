//
//  WorldMapScene.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-25.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef __WorldMapScene_H
#define __WorldMapScene_H

#include "NDScene.h"
#include "NDUILayer.h"
#include <vector>
#include "NDUIImage.h"
#include "NDPicture.h"
#include "NDTimer.h"
#include "NDUIBaseGraphics.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
//#include "SimpleAudioEngine_objc.h"
#include "NDWorldMapData.h"
#include "UIRoleNode.h"
#include "typedef.h"

using namespace NDEngine;

#define TAG_WORLD_MAP		(65535)

class WorldMapLayer: public NDUILayer, public NDUIButtonDelegate
{
	DECLARE_CLASS (WorldMapLayer)
	WorldMapLayer();
	~WorldMapLayer();
public:
	void Initialization(int nMapId);override
	void OnButtonClick(NDUIButton* button);override
	void draw();override
	void OnTimer(OBJID tag);override
	bool TouchBegin(NDTouch* touch);override
	void ShowRoleAtPlace(int placeId);
	void Goto(int nMapId);
	void SetFilter(ID_VEC idVec);
private:
	PlaceNode *GetPlaceNodeWithId(int placeId);
	CGPoint ConvertToMapPoint(CGPoint screenPoint);
	CGPoint ConvertToScreenPoint(CGPoint mapPoint);
	void OnNodeClick(PlaceNode* button);
	void SetMove(bool bSet);
	bool IsMoving();
	bool IsMoveArrive();
	void SetTarget(CGPoint pos);
	CGPoint GetTarget();
	void SetTargetMapId(int nMapId);
	int GetTargetMapId();
	void SetRoleDirect(bool directRight);
	int GetCurPlaceIndex();
	int GetPlaceIdByIndex(int nIndex);
	bool IsInFilterList(int nMapId);
	void SetCenterAtPos(CGPoint pos);

	CGPoint GetPlaceIdScreenPos(int placeId);
private:
	NDWorldMapData* m_mapData;
	PlaceNode* m_curBtn;
	NDTimer m_timer;
	cocos2d::CCArray *m_buttons;
	cocos2d::CCArray *m_buttonsFocus;
	CGPoint m_screenCenter, m_posMapOffset;
	ID_VEC m_vIdFilter;
	CUIRoleNode *m_roleNode;
	NDUIButton *m_btnClose;
	NDUIButton *m_btnRet;
	CGPoint m_posTarget;
	int m_nTargetMapId;
	bool m_bInMoving;
	//std::map<int, std::string> m_mapFilename;
};

#endif
