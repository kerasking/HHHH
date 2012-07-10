//
//  NDNpc.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDNpc.h"
#import "NDPath.h"
#import "NDMapData.h"
#import "NDMapLayer.h"
#import "NDUILayer.h"
#import "NDDirector.h"
#import "NDConstant.h"
#import "EnumDef.h"
#import "NDRidePet.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#include "GameScene.h"
#include "NDMapLayer.h"
#include "SMGameScene.h"

#include "ScriptGameData.h"
#include "ScriptDataBase.h"
#include "ScriptTask.h"
#include "TableDef.h"
#include "ScriptGameLogic.h"

using namespace NDEngine;

// lable->SetRenderTimes(3);

#define InitNameLable(lable) \
do \
{ \
if (!lable) \
{ \
lable = new NDUILabel; \
lable->Initialization(); \
lable->SetFontSize(12); \
lable->SetRenderTimes(3); \
} \
if (!lable->GetParent() && subnode) \
{ \
subnode->AddChild(lable); \
} \
} while (0)

#define DrawLable(lable, bDraw) do { if (bDraw && lable) lable->draw(); }while(0)


IMPLEMENT_CLASS(NDNpc, NDBaseRole)


NDNpc::NDNpc() :
npcState(NPC_STATE_NO_MARK)
{
	m_bRoleNpc = false;
	//ridepet = NULL;
	memset(m_lbName, 0, sizeof(m_lbName));
	memset(m_lbDataStr, 0, sizeof(m_lbDataStr));
	
	m_picBattle = NULL;
	m_picState = NULL;
	
	m_bActionOnRing = true;
	m_bDirectOnTalk = true;
	
	m_iStatus = -1;
	
	m_sprUpdate = NULL;
	
	m_iType = 0;
	
	m_bFarmNpc = false;
	
	m_bUnpassTurn = false;
	
	m_rectState	= CGRectZero;
}

NDNpc::~NDNpc()
{
	SAFE_DELETE(m_picBattle);
	SAFE_DELETE(m_picState);
}

void NDNpc::Init()
{
}

void NDNpc::SetActionOnRing(bool on)
{
	m_bActionOnRing = on;
}

bool NDNpc::IsActionOnRing()
{
	return m_bActionOnRing;
}

void NDNpc::SetDirectOnTalk(bool on)
{
	m_bDirectOnTalk = on;
}

bool NDNpc::IsDirectOnTalk()
{
	return m_bDirectOnTalk;
}

void NDNpc::Initialization(int lookface)
{	
	sex = lookface / 100000000 % 10;
	model = lookface / 1000 % 100;
	//lookface = 2000000;
	NSString *animationPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
	
	NSString *sprFile;
	
	if (lookface <= 0) 
		sprFile = [NSString stringWithFormat:@"%@npc1.spr", animationPath];
	else 
		sprFile = [NSString stringWithFormat:@"%@model_%d%s", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()], lookface/1000000, ".spr"];
//		if (sex == SpriteSexNone) 			
//			//sprFile = [NSString stringWithFormat:@"%@%d.spr", animationPath, (lookface % 100000) / 10];
//		{
//			if (lookface >= 13000 && lookface <= 18000) {
//				lookface /= 10;
//			}
//			SetNormalAniGroup(lookface);
//			
//			//如果模型朝向反转了,掩码也要反转
//			if (this->m_aniGroup && [this->m_aniGroup unpassPoint] != nil ) {
//				m_bUnpassTurn = ((lookface / 10) % 10) == 2;
//				//this->initUnpassPoint();
//			}
//			
//			return;
//		}
//		else if ( sex > 2 )   //动态NPC
//		{
//			m_bRoleNpc = true;
//			InitNonRoleData(m_name, lookface, 0);
//			return;
//		}
//		else
//		{
//			npcLookface = lookface;
//			hair = lookface / 10000000 % 10;
//			hairColor = lookface / 1000000 % 10;
//			skinColor = lookface / 100000 % 10;
//			expresstion = lookface / 10 % 100;
//			
//			/*
//			m_faceImage += "skin@";
//			m_faceImage += [[NSString stringWithFormat:@"%d", skinColor] UTF8String];
//			m_faceImage += ".png";
//			*/
//			
//			SetExpresstionImage(expresstion);
//			SetHair(hair, hairColor);
//			//SetFaceImage(m_faceImage.c_str());
//			SetFaceImageWithEquipmentId(skinColor);
//			
//			if (model <= 0 || model > 19) 
//				sprFile = [NSString stringWithFormat:@"%@npc1.spr", animationPath];
//			else 
//				sprFile = [NSString stringWithFormat:@"%@npc%d.spr", animationPath, model];
//		}
		
	NDSprite::Initialization([sprFile UTF8String]);
	
	m_faceRight = direct == 2;
	SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
	
}

