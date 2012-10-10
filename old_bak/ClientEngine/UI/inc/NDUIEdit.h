//
//  NDUIEdit.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
	
	//delegates begin
	class NDUIEditDelegate
	{
	public:
//		
//		函数：OnEditClick
//		作用：当编辑框被点击之后框架调用该方法
//		参数：edit当前编辑框
//		返回值：无
		virtual bool OnEditClick(NDUIEdit* edit);
//		
//		函数：OnEditInputFinish
//		作用：当编辑框输入完毕之后框架调用该方法
//		参数：edit当前编辑框
//		返回值：无
		virtual void OnEditInputFinish(NDUIEdit* edit);
//		
//		函数：OnEditInputCancle
//		作用：当编辑框输入被取消之后框架调用该方法
//		参数：edit当前编辑框
//		返回值：无
		virtual void OnEditInputCancle(NDUIEdit* edit);
//		
//		函数：OnEditTextChanged
//		作用：当编辑框文本内容改变时框架调用该方法
//		参数：edit当前编辑框
//		返回值：无
		virtual void OnEditTextChanged(NDUIEdit* edit);
//		
//		函数：OnEditInputCharcters
//		作用：当编辑框正输入字符时框架调用该方法
//		参数：edit当前编辑框，inputString编辑框的内容
//		返回值：无
		virtual bool OnEditInputCharcters(NDUIEdit* edit, const char* inputString);
	};
	//delegates end
	
	class NDUIEdit : public NDUINode
	{
		DECLARE_CLASS(NDUIEdit)
	public:
		NDUIEdit();
		~NDUIEdit();
	public:	
//		
//		函数：Initialization
//		作用：初始化编辑框，必须被显示或者隐式调用
//		参数：无
//		返回值：无
		void Initialization();
//		
//		函数：SetText
//		作用：设置编辑框的文本内容
//		参数：text文本内容
//		返回值：无	
		void SetText(const char* text);
//		
//		函数：GetText
//		作用：获取编辑框的文本内容
//		参数：无
//		返回值：文本内容
		std::string GetText();
//		
//		函数：SetFontColor
//		作用：设置编辑框内容的字体颜色
//		参数：fontColor颜色值rgba
//		返回值：无
		void SetFontColor(ccColor4B fontColor);
//		
//		函数：GetFontColor
//		作用：获取编辑框内容的颜色
//		参数：无
//		返回值：颜色值rgba
		ccColor4B GetFontColor();
//		
//		函数：SetPassword
//		作用：设置编辑框是否采用密码输入方式
//		参数：password如果true则采用密码输入方式，否则不采用
//		返回值：无
		void SetPassword(bool password);
//		
//		函数：IsPasswordChar
//		作用：判断编辑框是否采用密码输入方式
//		参数：无
//		返回值：true采用密码输入方式，否则不采用
		bool IsPasswordChar();
//		
//		函数：SetMaxLength
//		作用：设置编辑框允许输入最多的字符个数
//		参数：len字符数
//		返回值：无
		void SetMaxLength(int len);
//		
//		函数：GetMaxLength
//		作用：获取编辑框允许输入的最多字符个数
//		参数：无
//		返回值：字符个数
		int GetMaxLength();
//		
//		函数：SetMinLength
//		作用：设置编辑框最少需要输入的字符个数
//		参数：len字符数
//		返回值：无
		void SetMinLength(int len);
//		
//		函数：GetMinLength
//		作用：获取编辑框最少需要输入的字符数
//		参数：无
//		返回值：字符数
		int GetMinLength();
//		
//		函数：ShowFrame
//		作用：设置是否显示编辑框的边框
//		参数：show如果true显示，否则不显示
//		返回值：无
		void ShowFrame(bool show){ m_frameOpened = show; }
		
		void ShowCaret(bool bShow) {
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