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
#include "GameSceneLoading.h"
#include <sstream>
#include "CPet.h"
#include "SMGameScene.h"
#include "DramaScene.h"

/* 玩家寻路八个方向值,无效的方向值-1
	7  0  4
	 \ | /
	  \|/
   2-------3
	  /|\
	 / | \
	6  1  5
 
 */
 
namespace NDEngine
{

	
	#define UPDATAE_DIFF	(100)
	#define LABLESIZE		(12)
	
	IMPLEMENT_CLASS(NDManualRole, NDBaseRole)
	
	NDManualRole::NDManualRole() :
	state(0)
	{
		aniGroupTransformed = NULL;
		idTransformTo = 0;
		money = 0;								// 银两
		dwLookFace = 0;							// 创建人物的时候有6种外观可供选择外观
		iProfesstion = 0;						//玩家的职业
		synRank = SYNRANK_NONE;				// 帮派级别
		pkPoint = 0;							// pk值
		
		//m_pBattlePetShow = NULL;
		//ridepet = NULL;f
		
		bUpdateDiff = false;
		
		//m_picRing = NDPicturePool::DefaultPool()->AddPicture(RING_IMAGE);
		//CGSize size = m_picRing->GetSize();
		//m_picRing->Cut(CGRectMake(0, 0, size.width, size.height));
		
		teamId = 0;
		
		isSafeProtected = false;
		
		campOutOfTeam = -1;
		
		bClear = false;
		
		m_oldPos = CGPointZero;
		
		serverCol = -1;
		serverRow = -1;
		m_picVendor = NULL;
		m_picBattle = NULL;
		m_picGraveStone = NULL;
		
		levelup = false;
		
		exp = 0;
		restPoint = 0;
		
		bToLastPos = false;
		
		memset(m_lbName, 0, sizeof(m_lbName));
		memset(m_lbSynName, 0, sizeof(m_lbSynName));
		memset(m_lbPeerage, 0, sizeof(m_lbPeerage));
		m_numberOneEffect = NULL;
		
		effectFeedPetAniGroup = NULL;
		effectArmorAniGroup = NULL;
		effectDacoityAniGroup = NULL;
		
		m_posBackup = CGPointZero;
		
		marriageID = 0;
		
		marriageState = _MARRIAGE_MATE_LOGOUT;
		
		m_nPeerage	= 0;
		m_nRank		= 0;
	}
	
	NDManualRole::~NDManualRole()
	{
		ResetShowPet();
		SAFE_DELETE(m_picRing);
		delete m_numberOneEffect;
	}
	
