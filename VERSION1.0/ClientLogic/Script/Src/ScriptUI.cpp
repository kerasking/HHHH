
/*
 *  ScriptUI.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "ScriptUI.h"
#include "ScriptInc.h"
#include "NDUILabel.h"
#include "NDUIButton.h"
#include "NDUIImage.h"
#include "NDScrollLayer.h"

#include "define.h"
#include "NDUISynLayer.h"

#include "NDUILoad.h"
#include "CCPointExtension.h"
#include "NDNode.h"
#include "NDDirector.h"
#include "NDScene.h"
#include "NDUINode.h"
#include "NDUILayer.h"
#include "NDUIButton.h"
#include "NDPicture.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "NDUIDialog.h"

// smys begin
#include "NDUIScroll.h"
#include "NDUIScrollViewContainer.h"
#include "NDUIScrollViewMulHand.h"
#include "UIRoleNode.h"
#include "NDUIHyperlink.h"
#include "UIItemButton.h"
#include "UIEquipItem.h"
#include "UICheckBox.h"
#include "UIRadioButton.h"
#include "NDUIExp.h"
#include "UIEdit.h"
#include "NDUISpriteNode.h"
#include "NDUIChatText.h"
#include "UIList.h"
#include "UITabLogic.h"
//...
// smys end
#include "NDPath.h"

#include "NDUIScrollContainerExpand.h"
#include "NDUIScrollViewExpand.h"
#include "CCGeometry.h"
#include "ScriptMgr.h"
#include "NDUITableLayer.h"
#include "CCPlatformConfig.h"
#include "NDJsonReader.h"
#include "NDBitmapMacro.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
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

using namespace cocos2d;
using namespace NDEngine;


int GetChildrenTagList(LuaState* state)
{
	lua_State* L	= state->GetCState();
	if (!L)
	{
		LuaStateMgrObj.GetState()->PushNil();
		return 1;
	}
	lua_newtable(L);
	if (LUA_TUSERDATA != lua_type(L, 1))
	{
		return 1;
	}
	NDNode* pNode	= (NDNode*)lua_unboxpointer(L, 1);
	if (!pNode)
	{
		return 1;
	}
	const std::vector<NDNode*>& children	= pNode->GetChildren();
	if (children.empty())
	{
		return 1;
	}
	for (unsigned int i = 0; i < children.size(); i++) 
	{
		lua_pushnumber(L, i);
		lua_pushnumber(L, children[i]->GetTag());
		lua_settable(L, -3);
	}
	return 1;
}

int GetWorldServerPort()
{
	NDJsonReader kReader;
	string strText = kReader.getGameConfig("server_port");
	int nRet = atoi(strText.c_str());

	return nRet;
}

string GetGameConfig(const char* pszStringName)
{
	if (0 == pszStringName || !*pszStringName)
	{
		return 0;
	}

	NDJsonReader kReader;
	string strText = kReader.getGameConfig(pszStringName);

	return strText.c_str();
}

//#pragma mark 通过节点获取某节点的子节点

void PrintLog(const char* pszText)
{
	if (pszText && *pszText)
	{
		LOGD("Script message:%s",pszText);
		printf("Script message:%s",pszText);
	}
	else
	{
		LOGERROR("Error Script Message");
		printf("Error Script Message");
	}
}

NDUINode*							
GetUiNode(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *uinode = pNode->GetChild(tag);
	
	if (!uinode || !uinode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		return NULL;
	}
	
	return (NDUINode*)uinode;
}


NDUILabel*							
GetLabel(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *lb = pNode->GetChild(tag);
	
	if (!lb || !lb->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		return NULL;
	}
	
	return (NDUILabel*)lb;
}

NDUIButton*							
GetButton(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *btn = pNode->GetChild(tag);
	
	if (!btn || !btn->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		return NULL;
	}
	
	return (NDUIButton*)btn;
}

NDUILayer*							
GetUiLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *layer = pNode->GetChild(tag);
	
	if (!layer || !layer->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		return NULL;
	}
	
	return (NDUILayer*)layer;
}

NDUITableLayer*						
GetTableLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *tl = pNode->GetChild(tag);
	
	if (!tl || !tl->IsKindOfClass(RUNTIME_CLASS(NDUITableLayer)))
	{
		return NULL;
	}
	
	return (NDUITableLayer*)tl;
}

NDUIImage*							
GetImage(NDNode* pNode, int tag)
{	
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *img = pNode->GetChild(tag);
	
	if (!img || !img->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return NULL;
	}
	
	return (NDUIImage*)img;
}

NDUIContainerScrollLayer*			
GetScrollLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *sl = pNode->GetChild(tag);
	
	if (!sl || !sl->IsKindOfClass(RUNTIME_CLASS(NDUIContainerScrollLayer)))
	{
		return NULL;
	}
	
	return (NDUIContainerScrollLayer*)sl;
}

NDUIContainerHScrollLayer*			
GetHScrollLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *hsl = pNode->GetChild(tag);
	
	if (!hsl || !hsl->IsKindOfClass(RUNTIME_CLASS(NDUIContainerHScrollLayer)))
	{
		return NULL;
	}
	
	return (NDUIContainerHScrollLayer*)hsl;
}

NDUIScrollViewContainer*			
GetScrollViewContainer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *sc = pNode->GetChild(tag);
	
	if (!sc || !sc->IsKindOfClass(RUNTIME_CLASS(NDUIScrollViewContainer)))
	{
		return NULL;
	}
	
	return (NDUIScrollViewContainer*)sc;
}


CUIScrollViewContainerM*			
GetScrollViewContainerM(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *sc = pNode->GetChild(tag);
	
	if (!sc || !sc->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewContainerM*)sc;
}

CUIScrollContainerExpand*			
GetScrollContainerExpand(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *sc = pNode->GetChild(tag);
	
	if (!sc || !sc->IsKindOfClass(RUNTIME_CLASS(CUIScrollContainerExpand)))
	{
		return NULL;
	}
	
	return (CUIScrollContainerExpand*)sc;
}





CUIHyperlinkText*
GetHyperLinkText(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *hlt = pNode->GetChild(tag);
	
	if (!hlt || !hlt->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkText)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkText*)hlt;
}

CUIHyperlinkButton*
GetHyperLinkButton(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode* hlb = pNode->GetChild(tag);
	
	if (!hlb || !hlb->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkButton)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkButton*)hlb;
}

CUIItemButton*
GetItemButton(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode* itemBtn = pNode->GetChild(tag);
	
	if (!itemBtn || !itemBtn->IsKindOfClass(RUNTIME_CLASS(CUIItemButton)))
	{
		return NULL;
	}
	
	return (CUIItemButton*)itemBtn;
}

CUIEquipItem*							
GetEquipButton(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode* equipBtn = pNode->GetChild(tag);
	
	if (!equipBtn || !equipBtn->IsKindOfClass(RUNTIME_CLASS(CUIEquipItem)))
	{
		return NULL;
	}
	
	return (CUIEquipItem*)equipBtn; 
}

//#pragma mark 通过tag列表获取子结点

//通过tag列表获取节点
NDNode* RecursiveNode(NDNode* pParentNode, LuaObject& tagTable)
{
	if (!pParentNode || !tagTable.IsTable())
	{
		return NULL;
	}
	
	int nTableCount = tagTable.GetTableCount();
	if (nTableCount <= 0)
	{
		return NULL;
	}
	
	NDNode* pResultNode = pParentNode;
	for (int i = 1; i <= nTableCount; i++) 
	{
		LuaObject tag = tagTable[i];
		if (!tag.IsInteger())
		{
			return NULL;
		}
		
		if (!pResultNode)
		{
			return NULL;
		}
        int test = tag.GetInteger();
		pResultNode = pResultNode->GetChild(tag.GetInteger());
	}
	
	return pResultNode;
}

//通过tag列表获取UI节点(不导到脚本)
NDUINode*							
RecursiveUINode(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		return NULL;
	}
	
	return (NDUINode*)pResultNode; 
}

//通过tag列表获取标签节点
NDUILabel*							
RecursiveLabel(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		return NULL;
	}
	
	return (NDUILabel*)pResultNode; 
}

//通过tag列表获取按钮节点
NDUIButton*							
RecursiveButton(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		return NULL;
	}
	
	return (NDUIButton*)pResultNode; 
}

//通过tag列表获取层节点
NDUILayer*							
RecursiveUILayer(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		return NULL;
	}
	
	return (NDUILayer*)pResultNode; 
}

//通过tag列表获取层节点
NDUIImage*							
RecursiveImage(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return NULL;
	}
	
	return (NDUIImage*)pResultNode; 
}

//通过tag列表获取滚动节点
CUIScroll*
RecursiveScroll(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
	{
		return NULL;
	}
	
	return (CUIScroll*)pResultNode; 
}

//通过tag列表获取滚动层节点
NDUIScrollContainer*
RecursiveScrollContainer(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIScrollContainer)))
	{
		return NULL;
	}
	
	return (NDUIScrollContainer*)pResultNode; 
}

//通过tag列表获取视图容器节点
NDUIScrollViewContainer*							
RecursiveSVC(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIScrollViewContainer)))
	{
		return NULL;
	}
	
	return (NDUIScrollViewContainer*)pResultNode; 
}

//通过tag列表获取视图节点
CUIScrollView*							
RecursiveSV(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return NULL;
	}
	
	return (CUIScrollView*)pResultNode; 
}


//通过tag列表获取视图容器节点
CUIScrollViewContainerM*							
RecursiveSVCM(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewContainerM*)pResultNode; 
}

//通过tag列表获取视图节点
CUIScrollViewM*							
RecursiveSVM(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewM*)pResultNode; 
}

//通过tag列表获取视图容器节点
CUIScrollContainerExpand*							
RecursiveSCE(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollContainerExpand)))
	{
		return NULL;
	}
	
	return (CUIScrollContainerExpand*)pResultNode; 
}

//通过tag列表获取视图节点
UIScrollViewExpand*							
RecursiveSCEV(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(UIScrollViewExpand)))
	{
		return NULL;
	}
	
	return (UIScrollViewExpand*)pResultNode; 
}



//通过tag列表获取超链接文本节点
CUIHyperlinkText*							
RecursiveHyperText(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkText)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkText*)pResultNode; 
}

//通过tag列表获取超链接按钮节点
CUIHyperlinkButton*							
RecursiveHyperBtn(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkButton)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkButton*)pResultNode; 
}

//通过tag列表获取物品按钮节点
CUIItemButton*							
RecursiveItemBtn(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIItemButton)))
	{
		return NULL;
	}
	
	return (CUIItemButton*)pResultNode; 
}

//通过tag列表获取装备按钮节点
CUIEquipItem*							
RecursiveEquipBtn(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIEquipItem)))
	{
		return NULL;
	}
	
	return (CUIEquipItem*)pResultNode; 
}

//通过tag列表获取CheckBox节点
CUICheckBox*							
RecursiveCheckBox(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUICheckBox)))
	{
		return NULL;
	}
	
	return (CUICheckBox*)pResultNode; 
}

//通过tag列表获取RadioButton节点
CUIRadioButton*							
RecursiveRadioBtn(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioButton)))
	{
		return NULL;
	}
	
	return (CUIRadioButton*)pResultNode; 
}

//通过tag列表获取RadioGroup节点
CUIRadioGroup*							
RecursiveRadioGroup(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioGroup)))
	{
		return NULL;
	}
	
	return (CUIRadioGroup*)pResultNode; 
}

//通过tag列表获取经验条节点
CUIExp*							
RecursivUIExp(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIExp)))
	{
		return NULL;
	}
	
	return (CUIExp*)pResultNode; 
}

//通过tag列表获取edit节点
CUIEdit*							
RecursivUIEdit(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIEdit)))
	{
		return NULL;
	}
	
	return (CUIEdit*)pResultNode; 
}

//通过tag列表获取精灵节点
CUISpriteNode*							
RecursivUISprite(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode)))
	{
		return NULL;
	}
	return (CUISpriteNode*)pResultNode; 
}
//通过tag列表获取角色节点
CUIRoleNode*							
RecursivUIRoleNode(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRoleNode)))
	{
		return NULL;
	}
	return (CUIRoleNode*)pResultNode; 
}
//通过tag列表获取列表节点

#if 0
CUIList*							
RecursivUIList(NDNode* pParentNode, LuaObject tagTable)
{
	NDNode* pResultNode = RecursiveNode(pParentNode, tagTable);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIList)))
	{
		return NULL;
	}
	return (CUIList*)pResultNode; 
}
#endif

//#pragma mark 通过tag列表获取父结点
//通过tag列表获取节点
NDNode* PRecursiveNode(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	if (!pChildNode || nRecuriveCount == 0)
	{
		return NULL;
	}
	
	NDNode* pResultNode = pChildNode;
	for (unsigned int i = 0; i < nRecuriveCount; i++) 
	{
		if (!pResultNode)
		{
			return NULL;
		}
		pResultNode = pResultNode->GetParent();
	}
	
	return pResultNode;
}

//通过tag列表获取UI节点(不导到脚本)
NDUINode*							
PRecursiveUINode(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		return NULL;
	}
	
	return (NDUINode*)pResultNode; 
}

//通过tag列表获取标签节点
NDUILabel*							
PRecursiveLabel(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		return NULL;
	}
	
	return (NDUILabel*)pResultNode; 
}

//通过tag列表获取按钮节点
NDUIButton*							
PRecursiveButton(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		return NULL;
	}
	
	return (NDUIButton*)pResultNode; 
}

//通过tag列表获取层节点
NDUILayer*							
PRecursiveUILayer(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		return NULL;
	}
	
	return (NDUILayer*)pResultNode; 
}

//通过tag列表获取层节点
NDUIImage*							
PRecursiveImage(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return NULL;
	}
	
	return (NDUIImage*)pResultNode; 
}

//通过tag列表获取视图容器节点
NDUIScrollViewContainer*							
PRecursiveSVC(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(NDUIScrollViewContainer)))
	{
		return NULL;
	}
	
	return (NDUIScrollViewContainer*)pResultNode; 
}

//通过tag列表获取视图节点
CUIScrollView*							
PRecursiveSV(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return NULL;
	}
	
	return (CUIScrollView*)pResultNode; 
}



//** chh 2012-06-25 **//

