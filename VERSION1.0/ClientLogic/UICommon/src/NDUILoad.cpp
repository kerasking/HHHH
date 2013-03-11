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

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

#define ISEQUAL(a,b)		(TAbs((a)-(b))<0.0001f)
#define ISEQUAL_PT(pt,a,b)	(ISEQUAL(pt.x,a) && ISEQUAL(pt.y,b))

IMPLEMENT_CLASS(NDUILoad, NDUILoadEngine)

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
	if (!uiname || !parent)
	{
		return false;
	}

	// open ui file
	CUIData kUIData;

	LOGD("Ready to load ui file: %s",NDPath::GetUIConfigPath(uiname).c_str());

	if ( !kUIData.openUiFile(NDPath::GetUIConfigPath(uiname).c_str()) )
	{
		LOGERROR("kUIData openUIFile faild,file is %s",NDPath::GetUIConfigPath(uiname).c_str());
		return false;
	}

	// load all controlls
	int nCtrlAmount = kUIData.GetCtrlAmount();
	for(int i = 0; i < nCtrlAmount; i++)
	{
		NDUINode* pkNode = LoadCtrl( kUIData, i, parent, sizeOffset );

		if (pkNode)
		{
			if (delegate)
			{
				pkNode->SetTargetDelegate(delegate);
			}
			else if (luaDelegate && luaDelegate->IsFunction())
			{
				pkNode->SetLuaDelegate( *luaDelegate );
			}
		}
		else
		{
			LOGERROR("LoadCtrl( kUIData, i(%d), parent, sizeOffset ) is null", i);
		}
	}

	return true;
}

NDUINode* NDUILoad::LoadCtrl( CUIData& uiData, const int ctrlIndex, NDUINode *parent, const CCSize& sizeOffset )
{
	std::string str = uiData.getCtrlName( ctrlIndex );

	if (!uiData.getCtrlData((char*)str.c_str()))
	{
		LOGERROR("uiData.getCtrlData((char*)str.c_str()) failed");
		NDAsssert(0);
		return false;
	}

	UIINFO& uiInfo = uiData.getCtrlUiInfo();

	NDUILoad_Util::FilterStringName(uiInfo);

	//是否是繁体版的宏
#ifdef TRADITION		
	uiInfo.strText = uiInfo.strTextTradition;
#endif

	// 处理一下
	PostLoad(uiInfo);
	
	// 创建控件
	const char* ctrlTypeName = NULL;
	NDUINode* node = this->CreateCtrl( uiInfo, sizeOffset, ctrlTypeName );

	if (!node)
	{
		LOGERROR("@@ CreateCtrl() failed: type=%d\r\n", uiInfo.nType);
		CCLog( "@@ CreateCtrl() failed: type=%d\r\n", uiInfo.nType );
		//NDAsssert(0);
		return false;
	}

	node->SetTag(uiInfo.nID);
	if (parent)
	{
		parent->AddChild(node);
	}

	//优化关闭按钮手感
	if (this->IsCloseButton( uiInfo ))
	{
		node->SetBoundScale(2);
	}

	//特别处理：主界面右上角图标（点击半透明，类似NPC点击）
	if (strstr(uiData.getIniFile().GetPath(), "MainUI.ini") != NULL
		&& uiInfo.nID == 9
		&& node->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		NDUIButton* btn = reinterpret_cast<NDUIButton*>(node);
		btn->enableHighlight(true);
	}

	return node;
}

bool NDUILoad::IsAnchorValid( const float anchor )
{
	return ISEQUAL(anchor,0.f) || ISEQUAL(anchor,1.f) || ISEQUAL(anchor,0.5f);
}

