//
//  NDPlayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-27.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDMapLayer.h"
#include "NDMsgDefine.h"
#include "NDDirector.h"
#include "GameSceneLoading.h"
#include "ItemMgr.h"
#include "NDItemType.h"
#include "CCPointExtension.h"
#include "NDMapMgr.h"
#include "NDNpc.h"
#include "NDUISynLayer.h"
#include "NDAutoPath.h"
#include "BattleMgr.h"
#include "BattleSkill.h"
#include "EnumDef.h"
#include "GameScene.h"
#include "VendorBuyUILayer.h"
#include "HarvestEvent.h"
#include "DirectKey.h"
#include "AutoPathTip.h"
#include "QuickInteraction.h"
#include "NDString.h"
#include "NDUtility.h"

#include "ScriptMgr.h"
#include "ScriptTask.h"
#include <sstream>

#include "SMGameScene.h"
#include "ScriptGlobalEvent.h"
#include "Task.h"

NS_NDENGINE_BGN

#define MAX_DACOITY_STEP (5)

#define MAX_BATTLEFIELD_STEP (5)

#define INVALID_FOCUS_NPC_ID (0)

//劫匪与捕块判断距离
#define DACOITY_JUDGE_DISTANCE (0)

//战场中对立方判断距离( (cellX1-cellX2)^2+(cellY1-cellY2)^2 )
#define BATTLEFIELD_DISTANCE (1)

NDMapLayer* M_GetMapLayer()
{
	return NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene)));
}

IMPLEMENT_CLASS(NDPlayer, NDManualRole)

bool NDPlayer::ms_bFirstUse = true;

NDPlayer::NDPlayer() :
//money(0),
m_nEMoney(0),
m_nPhyPoint(0),
m_nDexPoint(0),
m_nMagPoint(0),
m_nDefPoint(0),
m_nLevelUpExp(0),
m_nSP(0),
m_nSWCountry(0),
m_nSWCamp(0),
m_nHonour(0),
//synRank(-1),
m_nSynMoney(0),
m_nSynContribute(0),
m_nSynSelfContribute(0),
m_nSynSelfContributeMoney(0),
m_nCurMapID(0)
{
	phyAdd = 0;

	/** 敏捷附加 */
	dexAdd = 0;

	/** 体力附加 */
	defAdd = 0;

	/** 智力附加 */
	magAdd = 0;

	/** 物攻附加 */
	wuGongAdd = 0;

	/** 物防附加 */
	wuFangAdd = 0;

	/** 法攻附加 */
	faGongAdd = 0;

	/** 法防附加 */
	faFangAdd = 0;

	/** 闪避附加 */
	sanBiAdd = 0;

	/** 暴击附加 */
	baoJiAdd = 0;

	/** 物理命中附加 */
	wuLiMingZhongAdd = 0;

	m_nGamePoints = 0;

	m_nServerCol = -1;
	m_nServerRow = -1;
	m_nStorgeMoney = 0;
	m_nStorgeEmoney = 0;
	m_nSkillPoint = 0;

	// 装备直接属性增加值
	m_eAtkSpd = 0;
	m_eAtk = 0;
	m_eDef = 0;
	m_eHardAtk = 0;
	m_eSkillAtk = 0;
	m_eSkillDef = 0;
	m_eSkillHard = 0;
	m_eDodge = 0;
	m_ePhyHit = 0;

	m_iTmpPhyPoint = 0;
	m_iTmpDexPoint = 0;
	m_iTmpMagPoint = 0;
	m_iTmpDefPoint = 0;
	m_iTmpRestPoint = 0;

	m_nBeginProtectedTime = 0;

	m_iFocusManuRoleID = -1;
	//m_npcFocus = NULL;

	m_nTargetIndex = 0;
	m_bCollide = false;
	m_pkTimer = new NDTimer();
	m_kGatherDlg = NULL;

	memset(&m_caclData, 0, sizeof(m_caclData));

	m_bRequireDacoity = false;
	m_iDacoityStep = 0;
	m_iBattleFieldStep = 0;

	InvalidNPC();

	m_nActivityValue = 0;
	m_nActivityValueMax = 0;
	m_nExpendHonour = 0;
	m_nMaxSlot = 0;
	m_nVipLev = 0;
	m_nLookface = 0;
	m_bLocked = false;
}

NDPlayer::~NDPlayer()
{
	g_pkDefaultHero = NULL;
	
	SAFE_DELETE(m_pkTimer);
}

NDPlayer& NDPlayer::defaultHero(int lookface, bool bSetLookFace)
{
	if (ms_bFirstUse)
	{
		ms_bFirstUse = false;
	}

	if (!g_pkDefaultHero)
	{
		g_pkDefaultHero = new NDPlayer;//CREATE_CLASS(NDSprite,"NDPlayer");
		g_pkDefaultHero->SetNodeLevel(NODE_LEVEL_MAIN_ROLE);
		g_pkDefaultHero->InitializationFroLookFace(lookface, false);
	}

	return *((NDPlayer*)g_pkDefaultHero);
}

