/*
 *  GameHelpScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_HELP_SCENE_H_
#define _GAME_HELP_SCENE_H_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUIMenuLayer.h"
#include "NDUICheckBox.h"
#include "NDUIMemo.h"
#include <string>
#include "JavaMethod.h"
#include "PlayerHead.h"
#include "NDUIImage.h"

using namespace NDEngine;

class HelpOperateItem : public NDUINode
{
	DECLARE_CLASS(HelpOperateItem)
	HelpOperateItem();
	~HelpOperateItem();
public:
	void SetOperateImage(const char* imageName);
	void SetOperateText(const char* text);
private:
	NDUIImage* m_image;
	NDUIText* m_memo;
};

class GameHelpScene : public NDScene, public NDUIButtonDelegate
{
	DECLARE_CLASS(GameHelpScene)
public:
	GameHelpScene();
	~GameHelpScene();
public:
	static GameHelpScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
private:
	std::string LoadTextWithParam(int index);
	void LoadText();
	void VisibleButtons(bool bVisible);
	
	void MakeOperateItems(unsigned int beginIndex, unsigned int endIndex);
private:
	NDUIMenuLayer	*m_menuLayer;
	NDUILabel		*m_lbGameHelp, *m_lbPage;
	NDUIButton		*m_btnIntroduce, *m_btnOperate, *m_btnMenuIntroduce, *m_btnGameSetting, *m_btnPrevPage, *m_btnNextPage;
	NDUIMemo		*m_memoTxt;
	std::string		m_strIntroduce;
	std::string		m_strMenuIntroduce;
	std::string		m_strGameSetting;
	
	NDUILayer		*m_layerOperateItems, *m_layerPageControl;
	std::vector<std::string> m_imageNames;
	std::vector<std::string> m_operateTexts;
	unsigned int m_curPage;
};

#endif // _GAME_HELP_SCENE_H_