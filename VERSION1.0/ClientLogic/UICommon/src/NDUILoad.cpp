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


#define ISEQUAL(a,b)		(TAbs((a)-(b))<0.0001f)
#define ISEQUAL_PT(pt,a,b)	(ISEQUAL(pt.x,a) && ISEQUAL(pt.y,b))

IMPLEMENT_CLASS(NDUILoad, NDObject)

class NDUILoad_Util
{
public:
	static unsigned int inline findAndReplace(
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

	static bool FilterStringName(UIINFO& uiInfo)
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
};

/////////////////////////////////////////////////////////////////////////////////////////////

//for cpp
bool NDUILoad::Load(
		  const char* uiname,
		  NDUINode *parent, 
		  NDUITargetDelegate* delegate, 
		  CCSize sizeOffset /*= CCSizeZero*/)
{
	return LoadAny( uiname, parent, delegate, NULL, sizeOffset );
}

//for LUA
bool NDUILoad::LoadLua(
		  const char* uiname,
		  NDUINode *parent, 
		  LuaObject luaDelegate,
		  float sizeOffsetW /*= 0.0f*/,
		  float sizeOffsetH /*= 0.0f*/)
{
	return LoadAny( uiname, parent, NULL, &luaDelegate, CCSizeMake(sizeOffsetW, sizeOffsetH));
}

// forCpp & forLua都转这儿处理
bool NDUILoad::LoadAny( const char* uiname, NDUINode *parent, 
					   NDUITargetDelegate* delegate, LuaObject* luaDelegate,
					   CCSize sizeOffset /*= CCSizeZero*/ )
{
	if (!uiname || !parent) return false;

	// open ui file
	CUIData  uiData;	
	if ( !uiData.openUiFile(NDPath::GetUIConfigPath(uiname).c_str()) )
	{
		NDAsssert(0);
		return false;
	}

	// load all controlls
	int nCtrlAmount = uiData.GetCtrlAmount();
	for(int i = 0; i < nCtrlAmount; i++)
	{
		NDUINode* node = this->LoadCtrl( uiData, i, parent, sizeOffset );
		if (node)
		{
			if (delegate)
			{
				node->SetTargetDelegate(delegate);
			}
			else if (luaDelegate && luaDelegate->IsFunction())
			{
				node->SetLuaDelegate( *luaDelegate );
			}
		}
	}

	return true;
}

NDUINode* NDUILoad::LoadCtrl( CUIData& uiData, const int ctrlIndex, NDUINode *parent, const CCSize& sizeOffset )
{
	std::string str = uiData.getCtrlName( ctrlIndex );

	if (!uiData.getCtrlData((char*)str.c_str()))
	{
		NDAsssert(0);
		return false;
	}

	UIINFO& uiInfo = uiData.getCtrlUiInfo();

	NDUILoad_Util::FilterStringName(uiInfo);

#ifdef TRADITION		
	//		if (IsTraditionalChinese())
	//		{
	uiInfo.strText = uiInfo.strTextTradition;
	//		}
#endif

	PostLoad(uiInfo);

	// check anchor pos
	CCPoint CtrlAnchorPos = uiInfo.CtrlAnchorPos;
	if (!IsAnchorValid(CtrlAnchorPos.x) || !IsAnchorValid(CtrlAnchorPos.y))
	{
		NDAsssert(0);
		return false;
	}
	
	// 上下对调一下（结果仍旧是像素单位，不是GL坐标，所以不能用SCREEN2GL转！）
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	uiInfo.CtrlPos.y = winsize.height - uiInfo.CtrlPos.y;

	// 根据锚地调整控件位置
	CtrlAnchorPos.y = 1.0f - CtrlAnchorPos.y;
	AdjustCtrlPosByAnchor( uiInfo, CtrlAnchorPos );

	// 创建控件
	const char* ctrlTypeName = NULL;
	NDUINode* node = this->CreateCtrl( uiInfo, sizeOffset, ctrlTypeName );

	if (!node)
	{
		CCLog( "@@ CreateCtrl() failed: type=%d\r\n", uiInfo.nType );
		//NDAsssert(0);
		return false;
	}

	node->SetTag(uiInfo.nID);
	if (parent)
	{
		parent->AddChild(node);
	}
	return node;
}

bool NDUILoad::IsAnchorValid( const float anchor )
{
	return ISEQUAL(anchor,0.f) || ISEQUAL(anchor,1.f) || ISEQUAL(anchor,0.5f);
}

void NDUILoad::AdjustCtrlPosByAnchor( UIINFO& uiInfo, const CCPoint& CtrlAnchorPos )
{
	// adjust pos by anchor pos
	if (ISEQUAL_PT(CtrlAnchorPos,0,0))
	{ // [0,0]
	}
	else if (ISEQUAL_PT(CtrlAnchorPos,0,1))
	{ // [0, 1]
		uiInfo.CtrlPos.y -= (float)uiInfo.nCtrlHeight;
	}
	else if (ISEQUAL_PT(CtrlAnchorPos,1,0))
	{ // [1, 0]
		uiInfo.CtrlPos.x -= (float)uiInfo.nCtrlWidth;
	}
	else if (ISEQUAL_PT(CtrlAnchorPos,1,1))
	{ // [1, 1]
		uiInfo.CtrlPos.x -= (float)uiInfo.nCtrlWidth;
		uiInfo.CtrlPos.y -= (float)uiInfo.nCtrlHeight;
	}
	else if (ISEQUAL_PT(CtrlAnchorPos,0.5,0.5))
	{ // [.5, .5]
		uiInfo.CtrlPos.x -= 0.5f * uiInfo.nCtrlWidth;
		uiInfo.CtrlPos.y -= 0.5f * uiInfo.nCtrlHeight;
	}
	else
	{
		//treat as [0,0]
	}
}

NDUINode* NDUILoad::CreateCtrl( UIINFO& uiInfo, CCSize sizeOffset, const char*& ctrlTypeName )
{
	NDUINode* node = NULL;

#ifdef ANDROID
	uiInfo.nCtrlHeight = uiInfo.nCtrlHeight * 2;
	uiInfo.nCtrlWidth = uiInfo.nCtrlWidth * 2;
#endif

	switch (uiInfo.nType) 
	{
	case MY_CONTROL_TYPE_UNKNOWN:
		{
			ControlHelp<MY_CONTROL_TYPE_UNKNOWN> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_UNKNOWN";
		}
		break;
	case MY_CONTROL_TYPE_PICTURE:
		{
			ControlHelp<MY_CONTROL_TYPE_PICTURE> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_PICTURE";
		}
		break;
	case MY_CONTROL_TYPE_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_CHECK_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_CHECK_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_CHECK_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_TEXT:
		{
			ControlHelp<MY_CONTROL_TYPE_TEXT> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_TEXT";
		}
		break;
	case MY_CONTROL_TYPE_LIST:
		{
			ControlHelp<MY_CONTROL_TYPE_LIST> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST";
		}
		break;
	case MY_CONTROL_TYPE_PROGRESS:
		{
			ControlHelp<MY_CONTROL_TYPE_PROGRESS> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_PROGRESS";
		}
		break;
	case MY_CONTROL_TYPE_SLIDER:
		{
			ControlHelp<MY_CONTROL_TYPE_SLIDER> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_SLIDER";
		}
		break;
	case MY_CONTROL_TYPE_BACK:
		{
			ControlHelp<MY_CONTROL_TYPE_BACK> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_BACK";
		}
		break;
	case MY_CONTROL_TYPE_TABLE:
		{
			ControlHelp<MY_CONTROL_TYPE_TABLE> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_TABLE";
		}
		break;
	case MY_CONTROL_TYPE_UITEXT:
		{
			ControlHelp<MY_CONTROL_TYPE_UITEXT> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_UITEXT";
		}
		break;
	case MY_CONTROL_TYPE_HYPER_TEXT:
		{
			ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_HYPER_TEXT";
		}
		break;
	case MY_CONTROL_TYPE_HYPER_TEXT_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_HYPER_TEXT_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_HYPER_TEXT_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_LIST_M:
		{
			ControlHelp<MY_CONTROL_TYPE_LIST_M> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST_M";
		}
		break;
	case MY_CONTROL_TYPE_ITEM_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_ITEM_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_ITEM_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_EQUIP_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_EQUIP_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_EQUIP_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_RADIO_BUTTON:
		{
			ControlHelp<MY_CONTROL_TYPE_RADIO_BUTTON> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_RADIO_BUTTON";
		}
		break;
	case MY_CONTROL_TYPE_EXP:
		{
			ControlHelp<MY_CONTROL_TYPE_EXP> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_EXP";
		}
		break;
	case MY_CONTROL_TYPE_EDIT:
		{
			ControlHelp<MY_CONTROL_TYPE_EDIT> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_EDIT";
		}
		break;
	case MY_CONTROL_TYPE_SPRITE:
		{
			ControlHelp<MY_CONTROL_TYPE_SPRITE> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_SPRITE";
		}
		break;
	case MY_CONTROL_TYPE_LIST_HV:
		{
			ControlHelp<MY_CONTROL_TYPE_LIST_HV> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST_HV";
		}
		break;
	case MY_CONTROL_TYPE_LIST_LOOP:
		{
			ControlHelp<MY_CONTROL_TYPE_LIST_LOOP> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST_LOOP";
		}
		break;
	default:
		break;
	}
	return node;
}

void NDUILoad::PostLoad(UIINFO& uiInfo)
{
	//@check
	// 备注：UI按480*320来配置的，LUA写脚本是按960*640的.
	//			这里乘个Scale，统一到980*640!	

	float scale = NDDirector::DefaultDirector()->GetScaleFactor();
	uiInfo.CtrlPos.x *= scale;
	uiInfo.CtrlPos.y *= scale;
	uiInfo.nCtrlWidth *= scale;
	uiInfo.nCtrlHeight *= scale;
}