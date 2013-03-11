---------------------------------------------------
--描述: 玩家背包界面
--时间: 2012.06.11
--作者: chh
---------------------------------------------------

BackLevelThreeWin = {}
local p = BackLevelThreeWin;
p.BEquip = false;
p.BEquipDaoFa = false;


--装备，材料，宝石，道具 TAG
local EQUIP_LAYER   = 1411;         --装备
local MATE_LAYER    = 1412;         --材料
local GEM_LAYER     = 1413;         --宝石
local PROP_LAYER    = 1414;         --道具
local DESTINY_LAYER = 1415;         --占星

local TAG_CLOSE     = 533;          --关闭

local TAG_EQUIP_NAME        = 401;               --装备名称
local TAG_EQUIP_PRICE       = 302;               --装备价格
local TAG_EQUIP_PROFESSION  = 201;               --装备职业
local TAG_EQUIP_LEVEL       = 202;               --装备等级
local TAG_EQUIP_PIC         = 48;                --装备图片
local TAG_EQUIP_ATTACK_TXT  = 418;               --文本
local TAG_EQUIP_ATTACK_VAL  = 214;               --数值
local TAG_EQUIP_ATTR        = {409,410,411,};
local TAG_EQUIP_GEN         = {203,204,419,420,215,216,};
local TAG_EQUIP_ATTR_TXT    = 415;              --提示附加属性文本


local TAG_EQUIP_UPGRADE     = 501;               --升级
local TAG_EQUIP_SELL        = 36;                --出售
local TAG_EQUIP_EQUIP       = 37;                --装备

local TAG_MATE_PIC           = 48;               --材料图片
local TAG_MATE_NAME         = 401;               --材料名称
local TAG_MATE_PRICE        = 201;               --材料价格
local TAG_MATE_DESC         = 402;               --材料描述
local TAG_MATE_SELL         = 501;               --出售


local TAG_PROP_PIC         = 51;
local TAG_PROP_NAME        = 401;
local TAG_PROP_PRICE       = 201;
local TAG_PROP_DESC        = 402;
local TAG_PROP_USE         = 501;                 --使用
local TAG_PROP_SELL        = 65;                  --出售

local TAG_GEM_PIC          = 48;                --宝石图片
local TAG_GEM_NAME         = 401;               --宝石名称
local TAG_GEM_PRICE        = 201;               --宝石价格
local TAG_GEM_PROP         = 54;                --宝石属性
local TAG_GEM_DESC         = 402;               --宝石描述
local TAG_GEM_USE          = 56;                --使用
local TAG_GEM_SELL         = 55;                --出售
local TAG_GEM_SYNTHESIS    = 501;               --合成

local TAG_DESTINY_PIC         = 51;
local TAG_DESTINY_NAME        = 401;
local TAG_DESTINY_EXP           = 201;               --价钱
local TAG_DESTINY_DESC        = 402;
local TAG_DESTINY_USE         = 501;                 --使用
local TAG_DESTINY_SELL        = 65;                  --出售
local TAG_DESTINY_ADD_DESC    = 20;                  --属性加层说明
local TAG_DESTINY_PRICE         = 52;               

local TAG_EQUIP_EQUIP_TIP   = {equip=GetTxtPri("BLTW_T1"),unsnatch=GetTxtPri("BLTW_T2"),};

p.parent = nil;

