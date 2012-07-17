/*
 *  NDUILoad.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDUILoad.h"
#include "NDControlHelp.h"
#include "UIData.h"
#include "NDDirector.h"



IMPLEMENT_CLASS(NDUILoad, NDObject)

unsigned int inline findAndReplace(
		std::string& source, 
		const std::string& find, 
		const std::string& replace, 
		unsigned int time=0 ) 
{     
	unsigned int num=0;     
	size_t fLen = find.size();
	size_t rLen = replace.size();     
	for (size_t pos=0; (pos=source.find(find, pos))!=std::string::npos; pos+=rLen)     
	{         
		source.replace(pos, fLen, replace); 
		
		if (time > 0 && ++num >= time)
			break;
	}     
	return num; 
}

bool FilterStringName(UIINFO& uiInfo)
{
	if (!uiInfo.strNormalFile.empty())
	{
		findAndReplace(uiInfo.strNormalFile, ".", "", 1);
		findAndReplace(uiInfo.strNormalFile, "\r", "", 1);
		findAndReplace(uiInfo.strNormalFile, "\\", "/");
	}
	
	if (!uiInfo.strSelectedFile.empty())
	{
		findAndReplace(uiInfo.strSelectedFile, ".", "", 1);
		findAndReplace(uiInfo.strSelectedFile, "\r", "", 1);
		findAndReplace(uiInfo.strSelectedFile, "\\", "/");
	}
	
	if (!uiInfo.strDisableFile.empty())
	{
		findAndReplace(uiInfo.strDisableFile, ".", "", 1);
		findAndReplace(uiInfo.strDisableFile, "\r", "", 1);
		findAndReplace(uiInfo.strDisableFile, "\\", "/");
	}
	
	if (!uiInfo.strFocusFile.empty())
	{
		findAndReplace(uiInfo.strFocusFile, ".", "", 1);
		findAndReplace(uiInfo.strFocusFile, "\r", "", 1);
		findAndReplace(uiInfo.strFocusFile, "\\", "/");
	}
	
	if (!uiInfo.strBackFile.empty())
	{
		findAndReplace(uiInfo.strBackFile, ".", "", 1);
		findAndReplace(uiInfo.strBackFile, "\r", "", 1);
		findAndReplace(uiInfo.strBackFile, "\\", "/");
	}
	
	if (!uiInfo.strText.empty())
	{
		findAndReplace(uiInfo.strText, "\r", "", 1);
	}
	
	if (!uiInfo.strTextAlign.empty())
	{
		findAndReplace(uiInfo.strTextAlign, "\r", "", 1);
	}
	
	return true;
}

bool FilterCtrlUV(CTRL_UV& uv)
{
	float scale = NDDirector::DefaultDirector()->GetScaleFactor();
	uv.x	*= scale;
	uv.y	*= scale;
	uv.w	*= scale;
	uv.h	*= scale;
	
	return true;
}

bool FilterPos(CGPoint& pos)
{
	float scale = NDDirector::DefaultDirector()->GetScaleFactor();
	pos.x	*= scale;
	pos.y	*= scale;
	
	return true;
}

bool FilterSize(UIINFO& uiInfo)
{/*
	FilterCtrlUV(uiInfo.rectNormal);
	FilterCtrlUV(uiInfo.rectSelected);
	FilterCtrlUV(uiInfo.rectDisable);
	FilterCtrlUV(uiInfo.rectFocus);
	FilterCtrlUV(uiInfo.rectBack);*/
	
	FilterPos(uiInfo.CtrlPos);

	float scale = NDDirector::DefaultDirector()->GetScaleFactor();
	uiInfo.nCtrlWidth		*= scale;
	uiInfo.nCtrlHeight		*= scale;
	
	
	return true;
}

