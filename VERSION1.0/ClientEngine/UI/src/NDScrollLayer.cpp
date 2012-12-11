/*
 *  NDScrollLayer.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-15.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDScrollLayer.h"
#include "NDDirector.h"
//#include "NDUtil.h"
#include "NDPath.h"

float ACCER_FIRST = -100.0f;

float POSI_UP_SPEED_MIN = 10.0f;
float NEGA_UP_SPEED_MIN = -10.0f;
float POSI_UP_SPEED_MAX = 1000.0f;
float NEGA_UP_SPEED_MAX = -1000.0f;

IMPLEMENT_CLASS(NDScrollLayer, NDUILayer)

NDScrollLayer::NDScrollLayer()
{
	m_bHorizontal = false;

	ResetMoveData();
}

NDScrollLayer::~NDScrollLayer()
{
}

void NDScrollLayer::Initialization()
{
	NDUILayer::Initialization();

	this->SetDelegate(this);

	this->SetScrollEnabled(true);
}

//void NDScrollLayer::SetScrollHorizontal(bool bHorizontal)
//{
//	m_bHorizontal = bHorizontal;
//}

void NDScrollLayer::draw()
{
	if (!this->IsVisibled())
		return;

	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);

	NDUILayer::draw();

	if (this->m_nState > STATE_BEGIN && m_nState < STATE_END)
	{
		if (IsScrollHorizontal())
		{
			if (m_bHEmpty)
			{
				SwitchStateTo (STATE_STOP);
			}

			float fHDis = GetHMoveDistance();
			if (fHDis < 0.5f && fHDis > -0.5f)
			{
				SwitchStateTo (STATE_STOP);
			}

			if (!refreshHorizonal(fHDis))
			{
				SwitchStateTo (STATE_STOP);
			}
		}
		else
		{
			if (m_bVEmpty)
			{
				SwitchStateTo (STATE_STOP);
			}

			float fVDis = GetVMoveDistance();
			if (fVDis < 0.5f && fVDis > -0.5f)
			{
				SwitchStateTo (STATE_STOP);
			}
			if (!refresh(fVDis))
			{
				SwitchStateTo (STATE_STOP);
			}
		}
	}
}

bool NDScrollLayer::TouchBegin(NDTouch* touch)
{
	if (!this->IsVisibled()) return false;

	if (NDUILayer::TouchBegin(touch))
	{
		ResetMove();

		return true;
	}

	return false;
}

bool NDScrollLayer::TouchEnd(NDTouch* touch)
{
	if (!this->IsVisibled()) return false;

	bool bRet = NDUILayer::TouchEnd(touch);

	m_bUp = true;

	return bRet;
}

bool NDScrollLayer::OnLayerMove(NDUILayer* uiLayer, UILayerMove move,
		float distance)
{
	bool bVertical = false;
	bool bHorizontal = false;

	switch (move)
	{
	case UILayerMoveUp:
		distance = -distance;
		bVertical = true;
		break;
	case UILayerMoveDown:
		bVertical = true;
		break;
	case UILayerMoveLeft:
		distance = -distance;
		bHorizontal = true;
		break;
	case UILayerMoveRight:
		bHorizontal = true;
		break;
	default:
		break;
	}

	if (!bVertical && !bHorizontal)
		return false;

	MoveInfo info(m_kMoveTouch, clock());
	PushMove(info, bHorizontal);

	if (bVertical)
	{
		refresh(distance);
	}
	else
	{
		refreshHorizonal(distance);
	}

	if (m_bUp)
	{
		SwitchStateTo (STATE_FIRST);
	}

	return true;
}

bool NDScrollLayer::DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch)
{
	if (NDUILayer::DispatchTouchEndEvent(beginTouch, endTouch))
		return true;

	NDScrollLayerDelegate *delegate =
			dynamic_cast<NDScrollLayerDelegate *>(this->GetDelegate());

	if (delegate)
		delegate->OnClickNDScrollLayer(this);

	return true;
}

void NDScrollLayer::ResetMoveData()
{
	m_nState = STATE_STOP;
	m_uiHCurMoveIndex = 0;
	m_uiHFirstMoveIndex = 0;
	m_uiVCurMoveIndex = 0;
	m_uiVFirstMoveIndex = 0;
	m_clockHt0 = 0.0f;
	m_clockVt0 = 0.0f;
	m_fHv0 = 0.0f;
	m_fVv0 = 0.0f;
	m_fHOldS = 0.0f;
	m_fVOldS = 0.0f;
	m_bHEmpty = true;
	m_bVEmpty = true;
	m_bUp = false;
}

void NDScrollLayer::ResetMove()
{
	ResetMoveData();

	//MoveInfo info(m_beginTouch, clock());
	//PushMove(info, true);
	//PushMove(info, false);
}

void NDScrollLayer::SwitchStateTo(int nToState)
{
	if (nToState < STATE_BEGIN || nToState >= STATE_END)
	{
		return;
	}

	m_nState = nToState;

	switch (nToState)
	{
	case STATE_STOP:
		break;
	case STATE_FIRST:
		SetMoveV();
		break;
	case STATE_SECOND:
		break;
	case STATE_THREE:
		break;
	default:
		break;

	}
}

void NDScrollLayer::SetHMoveSpeed()
{
	if (m_bHEmpty)
	{
		return;
	}

	unsigned int size = 0;
	if (m_uiHCurMoveIndex > m_uiHFirstMoveIndex)
	{
		size = m_uiHCurMoveIndex - m_uiHFirstMoveIndex;
	}
	else
	{
		size = m_uiHCurMoveIndex + MAX_MOVES - m_uiHFirstMoveIndex;
	}
	size = size > MAX_MOVES ? MAX_MOVES : size;

	float fSum = 0.0f;
	unsigned int uiTotal = 0;

	for (unsigned int i = 0; i < size - 1; i++)
	{
		unsigned int firstindex = (m_uiHFirstMoveIndex + i) % MAX_MOVES;
		unsigned int secondindex = (firstindex + 1) % MAX_MOVES;

		float dispass = m_HMoves[secondindex].pos.x
				- m_HMoves[firstindex].pos.x;
		clock_t clockpass = ClockTimeMinus(m_HMoves[secondindex].time,
				m_HMoves[firstindex].time);
		if (clockpass != 0)
		{
			fSum += dispass / clockpass * 1000000.0f;
			uiTotal++;
		}
	}

	if (uiTotal == 0)
	{
		m_bHEmpty = true;
		return;
	}

	this->m_fHv0 = fSum / uiTotal;
	if ((this->m_fHv0 < POSI_UP_SPEED_MIN)
			&& (this->m_fHv0 > NEGA_UP_SPEED_MIN))
	{
		m_bHEmpty = true;
		return;
	}
	if (m_fHv0 > POSI_UP_SPEED_MAX)
	{
		m_fHv0 = POSI_UP_SPEED_MAX;
	}
	else if (m_fHv0 < NEGA_UP_SPEED_MAX)
	{
		m_fHv0 = NEGA_UP_SPEED_MAX;
	}

	m_clockHt0 = clock();
}

void NDScrollLayer::SetVMoveSpeed()
{
	if (m_bVEmpty)
	{
		return;
	}

	unsigned int size = 0;
	if (m_uiVCurMoveIndex > m_uiVFirstMoveIndex)
	{
		size = m_uiVCurMoveIndex - m_uiVFirstMoveIndex;
	}
	else
	{
		size = m_uiVCurMoveIndex + MAX_MOVES - m_uiVFirstMoveIndex;
	}
	size = size > MAX_MOVES ? MAX_MOVES : size;

	double fSum = 0.0f;
	unsigned int uiTotal = 0;
	for (unsigned int i = 0; i < size - 1; i++)
	{
		unsigned int firstindex = (m_uiVFirstMoveIndex + i) % MAX_MOVES;
		unsigned int secondindex = (firstindex + 1) % MAX_MOVES;

		double dispass = m_VMoves[secondindex].pos.y
				- m_VMoves[firstindex].pos.y;
		clock_t clockpass = ClockTimeMinus(m_VMoves[secondindex].time,
				m_VMoves[firstindex].time);
		if (clockpass != 0)
		{
			fSum += dispass / clockpass * 1000000.0f;
			uiTotal++;
		}
	}

	if (uiTotal == 0)
	{
		m_bVEmpty = true;
		return;
	}

	this->m_fVv0 = fSum / uiTotal;
	if ((this->m_fVv0 < POSI_UP_SPEED_MIN)
			&& (this->m_fVv0 > NEGA_UP_SPEED_MIN))
	{
		m_bVEmpty = true;
		return;
	}
	if (m_fVv0 > POSI_UP_SPEED_MAX)
	{
		m_fVv0 = POSI_UP_SPEED_MAX;
	}
	else if (m_fVv0 < NEGA_UP_SPEED_MAX)
	{
		m_fVv0 = NEGA_UP_SPEED_MAX;
	}

	m_clockVt0 = clock();
}

void NDScrollLayer::SetMoveV()
{
	SetHMoveSpeed();
	SetVMoveSpeed();
}

float NDScrollLayer::GetHMoveDistance()
{
	if (m_bHEmpty)
	{
		return 0.0f;
	}

	double clockpass = (ClockTimeMinus(clock(), m_clockHt0)) / 1000000.0f;

	float fAccer = ACCER_FIRST;

	if (m_fHv0 < 0.0f)
	{
		fAccer = -fAccer;
	}

	if (this->m_fHv0 < 0.0f)
	{
		if (-fAccer * clockpass < this->m_fHv0)
		{
			clockpass = -this->m_fHv0 / fAccer;
			//return 0.0f;
		}
	}
	else
	{
		if (-fAccer * clockpass > this->m_fHv0)
		{
			clockpass = -this->m_fHv0 / fAccer;
			//return 0.0f;
		}
	}

	double s = m_fHv0 * clockpass + fAccer * (clockpass * clockpass) / 2.0f;
	float fRet = s - m_fHOldS;
	m_fHOldS = s;
	return fRet;
}

float NDScrollLayer::GetVMoveDistance()
{
	if (m_bVEmpty)
	{
		return 0.0f;
	}

	double clockpass = (ClockTimeMinus(clock(), m_clockVt0)) / 1000000.0f;

	float fAccer = ACCER_FIRST;

	if (m_fVv0 < 0.0f)
	{
		fAccer = -fAccer;
	}

	if (this->m_fVv0 < 0.0f)
	{
		if (-fAccer * clockpass < this->m_fVv0)
		{
			//clockpass = -this->m_fVv0 / fAccer;
			return 0.0f;
		}
	}
	else
	{
		if (-fAccer * clockpass > this->m_fVv0)
		{
			//clockpass = -this->m_fVv0 / fAccer;
			return 0.0f;
		}
	}

	double s = this->m_fVv0 * clockpass
			+ fAccer * (clockpass * clockpass) / 2.0f;
	float fRet = s - m_fVOldS;
	m_fVOldS = s;
	return fRet;
}

void NDScrollLayer::PushMove(MoveInfo& move, bool bHorizontal)
{
	if (bHorizontal)
	{
		if (m_uiHCurMoveIndex == m_uiHFirstMoveIndex && !m_bHEmpty)
		{
			m_uiHFirstMoveIndex = ++m_uiHFirstMoveIndex % MAX_MOVES;
		}

		m_HMoves[m_uiHCurMoveIndex] = move;
		m_uiHCurMoveIndex = ++m_uiHCurMoveIndex % MAX_MOVES;

		m_bHEmpty = false;
	}
	else
	{
		if (m_uiVCurMoveIndex == m_uiVFirstMoveIndex && !m_bVEmpty)
		{
			m_uiVFirstMoveIndex = ++m_uiVFirstMoveIndex % MAX_MOVES;
		}

		m_VMoves[m_uiVCurMoveIndex].pos = move.pos;
		m_VMoves[m_uiVCurMoveIndex].time = move.time;
		m_uiVCurMoveIndex = ++m_uiVCurMoveIndex % MAX_MOVES;

		m_bVEmpty = false;
	}
}

clock_t NDScrollLayer::ClockTimeMinus(clock_t sec, clock_t fir)
{
	clock_t clockret = 0;
	if (sec < fir)
	{
		clockret = ((unsigned long long) 1 << (sizeof(clock_t) * 8)) - fir
				+ sec;
	}
	else
	{
		clockret = sec - fir;
	}
	return clockret;
}

////////////////////////////////////////////
IMPLEMENT_CLASS(NDUILabelScrollLayer, NDScrollLayer)

NDUILabelScrollLayer::NDUILabelScrollLayer()
{
	m_lbText = NULL;

	m_uiViewHeight = 0;
}

NDUILabelScrollLayer::~NDUILabelScrollLayer()
{
}

void NDUILabelScrollLayer::Initialization()
{
	NDScrollLayer::Initialization();

	SetScrollHorizontal(false);

//	m_lbText = new NDUILabel;

//	m_lbText->Initialization();

//	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);

//	this->AddChild(m_lbText);
}

//NDUILabel* NDUILabelScrollLayer::GetScrollLabel()
//{
//	return m_lbText;
//}

bool NDUILabelScrollLayer::refresh(float distance)
{
	if (m_lbText)
	{
		float height = this->GetFrameRect().size.height;

		if (m_uiViewHeight)
			height = m_uiViewHeight;

		CCRect rect = m_lbText->GetFrameRect();

		float y = rect.origin.y + distance;

		if (y > 0 || y + m_uiTextHeight < height)
			return false;

		rect.origin.y = y;

		m_lbText->SetFrameRect(rect);

		return true;
	}

	return false;
}

void NDUILabelScrollLayer::SetFrameRect(CCRect rect)
{
	NDUILayer::SetFrameRect(rect);

	if (m_lbText)
		m_lbText->SetFrameRect(
				CCRectMake(0, 0, rect.size.width, rect.size.height));
}

void NDUILabelScrollLayer::SetText(const char* text,
		unsigned int leftInterval/*=0*/, unsigned int rightInterval/*=0*/,
		unsigned int height/*=0*/,
		cocos2d::ccColor4B fontColor/* = ccc4(58, 58, 58, 255)*/)
{
	if (!text)
		return;

	SAFE_DELETE_NODE (m_lbText);

	m_uiTextHeight = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(
			text,
			this->GetFrameRect().size.width - leftInterval - rightInterval, 13);

	m_lbText = NDUITextBuilder::DefaultBuilder()->Build(text, 13,
			CCSizeMake(
					this->GetFrameRect().size.width - leftInterval
							- rightInterval, m_uiTextHeight), fontColor, false);

	m_lbText->SetFrameRect(
			CCRectMake(leftInterval, 0,
					this->GetFrameRect().size.width - leftInterval
							- rightInterval, m_uiTextHeight));

	this->AddChild(m_lbText);
	m_lbText->SetVisible(this->IsVisibled());

	m_uiViewHeight = height;
}

