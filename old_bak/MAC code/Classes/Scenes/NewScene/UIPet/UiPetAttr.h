/*
 *  UiPetAttr.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _UI_PET_ATTR_H_
#define _UI_PET_ATTR_H_

#include "UiPetDefine.h"
#include "define.h"
#include "NDScrollLayer.h"


#include "NDScene.h"
#include "ImageNumber.h"
#include "NDUICustomView.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDSprite.h"
#include "NDCommonControl.h"
#include "GameUIAttrib.h"

using namespace NDEngine;

namespace NDEngine 
{
	//////////////////////////////////////////
	
		
	class CUIPetAttr : 
	public NDUILayer, 
	public NDUIButtonDelegate, 
	public NDUIDialogDelegate,
	public NDPropSlideBarDelegate
	{
	public:
		enum ePetAttrBasic 
		{
			ePAB_Begin = 0,
			ePAB_LiLiang = ePAB_Begin,
			ePAB_TiZhi,
			ePAB_MinJie,
			ePAB_ZhiLi,
			ePAB_End,
		};
		
	public:
		DECLARE_CLASS(CUIPetAttr)
		CUIPetAttr();
		~CUIPetAttr();
		
	public:
		void Initialization(); hide
		
		void Update(OBJID idPet, bool bEnable);
		
		void draw(); override
		void OnButtonClick(NDUIButton* button); override
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
		
		// new
		void OnPropSlideBarChange(NDPropSlideBar* bar, int change); override
		void SetVisible(bool visible); override
	private:
		void UpdatePoint();
		void setBattlePetValueToPetAttr();
		void sendAction();
		
		void UpdateStrucPoint();
		
		// new 
		bool changePointFocus(int iPointType);
		
		void InitPropAlloc();
		void AddPropAlloc(NDUINode* parent);
		
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
				
				int iPoint;		//玩家分配了多少点
				int iFix;		//固定多少点
				point_state()
				{
					iPoint = 0; iFix = 0;
				}
			};
			_stru_point()
			{
				iTotal = 0; iAlloc= 0;
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
				return m_psProperty[ePS].iPoint + m_psProperty[ePS].iFix;
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
			void reset() { memset(this, 0, sizeof(*this)); }
			int iTotal; //可分配点数
			int iAlloc; //已分配点数
			point_state m_psProperty[ps_end];
		};
		
		// 0 normal, 1 focus
		NDPropAllocLayer *m_pointFrame[_stru_point::ps_end];
		NDUIButton		*m_btnPointTxt[_stru_point::ps_end];
		NDUIButton		*m_btnPointMinus[_stru_point::ps_end]; NDPicture *m_picPointMinus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointPlus[_stru_point::ps_end];  NDPicture *m_picPointPlus[_stru_point::ps_end][2];
		NDUIButton		*m_btnPointCur[_stru_point::ps_end];
		
		_stru_point m_struPoint;
		
		NDUILayer *m_layerPropAlloc;
		
		NDUILabel *m_lbTotal, *m_lbAlloc;
		
		NDPropSlideBar *m_slideBar;
		
		NDUIButton *m_btnCommit;
		
		int m_iFocusPointType;
		
		OBJID m_idPet;
		bool m_bEnableOp;
	
	public:
		int int_PET_ATTR_STR; // 力量INT
		int int_PET_ATTR_STA; // 体质INT
		int int_PET_ATTR_AGI; // 敏捷INT
		int int_PET_ATTR_INI; // 智力INT
		
		int int_ATTR_FREE_POINT; //自由点数
	
	};
}

#endif