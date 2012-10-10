/*
 *  SyndicateInfoScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-9-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SYNDICATE_INFO_SCENE_H_
#define _SYNDICATE_INFO_SCENE_H_

#include "NDCommonScene.h"

class SyndicateInfoScene :
public NDCommonSocialScene
{
	DECLARE_CLASS(SyndicateInfoScene)
public:
	SyndicateInfoScene();
	~SyndicateInfoScene();
	void Initialization(const string& strTabTitle, const string& strInfo);
	void OnButtonClick(NDUIButton* button); override
};

#endif // _PLAYER_INFO_SCENE_H_