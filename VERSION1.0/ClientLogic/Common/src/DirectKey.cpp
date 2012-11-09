//
//  DirectKey.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-5-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "DirectKey.h"
#include "NDPicture.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDMapMgr.h"
#include "NDMapLayer.h"
#include "NDMapData.h"
#include "AutoPathTip.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "NDPath.h"

#define DIRECTKEY_SHRINK_W (18)
#define DIRECTKEY_SHRINK_H (18)

#define DIRECTKEY_DRAG_W (40)
#define DIRECTKEY_DRAG_H (40)

#define DIRECTKEY_W (140)
#define DIRECTKEY_H (140) 

IMPLEMENT_CLASS(NDUIDirectKeyTop, NDUILayer)

NDUIDirectKeyTop::NDUIDirectKeyTop()
{
	m_nodeObserver = NULL;
}

NDUIDirectKeyTop::~NDUIDirectKeyTop()
{
}

void NDUIDirectKeyTop::Initialization(NDNode* observer)
{
	NDUILayer::Initialization();
	
	m_nodeObserver = observer;
}

void NDUIDirectKeyTop::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
{
	if ( (!bCleanUp && node == m_nodeObserver)
		  && m_nodeObserver
		  && m_nodeObserver->IsKindOfClass(RUNTIME_CLASS(DirectKey))
		)
	{
		((DirectKey*)m_nodeObserver)->OnTouchUp();
	}
	
	if (!bCleanUp || node != m_nodeObserver) return;
	
	for_vec(m_kChildrenList,std::vector<NDNode*>::iterator)
	{
		if ((*it) && (*it)->GetDelegate() == node) 
		{
			(*it)->SetDelegate(NULL);
		}
	}
	
	if (GetDelegate() == node)
		SetDelegate(NULL);
		
}

IMPLEMENT_CLASS(DirectKey, NDUILayer)

bool DirectKey::s_shink = false;
CGRect DirectKey::s_Rect = CGRectZero;


CGRect RectAdd(CGRect rect, int value)
{
	return CGRectMake(rect.origin.x - value, rect.origin.y - value, rect.size.width + 2 * value, rect.size.height + 2 * value);
}

DirectKey::DirectKey()
{
	m_btnLeft = NULL;
	m_btnRight = NULL; 
	m_btnUp = NULL; 
	m_btnDown = NULL;
	
	m_timer = new NDTimer();
	
	m_btnShrink = NULL;
	
	m_btnLayer = NULL;
	
	m_picNormal = m_picDown = NULL;
	
	m_addShrink = false;
	
	m_touchDown = false;
	
	m_picCenterNormal = m_picCenterShrink = NULL;
}

DirectKey::~DirectKey()
{
	s_Rect = GetFrameRect();
	
	SAFE_DELETE(m_picNormal);
	
	SAFE_DELETE(m_picDown);
	
	SAFE_DELETE(m_picCenterNormal);
	
	SAFE_DELETE(m_picCenterShrink);
	
	if (!m_addShrink) 
	{
		SAFE_DELETE_NODE(m_btnShrink);
	}
	
	delete m_timer;
}

