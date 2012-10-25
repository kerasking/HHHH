/*
 *  UIExp.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIExp.h"
#include <sstream>

using namespace cocos2d;

IMPLEMENT_CLASS(CUIExp, NDUINode)

CUIExp::CUIExp()
{
	m_picBg = NULL;
	m_picProcess = NULL;
	m_lbText = NULL;
	m_unTotal = 0;
	m_unProcess = 0;
	m_bRecacl = true;
	m_nStyle = 0;
}

CUIExp::~CUIExp()
{
	CC_SAFE_DELETE (m_picBg);
	CC_SAFE_DELETE (m_picProcess);
}

void CUIExp::Initialization(const char* bgfile, const char* processfile)
{
	NDUINode::Initialization();

	if (bgfile)
	{
		m_strBgFile = bgfile;
	}

	if (processfile)
	{
		m_strProcessFile = processfile;
	}

	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_lbText);
}

void CUIExp::SetText(const char* text)
{
	m_strText = text ? text : "";
}

void CUIExp::SetTextFontColor(ccColor4B color)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(color);
	}
}

void CUIExp::SetTextFontSize(unsigned int unSize)
{
	if (m_lbText)
	{
		m_lbText->SetFontSize(unSize);
	}
}

void CUIExp::SetProcess(unsigned int unProcess)
{
	m_unProcess = unProcess;

	m_bRecacl = true;
}

void CUIExp::SetTotal(unsigned int unTotal)
{
	m_unTotal = unTotal;

	m_bRecacl = true;
}

unsigned int CUIExp::GetProcess()
{
	return m_unProcess;
}

unsigned int CUIExp::GetTotal()
{
	return m_unTotal;
}

void CUIExp::draw()
{
	NDUINode::draw();

	if (!this->IsVisibled())
	{
		return;
	}

	CGRect kScrRect = this->GetScreenRect();

	if (m_bRecacl && !m_strProcessFile.empty())
	{
		CC_SAFE_DELETE (m_picProcess);

		if (m_unProcess <= m_unTotal && 0 != m_unTotal && 0 != m_unProcess)
		{
			float fWidth = kScrRect.size.width * m_unProcess / m_unTotal;

			if ((int) fWidth > 0)
			{
				m_picProcess = NDPicturePool::DefaultPool()->AddPicture(
						m_strProcessFile, fWidth, kScrRect.size.height);
			}
		}
	}

	if (m_bRecacl && m_lbText)
	{
		if (m_unProcess <= m_unTotal && 0 != m_unTotal)
		{
			if(m_nStyle == 0)
			{
				std::stringstream ss;
				ss << m_strText.c_str() << m_unProcess << "/" << m_unTotal;
				//tq::CString str("%s%u/%u", m_strText.c_str(), m_unProcess, m_unTotal);
				m_lbText->SetText(ss.str().c_str());
			}
			else
			{
				std::stringstream ss;
				ss << m_strText.c_str() << m_unProcess/m_unTotal << "%";
				//tq::CString str("%s%u/%u", m_strText.c_str(), m_unProcess, m_unTotal);
				m_lbText->SetText(ss.str().c_str());
			}

		}
	}

	if (m_picBg)
	{
		m_picBg->DrawInRect(kScrRect);
	}

	if (m_picProcess)
	{
		CGRect kRect;
		kRect.origin = kScrRect.origin;
		kRect.size = m_picProcess->GetSize();
		m_picProcess->DrawInRect(kRect);
	}

	if (m_bRecacl)
	{
		m_bRecacl = false;
	}
}

void CUIExp::SetFrameRect(CGRect rect)
{
	CGRect rectOld = this->GetFrameRect();

	NDUINode::SetFrameRect(rect);

	if (CompareEqualFloat(rectOld.size.width, rect.size.width)
			&& CompareEqualFloat(rectOld.size.height, rect.size.height))
	{
		return;
	}

	CC_SAFE_DELETE (m_picBg);

	if (!m_strBgFile.empty())
	{
		m_picBg = NDPicturePool::DefaultPool()->AddPicture(m_strBgFile,
				rect.size.width, rect.size.height);
	}

	m_bRecacl = true;

	if (m_lbText)
	{
		m_lbText->SetFrameRect(
				CGRectMake(0, 0, rect.size.width, rect.size.height));
	}
}