void NDPlayer::pugeHero()
{
	SAFE_DELETE_NODE (g_pkDefaultHero);
}

void NDPlayer::SendNpcInteractionMessage(unsigned int uiNPCID)
{
	// 转到脚本处理
	ScriptMgr& kScript = ScriptMgrObj;
	std::stringstream ssNpcFunc;
	ssNpcFunc << "NPC_CLICK_" << uiNPCID;
	bool bRet = kScript.IsLuaFuncExist(ssNpcFunc.str().c_str(), "NPC");

	if (bRet)
	{
 		bRet = kScript.excuteLuaFunc(ssNpcFunc.str().c_str(), "NPC", uiNPCID);
		kScript.excuteLuaFunc("AttachTask", "NPC", uiNPCID);
	}
	else
	{
		bRet = kScript.excuteLuaFunc("NPC_CLICK_COMMON", "NPC", uiNPCID);
	}

	return;

	ShowProgressBar;
	NDTransData kTranslateData(_MSG_NPC);
	kTranslateData << (int) uiNPCID << (unsigned char) 0 << (unsigned char) 0 << int(123);
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&kTranslateData);
}

bool NDPlayer::DealClickPointInSideNpc(CCPoint point)
{
	bool bDeal = false;

	NDMapMgr::VEC_NPC& npclist = NDMapMgrObj.m_vNPC;
	for (NDMapMgr::vec_npc_it it = npclist.begin(); it != npclist.end(); it++) 
	{
		NDNpc* npc = *it;

		if (!npc)
		{
			continue;
		}

		if (npc->IsPointInside(point))
		{
			bDeal = true;

			npc->ShowHightLight(true);
		}
		else
		{
			npc->ShowHightLight(false);
		}
	}

	return bDeal;
}

bool NDPlayer::CancelClickPointInSideNpc()
{
	NDMapMgr::VEC_NPC& npclist = NDMapMgrObj.m_vNPC;
	for (NDMapMgr::vec_npc_it it = npclist.begin(); it != npclist.end(); it++) 
	{
		NDNpc* npc = *it;

		if (!npc)
		{
			continue;
		}

		npc->ShowHightLight(false);
	}

	return true;

}

bool NDPlayer::ClickPoint(CCPoint point, bool bLongTouch, bool bPath/*=true*/)
{
//	CCLog( "NDPlayer::ClickPoint(%d, %d), @0\r\n", (int)point.x, (int)point.y );

	if (AutoPathTipObj.IsWorking())
	{
		AutoPathTipObj.Stop();
	}
	
	if (ScriptMgrObj.excuteLuaFunc("CloseMainUI", ""))
	{
		//this->stopMoving();
		//return false;
	}
	
	if (bLongTouch && bPath)
	{
		//长按不执行其它操作
//		CCLog( "NDPlayer::ClickPoint(%d, %d), @1\r\n", (int)point.x, (int)point.y );
//		WriteCon( "NDPlayer::ClickPoint(%d, %d), @1\r\n", (int)point.x, (int)point.y );
		NDPlayer::defaultHero().Walk(point, SpriteSpeedStep8);
		return true;
	}
	
	bool bNpcPath = false;

	NDScene* pkRunningScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (pkRunningScene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene)))
	{
		//CSMGameScene* gameScene = (CSMGameScene*)pkRunningScene;
		if (!NDUISynLayer::IsShown())// && !gameScene->IsUIShow())
		{
			do {

				bool bDealed = false;
				// 1.先处理npc
				NDMapMgr::VEC_NPC& npclist = NDMapMgrObj.m_vNPC;
				for (NDMapMgr::vec_npc_it it = npclist.begin(); it != npclist.end(); it++) 
				{
					NDNpc* npc = *it;

					if (npc && npc->IsPointInside(point))
					{
						int dis = NDMapMgrObj.getDistBetweenRole(this, npc);

						CCPoint pos;

						if ( dis < FOCUS_JUDGE_DISTANCE )
						{
							SendNpcInteractionMessage(npc->m_nID);
							return false;
						}
						else if (npc->getNearestPoint(this->GetPosition(), pos))
						{
							point = ccpAdd(pos, CCPointMake(0, 30));

							AutoPathTipObj.work(npc->m_strName);
							bDealed = true;
							bNpcPath = true;
							break;

						}
					}
				}

				if (bDealed)
				{
					break;
				}

								/*
				// 2.再处理角色
				//other role
				if ( m_iFocusManuRoleID != -1 )
				{
					NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(m_iFocusManuRoleID);
					if (otherplayer && cocos2d::CCRect::CCRectContainsPoint(otherplayer->GetFocusRect(), point)) 
					{
						if ( otherplayer->IsInState(USERSTATE_BOOTH) )
						{ //与其摆摊玩家交互
							NDUISynLayer::Show();
							VendorBuyUILayer::s_idVendor = otherplayer->m_id;
							
							NDTransData bao(_MSG_BOOTH);
							bao << Byte(BOOTH_QUEST) << otherplayer->m_id << int(0);
							// SEND_DATA(bao);
						}
						
						QuickInteraction::RefreshOptions();
						
						return false;
					}
				}
				else
				{
					NDMapMgr::map_manualrole& roles = NDMapMgrObj.GetManualRoles();
					
					bool find = false;
					for (NDMapMgr::map_manualrole_it it = roles.begin(); it != roles.end(); it++) 
					{
						NDManualRole* role = it->second;
						
						if (role->bClear) continue;
						
						if ( !cocos2d::CCRect::CCRectContainsPoint(role->GetFocusRect(), point)) continue;
						
						find = true;
						
						SetFocusRole(role);
						
						return false;
					}
				}
				*/

				//** chh 2012-08-27 **//
				if ( m_iFocusManuRoleID == -1 )
				{
					NDMapMgr::map_manualrole& roles = NDMapMgrObj.GetManualRoles();

					bool find = false;
					for (NDMapMgr::map_manualrole_it it = roles.begin(); it != roles.end(); it++) 
					{
						NDManualRole* role = it->second;

						if (role->m_bClear) continue;

						if ( !cocos2d::CCRect::CCRectContainsPoint(role->GetFocusRect(), point)) continue;

						//find = true;

						SetFocusRole(role);

						//return false;
					}
				}

// 				NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(m_iFocusManuRoleID);
// 				if (otherplayer && cocos2d::CCRect::CCRectContainsPoint(otherplayer->GetFocusRect(), point)) 
// 				{
// 					if ( otherplayer->IsInState(USERSTATE_BOOTH) )
// 					{ //与其摆摊玩家交互
// 						NDUISynLayer::Show();
// 						VendorBuyUILayer::s_idVendor = otherplayer->m_nID;
// 
// 						NDTransData bao(_MSG_BOOTH);
// 						bao << Byte(BOOTH_QUEST) << otherplayer->m_nID << int(0);
// 						SEND_DATA(bao);
// 					}
// 
// 					ScriptGlobalEvent::OnEvent(GE_CLICK_OTHERPLAYER,otherplayer->m_nID);
// 					//QuickInteraction::RefreshOptions();
// 
// 					//return false;
// 				}

			}while(0);
		}//if
	}//if
 		
	if (bPath || bNpcPath)
	{
//		CCLog( "NDPlayer::ClickPoint(%d, %d), @2\r\n", (int)point.x, (int)point.y );
//		WriteCon( "NDPlayer::ClickPoint(%d, %d), @2\r\n", (int)point.x, (int)point.y );
		NDPlayer::defaultHero().Walk(point, SpriteSpeedStep8);
	}

	if (m_kPointList.empty())
	{
		NDMapLayer* layer = M_GetMapLayer();
		if (layer)
		{
			layer->ShowRoadSign(false);
		}

		return false;
	}

	return true;
}

