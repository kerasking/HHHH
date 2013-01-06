/*
 *  UIEdit.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 网龙(DeNA). All rights reserved.
 *
 */

#include "UIEdit.h"
#include "ScriptUI.h"
#include "IphoneInput.h"
#include "NDDirector.h"
#include "NDUtil.h"
#include "define.h"
//#include "I_Analyst.h"
#include "ObjectTracker.h"
#include "UsePointPls.h"

CUIEdit* CUIEdit::g_pCurUIEdit = NULL;

IMPLEMENT_CLASS(CUIEdit, NDUINode)

CUIEdit::CUIEdit()
{
	INC_NDOBJ_RTCLS

	m_picImage				= NULL;
	m_picFocusImage			= NULL;
	m_nMinLen				= 0;
	m_nMaxLen				= 9999;
	m_bPassword				= false;
	m_bEnableAjdustView		= true;
	m_bRecacl				= true;
	m_colorText				= ccc4(255, 255, 255, 255);
    //m_colorText				= ccc4(255, 0, 255, 255);
    m_iFlag                 = 0;

	m_curInputCount			= 0;
	m_curStrCount			= 0;

#if WITH_OLD_IME
	m_pPlatformInput		= NULL;
#endif

	m_bIMEOpen				= false;
}

void CUIEdit::Initialization()
{
	NDUINode::Initialization();

	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(14);
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));

	//m_lbText->SetTextAlignment(LabelTextAlignmentLeftCenter);
	//m_lbText->SetHasFontBoderColor(false);

	InitInput();
}

CUIEdit::~CUIEdit()
{
	DEC_NDOBJ_RTCLS

	SAFE_DELETE(m_lbText);
	SAFE_DELETE(m_picImage);
	SAFE_DELETE(m_picFocusImage);

    if(g_pCurUIEdit == this)
	{
		g_pCurUIEdit = NULL;
	}

#if WITH_OLD_IME
	SAFE_DELETE(m_pPlatformInput);
#endif
}

//文字改变了
void CUIEdit::OnTextChanged()
{
	if (!m_lbText) return;

// 	int strCount = m_strText.length();
// 	if(strCount > m_curStrCount)
// 	{
// 		m_curInputCount++;
// 	}
// 	else if(strCount < m_curStrCount)
// 	{
// 		m_curInputCount--;
// 		if(m_curInputCount < 0)
// 			m_curInputCount = 0;
// 	}
// 	m_curStrCount = strCount;
// 
// 	if(m_curInputCount > m_nMaxLen)
// 		return;
		
	string labelText = "";
	if (IsPassword())
	{
		int nStrLen	= m_strText.size();
		for (int i = 0; i < nStrLen; i++) 
		{
			labelText += "*";
		}
	}
	else
	{
		labelText = m_strText;
	}

	m_lbText->SetText( labelText.c_str() );
}

//设置字体大小
void CUIEdit::SetTextSize(unsigned int nSize)
{
    int curFontSize = nSize;
    
    if (m_lbText)
		m_lbText->SetFontSize(curFontSize);

#if WITH_OLD_IME
	if (m_pPlatformInput)
	{
		m_pPlatformInput->SetFontSize(nSize);
	}
#endif
}

//设置文本
void CUIEdit::SetText(const char* pszText)
{
	m_strText	= pszText ? pszText : "";
	
#if WITH_OLD_IME
	if (m_pPlatformInput)
	{
		m_pPlatformInput->SetText(m_strText.c_str());
	}
#endif

	this->OnTextChanged();
}

//设置是否显示为密码
void CUIEdit::SetPassword(bool bSet)
{
	if (m_bPassword != bSet)
	{
		m_bPassword	= bSet;
		this->OnTextChanged();
	}
}

//设置文本最大长度（字节数？）
void CUIEdit::SetMaxLength(unsigned int nLen)
{
	m_nMaxLen	= nLen;

#if WITH_OLD_IME
    if(m_pPlatformInput)
	{
        m_pPlatformInput->SetLengthLimit(nLen);
    }
#endif
}

//设置图像
void CUIEdit::SetImage(NDPicture* pic)
{
	if (m_picImage)
	{
		SAFE_DELETE(m_picImage);
	}
	
	m_picImage	= pic;
}

