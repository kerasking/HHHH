//
//  NDManualRole.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-17.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDManualRole.h"
#include "NDPath.h"
#include "NDConstant.h"
#include "CCPointExtension.h"
#include "AnimationList.h"
#include "EnumDef.h"
#include "NDPicture.h"
#include "NDMapLayer.h"
#include "NDMapMgr.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "NDAutoPath.h"
#include "NDUtility.h"
#include "GameScene.h"
//#include "NDDataPersist.h"
#include "NDUtility.h"
#include "Battle.h"
//#include "GameSceneLoading.h"
#include <sstream>
#include "CPet.h"
#include "SMGameScene.h"
#include "DramaScene.h"
#include "NDDebugOpt.h"
#include "NDSharedPtr.h"
#include "ScriptMgr.h"
#include "ObjectTracker.h"


/* 玩家寻路八个方向值,无效的方向值-1
    7  0  4
	 \ | /
	  \|/
   2-------3
	  /|\
	 / | \
	6  1  5
 
 */

NS_NDENGINE_BGN


#define UPDATAE_DIFF	(100)
#define LABLESIZE		(12)

IMPLEMENT_CLASS(NDManualRole, NDBaseRole)

NDManualRole::NDManualRole() :
m_nState(0)
{
	INC_NDOBJ_RTCLS

	m_pkAniGroupTransformed = NULL;
	m_nIDTransformTo = 0;
	m_nMoney = 0;								// 银两
/*	m_dwLookFace = 0;// 创建人物的时候有6种外观可供选择外观*/
	m_nProfesstion = 0;//玩家的职业
	m_nSynRank = SYNRANK_NONE;// 帮派级别
	m_nPKPoint = 0;	 // pk值

	//m_pBattlePetShow = NULL;
	//ridepet = NULL;

	m_bUpdateDiff = false;

	//m_picRing = NDPicturePool::DefaultPool()->AddPicture(RING_IMAGE);
	//CCSize size = m_picRing->GetSize();
	//m_picRing->Cut(CCRectMake(0, 0, size.width, size.height));

	m_nTeamID = 0;

	m_bIsSafeProtected = false;

	m_nCampOutOfTeam = -1;

	m_bClear = false;

	m_kOldPos = CCPointZero;

	m_nServerCol = -1;
	m_nServerRow = -1;
	m_pkVendorPicture = NULL;
	m_pkBattlePicture = NULL;
	m_pkGraveStonePicture = NULL;

	m_bLevelUp = false;

	m_nExp = 0;
	m_nRestPoint = 0;

	m_bToLastPos = false;

	memset(m_lbName, 0, sizeof(m_lbName));
	memset(m_lbSynName, 0, sizeof(m_lbSynName));
	memset(m_lbPeerage, 0, sizeof(m_lbPeerage));
	m_pkNumberOneEffect = NULL;

	m_pkEffectFeedPetAniGroup = NULL;
	m_pkEffectArmorAniGroup = NULL;
	m_pkEffectDacoityAniGroup = NULL;

	m_kPosBackup = CCPointZero;

	m_nMarriageID = 0;

	m_nMarriageState = _MARRIAGE_MATE_LOGOUT;

	m_nPeerage = 0;
	m_nRank = 0;

	m_nRideStatus	= 0;
	m_nMountType	= 0;
	m_nLookface		= 0;
	m_nQuality = -1;

	m_bShowLabel = true;
}

NDManualRole::~NDManualRole()
{
	DEC_NDOBJ_RTCLS
	ResetShowPet();
	SAFE_DELETE (m_pkRingPic);
	delete m_pkNumberOneEffect;
	RemoveAllSMEffect();
}

void NDManualRole::Update(unsigned long ulDiff)
{
	if (m_bIsSafeProtected) 
	{
		//获取自2001年1月1号零时到当前时间的秒数
		tm timeStrt20010101;
		timeStrt20010101.tm_year = 2001-1900;
		timeStrt20010101.tm_mon = 0;
		timeStrt20010101.tm_mday = 1;
		timeStrt20010101.tm_hour = 0;
		timeStrt20010101.tm_min = 0;
		timeStrt20010101.tm_sec = 0;
		timeStrt20010101.tm_isdst = 0;

		time_t secOf20010101 = mktime(&timeStrt20010101);
		time_t secNow = time(NULL);
		int diff = secNow - secOf20010101;

		int intervalTime = diff - m_nBeginProtectedTime;
		if (intervalTime > BEGIN_PROTECTED_TIME)
		{
			setSafeProtected(false);
		}
	}

	if (m_bUpdateDiff)
	{
		static unsigned long ulCount = 0;
		if (ulCount >= 250)
		{
			ulCount = 0;
			m_bUpdateDiff = false;
		}
		else
		{
			ulCount += ulDiff;
			return;
		}
	}

	updateFlagOfQiZhi();

	if (!isTeamLeader() && isTeamMember())
	{
		return;
	}

	if (isTeamLeader() && CheckToLastPos())
	{
		if (m_kDequeWalk.empty())
		{
			return;
		}

		SetTeamToLastPos();
		return;
	}

	if (!m_bIsMoving)
	{
		if (m_kDequeWalk.size())
		{
			std::vector < CCPoint > vPosition;
			deque<int>::iterator it = m_kDequeWalk.begin();
			CCPoint kCurrentPosition = GetPosition();

			for (; it != m_kDequeWalk.end(); it++)
			{
				int nDir = *it;
				//int dir = m_kDequeWalk.front();

				kCurrentPosition.x -= DISPLAY_POS_X_OFFSET;
				kCurrentPosition.y -= DISPLAY_POS_Y_OFFSET;

				if (int(kCurrentPosition.x) % int(MAP_UNITSIZE_X) != 0
						|| int(kCurrentPosition.y) % int(MAP_UNITSIZE_Y) != 0)
				{
					//continue;
					return;
				}

				int usOldRecordX = (kCurrentPosition.x) / MAP_UNITSIZE_X;
				int usOldRecordY = (kCurrentPosition.y) / MAP_UNITSIZE_Y;
				int usRecordX = usOldRecordX;
				int usRecordY = usOldRecordY;

				if (!GetXYByDir(usOldRecordX, usOldRecordY, nDir, usRecordX,
						usRecordY))
				{
					continue;
				}

				if (it == m_kDequeWalk.begin())
				{
					if (IsDirFaceRight(nDir))
					{
						m_bFaceRight = true;
						m_bReverse = true;
					}
					else
					{
						m_bFaceRight = false;
						m_bReverse = false;
					}
				}
//@del
// 				kCurrentPosition = ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
// 						usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);
				kCurrentPosition = ConvertUtil::convertCellToDisplay( usRecordX, usRecordY );

				vPosition.push_back(kCurrentPosition);

				//m_kDequeWalk.pop_front();
			}
			m_kDequeWalk.clear();

			if (!vPosition.empty())
			{
				SetAction(true);
				if (isTeamLeader())
				{
					teamMemberAction(true);
				}
				WalkToPosition(vPosition, SpriteSpeedStep4, false);
			}
		}
		else
		{
			SetAction(false);
			if (isTeamLeader())
			{
				teamMemberAction(false);
			}
		}
	}
}

void NDManualRole::Initialization(int lookface, bool bSetLookFace/*=true*/)
{
	NDLog("lookface:%d", lookface);

	//根据lookface获取人物图像
	int nModelID = lookface % 1000;

	//@del
	//CCStringRef pstrAniPath = new CCString(NDPath::GetAnimationPath().c_str());
	//CCStringRef pString = CCString::stringWithFormat("%smodel_%d.spr", pstrAniPath->getCString(), nModelID);
	//NDSprite::Initialization( pString->getCString());

	char spriteFile[200] = "";
	sprintf( spriteFile, "%smodel_%d.spr", NDPath::GetAnimationPath().c_str(), nModelID );	
	NDSprite::Initialization( spriteFile );
	
	m_bFaceRight = m_nDirect == 2;
	m_nLookface = lookface;

	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
}

void NDManualRole::ReLoadLookface(int lookface)
{
	int model_id = lookface%1000;///100;//++Guosen2012.6.17

	char aniPath[256];
	_snprintf(aniPath, 256, "%smodel_%d.spr", NDPath::GetAnimationPath().c_str(), model_id);
	this->reloadAni(aniPath);
	this->SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);

	//defaultDeal();
}

void NDManualRole::Walk(CCPoint toPos, SpriteSpeed speed)
{
	//CCLog( "NDManualRole::Walk(%d, %d)\r\n", (int)toPos.x, (int)toPos.y );
	//WriteCon( "NDManualRole::Walk(%d, %d)\r\n", (int)toPos.x, (int)toPos.y );

	std::vector < CCPoint > vec_pos;
	vec_pos.push_back(toPos);
	WalkToPosition(vec_pos, speed, false);

	//if (isTeamLeader())
//		{
//			std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
//			std::vector<s_team_info>::iterator it = teamlist.begin();
//			for (; it != teamlist.end(); it++) 
//			{
//				s_team_info info = *it;
//				if (info.team[0] == m_id) 
//				{
//					for (int i = 1; i < eTeamLen; i++) 
//					{
//						NDManualRole *role = NDMapMgrObj.GetTeamRole(info.team[i]);
//						if (role) 
//						{
//							role->Walk(toPos, speed);
//						}
//					}
//					break;
//				}
//			}
//		}
}

void NDManualRole::OnMoving(bool bLastPos)
{
	if (m_pkRidePet)
	{
		m_pkRidePet->OnMoving(bLastPos);
	}

	//if (isTeamLeader())
//	{
//		processTeamMemberOnMove(eMoveTypeMoving);
//	}
}

SpriteSpeed NDManualRole::GetSpeed()
{
	switch(this->m_nAccLevel)
	{
	case 0:
		return SpriteSpeedStep4;
	case 1:
		return SpriteSpeedStep6;
	case 2:
		return SpriteSpeedStep8;
	case 3:
		return SpriteSpeedStep10;
	case 4:
		return SpriteSpeedStep12;
	default:
		return SpriteSpeedStep4;
	}
}