void NDPlayer::stopMoving(bool bResetPos/*=true*/, bool bResetTeamPos/*=true*/)
{
	ScriptGlobalEvent::OnEvent(GE_ONMOVE_END);
	NDMapLayer* maplayer = M_GetMapLayer();
	if (maplayer)
	{
		maplayer->ShowRoadSign(false);
	}

	NDManualRole::stopMoving(bResetPos, bResetTeamPos);

	m_kTargetPos = CCPointZero;

	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
	if (scene) 
	{
		NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
		layer->SetScreenCenter(this->GetPosition());
	}

	if (AutoPathTipObj.IsWorking()) 
	{
		AutoPathTipObj.Stop();
	}
}

Task* NDPlayer::GetPlayerTask(int idTask)
{
	Task* task = NULL;

	for (vec_task_it it = m_vPlayerTask.begin(); it != m_vPlayerTask.end();
			it++)
	{
		task = *it;

		if (task->m_nTaskID == idTask)
		{
			return task;
		}
	}

	return NULL;
}

int NDPlayer::GetOrder()
{
	if (m_pkRidePet)
	{
		return m_pkRidePet->GetOrder() + 1;
	}

	return NDManualRole::GetOrder();

}

void NDPlayer::Walk(CCPoint toPos, SpriteSpeed speed, bool mustArrive/*=false*/)
{
//	CCLog( "@@ NDPlayer::Walk(%d, %d)\r\n", int(toPos.x), int(toPos.y));

	if (!isRoleCanMove())
	{
		return;
	}

	// roundup kPos
	CCPoint kPos = CCPointMake(
			int(toPos.x) / int(MAP_UNITSIZE_X) * int(MAP_UNITSIZE_X) + int(DISPLAY_POS_X_OFFSET),
			int(toPos.y) / int(MAP_UNITSIZE_Y) * int(MAP_UNITSIZE_Y) + int(DISPLAY_POS_Y_OFFSET));

	CCPoint kCurrentPosition = GetPosition();

// 	CCLog( "NDPlayer::Walk(), (%d, %d)->(%d, %d)\r\n",
// 		(int)kCurrentPosition.x, (int)kCurrentPosition.y, (int)kPos.x, (int)kPos.y );
//	WriteCon( "NDPlayer::Walk(), (%d, %d)->(%d, %d)\r\n",
//		(int)kCurrentPosition.x, (int)kCurrentPosition.y, (int)kPos.x, (int)kPos.y );

	if ((int(kCurrentPosition.x) - int(DISPLAY_POS_X_OFFSET)) % int(MAP_UNITSIZE_X) != 0
	 || (int(kCurrentPosition.y) - int(DISPLAY_POS_Y_OFFSET)) % int(MAP_UNITSIZE_Y) != 0)
	{ 
		// Cell没走完,又设置新的目标
		m_kTargetPos = kPos;
//		CCLog( "NDPlayer, Not Finished, reset target !! (%d, %d)\r\n", int(kPos.x), int(kPos.y));
	}
	else
	{
//		CCLog( "NDPlayer, WalkToPosition(%d, %d)\r\n", int(kPos.x), int(kPos.y));

		std::vector < CCPoint > vPos;
		//kPos = ccpAdd(kPos,kPos);
		vPos.push_back(kPos);
		this->WalkToPosition(vPos, speed, true, mustArrive);
	}

	ResetFocusRole();
}

