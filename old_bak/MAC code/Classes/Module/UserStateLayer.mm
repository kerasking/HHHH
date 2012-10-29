/*
 *  UserStateLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "UserStateLayer.h"
#include "NDUtility.h"
#include "UserStateUILayer.h"

PosText::PosText(int idPosText, int dir, int posX, int posY, int showSec, int clrIndex, int num, string& str, int clrBackIndex/*=-1*/)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_bShowBackColor = false;
	
	ccColor4B color;
	if (clrBackIndex != -1 && this->pharsePosTextColor(clrBackIndex, color))
	{
		m_bShowBackColor = true;
		m_clrBack = color;
	}
	
	m_id = idPosText;
	m_dir = dir;
	m_posX = posX*(winsize.width)/100;
	m_posY = posY*(winsize.height)/100;
	m_showSec = showSec;
	
	this->pharsePosTextColor(clrIndex, m_clr);
	
	m_num = num;
	m_str = str;
	
	m_bConstant = showSec == 0;
}

PosText::~PosText()
{
}

bool PosText::OnTimer()
{
	if (m_bConstant) {
		return false;
	}
	return --m_showSec < 0;
}

bool PosText::pharsePosTextColor(int clrIndex, ccColor4B& color)
{
	ccColor4B clr = ccc4(0, 0, 0, 255);
	
	color = clr;
	
	switch (clrIndex) {
		case 0:
			break;
		case 1:
			clr = INTCOLORTOCCC4(0xffffff);
			break;
		case 2:
			clr = INTCOLORTOCCC4(0xff0000);
			break;
		case 3:
			clr = INTCOLORTOCCC4(0xe5872a);
			break;
		case 4:
			clr = INTCOLORTOCCC4(0xffff00);
			break;
		case 5:
			clr = INTCOLORTOCCC4(0x00ff00);
			break;
		case 6:
			clr = INTCOLORTOCCC4(0x0099ff);
			break;
		case 7:
			clr = INTCOLORTOCCC4(0x0000ff);
			break;
		case 8:
			clr = INTCOLORTOCCC4(0x0032cd);
			break;
		default:
			return false;
	}
	
	color = clr;
	
	return true;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(UserStateLayer, NDLayer)

UserStateLayer::UserStateLayer()
{
}

UserStateLayer::~UserStateLayer()
{
}

void UserStateLayer::Initialization()
{
	NDLayer::Initialization();
	MAP_USER_STATE& mapUserState = UserStateUILayer::getAllUserState();
	for (MAP_USER_STATE_IT it = mapUserState.begin(); it != mapUserState.end(); it++) {
		NDUILabel* lb = new NDUILabel;
		lb->Initialization();
		string str = it->second->shortTip; //UserStateUILayer::getStateShowStr(*(it->second));
		lb->SetText(str.c_str());
		lb->SetFontColor(ccc4(0, 255, 0, 255));
		CGSize size = getStringSize(str.c_str(), 15);
		lb->SetFrameRect(CGRectMake(0.0f, 0.0f, size.width, size.height));
		this->m_mapLabel[it->first] = lb;
		this->AddChild(lb);
	}
	
	MAP_POS_TEXT& mapPosText = GameScene::GetAllPosText();
	for (MAP_POS_TEXT_IT itPosText = mapPosText.begin(); itPosText != mapPosText.end(); itPosText++) {
		this->AddPosText(itPosText->second);
	}
}

void UserStateLayer::AddPosText(PosText* pt)
{
	if (!pt) {
		return;
	}
	
	const unsigned int fontsize = 15; 
	
	this->RemovePosText(pt);
	
	NSString* strShow = nil;
	if (pt->m_num == 99999999)
	{
		strShow = [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String:pt->m_str.c_str()]];
	}
	else
	{
		strShow = [NSString stringWithFormat:@"%@%d", [NSString stringWithUTF8String:pt->m_str.c_str()], pt->m_num];
	}
	
	
	vector<NDUILayer*>& vLabels = m_mapPosTextLabel[pt->m_id];
	
	if (pt->m_dir == 0) { // 横
		CGSize size = getStringSize([strShow UTF8String], fontsize);
		NDUILayer* backLayer = new NDUILayer;
		backLayer->Initialization();
		backLayer->SetFrameRect(CGRectMake(pt->m_posX, pt->m_posY, size.width, size.height));
		backLayer->SetTouchEnabled(false);
		this->AddChild(backLayer);
		if (pt->m_bShowBackColor)
		{
			backLayer->SetBackgroundColor(pt->m_clrBack);
		}
		
		NDUILabel* lb = new NDUILabel;
		lb->Initialization();
		lb->SetFontSize(fontsize);
		lb->SetFontColor(pt->m_clr);
		lb->SetText([strShow UTF8String]);
		lb->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
		vLabels.push_back(backLayer);
		backLayer->AddChild(lb);
	} else if (pt->m_dir == 1) { // 纵
		GLfloat fStartY = 0;
		
		CGSize sizeMax = CGSizeZero;
		for (NSUInteger i = 0; i < [strShow length]; i++) {
			NSString* character = [strShow substringWithRange:NSMakeRange(i, 1)];
			CGSize size = getStringSize([character UTF8String], fontsize);
			if (size.width > sizeMax.width)
			{
				sizeMax.width = size.width;
			}
			if (size.height > sizeMax.height)
			{
				sizeMax.height = size.height;
			}
		}
		
		NDUILayer* backLayer = new NDUILayer;
		backLayer->Initialization();
		backLayer->SetFrameRect(CGRectMake(pt->m_posX, pt->m_posY, sizeMax.width, sizeMax.height));
		backLayer->SetTouchEnabled(false);
		this->AddChild(backLayer);
		vLabels.push_back(backLayer);
		if (pt->m_bShowBackColor)
		{
			backLayer->SetBackgroundColor(pt->m_clrBack);
		}
		
		for (NSUInteger i = 0; i < [strShow length]; i++) {
			NSString* character = [strShow substringWithRange:NSMakeRange(i, 1)];
			NDUILabel* lb = new NDUILabel;
			lb->Initialization();
			lb->SetFontSize(fontsize);
			lb->SetFontColor(pt->m_clr);
			lb->SetText([character UTF8String]);
			CGSize size = getStringSize([character UTF8String], fontsize);
			lb->SetFrameRect(CGRectMake(0, fStartY, size.width, size.height));
			backLayer->AddChild(lb);
			fStartY += size.height;
		}
	}
}

