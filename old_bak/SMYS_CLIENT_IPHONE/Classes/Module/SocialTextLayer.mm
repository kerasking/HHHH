/*
 *  SocialTextLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SocialTextLayer.h"
#include "NDUILayer.h"

IMPLEMENT_CLASS(SocialTextLayer, NDUINode)

SocialTextLayer::SocialTextLayer()
{
	m_socialElement = NULL;
	m_roundRectFrame = NULL;
	
	m_clrFocus = INTCOLORTOCCC4(0xFFDA24);
	m_clrBackground = ccc4(0, 0, 0, 0);
}

SocialTextLayer::~SocialTextLayer()
{
	
}

void SocialTextLayer::Initialization(CGRect rectRoundRect, CGRect rectCol, SocialElement* socialEle)
{
	NDUINode::Initialization();
	
	this->m_roundRectFrame = new NDUICircleRect;
	m_roundRectFrame->Initialization();
	m_roundRectFrame->SetRadius(5);
	m_roundRectFrame->SetFrameRect(rectRoundRect);

	this->AddChild(m_roundRectFrame);
	
	this->m_socialElement = socialEle;
	
	// 根据元素判断显示2列还是3列
	int col = 0;
	string text1 = socialEle->m_text1;
	if (!text1.empty()) {
		col++;
	}
	string text2 = socialEle->m_text2;
	if (!text2.empty()) {
		col++;
	}
	string text3 = socialEle->m_text3;
	if (!text3.empty()) {
		col++;
	}
	
	bool bOnline = (socialEle->m_state == ES_ONLINE);
	
	rectCol = CGRectMake(rectCol.origin.x, rectCol.origin.y + 3, rectCol.size.width, rectCol.size.height);
	
	switch (col) {
		case 1: // 1列
		{
			NDUILabel* lbText1 = new NDUILabel;
			lbText1->Initialization();
			lbText1->SetText(text1.c_str());
			if (bOnline) {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x777777));
			}

			lbText1->SetTextAlignment(LabelTextAlignmentCenter);
			lbText1->SetFrameRect(rectCol);
			
			this->AddChild(lbText1);
		}
			break;
		case 2: // 2列
		{
			NDUILabel* lbText1 = new NDUILabel;
			lbText1->Initialization();
			lbText1->SetText(text1.c_str());
			if (bOnline) {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x777777));
			}
			
			lbText1->SetTextAlignment(LabelTextAlignmentLeft);
			lbText1->SetFrameRect(rectCol);
			
			this->AddChild(lbText1);
			
			NDUILabel* lbText2 = new NDUILabel;
			lbText2->Initialization();
			lbText2->SetText(text2.c_str());
			if (bOnline) {
				lbText2->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText2->SetFontColor(INTCOLORTOCCC4(0x777777));
			}
			
			lbText2->SetTextAlignment(LabelTextAlignmentRight);
			lbText2->SetFrameRect(rectCol);
			
			this->AddChild(lbText2);
		}
			break;
		case 3: // 3列
		{
			NDUILabel* lbText1 = new NDUILabel;
			lbText1->Initialization();
			lbText1->SetText(text1.c_str());
			if (bOnline) {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText1->SetFontColor(INTCOLORTOCCC4(0x777777));
			}
			
			lbText1->SetTextAlignment(LabelTextAlignmentLeft);
			lbText1->SetFrameRect(rectCol);
			
			this->AddChild(lbText1);
			
			NDUILabel* lbText2 = new NDUILabel;
			lbText2->Initialization();
			lbText2->SetText(text2.c_str());
			if (bOnline) {
				lbText2->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText2->SetFontColor(INTCOLORTOCCC4(0x777777));
			}
			
			lbText2->SetTextAlignment(LabelTextAlignmentCenter);
			lbText2->SetFrameRect(rectCol);
			
			this->AddChild(lbText2);
			
			NDUILabel* lbText3 = new NDUILabel;
			lbText3->Initialization();
			lbText3->SetText(text3.c_str());
			if (bOnline) {
				lbText3->SetFontColor(INTCOLORTOCCC4(0x862700));
			} else {
				lbText3->SetFontColor(INTCOLORTOCCC4(0x777777));
			}
			
			lbText3->SetTextAlignment(LabelTextAlignmentRight);
			lbText3->SetFrameRect(rectCol);
			
			this->AddChild(lbText3);
		}
			break;

		default:
			break;
	}
}

void SocialTextLayer::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	m_roundRectFrame->SetFrameRect(CGRectMake(0.0f, 0.0f, this->GetFrameRect().size.width, this->GetFrameRect().size.height));
}

void SocialTextLayer::draw()
{
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) {
		NDUILayer* uiLayer = (NDUILayer*)parentNode;
		if (uiLayer->GetFocus() == this) { // 当前处于焦点,绘制焦点色
			this->m_roundRectFrame->SetFillColor(this->m_clrFocus);
		} else {
			this->m_roundRectFrame->SetFillColor(this->m_clrBackground);
		}
	}
	
	NDUINode::draw();
}