void NDNpc::WalkToPosition(CGPoint toPos)
{
	std::vector<CGPoint> vec_pos; vec_pos.push_back(toPos);
	this->MoveToPosition(vec_pos, SpriteSpeedStep4, false);
}

void NDNpc::OnMoving(bool bLastPos)
{
	
}

void NDNpc::OnMoveEnd()
{
	if (m_dequePos.empty()) 
	{
		return;
	}
	
	CGPoint pos = m_dequePos.front();
	m_dequePos.pop_front();
	
	std::vector<CGPoint> vec_pos; vec_pos.push_back(pos);
	MoveToPosition(vec_pos, ridepet == NULL ? SpriteSpeedStep4 : SpriteSpeedStep8, false);
}

bool NDNpc::OnDrawBegin(bool bDraw)
{
	NDNode *node = this->GetParent();
	CGSize sizemap;
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		sizemap = node->GetContentSize();
	}
	else 
	{
		return true;
	}
	
	RefreshTaskState();
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	ShowShadow(this->m_id != player.GetFocusNpcID());

	NDBaseRole::OnDrawBegin(bDraw);
	
	subnode->SetContentSize(sizemap);
	
	if (ridepet)
	{
		ridepet->SetPosition(GetPosition());
		
		if (!ridepet->GetParent())
		{
			subnode->AddChild(ridepet);
		}
	}
	
	//if (IsFocus())
//	{ //画光圈
//		NDBaseRole::OnDrawBegin(bDraw);
//	}
	
	//画骑宠
	if (ridepet)
	{
		ridepet->RunAnimation(bDraw);
	}
	
	
	if (m_talkBox && m_talkBox->IsVisibled() && bDraw) 
	{
		CGPoint scrPos = GetScreenPoint();
		scrPos.x -= DISPLAY_POS_X_OFFSET;
		scrPos.y -= DISPLAY_POS_Y_OFFSET;
		//NDLog(@"x=[%d],y=[%d]",int(scrPos.x), int(scrPos.y));
		
		CGSize sizeTalk = m_talkBox->GetSize();
		
		scrPos.x = scrPos.x-8+GetWidth()/2-sizeTalk.width/2;
		
		scrPos.y = scrPos.y-getGravityY()+30;
		
		TipTriangleAlign align = TipTriangleAlignCenter;
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		if (scrPos.x + sizeTalk.width > winsize.width) 
		{
			align = TipTriangleAlignRight;
			
			scrPos.x -= sizeTalk.width/2;
		}
		else if (scrPos.x < 0)
		{
			scrPos.x = scrPos.x+sizeTalk.width/2; 
			
			align = TipTriangleAlignLeft;
		}
		
		m_talkBox->SetTriangleAlign(align);
		m_talkBox->SetDisPlayPos(scrPos);
		m_talkBox->SetVisible(true);
	}
	
	return true;
}