void NDPlayer::SetPosition(CCPoint newPosition)
{
//@del
// 	int nNewCol = (newPosition.x - DISPLAY_POS_X_OFFSET) / MAP_UNITSIZE;
// 	int nNewRow = (newPosition.y - DISPLAY_POS_Y_OFFSET) / MAP_UNITSIZE;
// 	int nOldCol = (GetPosition().x - DISPLAY_POS_X_OFFSET) / MAP_UNITSIZE;
// 	int nOldRow = (GetPosition().y - DISPLAY_POS_Y_OFFSET) / MAP_UNITSIZE;
	CCPoint newCell = ConvertUtil::convertDisplayToCell( newPosition );
	int nNewCol = newCell.x;
	int nNewRow = newCell.y;

	CCPoint oldCell = ConvertUtil::convertDisplayToCell( GetPosition() );
	int nOldCol = oldCell.x;
	int nOldRow = oldCell.y;

	NDManualRole::SetPosition(newPosition);

	if (!isTeamLeader() && isTeamMember())
	{
		return;
	}

	if (nNewCol != nOldCol || nNewRow != nOldRow)
	{
		if (nOldCol == 0 && nOldRow == 0)
		{
		}
		else
		{
			/*
			 int dir = nNewCol != nOldCol ? ( nNewCol > nOldCol ? 3 : 2 ) :
			 ( nNewRow != nOldRow ? (nNewRow > nOldRow ? 1 : 0 ) : -1 );
			 */
			int dir = this->GetPathDir(nOldCol, nOldRow, nNewCol, nNewRow);

			if (dir != -1)
			{
				if(NDMapMgrObj.GetMotherMapID()/100000000!=9)
				{
					NDTransData data(_MSG_WALK_EX);

					data << m_nID << (unsigned short)nNewCol 
						<< (unsigned short)nNewRow << (unsigned char)dir;

					NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
				}
				m_nServerCol = nNewCol;
				m_nServerRow = nNewRow;
				//SetServerDir(dir);

				if (isTeamLeader()) 
				{
					teamSetServerDir(dir);
				}

				//processSwitch();

				if (m_iDacoityStep < MAX_DACOITY_STEP) m_iDacoityStep++;

				if (m_iBattleFieldStep < MAX_BATTLEFIELD_STEP) m_iBattleFieldStep++;
			}
		}
	}
}

void NDPlayer::Update(unsigned long ulDiff)
{
	if (m_bIsSafeProtected) 
	{
		int intervalTime = time(NULL) - m_nBeginProtectedTime;
		if (intervalTime > BEGIN_PROTECTED_TIME)
		{
			setSafeProtected(false);
		}
	}

	NDMapMgr& mgr = NDMapMgrObj;
	if (mgr.GetBattleMonster()) 
	{
		m_kTargetPos = CCPointZero;
		return;
	}

	if (!m_bRequireBattleField && m_iBattleFieldStep >= MAX_BATTLEFIELD_STEP)
	{
		HandleStateBattleField();
	}

	if (IsInDacoity() && !m_bRequireDacoity && m_iDacoityStep >= MAX_DACOITY_STEP) 
	{
		HandleStateDacoity();
	}

// 	// 采集
// 	if (!m_bCollide)
// 	{
// 		map_gather_point& mapgp = mgr.m_mapGP;
// 		map_gather_point_it it = mapgp.begin();
// 		for (; it != mapgp.end(); it++)
// 		{
// 			GatherPoint *gp = it->second;
// 			if (doGatherPointCollides(gp))
// 			{
// 				std::string str;
// 				str += NDCommonCString("GatherOrNot"); str += gp->getName(); str += "?";
// 				m_kGatherDlg = new NDUIDialog;
// 				m_kGatherDlg->Initialization();
// 				m_kGatherDlg->SetDelegate(this);
// 				m_kGatherDlg->Show(NDCommonCString("WenXinTip"), str.c_str(), NDCommonCString("Cancel"), NDCommonCString("gather"), NULL);
// 				m_gp = gp;
// 				m_bCollide = true;
// 				break;
// 			}
// 		}
// 	}

	CCPoint pos = GetPosition();
	if (
		(int(m_kTargetPos.x) != 0)
		&& (int(m_kTargetPos.y) != 0)
		&& (int(pos.x-DISPLAY_POS_X_OFFSET) % 32 == 0 ) //@todo.这里硬编码32了，以后修改！
		&& (int(pos.y-DISPLAY_POS_Y_OFFSET) % 32 == 0 ))
	{
		//if (this->GetParent()) 
		//			{
		//				NDLayer* layer = (NDLayer *)this->GetParent();
		//				if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
		//				{
		//					m_movePathIndex = 0;
		//					NDAutoPath::sharedAutoPath()->autoFindPath(m_position, m_targetPos, (NDMapLayer*)layer, m_iSpeed);
		//					m_pointList = NDAutoPath::sharedAutoPath()->getPathPointVetor();
		//					m_targetPos = CCPointZero;
		//				}		
		//			}
		std::vector<CCPoint> vec_pos; vec_pos.push_back(m_kTargetPos);
		this->WalkToPosition(vec_pos, SpriteSpeedStep8, true);
		m_kTargetPos = CCPointZero;
		ResetFocusRole();
	}

	HandleDirectKey();

	updateFlagOfQiZhi();
}