function p.LoadUI(parent)
    p.parent = parent;
    
    
    
    
    ----------------------------------------------------------------------
    --初始化层
    local equip_layer = createNDUILayer(); 
	if equip_layer == nil then
		return false;
	end
	
	equip_layer:SetPopupDlgFlag( true );
	equip_layer:Init();
	equip_layer:bringToTop();
	equip_layer:SetTag(EQUIP_LAYER);
    equip_layer:SetVisible(false);
	equip_layer:SetFrameRect(RectFullScreenUILayer);
	equip_layer:SetDebugName("equip_layer");
	p.parent:AddChildZ(equip_layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		equip_layer:Free();
		return false;
	end
	
	--bg    装备武器物品属性界面
	uiLoad:Load("Equip.ini", equip_layer, p.OnUIEventEquip, 0, 0);
    uiLoad:Free();
    ----------------------------------------------------------------------
    
    
    
    ----------------------------------------------------------------------
    local mate_layer = createNDUILayer();
	if mate_layer == nil then
		return false;
	end
	
	mate_layer:SetPopupDlgFlag( true );
	mate_layer:Init();
	mate_layer:bringToTop();
	mate_layer:SetTag(MATE_LAYER);
	mate_layer:SetFrameRect(RectFullScreenUILayer);
    mate_layer:SetVisible(false);
    mate_layer:SetDebugName("mate_layer");
    p.parent:AddChildZ(mate_layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		mate_layer:Free();
		return false;
	end
	
	--bg  背包材料属性界面
	uiLoad:Load("Mate.ini", mate_layer, p.OnUIEventMate, 0, 0);
    uiLoad:Free();
    ----------------------------------------------------------------------
    
    
    
    
    ----------------------------------------------------------------------
    local gem_layer = createNDUILayer();
	if gem_layer == nil then
		return false;
	end
	
	gem_layer:SetPopupDlgFlag( true );
	gem_layer:Init();
	gem_layer:bringToTop();
	gem_layer:SetTag(GEM_LAYER);
	gem_layer:SetFrameRect(RectFullScreenUILayer);
    gem_layer:SetVisible(false);
    gem_layer:SetDebugName("gem_layer");
    p.parent:AddChildZ(gem_layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		gem_layer:Free();
		return false;
	end
	
	--bg 背包宝石属性界面
	uiLoad:Load("Gem.ini", gem_layer, p.OnUIEventGem, 0, 0);
    uiLoad:Free();
    ----------------------------------------------------------------------
    
    
    
    
    
    ----------------------------------------------------------------------
    local prop_layer = createNDUILayer();
	if prop_layer == nil then
		return false;
	end
	
	prop_layer:SetPopupDlgFlag( true );
	prop_layer:Init();
	prop_layer:bringToTop();
	prop_layer:SetTag(PROP_LAYER);
	prop_layer:SetFrameRect(RectFullScreenUILayer);
    prop_layer:SetVisible(false);
    prop_layer:SetDebugName("prop_layer");
    p.parent:AddChildZ(prop_layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		prop_layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("Prop.ini", prop_layer, p.OnUIEventProp, 0, 0);
    uiLoad:Free();
    ----------------------------------------------------------------------
    
    
    
    
        
    ----------------------------------------------------------------------
    local destiny_layer = createNDUILayer();
	if destiny_layer == nil then
		return false;
	end
	destiny_layer:Init();
	destiny_layer:SetTag(DESTINY_LAYER);
	destiny_layer:SetFrameRect(RectFullScreenUILayer);
    destiny_layer:SetVisible(false);
    p.parent:AddChildZ(destiny_layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		destiny_layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("destiny/Destiny_Info.ini", destiny_layer, p.OnUIEventDestiny, 0, 0);
    uiLoad:Free();
    ----------------------------------------------------------------------

end

--显示装备三级窗口
function p.ShowUIEquip(nItemId, currPetId , bEquip)
    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);

    	
	local nQulity			= ItemFunc.GetQuality(nItemType);
	local strName			= ItemFunc.GetName(nItemType);
    local price             = ItemFunc.GetPrice(nItemType)*Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    local levelLV           = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
    local nJobReq           = ConvertN(ItemFunc.GetJobReq(nItemType));
    nJobReq = RolePetFunc.GetJobDesc(nJobReq);
	local nLvlReq           = ConvertN(ItemFunc.GetLvlReq(nItemType));
    
    if(levelLV>0) then 
        strName = strName.." +";
        strName = strName..levelLV;
    end
    
    --升阶
    local btnUpgrade = RecursiveButton(p.parent,{EQUIP_LAYER,TAG_EQUIP_UPGRADE});
   
    
    --出售
    local btnSale = RecursiveButton(p.parent,{EQUIP_LAYER,TAG_EQUIP_SELL});
    --装备
    local btnEquip = RecursiveButton(p.parent,{EQUIP_LAYER,TAG_EQUIP_EQUIP});
    
    --判断petId为0为时查看他人装备
    if(CheckN(currPetId) and currPetId>0) then
        btnUpgrade:SetParam1(nItemId);
        btnUpgrade:SetParam2(nItemType);
        btnSale:SetParam1(nItemId);
        btnEquip:SetParam1(nItemId);
        btnEquip:SetParam2(currPetId);
        
        if bEquip then
            btnEquip:SetTitle(TAG_EQUIP_EQUIP_TIP.unsnatch);
            btnSale:SetVisible(false);
        else
            btnEquip:SetTitle(TAG_EQUIP_EQUIP_TIP.equip);
            btnSale:SetVisible(true);
        end
        
    
			 	
       	if _G.ItemFunc.IfItemCanUpStep(nItemId) then
       		LogInfo("btnUpgrade:SetVisible(true);");
        	btnUpgrade:SetVisible(true);
    	else
        	btnUpgrade:SetVisible(false);
        end
        
        p.BEquip = bEquip;
        
    else    
        btnSale:SetVisible(false);
        btnEquip:SetVisible(false);
        btnSale:SetVisible(false);
        btnUpgrade:SetVisible(false);
    end
    
    
    
    local l_name = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_NAME});
    l_name:SetText(strName);
    
    --设置装备颜色
    ItemFunc.SetLabelColor(l_name,nItemType);
    
    local l_price = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_PRICE});
    l_price:SetText(SafeN2S(price));
    
    local l_profess = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_PROFESSION});
    l_profess:SetText(nJobReq);
    
    local l_level = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_LEVEL});
    l_level:SetText(SafeN2S(nLvlReq));
    
    local l_pic = RecursiveEquipBtn(p.parent,{EQUIP_LAYER,TAG_EQUIP_PIC});
    l_pic:ChangeItem(nItemId);
    
    local equipLv = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
    local txt,num = ItemFunc.GetAttrDesc(nItemType,equipLv);
    
    local l_attackText = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_ATTACK_TXT});
    local l_attackValue = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_ATTACK_VAL});
    l_attackText:SetText(txt);
    l_attackValue:SetText(num);
    
    local btAttrAmount = Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_NUM);
    if(btAttrAmount>#TAG_EQUIP_ATTR) then 
        btAttrAmount = #TAG_EQUIP_ATTR; 
    end
    local gem_beg = Item.ITEM_ATTR_BEGIN;
    
    
    local l_attr_txt = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_ATTR_TXT});
    if(btAttrAmount==0) then
        l_attr_txt:SetVisible(false);
    end
    
    
    
    --附加属性显示
    for i=1,#TAG_EQUIP_ATTR do
        if(i>btAttrAmount) then
            local l_attr = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_ATTR[i]});
            l_attr:SetText("");
        else
        
            local desc = Item.GetItemInfoN(nItemId, gem_beg);
            gem_beg = gem_beg + 1;
        
            local val = Item.GetItemInfoN(nItemId, gem_beg);
            gem_beg = gem_beg + 1;
        
            local txt = ItemFunc.GetAttrTypeValueDesc(desc, val);
            local l_attr = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_ATTR[i]});
            l_attr:SetText(txt);
        end
    end
    
    
    
    
    
    --镶嵌宝石显示
    local bGenCount = Item.GetItemInfoN(nItemId, Item.ITEM_GEN_NUM);
    LogInfo("bGenCount:[%d]",bGenCount);
    if(bGenCount>#TAG_EQUIP_GEN) then 
        bGenCount = #TAG_EQUIP_GEN; 
    end
    
    for i=1,#TAG_EQUIP_GEN do
        if(i>bGenCount) then
            local l_gem = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_GEN[i]});
            l_gem:SetText("");
        else
            local gemId = Item.GetItemInfoN(nItemId, gem_beg);
            LogInfo("gemId:[%d]",gemId);
            gem_beg = gem_beg + 1;
            local name = ItemFunc.GetName(gemId);
            LogInfo("name:[%s]",name);
            local l_gem = RecursiveLabel(p.parent,{EQUIP_LAYER,TAG_EQUIP_GEN[i]});
            l_gem:SetText(name);
            
            
            --设置装备颜色
            ItemFunc.SetLabelColor( l_gem,gemId);
        end
    end
    
    p.layerShowOrHide(EQUIP_LAYER, true);