bool NDUILoad::Load(
		  const char* uiname,
		  NDUINode *parent, 
		  NDUITargetDelegate* delegate, 
		  CGSize sizeOffset /*= CGSizeZero*/)
{
	if (!uiname || !parent)
	{
		NDAsssert(0);
		
		return false;
	}
	
	CUIData uiData;
	
	if ( !uiData.openUiFile(NDPath::GetUIConfigPath(uiname)) )
	{
		NDAsssert(0);
		
		return false;
	}
	
	int nCtrlAmount = uiData.GetCtrlAmount();
	
	for(int i=0; i<nCtrlAmount; i++)
	{
		std::string str = uiData.getCtrlName(i);
		
		if (!uiData.getCtrlData((char*)str.c_str()))
		{
			NDAsssert(0);
			continue;
		}
		
		UIINFO& uiInfo = uiData.getCtrlUiInfo();
	
		
		FilterStringName(uiInfo);
		
#ifdef TRADITION		
//		if (IsTraditionalChinese()) 
//		{
			uiInfo.strText = uiInfo.strTextTradition;
//		}
#endif
		
		FilterSize(uiInfo);
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		// 使用opengl坐标系
		uiInfo.CtrlPos.y = winsize.height - uiInfo.CtrlPos.y;
		
		CGPoint CtrlAnchorPos = uiInfo.CtrlAnchorPos;
		
		if (!(0.0f == CtrlAnchorPos.x || 0.5f == CtrlAnchorPos.x || 1.0f == CtrlAnchorPos.x)
			|| !(0.0f == CtrlAnchorPos.y || 0.5f == CtrlAnchorPos.y || 1.0f == CtrlAnchorPos.y))
		{
			NDAsssert(0);
			continue;
		}
		
		if (CtrlAnchorPos.y != 0.5f)
		{
			CtrlAnchorPos.y = CtrlAnchorPos.y == 0.0f ? 1.0f : 0.0f;
		}
		
		if (0.0f == CtrlAnchorPos.x && 0.0f == CtrlAnchorPos.y)
		{ // [0,0]
		}
		else if (0.0f == CtrlAnchorPos.x && 1.0f == CtrlAnchorPos.y)
		{ // [0, 1]
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight;
		}
		else if (1.0f == CtrlAnchorPos.x && 0.0f == CtrlAnchorPos.y)
		{ // [1, 0]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth;
		}
		else if (1.0f == CtrlAnchorPos.x && 1.0f == CtrlAnchorPos.y)
		{ // [1, 1]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth;
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight;
		}
		else if (0.5f == CtrlAnchorPos.x && 0.5 == CtrlAnchorPos.y)
		{ // [1, 1]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth / 2;
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight / 2;
		}
		else
		{
			NDAsssert(0);
			continue;
		}
		
		NDUINode* node = NULL;
		
		switch (uiInfo.nType) 
		{
			case MY_CONTROL_TYPE_UNKNOWN:
			{
				ControlHelp<MY_CONTROL_TYPE_UNKNOWN> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_PICTURE:
			{
				ControlHelp<MY_CONTROL_TYPE_PICTURE> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_CHECK_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_CHECK_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_TEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_TEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_LIST:
			{
				ControlHelp<MY_CONTROL_TYPE_LIST> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_PROGRESS:
			{
				ControlHelp<MY_CONTROL_TYPE_PROGRESS> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_SLIDER:
			{
				ControlHelp<MY_CONTROL_TYPE_SLIDER> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_BACK:
			{
				ControlHelp<MY_CONTROL_TYPE_BACK> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_TABLE:
			{
				ControlHelp<MY_CONTROL_TYPE_TABLE> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_UITEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_UITEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_HYPER_TEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_HYPER_TEXT_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_LIST_M:
			{
				ControlHelp<MY_CONTROL_TYPE_LIST_M> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_ITEM_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_ITEM_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EQUIP_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_EQUIP_BUTTON> help;
				node = (NDUINode*)(help.Create(uiInfo, sizeOffset));
			}
				break;
			case MY_CONTROL_TYPE_RADIO_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_RADIO_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EXP:
			{
				ControlHelp<MY_CONTROL_TYPE_EXP> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EDIT:
			{
				ControlHelp<MY_CONTROL_TYPE_EDIT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_SPRITE:
			{
				ControlHelp<MY_CONTROL_TYPE_SPRITE> help;
				(NDUINode*)node = help.Create(uiInfo, sizeOffset);
			}
				break;
			default:
				break;
		}
		
		if (!node)
		{
			//NDAsssert(0);
			continue;
		}
		
		node->SetTag(uiInfo.nID);
		
		parent->AddChild(node);
		
		node->SetTargetDelegate(delegate);
	}
	
	return true;
}

bool NDUILoad::LoadLua(
		  const char* uiname,
		  NDUINode *parent, 
		  LuaObject luaDelegate,
		  float sizeOffsetW /*= 0.0f*/,
		  float sizeOffsetH /*= 0.0f*/)
{
	if (!uiname || !parent)
	{
		NDAsssert(0);
		
		return false;
	}
	
	CUIData  uiData;
	
	if ( !uiData.openUiFile(NDPath::GetUIConfigPath(uiname)) )
	{
		NDAsssert(0);
		
		return false;
	}
	
	CGSize sizeOffset = CGSizeMake(sizeOffsetW, sizeOffsetH);
	
	int nCtrlAmount = uiData.GetCtrlAmount();
	
	for(int i=0; i<nCtrlAmount; i++)
	{
		std::string str = uiData.getCtrlName(i);
		
		if (!uiData.getCtrlData((char*)str.c_str()))
		{
			NDAsssert(0);
			continue;
		}
		
		UIINFO& uiInfo = uiData.getCtrlUiInfo();
		
		
		FilterStringName(uiInfo);
		
#ifdef TRADITION		
		//		if (IsTraditionalChinese()) 
		//		{
		uiInfo.strText = uiInfo.strTextTradition;
		//		}
#endif

		FilterSize(uiInfo);

		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		// 使用opengl坐标系
		uiInfo.CtrlPos.y = winsize.height - uiInfo.CtrlPos.y;
		
		CGPoint CtrlAnchorPos = uiInfo.CtrlAnchorPos;
		
		if (!(0.0f == CtrlAnchorPos.x || 0.5f == CtrlAnchorPos.x || 1.0f == CtrlAnchorPos.x)
			|| !(0.0f == CtrlAnchorPos.y || 0.5f == CtrlAnchorPos.y || 1.0f == CtrlAnchorPos.y))
		{
			NDAsssert(0);
			continue;
		}
		
		if (CtrlAnchorPos.y != 0.5f)
		{
			CtrlAnchorPos.y = CtrlAnchorPos.y == 0.0f ? 1.0f : 0.0f;
		}
		
		if (0.0f == CtrlAnchorPos.x && 0.0f == CtrlAnchorPos.y)
		{ // [0,0]
		}
		else if (0.0f == CtrlAnchorPos.x && 1.0f == CtrlAnchorPos.y)
		{ // [0, 1]
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight;
		}
		else if (1.0f == CtrlAnchorPos.x && 0.0f == CtrlAnchorPos.y)
		{ // [1, 0]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth;
		}
		else if (1.0f == CtrlAnchorPos.x && 1.0f == CtrlAnchorPos.y)
		{ // [1, 1]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth;
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight;
		}
		else if (0.5f == CtrlAnchorPos.x && 0.5 == CtrlAnchorPos.y)
		{ // [1, 1]
			uiInfo.CtrlPos.x = uiInfo.CtrlPos.x - uiInfo.nCtrlWidth / 2;
			uiInfo.CtrlPos.y = uiInfo.CtrlPos.y - uiInfo.nCtrlHeight / 2;
		}
		else
		{
			NDAsssert(0);
			continue;
		}
		
		NDUINode* node = NULL;
		
		switch (uiInfo.nType) 
		{
			case MY_CONTROL_TYPE_UNKNOWN:
			{
				ControlHelp<MY_CONTROL_TYPE_UNKNOWN> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_PICTURE:
			{
				ControlHelp<MY_CONTROL_TYPE_PICTURE> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_CHECK_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_CHECK_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_TEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_TEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_LIST:
			{
				ControlHelp<MY_CONTROL_TYPE_LIST> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_PROGRESS:
			{
				ControlHelp<MY_CONTROL_TYPE_PROGRESS> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_SLIDER:
			{
				ControlHelp<MY_CONTROL_TYPE_SLIDER> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_BACK:
			{
				ControlHelp<MY_CONTROL_TYPE_BACK> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_TABLE:
			{
				ControlHelp<MY_CONTROL_TYPE_TABLE> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_UITEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_UITEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_HYPER_TEXT:
			{
				ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_HYPER_TEXT_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_LIST_M:
			{
				ControlHelp<MY_CONTROL_TYPE_LIST_M> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_ITEM_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_ITEM_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EQUIP_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_EQUIP_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_RADIO_BUTTON:
			{
				ControlHelp<MY_CONTROL_TYPE_RADIO_BUTTON> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EXP:
			{
				ControlHelp<MY_CONTROL_TYPE_EXP> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_EDIT:
			{
				ControlHelp<MY_CONTROL_TYPE_EDIT> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			case MY_CONTROL_TYPE_SPRITE:
			{
				ControlHelp<MY_CONTROL_TYPE_SPRITE> help;
				node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			}
				break;
			default:
				break;
		}
		
		if (!node)
		{
			//NDAsssert(0);
			continue;
		}
		
		node->SetTag(uiInfo.nID);
		
		parent->AddChild(node);
		
		if (luaDelegate.IsFunction())
			node->SetLuaDelegate(luaDelegate);
	}
	
	return true;
}