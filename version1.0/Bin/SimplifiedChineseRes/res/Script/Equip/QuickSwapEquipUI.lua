

---------------------------------------------------
--描述: 快速换装备
--时间: 2012.12.19
--作者: chh
---------------------------------------------------
QuickSwapEquipUI = {}
local p = QuickSwapEquipUI;

local TAG_CONTAINER     = 101;
local TAG_SWAP_BTN      = 57;

local TAG_BOX_PIC1_BTN          = 204;
local TAG_BOX_NAME1_LBL         = 202;
local TAG_BOX_LEVEL1_LBL        = 203;

local TAG_BOX_PIC2_BTN          = 248;
local TAG_BOX_NAME2_LBL         = 249;
local TAG_BOX_LEVEL2_LBL        = 250;

local TAG_LIST_ITEM_PIC_BTN     = 6;
local TAG_LIST_ITEM_NAME_LBL    = 17;
local TAG_LIST_ITEM_LEVEL_LBL   = 18;
local TAG_LIST_ITEM_SIZE_BTN    = 77;

local TagClose          = 533;

p.nPetId = 0;
p.nPetIdTarget = 0;
p.sParent = nil;

function p.LoadUI( sParent, nPetId)
    p.nPetId = nPetId;
    p.sParent   = sParent;
    
--------------------添加层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.QuickSwapEquipUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	p.sParent:AddChildZ(layer,1);
-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("Reloading/Reloading_BG.ini", layer, p.OnUIEvent, 0, 0);
    uiLoad:Free();
    
    p.RefreshUser();
    p.FullRightTopInfo();
    
    return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEvent[%d], event:%d!", tag, uiEventType);
    
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if TagClose == tag then   
            p.CloseUI();
        elseif TAG_SWAP_BTN == tag then
            --换装消息
            p.SwapEquip();
        end
    end
    return true;
end

function p.SwapEquip()
    local nProfessA = GetDataBaseDataN("pet_config", RolePet.GetPetInfoN(p.nPetId,PET_ATTR.PET_ATTR_TYPE), DB_PET_CONFIG.PROFESSION);
    local nProfessB = GetDataBaseDataN("pet_config", RolePet.GetPetInfoN(p.nPetIdTarget,PET_ATTR.PET_ATTR_TYPE), DB_PET_CONFIG.PROFESSION);
    
    local nNameA    = RolePetFunc.GetPropDesc(p.nPetId, PET_ATTR.PET_ATTR_NAME);
    local nNameB    = RolePetFunc.GetPropDesc(p.nPetIdTarget, PET_ATTR.PET_ATTR_NAME);
    
    LogInfo("nProfessA:[%d],nProfessB:[%d]",nProfessA,nProfessB);
    
    if(nProfessA == PROFESSION_TYPE.AXE) then
        nProfessA = PROFESSION_TYPE.SWORD;
    end
    
    if(nProfessB == PROFESSION_TYPE.AXE) then
        nProfessB = PROFESSION_TYPE.SWORD;
    end
    
    LogInfo("nProfessA:[%d],nProfessB:[%d]",nProfessA,nProfessB);
    
    local nIsEquip = true;
    if(nProfessA ~= nProfessB) then
        nIsEquip = false;
    end
    
    local bFlag = p.IsAllowEquip(nIsEquip);
    if( bFlag ) then
        if(nIsEquip) then
            p.SendSwapEquip()
        else
            CommonDlgNew.ShowYesOrNoDlg(string.format("【%s】和【%s】职业不同，武器将不会互换，你确定要换装吗？",nNameA,nNameB), p.SwapEquipCallback);
        end
    end
end

function p.SwapEquipCallback(nEventType , nEvent, param)
	if nEventType == CommonDlgNew.BtnOk then
		p.SendSwapEquip();
	end
end


--nIsEquip:是否需要判断武器的等级条件
function p.IsAllowEquip( nIsEquip )
    local nFlagA = p.IsEquipOk(p.nPetId, p.nPetIdTarget, nIsEquip);
    local nFlagB = p.IsEquipOk(p.nPetIdTarget, p.nPetId, nIsEquip);
    
    local nNameA    = RolePetFunc.GetPropDesc(p.nPetId, PET_ATTR.PET_ATTR_NAME);
    local nNameB    = RolePetFunc.GetPropDesc(p.nPetIdTarget, PET_ATTR.PET_ATTR_NAME);
    if(nFlagA == false) then
        CommonDlgNew.ShowYesDlg(string.format("【%s】的等级不足，无法换上【%s】的装备。",nNameB,nNameA));
        return false;
    end
    
    if(nFlagB == false) then
        CommonDlgNew.ShowYesDlg(string.format("【%s】的等级不足，无法换上【%s】的装备。",nNameA,nNameB));
        return false;
    end
    return true;
end

--A武将的装备放到B武将上是否能装备
function p.IsEquipOk(nPetIdA, nPetIdB, nIsEquip)
    local nLevelB = RolePet.GetPetInfoN(nPetIdB, PET_ATTR.PET_ATTR_LEVEL);
    
    local idlist	= ItemPet.GetEquipItemList(GetPlayerId(), nPetIdA);
    for i,v in ipairs(idlist) do
        local nItemType			= Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nLvlReq           = ConvertN(ItemFunc.GetLvlReq(nItemType));
        
        local nPostion = Item.GetItemInfoN(v, Item.ITEM_POSITION);
        if( (nPostion == Item.POSITION_EQUIP_1 and nIsEquip) or (nPostion ~= Item.POSITION_EQUIP_1)) then
            
            if(nLevelB<nLvlReq) then
                return false;
            end
            
        end
    end
    return true;
end

