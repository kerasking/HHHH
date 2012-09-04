/*
 *  DramaCommand.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _DRAMA_COMMAND_H_ZJH_
#define _DRAMA_COMMAND_H_ZJH_

#include "DramaCommandBase.h"
#include "NDTimer.h"

///////////////////////////////////////////////
class DramaCommandDlg: public DramaCommandBase
{
public:

	void InitWithOpen(bool bLeft);
	void InitWithClose(bool bLeft);
	void InitWithSetFigure(bool bLeft, std::string filename, bool bReverse);
	void InitWithSetTitle(bool bLeft, std::string title, int nFontSize,
			int nFontColor);
	void InitWithSetTitleBySpriteKey(bool bLeft, int nKey, int nFontSize,
			int nFontColor);
	void InitWithSetContent(bool bLeft, std::string content, int nFontSize,
			int nFontColor);
	void InitWithTip(std::string content);
	virtual void excute();

protected:
private:
};

///////////////////////////////////////////////
class DramaCommandSprite: public DramaCommandBase
{
public:

	void InitWithAdd(int nLookFace, int nType, bool faceRight,
			std::string name);
	void InitWithAddByFile(std::string filename);
	void InitWithRemove(int nKey);
	void InitWithSetAnimation(int nKey, int nAniIndex);
	void InitWithSetPos(int nKey, int nPosX, int nPosY);
	void InitWithMove(int nKey, int nToPosX, int nToPosY, int nStep);
	virtual void excute();

private:

	void ExcuteAddSprite();
	void ExcuteAddSpriteByFile();
	void ExcuteRemoveSprite();
	void ExcuteSetAnimation();
	void ExcuteSetPostion();
	void ExcuteMoveSprite();
};

///////////////////////////////////////////////
class DramaCommandScene: public DramaCommandBase
{
public:

	void InitWithLoadDrama(int nMapId);
	void InitWithFinishDrama();
	void InitWithLoad(std::string centerText, int nFontSize, int nFontColor);
	void InitWithRemove(int nKey);
	virtual void excute();

private:

	void ExcuteLoadDramaScene();
	void ExcuteFinishDrama();
	void ExcuteLoadEraseScene();
	void ExcuteRemoveEraseScene();
};

///////////////////////////////////////////////
class DramaCommandCamera: public DramaCommandBase
{
public:

	void InitWithSetPos(int nPosX, int nPosY);
	void InitWithMove(int nToPosX, int nToPosY, int nStep);
	virtual void excute();

private:

	void ExcuteSetPosition();
	void ExcuteMovePostion();
};

///////////////////////////////////////////////
class DramaCommandWait: public DramaCommandBase, public ITimerCallback
{
public:

	void InitWithWait(float fTime);
	void InitWithWaitPreActionFinish();
	void InitWithWaitPreActFinishAndClick();
	virtual void excute();

private:

	void ExcuteWaitTime();
	void ExcuteWaitPreAction();
	void ExcuteWaitPreActionAndClick();

public:

	void OnTimer(OBJID tag);

private:

	NDTimer m_timer;
};

#endif // _DRAMA_COMMAND_H_ZJH_