end

--显示材料三级窗口
function p.ShowUIMate(nItemId)
   
    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local strName			= ItemFunc.GetName(nItemType);
    local price             = ItemFunc.GetPrice(nItemType)*Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    local desc              = ItemFunc.GetDesc(nItemType);

    local l_pic = RecursiveEquipBtn(p.parent,{MATE_LAYER,TAG_MATE_PIC});
    l_pic:ChangeItem(nItemId);
    
    local l_name = RecursiveLabel(p.parent,{MATE_LAYER,TAG_MATE_NAME});
    l_name:SetText(strName);
    
    --设置装备颜色
    ItemFunc.SetLabelColor(l_name,nItemType);
    
    local l_price = RecursiveLabel(p.parent,{MATE_LAYER,TAG_MATE_PRICE});
    l_price:SetText(SafeN2S(price));
    
    local l_desc = RecursiveLabel(p.parent,{MATE_LAYER,TAG_MATE_DESC});
    l_desc:SetText(desc);
    
    local btn = RecursiveButton(p.parent,{MATE_LAYER,TAG_MATE_SELL});
    btn:SetParam1(nItemId);
    
    p.layerShowOrHide(MATE_LAYER, true);
end

--显示宝石三级窗口
function p.ShowUIGem(nItemId)
    
    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local strName			= ItemFunc.GetName(nItemType);
    local price             = ItemFunc.GetPrice(nItemType)*Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    --local prop              = ItemFunc.GetGemPropDesc(nItemType);
    local desc              = ItemFunc.GetDesc(nItemType);

    local l_pic = RecursiveEquipBtn(p.parent,{GEM_LAYER,TAG_GEM_PIC});
    l_pic:ChangeItem(nItemId);
    
    local l_name = RecursiveLabel(p.parent,{GEM_LAYER,TAG_GEM_NAME});
    l_name:SetText(strName);
    
    --设置装备颜色
    ItemFunc.SetLabelColor(l_name,nItemType);
    
    local l_price = RecursiveLabel(p.parent,{GEM_LAYER,TAG_GEM_PRICE});
    l_price:SetText(SafeN2S(price));
    
    --[[
    local l_prop = RecursiveLabel(p.parent,{GEM_LAYER,TAG_GEM_PROP});
    l_prop:SetText(prop);
    ]]
    
    local l_desc = RecursiveLabel(p.parent,{GEM_LAYER,TAG_GEM_DESC});
    l_desc:SetText(desc);
    
    local btnSale = RecursiveButton(p.parent,{GEM_LAYER,TAG_GEM_SELL});
    btnSale:SetParam1(nItemId);
    
    local btnSyn = RecursiveButton(p.parent,{GEM_LAYER,TAG_GEM_SYNTHESIS});
    btnSyn:SetParam1(nItemId);
    
    local nGemLevel = Num3(nItemType)*10+Num2(nItemType);
    if(nGemLevel == 12) then
        btnSyn:EnalbeGray(true);
    else
        btnSyn:EnalbeGray(false);
    end
    
    p.layerShowOrHide(GEM_LAYER, true);
