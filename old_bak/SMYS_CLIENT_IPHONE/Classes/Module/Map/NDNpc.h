//
//  NDNpc.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef __NDNpc_H
#define __NDNpc_H

#include "NDBaseRole.h"
#include <string>
#include "EnumDef.h"
#include "NDUILabel.h"
#include "NDPicture.h"

namespace NDEngine 
{
	/** btState为1时灰色叹号,2彩色叹号,3灰色问号,4彩色问号 */
	enum 
	{
		QUEST_NONE = 0x01,// 没有任务
		QUEST_CANNOT_ACCEPT = 0x02,// 有任务但是级别不对
		QUEST_CAN_ACCEPT = 0x04, // 有任务可接
		QUEST_NOT_FINISH = 0x08, // 有任务未完成
		QUEST_FINISH = 0x10, // 有任务已完成(优先级最高)
	};
	
	class NDRidePet;
	class NDNpc : public NDBaseRole 
	{
		DECLARE_CLASS(NDNpc)
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
		void Initialization(int lookface); hide
		
		void WalkToPosition(CGPoint toPos);
		//－－－end
		//void SetHairImage(int hair, int hairColor);
		void SetExpresstionImage(int nExpresstion);
		
		// 设置npc任务提示
		void SetNpcState(NPC_STATE state);
		
		NPC_STATE GetNpcState() const {
			return this->npcState;
		}
		
		void SetStatus(int status);
		
		// 勿用,如需获取请直接访问ridePet
		//NDRidePet* GetRidePet();
		
		void AddWalkPoint(int col, int row);
		
		void SetActionOnRing(bool on);
		bool IsActionOnRing();
		
		void SetDirectOnTalk(bool on);
		bool IsDirectOnTalk();
		
		void ShowUpdate(bool bshow, bool bDraw);
		
		void HandleNpcMask(bool bSet);
		
		void SetType(int iType);
		int GetType();
		
		enum  LableType{ eLableName, eLabelDataStr, };
		void SetLable(LableType eLableType, int x, int y, std::string text, ccColor4B color1, ccColor4B color2);
		
		bool IsRoleNpc() {
			return this->m_bRoleNpc;
		}
		
		bool IsFarmNpc() { return m_bFarmNpc; }
		
		void SetFarmNpc(bool bFarmNpc) { m_bFarmNpc = bFarmNpc; } 
		
		void initUnpassPoint();
		
		bool IsPointInside(CGPoint point);
		
		bool getNearestPoint(CGPoint srcPoint, CGPoint& dstPoint);
		
		void ShowHightLight(bool bShow);
	public:
		int col;
		int row;
		int look;
		int model;
		
	private:
		 NPC_STATE npcState;
	public:
		// 骑宠相关
		//NDRidePet	*ridepet;
		std::string dataStr;
		std::string talkStr;
	private:
		NDUILabel *m_lbName[2], *m_lbDataStr[2];
		
		NDPicture *m_picBattle, *m_picState;
		
		std::deque<CGPoint> m_dequePos;
		
		bool m_bActionOnRing;
		bool m_bDirectOnTalk;
		int m_iStatus;
		// role型 npc
		bool m_bRoleNpc;
		
		NDSprite* m_sprUpdate;
		int m_iType;
		
		bool m_bFarmNpc;
		
		std::vector<CGRect> m_vUnpassRect;
		
		bool m_bUnpassTurn;
		
		CGRect m_rectState;
	private:
		bool IsUnpassNeedTurn();
		
		void RefreshTaskState();
		bool GetTaskList(ID_VEC& idVec);
		int GetDataBaseData(int nIndex);
		bool GetPlayerCanAcceptList(ID_VEC& idVec);
	};
}

#endif