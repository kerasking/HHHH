/*
 *  SystemAndCustomLayer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SYSTEM_AND_CUSTOM_LAYER_H_
#define _SYSTEM_AND_CUSTOM_LAYER_H_

#include "NDCommonControl.h"
#include "NDUISpecialLayer.h"
#include "NDScrollLayer.h"
#include "NDUITableLayer.h"
#include "NDDataPersist.h"
#include "NDUIDefaultButton.h"

class CustomFeedBack : 
public NDUILayer,
public NDUIButtonDelegate,
public NDUILayerDelegate,
public NDScrollLayerDelegate,
public CommonTextInputDelegate
{
	DECLARE_CLASS(CustomFeedBack)
	
	CustomFeedBack();
	
	~CustomFeedBack();
	
public:
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	bool SetTextContent(CommonTextInput* input, const char* text); override
	
	void OnClickNDScrollLayer(NDScrollLayer* layer); override
	
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
	
	bool SetFeedbackContent(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	
private:
	NDUIContainerScrollLayer *m_contentScroll; NDUILabel* m_lbFeedbackContent;
	
	CommonTextInput *m_input;
	
	NDUIButton *m_btnCommit;
	
	NDQuestionDataPlist m_dataplist;
};


class CustomPassword : 
public NDUILayer,
public NDUIButtonDelegate,
public CommonTextInputDelegate
{
	DECLARE_CLASS(CustomPassword)
	
	CustomPassword();
	
	~CustomPassword();
	
public:
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override

	
private:
	void InitPW(NDUILabel*& lb, NDUIMutexStateButton*& btn, NDUILabel*& lbBtn, const char* lbText, int startY);
	bool SetTextContent(CommonTextInput* input, const char* text); override
	
	bool SetTextContent(int textType , const char* text);
	
	bool checkNewPwd(const string& pwd);
	const char* GetTextContent(int textType);
private:
	NDUIMutexStateButton	*m_btnCurPW, *m_btnNewPW, *m_btnRepeatNewPW;
	NDUILabel	*m_lbCurPW, *m_lbNewPW, *m_lbRepeatNewPW;
	
	CommonTextInput *m_input;
	
	NDUIButton *m_btnCommit;
	
	enum { eInputNone, eInputCurPW, eInputNewPW, eInputRepeatNewPW, eInputEnd, };
	int m_iCurInput;
};


class CustomDeclaration :
public NDUILayer,
public NDUILayerDelegate
{
	DECLARE_CLASS(CustomDeclaration)
	
	CustomDeclaration();
	
	~CustomDeclaration();
	
	static void processDeclareData(const char* text);
	static bool HasDeclareData();
	static void ClearDeclareData();
private:
	static CustomDeclaration* s_instance;
public:
	void Initialization(const char* pic="custom_declare.png"); override
	
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
	
	bool SetDeclareContent(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	
	void SetVisible(bool visible); override
private:
	NDUIContainerScrollLayer *m_contentScroll;
	
	static std::string s_DeclareData;
};

#pragma mark 客服公告
class CustomGongGao :
public CustomDeclaration
{
	DECLARE_CLASS(CustomGongGao)
	
	void Initialization(); hide
};

#pragma mark 客服活动

class CustomActivity :
public NDUILayer,
public NDUITableLayerDelegate,
public NDUILayerDelegate
{
	DECLARE_CLASS(CustomActivity)
	
	CustomActivity();
	
	~CustomActivity();
	
	static void AddData(std::string str);
	static bool HasData();
	static void ClearData(); 
	static void refresh();
	
	enum { max_date = 7};
private:
	static std::string s_data[max_date];
	static std::string s_titles[max_date];
	static CustomActivity* s_instance;
	static unsigned int s_index;
public:
	
	void Initialization(); override
	
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
	
	void SetContent(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void refreshContent();
private:
	
	NDUIContainerScrollLayer *m_contentScroll;
	
	NDUITableLayer *m_tlDate;
};

#pragma mark 系统设置
class SystemSetting : 
public NDUILayer, 
public NDUIButtonDelegate, 
public NDUIOptionButtonDelegate
{
	DECLARE_CLASS(SystemSetting)
	SystemSetting();
	~SystemSetting();
public:
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	void OnOptionChange(NDUIOptionButton* option); override
	
private:
	typedef vector<string> VEC_OPT_STRING;
	
	void InitOption(CCPoint pos, VEC_OPT_STRING vOption, CommonOptionButton*& btn, const char* text);
private:
	NDDataPersist m_gameSettingData;
	//CommonOptionButton* m_headPicOpt;		// 头像显示
	//CommonOptionButton* m_miniMapOpt;	    // 缩略地图
	CommonOptionButton* m_showObjLevel;	// 显示品质
	CommonOptionButton* m_worldChatOpt;	// 世界聊天
	CommonOptionButton* m_synChatOpt;	    // 军团聊天
	CommonOptionButton* m_teamChatOpt;	// 队伍聊天
	CommonOptionButton* m_areaChatOpt;	// 区域聊天
	CommonOptionButton* m_directKeyOpt;   // 方向键
	
	NDUILayer* m_page1, /**m_page2*/;
	
	//NDUIButton		*m_btnPrevPage, *m_btnNextPage;	
	//NDUILayer		*m_pageControl;
	//unsigned int m_curPage;
	//NDUILabel		*m_lbPage;
};


#endif // _SYSTEM_AND_CUSTOM_LAYER_H_