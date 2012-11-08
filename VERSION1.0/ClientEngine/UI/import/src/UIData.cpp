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
	m_kInfo.strNormalFile = "";
	m_kInfo.strSelectedFile = "";
	m_kInfo.strDisableFile = "";
	m_kInfo.CtrlPos.x = 0;
	m_kInfo.CtrlPos.y = 0;
	m_kInfo.CtrlAnchorPos.x = 0.5f;
	m_kInfo.CtrlAnchorPos.y = 0.5f;
	m_kInfo.nID = 0;
	m_kInfo.nType = 1;
	m_kInfo.nCtrlWidth = 0;
	m_kInfo.nCtrlHeight = 0;
	m_kInfo.strText = "";
	m_kInfo.strTextAlign = "";
	m_kInfo.strTextTradition = "";
	m_kInfo.nTextFontSize = 0;
	m_kInfo.nTextFontColor = 0;
}

CUIData::~CUIData(void)
{

}

bool CUIData::openUiFile(const char* pszIniFile)
{
	m_kINIFile.SetPath(pszIniFile);
	return m_kINIFile.ReadFile();
}

int CUIData::GetCtrlAmount()
{
	//界面文件的第一个SECTION 标识界面大小
	return m_kINIFile.GetKeyAmount() - 1;
}

std::string CUIData::getCtrlName(int nIndex)
{
	return m_kINIFile.GetKeyName(nIndex + 1);
}

bool CUIData::getCtrlData(char* szCtrlName)
{
	if (szCtrlName == 0 || szCtrlName[0] == 0) return false;
	m_kInfo.reset();

	//获取控件图片信息
	m_kInfo.strNormalFile = m_kINIFile.GetValue(szCtrlName, NORMAL_FILE_KEY);
	m_kInfo.strSelectedFile = m_kINIFile.GetValue(szCtrlName, SELECTED_FILE_KEY);
	m_kInfo.strDisableFile = m_kINIFile.GetValue(szCtrlName, DISABLE_FILE_KEY);
	m_kInfo.strFocusFile = m_kINIFile.GetValue(szCtrlName, FOCUS_FILE_KEY);
	m_kInfo.strBackFile = m_kINIFile.GetValue(szCtrlName, BACK_FILE_KEY);

	const char* pszPos = 0;

	//获取POS 宽高，锚点信息
	pszPos = m_kINIFile.GetValue(szCtrlName, CTRL_POS_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%f %f", &m_kInfo.CtrlPos.x, &m_kInfo.CtrlPos.y);

	pszPos = m_kINIFile.GetValue(szCtrlName, CTRL_ANCHORPOS_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%f %f", &m_kInfo.CtrlAnchorPos.x, &m_kInfo.CtrlAnchorPos.y);

	m_kInfo.nCtrlWidth = m_kINIFile.GetValueI(szCtrlName, CTRL_WIDTH_KEY);
	m_kInfo.nCtrlHeight = m_kINIFile.GetValueI(szCtrlName, CTRL_HEIGHT_KEY);

	//取UV 信息
	pszPos = m_kINIFile.GetValue(szCtrlName, NORMAL_FILE_UV_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%d %d %d %d", &m_kInfo.rectNormal.x, &m_kInfo.rectNormal.y,
			&m_kInfo.rectNormal.w, &m_kInfo.rectNormal.h);

	pszPos = m_kINIFile.GetValue(szCtrlName, SELECTED_FILE_UV_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%d %d %d %d", &m_kInfo.rectSelected.x,
			&m_kInfo.rectSelected.y, &m_kInfo.rectSelected.w,
			&m_kInfo.rectSelected.h);

	pszPos = m_kINIFile.GetValue(szCtrlName, DISABLE_FILE_UV_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%d %d %d %d", &m_kInfo.rectDisable.x,
			&m_kInfo.rectDisable.y, &m_kInfo.rectDisable.w,
			&m_kInfo.rectDisable.h);

	pszPos = m_kINIFile.GetValue(szCtrlName, FOCUS_FILE_UV_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%d %d %d %d", &m_kInfo.rectFocus.x, &m_kInfo.rectFocus.y,
			&m_kInfo.rectFocus.w, &m_kInfo.rectFocus.h);

	pszPos = m_kINIFile.GetValue(szCtrlName, BACK_FILE_UV_KEY);
	if (!pszPos)
		return false;
	sscanf(pszPos, "%d %d %d %d", &m_kInfo.rectBack.x, &m_kInfo.rectBack.y,
			&m_kInfo.rectBack.w, &m_kInfo.rectBack.h);

	//取文本信息
	m_kInfo.strText = m_kINIFile.GetValue(szCtrlName, CTRL_TEXT_KEY);
	m_kInfo.strTextAlign = m_kINIFile.GetValue(szCtrlName, CTRL_TEXTALIGN_KEY);
	m_kInfo.strTextTradition = m_kINIFile.GetValue(szCtrlName,
			CTRL_TEXTTRADITION);
	m_kInfo.nTextFontSize = m_kINIFile.GetValueI(szCtrlName, CTRL_TEXTFONTSIZE);
	m_kInfo.nTextFontColor = m_kINIFile.GetValueI(szCtrlName,
			CTRL_TEXTFONTCOLOR);

	//其它信息
	m_kInfo.nID = m_kINIFile.GetValueI(szCtrlName, CTRL_ID_KEY);
	m_kInfo.nType = m_kINIFile.GetValueI(szCtrlName, CTRL_TYPE_KEY);

	return true;
}

std::string CUIData::getNormalFile()
{
	return m_kInfo.strNormalFile;
}

std::string CUIData::getSelectedFile()
{
	return m_kInfo.strSelectedFile;
}

std::string CUIData::getDisableFile()
{
	return m_kInfo.strDisableFile;
}

std::string CUIData::getFocusFile()
{
	return m_kInfo.strFocusFile;
}

std::string CUIData::getBackFile()
{
	return m_kInfo.strBackFile;
}

string CUIData::GetValKeyStr(const char* pszString)
{
	if (!pszString)
	{
		return "";
	}

	if (DISPLAY_RESOLUTION_BEGIN > m_kDisplayResolution
			|| DISPLAY_RESOLUTION_END <= m_kDisplayResolution)
	{
		return std::string(pszString);
	}

	return std::string(pszString);
}