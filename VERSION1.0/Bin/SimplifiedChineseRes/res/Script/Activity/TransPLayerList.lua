---------------------------------------------------
--描述: 玩家列表
--时间: 2012.9.13
--作者: tzq
---------------------------------------------------
TransPlayerList = {}
local p = TransPlayerList;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

p.CtrId = {listId = 50, btnClose = 49, btnLoot= 7, txtName = 70, txtLev = 72, txtCarLev = 75, txtIsLoot = 71, 
                 ViewSize = CGSizeMake(400*ScaleFactor, 25*ScaleFactor),};

function p.LoadUI ()
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    --------------------添加人物列表层---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.TransPlayerListUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.ActivityLayer+1);
    -----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("transport/Transport_playerList.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    
    p.RefreshUI();

    return true;
end

-----------------------------初始化数据---------------------------------
function p.RefreshUI()
    LogInfo("tzq RefreshUI begin"); 

    local layer = p.GetParent();
    local ListContainer  = GetScrollViewContainer(layer, p.CtrId.listId);
    
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(p.CtrId.ViewSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    
    LogInfo("tzq RefreshUI show"); 
    --设置当前要显示的说明信息
    local nPlayerId = GetPlayerId();  
    for i, v in pairs(Transport.tbOtherUserInfo) do
        LogInfo("tzq p.RefreshUI i = %d", i);   
        if v.nPlayerId ~= nPlayerId then
            p.AddViewItem(ListContainer, v.nPlayerId, "transport/Transport_playerList_L.ini", v);
        end
    end
end

---------------------------添加控件元素-------------------------------------
function p.AddViewItem(container, nId, uiFile, info)
    
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.LoadUI createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(p.CtrId.ViewSize);
    
    view:Init(false);
    view:SetViewId(nId);
    view:SetTag(nId);  
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    
    LogInfo("tzq p.AddViewItem uiFile = %s", uiFile); 
    uiLoad:Load(uiFile, view, p.OnUIEvent, 0, 0);
    
    p.refreshViewItem(view, nId, info);
end

---------------------------刷新控件元素-------------------------------------
function p.refreshViewItem(view, nId, info)
    local btn = GetButton(view, p.CtrId.btnLoot);
    btn:SetParam1(nId);   
    local nPlayerId = GetPlayerId();  

	SetLabel(view, p.CtrId.txtName, info.strPlayerName);
 	SetLabel(view, p.CtrId.txtLev, SafeN2S(info.Level));   
    
    local beLoot = info.nSucBeenLootedNum;
    local total     = Transport.tbGrainStatic.BeLootMax;
    local btn = GetButton(view, p.CtrId.btnLoot);
    
    
    SetLabel(view, p.CtrId.txtIsLoot, info.strArmyGroup);
    
    if beLoot < total and nPlayerId ~= info.nLooterId1 and  nPlayerId ~= info.nLooterId2 then
        p.IsCanBeLoot = true;
        --SetLabel(view, p.CtrId.txtIsLoot, GetTxtPri("TPL2_T1"));
        btn:EnalbeGray(false);
    else
        p.IsCanBeLoot = false;
        --SetLabel(view, p.CtrId.txtIsLoot, GetTxtPri("TPL2_T2"));
        btn:EnalbeGray(true);
    end
    
    local l_CarLev = SetLabel(view, p.CtrId.txtCarLev, Transport.tbGrainConfig[info.nGrain_config_id].Name);   
    LogInfo("chh_info.nGrain_config_id:[%d]",info.nGrain_config_id);
    l_CarLev:SetFontColor(Item.GetTransportCarQuality(info.nGrain_config_id)); 

    return;
end




function p.OnUIEvent(uiNode, uiEventType, param)
    local BtnClick = NUIEventType.TE_TOUCH_BTN_CLICK;
    local tag = uiNode:GetTag();
    
    if uiEventType == BtnClick then
        if p.CtrId.btnClose == tag then                   --关闭    
            CloseUI(NMAINSCENECHILDTAG.TransPlayerListUI);
        else
            local btn = ConverToButton(uiNode);
            if(btn == nil) then
                LogInfo("btn is nil!");
                return true;
            end
            
            if p.CtrId.btnLoot == tag then       
                local nId = btn:GetParam1();
                
                --获取是否再拦截冷却当中
                local cdTime = Transport.tbTimer.LootTimer.CountDownNum;
                if cdTime > 0 then
                    CommonDlgNew.ShowYesDlg(GetTxtPri("TPL2_T3"),nil,nil,3);
                    return true;
                end
            
                --获取还可以拦截别人的次数
                local LootTime = Transport.tbGrainStatic.LootMax - Transport.tbPlayerInfo.nLootOtherNum;
                if LootTime <= 0 then
                    CommonDlgNew.ShowYesDlg(GetTxtPri("TPL2_T4"),nil,nil,3);
                    return true;
                end
                
                --向服务端发送拦截消息
                MsgTransport.MsgSendLootInfo(MsgTransport.TransportActionType.LOOT, nId);
                CloseUI(NMAINSCENECHILDTAG.TransPlayerListUI);
            end
        end
    end
    return true;
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.TransPlayerListUI);
	if nil == layer then
		return nil;
	end
    
	return layer;
end