void DirectKey::Initialization()
{
// 	NDUILayer::Initialization();
// 	
// 	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
// 	
// 	m_picNormal = pool.AddPicture(NDPath::GetImgPathNew("nav_normal.png"));
// 	
// 	m_picNormal->SetColor(ccc4(125, 125, 125, 125));
// 	
// 	m_picDown = pool.AddPicture(NDPath::GetImgPathNew("nav_down.png"));
// 	
// 	//NDPicture *picCenter = pool.AddPicture(GetImgPathNew("nav_center.png"));
// 	
// 	vector<const char*>vImgFiles;
// 	vector<CGRect> vImgCustomRect;
// 	vector<CGPoint>vOffsetPoint;
// 	
// 	vImgFiles.push_back(NDPath::GetImgPathNew("nav_center.png")); 
// 	vImgCustomRect.push_back(CGRectMake(0, 0, DIRECTKEY_DRAG_W, DIRECTKEY_DRAG_H));
// 	vOffsetPoint.push_back(ccp(0.0f, 0.0f));
// 	
// 	vImgFiles.push_back(NDPath::GetImgPathNew("nav_fang.png")); 
// 	vImgCustomRect.push_back(CGRectMake(0, 0, DIRECTKEY_SHRINK_W, DIRECTKEY_SHRINK_H));
// 	vOffsetPoint.push_back(ccp((DIRECTKEY_DRAG_W-DIRECTKEY_SHRINK_W)/2, (DIRECTKEY_DRAG_H-DIRECTKEY_SHRINK_H)/2));
// 	
// 	m_picCenterNormal = new NDPicture;
// 	
// 	m_picCenterNormal->Initialization(vImgFiles, vImgCustomRect, vOffsetPoint);
// 	
// 	m_picCenterNormal->SetColor(ccc4(125, 125, 125, 125));
// 	
// 	vImgFiles[1] = NDPath::GetImgPathNew("nav_suo.png");
// 	
// 	m_picCenterShrink = new NDPicture;
// 	
// 	m_picCenterShrink->Initialization(vImgFiles, vImgCustomRect, vOffsetPoint);
// 	
// 	SetBackgroundImage(m_picNormal);
	
	/*
	CGSize sizeCenter = picCenter->GetSize(),
		   sizeBg = m_picNormal->GetSize();
	
	int horizontalW = (sizeBg.width-sizeCenter.width)/2,
		horizontalH = sizeCenter.height,
		horizontalY = (sizeBg.height-sizeCenter.height)/2,
		rightStartX = horizontalW+sizeCenter.width,
		verticalH = horizontalY,
		verticalW = sizeCenter.width,
		verticalStartX = horizontalW,
		downStartY = verticalH+sizeCenter.height;
	*/
	
	/*
	 left direct key
	 */
	
//	m_btnLeft = new NDUIButton();
//	m_btnLeft->Initialization();
//	m_btnLeft->CloseFrame();
//	m_btnLeft->SetFrameRect(CGRectMake(0, horizontalY, horizontalW, horizontalH));
//	m_btnLeft->SetTouchDownColor(ccc4(255, 255, 255, 0));
//	m_btnLeft->SetDelegate(this);
//	AddChild(m_btnLeft);	
	
	/*
	 right direct key
	 */
	
//	m_btnRight = new NDUIButton();
//	m_btnRight->Initialization();
//	m_btnRight->CloseFrame();
//	m_btnRight->SetFrameRect(CGRectMake(rightStartX, horizontalY, horizontalW, horizontalH));
//	m_btnRight->SetTouchDownColor(ccc4(255, 255, 255, 0));
//	m_btnRight->SetDelegate(this);
//	AddChild(m_btnRight);	
	
	/*
	 up direct key
	 */
	 
//	m_btnUp = new NDUIButton();
//	m_btnUp->Initialization();
//	m_btnUp->CloseFrame();
//	m_btnUp->SetFrameRect(CGRectMake(verticalStartX, 0, verticalW, verticalH));
//	m_btnUp->SetTouchDownColor(ccc4(255, 255, 255, 0));
//	m_btnUp->SetDelegate(this);
//	AddChild(m_btnUp);	
	
	/*
	 down direct key
	 */
	 
//	m_btnDown = new NDUIButton();
//	m_btnDown->Initialization();
//	m_btnDown->CloseFrame();
//	m_btnDown->SetFrameRect(CGRectMake(verticalStartX, downStartY, verticalW, verticalH));
//	m_btnDown->SetTouchDownColor(ccc4(255, 255, 255, 0));
//	m_btnDown->SetDelegate(this);
//	AddChild(m_btnDown);
	
	m_btnShrink = new NDUIButton();
	m_btnShrink->Initialization();
	m_btnShrink->SetImage(m_picCenterNormal);
	m_btnShrink->SetFrameRect(CGRectMake((DIRECTKEY_W-DIRECTKEY_DRAG_W)/2, 
										 (DIRECTKEY_H-DIRECTKEY_DRAG_H)/2, 
										  DIRECTKEY_DRAG_W, 
										  DIRECTKEY_DRAG_H));
	m_btnShrink->SetDelegate(this);
	m_btnShrink->SetNormalImageColor(ccc4(125, 125, 125, 255));
	m_btnShrink->SetTouchDownColor(ccc4(255, 255, 255, 255));
	m_addShrink = false;
	
	if (s_Rect.size.width == 0.0f || s_Rect.size.height == 0.0f) 
	{
		s_Rect = CGRectMake(0, 200, DIRECTKEY_W, DIRECTKEY_H);
	}
	
	SetFrameRect(s_Rect);
	
//	if (s_shink) 
//	{
//		ReverseShrinkState();
//	}
}

