---------------------------------------------------
--描述: 每日活动列表界面
--时间: 2012.9.12
--作者: 
---------------------------------------------------
DailyAction = {}
local p = DailyAction;

p.dbEnventActivicyInfo = {};  --静态表event_activity的数据
p.WorldActions = {};    --世界活动信息
p.ClassActions = {};     --帮派活动信息


p.CurFocusBtnId   = 0;    --当前的焦点按钮
p.TabInfo = { WorldInfo      =     {LayerTag = 1001, tabBtnId = 24,  focusIndex = 1, 
                                                            FucRefresh = nil, viewId = 101,},
                       
                       ClassInfo  =    {LayerTag = 1002,  tabBtnId = 25,  focusIndex = 2, 
                                                           FucRefresh = nil, FucOnEvent = nil, viewId = 101,},
                       
                       EveryDayActInfo  =  {LayerTag = 1003,  tabBtnId = 26,  focusIndex = 1, 
                                                            FucRefresh = nil, FucOnEvent = nil, },
}

p.CtrlId = {btnClose = 5, };
p.ViewCtrlId = {pic = 110, txtTime = 104, txtContent = 105, btnCtr = 100,};

local RectSubUILayer = CGRectMake(0, 39*ScaleFactor, 480*ScaleFactor, 275.0*ScaleFactor);
local ListViewSize = CGSizeMake(430*ScaleFactor, 50*ScaleFactor);

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