void NDManualRole::WalkToPosition(const std::vector<CCPoint>& kToPosVector,
		SpriteSpeed eSpeed, bool bMoveMap, bool bMustArrive/*=false*/)
{
	if (kToPosVector.empty())
	{
		return;
	}

	if (GetPosition().x > kToPosVector[0].x)
	{
		m_bFaceRight = false;
	}
	else
	{
		m_bFaceRight = true;
	}

	if (isTeamLeader() || !isTeamMember())
	{
		bool bGnoreMask = IsInState(USERSTATE_FLY) /*&& NDMapMgrObj.canFly()*/;
		MoveToPosition(kToPosVector,
				IsInState(USERSTATE_SPEED_UP) ?
						SpriteSpeedStep4 : SpriteSpeedStep8, bMoveMap,
				bGnoreMask, bMustArrive);

		if (isTeamLeader())
		{
			if (!m_kPointList.empty())
			{
				teamMemberWalkToPosition(kToPosVector);
			}
			else
			{
				//teamMemberWalkResetPosition();
				teamMemberStopMoving(true);
			}
		}
	}

	if (!m_bIsMoving)
	{
		SetAction(false);
		return;
	}

// 	if (m_pBattlePetShow)
// 	{
// 		if (vec_toPos[0].y > m_position.y)
// 		{
// 			m_pBattlePetShow->SetOrderState(OrderStateDown);
// 		}
// 		else
// 		{
// 			m_pBattlePetShow->SetOrderState(OrderStateUp);
// 		}
// 		m_pBattlePetShow->m_faceRight = m_faceRight;
// 		m_pBattlePetShow->WalkToPosition(vec_toPos[0]);
// 	}

	if (m_pkRidePet)
	{
		m_pkRidePet->m_bFaceRight = m_bFaceRight;
		m_pkRidePet->WalkToPosition(kToPosVector[0]);
	}

	SetAction(true);
}

void NDManualRole::processTeamMemberMove(bool bDraw)
{
// 	std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_id) 
// 		{
// 			CCPoint posOld = m_oldPos;// ccp(GetPosition().x/16*16+DISPLAY_POS_X_OFFSET, GetPosition().y/16*16+DISPLAY_POS_Y_OFFSET);
// 			CCPoint posNew = GetPosition();
// 			//CCPoint tmppos = pos;
// 			if (int(posOld.x) == 0 && int(posOld.y) == 0) 
// 			{
// 				break;
// 			}
// 			NDMapMgr& mapmgrobj = NDMapMgrObj;
// 			bool bArrDraw[eTeamLen]; memset(bArrDraw, 0, sizeof(bArrDraw));
// 			for (int j = 1; j < eTeamLen; j++) 
// 			{
// 				if (info.team[j] != 0) 
// 				{ // 重连后的队伍信息出现错误 队长重复加
// 					NDManualRole *mem = mapmgrobj.GetManualRole(info.team[j]);
// 					if (mem != NULL) 
// 					{	
// 						if (!mem->GetParent()) 
// 						{
// 							subnode->AddChild(mem);
// 						}
// 
// 						if (int(posOld.x) == 0 && int(posOld.y) == 0) 
// 						{
// 							break;
// 						}
// 
// 						int mdir = -1;
// 
// 						if (int(posOld.x) != int(posNew.x)) 
// 						{
// 							posNew.y = posOld.y;
// 							if (int(posOld.x) > int(posNew.x)) 
// 							{
// 								posNew.x = posNew.x+16;
// 							}
// 							else 
// 							{
// 								posNew.x = posNew.x-16;
// 							}
// 
// 							mdir = 0;
// 						}
// 						if (int(posOld.y) != int(posNew.y)) 
// 						{
// 							posNew.x = posOld.x;
// 							if (int(posOld.y) > int(posNew.y)) 
// 							{
// 								posNew.y = posNew.y+16;
// 							}
// 							else 
// 							{
// 								posNew.y = posNew.y-16;
// 							}
// 
// 							mdir = 0;
// 						}
// 
// 						if (mdir != -1) 
// 						{
// 							posOld = mem->GetPosition();
// 							mem->SetPosition(posNew);
// 							bArrDraw[j] = true;
// 						}
// 						else 
// 						{
// 							//NDLog("调和。。。。。");
// 						}
// 
// 						  //CCPoint posMem = mem->GetPosition();
// //							CCPoint posOld = posMem;
// //							int mdir = -1;
// //							if (int(posMem.x) != int(pos.x) ) 
// //							{
// //								posMem.y = pos.y;
// //								if (int(posMem.x) > int(pos.x)) 
// //								{
// //									posMem.x = pos.x + 16;
// //									mdir = 2;
// //								} 
// //								else 
// //								{
// //									posMem.x = pos.x - 16;
// //									mdir = 3;
// //								}
// //							} 
// //							else if (int(posMem.y) != int(pos.y)) 
// //							{
// //								posMem.x = pos.x;
// //								if (int(posMem.y) > int(pos.y)) 
// //								{
// //									posMem.y = pos.y + 16;
// //									mdir = 0;
// //								} 
// //								else 
// //								{
// //									posMem.y = pos.y - 16;
// //									mdir = 1;
// //								}
// //							}
// //							
// //							if (mdir != -1) 
// //							{
// //								mem->SetPosition(posMem);
// //								if (mem->m_id==4224) 
// //								{
// //									int a= 0;
// //									a++;
// //									a++;
// //								}
// //								//mem->RunAnimation(bDraw);
// //								pos.x = posOld.x;
// //								pos.y = posOld.y;
// //								bArrDraw[j] = true;
// //							}
// 
// 						}
// 					}
// 				}
// 				
// 				for (int j = eTeamLen-1; j >= 1; j--) 
// 				{
// 					if (info.team[j] != 0) //&& bArrDraw[j]) 
// 					{ // 重连后的队伍信息出现错误 队长重复加
// 						NDManualRole *mem = mapmgrobj.GetManualRole(info.team[j]);
// 						if (mem) 
// 						{
// 							mem->RunAnimation(bDraw);
// 						}
// 					}
// 				}
// 				
// 				break;
// 			}
// 		}
}

// itype=0(begin), =1(moving), =2(end)
void NDManualRole::processTeamMemberOnMove(int itype)
{
// 		std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
// 		std::vector<s_team_info>::iterator it = teamlist.begin();
// 		for (; it != teamlist.end(); it++) 
// 		{
// 			s_team_info info = *it;
// 			if (info.team[0] == m_nID) 
// 			{
// 				NDMapMgr& mapmgrobj = NDMapMgrObj;
// 				for (int j = 1; j < eTeamLen; j++) 
// 				{
// 					if (info.team[j] != 0) 
// 					{
// 						NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
// 						if (role)
// 						{
// 							if (itype == eMoveTypeBegin) 
// 							{
// 								role->OnMoveBegin();
// 							}
// 							else if (itype == eMoveTypeMoving)
// 							{
// 								role->OnMoving(false);
// 							}
// 							else if (itype == eMoveTypeEnd)
// 							{
// 								role->OnMoveEnd();
// 							}
// 						}
// 					}
// 				}
// 				break;
// 			}
// 		}
}

void NDManualRole::teamMemberWalkResetPosition()
{
//  		NDMapMgr& mapmgrobj = NDMapMgrObj;
// 		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 		std::vector<s_team_info>::iterator it = teamlist.begin();
// 		
// 		for (; it != teamlist.end(); it++) 
// 		{
// 			s_team_info info = *it;
// 			if (info.team[0] == m_nID) 
// 			{
// 				for (int j = 1; j < eTeamLen; j++) 
// 				{
// 					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 					if (role) 
// 					{
// 						role->resetTeamPos();
// 					}
// 				}
// 			}
// 		}
}

void NDManualRole::resetTeamPos()
{

}

void NDManualRole::teamMemberWalkToPosition(const std::vector<CCPoint>& toPos)
{
// 	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 	if (!layer) 
// 	{
// 		return;
// 	}
// 
// 	std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_nID) 
// 		{
// 			int iDealCount = 16 / m_nSpeed;
// 			int iLastTeamMember = 0;
// 
// 			NDMapMgr& mapmgrobj = NDMapMgrObj;
// 			std::vector<CCPoint> deque_point[eTeamLen];
// 			if (int(m_kPointList.size()) < iDealCount) 
// 			{
// 				return;
// 			}
// 			//for (std::vector<CCPoint>::iterator it = m_pointList.begin(); it != m_pointList.end(); it++)
// 			//				{
// 			//					deque_point[iLastTeamMember].push_back((*it));
// 			//				}
// 			deque_point[iLastTeamMember] = m_pointList;
// 
// 			for (int j = 1; j < eTeamLen; j++) 
// 			{
// 				if (info.team[j] != 0) 
// 				{
// 					NDManualRole* rolelast = mapmgrobj.GetTeamRole(info.team[iLastTeamMember]);
// 
// 					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 					if (!role || !rolelast) 
// 					{
// 						continue;
// 					}
// 
// 					CCPoint posCur = role->GetPosition();
// 					CCPoint posLast  = rolelast->GetPosition();
// 
// 
// 					role->WalkToPosition(toPos, SpriteSpeedStep4, false);
// 					role->stopMoving(false);
// 					if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
// 					{
// 						role->SetMoveMap(true);
// 					}
// 
// 					if (int(deque_point[iLastTeamMember].size()) < iDealCount) 
// 					{
// 						break;
// 					}
// 
// 					NDAutoPath::sharedAutoPath()->autoFindPath(posCur, posLast, layer, m_nSpeed);
// 					deque_point[j] = NDAutoPath::sharedAutoPath()->getPathPointVetor();
// 
// 					if (deque_point[j].empty()) 
// 					{
// 						int iTemp = iDealCount;
// 						while (iTemp--) 
// 						{
// 							deque_point[j].push_back(posLast);
// 						}
// 					}
// 
// 					if (int(deque_point[iLastTeamMember].size()) > iDealCount) 
// 					{
// 						deque_point[j].insert(deque_point[j].end(), 
// 							deque_point[iLastTeamMember].begin(),
// 							deque_point[iLastTeamMember].begin()+deque_point[iLastTeamMember].size()-iDealCount
// 							);
// 
// 					}
// 
// 					iLastTeamMember = j;
// 					role->SetPointList(deque_point[j]);
// 				}
// 			}
// 		}
// 	}
}

void NDManualRole::teamMemberAction(bool bAction)
{
// 	NDMapMgr& mapmgrobj = NDMapMgrObj;
// 	std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_nID) 
// 		{
// 			for (int j = 1; j < eTeamLen; j++) 
// 			{
// 				NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 				if (role) 
// 				{
// 					role->SetAction(bAction);
// 				}
// 			}
// 		}
// 	}
}