//通过tag列表获取视图容器节点
CUIScrollViewContainerM*							
PRecursiveSVCM(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewContainerM*)pResultNode; 
}

//通过tag列表获取视图节点
CUIScrollViewM*							
PRecursiveSVM(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewM*)pResultNode; 
}

//通过tag列表获取超链接文本节点
CUIHyperlinkText*							
PRecursiveHyperText(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkText)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkText*)pResultNode; 
}

//通过tag列表获取超链接按钮节点
CUIHyperlinkButton*							
PRecursiveHyperBtn(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkButton)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkButton*)pResultNode; 
}

//通过tag列表获取物品按钮节点
CUIItemButton*							
PRecursiveItemBtn(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIItemButton)))
	{
		return NULL;
	}
	
	return (CUIItemButton*)pResultNode; 
}

//通过tag列表获取装备按钮节点
CUIEquipItem*							
PRecursiveEquipBtn(NDNode* pChildNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pChildNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIEquipItem)))
	{
		return NULL;
	}
	
	return (CUIEquipItem*)pResultNode; 
}

//通过tag列表获取CheckBox节点
CUICheckBox*							
PRecursiveCheckBox(NDNode* pParentNode, unsigned int nRecuriveCoun)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCoun);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUICheckBox)))
	{
		return NULL;
	}
	
	return (CUICheckBox*)pResultNode; 
}

