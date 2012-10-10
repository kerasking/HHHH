/*
 *  PetInfoScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PET_INFO_SCENE_H_
#define _PET_INFO_SCENE_H_

#include "NDCommonScene.h"

/*
class PetInfoScene :
public NDCommonScene
{
	DECLARE_CLASS(PetInfoScene)
	
	PetInfoScene();
	
	~PetInfoScene();
	
public:
	
	static PetInfoScene* Scene(bool onlyAttr=false);
	
	void Initialization(bool onlyAttr=false); override
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
private:
	
	void InitAttr(NDUIClientLayer* client, bool onlyAttr=false);
	
	void InitSkill(NDUIClientLayer* client);
}; */

class NewPetInfoScene :
public NDCommonScene
{
	DECLARE_CLASS(NewPetInfoScene)
	
	NewPetInfoScene();
	
	~NewPetInfoScene();
	
public:
	static NewPetInfoScene* Scene(OBJID idPet);
		
	void Initialization(OBJID idPet); hide
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	void InitPet(NDUIClientLayer* client, OBJID idPet);
};

#endif // _PET_INFO_SCENE_H_