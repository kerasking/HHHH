/*
 *  StatusDialog.mm
 *  DragonDrive
 *
 *  Created by wq on 11-5-6.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "StatusDialog.h"
#include "NDDirector.h"
#include "Fighter.h"
#include "NDUtility.h"
#include "CCPointExtension.h"
//#include "SocialTextLayer.h"
#include "BattleMgr.h"
#include "Battle.h"
#include <sstream>
#include "NDPath.h"
#include "NDUIBaseGraphics.h"

const float DIALOG_WIDTH = 200.0f;
const float MAX_DIALOG_HEIGHT = 220.0f;

using namespace std;

IMPLEMENT_CLASS(StatusDialog, NDUILayer)

StatusDialog::StatusDialog()
{
	std::string bottomImage = NDPath::GetImgPath("bottom.png");
	m_picLeftTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage);
	m_picLeftTop->SetReverse(true);
	m_picLeftTop->Rotation(PictureRotation180);
	
	m_picRightTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage);
	m_picRightTop->Rotation(PictureRotation180);
	
	m_picLeftBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage);
	
	m_picRightBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage);
	m_picRightBottom->SetReverse(true);
	
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	scrRect = CCRectMake((winSize.width - DIALOG_WIDTH) / 2, 
			     (winSize.height - MAX_DIALOG_HEIGHT) / 2, 
			     DIALOG_WIDTH, MAX_DIALOG_HEIGHT);
	
	m_label = NULL;
	m_memo = NULL;
	m_table = NULL;
	//m_talkBox = NULL;
}

StatusDialog::~StatusDialog()
{
	this->releaseElement();
	delete m_picLeftTop;
	delete m_picRightTop;
	delete m_picLeftBottom;
	delete m_picRightBottom;
}

void StatusDialog::releaseElement()
{
	//for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
	//	SAFE_DELETE(*it);
	//}
	//m_vElement.clear();
}

void StatusDialog::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	//if (!m_talkBox) {
	//	m_talkBox = new TalkBox;
	//	m_talkBox->Initialization();
	//	m_talkBox->SetFix();
	//	this->AddChild(m_talkBox);
	//}
	
	CCRect screen = cell->GetScreenRect();
	screen.origin.x += screen.size.width - 10;
	screen.origin.y += 10;
	//m_talkBox->SetDisPlayPos(screen.origin);
	
//	VEC_FIGHTER_STATUS& vStatus = m_fighter->getFighterStatus();
//	FighterStatus fs = vStatus.at(cellIndex);
//	m_talkBox->addTalkMsg(fs->m_des, 360);
}

void StatusDialog::Initialization(Fighter* f)
{
	NDUILayer::Initialization();
	
	m_fighter = f;
	
	stringstream ssTitle;
	ssTitle << f->GetRole()->m_strName << "("
	<< f->GetRole()->m_nLevel << NDCommonCString("Ji") << ")";
	
	if(f->m_kInfo.fighterType==Fighter_TYPE_RARE_MONSTER){
		ssTitle << "¡¾" << NDCommonCString("xiyou") << "¡¿";
	}
	
	int nHeight = 5;
	
	m_label = new NDUILabel();
	m_label->Initialization();
	m_label->SetTextAlignment(LabelTextAlignmentCenter);
	m_label->SetText(ssTitle.str().c_str());
	m_label->SetFrameRect(CCRectMake(scrRect.origin.x, scrRect.origin.y + 5, DIALOG_WIDTH, 20));
	this->AddChild(m_label);
	nHeight += 20;
	
	stringstream ss;
	ss << "HP: " << f->m_kInfo.nLife << "/" << f->m_kInfo.nLifeMax
	<< "\nMP: " << f->m_kInfo.nMana << "/" << f->m_kInfo.nManaMax;
	
	m_memo = NDUITextBuilder::DefaultBuilder()->Build(ss.str().c_str(), 
							  13, 
							  CCSizeMake(DIALOG_WIDTH, 40), 
							  ccc4(0, 0, 0, 255),
							  true);

	m_memo->SetFrameRect(CCRectMake(scrRect.origin.x + 20,
		scrRect.origin.y + nHeight + 5, DIALOG_WIDTH - 40, 40));		
	this->AddChild(m_memo);
	nHeight += 45;
	
	// ÓÐÌØÊâ×´Ì¬
	VEC_FIGHTER_STATUS& vStatus = f->getFighterStatus();
	if (vStatus.size() > 0)
	{
		
		NDUILabel* lbStatus = new NDUILabel();
		lbStatus->Initialization();
		lbStatus->SetTextAlignment(LabelTextAlignmentCenter);
		lbStatus->SetText(NDCommonCString("state"));
		lbStatus->SetFrameRect(CCRectMake(scrRect.origin.x,
			scrRect.origin.y + nHeight, DIALOG_WIDTH, 20));
		this->AddChild(lbStatus);
		nHeight += 20;
		
		this->m_table = new NDUITableLayer;
		m_table->Initialization();
		m_table->SetDelegate(this);
		m_table->VisibleSectionTitles(false);
		m_table->SetBackgroundColor(ccc4(255, 255, 255, 0));
		this->AddChild(m_table);
		
		int nTableHeight = 0;
		NDDataSource* ds = new NDDataSource;
		m_table->SetDataSource(ds);
		
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		
		bool bChangeClr = false;
		FighterStatus* fs = NULL;
//		for (VEC_FIGHTER_STATUS_IT it = vStatus.begin(); it != vStatus.end(); it++) {
//			fs = it;
//			
//			SocialElement* se = new SocialElement;
//			this->m_vElement.push_back(se);
////			se->m_text1 = fs->m_name;
////			
////			int btTurn = BattleMgrObj.GetBattle()->getTurn();
////			if(fs->m_num - btTurn >= 0) {
////				stringstream ss;
////				ss << fs->m_num - btTurn << NDCommonCString("HuiHe");
////				se->m_text2 = ss.str();
////			}else{
////				se->m_text2 = NDCommonCString("yongjiu");
////			}
//			
//			SocialTextLayer* st = new SocialTextLayer;
//			st->Initialization(CCRectMake(0.0f, 0.0f, DIALOG_WIDTH - 38, 15.0f),
//					   CCRectMake(0.0f, 0.0f, DIALOG_WIDTH - 38, 15.0f), se);
//			
//			if (bChangeClr) {
//				st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
//			} else {
//				st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
//			}
//			
//			sec->AddCell(st);
//			
//			nTableHeight += 30;
//		}
		
		nTableHeight = nTableHeight > MAX_DIALOG_HEIGHT - nHeight - 5 ?
			MAX_DIALOG_HEIGHT - nHeight - 5 : nTableHeight;

		m_table->SetFrameRect(CCRectMake(scrRect.origin.x +
			20, scrRect.origin.y + nHeight + 5,
			DIALOG_WIDTH - 40, nTableHeight));
		nHeight += nTableHeight + 20;
	}
	
	if (nHeight < MAX_DIALOG_HEIGHT)
	{
		scrRect.size.height = nHeight;
	}
}

void StatusDialog::draw()
{
	NDUILayer::draw();
	
	if (this->IsVisibled())
	{
		/***
		* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
		* begin
		*/
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 2), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 2), 
// 			 ccc4(41, 65, 33, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 3), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 3), 
// 			 ccc4(57, 105, 90, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 4), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 4), 
// 			 ccc4(82, 125, 115, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 5), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 5), 
// 			 ccc4(82, 117, 82, 255), 1);
// 		
// 		//bottom frame
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 2), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 2), 
// 			 ccc4(41, 65, 33, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 3), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 3), 
// 			 ccc4(57, 105, 90, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 4), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 4), 
// 			 ccc4(82, 125, 115, 255), 1);
// 		DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 5), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 5), 
// 			 ccc4(82, 117, 82, 255), 1);
// 		
// 		//left frame
// 		DrawLine(ccp(scrRect.origin.x + 13, scrRect.origin.y + 16), 
// 			 ccp(scrRect.origin.x + 13, scrRect.origin.y + scrRect.size.height - 16), 
// 			 ccc4(115, 121, 90, 255), 8);
// 		
// 		//right frame
// 		DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + 16), 
// 			 ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + scrRect.size.height - 16), 
// 			 ccc4(115, 121, 90, 255), 8);
// 		
// 		//background
// 		DrawRecttangle(CCRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, scrRect.size.height - 10), ccc4(196, 201, 181, 255));
/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* end
*/
		
		m_picLeftTop->DrawInRect(CCRectMake(scrRect.origin.x+7, 
						    scrRect.origin.y, 
						    m_picLeftTop->GetSize().width, 
						    m_picLeftTop->GetSize().height));
		m_picRightTop->DrawInRect(CCRectMake(scrRect.origin.x + scrRect.size.width - m_picRightTop->GetSize().width - 7, 
						     scrRect.origin.y, 
						     m_picRightTop->GetSize().width, 
						     m_picRightTop->GetSize().height));
		m_picLeftBottom->DrawInRect(CCRectMake(scrRect.origin.x+7, 
						       scrRect.origin.y + scrRect.size.height - m_picLeftBottom->GetSize().height,
						       m_picLeftBottom->GetSize().width, 
						       m_picLeftBottom->GetSize().height));
		m_picRightBottom->DrawInRect(CCRectMake(scrRect.origin.x + scrRect.size.width - m_picRightBottom->GetSize().width - 7,
							scrRect.origin.y + scrRect.size.height - m_picRightBottom->GetSize().height,
							m_picRightBottom->GetSize().width,
							m_picRightBottom->GetSize().height));
	}
}

bool StatusDialog::TouchEnd(NDTouch* touch)
{
	Battle* parent = (Battle*)this->GetParent();

	if (parent) 
	{
		parent->CloseStatusDlg();
	}
	return true;
}