/////////////////////////////
//控件信息获取,从界面编辑器的导出数据中获取控件信息
//write by yay
//2011-11-22
///////////////////////////////


/*
使用

CUIData  uiData;
uiData.opeUiFile("data/ini/1.ini");

int nCtrlAmount = uidata.GetCtrlAmount();
for(int i=0; i<nCtrlAmount; i++)
{
	std:string str = uidata.getCtrlName(0);
	uidata.getCtrlData((char*)str.c_str()); 

	unsigned long nType = uidata.getType();	

	//here creat ctrl
	//取控件坐标
	cocos2d::CCPoint ctrlPos = uidata.getPos();	
	//取控件锚点值
	cocos2d::CCPoint AnchorPos = uidata.getAnchorPoint();	 
	//取控件ID 
	unsigned long nTag = uidata.getID();	
	//取控件类型

	switch(nType)
	{
	case 1;

	break;

	case 2:
	break;
	}

}

*/

#pragma once

#include <string>
#include "cocos2d.h"
#include "CCPointExtension.h"
#include "IniFile.h"
#include "UtilityInc.h"

enum DISPLAY_RESOLUTION
{
	DISPLAY_RESOLUTION_BEGIN,
	DISPLAY_RESOLUTION_480_320				= DISPLAY_RESOLUTION_BEGIN,
	DISPLAY_RESOLUTION_960_640,
	DISPLAY_RESOLUTION_1024_768,
	DISPLAY_RESOLUTION_2048_1536,
	DISPLAY_RESOLUTION_END,
};

struct CTRL_UV
{
	CTRL_UV()
	{
		x = 0;
		y = 0;
		w = 0;
		h = 0;
	}
	int x;
	int y;
	int w;
	int h;

	void reset() {
		x = y = w = h = 0;
	}
};

struct UIINFO
{
	std::string strNormalFile;
	std::string strSelectedFile;
	std::string strDisableFile;
	std::string strFocusFile;
	std::string strBackFile;

	CTRL_UV rectNormal;
	CTRL_UV rectSelected;
	CTRL_UV rectDisable;
	CTRL_UV rectFocus;
	CTRL_UV rectBack;

    cocos2d::CCPoint CtrlPos;
    cocos2d::CCPoint CtrlAnchorPos;

	unsigned long   nID;
	unsigned long   nType;

	float			nCtrlWidth;
	float			nCtrlHeight;

	std::string strText;
	std::string strTextAlign;
	std::string strTextTradition;
	
	unsigned long nTextFontSize;
	unsigned long nTextFontColor;

	void reset()
	{
		strNormalFile = "";
		strSelectedFile = "";
		strDisableFile = "";
		strFocusFile = "";
		strBackFile = "";

		rectNormal.reset();
		rectSelected.reset();
		rectDisable.reset();
		rectFocus.reset();
		rectBack.reset();

		CtrlPos.x = CtrlPos.y = 0.f;
		CtrlAnchorPos.x = CtrlAnchorPos.y = 0.f;

		nID = 0;
		nType = 0;
		nCtrlWidth = 0.0f;
		nCtrlHeight = 0.0f;

		strText = "";
		strTextAlign = "";
		strTextTradition = "";

		nTextFontSize = 0;
		nTextFontColor = 0;
	}

	UIINFO() { this->reset(); }
};

class CUIData
{
public:
	CUIData(void);
	~CUIData(void);
public:
	bool openUiFile(const char* pszIniFile);
	int  GetCtrlAmount();
	std::string getCtrlName(int nIndex);
	bool getCtrlData(char* szCtrlName);


	UIINFO& getCtrlUiInfo()
	{
		return m_kInfo;
	}

	float getCtrlWidth()
	{
		return m_kInfo.nCtrlWidth;
	}

	float getCtrlHeight()
	{
		return m_kInfo.nCtrlHeight;
	}

	//控件图片路径，注（为相对路径）
	std::string getNormalFile();
	std::string getSelectedFile();
	std::string getDisableFile();
	std::string getFocusFile();
	std::string getBackFile();

	//取控件图片的UV信息
	CTRL_UV getNormalFileUV()
	{
		return m_kInfo.rectNormal;
	}
	CTRL_UV getSelectedFileUV()
	{
		return m_kInfo.rectSelected;
	}
	CTRL_UV getDisableFileUV()
	{
		return m_kInfo.rectDisable;
	}
	CTRL_UV ggetFocusFileUV()
	{
		return m_kInfo.rectFocus;
	}
	
	CTRL_UV ggetBackFileUV()
	{
		return m_kInfo.rectBack;
	}


	//取控件坐标，[注：锚点坐标]
    cocos2d::CCPoint getPos()
	{
		return m_kInfo.CtrlPos;
	}

	//取控件锚点值
	cocos2d::CCPoint getAnchorPoint()
	{
		return m_kInfo.CtrlAnchorPos;
	}

	//取控件ID 
	unsigned long getID()
	{
		return m_kInfo.nID;
	}

	//取控件类型
	unsigned long getType()	
	{
		return m_kInfo.nType;
	}

	//取控件文本内容
	std::string getCtrlText()
	{
		return m_kInfo.strText;
	}

	//取文本对齐方式
	std::string getCtrlTextAlign()
	{
		return m_kInfo.strTextAlign;
	}

	CIniFile& getIniFile() { return m_kINIFile; }

private:

	string GetValKeyStr(const char* str);

	UIINFO m_kInfo;
	CIniFile m_kINIFile;
	DISPLAY_RESOLUTION m_kDisplayResolution;
};
