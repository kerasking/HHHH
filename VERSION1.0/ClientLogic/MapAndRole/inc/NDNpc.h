//
//  NDNpc.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef __NDNpc_H
#define __NDNpc_H

#include "NDBaseRole.h"
#include <string>
#include "EnumDef.h"
#include "NDUILabel.h"
#include "NDPicture.h"
#include "globaldef.h"

NS_NDENGINE_BGN

using namespace NDEngine;

class NDNpcLogic;

/** btState为1时灰色叹号,2彩色叹号,3灰色问号,4彩色问号 */
enum
{
	QUEST_NONE = 0x01, // 没有任务
	QUEST_CANNOT_ACCEPT = 0x02, // 有任务但是级别不对
	QUEST_CAN_ACCEPT = 0x04, // 有任务可接
	QUEST_NOT_FINISH = 0x08, // 有任务未完成
	QUEST_FINISH = 0x10, // 有任务已完成(优先级最高)
	QUEST_CAN_ACCEPT_SUB = 0x20,// 有支线任务可接
	QUEST_FINISH_SUB = 0x40,// 有支线任务已完成
};

class NDRidePet;
class NDNpc: public NDBaseRole
{
	DECLARE_CLASS (NDNpc)
public:
	NDNpc();
	~NDNpc();
	void Init(); override				
	void OnMoving(bool bLastPos); override
	void OnMoveEnd(); override
	bool OnDrawBegin(bool bDraw); override
	void OnDrawEnd(bool bDraw); override

	void BeforeRunAnimation(bool bDraw); override
public:
	//以下方法供逻辑层使用－－－begin
	//......
	void Initialization(int nLookface, bool bFaceRight=true); hide

	void WalkToPosition(CCPoint toPos);
	//－－－end
	//void SetHairImage(int hair, int hairColor);
	void SetExpresstionImage(int nExpresstion);

	// 设置npc任务提示
	void SetNpcState(NPC_STATE state);

	NPC_STATE GetNpcState() const
	{
		return m_eNPCState;
	}

	void SetStatus(int status);

	// 勿用,如需获取请直接访问ridePet
	//NDRidePet* GetRidePet();

	void AddWalkPoint(int col, int row);

	void SetActionOnRing(bool bOn);
	bool IsActionOnRing();

	void SetDirectOnTalk(bool bOn);
	bool IsDirectOnTalk();

	void ShowUpdate(bool bshow, bool bDraw);

	void HandleNpcMask(bool bSet);

	void SetType(int iType);
	int GetType();

	enum LableType
	{
		eLableName, eLabelDataStr,
	};
	void SetLable(LableType eLableType, int x, int y, std::string text,
			cocos2d::ccColor4B color1, cocos2d::ccColor4B color2);

	bool IsRoleNpc()
	{
		return m_bRoleNpc;
	}

	bool IsFarmNpc()
	{
		return m_bFarmNpc;
	}

	void SetFarmNpc(bool bFarmNpc)
	{
		m_bFarmNpc = bFarmNpc;
	} 

	void initUnpassPoint();

	bool IsPointInside(CCPoint point);

	bool getNearestPoint(CCPoint srcPoint, CCPoint& dstPoint);

	void ShowHightLight(bool bShow);
public:
	int m_nCol;
	int m_nRow;
	int m_nLook;
	int m_nModel;

private:
	NPC_STATE m_eNPCState;
public:
	// 骑宠相关
	//NDRidePet	*ridepet;
	std::string m_strData;
	std::string m_strTalk;

private:
	NDUILabel *m_pkNameLabel[2];
	NDUILabel *m_pkDataStrLebel[2];
	NDPicture *m_pkPicBattle;
	NDPicture *m_pkPicState;

	std::deque<CCPoint> m_dequePos;

	bool m_bActionOnRing;
	bool m_bDirectOnTalk;

	int m_iStatus;
	// role型 npc
	bool m_bRoleNpc;

	NDSprite* m_pkUpdate;

	int m_iType;

	bool m_bFarmNpc;

	std::vector<CCRect> m_vUnpassRect;

	bool m_bUnpassTurn;

	CCRect m_kRectState;

private:
	bool IsUnpassNeedTurn();
	bool GetTaskList(ID_VEC& idVec);
	int GetDataBaseData(int nIndex);

private:
	NDNpcLogic*	m_npcLogic;	
};

NS_NDENGINE_END

#endif