	void NDManualRole::Update(unsigned long ulDiff)
	{
				/***
				* 临时性注释 郭浩
				* begin
				*/
// 		
// 		if (isSafeProtected) 
// 		{
// 			int intervalTime = [NSDate timeIntervalSinceReferenceDate] - beginProtectedTime;
// 			if (intervalTime > BEGIN_PROTECTED_TIME)
// 			{
// 				setSafeProtected(false);
// 			}
// 		}
// 
// 		if (bUpdateDiff)
// 		{
// 			static unsigned long ulCount = 0;
// 			if (ulCount >= 250)
// 			{
// 				ulCount = 0;
// 				bUpdateDiff = false;
// 			}
// 			else 
// 			{
// 				ulCount += ulDiff;
// 				return;
// 			}
// 		}
// 
// 		updateFlagOfQiZhi();
// 
// 		if (!isTeamLeader() && isTeamMember()) 
// 		{
// 			return;
// 		}
// 
// 		if (isTeamLeader() && CheckToLastPos()) 
// 		{
// 			if (m_dequeWalk.empty()) 
// 			{
// 				return;
// 			}
// 
// 			SetTeamToLastPos();
// 			return;
// 		}
// 
// 		if ( !m_moving )
// 		{
// 			if ( m_dequeWalk.size() )
// 			{
// 				std::vector<CGPoint> vec_pos;
// 				deque<int>::iterator it = m_dequeWalk.begin();
// 				CGPoint posCur = GetPosition();
// 
// 				for (; it != m_dequeWalk.end(); it++) 
// 				{
// 					int dir = *it;
// 					//int dir = m_dequeWalk.front();
// 
// 					posCur.x -= DISPLAY_POS_X_OFFSET;
// 					posCur.y -= DISPLAY_POS_Y_OFFSET;
// 
// 					if ( int(posCur.x) % MAP_UNITSIZE != 0 || int(posCur.y) % MAP_UNITSIZE != 0)
// 					{
// 						//continue;
// 						return;
// 					}
// 
// 					int usOldRecordX	= (posCur.x)/MAP_UNITSIZE;
// 					int usOldRecordY	= (posCur.y)/MAP_UNITSIZE;
// 					int usRecordX		= usOldRecordX;
// 					int usRecordY		= usOldRecordY;
// 
// 					if ( !this->GetXYByDir(usOldRecordX, usOldRecordY, dir, usRecordX, usRecordY) )
// 					{
// 						continue;
// 					}
// 
// 
// 					if (it == m_dequeWalk.begin()) 
// 					{
// 						if (IsDirFaceRight(dir))
// 						{
// 							m_faceRight = true;
// 							m_reverse = true;
// 						}
// 						else
// 						{
// 							m_faceRight = false;
// 							m_reverse = false;
// 						}
// 					}
// 
// 					posCur = ccp(usRecordX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, usRecordY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
// 
// 					vec_pos.push_back(posCur);
// 
// 					//m_dequeWalk.pop_front();
// 				}
// 				m_dequeWalk.clear();
// 
// 				if (!vec_pos.empty()) 
// 				{
// 					SetAction(true);
// 					if (isTeamLeader()) 
// 					{
// 						teamMemberAction(true);
// 					}
// 					this->WalkToPosition(vec_pos, SpriteSpeedStep4, false);
// 				}

// 			}
// 			else 
// 			{
// 				SetAction(false);
// 				if (isTeamLeader()) 
// 				{
// 					teamMemberAction(false);
// 				}
// 			}
			/***
			*end
			*/
		}
	}
	
	void NDManualRole::Initialization(int lookface, bool bSetLookFace/*=true*/)
	{
		NDLog("lookface:%d",lookface);
		if (bSetLookFace) 
		{
			NDBaseRole::InitRoleLookFace(lookface);
		}
		
		//this->SetArmorImageWithEquipmentId(11253);
		//this->SetCloakImageWithEquipmentId(11253);
		//test
		/*
		this->SetArmorImageWithEquipmentId(11253);
		this->SetCloakImageWithEquipmentId(11253);
		this->SetFaceImageWithEquipmentId(11253);
		*/
		//this->SetFaceImageWithEquipmentId();
		
		//初始设置
		/*
		if (sex % 2 == SpriteSexMale)
		{
			this->SetCamp(CAMP_TANG);
			//this->SetHairImageWithEquipmentId(10000);
			this->SetExpressionImageWithEquipmentId(10400);
		}
		else 
		{
			this->SetCamp(CAMP_TANG);
			//this->SetHairImageWithEquipmentId(10000);
			this->SetExpressionImageWithEquipmentId(10401);
		}		
		
		*/
		
		//-----Set Hair Image
		/*
		int hairId = m_lookfaceInfo.sex;
		hairId = (hairId - 1) / 2 - 1;
		if (hairId < 0 || hairId > 2) 
		{
			hairId = 0;
		}
		switch (hairId) {
			case 0:
				this->SetHairImageWithEquipmentId(10000);
				break;
			case 1:
				this->SetHairImageWithEquipmentId(10001);
				break;
			case 2:
				this->SetHairImageWithEquipmentId(10002);
				break;
			default:
				break;
		}
		*/
		
		//-----Set ...
		//m_camp = CAMP_NEUTRAL;
		/*
		if (m_lookfaceInfo.hair > 0 ) 
		{
			if (m_lookfaceInfo.hair < 5) {
				this->SetCamp(m_lookfaceInfo.hair);
			}
			else 
			{
				this->SetEquipment((m_lookfaceInfo.hair + 1995) * 10, 0);
			}
		}
		 */
		
		/*
		//-----Set Equipment Weapon
		this->SetEquipment(this->GetEquipmentId(0), 0);
		
		//-----Set Equipment Cap
		this->SetEquipment(this->GetEquipmentId(1), 0);
		
		//-----Set Equipment Armor
		this->SetEquipment(this->GetEquipmentId(2), 0);
		 */
		
		//Load Animation Group
		
		//sex = lookface / 100000000 % 10; // 人物性别，1-男性，2-女性；
		direct = 2;
		
//		if (sex % 2 == SpriteSexMale) 
		int model_id=lookface/1000000;
		//	if (sex % 2 == SpriteSexMale) 

		/***
		* 临时性注释 郭浩
		*/
// 		NSString* aniPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
// 		NDSprite::Initialization([[NSString stringWithFormat:@"%@model_%d.spr",aniPath,model_id] UTF8String] );
		/***
		* end
		*/

//		else 
//			NDSprite::Initialization(MANUELROLE_HUMAN_FEMALE);
		
		m_faceRight = direct == 2;
		
		this->SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
		
		//defaultDeal();
	}
	
	
	void NDManualRole::Walk(CGPoint toPos, SpriteSpeed speed)
	{
		std::vector<CGPoint> vec_pos;
		vec_pos.push_back(toPos);
		this->WalkToPosition(vec_pos, speed, false);
		
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
/***
* 临时性注释 郭浩
* begin
*/

		//if (ridepet)
		//{
		//	ridepet->OnMoving(bLastPos);
		//}

/***
* @end
*/
		
		//if (isTeamLeader()) 
//		{
//			processTeamMemberOnMove(eMoveTypeMoving);
//		}
	}
	
	void NDManualRole::WalkToPosition(const std::vector<CGPoint>& vec_toPos, SpriteSpeed speed, bool moveMap, bool mustArrive/*=false*/)
	{
		if (vec_toPos.empty()) 
		{
			return;
		}
		
		if (this->GetPosition().x > vec_toPos[0].x) 
		{
			m_faceRight = false;		
		}
		else 
		{
			m_faceRight = true;
		}
		
		if (isTeamLeader() || !isTeamMember()) 
		{
			bool ignoreMask = IsInState(USERSTATE_FLY) && NDMapMgrObj.canFly();
			this->MoveToPosition(vec_toPos, IsInState(USERSTATE_SPEED_UP) ? SpriteSpeedStep8 : SpriteSpeedStep4, moveMap, ignoreMask, mustArrive);
			if (isTeamLeader()) 
			{
				if (!m_pointList.empty()) 
				{
					teamMemberWalkToPosition(vec_toPos);
				}
				else
				{
					//teamMemberWalkResetPosition();
					teamMemberStopMoving(true);
				}
			}
		}
		
		if (!m_moving) 
		{
			SetAction(false);
			return;
		}
		
		
		/*if (m_pBattlePetShow) 
		{
			if (vec_toPos[0].y > m_position.y) 
			{
				m_pBattlePetShow->SetOrderState(OrderStateDown);
			}
			else 
			{
				m_pBattlePetShow->SetOrderState(OrderStateUp);
			}
			m_pBattlePetShow->m_faceRight = m_faceRight;
			m_pBattlePetShow->WalkToPosition(vec_toPos[0]);
		}*/
		
		if (ridepet) 
		{
			ridepet->m_faceRight = m_faceRight;
			ridepet->WalkToPosition(vec_toPos[0]);
		}
		
		SetAction(true);
	}
	
	void NDManualRole::processTeamMemberMove(bool bDraw)
	{
		std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				CGPoint posOld = m_oldPos;// ccp(GetPosition().x/16*16+DISPLAY_POS_X_OFFSET, GetPosition().y/16*16+DISPLAY_POS_Y_OFFSET);
				CGPoint posNew = GetPosition();
				//CGPoint tmppos = pos;
				if (int(posOld.x) == 0 && int(posOld.y) == 0) 
				{
					break;
				}
				NDMapMgr& mapmgrobj = NDMapMgrObj;
				bool bArrDraw[eTeamLen]; memset(bArrDraw, 0, sizeof(bArrDraw));
				for (int j = 1; j < eTeamLen; j++) 
				{
					if (info.team[j] != 0) 
					{ // 重连后的队伍信息出现错误 队长重复加
						NDManualRole *mem = mapmgrobj.GetManualRole(info.team[j]);
						if (mem != NULL) 
						{	
							if (!mem->GetParent()) 
							{
								subnode->AddChild(mem);
							}
							
							if (int(posOld.x) == 0 && int(posOld.y) == 0) 
							{
								break;
							}
							
							int mdir = -1;
							
							if (int(posOld.x) != int(posNew.x)) 
							{
								posNew.y = posOld.y;
								if (int(posOld.x) > int(posNew.x)) 
								{
									posNew.x = posNew.x+16;
								}
								else 
								{
									posNew.x = posNew.x-16;
								}
								
								mdir = 0;
							}
							if (int(posOld.y) != int(posNew.y)) 
							{
								posNew.x = posOld.x;
								if (int(posOld.y) > int(posNew.y)) 
								{
									posNew.y = posNew.y+16;
								}
								else 
								{
									posNew.y = posNew.y-16;
								}
								
								mdir = 0;
							}
							
							if (mdir != -1) 
							{
								posOld = mem->GetPosition();
								mem->SetPosition(posNew);
								bArrDraw[j] = true;
							}
							else 
							{
								//NDLog("调和。。。。。");
							}

							
							//CGPoint posMem = mem->GetPosition();
//							CGPoint posOld = posMem;
//							int mdir = -1;
//							if (int(posMem.x) != int(pos.x) ) 
//							{
//								posMem.y = pos.y;
//								if (int(posMem.x) > int(pos.x)) 
//								{
//									posMem.x = pos.x + 16;
//									mdir = 2;
//								} 
//								else 
//								{
//									posMem.x = pos.x - 16;
//									mdir = 3;
//								}
//							} 
//							else if (int(posMem.y) != int(pos.y)) 
//							{
//								posMem.x = pos.x;
//								if (int(posMem.y) > int(pos.y)) 
//								{
//									posMem.y = pos.y + 16;
//									mdir = 0;
//								} 
//								else 
//								{
//									posMem.y = pos.y - 16;
//									mdir = 1;
//								}
//							}
//							
//							if (mdir != -1) 
//							{
//								mem->SetPosition(posMem);
//								if (mem->m_id==4224) 
//								{
//									int a= 0;
//									a++;
//									a++;
//								}
//								//mem->RunAnimation(bDraw);
//								pos.x = posOld.x;
//								pos.y = posOld.y;
//								bArrDraw[j] = true;
//							}
						}
					}
				}
				
				for (int j = eTeamLen-1; j >= 1; j--) 
				{
					if (info.team[j] != 0) //&& bArrDraw[j]) 
					{ // 重连后的队伍信息出现错误 队长重复加
						NDManualRole *mem = mapmgrobj.GetManualRole(info.team[j]);
						if (mem) 
						{
							mem->RunAnimation(bDraw);
						}
					}
				}
				
				break;
			}
		}
	}
	
	// itype=0(begin), =1(moving), =2(end)
	void NDManualRole::processTeamMemberOnMove(int itype)
	{
		std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				NDMapMgr& mapmgrobj = NDMapMgrObj;
				for (int j = 1; j < eTeamLen; j++) 
				{
					if (info.team[j] != 0) 
					{
						NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
						if (role)
						{
							if (itype == eMoveTypeBegin) 
							{
								role->OnMoveBegin();
							}
							else if (itype == eMoveTypeMoving)
							{
								role->OnMoving(false);
							}
							else if (itype == eMoveTypeEnd)
							{
								role->OnMoveEnd();
							}
						}
					}
				}
				break;
			}
		}
	}
	
	void NDManualRole::teamMemberWalkResetPosition()
	{
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
					if (role) 
					{
						role->resetTeamPos();
					}
				}
			}
		}
	}
	
	void NDManualRole::resetTeamPos()
	{
	
	}
	
	void NDManualRole::teamMemberWalkToPosition(const std::vector<CGPoint>& toPos)
	{
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		if (!layer) 
		{
			return;
		}
		
		std::vector<s_team_info> teamlist = NDMapMgrObj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				int iDealCount = 16 / m_iSpeed;
				int iLastTeamMember = 0;
				
				NDMapMgr& mapmgrobj = NDMapMgrObj;
				std::vector<CGPoint> deque_point[eTeamLen];
				if (int(m_pointList.size()) < iDealCount) 
				{
					return;
				}
				//for (std::vector<CGPoint>::iterator it = m_pointList.begin(); it != m_pointList.end(); it++)
//				{
//					deque_point[iLastTeamMember].push_back((*it));
//				}
				deque_point[iLastTeamMember] = m_pointList;
				
				for (int j = 1; j < eTeamLen; j++) 
				{
					if (info.team[j] != 0) 
					{
						NDManualRole* rolelast = mapmgrobj.GetTeamRole(info.team[iLastTeamMember]);
						
						NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
						if (!role || !rolelast) 
						{
							continue;
						}
					
						CGPoint posCur = role->GetPosition();
						CGPoint posLast  = rolelast->GetPosition();
					
						
						role->WalkToPosition(toPos, SpriteSpeedStep4, false);
						role->stopMoving(false);
						if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
						{
							role->SetMoveMap(true);
						}
						
						if (int(deque_point[iLastTeamMember].size()) < iDealCount) 
						{
							break;
						}
						
						NDAutoPath::sharedAutoPath()->autoFindPath(posCur, posLast, layer, m_iSpeed);
						deque_point[j] = NDAutoPath::sharedAutoPath()->getPathPointVetor();
						
						if (deque_point[j].empty()) 
						{
							int iTemp = iDealCount;
							while (iTemp--) 
							{
								deque_point[j].push_back(posLast);
							}
						}
						
						if (int(deque_point[iLastTeamMember].size()) > iDealCount) 
						{
							deque_point[j].insert(deque_point[j].end(), 
												  deque_point[iLastTeamMember].begin(),
												  deque_point[iLastTeamMember].begin()+deque_point[iLastTeamMember].size()-iDealCount
													);
			
						}
						
						iLastTeamMember = j;
						role->SetPointList(deque_point[j]);
					}
				}
			}
		}
	}
	
	void NDManualRole::teamMemberAction(bool bAction)
	{
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
					if (role) 
					{
						role->SetAction(bAction);
					}
				}
			}
		}
	}
	
	void NDManualRole::teamMemberStopMoving(bool bResetPos)
	{
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
					if (!role) 
					{
						continue;
					}
					if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
					{
						((NDPlayer*)role)->stopMoving(bResetPos);
					}
					else 
					{
						role->stopMoving(bResetPos);
					}

				}
			}
		}
	}
	
	void NDManualRole::SetTeamToLastPos()
	{
		if (!isTeamLeader()) 
		{
			return;
		}
	
		if (m_dequeWalk.empty()) 
		{
			return;
		}
		
		std::vector<CGPoint> vec_pos;
		CGPoint posCur;
		if (m_pointList.empty()) 
		{
			posCur = GetPosition();
		}
		else 
		{
			posCur = m_pointList.at(m_pointList.size()-1);
		}

		deque<int>::iterator itdeque = m_dequeWalk.begin();
		for (; itdeque != m_dequeWalk.end(); itdeque++) 
		{
			int dir = *itdeque;
			
			posCur.x -= DISPLAY_POS_X_OFFSET;
			posCur.y -= DISPLAY_POS_Y_OFFSET;
			
			int usRecordX = (posCur.x)/MAP_UNITSIZE;
			int usRecordY = (posCur.y)/MAP_UNITSIZE;
			NDAsssert(dir>=0 && dir<=3);
			switch(dir)
			{
				case 0:
					usRecordY--;
					break;
				case 1:
					usRecordY++;
					break;
				case 2:
					usRecordX--;
					break;
				case 3:
					usRecordX++;
					break;
				default:;
			}
			
			posCur = ccp(usRecordX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, usRecordY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
			
			vec_pos.push_back(posCur);
		}
		
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		int iIndex = 0;
		int iSize = vec_pos.size();
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 0; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
					if (role) 
					{
						if (iIndex < iSize) 
						{
							role->SetPosition(vec_pos[iSize-iIndex-1]);
							iIndex++;
						}
						
						if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
						{
							((NDPlayer*)role)->stopMoving(true);
						}
						else 
						{
							role->stopMoving(true);
						}

					}
				}
			}
		}
		
		m_dequeWalk.clear();
	}
	
	void NDManualRole::teamSetServerDir(int dir)
	{
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
					if (role) 
					{
						role->SetServerDir(dir);
					}
				}
			}
		}
	}
	
	void NDManualRole::teamSetServerPosition(int iCol, int iRow)
	{
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetManualRole(info.team[j]);
					if (role) 
					{
						role->SetServerPositon(iCol, iRow);
					}
				}
			}
		}
	}
	
	void NDManualRole::OnMoveEnd()
	{
		/*if (m_pBattlePetShow) 
		{
			m_pBattlePetShow->OnMoveEnd();
		}*/
		
		if (ridepet) 
		{
			ridepet->OnMoveEnd();
//			this->setStandActionWithRidePet();
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
	
	void NDManualRole::SetAction(bool bMove, bool ignoreFighting/*=false*/)
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
				this->setMoveActionWithRidePet();
			} 
			else
			{// 人物普通移动
				if (isTransformed())
				{
					AnimationListObj.moveAction(TYPE_MANUALROLE, aniGroupTransformed, 1 - m_faceRight);
				}
				else 
				{
					AnimationListObj.moveAction(TYPE_MANUALROLE, this, m_faceRight);
				}
			}
		} 
		else
		{
			if (IsInState(USERSTATE_BOOTH))
			{
				AnimationListObj.sitAction(this);
				return;
			}
			/*if (m_pBattlePetShow)
			{// 溜宠站立
				AnimationListObj.standAction(TYPE_ENEMYROLE, m_pBattlePetShow, m_faceRight);
			}*/
			if (AssuredRidePet() && !isTransformed())
			{// 骑宠站立
				this->setStandActionWithRidePet();
			} else 
			{
				if (isTransformed())
				{
					AnimationListObj.standAction(TYPE_MANUALROLE, aniGroupTransformed, 1 - m_faceRight);
				} 
				else
				{
					AnimationListObj.standAction(TYPE_MANUALROLE, this, m_faceRight);
				}
			}
		}

	}
	
	bool NDManualRole::AssuredRidePet()
	{
		return ridepet != NULL && ridepet->canRide()&& !isTransformed();
	}
	
	void NDManualRole::SetPosition(CGPoint newPosition)
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
		
		int nNewCol = (newPosition.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE;
		int nNewRow = (newPosition.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE;
		int nOldCol = (GetPosition().x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE;
		int nOldRow = (GetPosition().y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE;
		
		if ( nNewCol != nOldCol ||
			nNewRow != nOldRow ) 
		{
			if (nNewCol < nOldCol) 
			{
				m_faceRight = false;
				m_reverse = false;
				
			}
			else if (nNewCol > nOldCol)
			{
				m_faceRight = true;
				m_reverse = true;
			}
		}
		
		serverCol = nNewCol;
		serverRow = nNewRow;
		NDSprite::SetPosition(newPosition);
		
		/*if (m_pBattlePetShow) 
		{			
			m_pBattlePetShow->SetSpriteDir(this->m_faceRight ? 2 : 0);
			
			m_pBattlePetShow->SetPosition(newPosition);
		}*/
		
		if (ridepet) 
		{
			ridepet->SetSpriteDir(!this->m_faceRight ? 2 : 0);
			//if (isTeamLeader() || !isTeamMember()) 
//			{
//				this->setMoveActionWithRidePet();
//			}
			//ridepet->SetPosition(newPosition);
		}
		
		SetAction(true);
	}
	
	void NDManualRole::OnMoveTurning(bool bXTurnigToY, bool bInc)
	{
		if (ridepet) 
		{
			ridepet->OnMoveTurning(bXTurnigToY, bInc);
		}
	}
	
	bool NDManualRole::OnDrawBegin(bool bDraw)
	{
		NDNode *node = this->GetParent();
		
		//if (!node 
//			|| !(node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)) 
//			|| node->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) )
//		{
//			return true;
//		}
		
	
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (  !(scene->IsKindOfClass(RUNTIME_CLASS(GameScene))
			|| scene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene))
			|| scene->IsKindOfClass(RUNTIME_CLASS(DramaScene)) ) ) 
		{
			return true;
		}
		
		if ( !node ) 
		{
			return true;
		}
		
		/*
		if (!this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)) 
			&& !NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)
			&& !(scene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading)))) 
		{
			return false;
		}
		*/
		
		CGPoint pos = GetPosition();
		
		// 摆摊先处理
		if (this->IsInState(USERSTATE_BOOTH)) { // 摆摊不画骑宠
			if (this->m_picVendor) {
				CGSize sizemap;
				if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
				{
					CGSize szVendor = this->m_picVendor->GetSize();
					//把baserole坐标转成屏幕坐标
					NDMapLayer *layer = (NDMapLayer*)node;
					CGPoint screen = layer->GetScreenCenter();
					CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
					m_posScreen = ccpSub(this->GetPosition(), ccpSub(screen, CGPointMake(winSize.width / 2, winSize.height / 2)));
					
					sizemap = layer->GetContentSize();
					this->m_picVendor->DrawInRect(CGRectMake(pos.x-13-8, pos.y-10+320-sizemap.height, szVendor.width, szVendor.height));
				}
			}
			
			DrawRingImage(true);
			return true;
		}
		
		if (IsInGraveStoneState())
		{
			if (!m_picGraveStone)
			{
				m_picGraveStone = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("s124.png"));
			}
			
			if (m_picGraveStone)
			{
				if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
				{
					CGSize sizemap;
					NDMapLayer *layer = (NDMapLayer*)node;
					sizemap = layer->GetContentSize();
					CGSize sizeGraveStone = m_picGraveStone->GetSize();
					CGRect rect = CGRectMake(pos.x-13-8, pos.y-10+320-sizemap.height, sizeGraveStone.width, sizeGraveStone.height);
					m_picGraveStone->DrawInRect(rect);
					
					return false;
				}
			}
		}
		
		HandleEffectDacoity();
		
		// 处理影子
		if (IsInState(USERSTATE_STEALTH)) 
		{
			if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
			{
				SetShadowOffset(0, 10);
				ShowShadow(true);
				HandleShadow(node->GetContentSize());
			}
			return true;
		}
		else 
		{
			SetShadowOffset(ridepet ? -8 : 0, 10);
			ShowShadow(true, ridepet != NULL );
		}

		if (scene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading))) 
		{
			ShowShadow(false);
		}

		if ( node->IsKindOfClass(RUNTIME_CLASS(Battle)) )
		{
			HandleShadow(node->GetContentSize());
			return true;
		}
		
		// 特效数据先更新
		updateBattlePetEffect();
		refreshEquipmentEffectData();
		
		if (effectFeedPetAniGroup)
		{
			if (!effectFeedPetAniGroup->GetParent())
			{
				subnode->AddChild(effectFeedPetAniGroup);
			}
		}
		
		if (effectArmorAniGroup)
		{
			if (!effectArmorAniGroup->GetParent())
			{
				subnode->AddChild(effectArmorAniGroup);
			}
		}
		
		
		NDBaseRole::OnDrawBegin(bDraw);

		
		if (ridepet)
		{
			ridepet->SetPosition(pos);
			
			if (!ridepet->GetParent())
			{
				subnode->AddChild(ridepet);
			}
		}
		
		//画骑宠
		if (AssuredRidePet() && ridepet->iType != TYPE_RIDE_FLY)
		{
			ridepet->RunAnimation(bDraw);
		}
		
		// 人物变形动画
		if (aniGroupTransformed)
		{
			bDraw = !this->IsInState(USERSTATE_STEALTH);
			this->aniGroupTransformed->SetPosition(pos);
			//aniGroupTransformed->SetCurrentAnimation(m_moving ? MONSTER_MAP_MOVE : MONSTER_MAP_STAND, !this->m_faceRight);
//			aniGroupTransformed->SetSpriteDir(this->m_faceRight ? 2 : 0);
			aniGroupTransformed->RunAnimation(bDraw);
		}
		
		//if (m_talkBox && m_talkBox->IsVisibled()) 
		//{
		//	CGPoint scrPos = GetScreenPoint();
		//	scrPos.x -= DISPLAY_POS_X_OFFSET;
		//	scrPos.y -= DISPLAY_POS_Y_OFFSET;
		//	m_talkBox->SetDisPlayPos(ccp(scrPos.x+8, scrPos.y-getGravityY()+30));
		//	m_talkBox->SetVisible(true);
		//}
		
		//if (!this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)) )//&& NDDataPersist::IsGameSettingOn(GS_SHOW_NAME)) 
		{
			ShowNameLabel(bDraw);
		}
		
		
		return !isTransformed();
	}
	
	void NDManualRole::OnDrawEnd(bool bDraw)
	{
		NDNode *node = this->GetParent();
		
		if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			return;
		}
		
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (!this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)) 
			&& !NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)
			&& (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading)))) 
		{
			return;
		}
		
		//画骑宠
		if (AssuredRidePet() && ridepet->iType == TYPE_RIDE_FLY)
		{
			ridepet->RunAnimation(bDraw);
		}
		
		NDBaseRole::OnDrawEnd(bDraw);
		
		if (this->IsInState(USERSTATE_NUM_ONE)) 
		{
			RunNumberOneEffect();
		}
		
		if (this->IsInState(USERSTATE_FIGHTING) && this->m_picBattle) {
			CGSize sizemap;
			if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
			{
				sizemap = node->GetContentSize();
				CGPoint pos = GetPosition();
				pos.x -= DISPLAY_POS_X_OFFSET+8;
				pos.y -= DISPLAY_POS_Y_OFFSET+48;
				CGSize szBattle = this->m_picBattle->GetSize();
				this->m_picBattle->DrawInRect(CGRectMake(pos.x, pos.y+320-sizemap.height, szBattle.width, szBattle.height));
			}
		}
		
		if (effectArmorAniGroup != NULL && effectArmorAniGroup->GetParent() && !isTransformed()) 
		{
			CGPoint pos = GetPosition();
			pos.y += 6-getGravityY()+effectArmorAniGroup->GetHeight();
			effectArmorAniGroup->SetPosition(pos);
			effectArmorAniGroup->RunAnimation(bDraw);
		}
		
		//　画服务端下发的前部光效
		drawServerFrontEffect(bDraw);
	}
	
	void NDManualRole::RunNumberOneEffect()
	{
		if (!m_numberOneEffect) 
		{
			m_numberOneEffect = new NDLightEffect();
			std::string sprFullPath = NDPath::GetAnimationPath();
			sprFullPath.append("effect_106.spr");
			m_numberOneEffect->Initialization(sprFullPath.c_str());
			m_numberOneEffect->SetLightId(0);
		}
		if (m_numberOneEffect) 
		{
			m_numberOneEffect->SetPosition(ccpAdd(GetPosition(), ccp(0, 10)));
			NDNode* parent = this->GetParent();
			if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
			{
				m_numberOneEffect->Run(parent->GetContentSize());
			}
		}
		
	}
	
	void NDManualRole::stopMoving(bool bResetPos/*=true*/, bool bResetTeamPos/*=true*/)
	{
		NDSprite::stopMoving();
		
		if (bResetPos) 
		{
			NDManualRole::SetPosition(ccp(serverCol*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, serverRow*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
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
		
		if ( !bTransform ) NDBaseRole::drawEffects(bDraw);
		
		bool hasServerEffectFlag = IsServerEffectHasQiZhi();
		
		if (!hasServerEffectFlag && effectFlagAniGroup != NULL && effectFlagAniGroup->GetParent()) 
		{
			CGPoint pos = GetPosition();
			int ty = 0;
			if (isTransformed()) {
				ty = pos.y - DISPLAY_POS_Y_OFFSET-aniGroupTransformed->getGravityY() + 46;
			} else {
	
				ty =  pos.y-DISPLAY_POS_Y_OFFSET- getGravityY() + 46;
			}
			int tx = pos.x-DISPLAY_POS_X_OFFSET + 4;
			//if (getFace() == AnimationList.FACE_LEFT) {
			if ( !m_faceRight)
			{
				tx = pos.x-DISPLAY_POS_X_OFFSET + 12;
			}
			
			effectFlagAniGroup->SetSpriteDir(m_faceRight ? 0 : 2);
			effectFlagAniGroup->SetPosition(ccp(tx, ty));
			effectFlagAniGroup->RunAnimation(bDraw);
		}
		
		/*if (effectFeedPetAniGroup != NULL && effectFeedPetAniGroup->GetParent() && m_pBattlePetShow && !bTransform) 
		{
			CGPoint pos = m_pBattlePetShow->GetPosition();
			effectFeedPetAniGroup->SetPosition(ccp(pos.x, pos.y+8));
			effectFeedPetAniGroup->RunAnimation(bDraw);
		}*/
		
		//if (effectArmorAniGroup != NULL && effectArmorAniGroup->GetParent() && !bTransform) 
//		{
//			CGPoint pos = GetPosition();
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
		serverCol = col;
		serverRow = row;
	}
	
	void NDManualRole::SetServerDir(int dir)
	{
		switch (dir) {
			case 0:
				serverRow--;
				break;
			case 1:
				serverRow++;
				break;
			case 2:
				serverCol--;
				break;
			case 3:
				serverCol++;
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
		if (m_dequeWalk.size() == 0)
		{
			bUpdateDiff = true;
		}
		m_dequeWalk.push_back(dir);
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
			this->state |= nState;
		}
		else
		{
			this->state &= ~nState;
		}
		
		AnimationList& al = AnimationListObj;
		if (nState == USERSTATE_BOOTH) 
		{
			if (bSet) {
				al.sitAction(this);
				if (!m_picVendor) {
					m_picVendor = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("vendor.png"));
				}
			} else {
				if (this->m_picVendor) {
					SAFE_DELETE(m_picVendor);
				}
				if (this->ridepet) {
					al.ridePetStandAction(TYPE_MANUALROLE, this, this->m_faceRight);
				} else {
					al.standAction(TYPE_MANUALROLE, this, this->m_faceRight);
				}
			}
		}
		else if (nState == USERSTATE_FIGHTING) 
		{
			if (bSet) {
				if (!m_picBattle) {
					m_picBattle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("battle.png"));
				}
			} else {
				if (this->m_picBattle) {
					SAFE_DELETE(m_picBattle);
				}
			}
		}
	}
	
	void NDManualRole::SetState(int nState)
	{
		this->state = nState;
		if (this->IsInState(USERSTATE_BOOTH)) {
			this->UpdateState(USERSTATE_BOOTH, true);
		} else if (this->IsInState(USERSTATE_DEAD)) {
			// todo 死亡状态，如果是玩家自己要停止正常游戏逻辑
		}else if (this->IsInState(USERSTATE_FIGHTING))
		{
			NDPlayer& player = NDPlayer::defaultHero();
			if (!this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)) && (!this->isTeamMember() || this->teamId != player.teamId)) 
			{
				this->UpdateState(USERSTATE_FIGHTING, true);
			}
		}

	}
	
	bool NDManualRole::IsInState(int iState)
	{
		return this->state & iState;
	}
	
	// 正负状态
	bool NDManualRole::IsInDacoity()
	{
		return IsInState(USERSTATE_BATTLE_POSITIVE) || IsInState(USERSTATE_BATTLE_NEGATIVE);
	}
	
	void NDManualRole::setSafeProtected(bool isSafeProtected)
	{
		this->isSafeProtected = isSafeProtected;
		if (this->isSafeProtected)
		{
			beginProtectedTime = [NSDate timeIntervalSinceReferenceDate];
		}
	}
	
	void NDManualRole::updateFlagOfQiZhi()
	{
		int iid = -1;
		if (IsInState(USERSTATE_CAMP)) 
		{
			iid = getFlagId(GetCamp());
		}
		else if (IsInState(USERSTATE_HU_BIAO))
		{ //跑镖
			iid = getFlagId(CAMP_FOR_ESCORT);
		}
		else if (isTeamLeader()) 
		{
			iid = getFlagId(5);
		}
		
		if (iid != -1) 
		{
			if (effectFlagAniGroup == NULL) 
			{
				/*
				effectFlagAniGroup = new NDSprite;
				effectFlagAniGroup->Initialization(GetAniPath("qizi.spr"));
				effectFlagAniGroup->SetCurrentAnimation(iid, false);
				*/
			} 
		}else 
		{
			if (campOutOfTeam != -1) {
				SetCamp((CAMP_TYPE)campOutOfTeam);
				campOutOfTeam = -1;
			}
			if (effectFlagAniGroup) 
			{
				if (effectFlagAniGroup->GetParent()) 
				{
					effectFlagAniGroup->RemoveFromParent(true);
					effectFlagAniGroup = NULL;
				}
				else 
				{
					delete effectFlagAniGroup;
					effectFlagAniGroup = NULL;
				}
				
			}
		}
	}
	
	void NDManualRole::updateTransform(int idLookface)
	{
		if (idLookface != this->idTransformTo) {
			this->idTransformTo = idLookface;
			if (aniGroupTransformed) {
				aniGroupTransformed->RemoveFromParent(true);
				aniGroupTransformed = NULL;
			}
			
			if (this->idTransformTo != 0) {
				this->aniGroupTransformed = new NDMonster;
				this->aniGroupTransformed->SetNormalAniGroup(idLookface);
				this->subnode->AddChild(aniGroupTransformed);
			}
		}
	}
	
	bool NDManualRole::isTransformed()
	{
		return this->aniGroupTransformed != NULL;
	}
	
	void NDManualRole::playerLevelUp()
	{
		CGPoint pos = GetPosition();
		
		if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer))
			&& this->GetParent() && !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
		{
			pos = ((NDPlayer*)this)->GetBackupPosition();
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
		
		if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
		{
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
		CGPoint pos = GetPosition();
		
		if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer))
			&& this->GetParent() && !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
		{
			pos = ((NDPlayer*)this)->GetBackupPosition();
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
	
	bool  NDManualRole::CheckToLastPos()
	{
		bool bRet = false;
		NDMapMgr& mapmgrobj = NDMapMgrObj;
		std::vector<s_team_info> teamlist = mapmgrobj.GetTeamList();
		std::vector<s_team_info>::iterator it = teamlist.begin();
		
		for (; it != teamlist.end(); it++) 
		{
			s_team_info info = *it;
			if (info.team[0] == m_id) 
			{
				for (int j = 1; j < eTeamLen; j++) 
				{
					NDManualRole* role = mapmgrobj.GetTeamRole(info.team[j]);
					if (role && role->TeamIsToLastPos()) 
					{
						bRet = true;
						role->TeamSetToLastPos(false);
					}
				}
			}
		}
		
		return bRet;
	}
	
	void NDManualRole::ShowNameLabel(bool bDraw)
	{
#define InitNameLable(lable) \
do \
{ \
if (!lable) \
{ \
lable = new NDUILabel; \
lable->Initialization(); \
lable->SetFontSize(LABLESIZE); \
} \
if (!lable->GetParent() && subnode) \
{ \
subnode->AddChild(lable); \
} \
} while (0)

#define DrawLable(lable, bDraw) do { if (bDraw && lable) lable->draw(); }while(0)
		
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (  !(scene->IsKindOfClass(RUNTIME_CLASS(GameScene))
				|| scene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene))
				|| scene->IsKindOfClass(RUNTIME_CLASS(DramaScene)) ) ) 
		{
			return;
		}
		
		bool isEnemy = false;
		std::string names = m_name;
		NDPlayer& player = NDPlayer::defaultHero();
		CGSize sizewin = NDDirector::DefaultDirector()->GetWinSize();
		int iX = GetPosition().x - DISPLAY_POS_X_OFFSET;
		int iY = GetPosition().y;// - DISPLAY_POS_Y_OFFSET;
		if (IsInState(USERSTATE_CAMP)) {
			isEnemy = (GetCamp() != CAMP_NEUTRAL && player.GetCamp() != CAMP_NEUTRAL
					   && player.GetCamp() != GetCamp());
			names += rank;
		}
		
		if (player.IsInState(USERSTATE_BATTLEFIELD) && 
			this->IsInState(USERSTATE_BATTLEFIELD)  && 
			player.camp != this->camp)
		{
			isEnemy = true;
		}
		
		float fScale = NDDirector::DefaultDirector()->GetScaleFactor();
		
		iY = iY - this->getGravityY();// - 5 * fScale;
		
		int iNameW = getStringSizeMutiLine(names.c_str(), LABLESIZE, sizewin).width/2;
		/*
		std::string strPeerage = GetPeerageName(m_nPeerage);
		int iPeerage = 0;
		if (strPeerage != "")
		{
			strPeerage = std::string("[") + strPeerage + std::string("]");
			iPeerage = getStringSizeMutiLine(strPeerage.c_str(), LABLESIZE, sizewin).width;
		}
		
		if (iPeerage > 0)
		{
			iX += iPeerage / 2;
		}
		*/
			
		
		if (!synName.empty()) 
		{
			InitNameLable(m_lbName[0]);InitNameLable(m_lbName[1]);
			InitNameLable(m_lbPeerage[0]);InitNameLable(m_lbPeerage[1]);
			InitNameLable(m_lbSynName[0]);InitNameLable(m_lbSynName[1]);
			
			
			SetLableName(names, iX+8*fScale-iNameW, iY-LABLESIZE*fScale, isEnemy);
			std::stringstream ss; ss << synName << " [" << synRankStr << "]";
			int iSynNameW = getStringSizeMutiLine(ss.str().c_str(), LABLESIZE, sizewin).width/2;
			cocos2d::ccColor4B color = INTCOLORTOCCC4(0xffffff);
			if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
			{
				color = INTCOLORTOCCC4(0x00ff00);
			}
			SetLable(eLabelSynName, iX+8*fScale-iSynNameW, iY-LABLESIZE*fScale*2, ss.str(), INTCOLORTOCCC4(0x00ff00), INTCOLORTOCCC4(0x003300));
			/*
			if (iPeerage > 0)
				SetLable(eLablePeerage, iX+8-iNameW-iPeerage, iY-LABLESIZE, strPeerage, 
						 INTCOLORTOCCC4(GetPeerageColor(m_nPeerage)), INTCOLORTOCCC4(0x003300));
			
			if (iPeerage > 0)
				DrawLable(m_lbPeerage[1], bDraw); DrawLable(m_lbPeerage[0], bDraw);
			*/
			DrawLable(m_lbName[1], bDraw); DrawLable(m_lbName[0], bDraw); 
			DrawLable(m_lbSynName[1], bDraw); DrawLable(m_lbSynName[0], bDraw); 
		} 
		else 
		{
			InitNameLable(m_lbName[0]);InitNameLable(m_lbName[1]);
			InitNameLable(m_lbPeerage[0]);InitNameLable(m_lbPeerage[1]);
			SetLableName(names, iX+8*fScale-iNameW, iY-LABLESIZE*fScale, isEnemy);
			/*
			if (iPeerage >= 0)
				SetLable(eLablePeerage, iX+8-iNameW-iPeerage, iY-LABLESIZE, strPeerage, 
				INTCOLORTOCCC4(GetPeerageColor(m_nPeerage)), INTCOLORTOCCC4(0x003300));
			if (iPeerage > 0)
				DrawLable(m_lbPeerage[1], bDraw); DrawLable(m_lbPeerage[0], bDraw);
			*/
			DrawLable(m_lbName[1], bDraw); DrawLable(m_lbName[0], bDraw);
		}	
			
