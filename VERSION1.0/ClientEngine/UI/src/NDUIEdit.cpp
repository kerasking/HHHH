#include "NDUIEdit.h"
//#include "NDIphoneEdit.h"
//#include <UIKit/UIKit.h>
//#include "CCPointExtension.h"
#include "NDUtil.h"
#include "I_Analyst.h"
#include "NDUIBaseGraphics.h"
#include "NDUILayer.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIEdit, NDUINode)

#define FONT_SIZE 15
#define FOCUS_RUN_INTERVAL 30

	NDUIEdit::NDUIEdit()
	{
		INC_NDOBJ_RTCLS

			m_password = false;
		m_frameOpened = true;
		m_focusRunCount = 0;
		m_showCaret = true;

		m_maxLength = -1;
		m_minLength = -1;

		m_bClearPicOnFree = false;

		m_picImg = m_picFocusImg = NULL;
	}

	NDUIEdit::~NDUIEdit()
	{
		DEC_NDOBJ_RTCLS

			if (m_bClearPicOnFree)
			{
				delete m_picImg;
				delete m_picFocusImg;
			}
	}

	void NDUIEdit::Initialization()
	{
		NDUINode::Initialization();

		m_label = new NDUILabel();
		m_label->Initialization();
		m_label->SetTextAlignment(LabelTextAlignmentLeft);
		m_label->SetFontSize(FONT_SIZE);
		m_label->SetFontColor(ccc4(0, 0, 0, 255));

		this->AddChild(m_label);
	}

	void NDUIEdit::SetText(const char* text)
	{
		if (!text || !strcmp(m_thisText.c_str(), text))
		{
			return;
		}

		m_thisText = text;

		if (m_password)
		{
			int strLen = strlen(text);
			char* pText = (char*) malloc(strLen + 1);
			memset(pText, '*', strLen);
			pText[strLen] = 0x00;
			m_label->SetText(pText);
			free(pText);
		}
		else
		{
			m_label->SetText(m_thisText.c_str());
		}

		NDUIEditDelegate* pkDelegate =
			dynamic_cast<NDUIEditDelegate*>(this->GetDelegate());

		if (pkDelegate)
		{
			pkDelegate->OnEditTextChanged(this);
		}
	}

	std::string NDUIEdit::GetText()
	{
		return m_thisText;
	}

	void NDUIEdit::SetFontColor(ccColor4B fontColor)
	{
		m_label->SetFontColor(fontColor);
	}

	ccColor4B NDUIEdit::GetFontColor()
	{
		return m_label->GetFontColor();
	}

	void NDUIEdit::SetPassword(bool password)
	{
		m_password = password;
	}

	bool NDUIEdit::IsPasswordChar()
	{
		return m_password;
	}

	void NDUIEdit::SetMaxLength(int len)
	{
		m_maxLength = len - 1;
	}

	int NDUIEdit::GetMaxLength()
	{
		return m_maxLength;
	}

	void NDUIEdit::SetMinLength(int len)
	{
		m_minLength = len;
	}

	int NDUIEdit::GetMinLength()
	{
		return m_minLength;
	}

	void NDUIEdit::SetImage(NDPicture* pic, NDPicture* focusPic,
		bool clearPicOnFree/*=false*/)
	{
		if (m_bClearPicOnFree)
		{
			if (m_picImg)
				delete m_picImg;
			if (m_picFocusImg)
				delete m_picFocusImg;
		}

		m_picImg = pic;

		m_picFocusImg = focusPic;

		m_bClearPicOnFree = clearPicOnFree;
	}

	void NDUIEdit::SetFrameRect(CCRect rect)
	{
		NDUINode::SetFrameRect(rect);
		m_label->SetFrameRect(CCRectMake(0, 0, rect.size.width, rect.size.height));
	}

	void NDUIEdit::draw()
	{
		if (!isDrawEnabled())
			return;
		TICK_ANALYST (ANALYST_NDUIEdit);
		NDUINode::draw();

		if (this->IsVisibled())
		{
			NDNode* parentNode = this->GetParent();
			if (parentNode)
			{
				CCRect scrRect = this->GetScreenRect();

				//draw context
				if (!m_picImg)
					DrawRecttangle(scrRect, ccc4(255, 255, 255, 255));

				//draw frame
				if (m_frameOpened)
				{
					DrawPolygon(
						CCRectMake(scrRect.origin.x - 1, scrRect.origin.y - 1,
						scrRect.size.width + 2,
						scrRect.size.height + 2),
						ccc4(125, 125, 125, 255), 2);
				}

				if (parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
				{
					NDUILayer* uiLayer = (NDUILayer*) parentNode;

					if (uiLayer->GetFocus() == this)
					{
						if (m_picFocusImg)
							m_picFocusImg->DrawInRect(scrRect);
					}
					else
					{
						if (m_picImg)
							m_picImg->DrawInRect(scrRect);
					}

					//draw focus
					if (uiLayer->GetFocus() == this && m_showCaret)
					{
						if (m_focusRunCount < FOCUS_RUN_INTERVAL)
						{
							DrawLine(
								ccp(scrRect.origin.x + (m_picImg ? 5 : 2),
								scrRect.origin.y + (m_picImg ? 5 : 0)),
								ccp(scrRect.origin.x + (m_picImg ? 5 : 2),
								scrRect.origin.y + scrRect.size.height
								- (m_picImg ? 5 : 0)),
								ccc4(0, 0, 255, 255), 2);
						}
						if (m_focusRunCount++ > FOCUS_RUN_INTERVAL * 2)
						{
							m_focusRunCount = 0;

						}
					}

					if (m_picImg && m_label)
					{
						m_label->SetFrameRect(CCRectMake(7, (scrRect.size.height-FONT_SIZE)/2, scrRect.size.width, scrRect.size.height));
					}
				}
			}
		}
	}

	bool NDUIEditDelegate::OnEditClick(NDUIEdit* edit)
	{
		return true;
	}

	void NDUIEditDelegate::OnEditInputFinish(NDUIEdit* edit)
	{

	}

	void NDUIEditDelegate::OnEditInputCancle(NDUIEdit* edit)
	{

	}

	void NDUIEditDelegate::OnEditTextChanged(NDUIEdit* edit)
	{

	}

	bool NDUIEditDelegate::OnEditInputCharcters(NDUIEdit* edit,
		const char* inputString)
	{
		return true;
	}
}