void NDManualRole::teamMemberStopMoving(bool bResetPos)
{
// 	NDMapMgr& mapmgrobj = NDMapMgrObj;
// 	std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_nID) 
// 		{
// 			for (int j = 1; j < eTeamLen; j++) 
// 			{
// 				NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 				if (!role) 
// 				{
// 					continue;
// 				}
// 				if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
// 				{
// 					((NDPlayer*)role)->stopMoving(bResetPos);
// 				}
// 				else 
// 				{
// 					role->stopMoving(bResetPos);
// 				}
// 
// 			}
// 		}
// 	}
}

void NDManualRole::SetTeamToLastPos()
{
// 	if (!isTeamLeader())
// 	{
// 		return;
// 	}
// 
// 	if (m_kDequeWalk.empty())
// 	{
// 		return;
// 	}
// 
// 	std::vector < CCPoint > vec_pos;
// 	CCPoint kCurrentPosition;
// 	if (m_kPointList.empty())
// 	{
// 		kCurrentPosition = GetPosition();
// 	}
// 	else
// 	{
// 		kCurrentPosition = m_kPointList.at(m_kPointList.size() - 1);
// 	}
// 
// 	deque<int>::iterator itdeque = m_kDequeWalk.begin();
// 	for (; itdeque != m_kDequeWalk.end(); itdeque++)
// 	{
// 		int dir = *itdeque;
// 
// 		kCurrentPosition.x -= DISPLAY_POS_X_OFFSET;
// 		kCurrentPosition.y -= DISPLAY_POS_Y_OFFSET;
// 
// 		int usRecordX = (kCurrentPosition.x) / MAP_UNITSIZE;
// 		int usRecordY = (kCurrentPosition.y) / MAP_UNITSIZE;
// 		NDAsssert(dir >= 0 && dir <= 3);
// 		switch (dir)
// 		{
// 		case 0:
// 			usRecordY--;
// 			break;
// 		case 1:
// 			usRecordY++;
// 			break;
// 		case 2:
// 			usRecordX--;
// 			break;
// 		case 3:
// 			usRecordX++;
// 			break;
// 		default:
// 			break;
// 		}
// 
// 		kCurrentPosition = ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
// 				usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET);
// 
// 		vec_pos.push_back(kCurrentPosition);
// 	}
// 
// 	NDMapMgr& mapmgrobj = NDMapMgrObj;
// 	std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 
// 	int iIndex = 0;
// 	int iSize = vec_pos.size();
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_nID) 
// 		{
// 			for (int j = 0; j < eTeamLen; j++) 
// 			{
// 				NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 				if (role) 
// 				{
// 					if (iIndex < iSize) 
// 					{
// 						role->SetPosition(vec_pos[iSize-iIndex-1]);
// 						iIndex++;
// 					}
// 
// 					if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
// 					{
// 						((NDPlayer*)role)->stopMoving(true);
// 					}
// 					else 
// 					{
// 						role->stopMoving(true);
// 					}
// 
// 				}
// 			}
// 		}
// 	}
// 
// 	m_kDequeWalk.clear();
}

void NDManualRole::teamSetServerDir(int dir)
{
// 		NDMapMgr& mapmgrobj = NDMapMgrObj;
// 		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 		std::vector<s_team_info>::iterator it = teamlist.begin();
// 		
// 		for (; it != teamlist.end(); it++) 
// 		{
// 			s_team_info info = *it;
// 			if (info.team[0] == m_nID) 
// 			{
// 				for (int j = 1; j < eTeamLen; j++) 
// 				{
// 					NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
// 					if (role) 
// 					{
// 						role->SetServerDir(dir);
// 					}
// 				}
// 			}
// 		}
}

void NDManualRole::teamSetServerPosition(int iCol, int iRow)
{
// 	NDMapMgr& mapmgrobj = NDMapMgrObj;
// 	std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 	std::vector<s_team_info>::iterator it = teamlist.begin();
// 
// 	for (; it != teamlist.end(); it++) 
// 	{
// 		s_team_info info = *it;
// 		if (info.team[0] == m_nID) 
// 		{
// 			for (int j = 1; j < eTeamLen; j++) 
// 			{
// 				NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
// 				if (role) 
// 				{
// 					role->SetServerPositon(iCol, iRow);
// 				}
// 			}
// 		}
// 	}
}

void NDManualRole::OnMoveEnd()
{
	SetCurrentAnimation(MANUELROLE_STAND,m_bReverse);
	m_pkCurrentAnimation->setReverse(m_bReverse);

	/*if (m_pBattlePetShow)
	 {
	 m_pBattlePetShow->OnMoveEnd();
	 }*/

	if (m_pkRidePet)
	{
		m_pkRidePet->OnMoveEnd();
//			setStandActionWithRidePet();
	}

	//if	(isTeamLeader())
//		{
//			processTeamMemberOnMove(eMoveTypeEnd);
//		}
//		else if (isTeamMember()) 
//		{
//			if (m_id ==4224) 
//			{
//				int a=0;
//				a++;
//				a++;
//			}
//			SetAction(false);
//		}
}

void NDManualRole::SetAction(bool bMove, bool bIgnoreFighting/*=false*/)
{
	//int animationIndex = MANUELROLE_STAND;
//		if (bMove) 
//		{
//			if (ridepet) 
//			{
//				switch (ridepet->iType) 
//				{
//					case TYPE_RIDE:// 人物骑在骑宠上移动
//						animationIndex = MANUELROLE_RIDE_PET_MOVE;
//						break;
//					case TYPE_STAND:// 人物站在骑宠上移动
//						animationIndex = MANUELROLE_STAND_PET_MOVE;
//						break;
//					case TYPE_RIDE_BIRD:
//						animationIndex = MANUELROLE_RIDE_BIRD_WALK;
//						break;
//					case TYPE_RIDE_FLY:
//						animationIndex = MANUELROLE_FLY_PET_WALK;
//						break;
//					default:
//						break;
//				}
//			}
//			else 
//			{
//				animationIndex = MANUELROLE_WALK;
//			}
//
//		}
//		else 
//		{
//			if (ridepet) 
//			{
//				switch (ridepet->iType) 
//				{
//					case TYPE_RIDE:// 人物骑在骑宠上移动
//						animationIndex = MANUELROLE_RIDE_PET_STAND;
//						break;
//					case TYPE_STAND:// 人物站在骑宠上移动
//						animationIndex = MANUELROLE_STAND_PET_STAND;
//						break;
//					case TYPE_RIDE_BIRD:
//						animationIndex = MANUELROLE_RIDE_BIRD_STAND;
//						break;
//					case TYPE_RIDE_FLY:
//						animationIndex = MANUELROLE_FLY_PET_STAND;
//						break;
//					default:
//						break;
//				}
//			}
//			else 
//			{
//				animationIndex = MANUELROLE_STAND;
//			}
//		}
//		
//		SetCurrentAnimation(animationIndex, m_faceRight);

	//if (GameScreen.getInstance().getBattle() != null) {
//			return;
//		}

//		if (IsInState(USERSTATE_FIGHTING) && !ignoreFighting) 
//		{
//			return;
//		}

	if (bMove)
	{
		/*if (m_pBattlePetShow)
		 {// 溜宠移动
		 AnimationListObj.moveAction(TYPE_ENEMYROLE, m_pBattlePetShow, m_faceRight);
		 }*/

		if (AssuredRidePet() && !isTransformed())
		{
			//WriteCon( "NDManualRole::SetAction() -- 骑宠移动\r\n" );

			setMoveActionWithRidePet();
		}
		else
		{ 
			//WriteCon( "NDManualRole::SetAction() -- 普通移动\r\n" );

			// 人物普通移动
			if (isTransformed())
			{
				AnimationListObj.moveAction(TYPE_MANUALROLE,
					m_pkAniGroupTransformed, 1 - m_bFaceRight);
			}
			else
			{
				AnimationListObj.moveAction(TYPE_MANUALROLE, this, m_bFaceRight);
			}
		}
	}
	else
	{
		if (IsInState(USERSTATE_BOOTH))
		{
			AnimationListObj.sitAction(this,m_bFaceRight);
			return;
		}
// 		if (m_pBattlePetShow)
// 		{// 溜宠站立
// 			AnimationListObj.standAction(TYPE_ENEMYROLE, m_pBattlePetShow, m_bFaceRight);
// 		}

		if (isTransformed())
		{
			AnimationListObj.standAction(TYPE_MANUALROLE, m_pkAniGroupTransformed, 1 - m_bFaceRight);
		} 
		else if (IsInState(USERSTATE_PRACTISE))
		{
			AnimationListObj.sitAction(this, m_bFaceRight);
		}
		else if (AssuredRidePet() && !isTransformed())
		{
			//WriteCon( "NDManualRole::SetAction() -- 骑宠站立\r\n" );

			// 骑宠站立
			this->setStandActionWithRidePet();
		}
		else 
		{
			NDPlayer& player = NDPlayer::defaultHero();
			if (&player == this 
				|| 0 == strcmp( player.m_strName.c_str(), this->m_strName.c_str() )) //hum: no unique id !?
			{
				AnimationListObj.standAction(TYPE_MANUALROLE, this, m_bFaceRight);
			}
			else
			{
				this->standAction(true);
			}
		}
	}
}

bool NDManualRole::AssuredRidePet()
{
	return m_pkRidePet != NULL && m_bIsRide && !isTransformed();
}

void NDManualRole::SetPosition(CCPoint newPosition)
{
	//if (isTeamLeader())
//		{
	//int nNewCol = (newPosition.x-DISPLAY_POS_X_OFFSET)/16;
//			int nNewRow = (newPosition.y-DISPLAY_POS_Y_OFFSET)/16;
//			int nOldCol = (GetPosition().x-DISPLAY_POS_X_OFFSET)/16;
//			int nOldRow = (GetPosition().y-DISPLAY_POS_Y_OFFSET)/16;
//			
//			if ( nNewCol != nOldCol ||
//				nNewRow != nOldRow ) 
//			{
	//m_oldPos = GetPosition();
	//}
	//}

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

	if (nNewCol != nOldCol || nNewRow != nOldRow)
	{
		if (nNewCol < nOldCol)
		{
			m_bFaceRight = false;
			m_bReverse = false;

		}
		else if (nNewCol > nOldCol)
		{
			m_bFaceRight = true;
			m_bReverse = true;
		}
	}

	m_nServerCol = nNewCol;
	m_nServerRow = nNewRow;
	NDSprite::SetPosition(newPosition);

	/*if (m_pBattlePetShow)
	 {
	 m_pBattlePetShow->SetSpriteDir(m_faceRight ? 2 : 0);

	 m_pBattlePetShow->SetPosition(newPosition);
	 }*/

	if (m_pkRidePet)
	{
		m_pkRidePet->SetSpriteDir(!m_bFaceRight ? 2 : 0);
		//if (isTeamLeader() || !isTeamMember())
//			{
//				setMoveActionWithRidePet();
//			}
		//ridepet->SetPosition(newPosition);
	}

	SetAction(true);
}