void NDNpc::OnDrawEnd(bool bDraw)
{
	NDNode *node = this->GetParent();
	
	CGSize sizemap;
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		sizemap = node->GetContentSize();
	}
	else 
	{
		return;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	CGPoint playerpos = player.GetPosition();
	CGPoint npcpos = this->GetPosition();
	
	CGRect rectRole, rectNPC;
	rectRole = CGRectMake(playerpos.x - SHOW_NAME_ROLE_W, playerpos.y - SHOW_NAME_ROLE_H, 
						  SHOW_NAME_ROLE_W << 1, SHOW_NAME_ROLE_H << 1);
	rectNPC	= CGRectMake(npcpos.x, npcpos.y, 16, 16);
	bool collides = CGRectIntersectsRect(rectRole, rectNPC);
	
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
	
	CGSize size		= getStringSize(m_name.c_str(), 12);
	
	int showX = npcpos.x;
	int showY = npcpos.y - size.height - (m_currentAnimation ? ([m_currentAnimation bottomY]-[m_currentAnimation y]): 0);
	
//	if (collides)
//	{
		bool isEmemy = false;
		if ( player.IsInState(USERSTATE_FIGHTING) )
		{
			isEmemy = (GetCamp()!= CAMP_NEUTRAL && player.GetCamp() != CAMP_NEUTRAL
					   && GetCamp() != player.GetCamp());
		}
		
		
		//unsigned int iColor = isEmemy ? 0xe30318 : 0x88EEFF;
		unsigned int iColor = isEmemy ? 0xe30318 : 0xffff00;
		
		if (!dataStr.empty() && dataStr != NDCommonCString("wu"))
		{
			InitNameLable(m_lbDataStr[0]);InitNameLable(m_lbDataStr[1]);
			SetLable(eLabelDataStr, showX, showY, dataStr, INTCOLORTOCCC4(iColor), ccc4(0, 0, 0, 255));
			DrawLable(m_lbDataStr[1], bDraw); DrawLable(m_lbDataStr[0], bDraw);
			showY -= 20 * fScaleFactor;
		}
		
		if (!m_name.empty())
		{
			InitNameLable(m_lbName[0]);InitNameLable(m_lbName[1]);
			SetLable(eLableName, showX, showY, m_name, INTCOLORTOCCC4(iColor), ccc4(0, 0, 0, 255));
			DrawLable(m_lbName[1], bDraw); DrawLable(m_lbName[0], bDraw);
			//showY -= 5 * fScaleFactor;
		}
		
		if ( (npcState & NPC_STATE_BATTLE) > 0) 
		{
			if (m_picBattle == NULL)
			{
				m_picBattle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("battle.png"));
				CGSize sizeBattle = m_picBattle->GetSize();
				m_picBattle->DrawInRect(CGRectMake(npcpos.x-16, GetPosition().y-64+NDDirector::DefaultDirector()->GetWinSize().height-sizemap.height, sizeBattle.width, sizeBattle.height));
			}
		}else 
		{
			if (m_picState != NULL) 
			{
				CGSize sizeState = m_picState->GetSize();
				CGRect rect = CGRectMake(npcpos.x-sizeState.width / 2, showY+NDDirector::DefaultDirector()->GetWinSize().height-sizemap.height - sizeState.height, sizeState.width, sizeState.height);
				m_rectState = CGRectMake(npcpos.x-sizeState.width / 2, showY - sizeState.height, sizeState.width, sizeState.height);
				m_picState->DrawInRect(rect);
			}
		}
//	}
	
	if (!talkStr.empty() && talkStr.size() > 3 && abs(player.GetCol()-this->col) <= 2 && abs(player.GetRow()-this->row) <= 2) 
		addTalkMsg(talkStr, 0);
	else if (m_talkBox)
		SAFE_DELETE_NODE(m_talkBox);
	
	//升级特效
	ShowUpdate(m_iStatus == 1, bDraw);
	
}