function p.LoadUI()
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end

    --------------------添加每日活动层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.DailyActionUI);
	layer:SetDebugName( "DailyAction" ); --@opt
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.ActivityLayer);
    
    -----------------初始化ui添加到 layer 层上----------------------------------
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("event/event.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);

    local btn = GetButton(layer, p.TabInfo.ClassInfo.tabBtnId);
    --btn:EnalbeGray(true);
    btn:SetVisible(false);
    ------------------------------------------------------------------添加世界活动层-----------------------------------------------------------------------
    local layer0 = createNDUILayer();
	if layer0 == nil then
		return false;
	end
    
	layer0:Init();
	layer0:SetTag(p.TabInfo.WorldInfo.LayerTag);
	layer0:SetFrameRect(RectSubUILayer);
    layer0:SetVisible(false);
	layer:AddChild(layer0);
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("event/event_1.ini", layer0,  p.TabInfo.WorldInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    ------------------------------------------------------------------添加帮派活动层-----------------------------------------------------------------------
    local layer1 = createNDUILayer();
	if layer1 == nil then
		return false;
	end
    
	layer1:Init();
	layer1:SetTag(p.TabInfo.ClassInfo.LayerTag);
	layer1:SetFrameRect(RectSubUILayer);
    layer1:SetVisible(false);
	layer:AddChild(layer1);
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("event/event_1.ini", layer1,  p.TabInfo.ClassInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    ------------------------------------------------------------------添加日常活动层-----------------------------------------------------------------------
    local layer2 = createNDUILayer();
	if layer2 == nil then
		return false;
	end
    
	layer2:Init();
	layer2:SetTag(p.TabInfo.EveryDayActInfo.LayerTag);
	layer2:SetFrameRect(RectSubUILayer);
    layer2:SetVisible(false);
	layer:AddChild(layer2);
    AssistantUI.AssisLayer = layer2;
    
    --初始化ui添加到 layer 层上
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("event/event_1.ini", layer2,  p.TabInfo.EveryDayActInfo.FucOnEvent, CONTAINTER_X, CONTAINTER_Y);
    uiLoad:Free();
    
    -------------------------------初始化数据------------------------------------     
    p.initData();
    p.ChangeTab(p.TabInfo.WorldInfo.tabBtnId);
    
    local closeBtn = GetButton(layer, p.CtrlId.btnClose);
    closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    return true;
end

-------------------------------切换标签界面----nBtnId要切换的tab页面的按钮id----------------------------------------
function p.ChangeTab(nBtnId)
    
    if (nBtnId == nil) or (p.CurFocusBtnId == nBtnId) then 
        return;
    end
    
    p.CurFocusBtnId = nBtnId;
    
    local layerMain = p.GetMainLayer();
   
     --设置显示的layer页面
    for i,v in pairs(p.TabInfo) do
        local btn = GetButton(layerMain, v.tabBtnId);
        local layer = p.GetLayerByTag(v.LayerTag);    
        
        if v.tabBtnId == nBtnId then
            btn:TabSel(true);            --当前按钮设置为常亮
            layer:SetVisible(true);   --设置当前层为活动层
        else
            btn:TabSel(false);           --其他按钮去掉常亮标志
            layer:SetVisible(false);   --设置当前层为非活动层
        end
    end

    p.RefreshUI(nBtnId);    
end

---------------------------刷新龙将兵法的主页面层数据--------------------------------------
function p.RefreshUI(nBtnId)

    for i, v in pairs(p.TabInfo) do
         if v.tabBtnId == nBtnId then
            if v.FucRefresh ~= nil then
               v.FucRefresh();
            end
        end
    end
end
---------------------------获取龙将兵法的主页面层--------------------------------------
function p.GetMainLayer()
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DailyActionUI);
    return layer;
end

---------------------------通过子层标签获取层--------------------------------------
function p.GetLayerByTag(SublayerTag)
    local layer = p.GetMainLayer();
    local Sublayer = GetUiLayer(layer, SublayerTag);
    if(Sublayer == nil) then
        LogInfo("p.GetLayerByTag:[%d] is nil!", SublayerTag);
    end
    return Sublayer;
end
-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	
    local tag = uiNode:GetTag();
    local type = NUIEventType.TE_TOUCH_BTN_CLICK;
    
	if uiEventType == type then
		if p.CtrlId.btnClose == tag then                           
			CloseUI(NMAINSCENECHILDTAG.DailyActionUI);
        --elseif  p.TabInfo.ClassInfo.tabBtnId == tag  then
            --CommonDlgNew.ShowYesDlg("帮派活动暂未开启,敬请关注,谢谢!",nil,nil,3);
        else
            --处理几个标签页的按钮
            for i, v in pairs(p.TabInfo) do
                if v.tabBtnId == tag then
                    p.ChangeTab(tag);
                    break;
                end
            end  
        end
	end
    
	return true;
end


---------------------------关闭礼包窗口--------------------------------------
function p.freeData()
    --MsgActivityMix.mUIListener = nil;
end

---------------------------添加控件元素-------------------------------------
function p.AddViewItem(container, nId, uiFile)
    
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.LoadUI createUIScrollView failed");
        return;
    end
    
    container:SetViewSize(ListViewSize);
    
    view:Init(false);
    view:SetViewId(nId);
    view:SetTag(nId);  
    view:SetDebugName( "UIScrollView_" .. nId );
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
    
    uiLoad:Load(uiFile, view, p.OnViewUIEvent, 0, 0);
    --uiLoad:Load(uiFile, view, nil, 0, 0);
    
    p.refreshViewItem(view, nId);
end
---------------------------刷新控件元素-------------------------------------
function p.refreshViewItem(view, nId)

    local btn = GetButton(view, p.ViewCtrlId.btnCtr);
    btn:SetParam1(nId);   
    
    --按钮是否置灰判断   世界活动的时候才用到
    if p.CurFocusBtnId == p.TabInfo.WorldInfo.tabBtnId then
        local DataList = p.WorldActions;
        for i, v in pairs(DataList) do
            if v.nId == nId then
                if v.bStatus ~= 3 then  --未开启
                    btn:EnalbeGray(true);                          
                end
                break;
            end
        end
    end
    
    if  p.dbEnventActivicyInfo ~= nil then
        local info = p.dbEnventActivicyInfo[nId]; 
        local pool = _G.DefaultPicPool();
        local CtrPic = GetImage(view, p.ViewCtrlId.pic);
        LogInfo("refresh icon = %d", info.Icon); 
        local Pic = pool:AddPicture( _G.GetSMImg00Path( "action/activity"..info.Icon..".png"), false);  
        CtrPic:SetPicture(Pic);
        local str = p.GetTimeStr(info);
        str = info.Name..str;
        SetLabel(view, p.ViewCtrlId.txtTime, str); 
        SetLabel(view, p.ViewCtrlId.txtContent, info.Describe); 
        
        
        --[[
        --隐藏自动参战UI
        local checkBox = RecursiveCheckBox(view,{7});
        checkBox:SetVisible(false);
        local labelTxt = GetLabel(view, 8);
        labelTxt:SetVisible(false);
        ]]
    end
    
    return;
end

------------------获取要显示的时间文字------------------------------
function p.GetTimeStr(info)
    local str = "";
    return str;
end
------------------列表控件按键响应-------------------------------
function p.OnViewUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    LogInfo("p.OnViewUIEvent tag = %d", tag); 
        
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        local btn = ConverToButton(uiNode);
        
        if(btn == nil) then
            LogInfo("btn is nil!");
            return;
        end

        if p.ViewCtrlId.btnCtr == tag then       
            local nId = btn:GetParam1();
            LogInfo("p.OnViewUIEvent nId = %d", nId); 
            p.SendActionInfo(nId);
            ShowLoadBar();
            --CloseUI(NMAINSCENECHILDTAG.DailyActionUI);
        end
    end
	return true;
end

------------------首次充值消息响应-------------------------------
function p.SendActionInfo(nId)  
    LogInfo("send begin"); 

	local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
    
    LogInfo("send begin nId = %d", nId); 
    netdata:WriteByte(9);
    netdata:WriteInt(nId);	
    netdata:WriteInt(0);	   
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("send  end"); 
	return true;	
end

---------------------------初始化显示的数据--------------------------------------
function p.initData()
    p.dbEnventActivicyInfo = {};
    LogInfo("p.initData begin");
    
    local Idlist = GetDataBaseIdList("event_activity");
    
    for i, v in pairs(Idlist) do
        p.dbEnventActivicyInfo[v] = {};
        local record = p.dbEnventActivicyInfo[v];
        record.Name = GetDataBaseDataS("event_activity", v, DB_EVENT_ACTIVITY.NAME);    
        record.Icon = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.ICON);    
        record.TimeType = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.TIME_TYPE);    
        record.Group = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.GROUP);     
        record.BeginDay = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.BEGIN_DAY); 
        record.EndDay = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.END_DAY);    
        record.PointTime = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.POINT_TIME);    
        record.Continouans = GetDataBaseDataN("event_activity", v, DB_EVENT_ACTIVITY.CONTINOUANS);    
        record.Describe = GetDataBaseDataS("event_activity", v, DB_EVENT_ACTIVITY.DESCRIBE);       
    end
    
    for i, v in pairs(p.dbEnventActivicyInfo) do
        LogInfo("i = %d name = %s, icon = %d, timetype = %d, beginDay = %d, endDay = %d, pointTime = %d, continouans = %d, describe = %s",
                        i, v.Name, v.Icon, v.TimeType, v.BeginDay, v.EndDay, v.PointTime, v.Continouans, v.Describe); 
    end
    
   p.TabInfo.WorldInfo.FucRefresh = p.WorldRefresh;
   
   p.TabInfo.ClassInfo.FucRefresh = p.ClassRefresh;
   p.TabInfo.ClassInfo.FucOnEvent = p.ClassOnEvent;
   
   p.TabInfo.EveryDayActInfo.FucRefresh = p.EveryDayActRefresh;
   p.TabInfo.EveryDayActInfo.FucOnEvent = p.EveryDayActOnEvent;
   p.CurFocusBtnId = 0;
   
    --日常活动初始化
    AssistantUI.initData();
    --注册军令更新事件
    AssistantUI.RegisterGameDataEvent();
   
    LogInfo("p.initData end");