void NDManualRole::OnMoveTurning(bool bXTurnigToY, bool bInc)
{
	if (m_pkRidePet)
	{
		m_pkRidePet->OnMoveTurning(bXTurnigToY, bInc);
	}
}

bool NDManualRole::OnDrawBegin(bool bDraw)
{
	if (!NDDebugOpt::getDrawRoleManualEnabled())
		return false;

	NDNode* pkParent = GetParent();
	if (!pkParent)
		return true;

	NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!(pkScene->IsKindOfClass(RUNTIME_CLASS(GameScene))
			|| pkScene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene))
			|| pkScene->IsKindOfClass(RUNTIME_CLASS(DramaScene))))
	{
		return true;
	}

	if (pkScene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene)))
	{
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(pkScene);
		if (GetParent() == layer)
		{
			if (!this->IsKindOfClass(RUNTIME_CLASS(NDPlayer))
					&& !NDMapMgrObj.isShowOther)
			{
				return false;
			}
		}
	}
	CCPoint pos = GetPosition();

#if 1
	// 摆摊先处理
	if (IsInState (USERSTATE_BOOTH))
	{
		// 摆摊不画骑宠
		if (m_pkVendorPicture 
			&& pkParent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			CCSize szVendor = m_pkVendorPicture->GetSize();

			//把baserole坐标转成屏幕坐标
			NDMapLayer* pkLayer = (NDMapLayer*) pkParent;
			CCPoint screen = pkLayer->GetScreenCenter();
			CCSize winSize =
				CCDirector::sharedDirector()->getWinSizeInPixels();

			m_kScreenPosition = ccpSub(GetPosition(),
				ccpSub(screen,
				CCPointMake(winSize.width / 2,
				winSize.height / 2)));

			CCSize sizemap = pkLayer->GetContentSize();
			m_pkVendorPicture->DrawInRect(
				CCRectMake(pos.x - 13 - 8,
				pos.y - 10 + 320 - sizemap.height,
				szVendor.width, szVendor.height));
		}

		DrawRingImage(true);
		return true;
	}
#endif 

#if 2
	if (IsInGraveStoneState())
	{
		if (!m_pkGraveStonePicture)
		{
			m_pkGraveStonePicture = NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPath("s124.png"));
		}

		if (m_pkGraveStonePicture
			&& pkParent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			CCSize sizemap;
			NDMapLayer* pkLayer = (NDMapLayer*) pkParent;
			sizemap = pkLayer->GetContentSize();
			CCSize sizeGraveStone = m_pkGraveStonePicture->GetSize();
			CCRect rect = CCRectMake(pos.x - 13 - 8,
				pos.y - 10 + 320 - sizemap.height, sizeGraveStone.width,
				sizeGraveStone.height);

			m_pkGraveStonePicture->DrawInRect(rect);

			return false;
		}
	}
#endif 

#if 3
	HandleEffectDacoity();

	// 处理影子
	if (IsInState (USERSTATE_STEALTH))
	{
		if (IsKindOfClass (RUNTIME_CLASS(NDPlayer)))
		{
			SetShadowOffset(0, 10);
			ShowShadow(true);
			HandleShadow(pkParent->GetContentSize());
		}
		return true;
	}
	else
	{
		SetShadowOffset(m_pkRidePet ? -8 : 0, 10);
		ShowShadow(true, m_pkRidePet != NULL);
	}

	if (pkParent->IsKindOfClass(RUNTIME_CLASS(BattleUILayer)))
	{
		HandleShadow(pkParent->GetContentSize());
		return true;
	}
#endif

#if 4
	// 特效数据先更新
	updateBattlePetEffect();
	refreshEquipmentEffectData();

	if (m_pkEffectFeedPetAniGroup)
	{
		if (!m_pkEffectFeedPetAniGroup->GetParent())
		{
			m_pkSubNode->AddChild(m_pkEffectFeedPetAniGroup);
		}
	}

	if (m_pkEffectArmorAniGroup)
	{
		if (!m_pkEffectArmorAniGroup->GetParent())
		{
			m_pkSubNode->AddChild(m_pkEffectArmorAniGroup);
		}
	}

	NDBaseRole::OnDrawBegin(bDraw);
#endif

#if 5
	if (m_pkRidePet)
	{
		m_pkRidePet->SetPosition(pos);

		if (!m_pkRidePet->GetParent())
		{
			m_pkSubNode->AddChild(m_pkRidePet);
		}
	}

	if (AssuredRidePet())
	{
		m_pkRidePet->SetScale(this->GetScale());
	}

	//画骑宠
	if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
	{
		if (AssuredRidePet())
		{
			bool isSit = BaseScriptMgrObj.excuteLuaFunc<bool>("IsInPractising",
					"PlayerFunc");

			if (!isSit)
			{
				m_pkRidePet->RunAnimation(bDraw);
			}
		}
	}
	else if (AssuredRidePet() && !IsInState(USERSTATE_PRACTISE))
	{
		m_pkRidePet->RunAnimation(bDraw);
	}
#endif

#if 6
	// 人物变形动画
	if (m_pkAniGroupTransformed)
	{
		bDraw = !IsInState(USERSTATE_STEALTH);
		m_pkAniGroupTransformed->SetPosition(pos);
		m_pkAniGroupTransformed->RunAnimation(bDraw);
	}
#endif 

#if 7
	//if (m_talkBox && m_talkBox->IsVisibled())
	//{
	//	CCPoint scrPos = GetScreenPoint();
	//	scrPos.x -= DISPLAY_POS_X_OFFSET;
	//	scrPos.y -= DISPLAY_POS_Y_OFFSET;
	//	m_talkBox->SetDisPlayPos(ccp(scrPos.x+8, scrPos.y-getGravityY()+30));
	//	m_talkBox->SetVisible(true);
	//}
#endif

#if 8
	if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)) || NDMapMgrObj.isShowName)
	{
		DrawNameLabel(bDraw);
	}
#endif 

#if 9
	if (bDraw)
	{
		RunSMEffect (eSM_EFFECT_DRAW_ORDER_BACK);
	}
#endif

	return !isTransformed();
}

void NDManualRole::OnDrawEnd(bool bDraw)
{
	NDNode *node = GetParent();

	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return;
	}

	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();

	/*
	if (!IsKindOfClass(RUNTIME_CLASS(NDPlayer)) 
		&& !NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)
		&& (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading)))) 
	{
		return;
	}
	*/
 		
	//画骑宠
	if (AssuredRidePet() && m_pkRidePet->iType == TYPE_RIDE_FLY)
	{
		m_pkRidePet->RunAnimation(bDraw);
	}


	NDBaseRole::OnDrawEnd(bDraw);

	if (IsInState (USERSTATE_NUM_ONE))
	{
		RunNumberOneEffect();
	}

	if (IsInState(USERSTATE_FIGHTING) && m_pkBattlePicture)
	{
		CCSize sizemap;
		if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			sizemap = node->GetContentSize();
			CCPoint pos = GetPosition();
			pos.x -= DISPLAY_POS_X_OFFSET + 8;
			pos.y -= DISPLAY_POS_Y_OFFSET + 48; //@todo:硬编码了！
			CCSize szBattle = m_pkBattlePicture->GetSize();
			m_pkBattlePicture->DrawInRect(
					CCRectMake(pos.x, pos.y + 320 - sizemap.height,
							szBattle.width, szBattle.height));
		}
	}

	if (m_pkEffectArmorAniGroup != NULL && m_pkEffectArmorAniGroup->GetParent()
			&& !isTransformed())
	{
		CCPoint pos = GetPosition();
		pos.y += 6 - getGravityY() + m_pkEffectArmorAniGroup->GetHeight();
		m_pkEffectArmorAniGroup->SetPosition(pos);
		m_pkEffectArmorAniGroup->RunAnimation(bDraw);
	}

	//　画服务端下发的前部光效
	drawServerFrontEffect(bDraw);
	if (bDraw)
	{
		RunSMEffect(eSM_EFFECT_DRAW_ORDER_FRONT);
	}
}

void NDManualRole::RunNumberOneEffect()
{
	if (!m_pkNumberOneEffect)
	{
		m_pkNumberOneEffect = new NDLightEffect();
		std::string sprFullPath = NDPath::GetAnimationPath();
		sprFullPath.append("effect_106.spr");
		m_pkNumberOneEffect->Initialization(sprFullPath.c_str());
		m_pkNumberOneEffect->SetLightId(0);
	}
	if (m_pkNumberOneEffect)
	{
		m_pkNumberOneEffect->SetPosition(ccpAdd(GetPosition(), ccp(0, 10)));
		NDNode* parent = GetParent();
		if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			m_pkNumberOneEffect->Run(parent->GetContentSize());
		}
	}

}

void NDManualRole::stopMoving(bool bResetPos/*=true*/,
		bool bResetTeamPos/*=true*/)
{
	NDSprite::stopMoving();

	if (bResetPos)
	{
		NDManualRole::SetPosition(
// 				ccp(m_nServerCol * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
// 						m_nServerRow * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));//@del
		ConvertUtil::convertCellToDisplay( m_nServerCol, m_nServerRow ));
	}

	SetAction(false);
	/*
	 if (isTeamLeader() && bResetTeamPos)
	 {
	 teamMemberStopMoving(bResetPos);
	 }
	 */
}