//设置焦点图像
void CUIEdit::SetFocusImage(NDPicture* pic)
{
	if (m_picFocusImage)
	{
		SAFE_DELETE(m_picFocusImage);
	}
	
	m_picFocusImage	= pic;
}

//设置文本颜色
void CUIEdit::SetTextColor(ccColor4B color)
{
	m_colorText	= color;

#if WITH_OLD_IME
	if (!m_pPlatformInput)
	{
		return;
	}
	m_pPlatformInput->SetTextColor(color.r / 255, color.g / 255, color.b / 255, color.a / 255);
#endif

	SetShowTextColor(color);
}

//设置显示文本颜色
void CUIEdit::SetShowTextColor(ccColor4B color)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(color);
	}
}

//设置显示文本尺寸
void CUIEdit::SetShowTextFontSize(int nFontSize)
{
	int curFontSize = int(nFontSize * FONT_SCALE);

	if (m_lbText)
	{
		m_lbText->SetFontSize(curFontSize);
	}
}

void CUIEdit::draw()
{
    //TICK_ANALYST(ANALYST_CUIEdit);
	NDUINode::draw();
	
	if (!this->IsVisibled())
	{
		return;
	}
		
#if WITH_NEW_IME
	
	NDPicture* pic = m_picImage;
	if (m_bIMEOpen && m_picFocusImage)
	{
		pic	= m_picFocusImage;
	}

	if (pic)
	{
		pic->DrawInRect( this->GetScreenRect() );
	}

	if (m_lbText)
	{
		m_lbText->draw();
	}
#endif


#if WITH_OLD_IME
	if (m_pPlatformInput)
	{
        //** chh 2012-06-19 **//
        CCRect scrRect = m_lbText->GetFrameRect();
        CCSize textSize = getStringSize(TEST_TEXT,m_lbText->GetFontSize());
        int HBorder = (this->GetScreenRect().size.height-textSize.height)/2;
        
        
		m_pPlatformInput->SetFrame(scrRect.origin.x, scrRect.origin.y+HBorder, scrRect.size.width, scrRect.size.height);
	}
	if (m_bRecacl && m_pPlatformInput)
	{
		m_pPlatformInput->SetText(m_strText.c_str());
		m_pPlatformInput->EnableSafe(m_bPassword);
		m_pPlatformInput->EnableAutoAdjust(m_bEnableAjdustView);
		m_pPlatformInput->SetStyleNone();
		m_bRecacl	= false;
	}
	
	NDPicture* pic = m_picImage;
	
	if (m_pPlatformInput && m_pPlatformInput->IsInputState() && m_picFocusImage)
	{
		pic	= m_picFocusImage;
	}
	
	if (pic)
	{
		pic->DrawInRect(scrRect);
	}
	if (m_pPlatformInput && !m_pPlatformInput->IsShow() && m_lbText)
	{
		CCRect rectText		= m_lbText->GetScreenRect();
		if (!CompareEqualFloat(rectText.origin.x, scrRect.origin.x) || 
			!CompareEqualFloat(rectText.origin.y, scrRect.origin.y))
		{
            CCRect rect = scrRect;
            rect.origin.x += TEXT_LEFT_BORDER;
            m_lbText->SetFrameRect(rect);
		}
        //m_lbText->SetFrameRect(scrRect);
		m_lbText->draw();
	}
#endif //WITH_OLD_IME
}

//设置控件是否可见
void CUIEdit::SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	
#if WITH_OLD_IME
	if (m_pPlatformInput)
	{
		if (visible)
		{
			//m_pPlatformInput->Show();
		}
		else 
		{
			m_pPlatformInput->Hide();
		}
	}
#endif
}

//override: 设置控件区域大小
void CUIEdit::SetFrameRect(CCRect rect)
{
	NDUINode::SetFrameRect(rect);
	if (m_lbText)
	{
		CCRect rectLabel = CCRectMake( TEXT_LEFT_BORDER, 0, rect.size.width, rect.size.height );
		m_lbText->SetFrameRect( rectLabel );
		this->AddChild( m_lbText, 0x1 );
	}
	m_bRecacl	= true;
}

