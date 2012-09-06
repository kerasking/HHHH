//
//  NDUIDialog.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-24.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#ifndef __NDUIDialog_H
#define __NDUIDialog_H

#include "NDScrollLayer.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDPicture.h"
#include "NDTextNode.h"
//#include "NDUITableLayer.h"
//#include "NDUIMemo.h"
#include <vector>
#include <string>

namespace NDEngine
{
class NDUIDialog;

class NDUIDialogDelegate
{
public:
	virtual void OnDialogShow(NDUIDialog* dialog);
	virtual void OnDialogClose(NDUIDialog* dialog);
	virtual void OnDialogButtonClick(NDUIDialog* dialog,
			unsigned int buttonIndex);
	virtual bool OnDialogTimeOut(NDUIDialog* dialog);
};

class NDUIDialog: public NDUILayer,
		public NDUILayerDelegate,
		public NDUIButtonDelegate
{
	DECLARE_CLASS (NDUIDialog)
	NDUIDialog();
	~NDUIDialog();
public:
	// 带箭头功能调用该接口
	void Show(const char* title, const char* text, const char* cancleButton,
			const std::vector<std::string>& ortherButtons,
			const std::vector<bool> vec_arrow);
	void Show(const char* title, const char* text, const char* cancleButton,
			const std::vector<std::string>& ortherButtons);
	void Show(const char* title, const char* text, const char* cancleButton,
			const char* ortherButtons, .../*must NULL end*/);
	void Show0(const char* title, const char* text);
	void Show1(const char* title, const char* text, const char* op1);
	void Show2(const char* title, const char* text, const char* op1,
			const char* op2);
	void Show3(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3);
	void Show4(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4);
	void Show5(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5);
	void Show6(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5,
			const char* op6);
	void Show7(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5,
			const char* op6, const char* op7);
	void Show8(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5,
			const char* op6, const char* op7, const char* op8);
	void Show9(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5,
			const char* op6, const char* op7, const char* op8, const char* op9);
	void Show10(const char* title, const char* text, const char* op1,
			const char* op2, const char* op3, const char* op4, const char* op5,
			const char* op6, const char* op7, const char* op8, const char* op9,
			const char* op10);
	virtual void Close();
	std::string GetTitle();
public:
	void Initialization();override
	void OnButtonClick(NDUIButton* button);override
	bool TouchBegin(NDTouch* touch);override
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance);override
	void SetContent(const char *text,
			cocos2d::ccColor4B color = ccc4(79, 79, 79, 255),
			unsigned int fontsize = 13);
	void SetTitle(const char *text);
	void SetTime(uint sec);
	void OnTimer(OBJID tag);override
private:
	void InitUIData();
	void InitFullScrBtns(const std::vector<std::string>& ortherButtons);
protected:
	virtual void TimeOutDefaultDeal();

protected:
	bool m_bFullScreen;
	NDUILabel *m_lbTitle;
	NDUIContainerScrollLayer *m_contentScroll;
	unsigned int m_uiContentHeightFullScr, m_uiContentHeightNotFullScr;
	unsigned int m_uiContentLeftWidthFullScr, m_uiContentLeftWidthNotFullScr;
	unsigned int m_uiContentTopheight;
	unsigned int m_uiIntervalBtnAndContent;
	unsigned int m_uiTitleHeightFullScr, m_uiTitleHeightNotFullScr;

	CGSize m_sizeNotFullScr, m_sizeBtnFullScr, m_sizeBtnNotFullScr;

	enum
	{
		max_btns = 10, max_btns_half = 5,
	};
	NDUIButton *m_btnClose, *m_btnConfirm, *m_btnOptions[max_btns];

	NDTimer m_timer;
	NDUILabel *m_lbTime;
	int m_iCurTime;

	DECLARE_AUTOLINK (NDUIDialog)
	INTERFACE_AUTOLINK (NDUIDialog)
};

//	 class NDUIDialog;
//	 
//	 class NDUIDialogDelegate
//	 {
//	 public:
//	 virtual void OnDialogShow(NDUIDialog* dialog);
//	 virtual void OnDialogClose(NDUIDialog* dialog);
//	 virtual void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
//	 };
//	 
//	 class NDUIDialog : public NDUILayer, public NDUITableLayerDelegate
//	 {
//	 DECLARE_CLASS(NDUIDialog)
//	 NDUIDialog();
//	 ~NDUIDialog();
//	 public:
//	 void SetWidth(unsigned int width); /*default values 200*/
//	void SetTitleHeight(unsigned int height);/*default values 25*/
//	void SetContextHeight(unsigned int height);/*default values 80*/
//	void SetButtonHeight(unsigned int height);/*default values 30*/
//
//	// 带箭头功能调用该接口
//	void Show(const char* title, const char* text, const char* cancleButton, const std::vector<std::string>& ortherButtons, const std::vector<bool> vec_arrow);
//	void Show(const char* title, const char* text, const char* cancleButton, const std::vector<std::string>& ortherButtons);
//	void Show(const char* title, const char* text, const char* cancleButton, const char* ortherButtons,.../*must NULL end*/); 
//	
//	virtual void Close();
//	
//	std::string GetTitle();
//public:
//	void Initialization(); override
//	void draw(); override
//	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
//	bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override
//	bool TouchBegin(NDTouch* touch); override
//	bool TouchEnd(NDTouch* touch); override
//private: 
//	NDPicture* m_picLeftTop;		
//	NDPicture* m_picRightTop;
//	NDPicture* m_picLeftBottom;
//	NDPicture* m_picRightBottom;
//protected:
//	bool m_leaveButtonExists;
//	bool m_autoRemove;
//	NDUILabel* m_label;
//	NDUIText* m_memo;
//	NDUITableLayer* m_table;	
//	
//	unsigned int m_width, m_titleHeight, m_contextHeight, m_buttonHeight;
//	bool m_bTouchBegin;
//	
//	 };

}
#endif