void NDManualRole::drawEffects(bool bDraw)
{
	//if (getFace() == 0) {
	//					effectFlagAniGroup.setCurrent(iid,false);
	//				} else {
	//					effectFlagAniGroup.setCurrent(iid,true);
	//				}
	//				effectFlagAniGroup.refreshData();

	// 服务器下发的背部光效
	drawServerBackEffect(bDraw);

	bool bTransform = isTransformed();

	if (!bTransform)
		NDBaseRole::drawEffects(bDraw);

	bool hasServerEffectFlag = IsServerEffectHasQiZhi();

	if (!hasServerEffectFlag && m_pkEffectFlagAniGroup != NULL
			&& m_pkEffectFlagAniGroup->GetParent())
	{
		CCPoint kPosition = GetPosition();
		int ty = 0;
		if (isTransformed())
		{
			ty = kPosition.y - DISPLAY_POS_Y_OFFSET
					- m_pkAniGroupTransformed->getGravityY() + 46;
		}
		else
		{
			ty = kPosition.y - DISPLAY_POS_Y_OFFSET - getGravityY() + 46; //@todo:日了，这一堆的硬编码！？
		}
		int tx = kPosition.x - DISPLAY_POS_X_OFFSET + 4;
		//if (getFace() == AnimationList.FACE_LEFT) {
		if (!m_bFaceRight)
		{
			tx = kPosition.x - DISPLAY_POS_X_OFFSET + 12;
		}

		m_pkEffectFlagAniGroup->SetSpriteDir(m_bFaceRight ? 0 : 2);
		m_pkEffectFlagAniGroup->SetPosition(ccp(tx, ty));
		m_pkEffectFlagAniGroup->RunAnimation(bDraw);
	}

// 	if (m_pkEffectFeedPetAniGroup != NULL && m_pkEffectFeedPetAniGroup->GetParent() && m_pBattlePetShow && !bTransform)
// 	{
// 		CCPoint pos = m_pBattlePetShow->GetPosition();
// 		m_pkEffectFeedPetAniGroup->SetPosition(ccp(pos.x, pos.y+8));
// 		m_pkEffectFeedPetAniGroup->RunAnimation(bDraw);
// 	}

	//if (effectArmorAniGroup != NULL && effectArmorAniGroup->GetParent() && !bTransform)
//		{
//			CCPoint pos = GetPosition();
//			pos.y += 6-getGravityY()+effectArmorAniGroup->GetHeight();
//			effectArmorAniGroup->SetPosition(pos);
//			effectArmorAniGroup->RunAnimation(bDraw);
//		}
}

void NDManualRole::unpakcAllEquip()
{
	NDBaseRole::unpakcAllEquip();
	m_vEquipsID.clear();
	//SAFE_DELETE_NODE(m_pBattlePetShow);
}

void NDManualRole::SetServerPositon(int col, int row)
{
	m_nServerCol = col;
	m_nServerRow = row;
	SetPosx(col);
	SetPosx(row);
}

void NDManualRole::SetServerDir(int dir)
{
	switch (dir)
	{
	case 0:
		m_nServerRow--;
		break;
	case 1:
		m_nServerRow++;
		break;
	case 2:
		m_nServerCol--;
		break;
	case 3:
		m_nServerCol++;
		break;
	}
}

void NDManualRole::uppackBattlePet()
{
	/*
	 if (m_pBattlePetShow)
	 {
	 if (m_pBattlePetShow->GetParent())
	 {
	 m_pBattlePetShow->RemoveFromParent(true);
	 m_pBattlePetShow = NULL;
	 }
	 else
	 {
	 SAFE_DELETE(m_pBattlePetShow);
	 }
	 }*/
}

//NDBattlePet* NDManualRole::GetBattlePet()
//	{
//		if (m_pBattlePetShow == NULL) 
//		{
//			m_pBattlePetShow = new NDBattlePet;
//		}
//		return m_pBattlePetShow;
//	}

void NDManualRole::AddWalkDir(int dir)
{
	if (m_kDequeWalk.size() == 0)
	{
		m_bUpdateDiff = true;
	}
	m_kDequeWalk.push_back(dir);
}

//NDRidePet* NDManualRole::GetRidePet()
//	{
//		if (ridepet == NULL) 
//		{
//			ridepet = new NDRidePet;
//		}
//		return ridepet;
//	}

void NDManualRole::UpdateState(int nState, bool bSet)
{
	if (bSet)
	{
		m_nState |= nState;
	}
	else
	{
		m_nState &= ~nState;
	}

	AnimationList& al = AnimationListObj;
	if (nState == USERSTATE_BOOTH)
	{
		if (bSet)
		{
			al.sitAction(this, m_bFaceRight);

			if (!m_pkVendorPicture)
			{
				m_pkVendorPicture = NDPicturePool::DefaultPool()->AddPicture(
						NDPath::GetImgPath("vendor.png"));
			}
		}
		else
		{
			if (m_pkVendorPicture)
			{
				SAFE_DELETE (m_pkVendorPicture);
			}

			if (m_pkRidePet)
			{
				al.ridePetStandAction(TYPE_MANUALROLE, this, m_bFaceRight);
			}
			else
			{
				al.standAction(TYPE_MANUALROLE, this, m_bFaceRight);
			}
		}
	}
	else if (nState == USERSTATE_FIGHTING)
	{
		if (bSet)
		{
			if (!m_pkBattlePicture)
			{//--Guosen 2012.11.9//
				//m_pkBattlePicture = NDPicturePool::DefaultPool()->AddPicture(
				//		NDPath::GetImgPath("battle.png"));
			}
		}
		else
		{
			if (m_pkBattlePicture)
			{
				SAFE_DELETE (m_pkBattlePicture);
			}
		}
	}
}

void NDManualRole::SetState(int nState)
{
	bool bOldInPractise	= this->IsInState(USERSTATE_PRACTISE);
	m_nState = nState;

	if (IsInState (USERSTATE_BOOTH))
	{
		UpdateState(USERSTATE_BOOTH, true);
	}
	else if (IsInState (USERSTATE_DEAD))
	{
		// todo 死亡状态，如果是玩家自己要停止正常游戏逻辑
	}
	else if (IsInState (USERSTATE_FIGHTING))
	{
		NDPlayer& player = NDPlayer::defaultHero();

		if (!IsKindOfClass(RUNTIME_CLASS(NDPlayer))
				&& (!isTeamMember() || m_nTeamID != player.m_nTeamID))
		{
			UpdateState(USERSTATE_FIGHTING, true);
		}
	}

	bool bNewInPractise	= IsInState(USERSTATE_PRACTISE);
	if (!bOldInPractise && bNewInPractise)
	{
		AddSMEffect(BaseScriptMgrObj.excuteLuaFunc<std::string>("GetPractiseEffectPath", "PlayerFunc"), 
			eSM_EFFECT_ALIGNMENT_BOTTOM, eSM_EFFECT_DRAW_ORDER_FRONT);
	}
	else if (bOldInPractise && !bNewInPractise)
	{
		RemoveSMEffect(BaseScriptMgrObj.excuteLuaFunc<std::string>("GetPractiseEffectPath", "PlayerFunc"));
	}
}

bool NDManualRole::IsInState(int iState)
{
	return m_nState & iState;
}

// 正负状态
bool NDManualRole::IsInDacoity()
{
	return IsInState(USERSTATE_BATTLE_POSITIVE)
			|| IsInState(USERSTATE_BATTLE_NEGATIVE);
}

void NDManualRole::setSafeProtected(bool isSafeProtected)
{
	m_bIsSafeProtected = isSafeProtected;
	if (m_bIsSafeProtected)
	{
		//获取自2001年1月1号零时到当前时间的秒数
		tm timeStrt20010101;
		timeStrt20010101.tm_year = 2001-1900;
		timeStrt20010101.tm_mon = 0;
		timeStrt20010101.tm_mday = 1;
		timeStrt20010101.tm_hour = 0;
		timeStrt20010101.tm_min = 0;
		timeStrt20010101.tm_sec = 0;
		timeStrt20010101.tm_isdst = 0;

		time_t secOf20010101 = mktime(&timeStrt20010101);
		time_t secNow = time(NULL);
		m_nBeginProtectedTime = secNow - secOf20010101;
	}
}

void NDManualRole::updateFlagOfQiZhi()
{
	int iid = -1;
	if (IsInState (USERSTATE_CAMP))
	{
		iid = getFlagId(GetCamp());
	}
	else if (IsInState (USERSTATE_HU_BIAO))
	{ //跑镖
		iid = getFlagId(CAMP_FOR_ESCORT);
	}
	else if (isTeamLeader())
	{
		iid = getFlagId(5);
	}

	if (iid != -1)
	{
		if (m_pkEffectFlagAniGroup == NULL)
		{
			/*
			 effectFlagAniGroup = new NDSprite;
			 effectFlagAniGroup->Initialization(GetAniPath("qizi.spr"));
			 effectFlagAniGroup->SetCurrentAnimation(iid, false);
			 */
		}
	}
	else
	{
		if (m_nCampOutOfTeam != -1)
		{
			SetCamp((CAMP_TYPE) m_nCampOutOfTeam);
			m_nCampOutOfTeam = -1;
		}
		if (m_pkEffectFlagAniGroup)
		{
			if (m_pkEffectFlagAniGroup->GetParent())
			{
				m_pkEffectFlagAniGroup->RemoveFromParent(true);
				m_pkEffectFlagAniGroup = NULL;
			}
			else
			{
				delete m_pkEffectFlagAniGroup;
				m_pkEffectFlagAniGroup = NULL;
			}

		}
	}
}

void NDManualRole::updateTransform(int idLookface)
{
	if (idLookface != m_nIDTransformTo)
	{
		m_nIDTransformTo = idLookface;

		if (m_pkAniGroupTransformed)
		{
			m_pkAniGroupTransformed->RemoveFromParent(true);
			m_pkAniGroupTransformed = NULL;
		}

		if (m_nIDTransformTo != 0)
		{
			m_pkAniGroupTransformed = new NDMonster;
			m_pkAniGroupTransformed->SetNormalAniGroup(idLookface);
			m_pkSubNode->AddChild(m_pkAniGroupTransformed);
		}
	}
}

bool NDManualRole::isTransformed()
{
	return m_pkAniGroupTransformed != NULL;
}