//?
bool CUIEdit::AutoInputReturn() 
{
#if WITH_OLD_IME
	if (!m_pPlatformInput)
	{
		return true;
	}
	//Is Hide Allready
	if (!m_pPlatformInput->IsShow())
	{
		return true;
	}
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";

	this->OnTextChanged();
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
#endif
	return true; 
}

//初始化输入
void CUIEdit::InitInput()
{
	//@todo...
#if WITH_OLD_IME
	if (m_pPlatformInput)
	{
		return;
	}

	// 加上平台处理,暂时先用iphone初始始 todo
	m_pPlatformInput	= new CIphoneInput();
	m_pPlatformInput->Init();
	m_pPlatformInput->SetInputDelegate(this);
	m_pPlatformInput->Hide();
#endif

	this->SetTextColor(m_colorText);
}

//点击打开/关闭输入法
bool CUIEdit::OnClick(NDObject* object)
{
	CCLog( "CUIEdit::OnClick()\r\n" );

#if WITH_NEW_IME
	if (!m_bIMEOpen)
	{
		attachWithIME();
	}
#else
	if (m_pPlatformInput)
	{
		g_pCurUIEdit = this;
		m_pPlatformInput->Show();
	}
#endif

	OnScriptUiEvent(this, TE_TOUCH_BTN_CLICK);//++Guosen 2012.8.1//点击时传递按钮点击事件给LUA脚本，

	return true;
}

//////////////////////////////////////////////////////////////////////////////// 旧的输入法代码 {{
#if WITH_OLD_IME
//@oldime
bool CUIEdit::OnInputReturn(CInputBase* base) 
{
	if (this != base)
	{
		return false;
	}
	
	if (!m_pPlatformInput)
	{
		return true;
	}
	
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";
	
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_RETURN))
	{
		return false;
	}
	
	this->OnTextChanged();
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
	return true; 
}

//@oldime
bool CUIEdit::OnInputTextChange(CInputBase* base, const char* inputString)
{ 
	if (this != base)
	{
		return false;
	}
	
    const char* text	= m_pPlatformInput->GetText();
    unsigned int strcount = strlen(text);
    if (strcount >= m_nMaxLen) {
        //** chh 2012-08-14 **//
        //return false;
    }
	if (!m_pPlatformInput)
	{
		return true;
	}
    if ( 1 == m_iFlag )
    {
        int i;
        for(i=0;inputString[i];i++)
        {
            if((inputString[i]<48)||(inputString[i]>57))
                return false;
        }
    }
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_TEXT_CHANGE, inputString ? inputString : ""))
	{
		return false;
	}
	
	return true; 
}

//@oldime
void CUIEdit::OnInputFinish(CInputBase* base)
{
    if (this != base)
	{
		return;
	}
	
	if (!m_pPlatformInput)
	{
		return;
	}
	
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";
	
	this->OnTextChanged();
    
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_INPUT_FINISH))
	{
		return;
	}
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
}
#endif //WITH_OLD_IME
//////////////////////////////////////////////////////////////////////////////// 旧的输入法代码 }}






//////////////////////////////////////////////////////////////////////////////// 新的输入法代码 {{
#if WITH_NEW_IME
bool CUIEdit::attachWithIME()
{
	CCLog( "@@ CUIEdit::attachWithIME()\r\n" );

	bool bRet = CCIMEDelegate::attachWithIME();
	if (bRet)
	{
		CCLog( "@@ CUIEdit::attachWithIME(), call CCIMEDelegate::attachWithIME(), ret TRUE\r\n" );

		// open keyboard
		CCEGLView * pGlView = CCDirector::sharedDirector()->getOpenGLView();
		if (pGlView)
		{
			CCLog( "@@ CCIMEDelegate::attachWithIME(), call pGlView->setIMEKeyboardState(true)\r\n" );

			pGlView->setIMEKeyboardState(true);
		}
	}
	return bRet;
}

bool CUIEdit::detachWithIME()
{
	CCLog( "@@ CUIEdit::detachWithIME()\r\n" );

	bool bRet = CCIMEDelegate::detachWithIME();
	if (bRet)
	{
		// close keyboard
		CCEGLView * pGlView = CCDirector::sharedDirector()->getOpenGLView();
		if (pGlView)
		{
			CCLog( "@@ CUIEdit::detachWithIME(), call pGlView->setIMEKeyboardState(false)\r\n" );

			OnScriptUiEvent(this, TE_TOUCH_EDIT_INPUT_FINISH);
			pGlView->setIMEKeyboardState(false);
		}
	}
	return bRet;
}

