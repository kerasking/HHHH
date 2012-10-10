/*
 *  GeneralListLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __GENERAL_LIST_LAYER_H__
#define __GENERAL_LIST_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"
#include "ItemMgr.h"
#include "FarmMgr.h"
#include <vector>
#include <string>

using namespace NDEngine;

enum  GeneralListLayerType
{
	GeneralListLayer_None = 0,
	GeneralListLayer_Farm,
	GeneralListLayer_EmptyHamlet,
};

class GeneralListLayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(GeneralListLayer)
public:
	static void processMsgCommonList(NDTransData& data);
	static void processMsgCommonListRecord(NDTransData& data);
	//farm相关
	static void processFarmList(std::string title, VEC_ITEM& itemlist, std::vector<std::string>& vec_str, int iNPCID, int iType); 
	static void processEmpytHamlet(std::string title, std::vector<HamletInfo>& vec_info);
private:
	static GeneralListLayer* s_instance;
	
	typedef vector<string> VEC_BUTTON;
	typedef VEC_BUTTON::iterator VEC_BUTTON_IT;
	
	class ListField {
	public:
		enum FIELD_TYPE {
			FT_NONE = -1,
			FT_INT = 0,
			FT_STRING = 1,
		};
		
		ListField() {
			m_type = FT_NONE;
		}
		
		FIELD_TYPE m_type;
		string m_name;
	};
	
	typedef vector<ListField> VEC_LIST_FIELD;
	typedef VEC_LIST_FIELD::iterator VEC_LIST_FIELD_IT;
	
public:
	GeneralListLayer();
	~GeneralListLayer();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnPageChange(int nCurPage, int nTotalPage);
	void Init(const string& strTitle);
	
private:
	NDUITableLayer* m_tlMain, *m_tlOperate;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDPageButton* m_btnPage;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
	int m_id;
	VEC_LIST_FIELD m_vFields;
	VEC_BUTTON m_vOpts;
	
private:
	void refreshMainList();
	void releaseElement();
	void sendMessage(int action);
	void LoadUIOperate();
	void showEmpytHamletOperate();
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	
	int m_iFarmType;
	
	GeneralListLayerType m_glType;
};

#endif