void NDManualRole::playerLevelUp()
{
	CCPoint pos = GetPosition();

	if (IsKindOfClass(RUNTIME_CLASS(NDPlayer)) && GetParent()
			&& !GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		pos = ((NDPlayer*) this)->GetBackupPosition();
	}

	pos.x -= DISPLAY_POS_X_OFFSET;
	pos.y -= DISPLAY_POS_Y_OFFSET;

	NDSubAniGroupEx group;
	group.anifile = "effect_103.spr";
	group.type = SUB_ANI_TYPE_SELF;
	group.coordW = 8;
	group.coordH = 16;
	group.x = pos.x;
	group.y = pos.y;

	AddSubAniGroup(group);

	if (IsKindOfClass (RUNTIME_CLASS(NDPlayer))){
	NDSubAniGroupEx group;
	group.anifile = "effect_100.spr";
	group.type = SUB_ANI_TYPE_NONE;
	group.coordW = 28;
	group.coordH = 48;
	group.x = pos.x;
	group.y = pos.y;

	AddSubAniGroup(group);
}
}

void NDManualRole::playerMarry()
{
	CCPoint pos = GetPosition();

	if (IsKindOfClass(RUNTIME_CLASS(NDPlayer)) && GetParent()
			&& !GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		pos = ((NDPlayer*) this)->GetBackupPosition();
	}

	pos.x -= DISPLAY_POS_X_OFFSET;
	pos.y -= DISPLAY_POS_Y_OFFSET;

	NDSubAniGroupEx group;
	group.anifile = "effect_505.spr";
	group.type = SUB_ANI_TYPE_SCREEN_CENTER;
	group.coordW = 0;
	group.coordH = 124;
	group.x = pos.x;
	group.y = pos.y;

	AddSubAniGroup(group);
}

bool NDManualRole::CheckToLastPos()
{
		bool bRet = false;
// 		NDMapMgr& mapmgrobj = NDMapMgrObj;
// 		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
// 		std::vector<s_team_info>::iterator it = teamlist.begin();
// 		
// 		for (; it != teamlist.end(); it++) 
// 		{
// 			s_team_info info = *it;
// 			if (info.team[0] == m_nID) 
// 			{
// 				for (int j = 1; j < eTeamLen; j++) 
// 				{
// 					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
// 					if (role && role->TeamIsToLastPos()) 
// 					{
// 						bRet = true;
// 						role->TeamSetToLastPos(false);
// 					}
// 				}
// 			}
// 		}

	return bRet;
}

//@label
void NDManualRole::InitNameLable(NDUILabel*& label)
{
	if (!label) 
	{ 
		label = new NDUILabel; 
		label->Initialization(); 
		label->SetFontSize(LABLESIZE); 
	} 
	if (!label->GetParent() && m_pkSubNode) 
	{ 
		m_pkSubNode->AddChild(label); 
	}
}

//@label
void NDManualRole::DrawLable(NDUILabel* label, bool bDraw)
{ 
	if (bDraw && label) label->draw();
}

//@label
void NDManualRole::DrawNameLabel(bool bDraw)
{
	if (!m_bShowLabel) return;

	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene) return;

	if (!(scene->IsKindOfClass(RUNTIME_CLASS(GameScene))
			|| scene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene))
			|| scene->IsKindOfClass(RUNTIME_CLASS(DramaScene))))
	{
		return;
	}

	bool isEnemy = false;
	std::string names = m_strName;
	NDPlayer& player = NDPlayer::defaultHero();
	CCSize sizewin = CCDirector::sharedDirector()->getWinSizeInPixels();
	int iX = GetPosition().x - DISPLAY_POS_X_OFFSET;
	int iY = GetPosition().y; // - DISPLAY_POS_Y_OFFSET; //@check

	if (IsInState (USERSTATE_CAMP))
	{
		isEnemy = (GetCamp() != CAMP_NEUTRAL && player.GetCamp() != CAMP_NEUTRAL
				&& player.GetCamp() != GetCamp());
		names += m_strRank;
	}

	if (player.IsInState(USERSTATE_BATTLEFIELD)
			&& IsInState(USERSTATE_BATTLEFIELD) && player.m_eCamp != m_eCamp)
	{
		isEnemy = true;
	}

	iY = iY - FIGHTER_HEIGHT;

	int iNameW = getStringSizeMutiLine(names.c_str(), LABLESIZE*FONT_SCALE, sizewin).width/2;
	/*
	 std::string strPeerage = GetPeerageName(m_nPeerage);
	 int iPeerage = 0;
	 if (strPeerage != "")
	 {
	 strPeerage = std::string("[") + strPeerage + std::string("]");
	 iPeerage = getStringSizeMutiLine(strPeerage.c_str(), LABLESIZE*FONT_SCALE, sizewin).width;
	 }

	 if (iPeerage > 0)
	 {
	 iX += iPeerage / 2;
	 }
	 */

	if (!m_strSynName.empty())
	{
		InitNameLable(m_lbName[0]);
		InitNameLable(m_lbName[1]);
		InitNameLable(m_lbPeerage[0]);
		InitNameLable(m_lbPeerage[1]);
		InitNameLable(m_lbSynName[0]);
		InitNameLable(m_lbSynName[1]);

		SetLableName(names, iX + 8 * RESOURCE_SCALE*FONT_SCALE - iNameW, 
								iY - LABLESIZE*FONT_SCALE, isEnemy);

		std::stringstream ss;
		ss << m_strSynName << " [" << m_strSynRank << "]";
		int iSynNameW = getStringSizeMutiLine(ss.str().c_str(), LABLESIZE*FONT_SCALE,
			sizewin).width / 2;

		cocos2d::ccColor4B color = INTCOLORTOCCC4(0xffffff);

		if (IsKindOfClass (RUNTIME_CLASS(NDPlayer)))
		{
			color = INTCOLORTOCCC4(0x00ff00);
		}

		SetLable(eLabelSynName, 
					iX + 8 * RESOURCE_SCALE - iSynNameW,
					iY - LABLESIZE*RESOURCE_SCALE * 2, 
					ss.str(), 
					INTCOLORTOCCC4(0x00ff00),
					INTCOLORTOCCC4(0x003300));

		/*
		if (iPeerage > 0)
		SetLable(eLablePeerage, iX+8-iNameW-iPeerage, iY-LABLESIZE, strPeerage,
		INTCOLORTOCCC4(GetPeerageColor(m_nPeerage)), INTCOLORTOCCC4(0x003300));

		if (iPeerage > 0)
		DrawLable(m_lbPeerage[1], bDraw); DrawLable(m_lbPeerage[0], bDraw);
		*/

		DrawLable(m_lbName[1], bDraw);
		DrawLable(m_lbName[0], bDraw);
		DrawLable(m_lbSynName[1], bDraw);
		DrawLable(m_lbSynName[0], bDraw);
	}
	else
	{
		InitNameLable(m_lbName[0]);
		InitNameLable(m_lbName[1]);
		InitNameLable(m_lbPeerage[0]);
		InitNameLable(m_lbPeerage[1]);
		
		SetLableName(names, 
			iX + 8 * RESOURCE_SCALE - iNameW, 
			iY - LABLESIZE * RESOURCE_SCALE,
			isEnemy);
		/*
		if (iPeerage >= 0)
		SetLable(eLablePeerage, iX+8-iNameW-iPeerage, iY-LABLESIZE, strPeerage,
		INTCOLORTOCCC4(GetPeerageColor(m_nPeerage)), INTCOLORTOCCC4(0x003300));
		if (iPeerage > 0)
		DrawLable(m_lbPeerage[1], bDraw); DrawLable(m_lbPeerage[0], bDraw);
		*/
		DrawLable(m_lbName[1], bDraw);
		DrawLable(m_lbName[0], bDraw);
	}
}

//@label
void NDManualRole::SetLable(LableType eLableType, int x, int y,
		const std::string& in_utf8, cocos2d::ccColor4B color1, cocos2d::ccColor4B color2)
{
	if (!m_pkSubNode)
	{
		return;
	}

	NDUILabel *lable[2] = {0};
	memset(lable, 0, sizeof(lable));
	if (eLableType == eLableName)
	{
		lable[0] = m_lbName[0];
		lable[1] = m_lbName[1];
	}
	else if (eLableType == eLabelSynName)
	{
		lable[0] = m_lbSynName[0];
		lable[1] = m_lbSynName[1];
	}
	else if (eLableType == eLablePeerage)
	{
		lable[0] = m_lbPeerage[0];
		lable[1] = m_lbPeerage[1];
	}

	if (!lable[0] || !lable[1])
	{
		return;
	}

	CCSize fontSize = getStringSize( in_utf8.c_str(), lable[0]->GetFontSize() * FONT_SCALE);
	CCPoint posHead = this->getHeadPos();

	int newX = posHead.x - 0.5 * fontSize.width;
	int newY = posHead.y - 1.0 * fontSize.height;


	#if 0  //人物骑马需要另算坐标 
NDPlayer& player = NDPlayer::defaultHero();
	//判断人物是否在骑马
	if(player.m_nRideStatus == 1)
	{
		newY += 13 * RESOURCE_SCALE;
	}
#endif

	float offset = 1.0f * RESOURCE_SCALE;
	lable[0]->SetFrameRect(CCRectMake(newX, newY, fontSize.width, fontSize.height));//上
	lable[1]->SetFrameRect(CCRectMake(newX + offset, newY + offset, fontSize.width, fontSize.height));//底

// 	if(m_nQuality>-1){
// 		ccColor4B cColor4 = BaseScriptMgrObj.excuteLuaFuncRetColor4("GetColor", "Item",m_nQuality);
// 		lable[0]->SetFontColor(cColor4);
// 		//lable[1]->SetFontColor(cColor4);
// 	}

	lable[0]->SetText(in_utf8.c_str());
	lable[1]->SetText(in_utf8.c_str());

	lable[0]->SetFontColor(color1);
	lable[1]->SetFontColor(color2);
}

void NDManualRole::SetLableName( const std::string& utf8_text, int x, int y, bool isEnemy)
{
	if (isEnemy)
	{
		SetLable(eLableName, x, y, utf8_text, INTCOLORTOCCC4(0xFF0000),
				INTCOLORTOCCC4(0x003300));
	}
	else
	{
		/*
		if (pkPoint < 1) {// 白色
		SetLable(eLableName, x, y, utf8_text, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x003300));
		} else if (pkPoint <= 500) {// 黄色
		SetLable(eLableName, x, y, utf8_text, INTCOLORTOCCC4(0xfd7e0d), INTCOLORTOCCC4(0x003300));
		} else if (pkPoint <= 2000) {// 红色
		SetLable(eLableName, x, y, utf8_text, INTCOLORTOCCC4(0xe30318), INTCOLORTOCCC4(0x003300));
		} else {// 紫色
		SetLable(eLableName, x, y, utf8_text, INTCOLORTOCCC4(0x760387), INTCOLORTOCCC4(0x003300));
		}
		*/

		cocos2d::ccColor4B color = ccc4(255, 255, 255, 255);
		if (IsKindOfClass (RUNTIME_CLASS(NDPlayer)))
		{
			color = ccc4(243, 144, 27, 255);
		}

		SetLable(eLableName, x, y, utf8_text, color, INTCOLORTOCCC4(0x003300));
	}
}