void NDNpc::BeforeRunAnimation(bool bDraw)
{
	if (m_talkBox && m_talkBox->IsVisibled() && !bDraw) 
	{
		m_talkBox->SetVisible(false);
	}
}

void NDNpc::SetExpresstionImage(int nExpresstion)
{
	int express = 10400;
	switch (nExpresstion) 
	{
		case 0://
			break;
		case 1://
			express = 10400;
			break;
		case 2:// 
			express = 10401;
			break;
		case 3:// 
			express = 10404;
			break;
		case 4:// 
			express = 10405;
			break;
		case 5:// 
			express = 10406;
			break;
		case 6:// 
			express = 10407;
			break;
		case 7:// 
			express = 10408;
			break;
		case 8:// 
			express = 10409;
			break;
		case 9:// 
			express = 10410;
			break;
	}
	
	if (express >= 10400 && express < 10600) 
	{

		std::string str;
		str += [[NSString stringWithFormat:@"%@%d", [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()] ,express] UTF8String];
		str += ".png";
		SetExpressionImage(str.c_str());
	}
}

void NDNpc::SetNpcState(NPC_STATE state)
{
	if (state == this->npcState)
	{
		return;
	}
	
	if (m_picState)
	{
		SAFE_DELETE(m_picState);
	}
	this->npcState = state;
	
	if ( (npcState & QUEST_CANNOT_ACCEPT) > 0)
	{
		//m_picState = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("task_state_1.png"));
	} 
	else if ( (npcState & QUEST_CAN_ACCEPT) > 0) 
	{
		m_picState = NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("mark_submit.png"));
	} 
	else if ( (npcState & QUEST_NOT_FINISH) > 0)
	{
		m_picState = NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("mark_task_accepted.png"));
	} 
	else if ( (npcState & QUEST_FINISH) > 0)
	{
		m_picState = NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("mark_task_accept.png"));
	}
	
	if (!m_picState)
	{
		m_picState = ScriptMgrObj.excuteLuaFunc<NDPicture*>("GetNpcFuncPic", "NPC", this->m_id);
	}
}