void NDUILabelScrollLayer::draw()
{
	if (!this->IsVisibled())
		return;

	CCRect scrRect = this->GetScreenRect();

	if (m_uiViewHeight)
		scrRect.size.height = m_uiViewHeight;

	NDDirector::DefaultDirector()->SetViewRect(scrRect, this);

	NDUILayer::draw();
}

#pragma mark ÈÝÆ÷¹ö¶¯²ã

IMPLEMENT_CLASS(NDUIContainerScrollLayer, NDScrollLayer)

NDUIContainerScrollLayer::NDUIContainerScrollLayer()
{
	INIT_AUTOLINK(NDUIContainerScrollLayer);

	m_fMinY = m_fChange = m_fMaxChange = 0.0f;

	m_bVisibleScroll = true;

	m_imageScroll = NULL;
}

NDUIContainerScrollLayer::~NDUIContainerScrollLayer()
{
}

void NDUIContainerScrollLayer::Initialization()
{
	NDScrollLayer::Initialization();

	SetScrollHorizontal(false);
}

bool NDUIContainerScrollLayer::refresh(float distance)
{
	bool bRet = true;

	float tmpChange = m_fChange + distance;

	if (tmpChange < this->m_fMaxChange)
	{
		distance = this->m_fMaxChange - m_fChange;
		bRet = false;
	}
	else if (tmpChange > 0.0f)
	{
		distance = -m_fChange;
		bRet = false;
	}

	//if (tmpChange < this->m_fMaxChange || tmpChange > 0.0f) return false;

	for_vec(m_kChildrenList, std::vector<NDNode*>::iterator)
	{
		if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			continue;

		NDUINode* node = (NDUINode*) (*it);

		CCRect rect = node->GetFrameRect();

		rect.origin.y += distance;

		node->SetFrameRect(rect);
	}

	m_fChange += distance;

	if (m_bVisibleScroll && m_imageScroll && this->m_fMaxChange != 0.0f)
	{
		CCRect rect = m_imageScroll->GetFrameRect();

		if (rect.size.height > 0.0f)
		{
			rect.origin.y = tmpChange / this->m_fMaxChange
					* (this->GetFrameRect().size.height - rect.size.height);
			m_imageScroll->SetFrameRect(rect);

			NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathUINew("new_scroll.png"), 0,
					rect.size.height);

			m_imageScroll->SetPicture(pic, true);
		}
	}

	return true;
}

