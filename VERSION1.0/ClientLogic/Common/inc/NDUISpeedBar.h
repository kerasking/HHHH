/*
 *  NDUISpeedBar.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_UI_SPEED_BAR_H_
#define _ND_UI_SPEED_BAR_H_

#include "NDUIButton.h"
#include "NDUILayer.h"
#include "GlobalDialog.h"
#include "GameItemBag.h"
#include "NDUIAnimation.h"
#include <vector>

using namespace NDEngine;

typedef enum
{
	SpeedBarAlignmentBegin = 0,
	SpeedBarAlignmentLeft = SpeedBarAlignmentBegin,
	SpeedBarAlignmentRight,
	SpeedBarAlignmentBottom,
	SpeedBarAlignmentEnd,
}SpeedBarAlignment;

class NDUISpeedBar;

typedef struct _tagSpeedBarCellInfo
{
	friend class NDUISpeedBar;
	enum { invalid_index = -1, };
	int index;								// cell索引;
	int param1, param2, param3;
	NDPicture *background;
	NDPicture *foreground;
	bool gray;								// 是否变灰,且变灰时不处理事件
	_tagSpeedBarCellInfo()
	{ 
		memset(this, 0, sizeof(*this)); 
		
		index = invalid_index;
	}
	
	~_tagSpeedBarCellInfo()
	{
	}
	
	_tagSpeedBarCellInfo(NDPicture* background, NDPicture *foreground=NULL,int param1=0, bool gray=false, int param2=0, int param3=0, int index=invalid_index)
	{
		this->background	= background;
		this->foreground	= foreground;
		this->param1		= param1;
		this->param2		= param2;
		this->param3		= param3;
		this->index			= index;
		this->grayEnable(gray);
	}
	
	_tagSpeedBarCellInfo& operator =(const _tagSpeedBarCellInfo& rhs)
	{
		if (this->background) {
			delete this->background;
		}
		if (this->foreground) {
			delete this->foreground;
		}
		this->background	= rhs.background;
		this->foreground	= rhs.foreground;
		this->param1		= rhs.param1;
		this->param2		= rhs.param2;
		this->param3		= rhs.param3;
		this->index			= rhs.index;
		this->grayEnable(rhs.gray);
		return *this;
	}
	
	bool isGray() { return this->gray; }
	
private:
	bool grayEnable(bool gray)
	{
		this->gray = gray;
		
		if (background) background->SetGrayState(gray);
		
		if (foreground) foreground->SetGrayState(gray);
		
		return true;
	}
	
}SpeedBarCellInfo;

typedef std::vector<SpeedBarCellInfo> SpeedBarInfo;

class NDUISpeedBar;

class NDUISpeedBarDelegate
{
public:
	virtual void OnNDUISpeedBarEvent(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info, bool focused) {}
	virtual void OnNDUISpeedBarEventLongTouch(NDUISpeedBar* speedbar, const SpeedBarCellInfo& info) {}
	virtual void OnNDUISpeedBarSet(NDUISpeedBar* speedbar) {}
	// fromShrnk: true 从收缩到扩张, false 从扩张到收缩
	virtual void OnNDUISpeedBarShrinkClick(NDUISpeedBar* speedbar, bool fromShrnk) {}
	// 点击翻页完成后的回调, page 当前页
	virtual void OnRefreshFinish(NDUISpeedBar* speedbar, unsigned int page) {}
};

class NDUISpeedBar :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NDUISpeedBar)
public:
	NDUISpeedBar();
	
	virtual ~NDUISpeedBar();
	
	void Initialization(unsigned int funcNum,				// 功能项数
						unsigned int totalpage				// 总共几页
						); hide
	
	
	// intereface begin ..
	void refresh(SpeedBarInfo& info);
	
	// 暂时不用
	void refresh(SpeedBarCellInfo& info);
	
	void defocus();
	
	void SetGray(bool bGray);
	
	void SetGray(bool bGray, unsigned int index);
	
	void SetFoucusByIndex(unsigned int index);
	
	unsigned int GetCurPage() { return m_uiCurPage; }
	
	virtual void SetPage(unsigned int page) { }
	// interface end ..
	
	bool TouchBegin(NDTouch* touch); override
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnButtonLongClick(NDUIButton* button); override
	
	void draw(); override
	
	void SetVisible(bool visible); override
	
	virtual void Layout();
	
	virtual void DrawBackground();
	
	virtual void OnShrink(bool shrink) {}
	
	void SetShrink(bool bShrink, bool animation=true);
	
	bool IsShrink() { return m_stateShrink; }
	
protected:
	virtual void OnDrawAjustUI() {}
	void SetFocusImage(const char* filename);
	void SetShrinkDis(unsigned int dis);
	void ReverseShrink();
	bool FindPage(unsigned int curPage, unsigned int& resPage, bool judgeGray=false, bool judgeGaryReturnFront=true);
	void UpdatePage();
	
private:
	void ClearCellData(unsigned cellIndex);
	void UpdateCellData(unsigned cellIndex);
	
	void DealShrink(float time);
	
protected:
	// 派生类定制容器按钮(不包括设置与刷新)属性 begin ..
	CGSize				m_sizeBtn;				// 按钮大小
	CGPoint				m_pointBorder;			// 容器的内部坐标
	unsigned int		m_uiInterval;			// 容器内的间隔
	SpeedBarAlignment	m_align;				// 排版
	// 派生类定制属性 end ..
	
	unsigned int m_uiFuncNum;
	unsigned int m_uiTotalPage;
	unsigned int m_uiCurPage;
	
	NDUIButton *m_btnSetOption, *m_btnRefresh, *m_btnShrink;
	
	NDPicture *m_picShrink, *m_picBackGround, *m_picBackGroundShrink;
	
	NDUIImage		*m_imageFocus;
	
	ItemFocus		*m_focus;
	
	typedef struct _tagCellInfo
	{
		unsigned int key;
		bool bUse;
		SpeedBarCellInfo info;
	}CellInfo;
	std::vector<CellInfo> m_vecInfo;
	
private:	
	CIDFactory		m_idFactory;
	
	unsigned int	m_uiShrinkdis;
	
	bool			m_stateShrink; // 收缩
	
	NDUIAnimation	m_curUiAnimation;
	unsigned int	m_keyAnimation;
	
	NDUINode		*m_uiNodeFocus;
};

#endif // _ND_UI_SPEED_BAR_H_