void NDManualRole::updateBattlePetEffect()
{
	/*if (m_pBattlePetShow
	 && m_pBattlePetShow->GetQuality() > 8) {

	 if (IsInState(USERSTATE_FLY) && NDMapMgrObj.canFly())
	 {
	 SafeClearEffect(effectFeedPetAniGroup);
	 }
	 else
	 {
	 SafeAddEffect(effectFeedPetAniGroup, "effect_2001.spr");
	 }
	 } else */
	{
		SafeClearEffect (m_pkEffectFeedPetAniGroup);
	}
}

void NDManualRole::refreshEquipmentEffectData()
{
	if (!isTransformed())
	{
		if (m_nArmorQuality > 8 || m_nCloakQuality > 8)
		{
			SafeAddEffect(m_pkEffectArmorAniGroup, "effect_4001.spr");
		}
		else
		{
			SafeClearEffect (m_pkEffectArmorAniGroup);
		}

	}
	else
	{
		SafeClearEffect (m_pkEffectArmorAniGroup);
	}
}

void NDManualRole::BackupPositon()
{
	m_kPosBackup = GetPosition();
}

CCPoint NDManualRole::GetBackupPosition()
{
	return m_kPosBackup;
}

void NDManualRole::HandleEffectDacoity()
{
	if (!m_pkSubNode)
		return;

	NDPlayer& player = NDPlayer::defaultHero();

	if (this == &player)
		return;

	if ((player.IsInState(USERSTATE_BATTLE_POSITIVE)
			&& IsInState(USERSTATE_BATTLE_NEGATIVE))
			|| (player.IsInState(USERSTATE_BATTLE_NEGATIVE)
					&& IsInState(USERSTATE_BATTLE_POSITIVE)))
	{
		SafeAddEffect(m_pkEffectDacoityAniGroup, "effect_101.spr");
	}
	else
	{
		SafeClearEffect (m_pkEffectDacoityAniGroup);
	}

	if (m_pkEffectDacoityAniGroup)
	{
		if (!m_pkEffectDacoityAniGroup->GetParent())
		{
			m_pkSubNode->AddChild(m_pkEffectDacoityAniGroup);
		}
	}

	if (m_pkEffectDacoityAniGroup != NULL
			&& m_pkEffectDacoityAniGroup->GetParent())
	{
		m_pkEffectDacoityAniGroup->SetPosition(
				ccpAdd(GetPosition(), ccp(0, 8)));
		m_pkEffectDacoityAniGroup->RunAnimation(true);
	}
}

