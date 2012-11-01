

#ifndef __NDUIEdit_H
#define __NDUIEdit_H

#include "NDUINode.h"
#include <string>
#include "NDUILabel.h"
#include "NDPicture.h"
#include <vector>

namespace NDEngine
{	
	class NDUIEdit;

	class NDUIEditDelegate
	{
	public:

		virtual bool OnEditClick(NDUIEdit* edit);
		virtual void OnEditInputFinish(NDUIEdit* edit);
		virtual void OnEditInputCancle(NDUIEdit* edit);
		virtual void OnEditTextChanged(NDUIEdit* edit);
		virtual bool OnEditInputCharcters(NDUIEdit* edit, const char* inputString);
	};
	
	class NDUIEdit : public NDUINode
	{
		DECLARE_CLASS(NDUIEdit)
	public:
		NDUIEdit();
		~NDUIEdit();
	public:	
		void Initialization();

		void SetText(const char* text);

		std::string GetText();

		void SetFontColor(ccColor4B fontColor);

		ccColor4B GetFontColor();

		void SetPassword(bool password);

		bool IsPasswordChar();

		void SetMaxLength(int len);

		int GetMaxLength();

		void SetMinLength(int len);

		int GetMinLength();

		void ShowFrame(bool show){ m_frameOpened = show; }
		
		void ShowCaret(bool bShow)
		{
			this->m_showCaret = bShow;
		}
		
		void SetImage(NDPicture* pic, NDPicture* focusPic, bool clearPicOnFree=false);
		
	public:
		void draw(); override	
		void SetFrameRect(CGRect rect); override		
	private:
		std::string m_iphoneEditText, m_thisText;		
		NDUILabel* m_label;
		bool m_password, m_frameOpened, m_showCaret;
		int m_focusRunCount, m_maxLength, m_minLength;
		
		NDPicture *m_picImg, *m_picFocusImg;
		bool m_bClearPicOnFree;
	};
}

#endif