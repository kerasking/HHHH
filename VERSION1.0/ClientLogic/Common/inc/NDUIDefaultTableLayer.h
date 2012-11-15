/*
 *  NDUIDefaultTableLayer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

//
//  NDUITableLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUIDefaultTableLayer_H
#define __NDUIDefaultTableLayer_H

#include "NDUILayer.h"
#include <vector>
#include <string>
#include "NDDataSource.h"
#include "NDUILabel.h"
#include "NDUIBaseGraphics.h"
#include "NDPicture.h"

namespace NDEngine
{
	typedef enum
	{
		DefaultTableLayerStyle_SingleSection,		// 显示内容时不显示其它Section 默认
		DefaultTableLayerStyle_MutiSection,			// 显示内容时显示其它Section
	}DefaultTableLayerStyle;
	
	
	
	class NDUIDefaultSectionTitle;
	class NDUIDefaultTableLayer;
	class NDUIDefaultVerticalScrollBar;
	
	//---------------------------------------------
	class NDUIDefaultSectionTitleDelegate
	{
	public:
		virtual void OnDefaultSectionTitleClick(NDUIDefaultSectionTitle* sectionTitle);
	};
	
	class NDUIDefaultSectionTitle : public NDUINode
	{
		DECLARE_CLASS(NDUIDefaultSectionTitle)
		NDUIDefaultSectionTitle();
		~NDUIDefaultSectionTitle();
	public:
		void SetText(const char* title);
		std::string GetText();	
		void SetTextAlignment(LabelTextAlignment align);
		void SetFontColor(ccColor4B fontColor);		
		ccColor4B GetFontColor();
		
		void SetFrameRect(CCRect rect); override
		
		void Initialization(); override
		
		void SetStatePicture(NDPicture *picOpen, NDPicture *close, bool bClearOnFree=true);
		void SetBGPicture(NDPicture *pic, NDPicture *picfocus, bool bClearOnFree=true);
	public:
		void OnTouchDown(bool touched){ m_touched = touched; }
		void draw();override
		
	private:
		NDUILabel* m_lblText;
		bool m_touched;
		NDPicture *m_picOpen, *m_picClose, *m_picBG, *m_picFocusBG;
		bool m_bStateClearOnFree, m_bBGClearOnFree;
	};	
	//---------------------------------------------
	
	//---------------------------------------------
	class NDUIDefaultVerticalScrollBarDelegate
	{
	public:
		virtual void OnDefaultVerticalScrollBarUpClick(NDUIDefaultVerticalScrollBar* scrollBar);
		virtual void OnDefaultVerticalScrollBarDownClick(NDUIDefaultVerticalScrollBar* scrollBar);
	};
	
	class NDUIDefaultVerticalScrollBar : public NDUINode
	{
		DECLARE_CLASS(NDUIDefaultVerticalScrollBar)
		NDUIDefaultVerticalScrollBar();
		~NDUIDefaultVerticalScrollBar();
	public:
		void Initialization(); override
		
		void SetCurrentContentY(float y);                                                                                      
		float GetCurrentContentY();
		
		void SetContentHeight(float h);
		float GetContentHeight(); 
	public:
		void draw(); override			
		void OnClick(CCPoint touch);
		void OnTouchDown(bool touched, CCPoint pos){ m_touched = touched; m_touchPos = pos; }
	private:
		float m_currentContentY, m_contentHeight;
		bool m_touched;
		CCPoint m_touchPos;
		NDPicture* m_picUp, *m_picDown;
		
	};
	//---------------------------------------------
	
	//---------------------------------------------
	class NDUIDefaultTableLayerDelegate
	{
	public:
		virtual void OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
		virtual void OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	};
	
	class NDUIDefaultTableLayer : public NDUILayer, public NDUIDefaultSectionTitleDelegate, public NDUIDefaultVerticalScrollBarDelegate
	{
		DECLARE_CLASS(NDUIDefaultTableLayer)
		NDUIDefaultTableLayer();
		~NDUIDefaultTableLayer();
	public:		
		void SetDataSource(NDDataSource* dataSource);
		NDDataSource* GetDataSource(){ return m_dataSource; }
		
		void VisibleSectionTitles(bool bVisibled){ m_sectionTitleVisibled = bVisibled; }		
		void SetSectionTitlesHeight(unsigned int height){ m_sectionTitlesHeight = height; }			
		void SetSectionTitlesAlignment(LabelTextAlignment align){ m_sectionTitlesAlign = align; }
		
		void VisibleScrollBar(bool bVisibled){ m_scrollBarVisibled = bVisibled; }
		void SetScrollBarWidth(unsigned int width){ m_scrollBarWidth = width; }
		
		void SetCellsInterval(unsigned int interval){ m_cellsInterval = interval; }
		void SetCellsLeftDistance(unsigned int distace){ m_cellsLeftDistance = distace; }
		void SetCellsRightDistance(unsigned int distance){ m_cellsRightDistance = distance; }	
		
		void SetBackgroundColor(ccColor4B color); hide
		void SetStyle(DefaultTableLayerStyle style);	// 确保刷新数据源之前调用
		void ReflashData();
		void OpenSection(unsigned int sectionIndex);	// 确保设置数据源后再调用,调用该方法就无需ReflashData
		void CloseSection(unsigned int sectionIndex);	// 确保设置数据源后再调用,调用该方法就无需ReflashData
		void SetCellBackgroundPicture(std::string filename);
	public:	
		void Initialization();
		NDUIDefaultSectionTitle* GetActiveSectionTitle();
		void draw();override
		void OnDefaultSectionTitleClick(NDUIDefaultSectionTitle* sectionTitle); override
		void OnDefaultVerticalScrollBarUpClick(NDUIDefaultVerticalScrollBar* scrollBar);override
		void OnDefaultVerticalScrollBarDownClick(NDUIDefaultVerticalScrollBar* scrollBar);override
		bool TouchMoved(NDTouch* touch); override
		bool DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch); override			
	private:
		NDDataSource* m_dataSource;
		bool m_needReflash;
		NDSection* m_curSection;
		bool m_sectionTitleVisibled;
		bool m_scrollBarVisibled;		
		unsigned int m_curSectionIndex;
		unsigned int m_sectionTitlesHeight;
		unsigned int m_scrollBarWidth;
		std::vector<NDUIDefaultSectionTitle*> m_sectionTitles;
		std::vector<NDUIRecttangle*> m_backgrounds;
		std::vector<NDUIDefaultVerticalScrollBar*> m_scrollBars;
		unsigned int m_cellsInterval, m_cellsLeftDistance, m_cellsRightDistance;
		ccColor4B m_bgColor;
		
		LabelTextAlignment m_sectionTitlesAlign;
		DefaultTableLayerStyle m_style;
		std::string m_strCellBGFile;
		struct CellBG
		{
			NDPicture* pic;
			CCRect drawRect;
			
			CellBG() { pic = NULL; drawRect = CCRectZero; }
			CellBG(NDPicture *pic, CCRect drawRect) { this->pic = pic; this->drawRect = drawRect; }
		};
		std::vector<CellBG> m_picCellBGPicture;
		
		void MoveSection(unsigned int sectionIndex, int moveLen);
		void DrawBackground(unsigned int sectionIndex);		
		void DrawSectionTitle(unsigned int sectionIndex);
		NDUIDefaultVerticalScrollBar* DrawScrollbar(unsigned int sectionIndex);		
		void SetFocusOnCell(unsigned int cellIndex);
		
		CCRect GetCellRectWithIndex(unsigned int sectionIndex, unsigned int cellIndex);
		void UpdateSection();
	};
	//---------------------------------------------
}

#endif

