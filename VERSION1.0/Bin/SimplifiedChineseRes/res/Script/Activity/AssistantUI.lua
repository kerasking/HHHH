---------------------------------------------------
--描述: 助手界面
--时间: 2012.6.21
--作者: chh
---------------------------------------------------
AssistantUI = {}
local p = AssistantUI;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local TAG_CLOSE         = 533;
local TAG_GIFT_LIST     = 101;

local TAG_LIST_DESC      = 104;
local TAG_LIST_TAKE      = 105;

p.AssistantList = {};    --助手列表

p.GiftBackList = {};     --礼包列表

p.GifeItemSize = CGSizeMake(480*CoordScaleX, 45*CoordScaleY);
local TagImageSize = 13;

p.Infos = {};

p.RankGifeType = 2;       --军衔礼包类型

p.AssisLayer = nil;


--------------------------------------------------------------
function p.RegisterGameDataEvent()
    GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.StaminaUpdateEvent",p.StaminaUpdateEvent);
end

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("ass p.OnUIEven1t[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if TAG_CLOSE == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.GameAssistantUI);
        elseif (TAG_LIST_TAKE == tag) then
			local btn = ConverToButton(uiNode);
            local typeId = btn:GetParam1();
            LogInfo("ass typeId = %d", typeId);
            if(typeId == 1) then
                p.buyMilitaryOrdersDeal();
            elseif(typeId == 2) then
                p.levyDeal();
            elseif(typeId == 3) then
                p.salaryDeal();
            elseif(typeId == 4) then
                p.sportsDeal();
            elseif(typeId == 5) then    --运粮
                p.ylDeal();
            elseif(typeId == 6) then    --签到
                p.qdDeal();
            end
        end
        
	end
	return true;
end


---------------------------关闭助手窗口--------------------------------------
function p.freeData()
    MsgActivityMix.mUIListener = nil;
    p.GiftBackList = nil;
    p.Infos = nil;
    p.AssistantList = nil;
    GameDataEvent.UnRegister(GAMEDATAEVENT.USERATTR,p.StaminaUpdateEvent);
end


---------------------------初始化助手窗口--------------------------------------
function p.initData()
    p.GiftBackList = MsgActivityMix.GetGiftBackLists();
    
    p.AssistantList = {};

    p.Infos = {
        {GetTxtPri("GouMaiRankCount"),GetTxtPri("ZS_GouMai"),0},
        {GetTxtPri("ZhenShouCount"),GetTxtPri("ZS_ZhenSou"),0},
        {GetTxtPri("FenLuCount"),GetTxtPri("ZS_LinQu"),0},
        {GetTxtPri("TiaoZhanCount"),GetTxtPri("ZZ_JinJi"),0},
        {GetTxtPri("YunLiangCount"),GetTxtPri("ZZ_YunLiang"),0},
        {GetTxtPri("QianDaoCount"),GetTxtPri("ZZ_QianDao"),0},
    };


    --军令判断
    local allowBuyCount = p.allowBuyStaminaCount();
    if(allowBuyCount>0) then
        LogInfo("allowBuyCount:[%d]",allowBuyCount);
        table.insert(p.AssistantList,1);
        LogInfo("assis p.initData  table.insert(p.AssistantList,1)");
        p.Infos[1][1] = string.format(p.Infos[1][1],allowBuyCount);
        p.Infos[1][3] = allowBuyCount;
    end
    
    
    
    --征收判断
    local allowLevyCount = p.allowLevyCount();
    if(allowLevyCount>0 and IsFunctionOpen(StageFunc.Levy)) then
        LogInfo("allowLevyCount:[%d]",allowLevyCount);
        table.insert(p.AssistantList,2);
        LogInfo("assis p.initData  table.insert(p.AssistantList,2)");
        p.Infos[2][1] = string.format(p.Infos[2][1],allowLevyCount);
        p.Infos[2][3] = allowLevyCount;
    end
    
    
    --俸禄
    local salaryIds = {};
    for i,v in ipairs(p.GiftBackList) do
        if(v.type == p.RankGifeType) then
            table.insert(salaryIds,v.id);
            p.Infos[3][3] = v.id;
            break;
        end
    end
    
    if(#salaryIds>0) then
        LogInfo("salaryIds:[%d]",#salaryIds);
        table.insert(p.AssistantList,3);
        LogInfo("assis p.initData  table.insert(p.AssistantList,3)");
        p.Infos[3][1] = string.format(p.Infos[3][1],#salaryIds);
    end
    
    
    
    
    --竞技场判断
    local allowSportsCount = p.allowSportsCount();
    LogInfo("assis p.initData  allowSportsCount = %d", allowSportsCount);
    if(allowSportsCount>0 and IsFunctionOpen(StageFunc.Arena)) then
        LogInfo("allowSportsCount:[%d]",allowSportsCount);
        table.insert(p.AssistantList,4);
        LogInfo("assis p.initData  table.insert(p.AssistantList,4)");
        p.Infos[4][1] = string.format(p.Infos[4][1],allowSportsCount);
        p.Infos[4][3] = allowSportsCount;
    end
    
    --运粮次数判断
    local tInfo = MsgTransport.GetTransportCount();
    if(tInfo.YLCount >0 or tInfo.RJCount >0) then
        table.insert(p.AssistantList,5);
        p.Infos[5][1] = string.format(p.Infos[5][1],tInfo.YLCount,tInfo.RJCount);
    end
    
    --签到
    local bIsSigh = DailyCheckInUI.HasSigh();
    if(bIsSigh) then
        table.insert(p.AssistantList,6);
        p.Infos[6][1] = string.format(p.Infos[6][1]);
    end
    
	MsgActivityMix.mUIListener = p.processNet;
end

--军令更新事件
function p.StaminaUpdateEvent()
    if IsUIShow(NMAINSCENECHILDTAG.DailyActionUI) then
        LogInfo("p.StaminaUpdateEvent event!");
        p.initData();
        p.RefreshUI();
    end
end

--允许购买军令
function p.allowBuyStaminaCount()
    return PlayerVIPUI.allowBuyCount();
end

--允许征收的次数
function p.allowLevyCount()
    local total_levy = GetVipVal(DB_VIP_CONFIG.LEVY_NUM);
    local alert_levy = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_BUYED_LEVY);
    return total_levy-alert_levy;
end

--允许竞技场PK的次数
function p.allowSportsCount()
    return MsgArena.GetArenaPKCount();
end



--购买军令
function p.buyMilitaryOrdersDeal()
    PlayerVIPUI.buyMilOrderTip(0);
    --ShowLoadBar();
end


--征收
function p.levyDeal()
    CloseMainUI();
    Levy.LoadUI();
end


--领取俸禄处理
function p.salaryDeal()
    MsgActivityMix.SendGetGift(p.Infos[3][3]);
    ShowLoadBar();
end


--竞技场处理
function p.sportsDeal()
    CloseMainUI();
    _G.MsgArena.SendOpenArena();
end

function p.ylDeal()
    CloseMainUI();
    --打开运粮
    DailyAction.SendActionInfo(4);--发送打开运粮消息
    ShowLoadBar();
end

function p.qdDeal()
    CloseMainUI();
    DailyCheckInUI.LoadUI();
end

---------------------------初始化助手信息-----------------------------------
function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("MsgActivityMix processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_GIFTPACK_LIST then
        p.StaminaUpdateEvent();
    elseif(msgId == NMSG_Type._MSG_GET_GIFTPACK) then
        
        p.ShowGetGiftInfo(data);                    --显示获得信息
        MsgActivityMix.DelGiftById(data);           --删除本地缓存数据
        p.StaminaUpdateEvent();
	end
end


--显示获得助手内容的信息
function p.ShowGetGiftInfo(id)
    local gift = nil;
    for i=1,#p.GiftBackList do
        if(p.GiftBackList[i].id == id) then
            gift = p.GiftBackList[i];
            break;
        end
    end
    
    if(gift == nil) then
        LogInfo("p.ShowGetGiftInfo id:[%d] not data!",id);
        return;
    end
    
    local info = "";
    if(gift.type == 1 ) then
        if(not CheckN(gift.aux_param0) or
            not CheckN(gift.param1) or
            not CheckN(gift.param0)) then
            LogInfo("获得竞技场助手参数错误。");
            return;
        end
        info = string.format(GetTxtPri("ZS_JinJiPaiMing"),gift.aux_param0,gift.param1,gift.param0);
    elseif(gift.type == 2 ) then
        if(not CheckN(gift.aux_param0)) then
            LogInfo("获得军衔参数错误gift.aux_param0。");
            return;
        end
        local name = GetDataBaseDataS("rank_config",gift.aux_param0,DB_RANK.RANK_NAME);
        if(name == nil or not CheckN(gift.param0)) then
            LogInfo("获得军衔参数错误name and 。gift.param0");
            return;
        end
        info = string.format(GetTxtPri("ZS_FengRu"),name, gift.param0);
    elseif(gift.type == 3 ) then
        
    elseif(gift.type == 4 ) then
        
    elseif(gift.type == 5 ) then
        if(not CheckN(gift.aux_param0) or
            not CheckN(gift.param1) or
            not CheckN(gift.param0)) then
            LogInfo("获得通用助手参数错误。");
            return;
        end
        
        info = GetTxtPri("CB2_T17")..":";
        if(gift.param0>0) then
            info = string.format(GetTxtPri("ZS_YuanBao"),info,gift.param0);
        end
        
        if(gift.param0>0) then
            info = string.format(GetTxtPri("ZS_YinBi"),info,gift.param1);
        end
        
        if(gift.aux_param0>0) then
            local name = GetDataBaseDataS("itemtype", gift.param1, DB_ITEMTYPE.NAME);
            if(CheckS(name)) then
                info = string.format("%s %s",info, name);
            end
        end
    end
    
    CommonDlgNew.ShowYesDlg(info,nil,nil,3);
end


--刷新助手
function p.RefreshUI()
    local container = p.GetGiftListContainer();
    container:RemoveAllView();
    container:EnableScrollBar(true);
    local rectview = container:GetFrameRect();
    container:SetViewSize(p.GifeItemSize);
    
    for i, v in ipairs(p.AssistantList) do
        p.CreateAssistantItem(container,i);
	end
end

function p.CreateAssistantItem(container,i)

        local view = createUIScrollView();
        if view == nil then
            return;
        end
        view:Init(false);
        view:SetViewId(i);
        view:SetTag(i);
        view:SetMovableViewer(container);
        view:SetScrollViewer(container);
        view:SetContainer(container);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end
        
        LogInfo("ass p.CreateAssistantItem uiLoad:Load begin");  
        uiLoad:Load("event_2_L.ini", view, p.OnUIEvent, 0, 0);
        
        --实例化每一项
        p.RefreshAssistantItem(view,i);
        LogInfo("p.CreateAssistantItem p.RefreshAssistantItem end");
        uiLoad:Free();
        
        container:AddView(view);
end

function p.RefreshAssistantItem(view,i)  
    if(not CheckN(i)) then
        LogInfo("p.RefreshAssistantItem param error!");
        return;
    end
    
    local gift = p.AssistantList[i];
    if(gift == nil) then
        LogInfo("p.RefreshAssistantItem p.AssistantList[%d] is nil!", i);
        return;
    end
    
    SetLabel(view,TAG_LIST_DESC,p.Infos[gift][1]);
    
    local btn = GetButton(view, TAG_LIST_TAKE);
    btn:SetTitle(p.Infos[gift][2]);
    btn:SetParam1(gift);
    
    local img = GetImage(view, TagImageSize);
    local container = p.GetGiftListContainer();
    container:SetViewSize(img:GetFrameRect().size);
end

--获得助手列表
function p.GetGiftListContainer()
	local layer = p.GetLayer()
	local container = GetScrollViewContainer(layer, TAG_GIFT_LIST);
	return container;
end

--获得当前窗口层
function p.GetLayer()
    if p.AssisLayer == nil then
        LogInfo("p.GetLayer() p.AssisLayer == nil");    
    end
    return p.AssisLayer;
end