//通过tag列表获取RadioButton节点
CUIRadioButton*							
PRecursiveRadioBtn(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioButton)))
	{
		return NULL;
	}
	
	return (CUIRadioButton*)pResultNode; 
}

//通过tag列表获取RadioGroup节点
CUIRadioGroup*							
PRecursiveRadioGroup(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioGroup)))
	{
		return NULL;
	}
	
	return (CUIRadioGroup*)pResultNode; 
}

//通过tag列表获取经验条节点
CUIExp*	
PRecursiveUIExp(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIExp)))
	{
		return NULL;
	}
	
	return (CUIExp*)pResultNode; 
}

//通过tag列表获取edit条节点
CUIEdit*	
PRecursiveUIEdit(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIEdit)))
	{
		return NULL;
	}
	
	return (CUIEdit*)pResultNode; 
}

//通过tag列表获取精灵节点
CUISpriteNode*	
PRecursiveUISprite(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode)))
	{
		return NULL;
	}
	return (CUISpriteNode*)pResultNode; 
}
//通过tag列表获取精灵节点
CUIRoleNode*	
PRecursiveUIRoleNode(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIRoleNode)))
	{
		return NULL;
	}
	return (CUIRoleNode*)pResultNode; 
}
//通过回朔次数获取列表节点
#if 0
CUIList*	
PRecursiveUIList(NDNode* pParentNode, unsigned int nRecuriveCount)
{
	NDNode* pResultNode = PRecursiveNode(pParentNode, nRecuriveCount);
	if (!pResultNode || 
		!pResultNode->IsKindOfClass(RUNTIME_CLASS(CUIList)))
	{
		return NULL;
	}
	return (CUIList*)pResultNode; 
}
#endif
//#pragma mark 节点类型转换
NDUINode*							
ConverToUiNode(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		return NULL;
	}
	
	return (NDUINode*)pNode;
}


