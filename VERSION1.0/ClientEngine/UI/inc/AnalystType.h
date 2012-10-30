#ifndef _UTILITYANALYST_H_
#define _UTILITYANALYST_H_

#pragma once

#include <I_Analyst.h>

// #define ANALYST_NET		0
#define ANALYST_DB		1


enum ANALYST_TYPE
{
	ANALYST_BEGIN = 0,
    ANALYST_IDLE,
    ANALYST_MSG_PROCESS,
    ANALYST_DRAW_SCENE,
    ANALYST_DRAW_BASELAYER,
    
    ANALYST_SPRITE,
    ANALYST_NDTILE,
    ANALYST_NDTILE1,
    ANALYST_NDTILE2,
    ANALYST_NDTILE3,
    ANALYST_NDTILE4,
    
    ANALYST_QuickTalkCell,
    ANALYST_ChatRecord,
    ANALYST_ItemFocus,
    ANALYST_ItemViewText,
    ANALYST_HyperLinkButton,
    ANALYST_NDEraseInOutEffect,
    ANALYST_NDUIText,
    ANALYST_NDUIBUTTON,
    ANALYST_NDUICheckBox,
    ANALYST_NDUIDefaultSectionTitle,
    ANALYST_NDUIEdit,
    ANALYST_NDUIFrame,
    ANALYST_NDUIImage,
    ANALYST_NDUILabel,
    ANALYST_NDUILayer,
    ANALYST_NDUIMemo,
    ANALYST_NDUINode,
    ANALYST_NDUIOptionButton,
    ANALYST_NDUIOptionButtonEx,
    ANALYST_NDUIProgressBar,
    ANALYST_NDUISectionTitle,
    ANALYST_NpcNode,
    ANALYST_SocialTextLayer,
    ANALYST_CUICheckBox,
    ANALYST_CUIEdit,
    ANALYST_CUIExp,
    ANALYST_CUIItemButton,
    ANALYST_CUIRoleNode,
    ANALYST_CUISpriteNode,
    ANALYST_NDPicture,
    ANALYST_NDMapLayerdraw,
    ANALYST_NDMapLayerdraw1,
    ANALYST_NDMapLayerdraw2,
    ANALYST_NDMapLayerdraw3,
    ANALYST_NDMapLayerdraw4,
    ANALYST_NDMapLayerdraw5,
    ANALYST_NDMapLayerdraw6,
    ANALYST_DrawBgs,
    ANALYST_MakeOrders,
    ANALYST_DrawScenesAndAnimations,
    ANALYST_DrawScenesAndAnimations2,

	ANALYST_END,
};




#endif	//file guard