function p.SendSwapEquip()
    ShowLoadBar();
    MsgItem.SendExchangeEquip(p.nPetId,p.nPetIdTarget);
end

function p.OnUIUserItemEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIUserItemEvent[%d], event:%d!", tag, uiEventType);
    
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if TAG_LIST_ITEM_SIZE_BTN == tag then   
            local btn = ConverToButton(uiNode);
            if(btn) then
                local nPetId = btn:GetParam1();
                p.nPetIdTarget = nPetId;
                p.FullRightDownInfo(nPetId);
                p.SelectUserFocus(nPetId);
            end
        end
    end
    return true;
end

function p.CloseUI()
    p.nPetId = 0;
    p.nPetIdTarget = 0;
    local layer = p.GetCurrLayer();
    layer:RemoveFromParent(true);
end

function p.RefreshUser()
    local container = p.GetUserContainer();
    container:RemoveAllView();
    container:EnableScrollBar(true);
    
    local idTable = RolePetUser.GetPetListPlayer(GetPlayerId());
    idTable = RolePet.OrderPets(idTable);
    
    for i, v in ipairs(idTable) do
        if(p.nPetId ~= v) then
            p.CreateUserItem(v);
        end
	end
end

function p.CreateUserItem( nPetId )
    local container = p.GetUserContainer();
    local view = createUIScrollView();
    
    view:Init(false);
    view:SetScrollStyle(UIScrollStyle.Verical);
    view:SetViewId(nPetId);
    view:SetTag(nPetId);
    view:SetMovableViewer(container);
    view:SetScrollViewer(container);
    view:SetContainer(container);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        return false;
    end

    uiLoad:Load("Reloading/Reloading_L.ini", view, p.OnUIUserItemEvent, 0, 0);
       
    --实例化每一项
    p.RefreshUserItem( view, nPetId );
    
    container:AddView( view );
    uiLoad:Free();
end

function p.RefreshUserItem( view, nPetId )
    
    local btnPic   = GetImage(view, TAG_LIST_ITEM_PIC_BTN);
    local btnSz    = GetButton(view, TAG_LIST_ITEM_SIZE_BTN);
    local lblName  = GetLabel(view, TAG_LIST_ITEM_NAME_LBL);
    local lblLevel = GetLabel(view, TAG_LIST_ITEM_LEVEL_LBL);
    
    
    local pPicImg   = p.getPicture(nPetId);
    local sName     = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    local nLevel    = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    btnPic:SetPicture(pPicImg);
    btnSz:SetParam1(nPetId);
    lblName:SetText(sName);
    lblLevel:SetText(nLevel..GetTxtPub("Level"));
    
    ItemPet.SetLabelColor(lblName, nPetId);
    
    local container= p.GetUserContainer();
    container:SetViewSize(btnSz:GetFrameRect().size)
end

function p.FullRightTopInfo(nPetId)
    local nPetId = p.nPetId;
    if(not CheckN(nPetId)) then
        LogInfo("p.FullRightTopInfo not CheckN(nPetId)");
        return;
    end

    local layer = p.GetCurrLayer();
    local btnPic   = GetImage(layer, TAG_BOX_PIC1_BTN);
    local lblName  = GetLabel(layer, TAG_BOX_NAME1_LBL);
    local lblLevel = GetLabel(layer, TAG_BOX_LEVEL1_LBL);
    
    local pPicImg   = p.getPicture(nPetId);
    local sName     = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    local nLevel    = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    ItemPet.SetLabelColor(lblName, nPetId);
    
    btnPic:SetPicture(pPicImg);
    lblName:SetText(sName);
    lblLevel:SetText(nLevel..GetTxtPub("Level"));
end

function p.FullRightDownInfo(nPetId)
    if(not CheckN(nPetId)) then
        LogInfo("p.FullRightDownInfo not CheckN(nPetId)");
        return;
    end
    
    local layer = p.GetCurrLayer();
    local btnPic   = GetImage(layer, TAG_BOX_PIC2_BTN);
    local lblName  = GetLabel(layer, TAG_BOX_NAME2_LBL);
    local lblLevel = GetLabel(layer, TAG_BOX_LEVEL2_LBL);
    
    local pPicImg   = p.getPicture(nPetId);
    local sName     = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    local nLevel    = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL);
    
    ItemPet.SetLabelColor(lblName, nPetId);
    
    btnPic:SetPicture(pPicImg);
    lblName:SetText(sName);
    lblLevel:SetText(nLevel..GetTxtPub("Level"));
end

function p.SelectUserFocus(nPetId)
    local uContainer = p.GetUserContainer();
    for i=1, uContainer:GetViewCount() do
        local view = uContainer:GetView(i-1);
        
        local petBtn = GetButton(view, TAG_LIST_ITEM_SIZE_BTN);
        if(petBtn == nil) then
            LogInfo("p.SelectEquipFouce petBtn is nil!");
            return;
        end 
        if(view:GetViewId() ~= nPetId) then
            petBtn:SetFocus(false);
        else
            petBtn:SetFocus(true);
        end
    end
end

function p.GetUserContainer()
    local layer = p.GetCurrLayer();
    local container = GetScrollViewContainer(layer, TAG_CONTAINER);
    return container;
end

function p.GetCurrLayer()
	if p.sParent == nil then
		return nil;
	end
    
    local layer = GetUiLayer(p.sParent, NMAINSCENECHILDTAG.QuickSwapEquipUI);
    return layer;
end

function p.getPicture(nId)
	if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
    --**chh 2012-06-08
    if(nPetType == 0) then
        LogInfo("p.getPicture nPetType is nil!");
        return nil;
    end
    local rtn = GetPetPotraitPic(nPetType);
	return rtn;
end