NDUILabel*							
ConverToLabel(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		return NULL;
	}
	
	return (NDUILabel*)pNode;
}

NDUIButton*							
ConverToButton(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		return NULL;
	}
	
	return (NDUIButton*)pNode;
}

NDUILayer*							
ConverToUiLayer(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		return NULL;
	}
	
	return (NDUILayer*)pNode;
}

NDUITableLayer*						
ConverToTableLayer(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUITableLayer)))
	{
		return NULL;
	}
	
	return (NDUITableLayer*)pNode;
}

NDUIImage*							
ConverToImage(NDNode* pNode)
{	
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return NULL;
	}
	
	return (NDUIImage*)pNode;
}

/*
NDUIContainerScrollLayer*			
GetScrollLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *sl = pNode->GetChild(tag);
	
	if (!sl || !sl->IsKindOfClass(RUNTIME_CLASS(NDUIContainerScrollLayer)))
	{
		return NULL;
	}
	
	return (NDUIContainerScrollLayer*)sl;
}

NDUIContainerHScrollLayer*			
GetHScrollLayer(NDNode* pNode, int tag)
{
	if (!pNode)
	{
		return NULL;
	}
	
	NDNode *hsl = pNode->GetChild(tag);
	
	if (!hsl || !hsl->IsKindOfClass(RUNTIME_CLASS(NDUIContainerHScrollLayer)))
	{
		return NULL;
	}
	
	return (NDUIContainerHScrollLayer*)hsl;
}
*/

NDUIScrollViewContainer*			
ConverToSVC(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUIScrollViewContainer)))
	{
		return NULL;
	}
	
	return (NDUIScrollViewContainer*)pNode;
}