end

--显示道具三级窗口
function p.ShowUIProp(nItemId, nCurrPetId)
    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local strName			= ItemFunc.GetName(nItemType);
    local price             = ItemFunc.GetPrice(nItemType)*Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    local desc              = ItemFunc.GetDesc(nItemType);

    local l_pic = RecursiveEquipBtn(p.parent,{PROP_LAYER,TAG_PROP_PIC});
    l_pic:ChangeItem(nItemId);
    
    local l_name = RecursiveLabel(p.parent,{PROP_LAYER,TAG_PROP_NAME});
    l_name:SetText(strName);
    
    --设置装备颜色
    ItemFunc.SetLabelColor(l_name,nItemType);
    
    local l_price = RecursiveLabel(p.parent,{PROP_LAYER,TAG_PROP_PRICE});
    l_price:SetText(SafeN2S(price));
    
    local l_desc = RecursiveLabel(p.parent,{PROP_LAYER,TAG_PROP_DESC});
    l_desc:SetText(desc);
    
    local btn = RecursiveButton(p.parent,{PROP_LAYER,TAG_PROP_USE});  
    btn:SetParam1(nItemId);
    btn:SetParam2(nCurrPetId);
    
    local btnSale = RecursiveButton(p.parent,{PROP_LAYER,TAG_PROP_SELL});
    btnSale:SetParam1(nItemId);
    
    
    local nItemType	= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local nType = ItemFunc.GetPropType(nItemType);
    
    if(nType == 1 or nType == 4 or nType == 5 or nType == 6  or nType == 7) then
        btn:SetVisible(true);
    else
        btn:SetVisible(false);
    end
    
    p.layerShowOrHide(PROP_LAYER, true);
end

--显示道具三级窗口
--bEquipDaoFa:true 执行卸下操作，false 反之装备操作
function p.ShowUIDestiny(nItemId, nCurrPetId, bEquipDaoFa)
    if( nItemId == nil or nItemId == 0 )then
        LogInfo("BackLevelThreeWin.ShowUIDestiny 参数错误");
        return;
    end
    
    p.BEquipDaoFa = bEquipDaoFa;
    
    LogInfo("nCurrPetId:[%d]",nCurrPetId);

    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local nQuality          = Num1(nItemType);
    local strName			= ItemFunc.GetName(nItemType);
    local levelLV           = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION);
    local price             = ItemFunc.GetPrice(nItemType)*Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    local exp               = Item.GetItemInfoN(nItemId, Item.ITEM_EXP);
    local desc              = ItemFunc.GetDesc(nItemType);

    if(nQuality > DAOFA_QUALITY_DATA.RED) then 
        strName = string.format("%s (%d%s)",strName,levelLV,GetTxtPub("Level"));
    end
    
    local l_pic = RecursiveEquipBtn(p.parent,{DESTINY_LAYER,TAG_DESTINY_PIC});
    l_pic:ChangeItem(nItemId);
    
    local l_name = RecursiveLabel(p.parent,{DESTINY_LAYER,TAG_DESTINY_NAME});
    l_name:SetText(strName);
    
    local l_price = RecursiveLabel(p.parent,{DESTINY_LAYER,TAG_DESTINY_PRICE});
    l_price:SetText(price.."");
    
    
    --设置物品颜色
    ItemFunc.SetDaoFaLabelColor(l_name,nItemType);
    
    
    local sTip;
    
    if(nQuality == 1) then
        local nExpFx = GetDataBaseDataN("daofa_static_config",DB_DAOFA_STATIC_CONFIG_ID.RED,DB_DAOFA_STATIC_CONFIG.VALUE);
        sTip = string.format("%d",nExpFx);
    else
        sTip = string.format("%d/%d",exp,p.GetTotalByItemId(nItemId));
    end
    local l_exp = RecursiveLabel(p.parent,{DESTINY_LAYER,TAG_DESTINY_EXP});
    l_exp:SetText(sTip); 
    
    
    local s_add_desc = ItemFunc.GetDestinyAdd(nItemId);
    local l_add_desc = RecursiveLabel(p.parent,{DESTINY_LAYER,TAG_DESTINY_ADD_DESC});
    l_add_desc:SetText(GetTxtPri("DU_T26")..s_add_desc);
    
    
    local l_desc = RecursiveLabel(p.parent,{DESTINY_LAYER,TAG_DESTINY_DESC});
    l_desc:SetText(desc);
    
    local btn = RecursiveButton(p.parent,{DESTINY_LAYER,TAG_DESTINY_USE});  
    btn:SetParam1(nItemId);
    btn:SetParam2(nCurrPetId);
    
    local btnSale = RecursiveButton(p.parent,{DESTINY_LAYER,TAG_DESTINY_SELL});
    btnSale:SetParam1(nItemId);
    
    if bEquipDaoFa then
        btn:SetTitle(TAG_EQUIP_EQUIP_TIP.unsnatch);
        btnSale:SetVisible(false);
    else
        btn:SetTitle(TAG_EQUIP_EQUIP_TIP.equip);
        btnSale:SetVisible(true);
    end
    
    if bEquipDaoFa == nil then
        btn:SetVisible(false);
        btnSale:SetVisible(false);
    end
    
    p.layerShowOrHide(DESTINY_LAYER, true);
