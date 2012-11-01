---------------------------------------------------
--描述: 运量准备界面
--时间: 2012.9.13
--作者: tzq
---------------------------------------------------
TransportPrepare = {}
local p = TransportPrepare;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;


p.Ctrl = {Btn = {btnClose = 30, btnStart = 29, btnRefresh = 23, btnCall = 18, btnRaise = 27},
               Lable = {curCarName = 32, transTime = 21, awardItem = 22},};
               
p.FoodCar = { {btnId = 11,  isFocus = true},
                        {btnId = 12,  isFocus = false},
                        {btnId = 13,  isFocus = false},
                        {btnId = 14,  isFocus = false},
                        {btnId = 15,  isFocus = false},};
                        
p.CarPrompt = { [1] = "破旧的木板小车,只能运送很少粮草,可获得奖励:",
                            [2] = "精铁打造的货车,运送少量粮草,可获得奖励:",
                            [3] = "采用稀有紫铜打造,载重量较大,可获得奖励:",
                            [4] = "诸葛制造,你懂得!可获得奖励:",
                            [5] = "超豪华木牛流马升级版!运送大量粮草,可获得奖励:",};                        



function p.LoadUI()
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
	layer:SetTag(NMAINSCENECHILDTAG.TransportPrepareUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer, 1);
    

-----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("transport/Transport_M.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
-------------------------------初始化数据------------------------------------    
    p.RefreshUI();

    local btnClose = GetButton(layer, p.Ctrl.Btn.btnClose);
    btnClose:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    return true;
end

-----------------------------刷新ui显示---------------------------------
function p.RefreshUI()
    LogInfo("prepare RefreshUI begin");  
    local layer = p.GetParent();
    local CarIndex = Transport.tbPlayerInfo.nGrain_config_id;
    LogInfo("prepare CarIndex = %d", CarIndex);  
    --CarIndex = 2;
    --显示粮车相关信息
    for i, v in pairs(p.FoodCar) do
        LogInfo("i = %d, v.btnId = %d", i, v.btnId);  
        LogInfo("id = %d, name = %s, CarIndex = %d",Transport.tbGrainConfig[i].id, Transport.tbGrainConfig[i].Name, CarIndex);     
        local btn = GetButton(layer, v.btnId);     
        
        if i == CarIndex then
            LogInfo("i = %d, name = %s", i, Transport.tbGrainConfig[i].Name);   
            btn:TabSel(true);      
            btn: SetFocus(true);
            SetLabel(layer, p.Ctrl.Lable.curCarName, Transport.tbGrainConfig[i].Name);    --显示当前粮车的名字
            SetLabel(layer, p.Ctrl.Lable.transTime, FormatTime(Transport.tbGrainConfig[i].LastTime, 0));   --显示要运送的时间   
            local str = p.GetAwardStr(CarIndex, 0);    --获取要显示的奖励物品
            SetLabel(layer, p.Ctrl.Lable.awardItem, str);  --显示运送的奖励           
            
        else
            btn:TabSel(false);   
            btn: SetFocus(false);
        end     
    end
end

-----获取当前粮车可以获取的奖励物品----nIndex要运送的粮车---showFlag 0:不显示提示文字 1:显示提示文字-------------------
function p.GetAwardStr(nIndex, showFlag)

    --领取的奖励提示
    local ShowText = "";
    local Info = Transport.tbGrainConfig[nIndex]
    if showFlag == 1 then
        ShowText = ShowText .. p.CarPrompt[nIndex];
    end
    --奖励物品
    if (Info.ItemType ~= 0) and  (Info.ItemCount ~= 0) then
        if showFlag == 0 then
            ShowText = ShowText .. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount.."\n";
        else
            ShowText = ShowText .. ItemFunc.GetName(Info.ItemType) .."X"..Info.ItemCount..",";     
        end
    end
    
    LogInfo("p.GetAwardStr Base = %d, Grow = %d", Info.MoneyBase, Info.MoneyGrow);  
    --银币
    if Info.MoneyBase ~= 0 or Info.MoneyGrow ~= 0 then
        local num = Info.MoneyBase;
        if Info.MoneyGrow ~= 0 then
            local nPlayerId     = GetPlayerId();
            local mainpetid 	= RolePetUser.GetMainPetId(nPlayerId);
            local nLev			= RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL);
            num = num + nLev * Info.MoneyGrow;
            LogInfo("p.GetAwardStr nLev = %d, num = %d", nLev, num);     
        end
        ShowText = ShowText .."银币".."X"..num.."\n";
    end

    return ShowText;