CUIScrollView*			
ConverToSV(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return NULL;
	}
	
	return (CUIScrollView*)pNode;
}


CUIScrollViewContainerM*			
ConverToSVCM(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewContainerM*)pNode;
}

CUIScrollViewM*			
ConverToSVM(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM)))
	{
		return NULL;
	}
	
	return (CUIScrollViewM*)pNode;
}



CUIScrollContainerExpand*			
ConverToSCE(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollContainerExpand)))
	{
		return NULL;
	}
	
	return (CUIScrollContainerExpand*)pNode;
}

UIScrollViewExpand*			
ConverToSCEV(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(UIScrollViewExpand)))
	{
		return NULL;
	}
	
	return (UIScrollViewExpand*)pNode;
}



CUIHyperlinkText*
ConverToHLT(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkText)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkText*)pNode;
}

CUIHyperlinkButton*
ConverToHLB(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIHyperlinkButton)))
	{
		return NULL;
	}
	
	return (CUIHyperlinkButton*)pNode;
}

CUIRoleNode*
ConverToRoleNode(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIRoleNode)))
	{
		return NULL;
	}
	return (CUIRoleNode*)pNode;
}
CUIItemButton*
ConverToItemButton(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIItemButton)))
	{
		return NULL;
	}
	
	return (CUIItemButton*)pNode;
}

CUIEquipItem*							
ConverToEquipBtn(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIEquipItem)))
	{
		return NULL;
	}
	
	return (CUIEquipItem*)pNode; 
}

CUICheckBox*							
ConverToCheckBox(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUICheckBox)))
	{
		return NULL;
	}
	
	return (CUICheckBox*)pNode;  
}

CUIRadioButton*							
ConverToRadioBtn(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioButton)))
	{
		return NULL;
	}
	
	return (CUIRadioButton*)pNode;
}

CUIRadioGroup*							
ConverToRadioGroup(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIRadioGroup)))
	{
		return NULL;
	}
	
	return (CUIRadioGroup*)pNode;  
}

CUIEdit*							
ConverToEdit(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIEdit)))
	{
		return NULL;
	}
	
	CUIEdit* pEdit = (CUIEdit*)pNode;  
    if(pEdit && pEdit == CUIEdit::sharedCurEdit())
        pEdit->AutoInputReturn();
    return pEdit;
}

CUISpriteNode*							
ConverToSprite(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode)))
	{
		return NULL;
	}
	return (CUISpriteNode*)pNode;  
}
#if 0
CUIList*							
ConverToUIList(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIList)))
	{
		return NULL;
	}
	return (CUIList*)pNode;  
}
CUIListSection*							
ConverToUIListSection(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIListSection)))
	{
		return NULL;
	}
	return (CUIListSection*)pNode;  
}
CUIListCell*							
ConverToUIListCell(NDNode* pNode)
{
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIListCell)))
	{
		return NULL;
	}
	return (CUIListCell*)pNode;  
}
#endif
//#pragma mark 其它ui通用函数

CCSize GetStringSize(const char* str, unsigned int fontsize)
{
	if (!str || 0 == strlen(str))
	{
		return CCSizeZero;
	}
	return getStringSize(str, fontsize);
}
CCSize GetMutiLineStringSize(const char* str, int fontsize, int nWidth)
{
	if (!str || 0 == strlen(str))
	{
		return CCSizeZero;
	}
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	return getStringSizeMutiLine(str, fontsize, CCSizeMake(nWidth, winsize.height * 5));
}

CCSize GetHyperLinkTextSize(const char* str, unsigned int fontsize, int nBoundWidth)
{
	if (!str)
	{
		return CCSizeZero;
	}
	CCSize textSize;
	textSize.width	= nBoundWidth;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(str, textSize.width, fontsize);
	textSize.width	= NDUITextBuilder::DefaultBuilder()->StringWidthAfterFilter(str, textSize.width, fontsize);
	return textSize;
}

// @ndbitmap: create a single color label by NDBitmap mechanism 
#if WITH_NDBITMAP
NDUINode* CreateColorLabel_NDBitmap(const char* str, unsigned int fontsize, const CCRect& frameRect)
{
	NDUILabel* label = new NDUILabel;
	if (label)
	{
		label->Initialization();
		label->SetFrameRect( frameRect );
		label->SetRenderTimes(1);
		label->SetText(str);
		label->SetFontColor(ccc4(255, 255, 255, 255));
		label->SetTag(0);
		label->SetFontSize(fontsize);
	}
	return label;
}
#endif