void NDPlayer::OnMoving(bool bLastPos)
{
	NDManualRole::OnMoving(bLastPos);

	ScriptGlobalEvent::OnEvent (GE_ONMOVE);
}

void NDPlayer::OnMoveBegin()
{
	NDMapLayer* maplayer = M_GetMapLayer();
	if (!maplayer || m_kPointList.size() == 0)
	{
		return;
	}

	CCPoint pos = m_kPointList[m_kPointList.size() - 1];

//@del
// 	int nX = (pos.x - DISPLAY_POS_X_OFFSET) / MAP_UNITSIZE;
// 	int nY = (pos.y - DISPLAY_POS_Y_OFFSET) / MAP_UNITSIZE;
	CCPoint cellPos = ConvertUtil::convertDisplayToCell( pos );
	int nX = (int) cellPos.x;
	int nY = (int) cellPos.y;

	maplayer->ShowRoadSign(true, nX, nY);
}

void NDPlayer::OnMoveEnd()
{
	ScriptGlobalEvent::OnEvent(GE_ONMOVE_END);

	NDMapLayer* pkMaplayer = M_GetMapLayer();
	if (pkMaplayer)
	{
		pkMaplayer->ShowRoadSign(false);
	}

	if (!isTeamLeader() && isTeamMember())
	{
		return;
	}

	SetAction(false);
	NDManualRole::OnMoveEnd();
	if (isTeamLeader())
	{
		teamMemberAction(false);
	}
	//玩家停下来的时候 做聚焦改变处理	npc加载完成后,也做一次聚焦改变处理
	UpdateFocus();

	if (AutoPathTipObj.IsWorking())
	{
		AutoPathTipObj.Arrive();
	}
	processSwitch();
}

void NDPlayer::OnDrawEnd(bool bDraw)
{
	NDManualRole::OnDrawEnd(bDraw);
//	HarvestEventMgrObj.OnTimer(0);
}

void NDPlayer::CaclEquipEffect()
{
	m_eAtkSpd = 0;
	m_eAtk = 0;
	m_eDef = 0;
	m_eHardAtk = 0;
	m_eSkillAtk = 0;
	m_eSkillDef = 0;
	m_eSkillHard = 0;
	m_eDodge = 0;
	m_ePhyHit = 0;

	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (ItemMgrObj.EquipHasNotEffect((Item::eEquip_Pos) i) == true)
		{
			continue;
		}

		Item* pkItem = ItemMgrObj.GetEquipItemByPos((Item::eEquip_Pos) i);
		if (pkItem == NULL)
		{
			continue;
		}

		NDItemType *itemtype = ItemMgrObj.QueryItemType(pkItem->m_nItemType);
		if (itemtype == NULL)
		{
			continue;
		}

		m_eAtkSpd += itemtype->m_data.m_atk_speed + pkItem->getInlayAtk_speed();

		m_eAtk += pkItem->getAdditionResult(itemtype->m_data.m_enhancedId,
				pkItem->m_nAddition, itemtype->m_data.m_atk) + pkItem->getInlayAtk();
		m_eDef += pkItem->getAdditionResult(itemtype->m_data.m_enhancedId,
				pkItem->m_nAddition, itemtype->m_data.m_def) + pkItem->getInlayDef();
		m_eHardAtk += itemtype->m_data.m_hard_hitrate
				+ pkItem->getInlayHard_hitrate();
		m_eSkillAtk += pkItem->getAdditionResult(itemtype->m_data.m_enhancedId,
				pkItem->m_nAddition, itemtype->m_data.m_mag_atk)
				+ pkItem->getInlayMag_atk();
		m_eSkillDef += pkItem->getAdditionResult(itemtype->m_data.m_enhancedId,
				pkItem->m_nAddition, itemtype->m_data.m_mag_def)
				+ pkItem->getInlayMag_def();
		m_eSkillHard += itemtype->m_data.m_mana_limit
				+ pkItem->getInlayMana_limit();
		m_eDodge += itemtype->m_data.m_dodge + pkItem->getInlayDodge();
		m_ePhyHit += itemtype->m_data.m_hitrate + pkItem->getInlayHitrate(); // 物理命中
	}
}

