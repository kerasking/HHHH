/*
 *  NewHelpScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_HELP_SCENE_H_
#define _NEW_HELP_SCENE_H_

#include "NDCommonScene.h"
#include "NDCommonControl.h"
#include "NDUITableLayer.h"
#include "NDScrollLayer.h"
#include "NDTimer.h"
#include <vector>
#include <map>

typedef enum
{
	HelpDataString,
	HelpDataImage,
}HelpDataType;

typedef struct _tagHelpData
{
	HelpDataType type;
	std::string text;
}HelpData;

typedef std::vector<HelpData> vec_help_data;

typedef vec_help_data::iterator vec_help_data_it;

typedef std::map<int, vec_help_data> map_help_data;

typedef map_help_data::iterator map_help_data_it;

typedef std::map<int , std::string> map_index_help_data;

typedef map_index_help_data::iterator map_index_help_data_it;

class HelpCell : public NDPropCell
{
	DECLARE_CLASS(HelpCell)
	
public:
	HelpCell();
	
	~HelpCell();
	
	void Initialization(); override
	
	void draw(); override
	
private:

	NDPicture *m_pic;
};


class NewHelpLayer :
public NDUILayer,
public NDUITableLayerDelegate,
public NDUILayerDelegate
{
	DECLARE_CLASS(NewHelpLayer)
	
	NewHelpLayer();
	
	~NewHelpLayer();
	
public:	
	void Initialization(bool delayShow=false); override
	
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
	
	void SetContent(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);

	void OnTimer(OBJID tag); override
private:
	std::string LoadTextWithParam(int index);
	
	void LoadText();
	
	void refresh(vec_help_data& data);
	
private:

	NDUIContainerScrollLayer *m_contentScroll;
	
	NDUITableLayer *m_tl;
	
	std::string		m_strIntroduce;
	std::string		m_strMenuIntroduce;
	std::string		m_strGameSetting;
	
	map_help_data	m_mapData;
	
	map_index_help_data  m_mapIndex;

	NDTimer	m_timer;
	
};

class NewHelpScene :
public NDCommonSocialScene
{
	DECLARE_CLASS(NewHelpScene)
	
	NewHelpScene();
	
	~NewHelpScene();
	
public:
	
	static NewHelpScene* Scene(bool delayShow=false);
	
	void Initialization(bool delayShow=false); override
	
	void OnButtonClick(NDUIButton* button);
	
private:
	void Init(NDUIClientLayer* client);
	
	bool m_bDelayShow;
};


#endif // _NEW_HELP_SCENE_H_