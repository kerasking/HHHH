/*
 *  DramaDef.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */
 
#ifndef _DRAMA_DEF_H_ZJH_
#define _DRAMA_DEF_H_ZJH_

#include <string>

typedef enum
{
	DCT_INVALID						= 0,
	DCT_OPEN						= 1,
	DCT_CLOSE						= 2,
	DCT_SETDLGFIG					= 3,
	DCT_SETDLGTITLE					= 4,
	DCT_SETDLGCONTENT				= 5,
	DCT_ADDSPRITE					= 6,
	DCT_ADDSPRITEBYFILE				= 7,
	DCT_REMOVESPRITE				= 8,
	DCT_SETSPRITEANI				= 9,
	DCT_SETSPRITEPOS				= 10,
	DCT_MOVESPRITE					= 11,
	DCT_LOADMAPSCENE				= 12,
	DCT_LOADERASESCENE				= 13,
	DCT_REMOVEERASESCENE			= 14,
	DCT_SETCAMERA					= 15,
	DCT_MOVECAMERA					= 16,
	DCT_WAITTIME					= 17,
	DCT_WAITPREACTFINISH			= 18,
	DCT_WAITPREACTFINISHANDCLICK	= 19,
	DCT_SHOWTIPDLG					= 20,
	DCT_OVER						= 21,
	DCT_SPRITE_EFFECT              = 22,
	DCT_SPRITE_REVERSE             = 23,
	DCT_SOUND_EFFECT               = 24,
}DramaCommandType;

typedef enum
{
	ST_NONE							= 0,
	ST_PLAYER						= 1,
	ST_NPC							= 2,
	ST_MONSTER						= 3,
}SpriteType;

typedef struct _tagDramaCommandParam
{
	DramaCommandType	type;
	unsigned int		nKey;
	
	// Í¼ÏñÎÄ¼þÃû or title or content or sprite name or erase in/out scene center text
	std::string str; 

	int m_Pic_CellX; 
	int m_Pic_CellY;
	bool bRightTmp;

	union  
	{
		int		nMapId;
		int		nLookFace;
		int		nAniIndex;
		int		nPosX;
		int		nToPosX;
		int		nFontColor;
		float	fTime;
		bool	bReverse;
	}u1;
	
	union  
	{
		int		nFontSize;
		int		nSpriteType;
		int		nPoxY;
		int		nToPosY;
		bool	bTimeStart;
	}u2;
	
	union  
	{
		bool	bLeft;
		bool	bCameraMove;
		int		nTargetKey;
		bool	bFaceRight;
		int		nMoveStep;
		bool	bTimeout;
	}u3;
}DramaCommandParam;

#endif // _DRAMA_DEF_H_ZJH_
