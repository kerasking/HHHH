//
//  NDManualRole.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-17.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
#ifndef __NDManualRole_H
#define __NDManualRole_H

#include "NDBaseRole.h"
//#include "NDBattlePet.h"
//#include "NDRidePet.h"
#include <string>
#include <deque>
#include "NDMonster.h"
#include "NDUIImage.h"
#include "SyndicateCommon.h"
#include "NDUILabel.h"
#include "NDLightEffect.h"

using namespace std;

namespace NDEngine
{
	#define BEGIN_PROTECTED_TIME 3// 人物一开始的的保护时间,即不会遇怪
	
	
	#define SHOW_NAME_ROLE_W (64) // 在w(-64,64)区域内显示怪物和npc名字

	#define SHOW_NAME_ROLE_H (64)
	
	typedef struct _tagShowPetInfo
	{
		OBJID	idPet;
		int		lookface;
		int		quality;
		
		_tagShowPetInfo() 
		{
			memset(this, 0, sizeof(*this));
		}
		
		_tagShowPetInfo(OBJID idPet, int lookface, int quality)
		{
			this->idPet		= idPet;
			this->lookface	= lookface;
			this->quality	= quality;
		}
		
		bool operator==(const _tagShowPetInfo& r)
		{
			return this->lookface == r.lookface;
		}
	}ShowPetInfo;
	
	class NDPicture;
	class NDManualRole : public NDBaseRole 
	{
		DECLARE_CLASS(NDManualRole)
		
	public:
		// 服务端下发的光效显示
		typedef struct _tagServerEffect
		{
			bool bQiZhi;
			int severEffectId;
			NDLightEffect* effect;
			_tagServerEffect()
			{
				this->bQiZhi = false;
				this->effect = NULL;
				this->severEffectId = 0;
			}
			
			_tagServerEffect(bool bQiZhi, NDLightEffect* effect, int severEffectId)
			{
				this->bQiZhi = bQiZhi;
				this->effect = effect;
				this->severEffectId = severEffectId;
			}
			
		}ServerEffect;
		
	public:
		NDManualRole();
		~NDManualRole();
		
	public:
		void Update(unsigned long ulDiff); override
		void SetAction(bool bMove, bool ignoreFighting=false); hide
		bool AssuredRidePet(); hide
		
		void Initialization(int lookface, bool bSetLookFace=true); hide 
		
		virtual void Walk(CGPoint toPos, SpriteSpeed speed);
		void OnMoving(bool bLastPos); override
		void OnMoveEnd(); override
		void SetPosition(CGPoint newPosition); override
		void OnMoveTurning(bool bXTurnigToY, bool bInc); override
		
		bool OnDrawBegin(bool bDraw); override
		void OnDrawEnd(bool bDraw); override
		
		virtual void stopMoving(bool bResetPos=true, bool bResetTeamPos=true); hide
		
		void drawEffects(bool bDraw); override
		
		void unpakcAllEquip(); override
		
		void SetServerPositon(int col, int row);
		
		void SetServerDir(int dir);
		
		int GetServerX(){ return m_nServerCol; }
		int GetServerY(){ return m_nServerRow; }
		
		void uppackBattlePet();
		
		// 更新某一状态
		void UpdateState(int nState, bool bSet);
		// 直接设置状态
		void SetState(int nState);
		
		bool IsInState(int iState);
		
		// 正负状态
		bool IsInDacoity();
		
		void HandleEffectDacoity();
		
		// 勿用,如需获取请直接访问battlepet
		//NDBattlePet* GetBattlePet();
		
		void AddWalkDir(int dir);
		
		// 队伍相关接口
		bool isTeamMember(){ return m_nTeamID != 0; }
		bool isTeamLeader(){ return m_nTeamID == m_nID; }
		void teamSetServerDir(int dir);
		void teamSetServerPosition(int iCol, int iRow);
		
		bool IsSafeProtected(){ return m_bIsSafeProtected; }
		void setSafeProtected(bool isSafeProtected);
		
		void updateFlagOfQiZhi();
		
		void updateTransform(int idLookface);
		
		bool isTransformed();
		
		// 军团相关
		void setSynRank(int rank) {
			this->synRank = rank;
			this->m_strSynRank = getRankStr(synRank);
		}
		
		int getSynRank() const {
			return this->synRank;
		}
		
		void TeamSetToLastPos(bool bSet) { m_bToLastPos = bSet; }
		
		void playerLevelUp();
		
		void playerMarry();
		
		void updateBattlePetEffect();
		void refreshEquipmentEffectData();
		
		void BackupPositon();
		CGPoint GetBackupPosition();
		
