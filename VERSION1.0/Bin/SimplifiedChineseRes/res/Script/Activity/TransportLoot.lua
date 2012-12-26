---------------------------------------------------
--描述: 运粮拦截提示页面
--时间: 2012.9.26
--作者: tzq
---------------------------------------------------
TransportLoot = {}
local p = TransportLoot;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;
p.LootPlayerId = nil;
p.IsCanBeLoot = false;
p.LootPlayerLev = 0;

p.Ctrl = {Btn = {btnClose = 46, btnLoot = 45, btnRefresh = 23, btnCall = 18,},
               Lable = {txtName = 41, txtLev = 18, txtClass = 42, txtIsLoot = 47, txtClass = 19, txtCar = 21, txtRaise = 48, txtAward = 44,},};
               
p.FoodCar = { {btnId = 11, name = GetTxtPri("TL_T1"), isFocus = true},
                        {btnId = 12, name = GetTxtPri("TL_T2"), isFocus = false},
                        {btnId = 13, name = GetTxtPri("TL_T3"), isFocus = false},
                        {btnId = 14, name = GetTxtPri("TL_T4"), isFocus = false},
                        {btnId = 15, name = GetTxtPri("TL_T5"), isFocus = false},};



function p.LoadUI(nPlayerId)

    LogInfo("TransportLoot LoadUI begin"); 
    p.LootPlayerId = nPlayerId;
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

--------------------添加粮车准备界面层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.TransportLootUI);

	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, UILayerZOrder.ActivityLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("transport/Transport_L.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
-------------------------------初始化数据------------------------------------    
    p.RefreshUI();
    return true;
end

-----------------------------刷新ui显示---------------------------------
function p.RefreshUI()
    local layer = p.GetParent();
    LogInfo("Loot RefreshUI begin");  
    p.IsCanBeLoot = false;
    
    for i, v in pairs(Transport.tbOtherUserInfo) do
        if v.nPlayerId == p.LootPlayerId then
        	SetLabel(layer, p.Ctrl.Lable.txtName, v.strPlayerName);
            SetLabel(layer, p.Ctrl.Lable.txtLev, GetTxtPub("levels")..":"..SafeN2S(v.Level));
            p.LootPlayerLev = v.Level;
            --获取该玩家被成功拦截次数
            local beLoot = v.nSucBeenLootedNum;
            local total     = Transport.tbGrainStatic.BeLootMax;
            LogInfo("beLoot = %d, total =%d", beLoot, total);  
            if beLoot < total then
                p.IsCanBeLoot = true;
                SetLabel(layer, p.Ctrl.Lable.txtIsLoot, GetTxtPri("TL_T6"));
            else
                p.IsCanBeLoot = false;
                SetLabel(layer, p.Ctrl.Lable.txtIsLoot, GetTxtPri("TL_T7"));
            end
            
			--**chh 2012-12-12**--
            --SetLabel(layer, p.Ctrl.Lable.txtClass, GetTxtPri("TL_T8"));
            SetLabel(layer, p.Ctrl.Lable.txtClass, v.strArmyGroup); 

            local label = GetLabel(layer, p.Ctrl.Lable.txtRaise);
            label:SetVisible(false);
            --SetLabel(layer, p.Ctrl.Lable.txtRaise, GetTxtPri("TL_T8"));
            local l_CarLev = SetLabel(layer, p.Ctrl.Lable.txtCar, Transport.tbGrainConfig[v.nGrain_config_id].Name);  
            l_CarLev:SetFontColor(Item.GetTransportCarQuality(v.nGrain_config_id));
            LogInfo("v.nGrain_config_id:[%d]",v.nGrain_config_id);
       
            
            local str = p.GetAwardStr(v.nGrain_config_id);    --获取要显示的奖励物品
            SetLabel(layer, p.Ctrl.Lable.txtAward, str);  --显示运送的奖励     
        end
    end

end

function p.GetAwardStr(nIndex)
    --领取的奖励提示
    local ShowText = "";
    
    --获取奖励的银币
    local Info = Transport.tbGrainConfig[nIndex]
    
    --银币
    if Info.MoneyBase ~= 0 or Info.MoneyGrow ~= 0 then
        local num = Info.MoneyBase;
        if Info.MoneyGrow ~= 0 then
            --local nPlayerId     = GetPlayerId();
            --local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
            --local nLev			= RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL);
            local nLev = p.LootPlayerLev;
            num = num + nLev * Info.MoneyGrow;
            num = math.floor(num/10);
            LogInfo("p.GetAwardStr nLev = %d, num = %d", nLev, num);     
        end
        ShowText = string.format(GetTxtPri("TL_T9").."\n",ShowText,num);
    end
    
    if nIndex > 2 then
        --Info = Transport.tbGrainConfig[nIndex - 1];
        --奖励物品
        if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
            ShowText = ShowText ..GetTxtPri("TL_T10");
        end
    end
    
    return ShowText;
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if (p.Ctrl.Btn.btnClose == tag) then         --点击离开按钮                 
			CloseUI(NMAINSCENECHILDTAG.TransportLootUI);
        elseif (p.Ctrl.Btn.btnLoot == tag) then   --点击拦截按钮
            --判断要拦截的对象是否已经被拦截过两次
            if not p.IsCanBeLoot then
                CommonDlgNew.ShowYesDlg(GetTxtPri("TL_T11"),nil,nil,3); 
            else
                --向服务端发送拦截消息
                MsgTransport.MsgSendLootInfo(MsgTransport.TransportActionType.LOOT, p.LootPlayerId);
                CloseUI(NMAINSCENECHILDTAG.TransportLootUI);
            end
        end
	end
	return true;
end

-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.TransportLootUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end