void UserStateLayer::RemovePosText(PosText* pt)
{
	if (pt) {
		MAP_POS_TEXT_LABEL_IT it = m_mapPosTextLabel.find(pt->m_id);
		if (it != m_mapPosTextLabel.end()) {
			vector<NDUILayer*>& vLabels = it->second;
			for (vector<NDUILayer*>::iterator itLabel = vLabels.begin(); itLabel != vLabels.end(); itLabel++) {
				this->RemoveChild(*itLabel, true);
			}
			m_mapPosTextLabel.erase(it);
		}
	}
}

void UserStateLayer::AddStateLabel(int idState, string& str)
{
	if (this->m_mapLabel.count(idState) > 0) {
		return;
	}
	
	if (str.empty() || str == NDCommonCString("wu")) {
		return;
	}
	
	NDUILabel* lb = new NDUILabel;
	lb->Initialization();
	lb->SetText(str.c_str());
	lb->SetFontColor(ccc4(0, 255, 0, 255));
	CGSize size = getStringSize(str.c_str(), 15);
	lb->SetFrameRect(CGRectMake(0.0f, 0.0f, size.width, size.height));
	this->m_mapLabel[idState] = lb;
	this->AddChild(lb);
}

void UserStateLayer::RemoveStateLabel(int idState)
{
	MAP_STATE_LABEL_IT it = this->m_mapLabel.find(idState);
	if (it != m_mapLabel.end()) {
		this->RemoveChild(it->second, true);
		m_mapLabel.erase(it);
	}
}

void UserStateLayer::draw()
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	int showX = 3;
	int showY = 57;
	int rowCount = 1;
	for (MAP_STATE_LABEL_IT it = m_mapLabel.begin(); it != m_mapLabel.end(); it++) {
		CGRect rect = it->second->GetFrameRect();
		
		if (showX + rect.size.width > 56) {
			showX = 3;
			showY += rect.size.height + 3;
			rowCount++;
		}
		
		if (rowCount > 10) {
			it->second->SetFrameRect(CGRectZero);
		} else {
			rect.origin.x = showX;
			rect.origin.y = showY;
			it->second->SetFrameRect(rect);
			showX += rect.size.width + 6;
		}
	}
	
	NDLayer::draw();
}