#ifndef _INIT_MENU_SCENE_H_
#define _INIT_MENU_SCENE_H_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUILayer.h"
#include "NDPicture.h"
#include "NDUIDialog.h"
#include "NDSprite.h"
#include "NDUICustomView.h"
#include "UIImageCombiner.h"
#include "NDTimer.h"
#include "NDCombinePicture.h"

using namespace NDEngine;


class InitMenuScene : public NDScene, 
					public NDUIButtonDelegate, 
					public NDUIDialogDelegate, 
					public NDUICustomViewDelegate,
					public ITimerCallback
{
	DECLARE_CLASS(InitMenuScene)
	
	enum ChooseType
	{
		ctBegin			= 0,

		ctQuickGame = ctBegin,
		ctLogin,
		ctRegister,
		ctGameSetting,
		ctGameHelp,
		ctQuit,
		ctEnd,
	};
	
public:
	InitMenuScene();
	~InitMenuScene();
public:
	static InitMenuScene* Scene(bool bShowNetError=false);
	void Initialization(bool bShowNetError=false); override 
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	void OnTimer(OBJID tag); override

	void FastGameOrRegisterTip(int iType);

private:
	void UpdateChooseBtn(bool bUpdate);
	void InitBtnRelate();
	void OnClickChooseBtn(ChooseType ctIndex);
	
	NDCombinePicture* GetMenuTextCombinePic(ChooseType ctIndex, bool focus);
	NDPicture* GetMenuTextPic(std::string text, bool focus, bool first, bool bParticular=false);
	
	NDCombinePicture* GetVerTextCombinePic(std::string strver);
	NDPicture* GetVerTextPic(char cChar);
	
	void SetMenuBtnIndexImg(ChooseType ctIndex, bool focus);
	
	void SetMenuBtnImg(NDUIButton *btn, bool focus);
	
private:
	NDUILayer* m_Layer;
	
	NDUIButton	*m_btnLeft, *m_btnRight, *m_btnChoose[ctEnd]; 
	NDPicture* m_leftArrowImage, *m_leftArrowHightlightImage;
	NDPicture* m_rightArrowImage, *m_rightArrowHightlightImage;
	NDUIButton* m_btnFocus;
	
	NDPicture* m_focusImg[ctEnd];
	NDCombinePicture *m_cpicMenuText[ctEnd][2];
private:
	int m_iFirstIndex;
	int m_iCurrIndex;
	NDUIDialog	*m_dlgTip; 
	int iTipType; //1 快速注册 , 2 快速游戏

	NDTimer m_timer;
	std::string m_fileUrl, m_latestVersion;
	bool IsLatestVersion(std::string& fileUrl, std::string& latestVersion);
};

#endif // _INIT_MENU_SCENE_H_