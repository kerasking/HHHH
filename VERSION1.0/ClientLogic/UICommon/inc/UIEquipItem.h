#ifndef _UI_EQUIP_ITEM_H_ZJH_
#define _UI_EQUIP_ITEM_H_ZJH_

#include "UIItemButton.h"
#include "UISpriteNode.h"

class CUIEquipItem :
	public CUIItemButton
{
	DECLARE_CLASS(CUIEquipItem)
	
	CUIEquipItem();
	~CUIEquipItem();
    
    void Initialization();
    
    void SetUpgradeIconPos(int nUpgradeIconPos)
	{
        m_nUpgradeIconPos = nUpgradeIconPos;
        AdjustPos();
    };

	int GetUpgradeIconPos()
	{
        return m_nUpgradeIconPos;
    };
    
    void SetUpgrade(int nSet)
	{
        m_nIsUpgrade = nSet;
        AdjustPos();
    };
	int GetUpgrade(){return m_nIsUpgrade;};

protected:
    int m_nIsUpgrade;
    int m_nUpgradeIconPos;
    CUISpriteNode *m_GUpgradeSprite;
    CUISpriteNode *m_RUpgradeSprite;
    
    void AdjustPos();
};

#endif