void NDUIContainerScrollLayer::refreshContainer(
		float defaultChangeRange/*=0.0f*/)
{
	float fMax = 0.0f;
	float fMin = this->GetFrameRect().size.height;
	for_vec(m_kChildrenList, std::vector<NDNode*>::iterator)
	{
		if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			continue;

		NDUINode* node = (NDUINode*) (*it);

		CCRect rect = node->GetFrameRect();

		if (rect.origin.y < fMin)
			fMin = rect.origin.y;

		float height = rect.origin.y + rect.size.height;

		if (height > fMax)
			fMax = height;
	}

	m_fMinY = fMin;

	float selfHeight = this->GetFrameRect().size.height;

	//if (fMax > selfHeight+m_fChange) m_fMaxChange = selfHeight+m_fChange-fMax;
	if (fMax > selfHeight)
		m_fMaxChange = selfHeight - fMax;
	else
		m_fMaxChange = 0.0f;

	if (defaultChangeRange != 0.0f)
	{
		if (defaultChangeRange > selfHeight)
			m_fMaxChange = selfHeight - defaultChangeRange;
		else
			m_fMaxChange = 0.0f;
	}

	m_fChange = 0.0f;

	if (m_bVisibleScroll && fMax > 0.0f)
	{
		m_imageScroll = new NDUIImage;

		m_imageScroll->Initialization();

		float fHeight =
				fMax < selfHeight ? 0.0f : selfHeight / fMax * selfHeight;

		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(
				NDPath::GetImgPathUINew("new_scroll.png"), 0, fHeight);

		m_imageScroll->SetPicture(pic, true);

		m_imageScroll->SetFrameRect(CCRectMake(0, 0, pic->GetSize().width, 0));

		m_imageScroll->EnableEvent(false);

		this->AddChild(m_imageScroll, 1);
		m_imageScroll->SetVisible(this->IsVisibled());

		CCRect rect = m_imageScroll->GetFrameRect();
		rect.origin.x = this->GetFrameRect().size.width - rect.size.width * 2;
		rect.origin.y = 0.0f;
		rect.size.height = fHeight;
		m_imageScroll->SetFrameRect(rect);
	}
}