end

-----------是否刷新粮车响应函数---------------------------------
function p.onRefreshTransCar(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        --向服务端发送刷新粮车消息
        MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.REFRESH_CAR);
    end
end

-----------召唤最高品质粮车响应函数---------------------------------
function p.CallBestTransCar(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
        --向服务端发送召唤粮车消息
        MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.CALL_CAR);
    end
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

	local tag = uiNode:GetTag();
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if (p.Ctrl.Btn.btnClose == tag) then         --点击离开按钮                 
			CloseUI(NMAINSCENECHILDTAG.TransportPrepareUI);
        elseif (p.Ctrl.Btn.btnStart == tag) then   --点击开始运粮按钮
            --向服务端发送开始运粮消息
            MsgTransport.MsgSendTransportInfo(MsgTransport.TransportActionType.TRNSPORT);
            --ShowLoadBar();        
			CloseUI(NMAINSCENECHILDTAG.TransportPrepareUI);
        elseif (p.Ctrl.Btn.btnRefresh == tag) then   --点击刷新粮车按钮
                --获取当前粮车等级
                local CarMax = table.getn(p.FoodCar);
                if Transport.tbPlayerInfo.nGrain_config_id >= CarMax then
                    CommonDlgNew.ShowYesDlg("当前粮车已为最高等级,不需要刷新了!",nil,nil,3);
                    return true;
                end
                
                local num = (Transport.tbPlayerInfo.nRefreshCarTime + 1)* 2;
                local nPlayerId = GetPlayerId();
                local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);           

                if emoney < num then
                    CommonDlgNew.ShowYesDlg("金币不足,请充值,谢谢!",nil,nil,3);
                else
                    CommonDlgNew.ShowYesOrNoDlg( "是否花费"..num.."金币刷新运送的粮车", p.onRefreshTransCar, true );
                end
                
        elseif (p.Ctrl.Btn.btnCall == tag) then   --点击召唤粮车按钮
                --获取当前粮车等级
                local CarMax = table.getn(p.FoodCar);
                if Transport.tbPlayerInfo.nGrain_config_id >= CarMax then
                    CommonDlgNew.ShowYesDlg("当前粮车已为最高等级,不需要召唤了!",nil,nil,3);
                    return true;
                end
                
        
                local num = 200;
                local nPlayerId = GetPlayerId();
                local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);           

                if emoney < num then
                    CommonDlgNew.ShowYesDlg("金币不足,请充值,谢谢!",nil,nil,3);
                else
                    CommonDlgNew.ShowYesOrNoDlg( "是否花费200金币直接召唤"..Transport.tbGrainConfig[5].Name, p.CallBestTransCar, true );
                end
                
        elseif (p.Ctrl.Btn.btnRaise == tag) then   --点击鼓舞士气
                CommonDlgNew.ShowYesDlg("该功能暂未开启,谢谢!",nil,nil,3);
 
        else
            --点击可以运送的粮车,提示奖励的物品
            for i, v in pairs(p.FoodCar) do 
                if v.btnId == tag then
                    local str = p.GetAwardStr(i, 1);
                    CommonDlgNew.ShowYesDlg( str, nil, nil, 3 );
                    break;
                end
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
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.TransportPrepareUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end