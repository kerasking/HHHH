/*
 *  DramaCommandBase.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
 #ifndef _DRAMA_COMMAND_BASE_H_ZJH_
 #define _DRAMA_COMMAND_BASE_H_ZJH_
 
#include "DramaDef.h"
#include "globaldef.h"

class DramaCommandBase
{
public:
	DramaCommandBase();
	virtual ~DramaCommandBase();
	
	virtual void excute()				{}
	
	bool IsFinish();
	bool CanExcuteNextCommand();
	void SetPreCommandsFinish(bool bSet);
	bool IsPreCommandsFinish();
	unsigned int AllocKey();
	void DeAllocKey(unsigned int nKey);
	unsigned int GetKey();
public:
	static void ResetKeyAlloc();
	
protected:
	DramaCommandParam					m_param;
	bool								m_bFinish;
	bool								m_bCanExcuteNextCommand;
	bool								m_bPreCommandsFinish;
	
protected:
	void SetFinish(bool bFinish);
	void SetCanExcuteNextCommand(bool bCan);
	
private:
	static unsigned int					m_uiKeyGenerator;
	static								ID_VEC m_vIdRecyle;
};

#endif // _DRAMA_COMMAND_BASE_H_ZJH_