void NDUIContainerScrollLayer::VisibleScroll(bool visible)
{
	m_bVisibleScroll = visible;
}

float NDUIContainerScrollLayer::GetScrollBarWidth()
{
	return 5.0f * 2;
}

void NDUIContainerScrollLayer::ScrollNodeToTop(NDUINode* node)
{
	for_vec(m_kChildrenList, std::vector<NDNode*>::iterator)
	{
		if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			continue;

		NDUINode* child = (NDUINode*) (*it);

		if (child != node)
			continue;

		CCRect rect = child->GetFrameRect();

		float change = m_fMinY - rect.origin.y;

		refresh(change);

		break;
	}
}

bool NDUIContainerScrollLayer::SetContent(const char *text,
		cocos2d::ccColor4B color/*=ccc4(0, 0, 0, 255)*/,
		unsigned int fontsize/*=12*/)
{
	this->RemoveAllChildren(true);

	if (!text)
		return false;

	int width = this->GetFrameRect().size.width;

	if (m_bVisibleScroll)
		width -= GetScrollBarWidth();

	CCSize textSize;
	textSize.width = width - 4;
	textSize.height =
			NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text,
					textSize.width, fontsize);

	NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(text, fontsize,
			textSize, color, true);
	memo->SetFrameRect(CCRectMake(2, 8, textSize.width, textSize.height));
	this->AddChild(memo);
	memo->SetVisible(this->IsVisibled());

	this->refreshContainer();

	return true;
}

