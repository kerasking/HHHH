//
//  NDPlayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef __NDPlayer_H
#define __NDPlayer_H

#include "NDManualRole.h"
#include <string>
#include "EnumDef.h"
#include "Task.h"
#include "NDUIDialog.h"
#include "NDTimer.h"
//#include "GatherPoint.h"
#include "BattleUtil.h"

using namespace std;

#define FOCUS_JUDGE_DISTANCE (33)

namespace NDEngine
{
	class NDNpc;
	class NDUIDialog;
	
	typedef vector<Task*>						vec_task;
	typedef vec_task::iterator					vec_task_it;

	class NDPlayer : 
	public NDManualRole, 
	public NDUIDialogDelegate,
	public ITimerCallback
	{
		DECLARE_CLASS(NDPlayer)
	public:
		NDPlayer();
		~NDPlayer();
		
	public:
		// 逻辑接口
		static NDPlayer& defaultHero(int lookface = 0, bool bSetLookFace = false);
		static void pugeHero();
		void Walk(CGPoint toPos, SpriteSpeed speed, bool mustArrive=false); override

		void SetPosition(CGPoint newPosition); override
		
		void Update(unsigned long ulDiff); override
		//用于绘制
		//void SetPositionEx(CGPoint newPosition);
	public:
		// true:寻路操作被执行,false:其它操作被执行
		bool ClickPoint(CGPoint point, bool bLongTouch, bool bPath=true);
		bool DealClickPointInSideNpc(CGPoint point);
		bool CancelClickPointInSideNpc();
		
		void stopMoving(bool bResetPos=true, bool bResetTeamPos=true); hide
		
		//勿用
		void OnMoving(bool bLastPos); override
		void OnMoveBegin();
		void OnMoveEnd(); override
		
		void OnDrawEnd(bool bDraw); override
		
		void SetLoadMapComplete(){ isLoadingMap = false; }
		
		void CaclEquipEffect();
		
		int GetOrder(); override
		
		void OnDialogClose(NDUIDialog* dialog); override
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
		void OnTimer(OBJID tag); override
	
		void NextFocusTarget();
		void UpdateFocus();
		
		bool IsGathering() { return m_bCollide; }
		void ResetGather() { m_bCollide = false; /*m_gp = NULL;*/ }
		
		void ResetFocusRole();
		
		void SetFocusRole(NDBaseRole *baserole);
		
		void UpdateFocusPlayer();
		
		// 战斗技能
		void AddSkill(OBJID idSkill);
		void DelSkill(OBJID idSkill);
		SET_BATTLE_SKILL_LIST& GetSkillList(SKILL_TYPE type);
		bool IsBattleSkillLearned(OBJID idSkill);
		
		Task* GetPlayerTask(int idTask);
		
		void BattleStart();
		
		void BattleEnd(int iResult);
		
		bool canUnpackRidePet();
		
		int GetCanUseRepute();
		
		void SendNpcInteractionMessage(unsigned int idNpc);
		// NPC焦点相关操作
	public:
		NDNpc* GetFocusNpc();
		int GetFocusNpcID();
		bool IsFocusNpcValid();
		void InvalidNPC();
		
	
		bool DirectSwitch(int iSwitchCellX, int iSwitchCellY, int iPassIndex);
		bool CanSwitch(int iSwitchCellX, int iSwitchCellY);
		
	private:
		
		//bool doGatherPointCollides(GatherPoint *se); 
		void processSwitch();
		bool isRoleCanMove();

		void HandleDirectKey();
		
		void HandleStateBattleField();
		
		void HandleStateDacoity();
	private:
		// 勿用
		static bool m_bFirstUse;
	private:
		bool isLoadingMap;
		
		
	public:
		int eMoney; // 元宝	 
		int phyPoint;// 力量  --basic
		int dexPoint; // 敏捷 --basic
		int magPoint; // 魔法 --basic
		int defPoint; // 体质 --basic
		int lvUpExp; // 下次升级所需EXP
		int sp;
		/** 声望: 国家, 阵营; 荣誉 */
		int swGuojia;
		int swCamp;
		int honour;
		int expendHonour; // 已消耗荣誉值
		
		int synMoney; // 帮派银两
		int synContribute; // 帮派帮贡
		int synSelfContribute; // 个人帮贡
		int synSelfContributeMoney; // 个人捐献钱
		
		int iStorgeMoney; // 仓库银两
		int iStorgeEmoney; // 仓库元宝
		int iSkillPoint; // 灵气值
		
		int iRecordMap;
		
		// 玩家当前所在地图id
		int idCurMap;
		
		int eAtkSpd, eAtk, eDef, eHardAtk, eSkillAtk, eSkillDef,
		eSkillHard, eDodge, ePhyHit;// 装备直接属性增加值
		
		// 属性相关,属性界面更改属性缓存
		int iTmpPhyPoint, iTmpDexPoint, iTmpMagPoint, iTmpDefPoint, iTmpRestPoint;
		
		// 特殊状态附加属性
		/** 力量附加 */
		int phyAdd;
		
		/** 敏捷附加 */
		int dexAdd;
		
		/** 体力附加 */
		int defAdd;
		
		/** 智力附加 */
		int magAdd;
		
		/** 物攻附加 */
		int wuGongAdd;
		
		/** 物防附加 */
		int wuFangAdd;
		
		/** 法攻附加 */
		int faGongAdd;
		
		/** 法防附加 */
		int faFangAdd;
		
		/** 闪避附加 */
		int sanBiAdd;
		
		/** 暴击附加 */
		int baoJiAdd;
		
		/** 物理命中附加 */
		int wuLiMingZhongAdd;
		
		/** 积分*/
		int jifeng;
	
		/**活动值*/
		int activityValue;
		int activityValueMax;
		/**技能槽*/
		int m_nMaxSlot;
		/**VIP等级*/
		int m_nVipLev;
		
	public:
		void SetLookface(int nLookface);
		int GetLookface();
		void SetLocked(bool locked){m_bLocked=locked;}
	public:
		int m_iFocusManuRoleID;
		//NDNpc *m_npcFocus;
		
		int targetIndex; // 玩家当前选择的角色索引,该索引是magmgr里的所有NPC,其它玩家所在容器的索引.
		
		vec_task m_vPlayerTask; //玩家任务列表
	private:
		bool m_bCollide;
		//GatherPoint *m_gp;
		NDTimer *m_timer;
		NDUIDialog *m_dlgGather;
		bool m_bRequireDacoity;
		bool m_bRequireBattleField;
		int m_iDacoityStep, m_iBattleFieldStep;
		int m_iFocusNpcID;
		bool m_bLocked;
		SET_BATTLE_SKILL_LIST m_setActSkill;
		SET_BATTLE_SKILL_LIST m_setPasSkill;
		
		int m_nLookface;
	public:
		// 服务端发过来不需要计算的数据
		struct  
		{
			int extra_phyPoint;
			int extra_dexPoint;
			int extra_magPoint;
			int extra_defPoint;
			int phy_atk;
			int phy_def;
			int mag_atk;
			int mag_def;
			int atk_speed;
			int hitrate;
			int dodge;
			int hardhit;
		}m_caclData;
		
	};
}


#endif