void NDPlayer::NextFocusTarget()
{
	if ( isTeamMember() && !isTeamLeader() )
	{
		return;
	}

	if (!this->GetParent() || !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return;
	}

	SetFocusRole(NDMapMgrObj.GetNextTarget(FOCUS_JUDGE_DISTANCE));
}

void NDPlayer::UpdateFocus()
{
	if ( isTeamMember() && !isTeamLeader() )
	{
		return;
	}

	if (!this->GetParent() || !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return;
	}

	SetFocusRole(NDMapMgrObj.GetRoleNearstPlayer(FOCUS_JUDGE_DISTANCE));
}

void NDPlayer::SetFocusRole(NDBaseRole *baserole)
{
	//CSMGameScene* gs = (CSMGameScene*) NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
	/*if (gs) {
	 gs->SetTargetHead(baserole);
	 gs->RefreshQuickInterationBar(baserole);
	 }*/

	if (!baserole)
	{
		ResetFocusRole();
		return;
	}

	if (baserole->IsKindOfClass(RUNTIME_CLASS(NDNpc)))
	{
		ResetFocusRole();
		m_iFocusNpcID = baserole->m_nID;
		baserole->SetFocus(true);
		return;
	}

	if (baserole->IsKindOfClass(RUNTIME_CLASS(NDManualRole)))
	{
		ResetFocusRole();
		m_iFocusManuRoleID = baserole->m_nID;
		NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(m_iFocusManuRoleID);
		if (!otherplayer)
		{
			ResetFocusRole();
		}

		otherplayer->SetFocus(true);
		return;
	}
}

void NDPlayer::UpdateFocusPlayer()
{
	if ( m_iFocusManuRoleID != -1 )
	{
		NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(m_iFocusManuRoleID);
		if ( !otherplayer || otherplayer->m_bClear) SetFocusRole(NULL);
	}
}

void NDPlayer::ResetFocusRole()
{
	if ( m_iFocusManuRoleID != -1 )
	{
		NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(m_iFocusManuRoleID);
		if ( otherplayer ) otherplayer->SetFocus(false);
	}

	m_iFocusManuRoleID = -1;

	if (IsFocusNpcValid()) 
	{
		NDNpc *focusNpc = GetFocusNpc();

		if (focusNpc) focusNpc->SetFocus(false);

		InvalidNPC();
	}
}

void NDPlayer::AddSkill(OBJID idSkill)
{
	BattleMgr& kBattleMgr = BattleMgrObj;
	BattleSkill* pkSkill = kBattleMgr.GetBattleSkill(idSkill);

	if (!pkSkill)
	{
		return;
	}

	if (pkSkill->getType() == SKILL_TYPE_ATTACK)
	{
		this->m_setActSkill.insert(idSkill);
	}
	else if (pkSkill->getType() == SKILL_TYPE_PASSIVE)
	{
		this->m_setPasSkill.insert(idSkill);
	}
}

void NDPlayer::DelSkill(OBJID idSkill)
{
	if (this->m_setActSkill.count(idSkill) > 0)
	{
		this->m_setActSkill.erase(idSkill);
	}
	else
	{
		this->m_setPasSkill.erase(idSkill);
	}
}

SET_BATTLE_SKILL_LIST& NDPlayer::GetSkillList(SKILL_TYPE type)
{
	if (type == SKILL_TYPE_ATTACK)
	{
		return this->m_setActSkill;
	}
	else
	{
		return this->m_setPasSkill;
	}
}

bool NDPlayer::IsBattleSkillLearned(OBJID idSkill)
{
	return this->m_setActSkill.count(idSkill) > 0
			|| this->m_setPasSkill.count(idSkill) > 0;
}

#if 0
bool NDPlayer::doGatherPointCollides(GatherPoint *se)
{
	if ( this->IsInState(USERSTATE_FIGHTING)
	    || this->IsSafeProtected() || this->IsInState(USERSTATE_DEAD) )
		return false;

	if (NDMapMgrObj.GetBattleMonster())
	{
		return false;
	}

	if (!se)
	{
		return false;
	}

	if (!se->isAlive()) {
		return false;
	}

	bool collides = se->isCollides(GetPosition().x, GetPosition().y-8,
									 8, 8);

	if (collides) {
		if (!se->isJustCollided()) { // 防止一直碰到采集点
			se->setJustCollided(true);
			return true;
		}
	} else {
		se->setJustCollided(false);
	}
	return false;
}
#endif 

