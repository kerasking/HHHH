//
//  NDPlayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-27.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
#ifndef __NDPlayer_H
#define __NDPlayer_H

#include "NDManualRole.h"
#include <string>
#include "EnumDef.h"
#include "NDUIDialog.h"
#include "NDTimer.h"
#include "BattleUtil.h"
//#include "GatherPoint.h"

class Task;

using namespace std;

#define FOCUS_JUDGE_DISTANCE (33*RESOURCE_SCALE_960)

NS_NDENGINE_BGN

class NDNpc;
class NDUIDialog;

typedef vector<Task*> vec_task;
typedef vec_task::iterator vec_task_it;

class NDPlayer: public NDManualRole,
		public NDUIDialogDelegate,
		public ITimerCallback
{
	DECLARE_CLASS (NDPlayer)
public:
	NDPlayer();
	~NDPlayer();

public:
	// 逻辑接口
	static NDPlayer& defaultHero(int lookface = 0, bool bSetLookFace = false);
	static void pugeHero();
	void Walk(CCPoint toPos, SpriteSpeed speed, bool mustArrive = false);

	void SetPosition(CCPoint newPosition);

	void Update(unsigned long ulDiff);
	//用于绘制
	//void SetPositionEx(CCPoint newPosition);
public:
	// true:寻路操作被执行,false:其它操作被执行
	bool ClickPoint(CCPoint point, bool bLongTouch, bool bPath = true);
	bool DealClickPointInSideNpc(CCPoint point);
	bool CancelClickPointInSideNpc();

	void stopMoving(bool bResetPos = true, bool bResetTeamPos = true);

	//勿用
	void OnMoving(bool bLastPos);
	void OnMoveBegin();
	void OnMoveEnd();

	void OnDrawEnd(bool bDraw);
	void DrawNameLabel(bool bDraw);

	void SetLoadMapComplete()
	{
		m_bIsLoadingMap = false;
	}

	void CaclEquipEffect();

	int GetOrder();

	void OnDialogClose(NDUIDialog* dialog);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	virtual void OnTimer(OBJID tag);

	void NextFocusTarget();
	void UpdateFocus();

	bool IsGathering()
	{
		return m_bCollide;
	}
	void ResetGather()
	{
		m_bCollide = false;
	//	m_gp = NULL;
	}

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

	void SendNpcInteractionMessage(unsigned int uiNPCID);
	// NPC焦点相关操作
public:
	NDNpc* GetFocusNpc();
	int GetFocusNpcID();
	bool IsFocusNpcValid();
	void InvalidNPC();

	bool DirectSwitch(int iSwitchCellX, int iSwitchCellY, int iPassIndex);
	bool CanSwitch(int iSwitchCellX, int iSwitchCellY);

private:

//	bool doGatherPointCollides(GatherPoint *se);
	void processSwitch();
	bool isRoleCanMove();

	void HandleDirectKey();

	void HandleStateBattleField();

	void HandleStateDacoity();

public:
	override void RunAnimation(bool bDraw);

protected:

	virtual void InitializationFroLookFace(int lookface, bool bSetLookFace = true);
	virtual void debugDraw();

private:
	// 勿用
	static bool ms_bFirstUse;
private:
	bool m_bIsLoadingMap;

public:

	int m_nEMoney; // 元宝
	int m_nPhyPoint; // 力量  --basic
	int m_nDexPoint; // 敏捷 --basic
	int m_nMagPoint; // 魔法 --basic
	int m_nDefPoint; // 体质 --basic
	int m_nLevelUpExp; // 下次升级所需EXP
	int m_nSP;
	/** 声望: 国家, 阵营; 荣誉 */
	int m_nSWCountry;
	int m_nSWCamp;
	int m_nHonour;
	int m_nExpendHonour; // 已消耗荣誉值

	int m_nSynMoney; // 帮派银两
	int m_nSynContribute; // 帮派帮贡
	int m_nSynSelfContribute; // 个人帮贡
	int m_nSynSelfContributeMoney; // 个人捐献钱

	int m_nStorgeMoney; // 仓库银两
	int m_nStorgeEmoney; // 仓库元宝
	int m_nSkillPoint; // 灵气值

	int iRecordMap;

	// 玩家当前所在地图id
	int m_nCurMapID;

	int m_eAtkSpd;
	int m_eAtk;
	int m_eDef;
	int m_eHardAtk;
	int m_eSkillAtk;
	int m_eSkillDef;
	int m_eSkillHard;
	int m_eDodge;
	int	m_ePhyHit; // 装备直接属性增加值

	// 属性相关,属性界面更改属性缓存
	int m_iTmpPhyPoint;
	int m_iTmpDexPoint;
	int m_iTmpMagPoint;
	int m_iTmpDefPoint;
	int m_iTmpRestPoint;

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
	int m_nGamePoints;

	/**活动值*/
	int m_nActivityValue;
	int m_nActivityValueMax;
	/**技能槽*/
	int m_nMaxSlot;
	/**VIP等级*/
	int m_nVipLev;

public:
	void SetLocked(bool locked)
	{
		m_bLocked = locked;
	}
public:
	int m_iFocusManuRoleID;
	//NDNpc *m_npcFocus;

	int m_nTargetIndex; // 玩家当前选择的角色索引,该索引是magmgr里的所有NPC,其它玩家所在容器的索引.

	vec_task m_vPlayerTask; //玩家任务列表
private:
	bool m_bCollide;
//	GatherPoint *m_gp;
	NDTimer* m_pkTimer;
	NDUIDialog* m_kGatherDlg;
	bool m_bRequireDacoity;
	bool m_bRequireBattleField;
	int m_iDacoityStep;
	int m_iBattleFieldStep;
	int m_iFocusNpcID;
	bool m_bLocked;
	SET_BATTLE_SKILL_LIST m_setActSkill;
	SET_BATTLE_SKILL_LIST m_setPasSkill;

	//int m_nLookface;
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
	} m_caclData;

};

NS_NDENGINE_END

#endif
