/*
 *  NewPaiHangScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _NEW_PAI_HANG_SCENE_H_
#define _NEW_PAI_HANG_SCENE_H_

#include "NDCommonScene.h"
#include "NDUITableLayer.h"

typedef struct _tagPaiHangTitle
{
	std::vector<int> fildTypes;
	std::vector<std::string> fildNames;
}PaiHangTitle;

class NewPaiHangScene :
public NDCommonScene
{
	DECLARE_CLASS(NewPaiHangScene)
	
	NewPaiHangScene();
	
	~NewPaiHangScene();
	
	typedef std::vector<NDUILabel*> VEC_LABEL;
	
	enum { MAX_LABEL_COUNT = 3, };
	
public:
	
	static NewPaiHangScene* Scene(const std::vector<std::string>& vec_str, const std::vector<int>& vec_id);
	
	void Initialization(const std::vector<std::string>& vec_str, const std::vector<int>& vec_id); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void refreshCurTable();
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void OnTabLayerNextPage(TabLayer* tab, unsigned int lastPage, unsigned int nextPage); override
private:
	void GetTabData(TabLayer* tab, unsigned int index);
	void refreshTable(NDUITableLayer* tl);
	void refreshTitle(VEC_LABEL& vLabel, int iPaiHangId);
private:
	std::vector<NDUITableLayer*> m_vTable;
	std::vector<VEC_LABEL>	m_vLabels;
public:
	static void refresh();
	
	static std::map<int, PaiHangTitle> s_PaiHangTitle;
	//static std::vector<int> fildTypes;
	//static std::vector<std::string> fildNames;
	static int curPaiHangType;
	static int itype;
	static int totalPages;
	static std::map<int,std::vector<std::string> > values;
};


#endif // _NEW_PAI_HANG_SCENE_H_