NDUINode* CreateColorLabel(const char* str, unsigned int fontsize, unsigned int nConstraitWidth)
{
	//LUA fontSize=6, fix it.
	fontsize = (fontsize == 6 ? 12 : fontsize);
	if (!str)
	{
		return NULL;
	}
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	winsize.width	= nConstraitWidth;

//@ndbitmap
#if WITH_NDBITMAP
	if (nConstraitWidth > 0)
	{
		winsize = ::getStringSizeMutiLine( str, fontsize * FONT_SCALE, winsize );
	}
	return CreateColorLabel_NDBitmap(str, fontsize, CCRectMake(0,0,winsize.width,winsize.height));
#else
	return (NDUINode*)NDUITextBuilder::DefaultBuilder()->Build(str, fontsize, winsize, ccc4(255, 255, 255, 255));
#endif
}

NDScene* GetSMGameScene()
{
	return NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
}
NDScene* GetSMLoginScene()
{
	return NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
}

CCSize GetWinSize()
{
	return CCDirector::sharedDirector()->getWinSizeInPixels();
}

CCRect RectZero()
{
	return CCRectZero;
}

CCSize SizeZero()
{
	return CCSizeZero;
}

CCPoint PointZero()
{
	return CCPointZero;
}
#if 0
LIST_ATTR_SEC MakeListSecAttr(
	int nSectionWidth, int nSectionHeight,
	int nLInner, int nRInner, int nTInner, int nBInner,
	int nCellInner, int nCellWidth, int nCellHeight)
{
	LIST_ATTR_SEC attr;
	attr.unSectionWidth			= nSectionWidth;
	attr.unSectionHeight		= nSectionHeight;
	attr.unContentLInner		= nLInner;
	attr.unContentRInner		= nRInner;
	attr.unContentTInner		= nTInner;
	attr.unContentBInner		= nBInner;
	attr.unCellInner			= nCellInner;
	attr.unCellWidth			= nCellWidth;
	attr.unCellHeight			= nCellHeight;
	return attr;
}
#endif
void ShowLoadBar()
{
	ShowProgressBar;
}

void CloseLoadBar()
{
	CloseProgressBar;
}

//++ Guosen 2012.6.3 //获得各种路径
std::string NDPath_GetResourcePath()	{ return NDPath::GetResPath(); }
std::string NDPath_GetImagePath()		{ return NDPath::GetImagePath(); }
std::string NDPath_GetMapPath()			{ return NDPath::GetMapPath(); }
std::string NDPath_GetAnimationPath()	{ return NDPath::GetAnimationPath(); }
std::string NDPath_GetResPath()			{ return NDPath::GetResPath(); }
std::string NDPath_GetSoundPath()		{ return NDPath::GetSoundPath(); }
//tanwt 20120913 //注册本地通知
/*//新功能暂时不开放
int RegisterLocalNotification(string noticeTime,string Content)
{
    //指定的yyyymmddhh24miss，格化为time_t的时间
    struct tm tm1;
    time_t time1;
    char timeFormart[20] = {0};
    //sprintf(notifyTime, "%ld",noticeTime);
    sscanf(noticeTime.c_str(),"%4d%2d%2d%2d%2d%2d",&tm1.tm_year,&tm1.tm_mon,&tm1.tm_mday,&tm1.tm_hour,&tm1.tm_min,&tm1.tm_sec);
    sprintf(timeFormart,"%4d-%02d-%02d %02d:%02d:%02d",tm1.tm_year,tm1.tm_mon,tm1.tm_mday,tm1.tm_hour,tm1.tm_min,tm1.tm_sec);
    
    //注销所有的本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //定义本地通知
    UILocalNotification *notification=[[UILocalNotification alloc] init]; 

    //strftime(Noticetime, sizeof(Noticetime), "%F %T",localtime(&notifytime));
    if (notification!=nil) 
    { 
        NSString *noticeDate = [NSString stringWithFormat:@"%s", timeFormart];
        NSString *noticeContent = [NSString stringWithUTF8String:Content.c_str()];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //NSString *noticeDate = @"2012-09-14 00:02:30";
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //设置触发时间
        notification.fireDate = [formatter dateFromString:noticeDate];
        [formatter release];
        //NSDate *now=[NSDate new]; 
        //notification.fireDate=[now addTimeInterval:10]; 
        notification.timeZone=[NSTimeZone defaultTimeZone]; 
        notification.applicationIconBadgeNumber = 1;
        //notification.alertBody=@"服务器正式开启，大家一起来吧"; 
        notification.alertBody=noticeContent; 
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}
 */
