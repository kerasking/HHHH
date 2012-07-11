/*
 *  GameUIAttrib.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_ATTRIB_H_
#define _GAME_UI_ATTRIB_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "ImageNumber.h"
#include "GameRoleNode.h"
#include "NDUIDialog.h"
#include "NDCommonControl.h"
#include "NDScrollLayer.h"

namespace NDEngine 
{
	class NDUIFrame;
	class NDUIMenuLayer;
	class NDPicture;
	class NDUILabel;
	class NDUIButton;
	class NDUILine;
	class NDUIRecttangle;
	class NDUIImage;
	class NDPlayer;
	
	using namespace cocos2d;

	class NDUIStateBar : public NDUILayer
	{
	public:
		DECLARE_CLASS(NDUIStateBar)
		NDUIStateBar();
		~NDUIStateBar();
	public:
		void Initialization(bool bSlide=true); override
		void draw(); override
		void SetStateColor(ccColor4B color);
		void SetNumber(int iCurNum, int iMaxNum, bool bNumPic=true);
		void ShowNum(bool bShow);
		void SetLabelMinNum(ccColor4B color, int num, unsigned int uiFontSize = 15);
		void SetLabelMaxNum(ccColor4B color, int num, unsigned int uiFontSize = 15);
		void SetLabel(std::string text, ccColor4B color, unsigned int uiFontSize = 15);
		
		void SetPercent(unsigned int percent);
		void SetSlideColor(ccColor4B color);
		
		int GetCurNum() { return m_iCurNum; }
		int GetMaxNum() { return m_iMaxNum; }
	private:
		int m_iCurNum, m_iMaxNum;
		ccColor4B m_colorState;
		NDUILine		*m_line[4];
		NDUIRecttangle	*m_rectState, *m_rectSlide, *m_rectSlideBG;
		ImageNumber		*m_stateNum;
		bool m_bShowNum;
		
		NDUILabel *m_lbNumMin, *m_lbNumMax;
		bool m_bShowPic;
		
		NDUILabel *m_lbText;
		bool m_bShowLabel;
		unsigned int m_iPercent;
		
		bool m_bSlide;
	};
	
	class NDUIProp : public NDUILayer
	{
	public:
		DECLARE_CLASS(NDUIProp)
		NDUIProp();
		~NDUIProp();
	public:
		void Initialization(); override
		void draw(); override
		void SetKeyText(std::string text);
		void SetKeyColor(ccColor3B color);
		void SetValueText(std::string text);
		void SetValueColor(ccColor3B color);
		
		void SetCenterValueText(std::string text);
		void SetCenterValueColor(ccColor3B color);
		std::string GetKeyText() { if(!m_lbKey) return ""; return m_lbKey->GetText(); } 
		
		void SetNoChangeBGColor(bool bSet) { m_bChangeBGColor = bSet; }
	private:
		NDUILine		*m_line[4];
		NDUILabel		*m_lbKey;
		NDUILabel		*m_lbValueCenter;
		NDUILabel		*m_lbValue;
		
		bool m_bChangeBGColor;
	};
	
	class AttrInfo : 
	public NDUILayer,
	public NDScrollLayerDelegate,
	public NDUIButtonDelegate,
	public NDUILayerDelegate
	{
		DECLARE_CLASS(AttrInfo)
		
		AttrInfo();
		
		~AttrInfo();
		
	public:
		void Initialization(); override
		
		void OnClickNDScrollLayer(NDScrollLayer* layer); override
		
		void OnButtonClick(NDUIButton* button); override
		
		bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
		
		NDUILabel* GetDescLabel();
		
		void SetContentText(const char* text);
		
	protected:
		NDUIButton	*m_btnClose;
		
		NDUILabel	*m_lbDesc;
		
		NDUILabelScrollLayer *m_lslText;
	};
	

	class GameUIAttrib : 
	public NDUILayer, 
	public NDUIButtonDelegate, 
	public NDUIDialogDelegate,
	public NDPropSlideBarDelegate,
	public NDUITableLayerDelegate
	{
		friend class AttrInfo;
	public:
		DECLARE_CLASS(GameUIAttrib)
		GameUIAttrib();
		~GameUIAttrib();
		static GameUIAttrib* GetInstance();
	private:
		static GameUIAttrib *s_intance;
	public:
		void Initialization(); override
		void draw(); override
		void OnButtonClick(NDUIButton* button); override
		void OnPropSlideBarChange(NDPropSlideBar* bar, int change); override
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
		void SetVisible(bool visible); override
		void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
		
		void UpdateGameUIAttrib();
		
		void AddPropAlloc(NDUINode* parent);
		void AddProp(NDUINode* parent);
		
		void UpdateMoney();
		
		void ShowAttrInfo(bool show);
	private:
		void ShowBasic();
		void ShowDetail();
		void ShowAdvance();
		
		void CaclAndUpdateDetail();
		void CaclAndUpdateAdvance();
		void UpdateBasicData(int eProp, std::string valueCenter, std::string value);
		void UpdateDetailData(int eProp, std::string value);
		void UpdateAdvanceData(int eProp, std::string value);
		
		bool changePointFocus(int iPointType);
		void changeTitleFocus(int iTitleType);
		void changeTitleImage(int iTitleType, bool bFocus);
		
		void InitPropAlloc();
		
		void InitProp();
		
		void SetPlusOrMinusPicture(int eProp, bool plus, bool focus);
		void SetPropTextFocus(int eProp, bool focus);
		void UpdatePorpText(int eProp);
		void UpdatePorpAlloc();
		void UpdateSlideBar(int eProp);
	public:
		struct _stru_point 
		{
			enum  enumPointState
			{
				ps_begin   = 0,
				ps_liliang = ps_begin,
				ps_tizhi,
				ps_minjie,
				ps_zhili,
				ps_end,
			};
			struct point_state 
			{
				int a;
			};
			_stru_point()
			{
				iTotal = 0; iAlloc = 0;
			}
			
			bool IsAlloc(enumPointState ePS)
			{
				if (ePS < ps_begin || ePS >= ps_end) return false;
				
				return m_psProperty[ePS].iPoint > 0;
			}
			
			int GetPoint(enumPointState ePS)
			{
				if (ePS < ps_begin || ePS >= ps_end) 
				{
					return 0;
				}
				return m_psProperty[ePS].iPoint + m_psProperty[ePS].iFix + m_psProperty[ePS].iAdd;
			}
			int GetMinPoint(enumPointState ePS)
			{
				return this->iAlloc-m_psProperty[ePS].iPoint;
			}
			bool VerifyAllocPoint()
			{
				int iPoint = 0;
				for (int i = ps_begin; i< ps_end; i++) 
				{
					iPoint += m_psProperty[i].iPoint;
				}
				return iPoint == iAlloc;
			}
			
			bool SetAllocPoint(enumPointState ePS, int point)
			{
				if (ePS < ps_begin || ePS >= ps_end) return false;
				
				int tmp = point-m_psProperty[ePS].iPoint;
				
				if (iAlloc+tmp > iTotal) return false;
				
				iAlloc += tmp;
				
				m_psProperty[ePS].iPoint = point;
				
				return true;
			}

			int iTotal; ///< 可分配点数
			int iAlloc; ///< 已分配点数
			point_state m_psProperty[ps_end];
		};
	private:
		NDPicture *m_picBasic, *m_picBasicDown; NDUIButton *m_btnBasic;				///< 基本
		NDPicture *m_picDetail, *m_picDetailDown; NDUIButton *m_btnDetail;			///< 详细
		NDPicture *m_picAdvance, *m_picAdvanceDown; NDUIButton *m_btnAdvance;		///< 高级
		
		NDUILayer		*m_frameRole;								///< 角色frame
		NDUILabel		*m_lbName, *m_lbLevel, *m_lbNone, *m_lbJunXian;
		NDUILabel		*m_lbHP, *m_lbMP, *m_lbExp;

		NDUILayer		*m_layerRole;
		NDStateBar		*m_stateBarHP, *m_stateBarMP, *m_stateBarExp;
		
		NDPicture		*m_picPropDot;								///< 可分配点数
		NDUIImage		*m_imagePropDot;
		
		NDPicture		*m_picMinus;
		NDUIImage		*m_imageMinus;
		
		// 0 normal, 1 focus
		NDPropAllocLayer *m_pointFrame[_stru_point::ps_end];
		NDUIButton		*m_btnPointTxt[_stru_point::ps_end];
		NDUIButton		*m_btnPointMinus[_stru_point::ps_end]; NDPicture *m_picPointMinus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointPlus[_stru_point::ps_end];  NDPicture *m_picPointPlus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointCur[_stru_point::ps_end];
		NDUIButton		*m_btnPointTotal[_stru_point::ps_end];
		_stru_point m_struPoint;
		
		NDPicture		*m_picMoney, *m_picEMoney;
		NDUIImage		*m_imageMoney, *m_imageEMoney;
		NDUILabel		*m_lbMoney, *m_lbEMoney;
		
		NDUITableLayer  *m_tableLayerDetail;
		NDUITableLayer	*m_tableLayerAdvance;
		

		ImageNumber *m_imageNumTotalPoint, *m_imageNUmAllocPoint;
		ImageNumber *m_imageNumMoney, *m_imageNumEMoney;
		
		GameRoleNode	*m_GameRoleNode;
		
		//ImageNumber *m_imageNumInfo[3];
		
		NDUILabel *m_lbMoneyInfo[3];
		
		NDUILayer *m_layerPropAlloc, *m_layerProp;
		
		NDUILabel *m_lbTotal, *m_lbAlloc;
		
		NDPropSlideBar *m_slideBar;
		
		NDUIButton *m_btnCommit;
		
		AttrInfo *m_attrInfo;
		bool m_attrInfoShow;
		
		enum enumTilteBtnState 
		{
			eTBS_Begin = 0,
			eTBS_Basic = eTBS_Begin,
			eTBS_Detail,
			eTBS_Advance,
			eTBS_End,
		};
		
		enumTilteBtnState m_enumTBS;
		
		NDUIDialog	*m_dlgTip; 
		
		int m_iFocusPointType;
		int m_iFocusTitle;// 0-basic,1-detail, 2-advance
		
		NDUILabel*	m_pLabelVip;
	};
}

//////////////////////////////////////////
class GameAttribScene : public NDScene
{
	DECLARE_CLASS(GameAttribScene)
public:
	GameAttribScene();
	~GameAttribScene();
	static GameAttribScene* Scene();
	void Initialization(); override
};

#endif // _GAME_UI_ATTRIB_H_