end

---------------------------初始化-------------------------------------
function p.WorldRefresh()
    local layer = p.GetLayerByTag(p.TabInfo.WorldInfo.LayerTag);    
    local ListContainer  = GetScrollViewContainer(layer, p.TabInfo.WorldInfo.viewId);
    
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(ListViewSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    ListContainer:SetDebugName( "ScrollViewContainer" );
    
    --设置当前要显示的说明信息
    for i, v in pairs(p.WorldActions) do
        LogInfo("refresh i = %d  nId = %d", i, v.nId); 
        p.AddViewItem(ListContainer, v.nId, "event/event_1_L.ini");
    end
end


function p.ClassRefresh()
    local layer = p.GetLayerByTag(p.TabInfo.ClassInfo.LayerTag);    
    local ListContainer  = GetScrollViewContainer(layer, p.TabInfo.ClassInfo.viewId);
    
    if (ListContainer == nil) then 
        return;
    end

    ListContainer:SetViewSize(ListViewSize);
    ListContainer:EnableScrollBar(true);
    ListContainer:RemoveAllView();
    
    --设置当前要显示的说明信息
    for i, v in pairs(p.ClassActions) do
        LogInfo("refresh i = %d  nId = %d", i, v.nId); 
        p.AddViewItem(ListContainer, v.nId, "event/event_1_L.ini");
    end
end



function p.ClassOnEvent()

end

function p.EveryDayActRefresh()
    AssistantUI.RefreshUI();
end

function p.EveryDayActOnEvent()

end



