/*
 *  SyndicateUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_UI_LAYER_H__
#define __SYNDICATE_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDUIDialog.h"

using namespace NDEngine;

typedef struct _tagSynCellInfo {
	_tagSynCellInfo()
	{
		idSyn = 0;
		synFlag = 0;
	}
	
	int idSyn;
	int synFlag;
	
}SynCellInfo;

class SynListCell : public NDUINode
{
	DECLARE_CLASS(SynListCell)
	
	SynListCell();
	
	~SynListCell();
	
public:
	void Initialization();
	
	NDUILabel* GetKeyText();
	
	NDUILabel* GetValueText();
	
	void SetFocusTextColor(ccColor4B clr) {
		m_clrFocusText = clr;
	}
	
	void draw(); override
	
public:
	SynCellInfo m_info;
	
protected:
	NDUILabel	*m_lbKey, *m_lbValue;
	NDPicture	*m_picBg, *m_picFocus;
	ccColor4B	m_clrFocusText, m_clrNormalText;
};

class SyndicateUILayer :
public NDUILayer,
public NDUITableLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SyndicateUILayer)
public:
	static void OnAllSynList(NDTransData& data);
private:
	static SyndicateUILayer* s_instance;
public:
	SyndicateUILayer();
	~SyndicateUILayer();
	
	void Initialization();
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	
private:
	NDUITableLayer* m_tlSynList;
	NDUIButton *m_btnViewInfo, *m_btnApply;
	NDUILabel* m_lbPages;
	NDUIButton* m_btnPrePage;
	NDUIButton* m_btnNextPage;
	int m_nCurPage;
	int m_nTotalPage;
	
private:
	void RefreshAllSynList(NDTransData& data);
};

#endif