/*
void DirectKey::OnButtonDown(NDUIButton* button)
{
	if	(button == m_btnShrink) return ;
	
	PictureRotation rota = PictureRotation0;
	
	if (button == m_btnLeft) 
	{
		m_keyDirect = KeyDirectLeft;
		
		rota = PictureRotation270;
	}
	else if (button == m_btnRight)
	{
		m_keyDirect = KeyDirectRight;
		
		rota = PictureRotation90;
	}
	else if (button == m_btnUp)
	{
		m_keyDirect = KeyDirectUp;
	}
	else if (button == m_btnDown)
	{
		m_keyDirect = KeyDirectDown;
		
		rota = PictureRotation180;
	}
	
	if (m_picDown) 
	{
		m_picDown->Rotation(rota);
		
		SetBackgroundImage(m_picDown);
	}
	
	DealKey(m_keyDirect);
	
	m_timer->SetTimer(this, 1, 1.0f / 60.0f);
	
	if (AutoPathTipObj.IsWorking())
		AutoPathTipObj.Stop();
		
	if (m_btnShrink) 
	{
		m_btnShrink->SetNormalImageColor(ccc4(255, 255, 255, 255));
	}
}
*/

void DirectKey::OnTouchDown(KeyDirect type)
{
	if (m_touchDown) return;
	
	m_touchDown = true;
	
	m_keyDirect = type;
	
	UpdateDownPicture();
	
	DealKey(m_keyDirect);
	
	m_timer->SetTimer(this, 1, 1.0f / 60.0f);
	
	if (AutoPathTipObj.IsWorking())
		AutoPathTipObj.Stop();
	
	if (m_picCenterNormal) 
	{
		m_picCenterNormal->SetColor(ccc4(255, 255, 255, 255));
	}
}

void DirectKey::OnTimer(OBJID tag)
{	
	NDUILayer::OnTimer(tag);
	
	if (tag != 1) return;
	
	DealKey(m_keyDirect);
}

/*
void DirectKey::OnButtonUp(NDUIButton* button)
{
	if	(button == m_btnShrink) return ;
	
	m_timer->KillTimer(this, 1);
	m_dequeDir.clear();
	
	if (m_picNormal) 
		SetBackgroundImage(m_picNormal);
	
	if (m_btnShrink) 
	{
		m_btnShrink->SetNormalImageColor(ccc4(125, 125, 125, 255));
	}
}
*/

void DirectKey::OnTouchUp()
{
	if (!m_touchDown) return;
	
	m_touchDown = false;
	
	m_timer->KillTimer(this, 1);
	m_dequeDir.clear();
	
	//NDPlayer::defaultHero().stopMoving(true);
	
	if (m_picNormal) 
		SetBackgroundImage(m_picNormal);
		
	if (m_picCenterNormal) 
	{
		m_picCenterNormal->SetColor(ccc4(125, 125, 125, 125));
	}
}

bool DirectKey::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	if (button == m_btnShrink) 
	{
		RefreshPosition(moveTouch);
		
		return true;
	}
	
	return false;
}

