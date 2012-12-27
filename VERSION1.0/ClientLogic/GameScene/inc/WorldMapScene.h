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
#include "UIRoleNode.h"
#include "typedef.h"

using namespace NDEngine;

#define TAG_WORLD_MAP		(2021)

class PlaceNode;

class WorldMapLayer: public NDUILayer, public NDUIButtonDelegate
{
	DECLARE_CLASS (WorldMapLayer)
	WorldMapLayer();
	~WorldMapLayer();

public:
	void Initialization(int nMapId);override
	void OnButtonClick(NDUIButton* button);override
	void draw();
	void OnTimer(OBJID tag);override
	virtual bool TouchBegin(NDTouch* touch);
	virtual bool TouchEnd(NDTouch* touch);
	void SetRoleAtPlace(int placeId);
	void Goto(int nMapId);
	void SetFilter(ID_VEC idVec);
	ND_LAYER_PRIORITY getPriority() { return E_LAYER_PRIORITY_WORLDMAP; } //@priority

private:
	PlaceNode *GetPlaceNodeWithId(int placeId);
	CCPoint ConvertToMapPoint(CCPoint screenPoint);
	CCPoint ConvertToScreenPoint(CCPoint mapPoint);
	void OnNodeClick(PlaceNode* button);
	void SetMove(bool bSet);
	void SetRoleDirect(bool directRight);
	int GetCurPlaceIndex();
	int GetPlaceIdByIndex(int nIndex);
	bool IsInFilterList(int nMapId);
	void SetCenterAtPos(CCPoint pos);

	CCPoint GetPlaceIdScreenPos(int placeId);
	CCPoint GetTargetPos(int placeId);

	bool DoMove();
	bool isTimeout();
	CCPoint CalcNextPoint( const CCPoint& posStart, const CCPoint& posEnd );
	void onArrive();
	void debugDraw();

private:
	cocos2d::CCArray *m_arrBtnTiles;
	PlaceNode* m_curBtn;
	NDUIButton *m_btnClose;
	CUIRoleNode *m_roleNode;
//	NDUIButton *m_btnRet;

	NDTimer m_timer;
	
	CCPoint m_screenCenter, m_posMapOffset;
	ID_VEC m_vIdFilter;
	
	CCPoint m_posTarget;
	int m_nTargetMapId;
	bool m_bInMoving;
	struct cc_timeval m_tmStartMoving;
	int m_idMapCached;
	bool m_bArrive;
};

#endif