//////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIContainerHScrollLayer, NDScrollLayer)

NDUIContainerHScrollLayer::NDUIContainerHScrollLayer()
{
	m_fChange = m_fMaxChange = 0.0f;
}

NDUIContainerHScrollLayer::~NDUIContainerHScrollLayer()
{
}

void NDUIContainerHScrollLayer::Initialization()
{
	NDScrollLayer::Initialization();

	SetScrollHorizontal(true);
}

bool NDUIContainerHScrollLayer::refreshHorizonal(float distance)
{
	bool bRet = true;

	float tmpChange = m_fChange + distance;

	if (tmpChange < this->m_fMaxChange)
	{
		distance = this->m_fMaxChange - m_fChange;
		bRet = false;
	}
	else if (tmpChange > 0.0f)
	{
		distance = -m_fChange;
		bRet = false;
	}

	//if (tmpChange < this->m_fMaxChange || tmpChange > 0.0f) return false;

	for_vec(m_kChildrenList, std::vector<NDNode*>::iterator)
	{
		if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			continue;

		NDUINode* node = (NDUINode*) (*it);

		CCRect rect = node->GetFrameRect();

		rect.origin.x += distance;

		node->SetFrameRect(rect);
	}

	m_fChange += distance;

	return true;
}

void NDUIContainerHScrollLayer::refreshContainer()
{
	float fMax = 0.0f;
	for_vec(m_kChildrenList, std::vector<NDNode*>::iterator)
	{
		if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			continue;

		NDUINode* node = (NDUINode*) (*it);

		CCRect rect = node->GetFrameRect();

		float width = rect.origin.x + rect.size.width;

		if (width > fMax)
			fMax = width;
	}

	float selfWidth = this->GetFrameRect().size.width;

	//if (fMax > selfHeight+m_fChange) m_fMaxChange = selfHeight+m_fChange-fMax;
	if (fMax > selfWidth)
		m_fMaxChange = selfWidth - fMax;
	else
		m_fMaxChange = 0.0f;

	m_fChange = 0.0f;
}