bool DirectKey::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	if (button == m_btnShrink) 
	{
		RefreshPosition(endTouch);
		
		return true;
	}
	
	return false;
}

void DirectKey::OnButtonClick(NDUIButton* button)
{
	if (!button) return;
	
	NDNode *pNode = button->GetParent();
	
	if (button == m_btnShrink && pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		
		CGRect scrRect = button->GetScreenRect();
		//scrRect = ::RectAdd(scrRect, 2);
		scrRect.origin.x += (DIRECTKEY_DRAG_W-DIRECTKEY_SHRINK_W)/2;
		scrRect.origin.y += (DIRECTKEY_DRAG_H-DIRECTKEY_SHRINK_H)/2;
		scrRect.size.width = DIRECTKEY_SHRINK_W;
		scrRect.size.height = DIRECTKEY_SHRINK_H;
		
		CGPoint beginTouch = ((NDUILayer*)pNode)->m_kBeginTouch;
		if (CGRectContainsPoint(scrRect, beginTouch))
			ReverseShrinkState();
	}
}

void DirectKey::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
{
	if (!bCleanUp || node != m_btnLayer) return;
	
	if (GetDelegate() == m_btnLayer)
		SetDelegate(NULL);
}

void DirectKey::DealKey(KeyDirect type)
{
	m_dequeDir.push_back(type);
}

bool DirectKey::CheckCell(int iCellX, int iCellY)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	
	if (!scene) return false;
	
	NDMapLayer* maplayer = NDMapMgrObj.getMapLayerOfScene(scene);
	
	if (!maplayer) return false;
	
	NDMapData *mapdata = maplayer->GetMapData();
	
	if (!mapdata) return false;
	
	
	if (NDPlayer::defaultHero().IsInState(USERSTATE_FLY) 
		&& NDMapMgrObj.canFly())
	{
		return true;
	}
	
	return mapdata->canPassByRow(iCellY, iCellX);
}

bool DirectKey::NextDir(int iCellX, int iCellY, KeyDirect& dir)
{	
	static bool bUpPriority = true, bRightPriority = true;
	
	if (CanDiretect(iCellX, iCellY, dir)) 
	{
		return true;
	}
	
	if (dir == KeyDirectLeft || dir == KeyDirectRight) 
	{
		if (CanDiretect(iCellX, iCellY, bUpPriority ? KeyDirectUp : KeyDirectDown) ||
			CanDiretect(iCellX, iCellY, (bUpPriority = !bUpPriority, bUpPriority ? KeyDirectUp : KeyDirectDown))
			) 
		{
			dir = bUpPriority ? KeyDirectUp : KeyDirectDown;
			return true;
		}
	}
	
	if (dir == KeyDirectUp || dir == KeyDirectDown) 
	{
		if (CanDiretect(iCellX, iCellY, bRightPriority ? KeyDirectRight : KeyDirectLeft) ||
			CanDiretect(iCellX, iCellY, (bRightPriority = !bRightPriority, bRightPriority ? KeyDirectRight : KeyDirectLeft))
			) 
		{
			dir = bRightPriority ? KeyDirectRight : KeyDirectLeft;
			return true;
		}
	}
	
	return false;
}

bool DirectKey::CanDiretect(int iCellX, int iCellY, KeyDirect dir)
{
	switch (dir) 
	{
		case KeyDirectLeft:
			iCellX--;
			break;
		case KeyDirectRight:
			iCellX++;
			break;
		case KeyDirectUp:
			iCellY--;
			break;
		case KeyDirectDown:
			iCellY++;
			break;
		default: return false;
	}	
	
	return CheckCell(iCellX, iCellY);
}