void NDNpc::AddWalkPoint(int col, int row)
{
	this->col = col;
	this->row = row;
	
	m_dequePos.push_back(ccp(col*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, row*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
	
	if (!m_moving) 
	{
		CGPoint pos = m_dequePos.front();
		m_dequePos.pop_front();
		
		std::vector<CGPoint> vec_pos; vec_pos.push_back(pos);
		MoveToPosition(vec_pos, ridepet == NULL ? SpriteSpeedStep4 : SpriteSpeedStep8, false);
	}
}

void NDNpc::SetStatus(int status)
{
	m_iStatus = status;
}

void NDNpc::ShowUpdate(bool bshow, bool bDraw)
{
	if (!m_sprUpdate && bshow) 
	{
		m_sprUpdate = new NDSprite;
		m_sprUpdate->Initialization([[NSString stringWithFormat:@"%@builtupdate.spr", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()] ] UTF8String]);
		m_sprUpdate->SetCurrentAnimation(0, false);
		
		if (subnode) subnode->AddChild(m_sprUpdate);
	}

	if (m_sprUpdate && !bshow) 
	{
		SAFE_DELETE_NODE(m_sprUpdate);
	}
	
	if (bshow) 
	{
		CGPoint pos = this->GetPosition();
		pos.x -= DISPLAY_POS_X_OFFSET;
		pos.y -= DISPLAY_POS_Y_OFFSET;
		
		//if (aniGroup != null) {
//			updateEffect.draw(g, x - 5, y - aniGroup.getGravityY(),
//							  offsetX, offsetY);
//		} else if (baseRole != null) {
//			updateEffect.draw(g, x - 5, y - baseRole.getHeight(), offsetX,
//							  offsetY);
//		} else {
//			updateEffect.draw(g, x - 5, y - 20, offsetX, offsetY);
//		}

		pos.x -= 5;
		pos.y -= getGravityY();
		
		m_sprUpdate->SetPosition(pos);
		m_sprUpdate->RunAnimation(bDraw);
	}
}

void NDNpc::HandleNpcMask(bool bSet)
{
	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
	if (!layer)
	{
		return;
	}
	
	NDMapData *mapdata = layer->GetMapData();
	
	if (!mapdata) {
		return;
	}
	
	CGPoint point = this->GetPosition();
	int iCellY = int((point.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE), iCellX = int((point.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE);
	
	NSArray *unpass = [m_aniGroup unpassPoint];
	NSInteger unpassCount = [unpass count];
	if (unpass == nil || unpassCount % 2 != 0) {
		if (bSet)
			[mapdata addObstacleCell:iCellY andColumn:iCellX];
		else
			[mapdata removeObstacleCell:iCellY andColumn:iCellX];
		return;
	}
	
	for (NSInteger i = 0; i < unpassCount; i+= 2) {
		NSNumber *cellX = (NSNumber*)[unpass objectAtIndex:i];
		NSNumber *cellY = (NSNumber*)[unpass objectAtIndex:i+1];
		if (cellX && cellY) {
			if (bSet)
				[mapdata addObstacleCell:[cellY charValue]+iCellY andColumn:[cellX charValue]+iCellX];
			else
				[mapdata removeObstacleCell:[cellY charValue]+iCellY andColumn:[cellX charValue]+iCellX];
		}
	}
	
}

void NDNpc::SetType(int iType)
{
	m_iType = iType;
}

int NDNpc::GetType()
{
	return m_iType;
}

void NDNpc::SetLable(LableType eLableType, int x, int y, std::string text, ccColor4B color1, ccColor4B color2)
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
	else if (eLableType == eLabelDataStr) 
	{
		lable[0] = m_lbDataStr[0];
		lable[1] = m_lbDataStr[1];
	}
	
	if (!lable[0] || !lable[1]) 
	{
		return;
	}
	
	lable[0]->SetText(text.c_str());
	lable[1]->SetText(text.c_str());
	
	lable[0]->SetFontColor(color1);
	lable[1]->SetFontColor(color2);
	
	//lable[0]->SetFontBoderColer(color1);
	//lable[1]->SetFontBoderColer(color2);
	
	CGSize sizemap;
	sizemap = subnode->GetContentSize();
	CGSize sizewin = NDDirector::DefaultDirector()->GetWinSize();
	float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
	CGSize size = getStringSize(text.c_str(), 12);
	lable[1]->SetFrameRect(CGRectMake(x-(size.width/2)+1, y+NDDirector::DefaultDirector()->GetWinSize().height-sizemap.height, sizewin.width, 20 * fScaleFactor));
	lable[0]->SetFrameRect(CGRectMake(x-(size.width/2), y+NDDirector::DefaultDirector()->GetWinSize().height-sizemap.height, sizewin.width, 20 * fScaleFactor));
}
//NDRidePet* NDNpc::GetRidePet()
//{
//	if (ridepet == NULL) 
//	{
//		ridepet = new NDRidePet;
//	}
//	return ridepet;
//}

void NDNpc::initUnpassPoint()
{
	if (m_aniGroup == nil)
		return;
		
	CGPoint point = this->GetPosition();
	
	NSArray *unpass = [m_aniGroup unpassPoint];
	NSInteger unpassCount = [unpass count];
	if (unpass == nil || unpassCount % 2 != 0) {
		m_vUnpassRect.clear();
		
		m_vUnpassRect.push_back(CGRectMake(point.x-4, point.y-16, 20, 16));
		
		return;
	}
	
	//int iCellY = int((point.y-DISPLAY_POS_Y_OFFSET)/16), iCellX = int((point.x-DISPLAY_POS_X_OFFSET)/16);
	
	for (NSInteger i = 0; i < unpassCount; i+= 2) {
		NSNumber *cellX = (NSNumber*)[unpass objectAtIndex:i];
		NSNumber *cellY = (NSNumber*)[unpass objectAtIndex:i+1];
		
		CGPoint pos;
		pos.x = (IsUnpassNeedTurn() ? (-[cellX charValue]) : [cellX charValue]) * 16 + point.x;
		pos.y = [cellY charValue] * 16 + 8 + point.y;
		
		
		m_vUnpassRect.push_back(CGRectMake(pos.x, pos.y, 16, 16));
	}
}

bool NDNpc::IsUnpassNeedTurn()
{
	return m_bUnpassTurn;
}

bool NDNpc::IsPointInside(CGPoint point)
{
	if (m_currentAnimation)
	{
		CGRect rect = CGRectMake(this->m_position.x-this->GetWidth()/2,this->m_position.y-this->GetHeight(),this->GetWidth(),this->GetHeight());
		if (CGRectContainsPoint(rect, point))
			return true;
	}
	
	if (m_picState)
	{
		if (CGRectContainsPoint(m_rectState, point))
		{
			return true;
		}
	}
	
	std::vector<CGRect>::iterator it = m_vUnpassRect.begin();
	
	for (; it != m_vUnpassRect.end(); it++) {
		CGRect rect = *it;
		rect.origin.y -= 24;
		rect.size.height += 24;
		rect.origin.x -= 8;
		rect.size.width += 8;
		if (CGRectContainsPoint(rect, point))
			return true;
	}
	
	return false;
}

bool NDNpc::getNearestPoint(CGPoint srcPoint, CGPoint& dstPoint)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
	if (!scene) return false;
	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
	if (!layer) return false;
	NDMapData* mapdata = layer->GetMapData();
	if (!mapdata) return false;
	
	int resX = 0, resY = 0;
	
	int srcY = int((srcPoint.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE), srcX = int((srcPoint.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE);
	
	int maxDis = [mapdata columns]*[mapdata columns] + [mapdata rows]*[mapdata rows];
	
	int nArrayX[4] = {0, -1, 0, 1};
	int nArrayY[4] = {1, 0, -1, 0};
	
	if (m_aniGroup != nil && [m_aniGroup unpassPoint] != nil)
	{
		NSArray *unpass = [m_aniGroup unpassPoint];
		NSInteger unpassCount = [unpass count];
		
		for (NSInteger i = 0; i < unpassCount; i+= 2) {
			NSNumber *cellX = (NSNumber*)[unpass objectAtIndex:i];
			NSNumber *cellY = (NSNumber*)[unpass objectAtIndex:i+1];
			
			int x, y;
			
			x = col + (IsUnpassNeedTurn() ? (-[cellX charValue]) : [cellX charValue]);
			y = row + [cellY charValue];
			
			int newX, newY;
			
			for(int i = 0; i < 4; ++i)
			{
				newX = x + nArrayX[i];
				newY = y + nArrayY[i];
				if(newX < 0)
					continue;
				if(newX < 0)
					continue;
				if(newX > int([mapdata columns]))
					continue;
				if(newY > int([mapdata rows]))
					continue;
					
				if (![mapdata canPassByRow:newY andColumn:newX])
					continue;
				
				int cacl = (newX-srcX) * (newX-srcX) + (newY-srcY) * (newY-srcY);
				
				if (cacl < maxDis)
				{
					maxDis = cacl;
					
					resX = newX;
					
					resY = newY;
				}
			}	
		}
	}
	else 
	{
		
		for(int i = 0; i < 4; ++i)
		{
			int newX = col + nArrayX[i];
			int newY = row + nArrayY[i];
			if(newX < 0)
				continue;
			if(newX < 0)
				continue;
			if(newX > int([mapdata columns]))
				continue;
			if(newY > int([mapdata rows]))
				continue;
			
			if (![mapdata canPassByRow:newY andColumn:newX])
				continue;
			
			int cacl = (newX-srcX) * (newX-srcX) + (newY-srcY) * (newY-srcY);
			
			if (cacl < maxDis)
			{
				maxDis = cacl;
				
				resX = newX;
				
				resY = newY;
			}
		}	
	}

	if (resX == 0 && resY == 0)
	{
		resX = this->GetPosition().x;
		resY = this->GetPosition().y;
	}
	
	dstPoint = CGPointMake(resX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, resY*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET);
	
	return true;
}

void NDNpc::RefreshTaskState()
{
	// 玩家已接任务列表
	ID_VEC idlistAccept;
	ScriptGameDataObj.GetDataIdList(eScriptDataRole, NDPlayer::defaultHero().m_id, eRoleDataTask, idlistAccept);
	if (!idlistAccept.empty())
	{
		for (ID_VEC::iterator it = idlistAccept.begin(); 
			 it != idlistAccept.end(); 
			 it++) 
		{
			// 可交
			int nState = ScriptGetTaskState(*it);
			if (TASK_STATE_COMPLETE == nState)
			{
				if ( m_id == ScriptDBObj.GetN("task_type", *it, DB_TASK_TYPE_FINISH_NPC))
				{
					this->SetNpcState((NPC_STATE)QUEST_FINISH);
					return;
				}
			}
		}
	}
	
	ID_VEC idVec;
	GetTaskList(idVec);
	
	ID_VEC idCanAccept;
	if (GetPlayerCanAcceptList(idCanAccept))
	{
		for (ID_VEC::iterator it = idVec.begin(); 
			 it != idVec.end(); 
			 it++) 
		{
			// 可接
			for (ID_VEC::iterator itCanAccept = idCanAccept.begin(); 
				 itCanAccept != idCanAccept.end(); 
				 itCanAccept++) 
			{
				if (*it == *itCanAccept)
				{
					this->SetNpcState((NPC_STATE)QUEST_CAN_ACCEPT);
					return;
				}
			}
		}
	}
	
	for (ID_VEC::iterator it = idVec.begin(); 
		 it != idVec.end(); 
		 it++) 
	{
		// 未完成
		int nState = ScriptGetTaskState(*it);
		if (TASK_STATE_UNCOMPLETE == nState)
		{
			this->SetNpcState((NPC_STATE)QUEST_NOT_FINISH);
			return;
		}
	}
	
	this->SetNpcState((NPC_STATE)QUEST_CANNOT_ACCEPT);
}

int NDNpc::GetDataBaseData(int nIndex)
{
	int nKey = ScriptDBObj.GetKey("npc");
	if (0 == nKey)
	{
		return 0;
	}
	return ScriptGameDataObj.GetData<unsigned long long>(eScriptDataDataBase, nKey, eRoleDataPet, this->m_id, nIndex);
}

bool NDNpc::GetTaskList(ID_VEC& idVec)
{
	idVec.clear();
	
	int nTask		= GetDataBaseData(DB_NPC_TASK0);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK1);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK2);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK3);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK4);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK5);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK6);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK7);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK8);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	nTask			= GetDataBaseData(DB_NPC_TASK9);
	if (0 < nTask)
		idVec.push_back(nTask);
	
	
	return !idVec.empty();
}

bool NDNpc::GetPlayerCanAcceptList(ID_VEC& idVec)
{
	idVec.clear();
	
	if (!ScriptGameDataObj.GetDataIdList(eScriptDataRole, 
										 NDPlayer::defaultHero().m_id, 
										 eRoleDataTaskCanAccept, 
										 idVec))
	{
		return false;
	}
	
	return true;
}

void NDNpc::ShowHightLight(bool bShow)
{
	if (m_picState)
	{
		m_picState->SetColor(bShow ? ccc4(255, 255, 255, 125) : ccc4(255, 255, 255, 255));
	}
	
	this->SetHightLight(bShow);
}
