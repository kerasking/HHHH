/*
 *  UIExp.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIExp.h"
#include "SMString.h"
#include <sstream>
#include "define.h"
#include "NDUtil.h"
//using namespace cocos2d;

IMPLEMENT_CLASS(CUIExp, NDUINode)

CUIExp::CUIExp()
{
	m_picBg				= NULL;
	m_picProcess		= NULL;
	m_lbText			= NULL;
	m_unTotal			= 0;
	m_unProcess			= 0;
    m_unStart           = 0;
	m_bRecacl			= true;
    m_nStyle            = 0;
	m_fPercent			= 0.0f;
}

CUIExp::~CUIExp()
{
	SAFE_DELETE(m_picBg);
	SAFE_DELETE(m_picProcess);
	SAFE_DELETE_NODE(m_lbText);
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
void CUIExp::SetStart(unsigned int unStart)
{
    m_unStart	= unStart;
	m_bRecacl	= true;
}

void CUIExp::SetProcess(unsigned int unProcess)
{
	//WriteCon( "CUIExp::SetProcess(%d)\r\n", unProcess );

	m_unProcess = unProcess;

	m_bRecacl = true;
}

void CUIExp::SetTotal(unsigned int unTotal)
{
	//WriteCon( "CUIExp::SetTotal(%d)\r\n", unTotal );

	m_unTotal	= unTotal;
	
	m_bRecacl	= true;
}

unsigned int CUIExp::GetStart()
{
    return m_unStart;
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
	
	if (!m_picProcess && m_strProcessFile.length() > 0)
	{
		m_picProcess = NDPicturePool::DefaultPool()->AddPicture( m_strProcessFile.c_str(), false );
	}

	CCRect scrRect		= this->GetScreenRect();
	
	if (m_bRecacl && !m_strProcessFile.empty())
	{
		//SAFE_DELETE(m_picProcess);
        
        unsigned int t_unProcess    = m_unProcess - m_unStart;
        unsigned int t_unTotal      = m_unTotal - m_unStart;
		if(t_unTotal > 0)
		{
			m_fPercent = max(0.0f, (float(t_unProcess) / float(t_unTotal)));
		}

#if 0
		if (t_unProcess <= t_unTotal && 0 != t_unTotal && 0 != t_unProcess)
		{
			float fWidth	= scrRect.size.width * t_unProcess / t_unTotal;

			if (fWidth>scrRect.size.width)
			{
				fWidth=scrRect.size.width;
			}
			
			if ((int)fWidth > 0)
			{
 				m_picProcess	= NDPicturePool::DefaultPool()->AddPicture(
 								m_strProcessFile.c_str(), fWidth, scrRect.size.height);
			}
		}
#endif
	}
	
	if ( m_bRecacl && m_lbText )
	{
		if (0 != m_unTotal)
		{
            if(m_nStyle == 0)
			{
				m_lbText->SetVisible(true);
                std::stringstream ss;
                ss << m_strText.c_str() << m_unProcess << "/" << m_unTotal;
                //tq::CString str("%s%u/%u", m_strText.c_str(), m_unProcess, m_unTotal);
                m_lbText->SetText(ss.str().c_str());
            }
			else if(m_nStyle == 1)
			{
				m_lbText->SetVisible(true);
                std::stringstream ss;
                ss << m_strText.c_str() << m_unProcess/m_unTotal << "%";
                //tq::CString str("%s%u/%u", m_strText.c_str(), m_unProcess, m_unTotal);
                m_lbText->SetText(ss.str().c_str());
            }
			else if (m_nStyle == 2)
			{
				m_lbText->SetVisible(false);
            }
		}
	}
	
	if (m_picBg)
	{
		m_picBg->DrawInRect(scrRect);
	}

	if (m_picProcess)
	{
		if (m_picProcess->GetTexture()->getPixelsWide() >= 0 && 
			m_picProcess->GetTexture()->getPixelsHigh() >= 0)
		{
			CCSize sizeCut = CCSizeMake( m_picProcess->GetTexture()->getPixelsWide() * m_fPercent,
				m_picProcess->GetTexture()->getPixelsHigh());			

			CCRect cut = CCRectMake( 0, 0, sizeCut.width, sizeCut.height );
			m_picProcess->Cut( cut );

			CCRect rect;
			rect.origin		= scrRect.origin;
			rect.size		= CCSizeMake( scrRect.size.width * m_fPercent, scrRect.size.height );
			m_picProcess->DrawInRect(rect);
		}
	}

	if (m_bRecacl)
	{
		m_bRecacl	= false;
	}
}

void CUIExp::SetFrameRect(CCRect rect)
{
	CCRect rectOld = this->GetFrameRect();

	NDUINode::SetFrameRect(rect);
	
	if (CompareEqualFloat(rectOld.size.width, rect.size.width) && 
		CompareEqualFloat(rectOld.size.height, rect.size.height))
	{
		return;
	}

	SAFE_DELETE(m_picBg);
	
	if (!m_strBgFile.empty())
	{
		m_picBg		= NDPicturePool::DefaultPool()->AddPicture(
					m_strBgFile.c_str());//, rect.size.width, rect.size.height);
	}
	
	m_bRecacl	= true;
	
	if (m_lbText)
	{
		m_lbText->SetFrameRect(CCRectMake(0, 0, rect.size.width, rect.size.height*1.5));
	}
}
bool CUIExp::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_lbText)
	{
		return false;
	}
	return true;
}