		// 勿用,如需获取请直接访问ridePet
		//NDRidePet* GetRidePet();
		// 判断传入的角色绘制的优先级是否比自己高
		bool IsHighPriorDrawLvl(NDManualRole* otherRole);
		
		void SetServerEffect(std::vector<int>& vEffect);
		bool isEffectTurn(int effectTurn);
		void drawServerEffect(std::vector<ServerEffect>& vEffect, bool draw);
		void drawServerBackEffect(bool draw);
		void drawServerFrontEffect(bool draw);
		bool IsServerEffectHasQiZhi();
		
		CGRect GetFocusRect(); override
		
		bool IsInGraveStoneState();
		
		//void SetShowPet(ShowPetInfo& info);
		bool GetShowPetInfo(ShowPetInfo& info);
		//const NDBattlePet* GetShowPet();
		void ResetShowPetPosition();
		void ResetShowPet();
		int GetPathDir(int oldX, int oldY, int newX, int newY);
		bool GetXYByDir(int oldX, int oldY, int dir, int& newX, int& newY);
		bool IsDirFaceRight(int nDir);
	public:
		// 爵位
		static std::string	GetPeerageName(int nPeerage);
		static unsigned int	GetPeerageColor(int nPeerage);
		
	private:
		bool CheckToLastPos();
		void ShowNameLabel(bool bDraw);
		enum  LableType{ eLableName, eLabelSynName, eLablePeerage,};
		void SetLableName(std::string text, int x, int y, bool isEnemy);
		void SetLable(LableType eLableType, int x, int y, std::string text, cocos2d::ccColor4B color1, cocos2d::ccColor4B color2);
	protected:
		void WalkToPosition(const std::vector<CGPoint>& vec_toPos, SpriteSpeed speed, bool moveMap, bool mustArrive=false);
		void processTeamMemberMove(bool bDraw);
		
		enum { eMoveTypeBegin = 0, eMoveTypeMoving, eMoveTypeEnd,};
		void processTeamMemberOnMove(int itype);
		
		void resetTeamPos();
		void teamMemberWalkToPosition(const std::vector<CGPoint>& toPos);
		void teamMemberWalkResetPosition();
		void teamMemberAction(bool bAction);
		void teamMemberStopMoving(bool bResetPos);
		bool TeamIsToLastPos() { return m_bToLastPos; }

	public:
		void SetTeamToLastPos();
	public:
		int m_nState;								// 状态
		int m_nMoney;								// 银两
		int	m_dwLookFace;							// 创建人物的时候有6种外观可供选择外观
		int m_nProfesstion;						//玩家的职业
		int m_nPKPoint;							// pk值
		
		string m_strSynName;							// 帮派名字
		string m_strSynRank;						// 官职名字
		
		string m_strRank;
		int	m_nRank;
		
		bool m_bLevelUp;
		
		int m_nExp; // 经验值
		int m_nRestPoint; // 剩余点数
		
		int m_nTeamID; // 队伍id
		
		/* 伴侣id**/
		int m_nMarriageID;
		
		/* 伴侣名字**/
		std::string m_strLoverName;
		
		int m_nMarriageState;
		
		// 骑宠相关
		//NDRidePet	*ridepet;
		
		int m_nCampOutOfTeam;
		
		bool m_bClear;
		
		NDMonster* pkAniGroupTransformed;
		
		vector<int> m_vEquipsID;
		
		// 爵位
		int m_nPeerage;
	private:
		// 战宠相关
		//CAutoLink<NDBattlePet> m_pBattlePetShow;
		ShowPetInfo	m_kInfoShowPet;
		
		deque<int>	m_dequeWalk;
		bool		m_bUpdateDiff;
		int idTransformTo;
		NDPicture* m_picVendor;
		NDPicture* m_picBattle;
		NDPicture* m_picGraveStone;
		int synRank;							// 帮派级别
		
		NDLightEffect* m_numberOneEffect;
		void RunNumberOneEffect();
		
	protected:

		int m_nBeginProtectedTime;
		bool m_bIsSafeProtected;
		int m_nServerCol;
		int m_nServerRow;

	public:

		CGPoint m_kOldPos;

	protected:

		bool m_bToLastPos;
		
		NDUILabel *m_lbName[2];
		NDUILabel *m_lbSynName[2];
		NDUILabel *m_lbPeerage[2];
		
		NDSprite* m_pkEffectFeedPetAniGroup;
		NDSprite* m_pkEffectArmorAniGroup;
		NDSprite* m_pkEffectDacoityAniGroup;
		
		CGPoint m_kPosBackup;

	private:

		std::vector<ServerEffect> m_kServerEffectBack;
		std::vector<ServerEffect> m_kServerEffectFront;
	};
}

#endif


