//#include "StdAfx.h"
#include "UIData.h"
#include <stdio.h>


#define NORMAL_FILE_KEY  "NormalFile"
#define SELECTED_FILE_KEY  "SelectFile"
#define DISABLE_FILE_KEY  "DisableFile"
#define FOCUS_FILE_KEY  "FocusFile"
#define BACK_FILE_KEY "BackFile"

#define NORMAL_FILE_UV_KEY  "NormalFileUV"
#define SELECTED_FILE_UV_KEY  "SelectedFileUV"
#define DISABLE_FILE_UV_KEY  "DisableFileUV"
#define FOCUS_FILE_UV_KEY  "FocusFileUV"
#define BACK_FILE_UV_KEY "BackFileUV"

#define CTRL_POS_KEY  "Pos"
#define CTRL_WIDTH_KEY  "Width"
#define CTRL_HEIGHT_KEY  "Height"

#define CTRL_ANCHORPOS_KEY "AnchorPos"
#define CTRL_TEXT_KEY "Text"
#define CTRL_TEXTALIGN_KEY "TextAlign"
#define CTRL_ID_KEY "Tag"
#define CTRL_TYPE_KEY "Type"
#define CTRL_TEXTTRADITION "TextTradition"

#define CTRL_TEXTFONTSIZE "TextSize"
#define CTRL_TEXTFONTCOLOR "TextColor"

CUIData::CUIData(void)
{
	m_info.strNormalFile		= "";
	m_info.strSelectedFile		= "";
	m_info.strDisableFile		= "";
	m_info.CtrlPos.x			= 0;	
	m_info.CtrlPos.y			= 0;
	m_info.CtrlAnchorPos.x		= 0.5f;
	m_info.CtrlAnchorPos.y		= 0.5f;
	m_info.nID					= 0;
	m_info.nType				=1;
	m_info.nCtrlWidth			=0;
	m_info.nCtrlHeight			=0;
	m_info.strText				= "";
	m_info.strTextAlign			= "";
	m_info.strTextTradition		= "";
	m_info.nTextFontSize		= 0;
	m_info.nTextFontColor		= 0;
}

CUIData::~CUIData(void)
{

}


bool CUIData::openUiFile(const char* pszIniFile)
{
	ini.SetPath(pszIniFile);
	return ini.ReadFile();
}


int  CUIData::GetCtrlAmount()
{

	//界面文件的第一个SECTION 标识界面大小
	return ini.GetKeyAmount()-1;

}

std::string CUIData::getCtrlName(int nIndex)
{

	return ini.GetKeyName(nIndex+1);

}

bool CUIData::getCtrlData(char* szCtrlName)
{
	//获取控件图片信息
	m_info.strNormalFile	= ini.GetValue(szCtrlName,NORMAL_FILE_KEY);
	m_info.strSelectedFile	= ini.GetValue(szCtrlName,SELECTED_FILE_KEY);
	m_info.strDisableFile	= ini.GetValue(szCtrlName,DISABLE_FILE_KEY);
	m_info.strFocusFile		= ini.GetValue(szCtrlName,FOCUS_FILE_KEY);
	m_info.strBackFile		= ini.GetValue(szCtrlName,BACK_FILE_KEY);

	const char* pPos;

	//获取POS 宽高，锚点信息

	
	


	pPos= ini.GetValue( szCtrlName, CTRL_POS_KEY );

	if(!pPos)
		return false;
	sscanf(pPos, "%f %f", &m_info.CtrlPos.x, &m_info.CtrlPos.y);


	pPos= ini.GetValue( szCtrlName, CTRL_ANCHORPOS_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%f %f", &m_info.CtrlAnchorPos.x, &m_info.CtrlAnchorPos.y );


	m_info.nCtrlWidth	= ini.GetValueI(szCtrlName,CTRL_WIDTH_KEY);
	m_info.nCtrlHeight	= ini.GetValueI(szCtrlName,CTRL_HEIGHT_KEY);



	//取UV 信息
	pPos = ini.GetValue( szCtrlName, NORMAL_FILE_UV_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%d %d %d %d", &m_info.rectNormal.x, &m_info.rectNormal.y, &m_info.rectNormal.w, &m_info.rectNormal.h);

	pPos = ini.GetValue( szCtrlName, SELECTED_FILE_UV_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%d %d %d %d", &m_info.rectSelected.x, &m_info.rectSelected.y, &m_info.rectSelected.w, &m_info.rectSelected.h);


	pPos = ini.GetValue( szCtrlName, DISABLE_FILE_UV_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%d %d %d %d", &m_info.rectDisable.x, &m_info.rectDisable.y, &m_info.rectDisable.w, &m_info.rectDisable.h);


	pPos = ini.GetValue( szCtrlName, FOCUS_FILE_UV_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%d %d %d %d", &m_info.rectFocus.x, &m_info.rectFocus.y, &m_info.rectFocus.w, &m_info.rectFocus.h);

	pPos = ini.GetValue( szCtrlName, BACK_FILE_UV_KEY );
	if(!pPos)
		return false;
	sscanf( pPos, "%d %d %d %d", &m_info.rectBack.x, &m_info.rectBack.y, &m_info.rectBack.w, &m_info.rectBack.h);

	//取文本信息
	m_info.strText			= ini.GetValue(szCtrlName,CTRL_TEXT_KEY);
	m_info.strTextAlign		= ini.GetValue(szCtrlName,CTRL_TEXTALIGN_KEY);	
	m_info.strTextTradition = ini.GetValue(szCtrlName,CTRL_TEXTTRADITION);
	m_info.nTextFontSize	= ini.GetValueI(szCtrlName,CTRL_TEXTFONTSIZE);
	m_info.nTextFontColor	= ini.GetValueI(szCtrlName,CTRL_TEXTFONTCOLOR);
	
	

	//其它信息
	m_info.nID				= ini.GetValueI(szCtrlName,CTRL_ID_KEY);
	m_info.nType			= ini.GetValueI(szCtrlName,CTRL_TYPE_KEY);

	return true;
}


std::string CUIData::getNormalFile()
{
	return m_info.strNormalFile;
}

std::string CUIData::getSelectedFile()
{
	return m_info.strSelectedFile;
}

std::string CUIData::getDisableFile()
{
	return m_info.strDisableFile;
}

std::string CUIData::getFocusFile()
{
	return m_info.strFocusFile;
}

std::string CUIData::getBackFile()
{
	return m_info.strBackFile;
}



