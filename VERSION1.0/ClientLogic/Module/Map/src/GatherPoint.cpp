/*
 *  GatherPoint.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-3.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GatherPoint.h"
#include "NDMapMgr.h"
#include "NDUtility.h"
#include "NDPicture.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "define.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "NDPath.h"
#include <sstream>
#include <string>

using namespace std;

IMPLEMENT_CLASS(GatherPoint, NDBaseRole)

GatherPoint::GatherPoint()
{
}

GatherPoint::GatherPoint(int iID, int iTypeID, int xx, int yy,bool isBoss ,std::string name)
{
	m_state = MONSTER_STATE_NORMAL;
	
	x = xx;
	y = yy + DISPLAY_POS_Y_OFFSET;
	
	this->SetPosition(ccp(x,y));
	
	m_iID = iID;
	m_iTypeID = iTypeID;
	
	bossRing = NULL;
	m_pic = NULL;
	
// 	monster_type_info info;
// 	if ( !NDMapMgrObj.GetMonsterInfo(info, m_iTypeID) )
// 	{
// 		NDLog(@"采集点初始化失败,原因是没有找到类型[%d]信息", m_iTypeID);
// 		return;
// 	}
// 	else
// 	{
// 		gatherName = info.name;
// 	}
// 	
// 	if (isBoss)
// 	{
// 		if (this->bossRing == NULL)
// 		{
// 			bossRing = new NDSprite;
// 			bossRing->Initialization(NDPath::GetAniPath("caoyao_ani.spr"));
// 			bossRing->SetCurrentAnimation(0, false);
// 		}
// 	}
// 	
// 	if (info.lookFace>1000) 
// 	{
// 		SetNormalAniGroup(info.lookFace);
// 		m_position.x += 8;
// 	}
// 	else 
// 	{
// 		NDNode::Initialization();
// 		
// 		stringstream ss; ss << info.lookFace << ".png";
// 		
// 		m_pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath(ss.str().c_str()));
// 		
// 		if (m_pic) 
// 		{
// 			CCSize sizePic = m_pic->GetSize();
// 			this->SetPosition(CCPointMake(x-8, y-sizePic.height));
// 			SetSprite(m_pic);
// 		}
// 	}
// 	
// 	m_lbName = NULL;
// 	
// 	if (!gatherName.empty())
// 	{
// 		m_lbName = new NDUILabel;
// 		m_lbName->Initialization();
// 		m_lbName->SetFontSize(13);
// 		m_lbName->SetFontColor(ccc4(0, 0, 0, 255));
// 		m_lbName->SetText(gatherName.c_str());
// 	}
}

GatherPoint::~GatherPoint()
{
	if (m_pic) 
	{
		delete m_pic;
		m_pic = NULL;
	}
}

bool GatherPoint::OnDrawBegin(bool bDraw)
{
	NDNode *node = this->GetParent();
	
	CCSize sizemap;
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		sizemap = node->GetContentSize();
	}
	else 
	{
		return true;
	}
	
	m_pkSubNode->SetContentSize(sizemap);
	
	if (bossRing && m_pkAniGroup == nil)
	{
		//bossRing->SetPosition(GetPosition());
		CCPoint p = this->GetPosition();
		bossRing->SetPosition(CCPointMake(x-8, y+4-17));
		if (!bossRing->GetParent())
		{
			m_pkSubNode->AddChild(bossRing);
		}
	
		bossRing->RunAnimation(bDraw);
	}
	
		
	return true;
}

void GatherPoint::OnDrawEnd(bool bDraw)
{
	NDNode *node = this->GetParent();
	
	CCSize sizemap;
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		sizemap = node->GetContentSize();
	}
	else 
	{
		return;
	}
	
	if (m_lbName)
	{
		if (!m_lbName->GetParent())
		{
			m_pkSubNode->AddChild(m_lbName);
			m_lbName->SetFrameRect(CCRectMake(x-8, y-(m_pic ? m_pic->GetSize().height : 8)-13-5+320-sizemap.height, 480, 13));
		}
		
		if (bDraw)
		{
			m_lbName->draw();
		}
	}
	
}

int GatherPoint::GetOrder()
{
	return y;
}

int GatherPoint::getMapId() {
	return mapId;
}

void GatherPoint::setMapId(int mapId) {
	this->mapId = mapId;
}

string GatherPoint::getName() {
	return gatherName;
}

void GatherPoint::setGatherName(string gatherName) {
	this->gatherName = gatherName;
}
//带光环
void GatherPoint::enableRing(bool b) {
	if (b) {
		if (this->bossRing == NULL) {
			bossRing = new NDSprite;
			bossRing->Initialization(NDPath::GetAniPath("caoyao_ani.spr").c_str());
			bossRing->SetCurrentAnimation(0, false);
		}
	}else {
		if (this->bossRing)
		{
			if (this->bossRing->GetParent())
			{
				this->bossRing->RemoveFromParent(true);
			}
			else
			{
				delete this->bossRing;
			}
			
			this->bossRing = NULL;
		}
	}
}

void GatherPoint::sendCollection() { // 发送采集
	NDTransData bao(_MSG_COLLECTION);
	bao << (int)m_iID;
	SEND_DATA(bao);
}

int GatherPoint::getBottom() {
	return y;
}

int GatherPoint::getHeight() {
	// Auto-generated method stub
	return BASE_BOTTOM_WH;
}

//public Array getSubAniGroup() {
//	//  Auto-generated method stub
//	return null;
//}

int GatherPoint::getWidth() {
	//  Auto-generated method stub
	return BASE_BOTTOM_WH;
}

int GatherPoint::getX() {
	//  Auto-generated method stub
	return x;
}

int GatherPoint::getY() {
	//  Auto-generated method stub
	return y;
}

bool GatherPoint::isJustCollided() {
	return m_isJustCollided;
}

void GatherPoint::setJustCollided(bool isJustCollid) {
	this->m_isJustCollided = isJustCollid;
}

int getAttachArea() {
	//  Auto-generated method stub
	return 0;
}

bool GatherPoint::isCanDraw() {
	return m_isCanDraw;
}

//void GatherPoint::refreshData() {
//	if (this->bossRing != NULL) {
//		this->bossRing->refreshData();
//	}
//}

void GatherPoint::setCanDraw(bool b) {
	this->m_isCanDraw = b;
}

int GatherPoint::getId() {
	return this->m_iID;
}

bool GatherPoint::isAlive() {
	return this->m_state == MONSTER_STATE_NORMAL;
}

bool GatherPoint::isCollides(int x1,int y1, int w,int h) {
	CCRect rectRole = CCRectMake(x1,y1,w,h);
	CCRect rectMonster = CCRectMake(x+8,y-4,4,4);
	return cocos2d::CCRect::CCRectIntersectsRect(rectRole, rectMonster);
}

void GatherPoint::setId(int id) {
	this->m_iID = id;
}
int GatherPoint::getTypeId() {
	return this->m_iTypeID;
}
void GatherPoint::setState(int state) {
	this->m_state = state;
// 	if (state != MONSTER_STATE_NORMAL)
// 	{
// 		NDMapMgrObj.ClearOneGP(this);
// 	}
}
int GatherPoint::getState() {
	return this->m_state;
}