bool DirectKey::GetPosList(dk_vec_pos& vpos)
{
	if (m_dequeDir.empty()) 
	{
		return false;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	CGPoint pos = player.GetWorldPos();
	
	int iCellX = (int)pos.x-DISPLAY_POS_X_OFFSET,
		iCellY = (int)pos.y-DISPLAY_POS_Y_OFFSET;
		
	if( !(iCellX % 16 == 0 && iCellY % 16 == 0) )
	{
		return false;
	}
	
	iCellX /= 16; iCellY /= 16;
	
	for_vec(m_dequeDir, deque_dir_it)
	{
		KeyDirect dir = *it;
		
		if (!NextDir(iCellX, iCellY, dir)) continue;
		
		int tmpX = iCellX, tmpY = iCellY;
		
		switch (dir) 
		{
			case KeyDirectLeft:
				tmpX--;
				break;
			case KeyDirectRight:
				tmpX++;
				break;
			case KeyDirectUp:
				tmpY--;
				break;
			case KeyDirectDown:
				tmpY++;
				break;
			default:
				continue;
				break;
		}
		
		if (CheckCell(tmpX, tmpY)) 
		{
			vpos.push_back(ccp(tmpX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, tmpY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
			
			//iCellX = tmpX; iCellY = tmpY;
			
			m_dequeDir.erase(m_dequeDir.begin(), it);
			
			break;
		}
	}
	
	return !vpos.empty();
}

void DirectKey::ClearPosList()
{
	//m_dequeDir.clear();
}

void DirectKey::ReverseShrinkState()
{
	s_shink = !s_shink;

	SetVisible(!s_shink);
	
	if (m_btnShrink)
	{
		m_btnShrink->SetImage(s_shink ? m_picCenterShrink : m_picCenterNormal);
	}
	
	/*
	if (m_btnLeft) 
	{
		bool state = m_btnLeft->EventEnabled();
		
		m_btnLeft->EnableEvent(!state);
		
		m_btnLeft->SetVisible(!state);
		
		SetBackgroundImage(!state ? m_picNormal : NULL);
		
		s_shink = state;
		
		
		SetVisible(!state);
	}
	
	if (m_btnRight) 
	{
		bool state = m_btnRight->EventEnabled();
		
		m_btnRight->EnableEvent(!state);
		
		m_btnRight->SetVisible(!state);
	}
	
	if (m_btnUp) 
	{
		bool state = m_btnUp->EventEnabled();
		
		m_btnUp->EnableEvent(!state);
		
		m_btnUp->SetVisible(!state);
	}
	
	if (m_btnDown) 
	{
		bool state = m_btnDown->EventEnabled();
		
		m_btnDown->EnableEvent(!state);
		
		m_btnDown->SetVisible(!state);
	}
	*/
}

void DirectKey::RefreshPosition(CGPoint pos)
{
	CGRect rect = GetFrameRect();
	
	rect.origin.x = pos.x-rect.size.width/2;
	
	rect.origin.y = pos.y-rect.size.height/2;
	
	SetFrameRect(rect);
	
	s_Rect = rect;
	
	if (m_btnLayer) 
	{
		CGRect scrRect = GetScreenRect();
		
		CGRect btnRect = m_btnLayer->GetFrameRect();
		
		btnRect.origin.x = scrRect.origin.x+(DIRECTKEY_W-DIRECTKEY_DRAG_W)/2;
		
		btnRect.origin.y = scrRect.origin.y+(DIRECTKEY_H-DIRECTKEY_DRAG_H)/2;
		
		m_btnLayer->SetFrameRect(btnRect);
	}
}

void DirectKey::ShowFinish(NDScene* scene)
{
	if (!m_btnShrink) return;
	
	if (!scene) return;
	
	if (!m_btnLayer)
	{
		m_btnLayer = new NDUIDirectKeyTop;
		m_btnLayer->Initialization(this);
		m_btnLayer->SetBackgroundColor(ccc4(255, 255, 255, 0));
		m_btnLayer->SetDelegate(this);
		SetDelegate(m_btnLayer);
	} 
	
	if (m_btnLayer->GetParent()) 
	{
		m_btnLayer->RemoveFromParent(false);
	}
	
	CGPoint origin = GetScreenRect().origin;
	
	CGRect rect = m_btnShrink->GetFrameRect();
	
	rect.origin = ccpAdd(origin, rect.origin);
	
	m_btnLayer->SetFrameRect(rect);
	
	scene->AddChild(m_btnLayer, DIRECT_KEY_TOP_Z);
	
	rect.origin = CGPointZero;
	
	m_btnShrink->SetFrameRect(rect);
	
	if (m_btnShrink->GetParent() != m_btnLayer)
	{
		m_btnShrink->RemoveFromParent(false);
		m_btnLayer->AddChild(m_btnShrink);
	}
	
	m_addShrink = true;
	
	s_shink = !s_shink;
	
	ReverseShrinkState();
}

void DirectKey::OnBattleBegin()
{
//	if (m_btnLayer)
//		m_btnLayer->SetVisible(false);
		
	OnTouchUp();
}

void DirectKey::OnBattleEnd()
{
//	if (m_btnLayer)
//		m_btnLayer->SetVisible(true);
}

bool DirectKey::TouchBegin(NDTouch* touch)
{
	if (NDUILayer::TouchBegin(touch))
	{
		KeyDirect direct = GetPointAtDirect(touch->GetLocation());
		if (direct != KeyDirectNone)
		{
			OnTouchDown(direct);
		}
		
		return true;
	}
	
	return false;
}

bool DirectKey::TouchMoved(NDTouch* touch)
{
	if ( m_touchDown )
	{
		KeyDirect direct = GetPointAtDirect(touch->GetLocation());
		
		if (direct == KeyDirectNone)
		{	
			OnTouchUp();
		}
		else if (direct != m_keyDirect)
		{
			m_keyDirect = direct;
			
			m_dequeDir.clear();
			
			UpdateDownPicture();
			
			DealKey(m_keyDirect);
		}
	}
	
	return NDUILayer::TouchMoved(touch);
}


bool DirectKey::TouchEnd(NDTouch* touch)
{
	if (m_touchDown)
	{
		OnTouchUp();
	}
	
	return NDUILayer::TouchEnd(touch);
}

DirectKey::KeyDirect DirectKey::GetPointAtDirect(CGPoint pos)
{
	CGRect scrRect = GetScreenRect();
	
	KeyDirect direct = KeyDirectNone;
	
	if (!CGRectContainsPoint(scrRect, pos))
		return direct;
		
	CGPoint posInRect = ccpSub(pos, scrRect.origin);
	
	CGSize sizeRect = scrRect.size;
	
	if (posInRect.y < sizeRect.height / 2)
	{ // left up right
		if (posInRect.x < sizeRect.width / 2)
		{ // left up
			if (posInRect.x > posInRect.y)
				direct = KeyDirectUp;
			else
				direct = KeyDirectLeft;
		}
		else
		{ // up right
			if (posInRect.x - sizeRect.width / 2 > sizeRect.height / 2 - posInRect.y)
				direct = KeyDirectRight;
			else
				direct = KeyDirectUp;
		}
	}
	else
	{ // left down right
		if (posInRect.x < sizeRect.width / 2)
		{ // left down
			if (posInRect.x > sizeRect.height - posInRect.y)
				direct = KeyDirectDown;
			else
				direct = KeyDirectLeft;
		}
		else
		{ // down right
			if (posInRect.x - sizeRect.width / 2 > posInRect.y - sizeRect.height / 2)
				direct = KeyDirectRight;
			else
				direct = KeyDirectDown;
		}
	}
	
	return direct;
}

void DirectKey::UpdateDownPicture()
{
	PictureRotation rota = PictureRotation0;
	
	if (m_keyDirect == KeyDirectLeft) 
	{
		rota = PictureRotation270;
	}
	else if (m_keyDirect == KeyDirectRight)
	{
		rota = PictureRotation90;
	}
	else if (m_keyDirect == KeyDirectUp)
	{
	}
	else if (m_keyDirect == KeyDirectDown)
	{
		rota = PictureRotation180;
	}
	
	if (m_picDown) 
	{
		m_picDown->Rotation(rota);
		
		SetBackgroundImage(m_picDown);
	}
}