bool NDPlayer::DirectSwitch(int iSwitchCellX, int iSwitchCellY, int iPassIndex)
{
	if (!CanSwitch(iSwitchCellX, iSwitchCellY))
	{
		return false;
	}

	AutoPathTipObj.Stop();
	this->stopMoving();
	ScriptGlobalEvent::OnEvent(GE_SWITCH, iPassIndex);
	/*
	 NDTransData SEND_DATA;

	 SEND_DATA.WriteShort(_MSG_POSITION);
	 SEND_DATA.WriteInt(m_id);
	 SEND_DATA.WriteShort(iSwitchCellX);
	 SEND_DATA.WriteShort(iSwitchCellY);
	 SEND_DATA.WriteInt(iPassIndex);
	 SEND_DATA.WriteInt(_POSITION_MAPCHANGE);

	 NDDataTransThread::DefaultThread()->GetSocket()->Send(& SEND_DATA);

	 isLoadingMap = true;

	 NDDirector::DefaultDirector()->PushScene(GameSceneLoading::Scene());

	 this->stopMoving();
	 */

	return true;
}

bool NDPlayer::CanSwitch(int iSwitchCellX, int iSwitchCellY)
{
 	int x = (int(this->GetPosition().x) - DISPLAY_POS_X_OFFSET) / MAP_UNITSIZE_X;
 	int y = (int(this->GetPosition().y) - DISPLAY_POS_Y_OFFSET) / MAP_UNITSIZE_Y;
 
 	if (abs(x - iSwitchCellX) <= 3 && abs(y - iSwitchCellY) <= 3)
 	{
 		return true;
 	}
 
 	return false;

	//++Guosen 2012.8.29//在主城地图上确定两点，这两点连线的右侧是切屏区域//两个主城的判定是一样一样的
	#if 0
int iX1 = 2283;
	int iY1 = 372;
	int iX2 = 2596;
	int iY2 = 582;
	//x = k*y+b
	float k = (iX2-iX1)/(iY2-iY1);
	float b = iX1 - iY1 * k;
	//
	int iX = k * (this->GetPosition().y-DISPLAY_POS_Y_OFFSET) + b;
	if ( iX < this->GetPosition().x-DISPLAY_POS_X_OFFSET )
		return true;
	return false;
#endif
}

void NDPlayer::processSwitch()
{
	// 遍历所有切屏点
	CSMGameScene* scene = (CSMGameScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);

	if (!scene) return;

	NDMapLayer *maplayer = NDMapMgrObj.getMapLayerOfScene(scene);

	if (!maplayer) return;

	NDMapData *mapdata = maplayer->GetMapData();

	if (mapdata && mapdata->getSwitchs())
	{
		cocos2d::CCArray	*switchs = mapdata->getSwitchs();

		for (int i = 0; i < (int)switchs->count(); i++)
		{
			NDMapSwitch *mapswitch = (NDMapSwitch *)switchs->objectAtIndex(i);

			if (!mapswitch) continue;
			if (DirectSwitch(mapswitch->getX(), mapswitch->getY(), mapswitch->getPassIndex())) 
				break;
		}
	}
}

bool NDPlayer::isRoleCanMove()
{
	return !IsInState(USERSTATE_BOOTH) && (isTeamLeader() || !isTeamMember())
			&& !m_bLocked;
}

void NDPlayer::OnDialogClose(NDUIDialog* dialog)
{
	m_bCollide = false;
//	m_gp = NULL;
}

void NDPlayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	#if 0
if (m_bCollide && m_gp)
	{
		NDUISynLayer::ShowWithTitle(NDCommonCString("gathering"));
		m_pkTimer->SetTimer(this, 101, 5.0f);
		dialog->SetVisible(false);
	}
#endif
}

void NDPlayer::OnTimer(OBJID tag)
{
	#if 0
if (m_bCollide && m_gp)
	{
		m_pkTimer->KillTimer(this, 101);
		m_gp->sendCollection();
		if (m_kGatherDlg)
		{
			m_kGatherDlg->Close();
		}
	}
#endif
}

void NDPlayer::HandleDirectKey()
{
	NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();

	if (!pkScene || !pkScene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		return;
	}

	if (!this->GetParent()
			|| !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return;
	}

// 	DirectKey* dk = ((GameScene*)scene)->GetDirectKey();
// 	if (!dk)
// 	{
// 		return;
// 	}
// 
// 	dk_vec_pos kPosVector;
// 
// 	if (!dk->GetPosList(vpos)) return;
// 
// 	//dk->ClearPosList();
// 
// 	this->WalkToPosition(kPosVector, SpriteSpeedStep8, true);
}