int RegisterLocalNotification(string Date,string Content)
{
#if 0
    //定义本地通知
    UILocalNotification *notification=[[UILocalNotification alloc] init]; 
    if (notification!=nil) 
    { 
        NSString *noticeDate = [NSString stringWithFormat:@"%s", Date.c_str()];
        NSString *noticeContent = [NSString stringWithUTF8String:Content.c_str()];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //NSString *noticeDate = @"2012-09-14 00:02:30";
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //设置触发时间
        notification.fireDate = [formatter dateFromString:noticeDate];
        [formatter release];
        //NSDate *now=[NSDate new]; 
        //notification.fireDate=[now addTimeInterval:10]; 
        notification.timeZone=[NSTimeZone defaultTimeZone]; 
        notification.applicationIconBadgeNumber = 1;
        //notification.alertBody=@"服务器正式开启，大家一起来吧"; 
        notification.alertBody=noticeContent; 
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
#endif 
	return 0;
}

CCRect RectMake(float x, float y, float width, float height)
{
	return CCRectMake((x), (y), (width), (height));
}

CCPoint PointMake(float x, float y)
{
	return CCPointMake((x), (y));
}

CCSize SizeMake(float width, float height)
{
	return CCSizeMake((width), (height));
}

namespace NDEngine {



//#pragma mark ui脚本导出加载
	void ScriptUiLoad()
	{
		ETLUAFUNC("GetChildrenTagList", GetChildrenTagList)
		ETCFUNC("GetWorldServerPort",GetWorldServerPort);
		ETCFUNC("GetGameConfig",GetGameConfig)
		ETCFUNC("PrintLog",		PrintLog)
		ETCFUNC("GetUiNode",		GetUiNode)
		ETCFUNC("GetLabel",			GetLabel)
		ETCFUNC("GetButton",		GetButton)
		ETCFUNC("GetUiLayer",		GetUiLayer)
		ETCFUNC("GetTableLayer",	GetTableLayer)
		ETCFUNC("GetImage",			GetImage)
		ETCFUNC("GetScrollLayer",	GetScrollLayer)
		ETCFUNC("GetHScrollLayer",	GetHScrollLayer)
		ETCFUNC("GetScrollViewContainer",	GetScrollViewContainer)
		ETCFUNC("GetScrollViewContainerM",	GetScrollViewContainerM)
		ETCFUNC("GetScrollContainerExpand",	GetScrollContainerExpand)

		ETCFUNC("CGSizeMake",		SizeMake)
		ETCFUNC("CGPointMake",		PointMake)
		ETCFUNC("CGRectMake",		RectMake)
		ETCFUNC("ccc4",				ccc4);
		ETCFUNC("ccc3",				ccc3);
		ETCFUNC("ShowLoadBar",		ShowLoadBar);
		ETCFUNC("CloseLoadBar",		CloseLoadBar);
		ETCFUNC("GetSMGameScene",	GetSMGameScene);
		ETCFUNC("GetSMLoginScene",	GetSMLoginScene);
		ETCFUNC("GetWinSize",		GetWinSize);
		ETCFUNC("RectZero",			RectZero);
		ETCFUNC("SizeZero",			SizeZero);
		ETCFUNC("PointZero",		PointZero);
		//ETCFUNC("MakeListSecAttr",	MakeListSecAttr);
		ETCFUNC("GetStringSize",		GetStringSize);
		ETCFUNC("GetMutiLineStringSize", GetMutiLineStringSize);
		ETCFUNC("GetHyperLinkTextSize", GetHyperLinkTextSize);
		ETCFUNC("GetHyperLinkText",	GetHyperLinkText);
		ETCFUNC("GetHyperLinkButton", GetHyperLinkButton);
		ETCFUNC("GetItemButton", GetItemButton);
		ETCFUNC("GetEquipButton", GetEquipButton);

		ETCFUNC("CreateColorLabel", CreateColorLabel);

		ETCFUNC("RecursiveUINode", RecursiveUINode);
		ETCFUNC("RecursiveLabel", RecursiveLabel);
		ETCFUNC("RecursiveButton", RecursiveButton);
		ETCFUNC("RecursiveUILayer", RecursiveUILayer);
		ETCFUNC("RecursiveImage", RecursiveImage);
		ETCFUNC("RecursiveScroll", RecursiveScroll);
		ETCFUNC("RecursiveScrollContainer", RecursiveScrollContainer);
		ETCFUNC("RecursiveSVC", RecursiveSVC);
		ETCFUNC("RecursiveSV", RecursiveSV);

		//** chh 2012-06-25 **//
		ETCFUNC("RecursiveSVCM", RecursiveSVCM);
		ETCFUNC("RecursiveSVM", RecursiveSVM);



		//** chh 2012-07-24 **//
		ETCFUNC("RecursiveSCE", RecursiveSCE);
		ETCFUNC("RecursiveSCEV", RecursiveSCEV);


		ETCFUNC("RecursiveHyperText", RecursiveHyperText);
		ETCFUNC("RecursiveHyperBtn", RecursiveHyperBtn);
		ETCFUNC("RecursiveItemBtn", RecursiveItemBtn);
		ETCFUNC("RecursiveEquipBtn", RecursiveEquipBtn);
		ETCFUNC("RecursiveCheckBox", RecursiveCheckBox);
		ETCFUNC("RecursiveRadioBtn", RecursiveRadioBtn);
		ETCFUNC("RecursiveRadioGroup", RecursiveRadioGroup);
		ETCFUNC("RecursivUIExp", RecursivUIExp);
		ETCFUNC("RecursivUIEdit", RecursivUIEdit);
		ETCFUNC("RecursivUISprite", RecursivUISprite);
		ETCFUNC("RecursivUIRoleNode", RecursivUIRoleNode);

		ETCFUNC("PRecursiveUINode", PRecursiveUINode);
		ETCFUNC("PRecursiveLabel", PRecursiveLabel);
		ETCFUNC("PRecursiveButton", PRecursiveButton);
		ETCFUNC("PRecursiveUILayer", PRecursiveUILayer);
		ETCFUNC("PRecursiveImage", PRecursiveImage);
		ETCFUNC("PRecursiveSVC", PRecursiveSVC);
		ETCFUNC("PRecursiveSV", PRecursiveSV);

		//** chh 2012-06-25 **//
		ETCFUNC("PRecursiveSVCM", PRecursiveSVCM);
		ETCFUNC("PRecursiveSVM", PRecursiveSVM);

		ETCFUNC("PRecursiveHyperText", PRecursiveHyperText);
		ETCFUNC("PRecursiveHyperBtn", PRecursiveHyperBtn);
		ETCFUNC("PRecursiveItemBtn", PRecursiveItemBtn);
		ETCFUNC("PRecursiveEquipBtn", PRecursiveEquipBtn);

		ETCFUNC("PRecursiveCheckBox", PRecursiveCheckBox);
		ETCFUNC("PRecursiveRadioBtn", PRecursiveRadioBtn);
		ETCFUNC("PRecursiveRadioGroup", PRecursiveRadioGroup);
		ETCFUNC("PRecursiveUIExp", PRecursiveUIExp);
		ETCFUNC("PRecursiveUIEdit", PRecursiveUIEdit);
		ETCFUNC("PRecursiveUISprite", PRecursiveUISprite);
		ETCFUNC("PRecursiveUIRoleNode", PRecursiveUIRoleNode);

		ETCFUNC("ConverToUiNode", ConverToUiNode);
		ETCFUNC("ConverToLabel", ConverToLabel);
		ETCFUNC("ConverToButton", ConverToButton);
		ETCFUNC("ConverToUiLayer", ConverToUiLayer);
		ETCFUNC("ConverToTableLayer", ConverToTableLayer);
		ETCFUNC("ConverToImage", ConverToImage);
		ETCFUNC("ConverToSVC", ConverToSVC);
		ETCFUNC("ConverToSV", ConverToSV);

		//** chh 2012-06-25 **//
		ETCFUNC("ConverToSVCM", ConverToSVC);
		ETCFUNC("ConverToSVM", ConverToSV);

		ETCFUNC("ConverToSCE", ConverToSCE);
		ETCFUNC("ConverToSCEV", ConverToSCEV);


		ETCFUNC("ConverToHLT", ConverToHLT);
		ETCFUNC("ConverToHLB", ConverToHLB);
		ETCFUNC("ConverToItemButton", ConverToItemButton);
		ETCFUNC("ConverToEquipBtn", ConverToEquipBtn);
		ETCFUNC("ConverToRoleNode",ConverToRoleNode);

		ETCFUNC("ConverToCheckBox", ConverToCheckBox);
		ETCFUNC("ConverToRadioBtn", ConverToRadioBtn);
		ETCFUNC("ConverToRadioGroup", ConverToRadioGroup);
		ETCFUNC("ConverToEdit", ConverToEdit);
		ETCFUNC("ConverToSprite", ConverToSprite);
        
		//++ Guosen 2012.6.3 //获得各种路径
		ETCFUNC("NDPath_GetResourcePath",						NDPath_GetResourcePath);
		ETCFUNC("NDPath_GetImagePath",							NDPath_GetImagePath);
		ETCFUNC("NDPath_GetMapPath",							NDPath_GetMapPath);
		ETCFUNC("NDPath_GetAnimationPath",						NDPath_GetAnimationPath);
		ETCFUNC("NDPath_GetResPath",							NDPath_GetResPath);
		ETCFUNC("NDPath_GetSoundPath",							NDPath_GetSoundPath);
		//tanwt 20120913 //注册本地通知
		ETCFUNC("RegisterLocalNotification",				    RegisterLocalNotification);
	}

	bool OnScriptUiEvent(NDUINode* uinode, int targetEvent, int param/*= 0*/)
	{
		if (!uinode)
		{
			return false;
		}
		
		LuaObject funcObj;
		
		if (!uinode->GetLuaDelegate(funcObj)
			|| !funcObj.IsFunction())
		{
			return false;
		}
		
		LuaFunction<bool> luaUiEventCallBack = funcObj;
		
		bool bRet = luaUiEventCallBack(uinode, targetEvent, param);
		
		return bRet;
	}
}