end

function p.GetTotalByItemId(nItemId)
    local levelLV = Item.GetItemInfoN(nItemId, Item.ITEM_ADDITION)+1;
    local quality = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE)%10;
    
    local nMaxLevel = p.GetMaxLevelByQuality(quality);
    if levelLV>nMaxLevel then
        levelLV = nMaxLevel;
    end
    
    local ids = GetDataBaseIdList("dao_levelup_exp");
    for i,v in ipairs(ids) do
        local nLevel = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.LEVEL);
        local nQuality = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.QUALITY);
        LogInfo("levelLV:[%d],quality:[%d],nLevel:[%d],nQuality:[%d]",levelLV,quality,nLevel,nQuality);
        
        if(nLevel == levelLV and nQuality == quality) then
            return GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.EXP);
        end
    end
    
    return 0;
end

function p.GetMaxLevelByQuality(nQuality)
    local level = nil;
    local ids = GetDataBaseIdList("dao_levelup_exp");
    for i,v in ipairs(ids) do
        local nQualityV = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.QUALITY);
        if(nQuality == nQualityV) then
            local nLevel = GetDataBaseDataN("dao_levelup_exp", v, DB_DAO_LEVELUP_EXP.LEVEL);
            if(level) then
                if(level<nLevel) then
                    level = nLevel;
                end
            else
                level = nLevel;
            end
        end
    end
    if(level == nil) then
        return 0;
    end
    return level;
end