NDUINode* NDUILoad::CreateCtrl( UIINFO& uiInfo, CCSize sizeOffset, const char*& ctrlTypeName )
{
	NDUINode* node = NULL;

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
	case MY_CONTROL_TYPE_LIST_HORZ: //@listbox
		{
			ControlHelp<MY_CONTROL_TYPE_LIST_HORZ> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST_HORZ";
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
	case MY_CONTROL_TYPE_LIST_VERT: //@listbox
		{
			ControlHelp<MY_CONTROL_TYPE_LIST_VERT> help;
			node = (NDUINode*)help.Create(uiInfo, sizeOffset);
			ctrlTypeName = "MY_CONTROL_TYPE_LIST_VERT";
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

//重置锚点（统一到0,0点）
//非(0,0)点的锚点，缩放后容易引起缝隙
void NDUILoad::ResetAnchorPos( UIINFO& uiInfo )
{
	if (ISEQUAL_PT(uiInfo.CtrlAnchorPos,0,1))
	{ // [0, 1]
		uiInfo.CtrlPos.y -= (float)uiInfo.nCtrlHeight;
	}
	else if (ISEQUAL_PT(uiInfo.CtrlAnchorPos,1,0))
	{ // [1, 0]
		uiInfo.CtrlPos.x -= (float)uiInfo.nCtrlWidth;
	}
	else if (ISEQUAL_PT(uiInfo.CtrlAnchorPos,1,1))
	{ // [1, 1]
		uiInfo.CtrlPos.x -= (float)uiInfo.nCtrlWidth;
		uiInfo.CtrlPos.y -= (float)uiInfo.nCtrlHeight;
	}
	else if (ISEQUAL_PT(uiInfo.CtrlAnchorPos,0.5,0.5))
	{ // [.5, .5]
		uiInfo.CtrlPos.x -= 0.5f * uiInfo.nCtrlWidth;
		uiInfo.CtrlPos.y -= 0.5f * uiInfo.nCtrlHeight;
	}

	//统一为(0,0)即：左上角
	uiInfo.CtrlAnchorPos = ccp(0,0);
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

void NDUILoad::PostLoad(UIINFO& uiInfo)
{
	//@check
	// 备注：UI按480*320来配置的.
	// 假设INI配置(0,0,480,320)，转换后的结果如下：
	// ios retina:	(0,0,960,640)
	// ios:			(0,0,480,320)
	// android:		(0,0,800,480) //假设android的分辨率是800*600.
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    float scale = 2.0f; //先转到960*640，后面会乘个scale(基于960*640)
#else
	float scale = CCDirector::sharedDirector()->getContentScaleFactor();
#endif

	uiInfo.CtrlPos.x	*= scale;
	uiInfo.CtrlPos.y	*= scale;
	uiInfo.nCtrlWidth	*= scale;
	uiInfo.nCtrlHeight	*= scale;

	//@android: 如果是android机型，则从960*640的基础上再适配为具体的分辨率
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	float sx = NDDirector::DefaultDirector()->getAndroidScale().x;
	float sy = NDDirector::DefaultDirector()->getAndroidScale().y;

	uiInfo.CtrlPos.x *= sx;
	uiInfo.CtrlPos.y *= sy;
	uiInfo.nCtrlWidth *= sx;
	uiInfo.nCtrlHeight *= sy;	
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	if (IS_IPHONE5)
	{
		uiInfo.CtrlPos.x	*= IPHONE5_WIDTH_SCALE;
		uiInfo.nCtrlWidth	*= IPHONE5_WIDTH_SCALE;	
	}
#endif

	//重置锚点(0,0)
	ResetAnchorPos( uiInfo );

	// 上下对调一下（像素单位）
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	uiInfo.CtrlPos.y = winsize.height - uiInfo.CtrlPos.y;
	uiInfo.CtrlPos.y -= uiInfo.nCtrlHeight;
}

//是否关闭按钮
bool NDUILoad::IsCloseButton(const UIINFO& uiInfo)
{
	const char* p = uiInfo.strText.c_str();
	if (strstr( p, "close" ) 
		|| strstr( p, "CLOSE" ) 
		|| strstr( p, "Close" ))
	{
		return true;
	}

	p = uiInfo.strNormalFile.c_str();
	if (strstr( p, "close" ) 
		|| strstr( p, "CLOSE" ) 
		|| strstr( p, "Close" ))
	{
		return true;
	}

	//BUTTON_TOPUP 充值
	if (strstr( p, "BUTTON_TOPUP" ))
	{
		return true;
	}
	return false;
}