bool CUIEdit::canAttachWithIME()
{
	return true;
	//return CCIMEDelegate::canAttachWithIME();
}

bool CUIEdit::canDetachWithIME()
{
	return true;
	//return CCIMEDelegate::canDetachWithIME();
}

void CUIEdit::insertText(const char * text, int len)
{
	CCLog( "@@ CUIEdit::insertText() text=%s\r\n", text);
	CCLog( "@@ CUIEdit::insertText() length=%d \r\n", len);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	m_strText += text ? text : "";
#else
	std::string	tmpStr = text ? text : ""; //这个是=

	for (int i = 0; i < 2; i++)
	{
		int len = tmpStr.length();
		if (len > 0)
		{
			const char c = tmpStr[len - 1];
			if (c == '\r' || c == '\n')
			{
				tmpStr.erase( tmpStr.end() - 1 );
			}
		}
	}

	int inputCount = 0;
	const char *tmpPointer = tmpStr.c_str();
	while (*tmpPointer != '\0')
	{
		if ((unsigned char) *tmpPointer < 0x80)
		{
			tmpPointer++;
			inputCount++;
		}
		else
		{
			tmpPointer += 3;
			inputCount++;
		}
	}
	CCLog( "@@ CUIEdit::insertText() inputCount=%d \r\n", inputCount);
	CCLog( "@@ CUIEdit::insertText() m_nMaxLen=%d \r\n", m_nMaxLen);

	if(inputCount > m_nMaxLen)
		return;

	m_strText = tmpStr;

#endif

	this->OnTextChanged();

#if 0
	std::string sInsert(text, len);
#endif

// 	// insert \n means input end
// 	int nPos = sInsert.find('\n');
// 	if ((int)sInsert.npos != nPos)
// 	{
// 		len = nPos;
// 		sInsert.erase(nPos);
// 	}

#if 0
	if (len > 0)
	{
		m_strText += text; //@todo...
		this->OnTextChanged();
	}
#endif

// 	if ((int)sInsert.npos == nPos) {
// 		return;
// 	}
// 
// 	// '\n' inserted, let delegate process first
// 	if (m_pDelegate && m_pDelegate->onTextFieldInsertText(this, "\n", 1))
// 	{
// 		return;
// 	}
// 
// 	// if delegate hasn't processed, detach from IME by default
// 	detachWithIME();
}

void CUIEdit::deleteBackward()
{
	//android平台不需要理会deleteBackward(), ios没测试.
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	CCLog( "@@ CUIEdit::deleteBackward()\r\n" );

	int nStrLen = m_strText.length();
	if (! nStrLen)
	{
		// there is no string
		return;
	}

	// get the delete byte number
	int nDeleteLen = 1;    // default, erase 1 byte

	while(0x80 == (0xC0 & m_strText.at(nStrLen - nDeleteLen)))
	{
		++nDeleteLen;
	}

	// if all text deleted, show placeholder string
	if (nStrLen <= nDeleteLen)
	{
		m_strText = "";
	}
	else
	{
		// set new input text
		string sText( m_strText.c_str(), nStrLen - nDeleteLen );
		m_strText = sText;
	}

	this->OnTextChanged();
#endif
}

const char* CUIEdit::getContentText()
{
	return m_strText.c_str();
	//return m_pInputText->c_str();
}

void CUIEdit::keyboardDidShow(CCIMEKeyboardNotificationInfo& info)
{
	m_bIMEOpen = true;
}

void CUIEdit::keyboardDidHide(CCIMEKeyboardNotificationInfo& info)
{
	m_bIMEOpen = false;
}

void CUIEdit::onAction( int action )
{
	CCLog( "@@ CUIEdit::onAction(%d)\r\n", action );

	if (action == 0)
	{
		//action=enter
		this->detachWithIME();
	}
	else if (action == 6)
	{
		//action=done
		this->detachWithIME();
	}
}

#endif //WITH_NEW_IME
//////////////////////////////////////////////////////////////////////////////// 新的输入法代码 }}