--装备窗口事件
function p.OnUIEventEquip(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("tag:[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
            p.layerShowOrHide(EQUIP_LAYER, false);
        elseif(tag == TAG_EQUIP_UPGRADE) then       --升级
            p.layerShowOrHide(EQUIP_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            local nItemTypeId = btn:GetParam2();
            
         	if not IsUIShow(NMAINSCENECHILDTAG.PlayerEquipUpStepUI) then
				--CloseMainUI();
				LogInfo("sheng jie[%d][%d]", nItemId,nItemTypeId);
				PlayerEquipUpStepUI.LoadUI(nItemId,nItemTypeId);
				
			end   
        elseif(tag == TAG_EQUIP_SELL) then          --出售
            p.layerShowOrHide(EQUIP_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            p.SellItemTip(nItemId);
            
        elseif(tag == TAG_EQUIP_EQUIP) then         --装备
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            local nPetId = btn:GetParam2();
            local isEquip = p.BEquip;
            
            p.EquipOperate(nItemId, nPetId, isEquip);
        end
    end
    
    return true;
end



--装备操作
function p.EquipOperate(nItemId, nPetId, isEquip)
    p.layerShowOrHide(EQUIP_LAYER, false);
    
    if(isEquip) then
        if not RolePet.IsExistPet(nPetId) then
            LogInfo("脱装 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
            return true;
        end
        
        if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
            CloseMainUI();
            PlayerUIBackBag.LoadUI(Item.bTypeEquip, nPetId);
        end
        
        --判断背包是否已满
        if(ItemFunc.IsBagFull(-1)) then
            return false;
        end
        
        MsgItem.SendUnPackEquip(nPetId, nItemId);
    else
        if not RolePet.IsExistPet(nPetId) then
            LogInfo("穿装备 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
            return true;
        end
        
        --判断背包是否已满
        if(ItemFunc.IsBagFullEquip(nPetId, nItemId)) then
            return false;
        end
        
        --判断装备职业
        if(p.equippedWithEquipment(nPetId, nItemId) == false) then
            return;
        end
        
        --判断宠物等级是否到达装备要求等级
        if(p.equipMinimumLevel(nPetId, nItemId) == false) then
            return;
        end
        
        MsgItem.SendPackEquip(nItemId, nPetId);
    end
    ShowLoadBar(); 
end


--判断装备职业
function p.equippedWithEquipment(nPetId, nEquipId)
    local nItemType			= Item.GetItemInfoN(nEquipId, Item.ITEM_TYPE);
    local nItemProfess = Num4(nItemType);
    
    local nPetType      = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    local nPetProfess   = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.PROFESSION);
    
    LogInfo("nPetId:[%d], nEquipId:[%d], nItemType:[%d], nItemProfess:[%d], nPetType:[%d], nPetProfess:[%d]",nPetId, nEquipId, nItemType, nItemProfess, nPetType, nPetProfess);
    
    
    nPetProfess = nPetProfess%3;
    if(nPetProfess == 0) then
        nPetProfess = 3;
    end
    
    if(nItemProfess~=nPetProfess and nItemProfess ~= 0) then
        p.tipEquipProfessIrreg();
        return false;
    end
    return true;
end


--判断宠物等级是否到达装备要求等级
function p.equipMinimumLevel(nPetId, nEquipId)
    local nItemType	= Item.GetItemInfoN(nEquipId, Item.ITEM_TYPE);
    local equipLv   = ConvertN(ItemFunc.GetLvlReq(nItemType));
    local petLv = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    LogInfo("nPetId:[%d], nEquipId:[%d], equipLv:[%d], petLv:[%d]",nPetId, nEquipId, equipLv, petLv);
    
    if(equipLv>petLv) then
        p.tipPetLevelLack();
        return false;
    end
    return true;
end


function p.OnUIEventMate(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventEquip[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
            p.layerShowOrHide(MATE_LAYER, false);
        elseif(tag == TAG_MATE_SELL) then           --出售
            p.layerShowOrHide(MATE_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            p.SellItemTip(nItemId);
        end
    end
    return true;
end


function p.OnUIEventGem(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventGem[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
            p.layerShowOrHide(GEM_LAYER, false);
        elseif(tag == TAG_GEM_USE) then             --使用
            --p.layerShowOrHide(GEM_LAYER, false);
            
            CloseMainUI();
            EquipUpgradeUI.LoadUI(EquipUpgradeUI.TAG.MOSAIC);
            
        elseif(tag == TAG_GEM_SELL) then            --出售
            p.layerShowOrHide(GEM_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            p.SellItemTip(nItemId);
            
        elseif(tag == TAG_GEM_SYNTHESIS) then       --合成
            p.layerShowOrHide(GEM_LAYER, false); 
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            
            p.GemSynthesis(nItemId);
        end
    end
    return true;
end

--宝石合成
function p.GemSynthesis(nItemId)
    --判断背包是否已满
    if(ItemFunc.IsBagFull()) then
        return false;
    end
    
    --宝石不足判断
    local nItemType			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local count             = Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
    if(count<2) then
        p.tipMateLack();
        return;
    end
    
    MsgCompose.SendGenComposeAction(nItemId);
    ShowLoadBar();
end


p.nTagId = 0;

function p.OnUIEventProp(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventEquip[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
            p.layerShowOrHide(PROP_LAYER, false);
        elseif(tag == TAG_PROP_USE) then            --使用
            p.layerShowOrHide(PROP_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId   = btn:GetParam1();
            local nItemType	= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
        	LogInfo("qbw glid id"..nItemId);
            
            
            
            
            
            
            local nType = ItemFunc.GetPropType(nItemType);
            
            if(nType == 1) then     --礼包使用
                
                --local nNum = GetDataBaseDataN("box_type",nItemType,DB_BOX_TYPE.ID);
                
                --判断背包是否已满
                --if(ItemFunc.IsBagFull(nNum)) then
                if(ItemFunc.IsBagFull()) then
                    return false;
                end
                
                
                local nPlayerId     = GetPlayerId();
                local nPetId        = RolePetFunc.GetMainPetId(nPlayerId);
                
                --判断宠物等级是否到达物品要求等级
                if(p.equipMinimumLevel(nPetId, nItemId) == false) then
                    return;
                end
                local count = Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
                p.nTagId = CommonDlgNew.ShowInputDlg(GetTxtPri("PLAYER_T3"), p.OnUIEventUseNum, {nItemId}, count,2);
                
            elseif(nType == 2) then     --任务物品
            
            elseif(nType == 3) then     --升阶
                
                local btn = ConverToButton(uiNode);
                local nItemId   = btn:GetParam1();
                PlayerEquipUpStepUI.LoadUI(nItemId);
                
            elseif(nType == 4) then     --经验卡
                --PlayerEquipGlidUI.LoadUI(nItemId);
                
                local nCurrPetId = btn:GetParam2();
                
                --计算最大使用多少张经验卡
                local count = Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
                local nPlayerTotalExp, nPetTotalExp = p.GetExps(nItemId,nCurrPetId);
                local nItemTypeId = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
                local nExpVal = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.DATA);
                
                local nMaxUseCount = math.floor((nPlayerTotalExp-nPetTotalExp)/nExpVal);
                
                LogInfo("count:[%d],nPlayerTotalExp:[%d],nItemTypeId:[%d],nExpVal:[%d],nMaxUseCount:[%d]",count,nPlayerTotalExp,nItemTypeId,nExpVal,nMaxUseCount);
                
                if(nMaxUseCount<count) then
                    count = nMaxUseCount;
                end
                
                if(count<1) then
                    count = 1;
                end
                
                p.nTagId = CommonDlgNew.ShowInputDlg(GetTxtPri("PLAYER_T3"), p.OnUIEventUseNum, {nItemId,nCurrPetId},count,2);
            elseif(nType == 5) then     --神铸
                local btn = ConverToButton(uiNode);
                local nItemId   = btn:GetParam1();
                PlayerEquipGlidUI.LoadUI(nItemId);
            elseif(nType == 6) then     --神马鞭
                CloseMainUI();
                PetUI.LoadUI(true);
           elseif nType == 7 then	--斗地主道具
            	local count = Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT);
            	p.nTagId = CommonDlgNew.ShowInputDlg(GetTxtPri("PLAYER_T3"), p.OnUIEventUseNum, {nItemId}, count, 2);               
            end
            
            
        elseif(tag == TAG_PROP_SELL) then           --出售
            p.layerShowOrHide(PROP_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            p.SellItemTip(nItemId);
        end
    end
    return true;
end


function p.OnUIEventDestiny(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventDestiny[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if(tag == TAG_CLOSE) then
            p.layerShowOrHide(DESTINY_LAYER, false);
        elseif(tag == TAG_DESTINY_USE) then            --使用
            p.layerShowOrHide(PROP_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId   = btn:GetParam1();
            local nPetId    = btn:GetParam2();
            local nPosition = DestinyUI.GetCanEquipPosition();
            
            p.DestinyEquipOperate(nItemId, nPetId, nPosition, p.BEquipDaoFa);
            p.layerShowOrHide(DESTINY_LAYER, false);
        elseif(tag == TAG_DESTINY_SELL) then           --出售
            p.layerShowOrHide(DESTINY_LAYER, false);
            
            local btn = ConverToButton(uiNode);
            local nItemId = btn:GetParam1();
            p.SellItemTip(nItemId);
            
            p.layerShowOrHide(DESTINY_LAYER, false);
        end
    end
     
    return true;
end

function p.DestinyEquipOperate(nItemId, nPetId, nPosition, bIsEquip)
    LogInfo("p.DestinyEquipOperate");
    local nItemType	= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    if( bIsEquip ) then    
        --卸下
        --判断背包是否已满
        if(ItemFunc.IsDestinyBagFull()) then
            return false;
        end
        
        MsgItem.SendUnDaoFa(nPetId, nItemId);
    else
        local nPlayerId = GetPlayerId();
        
        local idlist	= ItemPet.GetDaoFaItemList(nPlayerId, nPetId);
        LogInfo("#idlist:[%d],Item.POSITION_DAO_FA_8 - Item.POSITION_DAO_FA_1:[%d]",#idlist,Item.POSITION_DAO_FA_8 - Item.POSITION_DAO_FA_1);
        
        --不能装备福星
        local nQuality = Num1(nItemType)
        if(nQuality == 1) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T17"));
            return false;
        end
        
        
        --装备栏满判断
        if (#idlist >= (Item.POSITION_DAO_FA_8 - Item.POSITION_DAO_FA_1 + 1)) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T11"));
            return false;
        end
        
        --装备
        if nPosition == 0 then
            LogInfo("error nPosition == 0!");
            return false;
        end
        
        local nItemType1			= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
        local nType1 = GetDataBaseDataN("itemtype", nItemType1, DB_ITEMTYPE.ATTR_TYPE_1)/10;
        local nStatusType1 = GetDataBaseDataN("itemtype", nItemType1, DB_ITEMTYPE.STATUS_ATTR_TYPE1);
        --判断是否有相同占星存在
        for i,v in ipairs(idlist) do
            local nItemType2			= Item.GetItemInfoN(v, Item.ITEM_TYPE);
            local nType2 = GetDataBaseDataN("itemtype", nItemType2, DB_ITEMTYPE.ATTR_TYPE_1)/10;
            local nStatusType2 = GetDataBaseDataN("itemtype", nItemType2, DB_ITEMTYPE.STATUS_ATTR_TYPE1);
            
            if(nType1 == 0) then
                if(nStatusType2 == nStatusType1) then
                    CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T27"));
                    return false;
                end
            else
                if(nType1 == nType2) then
                    CommonDlgNew.ShowYesDlg(GetTxtPri("DU_T27"));
                    return false;
                end
            end
            
        end
        
        MsgItem.SendPackDaoFa(nItemId, nPetId, nPosition);
    end

    ShowLoadBar();
end

function p.OnUIEventUseNum(nEventType, param, val)
    if(CommonDlgNew.BtnOk == nEventType) then
        local num = math.floor(SafeS2N(val));
        
        if(num>0) then
            local nItemType	= Item.GetItemInfoN(param[1], Item.ITEM_TYPE);
            local nType = ItemFunc.GetPropType(nItemType);
            local count = Item.GetItemInfoN(param[1], Item.ITEM_AMOUNT);
            
            
            if(num>count) then
                p.tipNumMaxVail(count);
                return;
            end
            
            if(nType == 1) then
                
            elseif(nType == 4) then
                
                --主角使用经验卡判断
                local nPlayerId = GetPlayerId();
                local nPlayerPetId = RolePetFunc.GetMainPetId(nPlayerId);
                if(nPlayerPetId == param[2]) then
                    p.tiPlayerUseVail();
                    return;
                end
                
                --****--
                --判断宠物等级是否到达物品要求等级
                if(p.equipMinimumLevel(param[2], param[1]) == false) then
                    return;
                end

                --****--
                --判断宠物等级是否到达物品要求等级
                if(p.equipMinimumLevel(param[2], param[1]) == false) then
                    return;
                end
                
                --伙伴等级超过主角判断
                local nPlayerTotalExp, nPetTotalExp = p.GetExps(param[1],param[2]);
                local nGetExp = p.GetTotalExp(param[1],num);
                if(nPetTotalExp+nGetExp>=nPlayerTotalExp) then
                    p.tipUpdageLevelVail();
                    return;
                end
                
            end
        
            MsgItem.SendUseItem(param[1],num,param[2]);
            ShowLoadBar();
        else
            p.tipNumVail();
        end
    end
end

--获得使用经验卡后获得的经验
function p.GetTotalExp(nItemId, nNum)
    local nItemTypeId = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local nExpVal = GetDataBaseDataN("itemtype", nItemTypeId, DB_ITEMTYPE.DATA);
    local nAddTotalExp = nExpVal * nNum;
    return nAddTotalExp;
end

--获得主角经验和当前伙伴经验
function p.GetExps(nItemId, nPetId)
    
    local nPlayerId = GetPlayerId();
    local nPlayerPetId = RolePetFunc.GetMainPetId(nPlayerId);
    local nPlayerPetLevel = RolePet.GetPetInfoN(nPlayerPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    LogInfo("nPlayerId:[%d],nPlayerPetId:[%d],nPlayerPetLevel:[%d]",nPlayerId,nPlayerPetId,nPlayerPetLevel);
    
    local nCurrPetLevel = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL)-1;
    local nCurrPetExp = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP);
    
    LogInfo("nCurrPetLevel:[%d],nCurrPetExp:[%d]",nCurrPetLevel,nCurrPetExp);
                
    local nPlayerTotalExp, nPetTotalExp;
    nPlayerTotalExp = 0;
    nPetTotalExp = 0;
    for i=1,nPlayerPetLevel do
        nPlayerTotalExp = nPlayerTotalExp + GetDataBaseDataN("pet_levexp", i, DB_PET_LEVEXP.EXP);
    end
    
    for i=1,nCurrPetLevel do
        nPetTotalExp = nPetTotalExp + GetDataBaseDataN("pet_levexp", i, DB_PET_LEVEXP.EXP);
    end
    nPetTotalExp = nPetTotalExp + nCurrPetExp;
    
    LogInfo("nPlayerTotalExp:[%d],nPetTotalExp:[%d]",nPlayerTotalExp,nPetTotalExp);
    
    return nPlayerTotalExp,nPetTotalExp;
end

--获得装备查看层
function p.GetEquipLayer()
    local scene = GetSMGameScene();
    if(scene == nil or p.parent == nil) then
        return nil;
    end
    return GetUiLayer(p.parent,EQUIP_LAYER);
end

--获得道具查看层
function p.GetPropLayer()
    local scene = GetSMGameScene();
    if(scene == nil or p.parent == nil) then
        return nil;
    end
    return GetUiLayer(p.parent,PROP_LAYER);
end

--主角不得使用经验卡
function p.tiPlayerUseVail()
    CommonDlgNew.ShowYesDlg(GetTxtPri("NotUseExpCard"));
end

--伙伴等级验证
function p.tipUpdageLevelVail()
    CommonDlgNew.ShowYesDlg(GetTxtPri("PartnerLevelLimit"));
end

--数字验证
function p.tipNumVail()
    CommonDlgNew.ShowYesDlg(GetTxtPri("NumGT0"));
end

--最大验证
function p.tipNumMaxVail(nNum)
    CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("MaxExpUseLimit"),nNum));
end

--层的显示和隐藏
function p.layerShowOrHide(tag, flag)
    local layer = GetUiLayer(p.parent, tag);
    layer:SetVisible(flag);
end

function p.DestoryLayer()
    p.parent = nil;
end

--人物职业不符合
function p.tipEquipProfessIrreg()
    CommonDlgNew.ShowYesDlg(GetTxtPri("ProfessionLimit"));
end


--人物等级不够
function p.tipPetLevelLack()
    CommonDlgNew.ShowYesDlg(GetTxtPri("PlayerLevelLimit"));
end

--材料不足
function p.tipMateLack()
    CommonDlgNew.ShowYesDlg(GetTxtPri("MateNotEnough"));
end


--出售物品
function p.SellItemTip(nItemId)
    --价格为0的不能卖
    local nItemType = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
    local nPrice = ItemFunc.GetPrice(nItemType);
    if(nPrice <= 0) then
        CommonDlgNew.ShowTipDlg(GetTxtPri("NotSellItem"));
        return;
    end
    CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("IsSellItem"),p.SellItemOk,nItemId);
end

function p.SellItemOk(nEventType, param)
    if(nEventType == CommonDlgNew.BtnOk) then
        ShowLoadBar();
        
        local nItemId = param;
        local nCount = Item.GetItemInfoN(nItemId, Item.ITEM_AMOUNT)
        MsgItem.SendShopAction(nItemId,nCount);
    end
end