void NDPlayer::HandleStateDacoity()
{
// 	if (this->IsInState(USERSTATE_FIGHTING)
// 		|| this->IsInState(USERSTATE_DEAD)
// 		|| this->IsInState(USERSTATE_PVE)
// 		|| (isTeamMember() && !isTeamLeader())
// 		|| this->IsInState(USERSTATE_BATTLEFIELD)
// 		)
// 	{
// 		return;
// 	}
// 
// 	NDMapMgr& mapmgr = NDMapMgrObj;
// 
// 	if (!(mapmgr.canPk()))
// 	{
// 		return;
// 	}
// 
// 	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
// 	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
// 	{
// 		return;
// 	}
// 
// 	//与其它玩家碰撞检测
// 	NDManualRole* role = mapmgr.NearestDacoityManualrole(*this, DACOITY_JUDGE_DISTANCE);
// 
// 	if (!role) return;
// 
// 	//发送战斗消息
// 	NDTransData bao(_MSG_BATTLEACT);
// 	bao << (unsigned char)BATTLE_ACT_USER_COLLIDE; // Action值
// 	bao << (unsigned char)0; // btturn
// 	bao << (unsigned char)1; // datacount
// 	bao << int(role->m_nID);
// 	SEND_DATA(bao);
// 
// 	m_bRequireDacoity = true;
// 
// 	m_iDacoityStep = 0;
}

void NDPlayer::HandleStateBattleField()
{
// 	if (!this->IsInState(USERSTATE_BATTLEFIELD) ||
// 		this->IsInState(USERSTATE_BF_WAIT_RELIVE)
// 		) 
// 	{
// 		return;
// 	}
// 
// 	NDMapMgr& mapmgr = NDMapMgrObj;
// 
// 	//		if (!(mapmgr.canPk())) 
// 	//		{
// 	//			return;
// 	//		}
// 
// 	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
// 	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
// 	{
// 		return;
// 	}
// 
// 	//与其它玩家碰撞检测
// 	NDManualRole* role = mapmgr.NearestBattleFieldManualrole(*this, BATTLEFIELD_DISTANCE);
// 
// 	if (!role) return;
// 
// 	//发送战斗消息
// 	NDTransData bao(_MSG_BATTLEACT);
// 	bao << (unsigned char)BATTLE_ACT_USER_COLLIDE; // Action值
// 	bao << (unsigned char)0; // btturn
// 	bao << (unsigned char)1; // datacount
// 	bao << int(role->m_id);
// 	SEND_DATA(bao);
// 
// 	m_bRequireBattleField = true;
// 
// 	m_iBattleFieldStep = 0;
}

void NDPlayer::BattleStart()
{
	m_bRequireDacoity = true;

	m_bRequireBattleField = true;
}

void NDPlayer::BattleEnd(int iResult)
{
	m_bRequireDacoity = false;

	m_bRequireBattleField = false;
}

bool NDPlayer::canUnpackRidePet()
{
	NDMapMgr& mgr = NDMapMgrObj;

	NDMapLayer * maplayer = mgr.getMapLayerOfScene(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));

	if (maplayer && IsInState(USERSTATE_FLY) && mgr.canFly())
	{
		NDMapData *mapdata = maplayer->GetMapData();

		if (!mapdata || !mapdata->getSwitchs() || int(mapdata->getSwitchs()->count()) == 0)
		{
			return true;
		}

		NDMapSwitch* mapswitch = (NDMapSwitch *)mapdata->getSwitchs()->objectAtIndex(0);

		if (!mapswitch) return true;

		// 不能自动寻路到切屏点 todo
// 		CCPoint from = ccp(m_nServerCol*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, m_nServerRow*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET); //@del
// 		CCPoint to = ccp(mapswitch->getX()*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, mapswitch->getY()*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
		CCPoint from = ConvertUtil::convertCellToDisplay( m_nServerCol, m_nServerRow );
		CCPoint to = ConvertUtil::convertCellToDisplay( mapswitch->getX(), mapswitch->getY() );
		return NDAutoPath::sharedAutoPath()->autoFindPath(from, to , maplayer,
			IsInState(USERSTATE_SPEED_UP) ? SpriteSpeedStep8 : SpriteSpeedStep4, false);
	}

	return true;
}

// NPC焦点相关操作
NDNpc* NDPlayer::GetFocusNpc()
{
	if (!IsFocusNpcValid())
	{
		return NULL;
	}

	return NDMapMgrObj.GetNpc(m_iFocusNpcID);
}

int NDPlayer::GetFocusNpcID()
{
	return m_iFocusNpcID;
}

bool NDPlayer::IsFocusNpcValid()
{
	return m_iFocusNpcID != INVALID_FOCUS_NPC_ID;
}

void NDPlayer::InvalidNPC()
{
	m_iFocusNpcID = INVALID_FOCUS_NPC_ID;
}

int NDPlayer::GetCanUseRepute()
{
//		if (honour < expendHonour)
//			return 0;
//			
//		return honour - expendHonour;
	return m_nExpendHonour;
}

//override for debuging sake
void NDPlayer::RunAnimation(bool bDraw)
{
	NDManualRole::RunAnimation(bDraw);
}

void NDPlayer::debugDraw()
{
	NDManualRole::debugDraw();
}

void NDPlayer::InitializationFroLookFace( int lookface, bool bSetLookFace /*= true*/ )
{
	Initialization(lookface,bSetLookFace);
}

NS_NDENGINE_END