// 判断传入的角色绘制的优先级是否比自己高
bool NDManualRole::IsHighPriorDrawLvl(NDManualRole* otherRole)
{
	if (!otherRole)
	{
		return false;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();

	if (otherRole->m_nID == kPlayer.m_nID)
	{
		return true;
	}

	if (kPlayer.m_nID == m_nID)
	{
		return false;
	}

	if (isTeamMember() && kPlayer.m_nTeamID == m_nTeamID)
	{
		return false;
	}

	if (otherRole->isTeamMember() && kPlayer.m_nTeamID == otherRole->m_nTeamID)
	{
		return true;
	}

	return false;
}

void NDManualRole::SetServerEffect(std::vector<int>& vEffect)
{
	// 删除原先光效
	for_vec(m_kServerEffectBack, std::vector < ServerEffect > ::iterator)
	{
		delete (*it).effect;
	}

	for_vec(m_kServerEffectFront, std::vector < ServerEffect > ::iterator)
	{
		delete (*it).effect;
	}

	m_kServerEffectBack.clear();
	m_kServerEffectFront.clear();

	// 设置新光效
	for_vec(vEffect, std::vector<int>::iterator)
	{
		ServerEffect serverEffect;

		int effectId = *it;

		serverEffect.severEffectId = effectId;

		std::string sprFullPath = NDPath::GetAnimationPath();

// 		if (effectId / 1000 % 10 == 9)
// 		{ // 旗子
// 			serverEffect.bQiZhi = true;
// 			sprFullPath.append("qizi.spr");
// 		}
// 		else
// 		{
// 			// 低四位为光效id
// 			std::stringstream ss;
// 			ss << "effect_" << effectId % 10000 << ".spr";
// 			sprFullPath.append(ss.str());
// 		}

		NDLightEffect* pkEffect = new NDLightEffect();
		pkEffect->Initialization(sprFullPath.c_str());
		pkEffect->SetLightId(0);
		serverEffect.effect = pkEffect;

		if (effectId / 100000 % 10 == 0)
		{ // 背后光效
			m_kServerEffectBack.push_back(serverEffect);
		}
		else
		{ // 前面光效
			m_kServerEffectFront.push_back(serverEffect);
		}
	}
}

bool NDManualRole::isEffectTurn(int effectTurn)
{
	return ((!m_bFaceRight && effectTurn == 0)
			|| (m_bFaceRight && effectTurn != 0));
}

void NDManualRole::drawServerEffect(std::vector<ServerEffect>& vEffect,
		bool draw)
{
	NDNode* parent = GetParent();
	if (!parent || !parent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return;
	}

	CCSize parentSize = parent->GetContentSize();

	for_vec(vEffect, std::vector < ServerEffect > ::iterator)
	{
		ServerEffect& serverEffect = *it;

		float ty = 0;
		float tx = m_kPosition.x - 4;

		if (serverEffect.bQiZhi)
		{
			if (isTransformed())
			{
				ty = m_kPosition.y - DISPLAY_POS_Y_OFFSET
						- m_pkAniGroupTransformed->getGravityY() + 46;
			}
			else
			{
				ty = m_kPosition.y - DISPLAY_POS_Y_OFFSET - getGravityY() + 46;
			}

			if (isEffectTurn(serverEffect.severEffectId / 10000 % 10))
			{
				tx = tx + 10;
			}
		}
		else
		{
			tx = m_kPosition.x + (m_bFaceRight ? 0 : 2);
			//ty = m_position.y + 8;// + (ridepet ? -8 : 0);

			bool gravity = (serverEffect.severEffectId / 1000000 % 10) == 1;

			ty = m_kPosition.y - DISPLAY_POS_Y_OFFSET
					- (gravity ? getGravityY() : 0) + 46 + 32;
		}

		if (serverEffect.effect)
		{
			int aniID =
					serverEffect.bQiZhi ? serverEffect.severEffectId % 1000 : 0;
			bool face = !isEffectTurn(serverEffect.severEffectId / 10000 % 10); // ０正向, 1~9反向

			serverEffect.effect->SetLightId(aniID, face);
			serverEffect.effect->SetPosition(ccp(tx, ty));
			serverEffect.effect->Run(parentSize, draw);
		}
	}
}

void NDManualRole::drawServerBackEffect(bool draw)
{
	if (m_kServerEffectBack.size())
	{
		drawServerEffect(m_kServerEffectBack, draw);
	}
}

void NDManualRole::drawServerFrontEffect(bool draw)
{
	if (m_kServerEffectFront.size())
	{
		drawServerEffect(m_kServerEffectFront, draw);
	}
}

bool NDManualRole::IsServerEffectHasQiZhi()
{
	for_vec(m_kServerEffectBack, std::vector < ServerEffect > ::iterator)
	{
		if ((*it).bQiZhi)
		{
			return true;
		}
	}

	for_vec(m_kServerEffectFront, std::vector < ServerEffect > ::iterator)
	{
		if ((*it).bQiZhi)
		{
			return true;
		}
	}

	return false;
}

CCRect NDManualRole::GetFocusRect()
{
	int tx = m_kPosition.x - DISPLAY_POS_X_OFFSET - 4;
	int ty = 0;
	int w = 24;
	int h = 0;

	if (IsInGraveStoneState() && m_pkGraveStonePicture)
	{
		CCSize sizeGraveStone = m_pkGraveStonePicture->GetSize();
		h = sizeGraveStone.height;
		ty = m_kPosition.y - 16;
		w = sizeGraveStone.width;
		tx -= 4;
	}
	else if (isTransformed())
	{
		h = m_pkAniGroupTransformed->GetHeight();
		ty = m_kPosition.y - h;
		w = m_pkAniGroupTransformed->GetWidth();
	}
	else
	{
		h = getGravityY();
		ty = m_kPosition.y - h + 22;
		w = GetWidth();
	}

	return CCRectMake(tx, ty, w, h);
}

bool NDManualRole::IsInGraveStoneState()
{
	return IsInState(USERSTATE_DEAD) || IsInState(USERSTATE_BF_WAIT_RELIVE);
}

// const NDBattlePet* NDManualRole::GetShowPet()
// {
// // 	if (m_pBattlePetShow)
// // 		return m_pBattlePetShow.Pointer();
// 
// 	return NULL;
// }

void NDManualRole::SetShowPet(ShowPetInfo& info)
{
// 	NDBattlePet* pet = m_pBattlePetShow.Pointer();
// 
// 	bool recreate = !(info == m_infoShowPet);
// 
// 	m_infoShowPet = info;
// 
// 	if (recreate)
// 	{
// 		SAFE_DELETE_NODE(pet);
// 
// 		if (m_infoShowPet.lookface > 0)
// 		{
// 			pet = new NDBattlePet();
// 			pet->Initialization(m_infoShowPet.lookface);
// 			pet->m_faceRight = !m_faceRight;
// 			pet->SetCurrentAnimation(MONSTER_STAND, !m_faceRight);
// 			pet->SetOwnerID(m_id);
// 			m_pBattlePetShow = pet->QueryLink();
// 
// 			GameScene *scene = GameScene::GetCurGameScene();
// 			if (!scene) return;
// 			NDMapLayer* maplayer = NDMapMgrObj.getMapLayerOfScene(scene);
// 			if (!maplayer) return;
// 			maplayer->AddChild(pet);
// 
// 		}
// 	}
// 
// 	if (pet)
// 	{
// 		pet->m_id = m_infoShowPet.idPet;
// 		pet->SetQuality(m_infoShowPet.quality);
// 	}
// 
// 	ResetShowPetPosition();
}

bool NDManualRole::GetShowPetInfo(ShowPetInfo& info)
{
	info = m_kInfoShowPet;
	return true;
}

void NDManualRole::ResetShowPetPosition()
{
	/*if (!m_pBattlePetShow)
	 return;

	 m_pBattlePetShow->SetPosition(GetPosition());*/
}

void NDManualRole::ResetShowPet()
{
	ShowPetInfo emptyShowPetInfo;
	//SetShowPet(emptyShowPetInfo); ///<临时性注释 郭浩
}

std::string NDManualRole::GetPeerageName(int nPeerage)
{
	if (nPeerage < 0 || nPeerage > 11)
	{
		return "";
	}

	std::stringstream ss;
	ss << "Peerage" << nPeerage;

	//NDString strKey;
//		strKey.Format("Peerage%d", nPeerage);
	//const char* pStr = NDCommonCString(strKey.getData());
	string pStr = NDCommonCString(ss.str().c_str());

	if (!pStr.empty())
	{
		return pStr;
	}

	return "";
}

unsigned int NDManualRole::GetPeerageColor(int nPeerage)
{
	unsigned int unClr = 0xffffff;
	switch (nPeerage)
	{
	case 9:
		unClr = 0xe36c0a;
		break;
	case 10:
		unClr = 0x943634;
		break;
	case 11:
		unClr = 0xff0000;
		break;
	default:
		break;
	}

	return unClr;
}

int NDManualRole::GetPathDir(int oldX, int oldY, int newX, int newY)
{
	if (!(abs(oldX - newX) <= 1 && abs(oldY - newY) <= 1))
	{
		return -1;
	}

	if (oldX > newX)
	{
		return oldY > newY ? 7 : (oldY == newY ? 2 : 6);
	}
	else if (oldX < newX)
	{
		return oldY > newY ? 4 : (oldY == newY ? 3 : 5);
	}
	else if (oldX == newX)
	{
		return oldY > newY ? 0 : (oldY == newY ? -1 : 1);
	}

	return -1;
}

bool NDManualRole::GetXYByDir(int oldX, int oldY, int dir, int& newX, int& newY)
{
	if (dir < 0 || dir > 7)
	{
		return false;
	}

	switch (dir)
	{
	case 0:
		newX = oldX;
		newY = oldY - 1;
		break;
	case 1:
		newX = oldX;
		newY = oldY + 1;
		break;
	case 2:
		newX = oldX - 1;
		newY = oldY;
		break;
	case 3:
		newX = oldX + 1;
		newY = oldY;
		break;
	case 4:
		newX = oldX + 1;
		newY = oldY - 1;
		break;
	case 5:
		newX = oldX + 1;
		newY = oldY + 1;
		break;
	case 6:
		newX = oldX - 1;
		newY = oldY + 1;
		break;
	case 7:
		newX = oldX - 1;
		newY = oldY - 1;
		break;
	default:
		break;
	}

	return true;
}

bool NDManualRole::IsDirFaceRight(int nDir)
{
	if (4 == nDir || 3 == nDir || 5 == nDir)
	{
		return true;
	}

	return false;
}

bool NDManualRole::AddSMEffect( const std::string& strEffectPath, int nSMEffectAlignment, int nDrawOrder)
{
	if (eSM_EFFECT_ALIGNMENT_BEGIN > nSMEffectAlignment 
		|| eSM_EFFECT_ALIGNMENT_END <= nSMEffectAlignment
		|| eSM_EFFECT_DRAW_ORDER_BEGIN > nDrawOrder
		|| eSM_EFFECT_DRAW_ORDER_END <= nDrawOrder)
	{
		return false;
	}
	if ("" == strEffectPath)
	{
		return false;
	}
	std::map<std::string, NDLightEffect*>& mapEffect	= m_kArrMapSMEffect[nDrawOrder][nSMEffectAlignment];
	if (mapEffect.find(strEffectPath) != mapEffect.end())
	{
		return false;
	}
	mapEffect[strEffectPath]	= new NDLightEffect();
	mapEffect[strEffectPath]->Initialization(strEffectPath.c_str());
	mapEffect[strEffectPath]->SetLightId(0);
}

bool NDManualRole::RemoveSMEffect( const std::string& strEffectPath)
{
	if ("" == strEffectPath)
	{
		return false;
	}
	bool bFind	= false;
	for (int i = eSM_EFFECT_DRAW_ORDER_BEGIN; i < eSM_EFFECT_DRAW_ORDER_END; i++) 
	{
		for (int j = eSM_EFFECT_ALIGNMENT_BEGIN; j < eSM_EFFECT_ALIGNMENT_END; j++) 
		{
			std::map<std::string, NDLightEffect*>& mapEffect	= m_kArrMapSMEffect[i][j];
			std::map<std::string, NDLightEffect*>::iterator it	= mapEffect.find(strEffectPath);
			if (it != mapEffect.end())
			{
				SAFE_DELETE(it->second);
				mapEffect.erase(it);
				bFind	= true;
			}
		}
	}
	return bFind;
}

void NDManualRole::RemoveAllSMEffect()
{
	for (int i = eSM_EFFECT_DRAW_ORDER_BEGIN; i < eSM_EFFECT_DRAW_ORDER_END; i++) 
	{
		for (int j = eSM_EFFECT_ALIGNMENT_BEGIN; j < eSM_EFFECT_ALIGNMENT_END; j++) 
		{
			std::map<std::string, NDLightEffect*>& mapEffect	= m_kArrMapSMEffect[i][j];
			std::map<std::string, NDLightEffect*>::iterator it	= mapEffect.begin();
			for (; it != mapEffect.end(); it++) 
			{
				SAFE_DELETE(it->second);
			}
			mapEffect.clear();
		}
	}
}

void NDManualRole::RunSMEffect(int nDrawOrder)
{
	if (eSM_EFFECT_DRAW_ORDER_BEGIN > nDrawOrder
		|| eSM_EFFECT_DRAW_ORDER_END <= nDrawOrder)
	{
		return;
	}
	NDNode* pParent = this->GetParent();
	if (!pParent) 
	{
		return;
	}
	NDDirector* director		= NDDirector::DefaultDirector();
	float fScaleFactor			= RESOURCE_SCALE;
	CCSize sizeEffectParent		= pParent->GetContentSize();
	CCPoint posRole				= this->GetPosition();
	for (int j = eSM_EFFECT_ALIGNMENT_BEGIN; j < eSM_EFFECT_ALIGNMENT_END; j++) 
	{
		std::map<std::string, NDLightEffect*>& mapEffect	= m_kArrMapSMEffect[nDrawOrder][j];
		if (mapEffect.empty())
		{
			continue;
		}
		CCPoint posOffect		= CCPointZero;
		if (eSM_EFFECT_ALIGNMENT_TOP == j)
		{
			posOffect			= ccp(0, -FIGHTER_HEIGHT * fScaleFactor);
		}
		else if (eSM_EFFECT_ALIGNMENT_CENTER == j)
		{
			posOffect			= ccp(0, -FIGHTER_HEIGHT * fScaleFactor / 2);
		}
		else if (eSM_EFFECT_ALIGNMENT_BOTTOM == j)
		{
		}
		std::map<std::string, NDLightEffect*>::iterator it	= mapEffect.begin();
		for (; it != mapEffect.end(); it++) 
		{
			NDLightEffect* pEffect	= it->second;
			if (!pEffect)
			{
				continue;
			}
			pEffect->SetPosition(ccpAdd(posRole, posOffect));
			pEffect->Run(sizeEffectParent);
		}
	}
}

/************************************************************************************************************
 Function:         ChangeModelWithMount
 Description:    根据骑乘状态修改人物当前的信息
 Input:   nRideStatus:    骑乘状态  0：步行     1：骑马
              nMountType:    骑乘的类型 
 Output:     无
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 Other:  1. add by tangziqin  2012.7.27   增加函数头注释      
              2.
 ************************************************************************************************************/
bool NDManualRole::ChangeModelWithMount( int nRideStatus, int nMountType )
{
	if  (m_nRideStatus == nRideStatus)
	{
		if (0 == m_nRideStatus)
        {
			return true;
        }
		else if ( m_nMountType == nMountType )
        {
			return true;
        }
	}
	unsigned int nMountLookface	= ScriptDBObj.GetN( "mount_model_config", nMountType, DB_MOUNT_MODEL_LOOKFACE );
	unsigned int nMountID		= nMountLookface%1000;     
	unsigned int nPlayerID		= m_nLookface%1000;
	char aniPath[256];
	if ( nRideStatus == 0 )
	{
		_snprintf(aniPath, 256, "%smodel_%d.spr", NDPath::GetAnimationPath().c_str(), nPlayerID);
	}
	else
	{
		_snprintf(aniPath, 256, "%smodel_%d_%d.spr", NDPath::GetAnimationPath().c_str(), nPlayerID, nMountID);
	}
	reloadAni(aniPath);

	m_nRideStatus	= nRideStatus;
	m_nMountType	= nMountType;
	
	SetCurrentAnimation( MANUELROLE_STAND, m_bFaceRight );
	return true;
}

//override for debug
void NDManualRole::RunAnimation(bool bDraw)
{
	if (!NDDebugOpt::getRunAnimManualEnabled()) return;

	NDBaseRole::RunAnimation(bDraw);
}

void NDManualRole::debugDraw()
{
	NDBaseRole::debugDraw();
}

//in screen pixels.
CCPoint NDManualRole::getFootPos()
{
	CCPoint pos = NDBaseRole::getFootPos();

	if (m_nRideStatus == 1)
	{
		int sign = (m_bFaceRight ? -1 : 1);
		const float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
		pos.x += DISPLAY_POS_X_OFFSET * fScale * sign;
	}

	return pos;
}

//in screen pixels.
CCPoint NDManualRole::getHeadPos()
{
	CCPoint pos = NDBaseRole::getHeadPos();

	if (m_nRideStatus == 1)
	{
		int sign = (m_bFaceRight ? -1 : 1);
		const float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
		pos.x += DISPLAY_POS_X_OFFSET * fScale * sign;
		pos.y -= DISPLAY_POS_Y_OFFSET;
	}

	return pos;
}

NS_NDENGINE_END