#undef InitNameLable
#undef DrawLable
	}
	
	void NDManualRole::SetLable(LableType eLableType, int x, int y, std::string text, cocos2d::cocos2d::ccColor4B color1, cocos2d::cocos2d::ccColor4B color2)
	{
		if (!subnode) 
		{
			return;
		}
		
		NDUILabel *lable[2]; memset(lable, 0, sizeof(lable));
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
		
		lable[0]->SetText(text.c_str());
		lable[1]->SetText(text.c_str());
		
		lable[0]->SetFontColor(color1);
		lable[1]->SetFontColor(color2);
		
		CGSize sizemap;
		sizemap = subnode->GetContentSize();
		CGSize sizewin = NDDirector::DefaultDirector()->GetWinSize();
		float fScale = NDDirector::DefaultDirector()->GetScaleFactor();
		lable[1]->SetFrameRect(CGRectMake(x+1, y+sizewin.height+1-sizemap.height, sizewin.width, (LABLESIZE+5)*fScale));
		lable[0]->SetFrameRect(CGRectMake(x, y+sizewin.height-sizemap.height, sizewin.width, (LABLESIZE+5)*fScale));
	}
	
	void NDManualRole::SetLableName(std::string text, int x, int y, bool isEnemy)
	{
		if (isEnemy) {
			SetLable(eLableName, x, y, text, INTCOLORTOCCC4(0xFF0000), INTCOLORTOCCC4(0x003300));
		}else {
			/*
			if (pkPoint < 1) {// 白色
				SetLable(eLableName, x, y, text, INTCOLORTOCCC4(0xffffff), INTCOLORTOCCC4(0x003300));
			} else if (pkPoint <= 500) {// 黄色
				SetLable(eLableName, x, y, text, INTCOLORTOCCC4(0xfd7e0d), INTCOLORTOCCC4(0x003300));
			} else if (pkPoint <= 2000) {// 红色
				SetLable(eLableName, x, y, text, INTCOLORTOCCC4(0xe30318), INTCOLORTOCCC4(0x003300));
			} else {// 紫色
				SetLable(eLableName, x, y, text, INTCOLORTOCCC4(0x760387), INTCOLORTOCCC4(0x003300));
			}
			*/
			cocos2d::ccColor4B color = ccc4(255, 255, 255, 255);
			if (this->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
			{
				color	= ccc4(243, 144, 27, 255);
			}
			
			SetLable(eLableName, x, y, text, color, INTCOLORTOCCC4(0x003300));
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
		} else */{
			SafeClearEffect(effectFeedPetAniGroup);
		}
	}
	
	void NDManualRole::refreshEquipmentEffectData()
	{
		if (!isTransformed()) {
		    if (this->m_armorQuality > 8 || this->m_cloakQuality > 8) {
				SafeAddEffect(effectArmorAniGroup, "effect_4001.spr");
		    }
			else 
			{
				SafeClearEffect(effectArmorAniGroup);
			}

		} else {
			SafeClearEffect(effectArmorAniGroup);
		}
	}
	
	void NDManualRole::BackupPositon()
	{
		m_posBackup = GetPosition();
	}
	
	CGPoint NDManualRole::GetBackupPosition()
	{
		return m_posBackup;
	}
	
	void NDManualRole::HandleEffectDacoity()
	{
		if (!subnode) return;
		
		NDPlayer& player = NDPlayer::defaultHero();
		
		if (this == &player) return;
		
		if ( (player.IsInState(USERSTATE_BATTLE_POSITIVE) && this->IsInState(USERSTATE_BATTLE_NEGATIVE)) ||
			 (player.IsInState(USERSTATE_BATTLE_NEGATIVE) && this->IsInState(USERSTATE_BATTLE_POSITIVE))
			 ) 
		{
			SafeAddEffect(effectDacoityAniGroup, "effect_101.spr");
		} 
		else 
		{
			SafeClearEffect(effectDacoityAniGroup);
		}
		
		if (effectDacoityAniGroup)
		{
			if (!effectDacoityAniGroup->GetParent())
			{
				subnode->AddChild(effectDacoityAniGroup);
			}
		}
		
		if (effectDacoityAniGroup != NULL && effectDacoityAniGroup->GetParent()) 
		{
			effectDacoityAniGroup->SetPosition(ccpAdd(GetPosition(), ccp(0,8)));
			effectDacoityAniGroup->RunAnimation(true);
		}
	}
	
	// 判断传入的角色绘制的优先级是否比自己高
	bool NDManualRole::IsHighPriorDrawLvl(NDManualRole* otherRole)
	{
		if (!otherRole) return false;
		
		NDPlayer& player = NDPlayer::defaultHero();
		
		if (otherRole->m_id == player.m_id) return true;
		
		if (player.m_id == m_id) return false;
		
		if (isTeamMember() && player.teamId == teamId) return false;
		
		if (otherRole->isTeamMember() && player.teamId == otherRole->teamId) return true;
		
		return false;
	}
	
	void NDManualRole::SetServerEffect(std::vector<int>& vEffect)
	{
		// 删除原先光效
		for_vec(m_serverEffectBack, std::vector<ServerEffect>::iterator)
		{
			delete (*it).effect;
		}
		
		for_vec(m_serverEffectFront, std::vector<ServerEffect>::iterator)
		{
			delete (*it).effect;
		}
		
		m_serverEffectBack.clear();
		
		m_serverEffectFront.clear();
		
		// 设置新光效
		for_vec(vEffect, std::vector<int>::iterator)
		{
			ServerEffect serverEffect;
			
			int effectId = *it;
			
			serverEffect.severEffectId = effectId;
			
			std::string sprFullPath = NDPath::GetAnimationPath();
			
			if (effectId / 1000 % 10 == 9)
			{ // 旗子
				serverEffect.bQiZhi = true;
				sprFullPath.append("qizi.spr");
			}
			else
			{	
				// 低四位为光效id
				std::stringstream ss; 
				ss << "effect_" << effectId % 10000 << ".spr";
				sprFullPath.append(ss.str());
			}
			
			NDLightEffect *effect = new NDLightEffect();
			effect->Initialization(sprFullPath.c_str());
			effect->SetLightId(0);
			serverEffect.effect = effect;
			
			if (effectId / 100000 % 10 == 0)
			{ // 背后光效
				m_serverEffectBack.push_back(serverEffect);
			}
			else
			{ // 前面光效
				m_serverEffectFront.push_back(serverEffect);
			}
		}
	}
	
	bool NDManualRole::isEffectTurn(int effectTurn)
	{
		return ( (!m_faceRight && effectTurn == 0) ||
				 (m_faceRight && effectTurn != 0) 
				);
	}
	
	void NDManualRole::drawServerEffect(std::vector<ServerEffect>& vEffect, bool draw)
	{
		NDNode* parent = this->GetParent();
		if (!parent || !parent->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
		{
			return;
		}
		
		CGSize parentSize = parent->GetContentSize();
		
		for_vec(vEffect, std::vector<ServerEffect>::iterator)
		{
			ServerEffect& serverEffect = *it;
			
			float ty = 0;
			float tx = m_position.x-4;
			
			if (serverEffect.bQiZhi)
			{
				if (isTransformed())
				{
					ty = m_position.y - DISPLAY_POS_Y_OFFSET-aniGroupTransformed->getGravityY() + 46;
				}
				else
				{
					ty = m_position.y - DISPLAY_POS_Y_OFFSET- getGravityY() + 46;
				}
				
				if (isEffectTurn(serverEffect.severEffectId / 10000 % 10)) 
				{
					tx = tx + 10;
				}
			}
			else
			{
				tx = m_position.x+(m_faceRight ? 0 : 2);
				//ty = m_position.y + 8;// + (ridepet ? -8 : 0);
				
				bool gravity = (serverEffect.severEffectId / 1000000 % 10) == 1;
				
				ty = m_position.y - DISPLAY_POS_Y_OFFSET- (gravity ? getGravityY() : 0) + 46+32;
			}
			
			if (serverEffect.effect)
			{
				int aniID = serverEffect.bQiZhi ? serverEffect.severEffectId % 1000 : 0;
				bool face = !isEffectTurn(serverEffect.severEffectId / 10000 % 10);  // ０正向, 1~9反向
				
				serverEffect.effect->SetLightId(aniID, face);
				serverEffect.effect->SetPosition(ccp(tx, ty));
				serverEffect.effect->Run(parentSize, draw);
			}
		}
	}
	
	void NDManualRole::drawServerBackEffect(bool draw)
	{
		if (m_serverEffectBack.size())
		{
			drawServerEffect(m_serverEffectBack, draw);
		}
	}
	
	void NDManualRole::drawServerFrontEffect(bool draw)
	{
		if (m_serverEffectFront.size())
		{
			drawServerEffect(m_serverEffectFront, draw);
		}
	}
	
	bool NDManualRole::IsServerEffectHasQiZhi()
	{
		for_vec(m_serverEffectBack, std::vector<ServerEffect>::iterator)
		{
			if ( (*it).bQiZhi )
				return true;
		}
		
		for_vec(m_serverEffectFront, std::vector<ServerEffect>::iterator)
		{
			if ( (*it).bQiZhi )
				return true;
		}
		
		return false;
	}
	
	CGRect NDManualRole::GetFocusRect() override
	{
		int tx = m_position.x-DISPLAY_POS_X_OFFSET-4, ty = 0;
		int w = 24, h = 0;
		
		if (IsInGraveStoneState() && m_picGraveStone)
		{
			CGSize sizeGraveStone = m_picGraveStone->GetSize();
			h = sizeGraveStone.height;
			ty = m_position.y - 16;
			w = sizeGraveStone.width;
			tx -= 4;
		}
		else if (isTransformed())
		{
			h = this->aniGroupTransformed->GetHeight();
			ty = m_position.y - h;
			w = this->aniGroupTransformed->GetWidth();
		}
		else
		{
			h = this->getGravityY();
			ty = m_position.y - h + 22;
			w = this->GetWidth();
		}
		
		return CGRectMake(tx, ty, w, h);
	}
	
	bool NDManualRole::IsInGraveStoneState()
	{
		return this->IsInState(USERSTATE_DEAD) || this->IsInState(USERSTATE_BF_WAIT_RELIVE);
	}
	
	/*const NDBattlePet* NDManualRole::GetShowPet()
	{
		if (m_pBattlePetShow) 
			return m_pBattlePetShow.Pointer();
			
		return NULL;
	}
	
	void NDManualRole::SetShowPet(ShowPetInfo& info)
	{
		NDBattlePet* pet = m_pBattlePetShow.Pointer();
		
		bool recreate = !(info == m_infoShowPet);
		
		m_infoShowPet = info;
		
		if (recreate)
		{
			SAFE_DELETE_NODE(pet);
			
			if (m_infoShowPet.lookface > 0)
			{
				pet = new NDBattlePet();
				pet->Initialization(m_infoShowPet.lookface);
				pet->m_faceRight = !this->m_faceRight;
				pet->SetCurrentAnimation(MONSTER_STAND, !this->m_faceRight);
				pet->SetOwnerID(this->m_id);
				m_pBattlePetShow = pet->QueryLink();
				
				GameScene *scene = GameScene::GetCurGameScene();
				if (!scene) return;
				NDMapLayer* maplayer = NDMapMgrObj.getMapLayerOfScene(scene);
				if (!maplayer) return;
				maplayer->AddChild(pet);
				
			}
		}
		
		if (pet)
		{
			pet->m_id = m_infoShowPet.idPet;
			pet->SetQuality(m_infoShowPet.quality);
		}
		
		ResetShowPetPosition();
	}*/
	
	bool NDManualRole::GetShowPetInfo(ShowPetInfo& info)
	{
		info = m_infoShowPet;
		return true;
	}
	
	void NDManualRole::ResetShowPetPosition()
	{
		/*if (!m_pBattlePetShow) 
			return;
			
		m_pBattlePetShow->SetPosition(this->GetPosition());*/
	}
	
	void NDManualRole::ResetShowPet()
	{
		ShowPetInfo emptyShowPetInfo;
		SetShowPet(emptyShowPetInfo);
	}
	
	std::string NDManualRole::GetPeerageName(int nPeerage)
	{
		if (nPeerage < 0 || nPeerage > 11)
			return "";
			
		std::stringstream ss;
		ss << "Peerage" << nPeerage;

		//NDString strKey;
//		strKey.Format("Peerage%d", nPeerage);
		//const char* pStr = NDCommonCString(strKey.getData());
		const char* pStr = NDCommonCString(ss.str().c_str());
		if (pStr) {
			return pStr;
		}
		return "";
	}
	
	unsigned int NDManualRole::GetPeerageColor(int nPeerage)
	{
		unsigned int unClr = 0xffffff;
		switch (nPeerage) {
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
		if ( !(abs(oldX - newX) <= 1 && abs(oldY - newY) <= 1) )
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
		
		switch (dir) {
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
				newY = oldY + 1 ;
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
}

